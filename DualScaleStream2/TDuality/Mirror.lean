/-
Stream 2 · P2.2 — On `T²`, the factorized duality `D₀` conjugates the τ-shift into a B-shift.

Source (Tier L, for the interpretation): Giveon–Porrati–Rabinovici hep-th/9401139
(`papers/foundations/giveon_hep-th_9401139.txt`, line 344): "For a complex torus, mirror
symmetry is identical to what is called 'factorized duality'". On `T²` the complex-structure
modulus τ and the Kähler modulus ρ = B + i√det G are exchanged by it.

Tier A here: the exact integer matrix identity (verified with sympy before formalization)
    `D₀ · basisChange(T, (Tᵀ)⁻¹) · D₀ = (g_Θ)ᵀ`,  `T = [[1,1],[0,1]]`, `Θ = [[0,−1],[1,0]]`,
i.e. conjugating the unimodular basis change `T` (the τ ↦ τ + 1 generator) by the
factorized duality gives the transpose Θ-shift — which, by `DFT.BShift.genMetric_bshift`,
is exactly the form acting on the generalized metric as an integer B-field shift. Which
*sign* of the ρ-shift this is depends on the orientation convention for ρ and is not
claimed here.
-/
import DualScaleStream2.TDuality.Factorized

namespace DualScaleStream2.TDuality

open Matrix

/-- `T = [[1,1],[0,1]]`. -/
def tauShift : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 0, 1]

/-- `(Tᵀ)⁻¹ = [[1,0],[-1,1]]`. -/
def tauShiftDual : Matrix (Fin 2) (Fin 2) ℤ := !![1, 0; -1, 1]

theorem tauShift_dual_spec : tauShiftᵀ * tauShiftDual = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [tauShift, tauShiftDual, Matrix.mul_apply, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;> decide

/-- The τ-shift is in `O(2,2;ℤ)`. -/
theorem tauShift_isODD : IsODD (basisChange tauShift tauShiftDual) :=
  basisChange_isODD _ _ tauShift_dual_spec

/-- `Θ = [[0,−1],[1,0]]` (antisymmetric). -/
def mirrorTheta : Matrix (Fin 2) (Fin 2) ℤ := !![0, -1; 1, 0]

theorem mirrorTheta_antisymm : mirrorThetaᵀ = -mirrorTheta := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- **Mirror identity**: `D₀ T D₀ = g_Θᵀ`. -/
theorem mirror_conjugates_tauShift :
    factorized (0 : Fin 2) * basisChange tauShift tauShiftDual * factorized 0 =
      (thetaShift mirrorTheta)ᵀ := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

end DualScaleStream2.TDuality
