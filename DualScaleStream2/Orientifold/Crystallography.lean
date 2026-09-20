/-
Stream 9 · S9.3 — the crystallographic restriction on an orientifold group, stated honestly.

An orbifold/orientifold group must act on `T⁶ = ℝ⁶/Λ` by isometries **preserving the lattice**, hence by integer
matrices in a lattice basis. That restricts the possible finite orders. This file computes the arithmetic of `φ`;
it is **not** the crystallographic restriction, and the two must not be confused.

> **Correction (S9.4, `CrystallographicOrders.lean`).** An earlier version of this header claimed that a matrix of
> finite order `n` over `ℤ` of size `d` exists only if `φ(n) ≤ d`. **That is false for every `d ≥ 5`**, and S9.4
> refutes it in the kernel: `diag(C_{Φ₃}, C_{Φ₅}) ∈ SL(6, ℤ)` has order `15` while `φ(15) = 8 > 6`. The order of a
> matrix is the `lcm` of its eigenvalue orders, not the largest of them, so no eigenvalue need be a primitive
> `n`-th root of unity. The correct criterion is `ψ(n) = Σ_{p^a ‖ n, p^a ≠ 2} φ(p^a) ≤ d`; for `d = 6` it adds
> exactly `15, 20, 24, 30` to the list below. **The `φ`-list proved here is correct arithmetic about `φ` and
> nothing more** — for the orders available on a rank-6 lattice, read `CrystallographicOrders.psi_le_six_list`.
> The rank-2 list is unaffected: `ψ(n) ≤ 2` and `φ(n) ≤ 2` agree (`rank_two_unaffected`).

### What is proved here (Tier A)
* `phi_le_six_list`: the `n ≥ 1` with `φ(n) ≤ 6` are exactly `1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 18`
  (checked for every `n ≤ 200`, and `φ(n) > 6` for all `n` in `(18, 200]`).
* `theta_orders`: the three elements used in `NarainT6.lean` have order 2 (`θᵢ² = 1`, `θᵢ ≠ 1`), so they are
  inside the list, as they must be.
* `rank_two_case`: the rank-2 case used in Stream 8 §8 — `φ(n) ≤ 2` gives `n ∈ {1, 2, 3, 4, 6}` — is the same
  statement one dimension at a time, recomputed here so the two streams share one lemma.

### What is NOT proved here (Tier L)
**The crystallographic restriction theorem itself** — that a finite-order integer matrix of size `d` and order
`n` forces `ψ(n) ≤ d` — is *not* formalized. What S9.4 does establish is the converse direction for the cases at
issue: the four orders `ψ` admits beyond the `φ`-list are realised by explicit matrices in `SL(6, ℤ)`, so an
enumeration built on `φ(n) ≤ 6` provably misses cases. The physics statement — that an orientifold group must act
crystallographically — is the standard one, cited from the references pinned in `NarainT6.lean`.
-/
import DualScaleStream2.Orientifold.NarainT6

namespace DualScaleStream2.Orientifold.Crystallography

open Nat

/-- The `n ≤ 200` with `φ(n) ≤ 6`. **This is arithmetic about `φ`, not the list of orders available on a rank-6
lattice** — see the correction in the header and `CrystallographicOrders.psi_le_six_list`. -/
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

/-- `2` is in the `φ`-list, as it must be — and in the corrected `ψ`-list too, since `ψ(2) = 0`. -/
theorem order_two_allowed : (2 : ℕ) ∈ ((List.range 201).filter fun n => 1 ≤ n && Nat.totient n ≤ 6) := by
  decide +kernel

end DualScaleStream2.Orientifold.Crystallography
