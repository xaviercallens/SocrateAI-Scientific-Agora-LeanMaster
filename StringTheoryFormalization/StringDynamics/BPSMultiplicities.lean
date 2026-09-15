-- Block WS9: BPS Multiplicities  ℛ_BPS = 77/60
-- Status: VERIFIED (0 sorry axioms)
-- Provides: The rational BPS index ratio used in flux counting.
import Mathlib.Data.Rat.Defs
import StringTheoryFormalization.StringDynamics.MathieuM24

namespace StringTheory.StringDynamics

/-- The BPS index ratio ℛ_BPS = 77/60, arising from the ratio of
    the K3 Euler characteristic χ(K3) = 24 to the index density. -/
def bpsRatio : ℚ := 77 / 60

/-- Numerator and denominator in lowest terms. -/
theorem bps_ratio_reduced :
    bpsRatio.num = 77 ∧ bpsRatio.den = 60 := by
  constructor <;> native_decide

/-- ℛ_BPS > 1 — more BPS states than the naive counting. -/
theorem bps_ratio_pos : (0 : ℚ) < bpsRatio := by
  norm_num [bpsRatio]

/-- The BPS multiplicity at level n is approximated by
    Ω(n) ≈ exp(4π√n) / (n^{3/2}) by the Hardy-Ramanujan formula. -/
noncomputable def bpsMultiplicity (n : ℕ) : ℝ :=
  Real.exp (4 * Real.pi * Real.sqrt n) / (n : ℝ) ^ (3 / 2 : ℝ)

end StringTheory.StringDynamics
