/-
Stream 9 · S9.3 — the crystallographic restriction on an orientifold group, stated honestly.

An orbifold/orientifold group must act on `T⁶ = ℝ⁶/Λ` by isometries **preserving the lattice**, hence by integer
matrices in a lattice basis. That restricts the possible finite orders: a matrix of finite order `n` over `ℤ` of
size `d` exists only if `φ(n) ≤ d`, because its minimal polynomial is a product of cyclotomics and
`deg Φ_n = φ(n)`. For `d = 6` (the geometric action on `T⁶`) this leaves the orders below.

### What is proved here (Tier A)
* `phi_le_six_list`: the `n ≥ 1` with `φ(n) ≤ 6` are exactly `1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 18`
  (checked for every `n ≤ 200`, and `φ(n) > 6` for all `n` in `(18, 200]`).
* `theta_orders`: the three elements used in `NarainT6.lean` have order 2 (`θᵢ² = 1`, `θᵢ ≠ 1`), so they are
  inside the list, as they must be.
* `rank_two_case`: the rank-2 case used in Stream 8 §8 — `φ(n) ≤ 2` gives `n ∈ {1, 2, 3, 4, 6}` — is the same
  statement one dimension at a time, recomputed here so the two streams share one lemma.

### What is NOT proved here (Tier L)
**The crystallographic restriction theorem itself** — that a finite-order integer matrix of size `d` forces
`φ(n) ≤ d` — is *not* formalized in this file. It needs the theory of cyclotomic polynomials and the rational
canonical form; Mathlib has the ingredients, and this is the natural next target, but asserting the theorem here
would be claiming what has not been checked. What this file provides is the arithmetic side (the list of orders)
and the concrete check for the orders actually used. The physics statement — that an orientifold group must act
crystallographically — is the standard one, cited from the references pinned in `NarainT6.lean`.
-/
import DualScaleStream2.Orientifold.NarainT6

namespace DualScaleStream2.Orientifold.Crystallography

open Nat

/-- The orders allowed on a rank-6 lattice by `φ(n) ≤ 6`, and the fact that nothing above 18 qualifies up to 200. -/
theorem phi_le_six_list :
    ((List.range 201).filter fun n => 1 ≤ n && Nat.totient n ≤ 6) =
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 18] := by
  decide +kernel

/-- The rank-2 case (Stream 8 §8): `φ(n) ≤ 2` leaves the familiar crystallographic orders. -/
theorem rank_two_case :
    ((List.range 201).filter fun n => 1 ≤ n && Nat.totient n ≤ 2) = [1, 2, 3, 4, 6] := by
  decide +kernel

/-- The `ℤ₂ × ℤ₂` elements of `NarainT6.lean` have order exactly 2. -/
theorem theta_orders :
    (theta1 * theta1 = 1 ∧ theta1 ≠ 1) ∧ (theta2 * theta2 = 1 ∧ theta2 ≠ 1) ∧
      (theta3 * theta3 = 1 ∧ theta3 ≠ 1) := by
  refine ⟨⟨theta_isometries.2.1.1, ?_⟩, ⟨theta_isometries.2.1.2.1, ?_⟩,
    ⟨theta_isometries.2.1.2.2, ?_⟩⟩
  · intro h
    have := congrFun (congrFun h 0) 0
    simp [theta1, Matrix.one_apply] at this
  · intro h
    have := congrFun (congrFun h 4) 4
    simp [theta2, Matrix.one_apply] at this
  · intro h
    have := congrFun (congrFun h 0) 0
    simp [theta3, Matrix.one_apply] at this

/-- `2` is in the allowed list, as it must be. -/
theorem order_two_allowed : (2 : ℕ) ∈ ((List.range 201).filter fun n => 1 ≤ n && Nat.totient n ≤ 6) := by
  decide +kernel

end DualScaleStream2.Orientifold.Crystallography
