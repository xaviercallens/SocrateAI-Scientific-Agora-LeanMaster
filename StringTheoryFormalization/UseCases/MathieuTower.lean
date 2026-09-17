-- Use Case 4: The Mathieu Group Point-Stabilizer Tower M24 ⊃ M23 ⊃ M22 ⊃ M21
-- Status: VERIFIED (0 sorry, 0 admit) — arithmetic consistency is Tier A;
--         the individual group orders are Tier L (standard ATLAS values, not
--         re-derived here from the Golay-code/group-action construction).
-- Source: Conway-Norton (1979); ATLAS of Finite Groups (Conway et al. 1985);
--         builds on the already-certified `StringDynamics.MathieuM24.M24_order`.
import Mathlib.Tactic.NormNum
import StringTheoryFormalization.StringDynamics.MathieuM24

namespace StringTheory.UseCases.MathieuTower

open StringTheory.StringDynamics

/-!
# The Mathieu Point-Stabilizer Tower

## Physical background

`M₂₄` is the sporadic simple group that appears in Mathieu Moonshine: the elliptic
genus of K3 decomposes into characters of the `N=4` superconformal algebra whose
multiplicities are (twice) dimensions of `M₂₄` representations (Eguchi-Ooguri-Tachikawa
2010; Gaberdiel-Hohenegger-Volpato, `papers/foundations/
gaberdiel_hohenegger_volpato_mathieu_1006_0221.txt`, who work extensively with the
subgroup chain `M₂₃ ⊂ M₂₄` when computing twining genera for group elements that fix a
point — e.g. l.811, "elements in `M₂₄` that are not in `M₂₃`"). `M₂₄` acts on the 24
points of the extended binary Golay code; this action is 5-transitive, and successively
fixing points peels off the point-stabilizer tower `M₂₄ ⊃ M₂₃ ⊃ M₂₂ ⊃ M₂₁ ≅ PSL(3,4)`,
with each step an orbit-stabilizer relation `|Gₙ| = n·|Gₙ₋₁|`. The individual group
orders themselves (`|M₂₃|=10200960` etc.) are standard ATLAS-of-Finite-Groups data
(Conway et al. 1985; Conway-Norton 1979); they are **not checked against a source in
this book's library** — this project has no formalization of the Golay code or of group
actions, only the numerical orders, taken as given.

## Mathematical content

`orderM23`, `orderM22`, `orderM21` are hard-coded natural-number constants (the ATLAS
values). The file proves four arithmetic facts about them and the numeral
`244823040 = |M₂₄|` (itself proved equal to `2^10·3^3·5·7·11·23` in the already-certified
`StringDynamics.MathieuM24.M24_order`): the three orbit-stabilizer index relations
`244823040 = 24·orderM23`, `orderM23 = 23·orderM22`, `orderM22 = 22·orderM21`; the prime
factorization of `orderM21 = 2^6·3^2·5·7`; and the **main result**
`mathieu_tower_consistent`, that composing the tower `24·(23·(22·orderM21))` lands back
on `244823040`. This is a check that four given numerals multiply out consistently — it
is **not** a formalization of the Mathieu group, its Golay-code action, transitivity, or
the orbit-stabilizer theorem itself; no group, group action or code appears anywhere in
this file, only their orders as bare numerals.

## Proof techniques

Every proof is `unfold` followed by `norm_num` (verifying one numeral equation) or, for
the two composition theorems, a chain of `rw` substituting the already-proved index
relations (and, in `mathieu_tower_matches_certified_order`, the imported `M24_order`)
into each other so the final numeral equality is definitional.

## Related declarations

* `StringTheory.StringDynamics.M24_order` (imported) is the declaration
  `mathieu_tower_matches_certified_order` ties back to; the atlas records the pair
  `M24_order ∩ M21_order_factorization` at dep-Jaccard 0.925 but cosine only 0.112 —
  the high overlap is shared `norm_num`/numeral machinery, not a mathematical
  coincidence, since one literally imports and cites the other by name in this file.
* `StringTheory.StringDynamics.M24RepDim`/`M24RepDim_sum_sq` (same source file) certify
  a *different* fact about `M₂₄` — that a hard-coded list of representation dimensions
  squares-and-sums to `|M₂₄|` — complementary Moonshine bookkeeping, not overlapping
  with the stabilizer tower proved here.
* `DualScaleValidation.UseCase2.m24_order_divisible_by_bps_lock` (cosine 0.429 with
  `Lean5Corpus.Problems.MathieuFrobenius.conductor_divisible_by_first_five_primes`) is an
  independent re-proof, in a different library, of a related divisibility fact about
  `|M₂₄|`; it does not use this file's tower directly.
-/

/-- Order of `M₂₃` (standard ATLAS value; not re-derived from a group action here). -/
def orderM23 : ℕ := 10200960

/-- Order of `M₂₂` (standard ATLAS value; not re-derived from a group action here). -/
def orderM22 : ℕ := 443520

/-- Order of `M₂₁ ≅ PSL(3,4)` (standard ATLAS value; not re-derived here). -/
def orderM21 : ℕ := 20160

/-- `M₂₄` acts transitively on 24 points with point stabilizer `M₂₃`. -/
theorem M24_stabilizer_index : 244823040 = 24 * orderM23 := by
  unfold orderM23; norm_num

/-- `M₂₃` acts transitively on 23 points with point stabilizer `M₂₂`. -/
theorem M23_stabilizer_index : orderM23 = 23 * orderM22 := by
  unfold orderM23 orderM22; norm_num

/-- `M₂₂` acts transitively on 22 points with point stabilizer `M₂₁`. -/
theorem M22_stabilizer_index : orderM22 = 22 * orderM21 := by
  unfold orderM22 orderM21; norm_num

/-- `PSL(3,4)` has the standard order `20160 = 2^6 · 3^2 · 5 · 7`. -/
theorem M21_order_factorization : orderM21 = 2 ^ 6 * 3 ^ 2 * 5 * 7 := by
  unfold orderM21; norm_num

/-- **Main result**: composing the whole stabilizer tower `24 · 23 · 22`
    against the `PSL(3,4)` order lands back exactly on the already-certified
    `M24_order` — i.e. the tower is self-consistent end to end, tying this
    file's new claims to `MathieuM24`'s existing Tier-A result rather than
    merely restating disconnected numbers. -/
theorem mathieu_tower_consistent :
    24 * (23 * (22 * orderM21)) = 244823040 := by
  rw [← M22_stabilizer_index, ← M23_stabilizer_index, ← M24_stabilizer_index]

/-- Cross-check against the certified factorization in `MathieuM24`: the tower
    product equals the prime factorization already proved there. -/
theorem mathieu_tower_matches_certified_order :
    24 * (23 * (22 * orderM21)) = 2 ^ 10 * 3 ^ 3 * 5 * 7 * 11 * 23 := by
  rw [mathieu_tower_consistent, M24_order]

end StringTheory.UseCases.MathieuTower
