/-
Stream 2 · The Dual-Scale bound on a `d`-torus.

The project's dual-scale principle (Stream 1: `DualScaleM24Formalization.DualScale.EffectiveMetric`,
`genesis_no_singularity`) is the circle statement `R_eff(R) = R + α'/R ≥ 2√α'`: no
T-duality-invariant scale can shrink below the string scale. This file proves the
`d`-dimensional generalization on the space of flat torus metrics.

Define the **dual scale** of a torus metric `G` as the trace of its generalized metric at
`B = 0`: `𝒟(G) = tr H(G,0) = tr G + tr G⁻¹` (Hull–Zwiebach eq. (2.17), see
`DFT.GeneralizedMetric`).

Tier A here, for every `d`:
* `𝒟(G⁻¹) = 𝒟(G)` — invariance under the full T-duality;
* `𝒟(G) ≥ 2d` for every positive-definite `G` — via `tr((G−1) G⁻¹ (G−1)) ≥ 0`, which
  expands to `tr G + tr G⁻¹ − 2d`; no eigenvalue decomposition needed;
* the bound is attained at the self-dual point `G = 1`;
* at `d = 1`, `G = R²`: `𝒟 = (R + 1/R)² − 2`, so the torus bound specializes to exactly the
  circle statement `R + 1/R ≥ 2` behind Stream 1's dual-scale principle.

Not claimed: any cosmological interpretation (Tier C in the project's own narrative).
-/
import DualScaleStream2.DFT.GeneralizedMetric
import Mathlib.LinearAlgebra.Matrix.PosDef

namespace DualScaleStream2.DualScale

open Matrix DualScaleStream2.DFT

variable {d : ℕ}

/-- Dual scale `𝒟(G) = tr H(G, 0)`. -/
noncomputable def dualScale (G : Matrix (Fin d) (Fin d) ℝ) : ℝ := (genMetric G 0).trace

theorem dualScale_eq (G : Matrix (Fin d) (Fin d) ℝ) :
    dualScale G = G.trace + G⁻¹.trace := by
  simp [dualScale, genMetric, Matrix.mul_apply, Matrix.one_apply, Matrix.conjTranspose_apply]
  <;>
    simp_all [Matrix.trace, Matrix.mul_apply, Finset.sum_apply, Finset.sum_apply]
  <;>
    rfl

/-- T-duality invariance. -/
theorem dualScale_inv (G : Matrix (Fin d) (Fin d) ℝ) (hG : IsUnit G.det) :
    dualScale G⁻¹ = dualScale G := by
  rw [dualScale_eq, dualScale_eq]
  have h_inv_inv : (G⁻¹)⁻¹ = G := Matrix.nonsing_inv_nonsing_inv G hG
  rw [h_inv_inv]
  ring

/-- **Dual-scale bound** on the space of torus metrics. -/
theorem dualScale_ge (G : Matrix (Fin d) (Fin d) ℝ) (hG : G.PosDef) :
    (2 * d : ℝ) ≤ dualScale G := by
  rw [dualScale_eq]
  have hdet : IsUnit G.det := G.isUnit_iff_isUnit_det.mp hG.isUnit
  have hl : G⁻¹ * G = 1 := Matrix.nonsing_inv_mul G hdet
  have hr : G * G⁻¹ = 1 := Matrix.mul_nonsing_inv G hdet
  have hGinv_psd : G⁻¹.PosSemidef := hG.posSemidef.inv
  have hGT : Gᵀ = G := (Matrix.conjTranspose_eq_transpose_of_trivial G).symm.trans hG.isHermitian
  have hMh : (G - 1)ᴴ = G - 1 := by
    rw [Matrix.conjTranspose_eq_transpose_of_trivial, Matrix.transpose_sub,
      Matrix.transpose_one, hGT]
  have hpsd : ((G - 1)ᴴ * G⁻¹ * (G - 1)).PosSemidef :=
    Matrix.PosSemidef.conjTranspose_mul_mul_same hGinv_psd (G - 1)
  rw [hMh] at hpsd
  have htrace_nonneg : 0 ≤ ((G - 1) * G⁻¹ * (G - 1)).trace := hpsd.trace_nonneg
  have hexpand : (G - 1) * G⁻¹ * (G - 1) = (G - 1) - (1 - G⁻¹) := by
    rw [Matrix.sub_mul, Matrix.one_mul, Matrix.sub_mul, Matrix.mul_sub, Matrix.mul_sub]
    simp only [Matrix.mul_one]
    rw [hr, hl, Matrix.one_mul]
  rw [hexpand] at htrace_nonneg
  rw [Matrix.trace_sub, Matrix.trace_sub, Matrix.trace_sub, Matrix.trace_one] at htrace_nonneg
  simp only [Fintype.card_fin] at htrace_nonneg
  linarith

/-- The bound is attained at the self-dual metric. -/
theorem dualScale_one : dualScale (1 : Matrix (Fin d) (Fin d) ℝ) = 2 * d := by
  rw [dualScale_eq]
  simp [Matrix.trace_one, inv_one]
  ring

/-- Circle case: `𝒟(R²) = (R + 1/R)² − 2`. -/
theorem dualScale_circle (R : ℝ) (hR : R ≠ 0) :
    dualScale (!![R ^ 2] : Matrix (Fin 1) (Fin 1) ℝ) = (R + R⁻¹) ^ 2 - 2 := by
  rw [dualScale_eq]
  have hinv : (!![R ^ 2] : Matrix (Fin 1) (Fin 1) ℝ)⁻¹ = !![(R ^ 2)⁻¹] := by
    rw [Matrix.inv_def, Matrix.det_fin_one_of, Matrix.adjugate_fin_one, Ring.inverse_eq_inv]
    ext i j
    fin_cases i <;> fin_cases j <;> simp
  rw [hinv]
  simp only [Matrix.trace_fin_one_of]
  field_simp
  ring

/-- **Specialization to Stream 1's dual-scale principle**: `R + 1/R ≥ 2` for `R > 0` —
    the `d = 1` content of `dualScale_ge` together with `dualScale_circle`. -/
theorem circle_effective_scale_ge_two (R : ℝ) (hR : 0 < R) : 2 ≤ R + R⁻¹ := by
  have h : R + R⁻¹ - 2 = (R - 1) ^ 2 / R := by field_simp; ring
  have h_nonneg : 0 ≤ (R - 1) ^ 2 / R := by
    apply div_nonneg
    · exact sq_nonneg (R - 1)
    · linarith
  linarith

end DualScaleStream2.DualScale
