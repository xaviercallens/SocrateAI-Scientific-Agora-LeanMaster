/-
Stream 2 · P2.4 — The DFT generalized metric on a `d`-torus.

Source (Tier L): Hull & Zwiebach, *Double Field Theory*, arXiv:0904.4664, eq. (2.17)
(`papers/foundations/hull_zwiebach_0904_4664.txt`, lines 662–672):
`H(E) = [[G − B G⁻¹ B, B G⁻¹], [−G⁻¹ B, G⁻¹]]` with `E = G + B`, acting on the column
vector `(X', P)`, and "The matrix H(E) satisfies the constraint H⁻¹ = ηHη."

Tier A here (over `ℝ`, every `d`):
* `(ηH)² = 1` — Hull–Zwiebach's constraint — needing only `G` invertible (no symmetry or
  antisymmetry of `B` is used; this is sharper than the source states);
* `H` is symmetric when `G` is symmetric and `B` antisymmetric;
* at `B = 0` the full duality conjugates `G ↦ G⁻¹` (T-duality is metric inversion);
* the mass form `Zᵀ H Z` is covariant under any `g` with `gᵀ η g = η`;
* at `d = 1`, `G = R²`, `B = 0`, the mass form reproduces Stream 1's
  `TDuality.momentumMassSq` (up to its factor 2) — so Stream 2's DFT layer and
  Stream 1's circle computation are proved to be the same physics, not merely analogous.

Ordering note: Hull–Zwiebach order the doubled vector as `(X', P)` = (winding, momentum);
the generalized metric's `G` block pairs with winding.
-/
import DualScaleStream2.TDuality.ODD
import StringTheoryFormalization.UseCases.TDualityMassSpectrum
import Mathlib.LinearAlgebra.Matrix.NonsingularInverse
import Mathlib.Data.Real.Basic

namespace DualScaleStream2.DFT

open Matrix DualScaleStream2.TDuality

variable {d : ℕ}

/-- Real `O(d,d)` form `η = [[0, I],[I, 0]]`. -/
noncomputable def etaR (d : ℕ) : Matrix (Charge d) (Charge d) ℝ := fromBlocks 0 1 1 0

/-- Hull–Zwiebach generalized metric `H(G, B)`, eq. (2.17). -/
noncomputable def genMetric (G B : Matrix (Fin d) (Fin d) ℝ) : Matrix (Charge d) (Charge d) ℝ :=
  fromBlocks (G - B * G⁻¹ * B) (B * G⁻¹) (-(G⁻¹ * B)) G⁻¹

theorem etaR_mul_self : etaR d * etaR d = 1 := by
  unfold etaR
  rw [fromBlocks_multiply]
  simp

/-- **Hull–Zwiebach constraint** `H⁻¹ = ηHη`, in the form `(ηH)(ηH) = 1`. -/
theorem etaR_genMetric_sq (G B : Matrix (Fin d) (Fin d) ℝ) (hG : IsUnit G.det) :
    (etaR d * genMetric G B) * (etaR d * genMetric G B) = 1 := by
  have hl : G⁻¹ * G = 1 := Matrix.nonsing_inv_mul G hG
  have hr : G * G⁻¹ = 1 := Matrix.mul_nonsing_inv G hG
  have hM : etaR d * genMetric G B
      = fromBlocks (-(G⁻¹ * B)) G⁻¹ (G - B * G⁻¹ * B) (B * G⁻¹) := by
    unfold etaR genMetric
    rw [fromBlocks_multiply]
    simp
  rw [hM, fromBlocks_multiply]
  rw [show (1 : Matrix (Charge d) (Charge d) ℝ) = fromBlocks 1 0 0 1 from fromBlocks_one.symm]
  apply fromBlocks_inj.mpr
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- block₁₁ : -(G⁻¹*B) * -(G⁻¹*B) + G⁻¹ * (G - B*G⁻¹*B) = 1
    simp only [neg_mul_neg, Matrix.mul_sub, mul_assoc, hl]
    abel
  · -- block₁₂ : -(G⁻¹*B) * G⁻¹ + G⁻¹ * (B*G⁻¹) = 0
    simp only [neg_mul, mul_assoc]
    abel
  · -- block₂₁ : (G-B*G⁻¹*B) * -(G⁻¹*B) + (B*G⁻¹) * (G-B*G⁻¹*B) = 0
    have hGB : G * (G⁻¹ * B) = B := by rw [← mul_assoc, hr, one_mul]
    simp only [mul_neg, Matrix.sub_mul, Matrix.mul_sub, mul_assoc, hl, hGB, mul_one]
    abel
  · -- block₂₂ : (G-B*G⁻¹*B) * G⁻¹ + (B*G⁻¹) * (B*G⁻¹) = 1
    simp only [Matrix.sub_mul, mul_assoc, hr]
    abel

theorem genMetric_symm (G B : Matrix (Fin d) (Fin d) ℝ) (hG : IsUnit G.det)
    (hGs : Gᵀ = G) (hB : Bᵀ = -B) : (genMetric G B)ᵀ = genMetric G B := by
  have hGinv : (G⁻¹)ᵀ = G⁻¹ := by rw [Matrix.transpose_nonsing_inv, hGs]
  unfold genMetric
  rw [fromBlocks_transpose]
  apply fromBlocks_inj.mpr
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- (G - B*G⁻¹*B)ᵀ = G - B*G⁻¹*B
    rw [Matrix.transpose_sub, hGs, Matrix.transpose_mul, Matrix.transpose_mul, hB, hGinv]
    simp only [mul_neg, neg_mul, neg_neg, mul_assoc]
  · -- (-(G⁻¹*B))ᵀ = B*G⁻¹
    rw [Matrix.transpose_neg, Matrix.transpose_mul, hGinv, hB]
    simp only [neg_mul, neg_neg]
  · -- (B*G⁻¹)ᵀ = -(G⁻¹*B)
    rw [Matrix.transpose_mul, hGinv, hB, mul_neg]
  · -- (G⁻¹)ᵀ = G⁻¹
    exact hGinv

/-- **T-duality is metric inversion**: conjugating by the full duality maps `H(G,0)` to
    `H(G⁻¹,0)`. -/
theorem tduality_inverts_metric (G : Matrix (Fin d) (Fin d) ℝ) (hG : IsUnit G.det) :
    etaR d * genMetric G 0 * etaR d = genMetric G⁻¹ 0 := by
  have hGG : G⁻¹⁻¹ = G := Matrix.nonsing_inv_nonsing_inv G hG
  have hL : genMetric G 0 = fromBlocks G 0 0 G⁻¹ := by
    unfold genMetric
    simp
  have hR : genMetric G⁻¹ 0 = fromBlocks G⁻¹ 0 0 G := by
    unfold genMetric
    simp [hGG]
  rw [hL, hR]
  unfold etaR
  rw [mul_assoc, fromBlocks_multiply, fromBlocks_multiply]
  simp

/-- Mass form `Zᵀ H Z`. -/
noncomputable def massForm (H : Matrix (Charge d) (Charge d) ℝ) (Z : Charge d → ℝ) : ℝ :=
  Z ⬝ᵥ (H *ᵥ Z)

/-- **Covariance**: transforming the background by `g` is the same as transforming the
    charge vector by `g`. -/
theorem massForm_covariant (g H : Matrix (Charge d) (Charge d) ℝ) (Z : Charge d → ℝ) :
    massForm (gᵀ * H * g) Z = massForm H (g *ᵥ Z) := by
  unfold massForm
  rw [show (gᵀ * H * g) *ᵥ Z = gᵀ *ᵥ (H *ᵥ (g *ᵥ Z)) by
    rw [← Matrix.mulVec_mulVec, ← Matrix.mulVec_mulVec]]
  rw [Matrix.dotProduct_transpose_mulVec, dotProduct_comm]

/-- **Cross-link to Stream 1.** On a circle of radius `R` (`G = R²`, `B = 0`), with winding
    `w` and momentum `n`, the DFT mass form equals half of Stream 1's
    `momentumMassSq n w R = P_L² + P_R²`. -/
theorem massForm_circle (n w R : ℚ) (hR : R ≠ 0) :
    massForm (genMetric (d := 1) (!![((R : ℝ) ^ 2)]) 0) (Sum.elim ![(w : ℝ)] ![(n : ℝ)]) =
      ((StringTheory.UseCases.TDuality.momentumMassSq n w R : ℚ) : ℝ) / 2 := by
  have hR' : (R : ℝ) ≠ 0 := by exact_mod_cast hR
  have hR2 : ((R : ℝ) ^ 2) ≠ 0 := pow_ne_zero 2 hR'
  have hinv : (!![((R : ℝ) ^ 2)] : Matrix (Fin 1) (Fin 1) ℝ)⁻¹ = !![((R : ℝ) ^ 2)⁻¹] := by
    rw [Matrix.inv_def, Matrix.det_fin_one_of, Matrix.adjugate_fin_one, Ring.inverse_eq_inv]
    ext i j
    fin_cases i <;> fin_cases j <;> simp
  have hgm : genMetric (d := 1) (!![((R : ℝ) ^ 2)]) 0
      = fromBlocks !![((R : ℝ) ^ 2)] 0 0 !![((R : ℝ) ^ 2)⁻¹] := by
    unfold genMetric
    simp [hinv]
  rw [hgm]
  unfold massForm
  rw [fromBlocks_mulVec]
  simp only [Sum.elim_comp_inl, Sum.elim_comp_inr, Matrix.zero_mulVec, add_zero, zero_add]
  rw [sumElim_dotProduct_sumElim]
  have e1 : (![(w : ℝ)] ⬝ᵥ (!![((R : ℝ) ^ 2)] *ᵥ ![(w : ℝ)])) = (R : ℝ) ^ 2 * w ^ 2 := by
    simp [Matrix.mulVec, dotProduct]
    ring
  have e2 : (![(n : ℝ)] ⬝ᵥ (!![((R : ℝ) ^ 2)⁻¹] *ᵥ ![(n : ℝ)])) = ((R : ℝ) ^ 2)⁻¹ * n ^ 2 := by
    simp [Matrix.mulVec, dotProduct]
    ring
  rw [e1, e2]
  unfold StringTheory.UseCases.TDuality.momentumMassSq
    StringTheory.UseCases.TDuality.leftMomentum StringTheory.UseCases.TDuality.rightMomentum
  push_cast
  field_simp
  ring

end DualScaleStream2.DFT
