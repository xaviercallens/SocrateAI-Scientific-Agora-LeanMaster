#!/usr/bin/env python3
"""
tools/sorry_grep.py — gate G2: no `sorry`, `admit` or `native_decide` in built code.

Why this is a script and not a grep. A naive `grep -rn sorry` over this repository returns
~20 false positives from docstrings ("0 sorry, 0 admit") and one from a *string literal*,
`s!"{totalSorryCount} sorry axioms remaining"` in StringTheoryFormalization/Pipeline/
DAGOrchestrator.lean. A gate that is permanently red on a known false positive is a signal
engineered to be ignored (LL.md S11.9), so the stripping has to be part of the tool.

Removed before matching, in order: block comments and docstrings `/- ... -/`, line comments
`--`, then string literals `"..."` (including `s!"..."` interpolations).

Exit 0 = clean, 1 = a real occurrence, 2 = self-test failure.
Usage:  python3 tools/sorry_grep.py [lib ...]        (default: all ten first-party libraries)
        python3 tools/sorry_grep.py --self-test
"""
import re, sys, pathlib

LIBS = ["DualScaleDyons", "StringTheoryFoundation", "DualScaleStream2", "DualScaleMoonshine",
        "DualScaleCosmology", "DoubleFieldTheory", "StringTheoryFormalization",
        "DualScaleM24Formalization", "DualScaleValidation", "Lean5Corpus"]
BAD = re.compile(r"\bsorry\b|\badmit\b|native_decide")


def strip(text: str) -> str:
    text = re.sub(r"/-.*?-/", "", text, flags=re.S)     # block comments AND docstrings
    text = re.sub(r"--[^\n]*", "", text)                # line comments
    text = re.sub(r'"(?:[^"\\\n]|\\.)*"', '""', text)   # string literals, incl. s!"..."
    return text


def scan(roots):
    hits = []
    for root in roots:
        for f in sorted(pathlib.Path(root).rglob("*.lean")):
            for i, line in enumerate(strip(f.read_text(encoding="utf-8")).splitlines(), 1):
                if BAD.search(line):
                    hits.append(f"{f}:{i}: {line.strip()}")
    return hits


def self_test() -> int:
    """Negative control: the stripper must hide comments and strings, and must NOT hide code."""
    cases = [
        ('/-- 0 sorry, 0 admit -/\ntheorem t : True := trivial', False, "docstring"),
        ('-- sorry\ntheorem t : True := trivial',                 False, "line comment"),
        ('def f := s!"{n} sorry axioms remaining"',                False, "string literal"),
        ('theorem t : (0:Nat) = 1 := by sorry',                    True,  "real sorry"),
        ('theorem t : True := by native_decide',                   True,  "native_decide"),
    ]
    bad = []
    for src, should_hit, label in cases:
        got = bool(BAD.search(strip(src)))
        if got != should_hit:
            bad.append(f"{label}: expected {'hit' if should_hit else 'no hit'}, got the opposite")
    print("SELF-TEST " + ("FAIL -- " + "; ".join(bad) if bad
                          else "ok -- comments and strings hidden, real occurrences visible"),
          file=sys.stderr)
    return 2 if bad else 0


if __name__ == "__main__":
    if "--self-test" in sys.argv:
        sys.exit(self_test())
    roots = [a for a in sys.argv[1:] if not a.startswith("-")] or LIBS
    found = scan(roots)
    print("\n".join(found) if found else f"G2 clean: no sorry/admit/native_decide in {len(roots)} libraries")
    sys.exit(1 if found else 0)
