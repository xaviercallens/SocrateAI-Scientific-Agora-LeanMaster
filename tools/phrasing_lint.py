#!/usr/bin/env python3
"""
tools/phrasing_lint.py — enforce CLAUDE.md's banned claims, in code and in prose.

CLAUDE.md: "Never 'zero axioms' or '100% verified'; the axioms are propext, Classical.choice,
Quot.sound." That ban existed for months and 39 occurrences survived in Lean docstrings
(LL.md S11.10), including in the file whose module docstring claimed the trans-Planckian
censorship conjecture was "satisfied unconditionally". A phrasing ban is a lint, and a lint
nobody runs is a preference. This is the check.

Tier A certifies the Lean STATEMENT, never its physical meaning; any wording implying that a
compile settles a physical claim is what this catches.

Exit 0 = clean, 1 = banned phrasing found, 2 = self-test failure.
Usage:  python3 tools/phrasing_lint.py [path ...]     (default: libraries + docs + README + papers/book)
        python3 tools/phrasing_lint.py --self-test
"""
import re, sys, pathlib

BANNED = [
    (r"100\s*%\s*(certified|verified|proved|proven)", "'100% certified/verified'"),
    (r"\bzero axioms\b",                               "'zero axioms'"),
    # NOT banned: "depends on no axioms at all". CLAUDE.md bans "zero axioms" and "100% verified";
    # it does not ban an accurate per-theorem fact. A `decide`-proved theorem really does print an
    # EMPTY axiom list -- 16 of them in DualScaleDyons alone. An earlier version of this lint banned
    # bare "no axioms" and flagged those true statements: a rule invented by the lint's author,
    # stricter than the rule it was enforcing. A lint may not be more severe than its source.
    (r"\bfully verified\b",                            "'fully verified'"),
    (r"\bmathematically certain\b",                    "'mathematically certain'"),
]
PATTERNS = [(re.compile(p, re.I), why) for p, why in BANNED]

LIBS = ["DualScaleDyons", "StringTheoryFoundation", "DualScaleStream2", "DualScaleMoonshine",
        "DualScaleCosmology", "DoubleFieldTheory", "StringTheoryFormalization",
        "DualScaleM24Formalization", "DualScaleValidation", "Lean5Corpus"]
# `papers/publication/` is deliberately OUTSIDE the default scope. Its two remaining hits are
# quoted criticism of the banned claim ("...more useful than the earlier revision's blanket claim
# of ``100\% certified''"), inside artifacts already published to Zenodo. Editing a published
# paper so a lint reports clean is the same move as force-updating a released tag to hide an
# error in it. Run `phrasing_lint.py papers` deliberately when revising one; do not silence it.
DEFAULT = LIBS + ["docs", "README.md", "LL.md", "papers/book/chapters", ".claude/skills"]
SUFFIXES = {".lean", ".md", ".tex"}

# A banned phrase inside QUOTES is being discussed, not asserted -- the same principle as
# stripping string literals in sorry_grep.py, and better than an exemption list, which grows
# until the ban has been repealed by attrition. Handles "...", '...', `...` and LaTeX ``...''.
# NOTE: single-backtick spans are deliberately NOT quotation. In Lean and Markdown a backtick is
# code formatting, and the 39 violations removed on 2026-09-21 were themselves backtick-wrapped
# (`@kernel_status: 100% Certified ...`). Stripping them hid the very form this lint exists to
# catch; the self-test caught that, which is why it asserts on both historical forms.
QUOTED = re.compile(r"``[^`]*?''|\"[^\"\n]*\"|\u201c[^\u201d\n]*\u201d")


# --- typesetting layer -------------------------------------------------------------------
# A banned phrase is invisible to a literal matcher the moment it crosses a macro boundary,
# math mode, or a discretionary hyphen. Found 2026-09-21 by the Stream 1 session, which hit the
# same class in its own PASS(N) check: `PASS(\texorpdfstring{$N$}{N})` did not match `PASS\([0-9N]`.
# Before this layer existed, this lint MISSED six of seven LaTeX encodings of phrases it was
# written to catch, while reporting "clean across fourteen paths" -- clean in the encodings the
# author happened to think of, which is the `= True` signature problem in a third costume.
MACRO_WRAP = re.compile(r"\\(?:emph|textbf|textit|texttt|textrm|mbox|text|uline)\{([^{}]*)\}")
TEXORPDF   = re.compile(r"\\texorpdfstring\{([^{}]*)\}\{[^{}]*\}")
SPACING    = re.compile(r"\\[,;:!]|\\ |\\-|\\/|~")
ESCAPED    = re.compile(r"\\([%&#_$])")

def detex(line: str) -> str:
    """Normalise the typesetting layer so a macro boundary cannot hide a banned phrase."""
    prev = None
    while prev != line:                      # nested \textbf{\emph{...}}
        prev = line
        line = TEXORPDF.sub(r"\1", line)
        line = MACRO_WRAP.sub(r"\1", line)
    line = SPACING.sub("", line)
    line = ESCAPED.sub(r"\1", line)         # 100\% -> 100%
    line = line.replace("$", "")             # math-mode delimiters, keep the content
    return line

def unquoted(line: str) -> str:
    return QUOTED.sub(" ", line)

# Kept deliberately tiny: only self-reference by the lint's own documentation.
EXEMPT = re.compile(r"phrasing_lint|CLAUDE\.md forbid", re.I)


def scan(roots):
    hits = []
    for root in roots:
        rp = pathlib.Path(root)
        files = [rp] if rp.is_file() else [f for f in rp.rglob("*") if f.suffix in SUFFIXES]
        for f in files:
            try:
                text = f.read_text(encoding="utf-8")
            except (UnicodeDecodeError, OSError):
                continue
            for i, line in enumerate(text.splitlines(), 1):
                if EXEMPT.search(line):
                    continue
                probe = unquoted(detex(line))
                for pat, why in PATTERNS:
                    if pat.search(probe):
                        hits.append(f"{f}:{i}: {why} :: {line.strip()[:110]}")
                        break
    return hits


def self_test() -> int:
    cases = [
        ("**Kernel Verification:** 100% Certified (0 sorry, 0 admit)", True,  "the historical form"),
        ("- `@kernel_status: 100% Certified (0 sorry, 0 admit)`",      True,  "the metadata form"),
        ("this development has zero axioms",                           True,  "'zero axioms'"),
        (r"100\% verified",                                            True,  "LaTeX-escaped percent"),
        (r"\emph{zero} axioms",                                        True,  "phrase split by \\emph"),
        (r"100\,\% certified",                                          True,  "thin space + escaped percent"),
        (r"Zero ax\-ioms",                                             True,  "discretionary hyphen"),
        (r"\textbf{100\%} verified",                                    True,  "bold-wrapped"),
        (r"100 \% certified",                                          True,  "spaced percent"),
        ("Tier A: no `sorry`; axioms propext, Classical.choice.",      False, "an accurate statement"),
        ("depends on no axioms beyond propext, Classical.choice.",      False, "the prescribed qualified form"),
        ("149 theorems depend on no axioms at all.",                    False, "accurate: decide proofs print []"),
        ('replace the "100% CERTIFIED" banner with something honest', False, "a quoted mention"),
        ("``zero axioms'' is not a state a theorem can be in",         False, "a LaTeX-quoted mention"),
    ]
    bad = []
    for src, should, label in cases:
        got = bool(not EXEMPT.search(src) and any(p.search(unquoted(detex(src))) for p, _ in PATTERNS))
        if got != should:
            bad.append(f"{label}: expected {'hit' if should else 'no hit'}, got the opposite")
    print("SELF-TEST " + ("FAIL -- " + "; ".join(bad) if bad
                          else "ok -- banned forms caught, accurate wording and meta-discussion exempt"),
          file=sys.stderr)
    return 2 if bad else 0


if __name__ == "__main__":
    if "--self-test" in sys.argv:
        sys.exit(self_test())
    roots = [a for a in sys.argv[1:] if not a.startswith("-")] or DEFAULT
    found = scan(roots)
    print("\n".join(found) if found else f"phrasing lint clean across {len(roots)} paths")
    sys.exit(1 if found else 0)
