"""
leanstack/warm.py — pre-fill the OS page cache with .olean files, and measure how much is resident.

Why: after an OOM kill the kernel has already evicted the clean page cache (it does that before it
kills), so the next `lake env lean` faults every imported .olean back in from the persistent disk —
observed at ~2 MB/s and 1% CPU for 20–40 min on this VM. Reading the files once, sequentially and in
large chunks, is the cheapest way to get them back; afterwards Lean's mmap finds them in memory.

Run it BEFORE a build session, never during one: it competes for the same disk bandwidth.
`warm_files` reads only the files you give it; `olean_closure` computes the exact set one module
imports (parsing source headers, no Lean), so you warm the few GB you need, not all of Mathlib.

Mathlib v4.33.1 is built with the module system: each module has `.olean` (public part),
`.olean.server` and `.olean.private`. Our libraries are not `module` files, and on this VM the
`.olean.private` files of DualScaleDyons' import closure were 87% page-cache resident after the
main session's compiles (fincore, 2026-09-19) — evidence that non-module importers load them too.
So `with_parts` adds the sibling parts by default; the closure of DualScaleDyons is 10,431 modules,
2.19 GB of `.olean` + 0.13 GB `.server` + 4.65 GB `.private` ≈ 7.0 GB (measured sizes).

Resident-size measurement uses util-linux `fincore` when it is installed (it is on this VM).
"""

import os
import shutil
import subprocess
import time
from pathlib import Path

from leanstack import source

CHUNK = 8 * 1024 * 1024


def toolchain_dir(root: Path) -> Path | None:
    tc = (root / "lean-toolchain").read_text().strip() if (root / "lean-toolchain").exists() else ""
    if not tc:
        return None
    name = tc.replace("/", "--").replace(":", "---")
    for base in (Path(os.environ.get("ELAN_HOME", Path.home() / ".elan")),):
        d = base / "toolchains" / name
        if d.exists():
            return d
    return None


def search_path(root: Path) -> list[tuple[Path, Path]]:
    """(source root, olean root) pairs, in Lean's search order: this package, dependencies, core."""
    pairs = [(root, root / ".lake" / "build" / "lib" / "lean")]
    pkgs = root / ".lake" / "packages"
    if pkgs.exists():
        for p in sorted(pkgs.iterdir()):
            pairs.append((p, p / ".lake" / "build" / "lib" / "lean"))
    tc = toolchain_dir(root)
    if tc:
        pairs.append((tc / "src" / "lean", tc / "lib" / "lean"))
    return pairs


def _header_imports(path: Path) -> list[str]:
    """Imports of a source file, reading only as much of it as the header needs (8 KB, doubling)."""
    size = 8192
    with open(path, "rb") as f:
        while True:
            f.seek(0)
            head = f.read(size)
            lines, complete = source.scan_header(head.decode("utf-8", errors="ignore"))
            if complete or len(head) < size:
                break
            size *= 2
    return [m for line in lines for m in (source.IMPORT_LINE.match(line).group(1).split()
                                          if source.IMPORT_LINE.match(line) else [])]


def olean_closure(modules: list[str], root: Path = source.REPO_ROOT) -> tuple[list[Path], list[str]]:
    """The .olean files of `modules` and everything they import (transitively).
    Returns (olean paths in first-visit order, modules whose source or olean could not be found)."""
    pairs = search_path(root)
    seen, order, missing = set(), [], []
    todo = list(reversed(modules))
    while todo:
        mod = todo.pop()
        if mod in seen:
            continue
        seen.add(mod)
        rel = mod.replace(".", "/")
        src = olean = None
        for s_root, o_root in pairs:
            if (o_root / (rel + ".olean")).exists():
                olean = o_root / (rel + ".olean")
                src = s_root / (rel + ".lean") if (s_root / (rel + ".lean")).exists() else None
                break
        if olean is None:
            missing.append(mod)
            continue
        order.append(olean)
        if src is not None:
            todo.extend(reversed(_header_imports(src)))
        else:
            missing.append(mod + " (no source: imports not followed)")
    return order, missing


OLEAN_PARTS = ("", ".server", ".private")


def with_parts(oleans: list[Path], parts: tuple[str, ...] = OLEAN_PARTS) -> list[Path]:
    """Each `.olean` followed by those of its sibling parts (`.olean.server`, `.olean.private`) that exist."""
    out = []
    for f in oleans:
        for suffix in parts:
            p = Path(str(f) + suffix)
            if p.exists():
                out.append(p)
    return out


def files_under(path: Path, suffix: str = ".olean") -> list[Path]:
    path = Path(path)
    if path.is_file():
        return [path]
    return sorted(p for p in path.rglob("*" + suffix) if p.is_file())


def warm_files(files: list[Path], max_bytes: int | None = None) -> dict:
    """Read files sequentially; report bytes read and throughput. Stops at `max_bytes`."""
    t0 = time.time()
    total = nfiles = 0
    buf = bytearray(CHUNK)
    for p in files:
        if max_bytes is not None and total >= max_bytes:
            break
        try:
            fd = os.open(p, os.O_RDONLY)
        except OSError:
            continue
        try:
            if hasattr(os, "posix_fadvise"):
                os.posix_fadvise(fd, 0, 0, os.POSIX_FADV_SEQUENTIAL)
            with os.fdopen(fd, "rb", buffering=0) as f:
                fd = None
                while True:
                    n = f.readinto(buf)
                    if not n:
                        break
                    total += n
                    if max_bytes is not None and total >= max_bytes:
                        break
        finally:
            if fd is not None:
                os.close(fd)
        nfiles += 1
    dt = max(time.time() - t0, 1e-9)
    return {"files": nfiles, "bytes": total, "seconds": round(dt, 3), "mb_per_s": round(total / dt / 1e6, 2)}


def resident_bytes(files: list[Path], batch: int = 400) -> dict | None:
    """Page-cache-resident bytes of `files` via `fincore` (None if fincore is not installed)."""
    if not shutil.which("fincore"):
        return None
    res = size = 0
    for i in range(0, len(files), batch):
        out = subprocess.run(["fincore", "-b", "-n", "-r", "-o", "RES,SIZE", *map(str, files[i:i + batch])],
                             capture_output=True, text=True)
        for line in out.stdout.splitlines():
            parts = line.split()
            if len(parts) == 2 and parts[0].isdigit():
                res += int(parts[0])
                size += int(parts[1])
    return {"resident_bytes": res, "size_bytes": size,
            "resident_fraction": round(res / size, 4) if size else None}
