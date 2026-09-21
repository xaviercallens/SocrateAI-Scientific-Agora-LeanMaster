---
name: claim-audit
description: Use when auditing whether Lean declarations claim more than they prove, whether a critique written in prose ever reached the code, or whether banned certification wording survives — and when writing any new checker over a Lean repository. Covers the five audit tools, how to tune a detector without fooling yourself, and the failure modes that make a checker report "clean" when it is blind.
---

# Auditing claims, not proofs

The gates (`lean-proof-gate`) check that a proof proves its statement. **They cannot see a statement that is
true and proves less than its name says**, or a docstring that asserts what the statement does not. Nine such
defects were found in one day across two repositories with every gate green (`LL.md` §S11).

## The tools

All live in `tools/`, all take `--self-test`, **all exit non-zero on failure**.

| tool | question it asks |
|---|---|
| `name_vs_statement.py` | does the statement mention what the name claims? |
| `disclosure_reaches_source.py` | a limit written in prose — is it also at the declaration? |
| `book_vs_source.py` | same, block-level, for `papers/book/chapters/*.tex` `leanbox` readings |
| `phrasing_lint.py` | banned certification wording ("zero axioms", "100% verified") |
| `sorry_grep.py` | gate G2, comment- and string-literal-aware |

```bash
python3 tools/<tool>.py --self-test   # ALWAYS first; an empty report is not a clean bill
python3 tools/<tool>.py               # then the run
```

## The two defects these exist to find

1. **The claim lives in the name.** A theorem constrains an object completely and never *identifies* it — four
   theorems can pin down what `Sym²` does and none say it *is* precomposition, after which the name does the
   identifying. Test: for each named declaration, point at the theorem that would be **false** if the name were
   wrong. If only a docstring would change, the identification is not in the kernel.
2. **The critique never landed.** The correct reading exists — in the book, a README, a review brief — and not
   at the declaration, so it does not travel with it into generated catalogues, `@rag_query` metadata, or the
   next reader. **When a review finds that a declaration claims more than it proves, the first edit is that
   declaration's docstring.** Writing it up elsewhere is the second edit. A correct critique sitting only in
   prose is an *unlanded fix* — treat it as open, not done.

Disclose **in place**: statement unchanged, nothing deleted, original text left standing, and open with the
literal word **`Disclosure`** so the audit and the reader look for the same token.

## Writing or tuning a checker: five ways to fool yourself

Each of these actually happened, most of them inside the commit that added the check.

1. **A scan that cannot see a declaration reports it as clean.** Anchor on
   `^\s*(?:@\[…\]\s*)?(?:private|protected|noncomputable|…)*\s*(?:theorem|lemma)`, never `^(theorem|lemma)`.
   Two `@[simp]` theorems were invisible to three separate tools for this one reason.
2. **A scan written for one signature cannot see another costume.** A vacuity sweep keyed on `= True` could not
   see `0 ≤ sys.dim` with `dim : ℕ`. **A vacuous statement need not be `True`; it need only be implied by
   nothing.** Record what a scan *cannot* see, at the time you write it.
3. **The encoding layers.** Strip comments *and* string literals before matching; do **not** treat single
   backticks as quotation (in Lean and Markdown they are code formatting, and that is where violations live);
   and for `.tex`, normalise the typesetting layer — a phrase crossing a macro boundary, math mode or a
   discretionary hyphen is invisible ("100\% verified", "\emph{zero} axioms", "Zero ax\-ioms" — quoted here
   rather than code-fenced, because this very lint reads backticks as code, not as quotation).
4. **Negated matches are not hits.** "shows the guard **is not** vacuous" is the opposite of a criticism.
5. **A lint may not be more severe than its source.** Check what the rule actually says before mechanising it;
   a mechanised rule is harder to argue with than a written one.

**Tune against the positive controls, never against the candidate count.** A narrowing that produces a tidier
list while dropping a case you already know about is a regression that reads as an improvement. Keep a fixture
per known case and re-check all of them after every change.

**Negative-control the self-test itself.** Reintroduce the bug in a scratch copy and confirm the test goes red;
a self-test that has never failed is an assertion. Make it bidirectional: the stripper must hide comments *and*
must not hide a real defect.

## Reporting

Output is a **reading list, not a verdict**. These tools cannot establish that anything is clean — false
negatives are the dangerous direction. Expect most hits to be false positives (Lean states properties
symbolically: `isometry` is `MᵀGM = G`, `nonneg` is `0 ≤ x`). Filter to *missing object names* and
*weak-statement signatures*, hand the rest forward, and **never report a number that implies you read it all**.

Keep numerator and denominator over the same population — audited theorems ≠ parsed `theorem`/`lemma`
declarations ≠ statement-lock declarations, which differ by ~400 in LeanMaster.

## Scope

Never edit a **published** artifact so a check reports clean — a Zenodo paper, a released tag. Quoted criticism
of a banned claim inside a published paper is correct content; exclude the path deliberately and say why.
Same rule as not force-updating a released tag to hide an error in it.
