/-
Stream 2 · P2.5 — Why the flux contribution to the K3 × K3 tadpole is an integer.

Source (Tier L): Dasgupta, Rajesh, Sethi, hep-th/9908088
(`papers/foundations/dasgupta_rajesh_sethi_hep-th_9908088.txt`, lines 230–232): "Dirac
quantization requires that the cohomology class [G/π] be an element of H^(2,2)(M, ZZ). If
χ/24 ∈ ZZ then [G/2π] is an integer cohomology class." With Künneth (Tier L),
`H²(K3) ⊗ H²(K3) ⊂ H⁴(K3 × K3)` and the intersection form on it is the Kronecker product of
the two K3 forms.

Tier A here: the Kronecker product of an **even** symmetric integer form with **any**
symmetric integer form is even. Since the K3 lattice is even (its summands `U` and `E8(−1)`
are proved even in `Lattice.Hyperbolic` / `Lattice.E8`), every flux
`G ∈ H²(K3) ⊗ H²(K3)` has even self-intersection, so `½ ∫ G ∧ G ∈ ℤ` — the flux term in
the tadpole condition `½∫G∧G + n = 24` (`Flux.Tadpole`) is an integer.
-/
import DualScaleStream2.Lattice.Basic
import Mathlib.LinearAlgebra.Matrix.Kronecker

namespace DualScaleStream2.Flux

open Matrix DualScaleStream2.Lattice

variable {n m : ℕ}

/-- Kronecker product of two integer forms, on `Fin n × Fin m`. -/
def kronForm (L₁ : Gram n) (L₂ : Gram m) : Matrix (Fin n × Fin m) (Fin n × Fin m) ℤ :=
  kroneckerMap (· * ·) L₁ L₂

theorem kronForm_symm (L₁ : Gram n) (L₂ : Gram m) (h₁ : L₁ᵀ = L₁) (h₂ : L₂ᵀ = L₂) :
    (kronForm L₁ L₂)ᵀ = kronForm L₁ L₂ := by
  unfold kronForm
  rw [← Matrix.kroneckerMap_transpose, h₁, h₂]

theorem kronForm_evenDiag (L₁ : Gram n) (L₂ : Gram m) (h₁ : IsEvenDiag L₁) :
    ∀ p, Even (kronForm L₁ L₂ p p) := by
  intro p
  obtain ⟨i, j⟩ := p
  unfold kronForm
  rw [Matrix.kroneckerMap_apply]
  exact (h₁ i).mul_right _

/-- **Flux self-intersection is even.** -/
theorem kronForm_even (L₁ : Gram n) (L₂ : Gram m) (h₁s : L₁ᵀ = L₁) (h₂s : L₂ᵀ = L₂)
    (h₁ : IsEvenDiag L₁) (x : Fin n × Fin m → ℤ) :
    Even (x ⬝ᵥ (kronForm L₁ L₂ *ᵥ x)) := by
  set e : Fin n × Fin m ≃ Fin (n * m) := finProdFinEquiv with he
  set M : Gram (n * m) := (kronForm L₁ L₂).submatrix e.symm e.symm with hM
  have hsymm : Mᵀ = M := by
    rw [hM, Matrix.transpose_submatrix, kronForm_symm L₁ L₂ h₁s h₂s]
  have heven : IsEvenDiag M := by
    intro i
    rw [hM, Matrix.submatrix_apply]
    exact kronForm_evenDiag L₁ L₂ h₁ _
  have hxe : (x ∘ e.symm) ∘ (e.symm).symm = x := by
    funext i; simp
  have hMv : M *ᵥ (x ∘ e.symm) = (kronForm L₁ L₂ *ᵥ x) ∘ e.symm := by
    rw [hM, Matrix.submatrix_mulVec_equiv, hxe]
  have key := even_quadratic_form_of_even_diag M hsymm heven (x ∘ e.symm)
  rwa [hMv, comp_equiv_dotProduct_comp_equiv] at key

/-- Hence the flux contribution `½ ∫ G ∧ G` is an integer. -/
theorem flux_half_selfIntersection_integral (L₁ : Gram n) (L₂ : Gram m) (h₁s : L₁ᵀ = L₁)
    (h₂s : L₂ᵀ = L₂) (h₁ : IsEvenDiag L₁) (x : Fin n × Fin m → ℤ) :
    ∃ k : ℤ, x ⬝ᵥ (kronForm L₁ L₂ *ᵥ x) = 2 * k := by
  obtain ⟨r, hr⟩ := kronForm_even L₁ L₂ h₁s h₂s h₁ x
  exact ⟨r, by rw [hr]; ring⟩

end DualScaleStream2.Flux
