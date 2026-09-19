#!/usr/bin/env python3
"""
tools/axiom_audit.py — gate G3 of docs/STREAM2_WORKFLOW.md.

For every `theorem`/`lemma` declared in the given library's source, run
`#print axioms` against the *built* library and fail unless each depends only on
Lean's three standard axioms. `sorryAx` (a remaining `sorry`) and
`Lean.ofReduceBool` (`native_decide`) both fail the gate.

Usage:
  lake build DualScaleStream2 && python3 tools/axiom_audit.py DualScaleStream2
"""

import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

# Reusable from any Lake project: set LEAN_PROJECT_ROOT=/path/to/project (default: this repository).
ROOT = Path(os.environ.get("LEAN_PROJECT_ROOT") or Path(__file__).resolve().parent.parent).resolve()
STANDARD = {"propext", "Classical.choice", "Quot.sound"}
# Attribute-prefixed heads (`@[simp] theorem ...`) and `protected` ones are theorems too; before 2026-09-19 the
# pattern required `theorem` at column 0 and silently skipped two `@[simp]` theorems of DualScaleStream2.
DECL = re.compile(r"^(?:@\[[^\]]*\]\s*)*(?:protected\s+)?(?:theorem|lemma)\s+([A-Za-z0-9_'.]+)", re.MULTILINE)
NAMESPACE = re.compile(r"^(namespace|end)\s+([A-Za-z0-9_.]+)\s*$", re.MULTILINE)


def qualified_names(path: Path) -> list[str]:
    # Comments and docstrings are removed first: a docstring line that begins with "theorem ..." must not
    # be mistaken for a declaration (it made the probe file unparsable after a documentation pass).
    from statement_lock import strip_comments
    text = strip_comments(path.read_text(encoding="utf-8"))
    events = sorted(
        [(m.start(), "ns", m.group(1), m.group(2)) for m in NAMESPACE.finditer(text)]
        + [(m.start(), "decl", m.group(1), None) for m in DECL.finditer(text)]
    )
    stack: list[str] = []
    names = []
    for _, kind, a, b in events:
        if kind == "ns":
            if a == "namespace":
                stack.append(b)
            elif stack and stack[-1] == b:
                stack.pop()
        else:
            names.append(".".join(stack + [a]))
    return names


def main() -> int:
    args = sys.argv[1:] or ["DualScaleStream2"]
    if all(a.endswith(".lean") for a in args):
        # Audit specific modules (e.g. one gated phase while others are still in progress).
        files = [ROOT / a for a in args]
        imports = "".join(f"import {a.removesuffix('.lean').replace('/', '.')}\n" for a in args)
    else:
        lib = args[0]
        files = sorted((ROOT / lib).rglob("*.lean"))
        imports = f"import {lib}\n"
    names = [n for f in files for n in qualified_names(f)]
    probe = imports + "".join(f"#print axioms {n}\n" for n in names)
    with tempfile.NamedTemporaryFile("w", suffix=".lean", dir="/tmp", delete=False) as fh:
        fh.write(probe)
        tmp = fh.name
    proc = subprocess.run(["lake", "env", "lean", tmp], cwd=ROOT, capture_output=True, text=True)
    Path(tmp).unlink(missing_ok=True)
    out = proc.stdout
    import_errors = [ln for ln in (proc.stdout + proc.stderr).splitlines() if ": error" in ln]
    if import_errors:
        # Fail loudly: a missing/stale .olean makes every name "MISSING", which previously
        # looked like an audit result instead of an infrastructure failure.
        print("AUDIT ERROR — the probe file did not elaborate (build the library first):")
        for ln in import_errors[:5]:
            print("   ", ln)
        return 2

    blocks = re.split(r"(?='[^']+' (?:depends on axioms|does not depend on any axioms))", out)
    results = {}
    for blk in blocks:
        m = re.match(r"'([^']+)' (depends on axioms: \[([^\]]*)\]|does not depend on any axioms)", blk.strip(), re.S)
        if m:
            axioms = {a.strip() for a in (m.group(3) or "").replace("\n", " ").split(",") if a.strip()}
            results[m.group(1)] = axioms

    bad = 0
    for n in names:
        if n not in results:
            print(f"MISSING  {n}  (no #print axioms output — name resolution failed)")
            bad += 1
            continue
        extra = results[n] - STANDARD
        status = "OK     " if not extra else "FAIL   "
        bad += bool(extra)
        print(f"{status} {n}  {sorted(results[n]) or '[]'}")
    print(f"\n{len(names)} theorems audited, {bad} failing")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
