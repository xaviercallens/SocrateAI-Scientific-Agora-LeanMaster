"""
leanstack/cache.py — LeanCache: fingerprints, the result cache, and Lake's own traces.

What Lake already does (read from a real trace, `.lake/build/lib/lean/**/*.trace`, schema
"2025-09-10"): every module build is keyed by a `depHash` over the source hash, the imports'
hashes, the toolchain ("Lean 4.33.1, commit …") and the options (-DmaxHeartbeats=…). So
`lake build` never recompiles an unchanged module, and this file does NOT try to replace that.

What Lake does not do, and this file adds:

1. A fingerprint that exists *before* anything is built, so the planner can say "cached / must
   rebuild / what else is affected" without invoking Lake (every `lake` call loads the workspace,
   and a cold `lake env lean` re-reads gigabytes of .olean files).
2. A cache for actions Lake never caches: single-file checks (`lake env lean File.lean`, what
   prover_loop and agents run hundreds of times), axiom audits and statement-lock checks. Their
   result is a function of the same inputs, so it is keyed by the same fingerprint.
3. A cross-check: `lake_trace(module)` reads Lake's depHash next to ours. They use different hash
   functions, so they are never equal; what must agree is *when they change*.

Fingerprint of a module M (leanstack-fp-v1), sha256 over:
    "leanstack-fp-v1", toolchain (lean-toolchain), options (-D flags, sorted), action-independent,
    sha256(source of M),
    for each import I of M, sorted: ("own", I, fingerprint(I)) if I is a first-party module,
                                     ("ext", I, external_key) otherwise,
where external_key = sha256 of the lake-manifest.json package pins (name, rev). A Mathlib bump
therefore changes every fingerprint that (transitively) imports Mathlib, and nothing else.
"""

import hashlib
import json
from pathlib import Path

from leanstack import source
from leanstack.memory import LeanMemory

FP_VERSION = "leanstack-fp-v1"
KNOWN_TRACE_SCHEMAS = {"2025-09-10"}


class Fingerprinter:
    def __init__(self, root: Path | str = source.REPO_ROOT, options: list[str] | None = None):
        self.root = Path(root).resolve()
        self.options = sorted(options if options is not None else source.lake_lean_options(self.root))
        tc = self.root / "lean-toolchain"
        self.toolchain = tc.read_text().strip() if tc.exists() else "unknown-toolchain"
        self.external_key = self._external_key()
        self._fp: dict[str, str] = {}
        self._imports: dict[str, list[str]] = {}
        self._src_sha: dict[str, str] = {}

    def _external_key(self) -> str:
        manifest = self.root / "lake-manifest.json"
        if not manifest.exists():
            return "no-manifest"
        pins = sorted((p.get("name", ""), p.get("rev", ""))
                      for p in json.loads(manifest.read_text()).get("packages", []))
        return hashlib.sha256(json.dumps(pins).encode()).hexdigest()

    def is_own(self, module: str) -> bool:
        return source.path_of(module, self.root).exists()

    def _load(self, module: str) -> None:
        if module in self._imports:
            return
        data = source.path_of(module, self.root).read_bytes()
        self._src_sha[module] = hashlib.sha256(data).hexdigest()
        self._imports[module] = source.imports(data.decode("utf-8", errors="ignore"))

    def imports(self, module: str) -> list[str]:
        self._load(module)
        return self._imports[module]

    def source_sha(self, module: str) -> str:
        self._load(module)
        return self._src_sha[module]

    def fingerprint(self, module: str) -> str:
        """Iterative post-order walk (no recursion limit at 10^5 modules); raises on an import cycle."""
        if module in self._fp:
            return self._fp[module]
        stack, on_path = [(module, False)], set()
        while stack:
            mod, done = stack.pop()
            if mod in self._fp:
                continue
            if done:
                on_path.discard(mod)
                self._fp[mod] = self._combine(mod)
                continue
            if mod in on_path:
                raise ValueError(f"import cycle through {mod}")
            on_path.add(mod)
            stack.append((mod, True))
            for imp in self.imports(mod):
                if self.is_own(imp) and imp not in self._fp:
                    if imp in on_path:
                        raise ValueError(f"import cycle: {mod} -> {imp}")
                    stack.append((imp, False))
        return self._fp[module]

    def _combine(self, module: str) -> str:
        parts = [FP_VERSION, self.toolchain, *self.options, self.source_sha(module)]
        for imp in sorted(self.imports(module)):
            if self.is_own(imp):
                parts.append(f"own:{imp}:{self._fp[imp]}")
            else:
                parts.append(f"ext:{imp}:{self.external_key}")
        return hashlib.sha256("\n".join(parts).encode()).hexdigest()

    def fingerprint_text(self, text: str, label: str = "<scratch>") -> str:
        """Fingerprint of a file that is not (yet) a module — a prover candidate, an audit probe.
        Two identical candidates against identical imports get the same key, so a failure is
        never recompiled twice."""
        parts = [FP_VERSION, self.toolchain, *self.options, hashlib.sha256(text.encode()).hexdigest()]
        for imp in sorted(source.imports(text)):
            parts.append(f"own:{imp}:{self.fingerprint(imp)}" if self.is_own(imp)
                         else f"ext:{imp}:{self.external_key}")
        return hashlib.sha256("\n".join(parts).encode()).hexdigest()


def reverse_imports(modules: dict[str, list[str]]) -> dict[str, set[str]]:
    rev: dict[str, set[str]] = {m: set() for m in modules}
    for m, imps in modules.items():
        for i in imps:
            rev.setdefault(i, set()).add(m)
    return rev


def impacted(changed: list[str], modules: dict[str, list[str]]) -> list[str]:
    """Every module that transitively imports one of `changed` (the changed ones included):
    the set whose build, audit and lock results a change can invalidate."""
    rev = reverse_imports(modules)
    seen, todo = set(), list(changed)
    while todo:
        m = todo.pop()
        if m in seen:
            continue
        seen.add(m)
        todo.extend(rev.get(m, ()))
    return sorted(seen)


def lake_trace(module: str, root: Path | str = source.REPO_ROOT) -> dict | None:
    """Lake's own record of the last build of `module`, or None if absent / unknown schema.
    Unknown schema versions are skipped, not guessed at (the format is Lake-internal)."""
    path = Path(root) / ".lake" / "build" / "lib" / "lean" / (module.replace(".", "/") + ".trace")
    if not path.exists():
        return None
    try:
        data = json.loads(path.read_text())
    except (OSError, ValueError):
        return None
    schema = data.get("schemaVersion")
    if schema not in KNOWN_TRACE_SCHEMAS:
        return {"module": module, "schema_version": schema, "dep_hash": None, "unknown_schema": True}
    toolchain, options = None, []
    for item in data.get("inputs", []):
        if isinstance(item, list) and len(item) == 2:
            key, val = item
            if isinstance(key, str) and key.startswith("Lean "):
                toolchain = key
            elif key == "options" and isinstance(val, list):
                options = [o[0] for o in val if isinstance(o, list) and o]
    return {"module": module, "schema_version": schema, "dep_hash": data.get("depHash"),
            "toolchain": toolchain, "options": options, "mtime": path.stat().st_mtime}


class LeanCache:
    """Result cache keyed by (fingerprint, action). Actions: 'build', 'check', 'audit', 'lock'."""

    def __init__(self, memory: LeanMemory, fingerprinter: Fingerprinter):
        self.memory = memory
        self.fp = fingerprinter

    def lookup(self, module: str, action: str = "build") -> dict | None:
        """The last recorded result for the module's *current* fingerprint, or None (miss)."""
        return self.memory.result(self.fp.fingerprint(module), action)

    def is_fresh(self, module: str, action: str = "build") -> bool:
        hit = self.lookup(module, action)
        return bool(hit and hit["status"] == "ok")

    def record(self, module: str, action: str, status: str, **run) -> int:
        fp = self.fp.fingerprint(module)
        run_id = self.memory.record_run(module, fp, action, run.pop("command", ""), status,
                                        run.pop("returncode", None), run.pop("wall_s", 0.0), **run)
        self.memory.upsert_module(module, path=str(source.path_of(module, self.fp.root)),
                                  source_sha=self.fp.source_sha(module), fingerprint=fp,
                                  imports=self.fp.imports(module))
        return run_id

    def stale(self, modules: list[str], action: str = "build") -> list[str]:
        return [m for m in modules if not self.is_fresh(m, action)]
