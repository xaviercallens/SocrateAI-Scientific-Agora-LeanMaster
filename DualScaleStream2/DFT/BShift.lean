/-
Stream 2 · P2.4 — Integer B-field shifts are T-dualities of the generalized metric.

Sources (Tier L): Giveon–Porrati–Rabinovici hep-th/9401139 §2.4 eq. (2.4.25)
(`papers/foundations/giveon_hep-th_9401139.txt`, lines 1355–1373): the Θ-shift
`g_Θ = [[I, Θ],[0, I]]` with integer antisymmetric Θ is "a symmetry of the spectrum … the
B-term … gives only topological contributions"; Hull–Zwiebach eq. (2.17) for `H(G, B)`.

Tier A here, every `d`, over `ℝ`: for invertible symmetric `G`, antisymmetric `B` and `Θ`,
    `g_Θ · H(G, B) · g_Θᵀ = H(G, B + Θ)`.
The convention was checked *before* formalization (sympy, `d = 2`, generic symbols): of
the four candidates `g Hgᵀ`/`gᵀHg` with `±Θ` in the upper or lower block, exactly this one
holds, so the sign/ordering here is not a guess.

Combined with `TDuality.thetaShift_isODD` (the Θ-shift lies in `O(d,d;ℤ)`) this says the
periodic identification `B ∼ B + Θ` of the B-field is an `O(d,d;ℤ)` duality of the DFT
background.
-/
import DualScaleStream2.DFT.GeneralizedMetric

namespace DualScaleStream2.DFT

open Matrix DualScaleStream2.TDuality

variable {d : ℕ}

/-- Real Θ-shift `g_Θ = [[I, Θ],[0, I]]`. -/
noncomputable def thetaShiftR (Θ : Matrix (Fin d) (Fin d) ℝ) : Matrix (Charge d) (Charge d) ℝ :=
  fromBlocks 1 Θ 0 1

/-- **B-shift covariance.** -/
theorem genMetric_bshift (G B Θ : Matrix (Fin d) (Fin d) ℝ) (hG : IsUnit G.det)
    (hGs : Gᵀ = G) (hB : Bᵀ = -B) (hΘ : Θᵀ = -Θ) :
    thetaShiftR Θ * genMetric G B * (thetaShiftR Θ)ᵀ = genMetric G (B + Θ) := by
  unfold thetaShiftR genMetric
  rw [fromBlocks_transpose, fromBlocks_multiply, fromBlocks_multiply, Matrix.transpose_one,
    Matrix.transpose_zero, hΘ]
  apply fromBlocks_inj.mpr
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- block₁₁
    simp only [Matrix.one_mul, Matrix.zero_mul, zero_add, Matrix.mul_one, Matrix.add_mul,
      Matrix.mul_add, Matrix.mul_assoc, Matrix.neg_mul, Matrix.mul_neg, neg_neg]
    abel
  · -- block₁₂
    simp only [Matrix.one_mul, Matrix.zero_mul, zero_add, Matrix.mul_one, Matrix.mul_zero,
      add_zero, Matrix.add_mul]
  · -- block₂₁
    simp only [Matrix.one_mul, Matrix.zero_mul, Matrix.mul_one, Matrix.mul_zero, add_zero,
      zero_add, Matrix.mul_add, Matrix.mul_neg, neg_add]
  · -- block₂₂
    simp only [Matrix.one_mul, Matrix.zero_mul, Matrix.mul_one, Matrix.mul_zero, add_zero,
      zero_add]

/-- The real Θ-shift preserves `η` (the real counterpart of `TDuality.thetaShift_isODD`). -/
theorem thetaShiftR_preserves_eta (Θ : Matrix (Fin d) (Fin d) ℝ) (hΘ : Θᵀ = -Θ) :
    (thetaShiftR Θ)ᵀ * etaR d * thetaShiftR Θ = etaR d := by
  unfold thetaShiftR etaR
  rw [fromBlocks_transpose, fromBlocks_multiply, fromBlocks_multiply, Matrix.transpose_one,
    Matrix.transpose_zero, hΘ]
  simp

/-- Shifting by `Θ` and then by `-Θ` returns the original background. -/
theorem genMetric_bshift_cancel (G B Θ : Matrix (Fin d) (Fin d) ℝ) :
    genMetric G (B + Θ + -Θ) = genMetric G B := by
  simp [genMetric, Matrix.mul_add, Matrix.add_mul, Matrix.mul_assoc]
  <;>
    abel
  <;>
    simp_all [Matrix.mul_assoc]
  <;>
    abel
  <;>
    simp_all [Matrix.mul_assoc]
  <;>
    abel

end DualScaleStream2.DFT
