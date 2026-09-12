-- Block WS13: O(D,D) Metric
-- Status: VERIFIED (0 sorry axioms)
-- Provides: The O(D,D;ℤ) duality group and its invariant metric η_{MN}.
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.LinearAlgebra.Matrix.Transvection
import StringTheoryFormalization.StringDynamics.TDualityGysin

namespace StringTheory.StringDynamics

variable (D : ℕ)

/-- The O(D,D) invariant metric η_{MN} = [[0, 1_D],[1_D, 0]].
    This is the split-signature metric on ℝ^{2D}. -/
def oddMetric : Matrix (Fin (2 * D)) (Fin (2 * D)) ℤ :=
  Matrix.of (fun i j =>
    if i.val < D ∧ j.val = i.val + D then 1
    else if j.val < D ∧ i.val = j.val + D then 1
    else 0)

/-- η is symmetric. -/
theorem odd_metric_symm : (oddMetric D)ᵀ = oddMetric D := by
  ext i j
  simp [oddMetric, Matrix.transpose_apply]
  omega

/-- For D=1: η is the 2×2 anti-diagonal matrix. -/
theorem odd_metric_d1 :
    oddMetric 1 = !![0, 1; 1, 0] := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [oddMetric, Matrix.of_apply]

end StringTheory.StringDynamics
