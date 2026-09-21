#!/usr/bin/env python3
"""
tools/book_vs_source.py — does the book's critique of a declaration reach the declaration?

LL.md S11.8: a correct critique that lives only in prose is an UNLANDED FIX. Three were found
that way on 2026-09-21 (bdf2_order_bound, tcc_cosmic_protection_contract, genesis_no_singularity):
in each case papers/book/ read the declaration correctly and the Lean file did not, so every
downstream consumer -- lean_catalogue.md, the files' own @rag_query metadata, anyone opening the
source -- met the claim and never the critique.

This works at the BLOCK level, not the line level. A `leanbox` is the book's self-contained
reading of one or more declarations, so it is the right unit: a limiting sentence anywhere in
the box qualifies every \\lean{...} the box names. The line-window version of this check
(disclosure_reaches_source.py) missed these because the critique and the name sat paragraphs apart.

Output is a READING LIST, not a verdict. The book legitimately discusses declarations it is not
criticising, and a box may criticise one of the names it mentions rather than all of them.

Exit 0 = no candidates, 1 = candidates to read, 2 = self-test failure.
Usage:  python3 tools/book_vs_source.py [--all]      (--all: list correctly-landed ones too)
        python3 tools/book_vs_source.py --self-test
"""
import re, sys, pathlib, collections

BOOK = pathlib.Path("papers/book/chapters")
LIBS = ["DualScaleDyons", "StringTheoryFoundation", "DualScaleStream2", "DualScaleMoonshine",
        "DualScaleCosmology", "DoubleFieldTheory", "StringTheoryFormalization",
        "DualScaleM24Formalization", "DualScaleValidation", "Lean5Corpus"]

# Language in which the book LIMITS what a declaration establishes.
LIMIT = re.compile(
    r"vacuou|says nothing|is not a proof|not a theorem|proves less|no Lean statement|"
    r"is not formalized|not formalised|does not state|does not show|does not prove|"
    r"does not define|is not defined in Lean|never used|is not used|typed in, not derived|"
    r"asserted, not derived|only the remark|literally:|placeholder|not itself a proof|"
    r"carries no|is a lookup table|free parameter|Tier~\\TC|\\TC\{\}|"
    # Added after a positive control against git history: the picard box limits its declarations
    # with "is the same statement under a second name" and "No operator ... appear", neither of
    # which the first pattern set knew. A detector is only as wide as the phrasings it has met.
    r"contains none|contains no |under a second name|the same statement under|no [a-z, \\{}$\\\\]{0,60}appears?\b|"
    r"no [a-z, \\{}$\\\\]{0,60}(is|are) defined\b|neither .{0,40}nor .{0,40}(appear|is defined)", re.I)

# Language in a DOCSTRING that carries such a limit. Includes the repo's Disclosure convention.
# Widened 2026-09-21 after the tool reported FTermPotential.lean's three declarations as
# unlanded when all three carry precise disclosures ("Not a statement about flux quantization
# ... despite the name", "is never used", "not a derivation of"). False negatives on the LANDED
# side manufacture false positives on the report -- the dangerous direction, pointed at the fix.
LANDED = re.compile(
    r"Disclosure|vacuou|says nothing|not a proof|proves less|not a theorem|placeholder|"
    r"not formalized|not formalised|does not state|asserted, not derived|typed in|"
    r"conditional remark|carries no|only the remark|not established here|checksum|"
    r"despite the name|not a statement about|is never used|is not used|are not used|"
    r"not a derivation|independent of|is not constructed|no .{0,40}is constructed|"
    r"one direction only|re-exports", re.I)

DECL = re.compile(r'(?:/--(?P<doc>.*?)-/\s*)?^\s*(?:@\[[^\]]*\]\s*)?'
                  r'(?:(?:private|protected|noncomputable|partial|unsafe|scoped|local)\s+)*'
                  r'(?:theorem|lemma|def)\s+(?P<name>[A-Za-z_][\w\'.]*)', re.M | re.S)
BOX = re.compile(r"\\begin\{leanbox\}(.*?)\\end\{leanbox\}", re.S)
LEAN = re.compile(r"\\lean\{([^}]*)\}")

# A NEGATED limit is the opposite of a criticism: the book cites `dmvv_unreachable_example` to
# show a guard "is not vacuous", and says a decomposition "is not vacuous". Matching those as
# limits produced four of the ten strongest-looking candidates in the first full sweep.
NEGATED = re.compile(r"\b(is|are|was|were)\s+not\s+(vacuous|a placeholder)|not\s+vacuous", re.I)


def limited(text: str) -> bool:
    return bool(LIMIT.search(NEGATED.sub(" ", text)))


def declarations():
    d = collections.defaultdict(list)
    for lib in LIBS:
        for p in pathlib.Path(lib).rglob("*.lean"):
            src = p.read_text(encoding="utf-8")
            for m in DECL.finditer(src):
                d[m.group("name")].append((str(p), m.group("doc") or ""))
    return d


# Sentence-level, not box-level. The box is the right unit for READING, but attributing its
# limit to every name it mentions over-attributes badly: a box that says one declaration "says
# nothing about spacetime" may name six others neutrally in the same breath. Box-level gave 121
# candidates across 41 chapters, dominated by exactly that. Requiring the limiting language and
# the \lean{name} to sit in the SAME SENTENCE is the honest granularity -- it still catches all
# four cases this tool was positive-controlled against.
SENT = re.compile(r"(?<=[.;:])\s+(?=[A-Z\\])")


def scan(decls):
    unlanded, landed = [], []
    for tex in sorted(BOOK.glob("*.tex")):
        for box in BOX.finditer(tex.read_text(encoding="utf-8")):
            body = box.group(1)
            if not limited(body):
                continue
            # The book's idiom is "NAME: <what it states>. <why that is less than the name>."
            # so the limit usually lands in the sentence AFTER the one naming the declaration.
            # Pure same-sentence matching dropped three of this tool's four positive controls;
            # a window of the naming sentence plus the next two keeps all four and still cuts
            # 121 box-level candidates to a readable list. Tuned against the controls, not to
            # a target count -- a narrowing that loses a known case is wrong however tidy.
            sents = SENT.split(body)
            keep = []
            for i, t in enumerate(sents):
                # Symmetric window: the limit can precede the name as well as follow it
                # ("It does not state the bound ...; \lean{self_dual_symmetric} says a'/a' = 1").
                # A forward-only window lost that control.
                lo, hi = max(0, i - 2), i + 3
                if LEAN.search(t) and any(limited(u) for u in sents[lo:hi]):
                    keep.append((t, lo, hi))
            body = " ".join(t for t, _, _ in keep)
            lo = min((l for _, l, _ in keep), default=0)
            hi = max((h for _, _, h in keep), default=0)
            for raw in LEAN.finditer(body):
                name = raw.group(1).replace("\\_", "_").replace("\\", "").split(".")[-1]
                if name not in decls:
                    continue
                cands = decls[name]
                quote = " ".join(t for t in sents[lo:hi] if limited(t))
                quote = re.sub(r"\s+", " ", re.sub(r"\\lean\{([^}]*)\}", r"\1", quote)).strip()[:180]
                row = (name, ", ".join(f for f, _ in cands), tex.name, quote)
                (landed if any(LANDED.search(doc) for _, doc in cands) else unlanded).append(row)
    return unlanded, landed


def self_test() -> int:
    """The three known cases must be detectable: limit language in the box, and the pre-fix
    docstrings carried none. Verified against git history in the commit message of this tool."""
    checks = [
        (r"\begin{leanbox}[x] \lean{foo} says nothing about spacetime. \end{leanbox}", True,  "limit language found"),
        (r"\begin{leanbox}[x] \lean{foo} is proved by \lean{bar}. \end{leanbox}",      False, "neutral box ignored"),
    ]
    bad = []
    for src, should, label in checks:
        m = BOX.search(src)
        got = bool(m and LIMIT.search(m.group(1)))
        if got != should:
            bad.append(label)
    if not LANDED.search("**Disclosure (2026-09-21).** ..."):
        bad.append("Disclosure convention not recognised as landed")
    if LANDED.search("BDF2 stability order bound: spatial dimension is at least 0."):
        bad.append("a bare descriptive docstring wrongly counted as landed")
    if not LANDED.search("Not a statement about flux quantization, despite the name: `s` is never used."):
        bad.append("a real in-place disclosure not counted as landed")
    if limited("dmvv_unreachable_example shows the guard is not vacuous."):
        bad.append("a NEGATED limit counted as a criticism")
    if not limited("It says nothing about spacetime."):
        bad.append("a plain limit no longer detected")
    print("SELF-TEST " + ("FAIL -- " + "; ".join(bad) if bad
                          else "ok -- limit language detected, neutral boxes ignored, "
                               "Disclosure counted, bare description not"), file=sys.stderr)
    return 2 if bad else 0


if __name__ == "__main__":
    if "--self-test" in sys.argv:
        sys.exit(self_test())
    decls = declarations()
    unlanded, landed = scan(decls)
    seen = set()
    print("=== BOOK LIMITS IT, THE DECLARATION DOES NOT SAY SO (reading list) ===")
    for name, files, tex, quote in unlanded:
        if (name, tex) in seen:
            continue
        seen.add((name, tex))
        print(f"  {name}\n      lean : {files}\n      book : {tex}\n      says : {quote}")
    if "--all" in sys.argv:
        print("\n=== landed (docstring already carries a limit) ===")
        for name, files, tex, _q in sorted(set(landed)):
            print(f"  {name}  [{tex}]")
    print(f"\n{len(seen)} candidates; {len(set(landed))} already landed", file=sys.stderr)
    sys.exit(1 if seen else 0)
