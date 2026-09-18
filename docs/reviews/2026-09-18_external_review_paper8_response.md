# Response to the external review of paper 8

Review text, verbatim: [`2026-09-18_external_review_paper8.md`](2026-09-18_external_review_paper8.md).
Each claim in the review was checked against the paper's source and, where it concerns mathematics, against
the Lean library. Verdicts: **Validated** (true of the paper and the code), **Overstated** (stronger than the
paper or the code supports — not adopted), **Incorrect**, or **Acted on**.

The review is favourable and contains **no explicit recommendations**. Its value for this project is
different: several of its sentences describe the work as stronger than it is, which shows where a careful
reader can over-read the paper. Those are the places we revised. A favourable review is not evidence that
the work is right, and none of its praise is quoted in the paper, the README or the Zenodo records.

## Summary of actions

| # | Review statement | Verdict | Action |
|---|---|---|---|
| 1 | 19 modules, 99 theorems, zero `sorry`, three standard axioms | Validated (at the reviewed version) | now 100 theorems — see #8 |
| 2 | Tier A is "absolute mathematical certainty" | Overstated | paper 8 §1.3 now states the trust base of a Tier A claim |
| 3 | The paper bans sensationalist phrases; §8 lists what is not proved; §9 is the methods | Validated | — |
| 4 | `E8` and `U`: "positive/negative definiteness via exact rational LDLᵀ factorizations" | Incorrect for `U` | none needed in the paper (it was right); noted in its revision note |
| 5 | It "arithmetically verifies the specific signatures" (3,19), (4,20), (6,22) | Overstated | none needed; noted in the revision note |
| 6 | "Formalizes the full arithmetic duality group"; spectrum "perfectly invariant" | Partly validated | none needed — see below |
| 7 | DFT: `(ηH)² = 1`, B-shift covariance, level matching as a null charge vector | Validated, with one precision | — |
| 8 | The trace bound is "minimized exactly at the self-dual point (G = 1)" | **Incorrect at the time — now true** | **new theorem `dualScale_eq_iff`**; paper 8, book ch. 31/37/38, status docs updated |
| 9 | It "validates the Eguchi–Ooguri–Tachikawa observation" | Overstated | none needed; noted in the revision note |
| 10 | The orchestrator was "human" | Incorrect | paper 8 §9.3 says so explicitly; **the same error was found in our own paper 9 and fixed** |
| 11 | Hallucinated reports "were caught 100% of the time" | Not knowable | paper 8 §9.3 now says why, and what is guaranteed instead |
| 12 | "This proves that AI cannot be trusted for mathematics unless governed by a strict cryptographic/kernel gate" | Overstated; "cryptographic" is incorrect | paper 8 §9.3: three incidents support no general conclusion |
| 13 | "a bulletproof, bug-free algebraic foundation" | Rejected | "absolute certainty", "bulletproof", "bug-free" added to the paper's list of phrases it does not use |

## Point by point

**1. Counts — validated.** `python3 tools/axiom_audit.py DualScaleStream2` reported 99 theorems, 0 failing, at
the reviewed version (`v3.5.0`); 19 modules are listed in `DualScaleStream2.lean`. After this response the
count is 100 (#8).

**2. "Absolute mathematical certainty" — overstated.** A Tier A claim is certain *relative to* a trust base:
Lean's type theory and kernel implementation at this version, the axioms `propext`, `Classical.choice`,
`Quot.sound`, the Mathlib definitions the statement is written in, and the correspondence between the formal
statement and the prose beside it. The kernel checks none of the last item, and it is where every real error
in this project has been found: a mistyped `M₂₄` dimension table, a "unique" minimum that was not unique
under `Nat` truncation, a source equation transcribed with a dimensionally impossible exponent
(`CKNBound.lean`, Stream 3). Paper 8 §1.3 now says this.

**4. `U` is not definite — the review is incorrect, the paper was right.** The hyperbolic plane
`U = [[0,1],[1,0]]` is *indefinite*, signature (1,1). The paper proves it is even, symmetric and unimodular,
and exhibits a congruence to `diag(2,−2)`; reading the signature off that congruence is Sylvester's law,
Tier L. The `LDLᵀ` certificate is for `E8` only (`cartanE8_posDef`), with `E8(−1)` negative definite as a
consequence. No paper change was needed.

**5. Signatures are bookkeeping — overstated.** `sigK3_eq`, `sigMukai_eq`, `sigK3T2_eq` add signature records
whose inputs `sigU = (1,1)` and `sigE8Neg = (0,8)` are definitions marked Tier L. They are not computed from
Gram matrices, and the paper, the module docstrings and `docs/VERIFIED_FOUNDATION.md` §2 all say so. What is
Tier A is the addition and the cross-check against the independently tabulated Hodge signature.

**6. `O(d,d;ℤ)` — partly validated.** The group is defined by the predicate `gᵀηg = η` for every `d`, and the
paper proves closure, invertibility over ℤ, and invariance of the charge norm and of the (mass², level)
spectrum under *every* element, not only generators. What is **not** proved is that the exhibited elements
*generate* the group (Giveon–Porrati–Rabinovici; Tier L), and what is matched is the discrete charge spectrum,
not the string partition function. Both limits are already stated in paper 8 §3 and §8.

**7. DFT — validated, with one precision.** Level matching is proved equivalent to η-nullity of the charge
vector (`n·w = 0`); "totally null" is a property of the momentum and winding *frames* (`d`-dimensional
subspaces), proved separately. The paper keeps the two apart.

**8. Uniqueness of the minimizer — incorrect at the time; acted on.** The reviewed version proved
`dualScale_ge` (`tr G + tr G⁻¹ ≥ 2d`) and `dualScale_one` (the value `2d` is attained at `G = 1`). It stated
in three places that uniqueness was *not* proved and declined to write "equality iff". The review read it as
proved. Two responses were possible: correct the reading, or close the gap. We closed it.

```lean
theorem dualScale_eq_iff (G : Matrix (Fin d) (Fin d) ℝ) (hG : G.PosDef) :
    dualScale G = 2 * d ↔ G = 1
```

Proof: equality forces `tr((G−1)ᵀG⁻¹(G−1)) = 0`; a positive-semidefinite matrix with zero trace is zero
(`Matrix.PosSemidef.trace_eq_zero_iff`); since `G⁻¹` is positive *definite*, `xᵀ(G−1)ᵀG⁻¹(G−1)x = 0` for all
`x` forces `(G−1)x = 0` for all `x`. Two honest notes. First, `dualScale_ge` is proved without any eigenvalue
decomposition, and the paper says so; the uniqueness half is *not* — Mathlib's trace lemma goes through the
spectral theorem — and the paper now says that too. Second, this is a statement at `B = 0`; nothing is proved
about the minimizer once `B ≠ 0`. Gates: eight-library build 3781 jobs, 0 errors; statement lock reported
exactly one change (`ADDED dualScale_eq_iff`) before locking; axiom audit 100 theorems, 0 failing, standard
axioms only. This closes roadmap item 6 of the book's chapter 38, which is updated along with chapters 31 and
37 (both said "not formalized").

**9. Moonshine — overstated.** The module proves that `A₁…A₅` of EOT's table each equal an entry of a table
of `M₂₄` irreducible dimensions, and that `A₆`, `A₇` decompose as stated. That is an arithmetic coincidence
between two tables. That the elliptic genus carries an `M₂₄` *action* is Gannon's theorem, Tier L, and the
table's own correctness rests on its source plus a Burnside check (`M24RepDim_sum_sq`). "Validates the
observation" is more than this supports.

**10. "Human orchestrator" — incorrect; and we had made the same error ourselves.** Paper 8 §9.1 says the
orchestrator was a model (Opus). Statement review, tiering and every gate run were done by that model under
the author's direction; no human checked each step. While checking this point we found the phrase "human
orchestrator" in our own paper 9 (§12.1), written the same day. It is corrected, together with a sentence in
paper 9 §4 that said only "a human re-reading the source" can catch a false citation — in fact the CKN
transcription error was caught by the model re-reading it. The review's slip was useful precisely because it
was also ours.

**11. "Caught 100% of the time" — not knowable.** We can list the false success reports that the gate
caught (three, all from the same model tier). A false report the gate missed would not be in that list, so no
detection rate can be inferred from it. What the design does guarantee is narrower: an agent's report is never
counted, only a kernel recompilation is, so a false report cannot by itself place an unproved statement in
the library. It gives no protection against a statement that compiles but says the wrong thing (see #2).

**12. No general conclusion about AI.** Three incidents in one project do not "prove" anything about language
models and mathematics. Also, the Lean kernel is a type checker for a dependent type theory; nothing about it
is cryptographic.

**13. "Bulletproof, bug-free" — rejected.** This repository's history contains the bugs listed under #2, a
proof that used `native_decide` until the axiom audit flagged it, a roadmap sketch in paper 7 that did not
compile when it was finally compiled, and a book whose Lean-name check reported 89 unresolved names — many
were artefacts of the checker, but a number were genuine misuses, in 12 chapters. Each was
found and fixed, which is an argument for the method, not a claim that nothing remains. Paper 8 now lists
"absolute certainty", "bulletproof" and "bug-free" among the phrases it does not use.

## What was not done, and why
* **The Zenodo record of paper 8 (10.5281/zenodo.22823733) is unchanged.** Published files are frozen; paper 8
  Revision 2 lives in the repository. Issuing it as a new *version* of that record is the author's decision.
* **The theorem atlas and the book's theorem index were not regenerated.** They are built from a kernel
  dependency dump that predates Stream 3 and this theorem, so they still list 427 declarations.
  `tools/check_book_lean_names.py` was extended so that a theorem newer than the dump is resolved through its
  source declaration and then verified by Lean under its full name (a negative control with two invented names
  was run and rejected both).
