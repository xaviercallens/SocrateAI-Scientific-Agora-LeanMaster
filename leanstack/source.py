"""
leanstack/source.py — plain-text facts about Lean source files, shared by every layer.

Nothing here runs Lean. Everything is a parse of the source text, so every result is a
*claim about the text*, not about the elaborated environment:

* `imports(text)`            the module header's imports (handles `module`, `public import`, `meta import`, `import all`);
* `own_modules(root)`        every first-party module, from the `lean_lib` roots in `lakefile.lean`;
* `lake_lean_options(root)`  the package `leanOptions` in `lakefile.lean` as `-D` flags
                             (`lake env lean` ignores them — LL.md S2.4 — so callers must pass them);
* `declarations(text)`       declaration heads with namespace, kind, docstring, statement text, line;
* `heavy_kernel_decls(text)` declarations whose proof calls `decide +kernel` (the memory-heavy ones).

Statement extraction is reused from `tools/statement_lock.py`, so `statement_hash` equals the hash
the statement lock stores (cross-checked by tests/test_leanstack.py against docs/statement_lock.json).
"""

import functools
import hashlib
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO_ROOT / "tools"))

from statement_lock import strip_comments, statement_text  # noqa: E402  (reuse, do not duplicate)

IMPORT_LINE = re.compile(r"^(?:public\s+|private\s+)?(?:meta\s+)?import\s+(?:all\s+)?(.+)$")
LEAN_LIB = re.compile(r"lean_lib\s+«?([A-Za-z0-9_.]+)»?\s+where(?P<body>(?:\n[ \t]+.*)*)")
ROOTS = re.compile(r"roots\s*:=\s*#\[([^\]]*)\]")
LEAN_OPTION = re.compile(r"⟨`([A-Za-z0-9_.]+)\s*,\s*\(?\s*([^:()⟩]+?)\s*(?::\s*[A-Za-z]+\s*)?\)?\s*⟩")

MODIFIERS = r"(?:@\[[^\]]*\]\s*)*(?:(?:private|protected|noncomputable|partial|unsafe|nonrec)\s+)*"
DECL_HEAD = re.compile(
    r"^" + MODIFIERS + r"(?P<kind>theorem|lemma|def|abbrev|instance|structure|class|inductive|opaque|axiom)"
    r"\s+(?P<name>[A-Za-z_À-῿℀-⅏«][A-Za-z0-9_'.!?À-῿₀-ₜ℀-⅏«»]*)",
    re.MULTILINE,
)
NAMESPACE = re.compile(r"^(namespace|end)\s+([A-Za-z0-9_.]+)\s*$", re.MULTILINE)
DOCSTRING_BEFORE = re.compile(r"/--([\s\S]*?)-/\s*(?:@\[[^\]]*\]\s*)*\Z")
DECIDE_KERNEL = re.compile(r"decide\s*\+kernel|decide\s*\(config\s*:=\s*\{[^}]*kernel\s*:=\s*true")
PIN = re.compile(r"papers/foundations/([A-Za-z0-9_.\-]+?\.txt)[^\n]{0,120}?\bll?\.\s?(\d+)(?:\s?[–-]\s?(\d+))?")
PIN_FILE = re.compile(r"papers/foundations/([A-Za-z0-9_.\-]+?\.txt)")
TIER = re.compile(r"\bTier\s+([ALC])\b")


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def module_of(path: Path, root: Path) -> str:
    rel = path.resolve().relative_to(root.resolve())
    return ".".join(rel.with_suffix("").parts)


def path_of(module: str, root: Path) -> Path:
    return root / (module.replace(".", "/") + ".lean")


def header(text: str) -> str:
    """The module header: the `module` / `prelude` / import lines before the first other command,
    skipping comments. Imports can only appear there. Scans only the header, not the whole file."""
    return "\n".join(scan_header(text)[0])


def scan_header(text: str) -> tuple[list[str], bool]:
    """(header lines, complete). `complete` is False when the text ended before the first
    non-header command — i.e. a caller that read only a prefix of the file must read more."""
    lines, i, n = [], 0, len(text)
    while i < n:
        if text[i].isspace():
            i += 1
        elif text.startswith("--", i):
            j = text.find("\n", i)
            if j < 0:
                return lines, False
            i = j
        elif text.startswith("/-", i):
            i = _comment_end(text, i)
            if i >= n:
                return lines, False
        else:
            j = text.find("\n", i)
            if j < 0:
                return lines, False
            line = text[i:j]
            k = line.find("--")        # trailing line comment
            s = (line if k < 0 else line[:k]).strip()
            if s in ("module", "prelude") or IMPORT_LINE.match(s):
                lines.append(s)
                i = j
            else:
                return lines, True
    return lines, False


COMMENT_TOKEN = re.compile(r"/-|-/")
COMMENT_START = re.compile(r"/-|--")


def _comment_end(text: str, start: int) -> int:
    """Index just past the (nested) block comment that starts at `start`."""
    depth, i = 0, start
    for m in COMMENT_TOKEN.finditer(text, start):
        if m.start() < i:
            continue
        depth += 1 if m.group() == "/-" else -1
        i = m.end()
        if depth == 0:
            return i
    return len(text)


def imports(text: str) -> list[str]:
    out = []
    for line in header(text).splitlines():
        m = IMPORT_LINE.match(line)
        if m:
            out.extend(m.group(1).split())
    return out


@functools.lru_cache(maxsize=16)
def _lakefile_text(lakefile: Path, mtime: float) -> str:
    return strip_comments(lakefile.read_text(encoding="utf-8"))


def lean_libs(root: Path) -> dict[str, list[str]]:
    """`lean_lib` name -> root modules, read from lakefile.lean (defaults to the lib name)."""
    lakefile = root / "lakefile.lean"
    if not lakefile.exists():
        return {}
    text = _lakefile_text(lakefile, lakefile.stat().st_mtime)
    libs = {}
    for m in LEAN_LIB.finditer(text):
        roots = ROOTS.search(m.group("body") or "")
        names = [r.strip().lstrip("`") for r in roots.group(1).split(",")] if roots else [m.group(1)]
        libs[m.group(1)] = [n for n in names if n]
    return libs


def lake_lean_options(root: Path) -> list[str]:
    """Package `leanOptions` from lakefile.lean as `-Dname=value` flags, in file order."""
    lakefile = root / "lakefile.lean"
    if not lakefile.exists():
        return []
    text = _lakefile_text(lakefile, lakefile.stat().st_mtime)
    block = re.search(r"leanOptions\s*:=\s*#\[([\s\S]*?)\]", text)
    if not block:
        return []
    return [f"-D{name}={value.strip()}" for name, value in LEAN_OPTION.findall(block.group(1))]


def own_modules(root: Path) -> dict[str, Path]:
    """Every module reachable from a lean_lib root through first-party imports:
    module name -> source path. Modules outside the repo (Mathlib, core) are not included."""
    todo = [r for roots in lean_libs(root).values() for r in roots]
    seen: dict[str, Path] = {}
    while todo:
        mod = todo.pop()
        if mod in seen:
            continue
        p = path_of(mod, root)
        if not p.exists():
            continue
        seen[mod] = p
        todo.extend(imports(p.read_text(encoding="utf-8", errors="ignore")))
    return dict(sorted(seen.items()))


def library_of(module: str, root: Path) -> str:
    for lib, roots in lean_libs(root).items():
        for r in roots:
            if module == r or module.startswith(r + "."):
                return lib
    return module.split(".")[0]


def blank_comments(text: str) -> str:
    """Like `statement_lock.strip_comments`, but comment characters become spaces and newlines
    are kept, so every offset and line number in the result is the same as in `text`.
    (Same scanning rules: nested `/- -/`, `--` to end of line, string literals not special.)"""
    out, i, n = [], 0, len(text)
    while i < n:
        m = COMMENT_START.search(text, i)
        if not m:
            out.append(text[i:])
            break
        out.append(text[i:m.start()])
        if m.group() == "--":
            j = text.find("\n", m.start())
            j = n if j < 0 else j
        else:
            j = _comment_end(text, m.start())
        out.append(re.sub(r"[^\n]", " ", text[m.start():j]))
        i = j
    return "".join(out)


def declarations(text: str, code: str | None = None) -> list[dict]:
    """Declaration heads in source order. `name` is namespace-qualified the way
    `tools/axiom_audit.py` qualifies it; `short` is the name as written (the statement-lock key);
    `statement` is the whitespace-normalized text that `tools/statement_lock.py` hashes."""
    code = code if code is not None else blank_comments(text)
    events = sorted(
        [(m.start(), "ns", m) for m in NAMESPACE.finditer(code)]
        + [(m.start(), "decl", m) for m in DECL_HEAD.finditer(code)],
        key=lambda e: e[0],
    )
    stack: list[str] = []
    out = []
    for pos, kind, m in events:
        if kind == "ns":
            if m.group(1) == "namespace":
                stack.extend(m.group(2).split("."))
            else:
                parts = m.group(2).split(".")
                if stack[-len(parts):] == parts:
                    del stack[-len(parts):]
            continue
        short = m.group("name").strip("«»")
        dkind = "theorem" if m.group("kind") == "lemma" else m.group("kind")
        before = text[max(0, pos - 20000):pos].rstrip()  # bounded: O(n) per file
        # Only the last `/--` can open this declaration's docstring; searching from the window start let the
        # non-greedy match begin at an earlier declaration's docstring and swallow the code in between.
        start = before.rfind("/--")
        d = DOCSTRING_BEFORE.search(before[start:]) if start >= 0 else None
        doc = " ".join(d.group(1).split()) if d else ""
        out.append({
            "name": ".".join(stack + [short]) if stack else short,
            "short": short,
            "kind": dkind,
            "statement": statement_text(code, pos, dkind),
            "docstring": doc,
            "line": code.count("\n", 0, pos) + 1,
            "pins": source_pins(doc),
            "tiers": sorted(set(TIER.findall(doc))),
        })
    return out


def statement_hash(statement: str) -> str:
    """The 16-hex-digit hash `tools/statement_lock.py` stores for a declaration."""
    return hashlib.sha256(statement.encode()).hexdigest()[:16]


def source_pins(doc: str) -> list[dict]:
    """`papers/foundations/<file>.txt` citations with their line ranges when written as `l. N` / `ll. N–M`."""
    pins, seen_files = [], set()
    for m in PIN.finditer(doc):
        lo = int(m.group(2))
        pins.append({"file": m.group(1), "lines": [lo, int(m.group(3) or lo)]})
        seen_files.add(m.group(1))
    for m in PIN_FILE.finditer(doc):
        if m.group(1) not in seen_files:
            pins.append({"file": m.group(1), "lines": None})
            seen_files.add(m.group(1))
    return pins


def heavy_kernel_decls(text: str, code: str | None = None) -> list[dict]:
    """Declarations whose proof uses `decide +kernel` (comments ignored). These are the
    candidates for 'own file, run alone': the kernel's memory for such checks accumulates
    across one file, so two heavy checks in one file can exceed what either needs alone."""
    code = code if code is not None else blank_comments(text)
    heads = list(DECL_HEAD.finditer(code))
    out = []
    for i, m in enumerate(heads):
        end = heads[i + 1].start() if i + 1 < len(heads) else len(code)
        n = len(DECIDE_KERNEL.findall(code[m.start():end]))
        if n:
            out.append({"short": m.group("name").strip("«»"), "line": code[:m.start()].count("\n") + 1, "calls": n})
    return out
