-- Use Case 1: T-Duality Invariance of the Closed String Mass Spectrum
-- Status: VERIFIED (0 sorry, 0 admit)
-- Source: Polchinski Vol.1 §8.1-8.2; Giveon-Porrati-Rabinovici (1994) hep-th/9401139.
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace StringTheory.UseCases.TDuality

/-!
# T-Duality Invariance of the Closed-String Mass Spectrum

A closed string compactified on a circle of radius `R` (units `α' = 1`) carries
integer momentum number `n` and integer winding number `w`. Its left/right-moving
target-space momenta are
  `P_L(n, w, R) = n / R + w R`,
  `P_R(n, w, R) = n / R - w R`.
T-duality is the discrete symmetry `R ↦ 1/R`, `n ↦ w`, `w ↦ n` (Buscher's rules,
already partly certified for the dilaton sector in
`DoubleFieldTheory.TDualityBuscher`). This file certifies the piece that module's
docstring *states* but does not itself prove: that this map leaves the physical
mass spectrum exactly invariant, by tracking what it does to `P_L`, `P_R`
individually, not just to `M²`.

The mass² formula is `M² = P_L² + P_R² + (2/α')(N + Ñ - 2)`; the oscillator term
is untouched by the duality map, so only the momentum piece needs to be checked.
-/

/-- Left-moving momentum: combination of momentum and winding that survives
    T-duality unchanged. -/
def leftMomentum (n w R : ℚ) : ℚ := n / R + w * R

/-- Right-moving momentum: the combination that flips sign under T-duality
    (this sign flip is the defining, non-trivial content of Buscher's rule). -/
def rightMomentum (n w R : ℚ) : ℚ := n / R - w * R

/-- Momentum-squared contribution to `M²`. -/
def momentumMassSq (n w R : ℚ) : ℚ := (leftMomentum n w R) ^ 2 + (rightMomentum n w R) ^ 2

/-- **T-duality on the left-mover**: exchanging `(n,w) ↦ (w,n)` and `R ↦ 1/R`
    leaves `P_L` exactly fixed. -/
theorem tduality_fixes_left_momentum (n w R : ℚ) (hR : R ≠ 0) :
    leftMomentum w n (1 / R) = leftMomentum n w R := by
  unfold leftMomentum
  field_simp
  ring

/-- **T-duality on the right-mover**: the same exchange flips the *sign* of
    `P_R`. This sign flip is what makes T-duality a genuine ℤ₂ symmetry of the
    worldsheet theory (a parity on the right-moving sector) rather than a
    trivial relabeling. -/
theorem tduality_flips_right_momentum (n w R : ℚ) (hR : R ≠ 0) :
    rightMomentum w n (1 / R) = - rightMomentum n w R := by
  unfold rightMomentum
  field_simp
  ring

/-- **Main result**: the momentum contribution to `M²` is exactly invariant
    under T-duality, since it only ever sees `P_L²` and `P_R²`, and squaring
    erases the sign flip on `P_R`. -/
theorem tduality_invariant_mass_squared (n w R : ℚ) (hR : R ≠ 0) :
    momentumMassSq w n (1 / R) = momentumMassSq n w R := by
  unfold momentumMassSq
  rw [tduality_fixes_left_momentum n w R hR, tduality_flips_right_momentum n w R hR]
  ring

/-- The self-dual radius `R = 1` is the unique positive fixed point of `R ↦ 1/R`. -/
theorem self_dual_radius_unique (R : ℚ) (hR : 0 < R) (hFix : (1 : ℚ) / R = R) :
    R = 1 := by
  have hR' : R ≠ 0 := ne_of_gt hR
  field_simp at hFix
  nlinarith [sq_nonneg (R - 1), sq_nonneg (R + 1)]

end StringTheory.UseCases.TDuality
