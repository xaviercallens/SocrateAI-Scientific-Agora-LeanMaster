/-
Stream 2 · P2.2 — Factorized T-dualities and the charge norm of `Γ^{d,d}`.

Source (Tier L): Giveon, Porrati, Rabinovici, hep-th/9401139, §2.4, eq. (2.4.29)
(`papers/foundations/giveon_hep-th_9401139.txt`, lines 1399–1422):
`g_{D_i} = [[I − e_i, e_i],[e_i, I − e_i]]`, "a generalization of the R → 1/R circle
duality in the X^i direction". Their statement that the Θ-shifts, basis changes and
factorized dualities *generate* `O(d,d,ℤ)` (line 1422) is Tier L and not proved here.

Tier A here, for every `d`:
* each factorized duality `D_k` lies in `O(d,d;ℤ)`, is an involution, and they commute;
* on `T²` the product `D₀ D₁` is the full duality `η` (swap all momenta and windings);
* the charge norm `Zᵀ η Z` equals `2 n·w`, is even (so `Γ^{d,d}` is an even lattice —
  generalizing Stream 1's rank-1 `NarainLattice.narain_form_even`), and is invariant
  under all of `O(d,d;ℤ)`.
-/
import DualScaleStream2.TDuality.ODD
import Mathlib.Data.Matrix.Basis

namespace DualScaleStream2.TDuality

open Matrix

variable {d : ℕ}

/-- `e_k`: the matrix unit at `(k,k)`. -/
def proj (k : Fin d) : Matrix (Fin d) (Fin d) ℤ := single k k 1

/-- Factorized duality `D_k` (GPR eq. (2.4.29)). -/
def factorized (k : Fin d) : Matrix (Charge d) (Charge d) ℤ :=
  fromBlocks (1 - proj k) (proj k) (proj k) (1 - proj k)

theorem proj_mul_self (k : Fin d) : proj k * proj k = proj k := by
  unfold proj
  simp [single_mul_single_same]

theorem proj_transpose (k : Fin d) : (proj k)ᵀ = proj k := by
  unfold proj
  exact transpose_single k k 1

/-- Helper: `proj k` and `proj l` commute (they are `0` unless `k = l`). -/
theorem proj_comm (k l : Fin d) : proj k * proj l = proj l * proj k := by
  unfold proj
  by_cases h : k = l
  · rw [h]
  · simp [single_mul_single_of_ne, h, Ne.symm h]

theorem factorized_mul_self (k : Fin d) : factorized k * factorized k = 1 := by
  have hp : proj k * proj k = proj k := proj_mul_self k
  unfold factorized
  rw [fromBlocks_multiply, ← fromBlocks_one, fromBlocks_inj]
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp only [sub_mul, mul_sub, one_mul, mul_one, hp] <;> abel

theorem factorized_isODD (k : Fin d) : IsODD (factorized k) := by
  have hp : proj k * proj k = proj k := proj_mul_self k
  have ht : (factorized k)ᵀ = factorized k := by
    unfold factorized
    rw [fromBlocks_transpose, transpose_sub, transpose_one, proj_transpose]
  unfold IsODD
  rw [ht]
  unfold factorized eta
  rw [fromBlocks_multiply, fromBlocks_multiply, fromBlocks_inj]
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp only [mul_zero, one_mul, mul_one, add_zero, zero_add, sub_mul, mul_sub, hp] <;>
      abel

theorem factorized_comm (k l : Fin d) :
    factorized k * factorized l = factorized l * factorized k := by
  have hkl : proj k * proj l = proj l * proj k := proj_comm k l
  unfold factorized
  rw [fromBlocks_multiply, fromBlocks_multiply, fromBlocks_inj]
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp only [sub_mul, mul_sub, one_mul, mul_one, hkl] <;> abel

/-- On `T²`, dualizing both circles is the full duality `η`. -/
theorem factorized_two : factorized (0 : Fin 2) * factorized 1 = eta 2 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- Charge norm `Zᵀ η Z` of a charge vector `Z = (n, w)`. -/
def chargeNorm (Z : Charge d → ℤ) : ℤ := Z ⬝ᵥ (eta d *ᵥ Z)

theorem chargeNorm_sumElim (n w : Fin d → ℤ) :
    chargeNorm (Sum.elim n w) = 2 * (n ⬝ᵥ w) := by
  unfold chargeNorm eta
  rw [fromBlocks_mulVec, Sum.elim_comp_inl, Sum.elim_comp_inr]
  simp only [Matrix.zero_mulVec, Matrix.one_mulVec, zero_add, add_zero]
  rw [sumElim_dotProduct_sumElim, dotProduct_comm w n]
  ring

/-- `Γ^{d,d}` is an even lattice. -/
theorem chargeNorm_even (Z : Charge d → ℤ) : Even (chargeNorm Z) := by
  let n := Z ∘ Sum.inl
  let w := Z ∘ Sum.inr
  have hz : Z = Sum.elim n w := by ext ⟨i⟩ <;> rfl
  rw [hz, chargeNorm_sumElim]
  use n ⬝ᵥ w
  ring

/-- The charge norm is `O(d,d;ℤ)`-invariant. -/
theorem chargeNorm_invariant (g : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g)
    (Z : Charge d → ℤ) : chargeNorm (g *ᵥ Z) = chargeNorm Z := by
  unfold chargeNorm
  unfold IsODD at hg
  rw [mulVec_mulVec, dotProduct_mulVec, vecMul_mulVec, ← mul_assoc, hg, dotProduct_mulVec]

end DualScaleStream2.TDuality
