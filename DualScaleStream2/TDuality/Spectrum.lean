/-
Stream 2 · P2.2b — T-dual backgrounds have identical perturbative spectra.

Source (Tier L, for the physical statement): Giveon, Porrati, Rabinovici, hep-th/9401139,
§2.4 (`papers/foundations/giveon_hep-th_9401139.txt`): after eq. (2.4.29), "It can be shown
straightforwardly that this transformation leaves the partition function invariant"
(line 1417). Mass form from
Hull–Zwiebach eq. (2.17) (see `DFT.GeneralizedMetric`).

Tier A here, every `d`, lattice level:
* every `g ∈ O(d,d;ℤ)` is invertible over `ℤ`, with inverse `η gᵀ η`, itself in `O(d,d;ℤ)`;
* **spectrum equivalence**: for any background `H` and any `g ∈ O(d,d;ℤ)`, there is a
  bijection `e` of the integer charge lattice with
  `massForm (gᵀ H g) Z = massForm H (e Z)` and `chargeNorm (e Z) = chargeNorm Z` —
  i.e. the backgrounds `H` and `gᵀ H g` have the same set of (mass², level-matching)
  data, charge by charge.

Not claimed: invariance of the full partition function (oscillators, modular integrals).
-/
import DualScaleStream2.TDuality.Factorized
import DualScaleStream2.DFT.GeneralizedMetric

namespace DualScaleStream2.TDuality

open Matrix DualScaleStream2.DFT

variable {d : ℕ}

theorem isODD_left_inv (g : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g) :
    (eta d * gᵀ * eta d) * g = 1 := by
  rw [Matrix.mul_assoc, Matrix.mul_assoc]
  unfold IsODD at hg
  rw [← Matrix.mul_assoc gᵀ, hg, eta_mul_self]

theorem isODD_right_inv (g : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g) :
    g * (eta d * gᵀ * eta d) = 1 := by
  exact mul_eq_one_comm.mp (isODD_left_inv g hg)

/-- Helper: `η` is symmetric. -/
theorem eta_transpose : (eta d)ᵀ = eta d := by
  unfold eta
  rw [fromBlocks_transpose]
  simp

theorem isODD_inv_isODD (g : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g) :
    IsODD (eta d * gᵀ * eta d) := by
  have hr := isODD_right_inv g hg
  have ht : (eta d * gᵀ * eta d)ᵀ = eta d * g * eta d := by
    rw [Matrix.transpose_mul, Matrix.transpose_mul, Matrix.transpose_transpose, eta_transpose,
      Matrix.mul_assoc]
  unfold IsODD
  rw [ht, Matrix.mul_assoc (eta d * g) (eta d) (eta d), eta_mul_self, Matrix.mul_one,
    Matrix.mul_assoc (eta d) g (eta d * gᵀ * eta d), hr, Matrix.mul_one]

/-- Real image of an integer matrix. -/
noncomputable def toReal (g : Matrix (Charge d) (Charge d) ℤ) : Matrix (Charge d) (Charge d) ℝ :=
  g.map (Int.cast : ℤ → ℝ)

/-- **T-dual backgrounds have identical (mass², level) spectra.** -/
theorem spectrum_equivalence (g : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g)
    (H : Matrix (Charge d) (Charge d) ℝ) :
    ∃ e : (Charge d → ℤ) ≃ (Charge d → ℤ), ∀ Z : Charge d → ℤ,
      massForm ((toReal g)ᵀ * H * toReal g) (fun i => (Z i : ℝ)) =
        massForm H (fun i => (e Z i : ℝ)) ∧
      chargeNorm (e Z) = chargeNorm Z := by
  refine ⟨⟨fun Z => g *ᵥ Z, fun Z => (eta d * gᵀ * eta d) *ᵥ Z, ?_, ?_⟩, fun Z => ⟨?_, ?_⟩⟩
  · intro Z
    show (eta d * gᵀ * eta d) *ᵥ (g *ᵥ Z) = Z
    rw [Matrix.mulVec_mulVec, isODD_left_inv g hg, Matrix.one_mulVec]
  · intro Z
    show g *ᵥ ((eta d * gᵀ * eta d) *ᵥ Z) = Z
    rw [Matrix.mulVec_mulVec, isODD_right_inv g hg, Matrix.one_mulVec]
  · have hcast : toReal g *ᵥ (fun i => (Z i : ℝ)) = fun i => ((g *ᵥ Z) i : ℝ) := by
      funext i
      simp only [toReal, Matrix.mulVec, dotProduct, Matrix.map_apply]
      push_cast
      rfl
    show massForm ((toReal g)ᵀ * H * toReal g) (fun i => (Z i : ℝ)) =
      massForm H (fun i => ((g *ᵥ Z) i : ℝ))
    rw [← hcast]
    exact massForm_covariant (toReal g) H (fun i => (Z i : ℝ))
  · exact chargeNorm_invariant g hg Z

end DualScaleStream2.TDuality
