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

`M₂₄` — the sporadic group central to Mathieu Moonshine (already certified in
`StringDynamics.MathieuM24.M24_order`, order `244823040 = 2^10·3^3·5·7·11·23`)
— is constructed as automorphisms of the extended binary Golay code acting on
24 points. This action is 5-transitive, and successively stabilizing points
peels off a *tower* of smaller Mathieu groups:

    M₂₄  ⊃  M₂₃  ⊃  M₂₂  ⊃  M₂₁ ≅ PSL(3,4)
  (24 pts)  (23 pts)  (22 pts)   (21 pts)

with `|M₂₄| = 24·|M₂₃|`, `|M₂₃| = 23·|M₂₂|`, `|M₂₂| = 22·|M₂₁|` (orbit-stabilizer,
since each action is transitive on the indicated number of points). This file
certifies that the four standard ATLAS orders are arithmetically consistent
with that tower, and that the tower composes back to exactly the already
certified `M24_order`.
-/

/-- Order of `M₂₃` (ATLAS). -/
def orderM23 : ℕ := 10200960

/-- Order of `M₂₂` (ATLAS). -/
def orderM22 : ℕ := 443520

/-- Order of `M₂₁ ≅ PSL(3,4)` (ATLAS). -/
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
