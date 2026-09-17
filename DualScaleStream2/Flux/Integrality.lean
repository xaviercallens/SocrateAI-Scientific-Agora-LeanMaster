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

### Physical background
The M-theory flux `G` on `K3 × K3` (or the analogous flux in the type IIB / F-theory
picture on `K3 × T²`) must satisfy a Dirac-type quantization condition: its cohomology
class is only guaranteed integral, `[G/2π] ∈ H^{(2,2)}(M,ℤ)`, once `χ/24 ∈ ℤ`
(Dasgupta–Rajesh–Sethi, `papers/foundations/dasgupta_rajesh_sethi_hep-th_9908088.txt`,
lines 230–232). The tadpole-cancellation condition that counts D-branes against flux
(`Flux.Tadpole`) needs specifically that `½ ∫ G ∧ G` be an *integer*, not just that `G`'s
cohomology class is integral — and on a product of two K3 surfaces, `H²(K3)⊗H²(K3) ⊂
H⁴(K3×K3)` by Künneth, with the intersection form there the Kronecker (tensor) product of
the two copies of the K3 intersection form. This file isolates the purely lattice-theoretic
reason `½ ∫ G∧G` comes out integral: the K3 intersection form is *even* (every vector has
even self-intersection), and evenness of one Kronecker factor is already enough.

### Mathematical content
Defines `kronForm L₁ L₂`, the Kronecker product of two integer Gram matrices, as a form on
`Fin n × Fin m`. Proves `kronForm_symm` (the Kronecker product of symmetric forms is
symmetric); `kronForm_evenDiag` (if `L₁` has even diagonal, so does `kronForm L₁ L₂`, for
*any* symmetric `L₂` — no evenness hypothesis on `L₂` is needed); `kronForm_even`, the
genuinely nontrivial step, that even-diagonal-plus-symmetric already implies the *whole*
quadratic form `x ⬝ᵥ (kronForm L₁ L₂ *ᵥ x)` is even for every integer vector `x`, not merely
on basis vectors; and `flux_half_selfIntersection_integral`, repackaging that evenness as
`∃ k, x ⬝ᵥ (kronForm L₁ L₂ *ᵥ x) = 2k`, i.e. half the self-intersection is an integer.
**Not proved here**: that the K3 lattice itself is even (that is `Lattice.Hyperbolic`'s and
`Lattice.E8`'s job, cited but not re-derived); that flux actually lives in `H²(K3)⊗H²(K3)`
or that Künneth applies (both Tier L, DRS + standard Künneth); and nothing about which
particular flux configurations exist or solve the equations of motion.

### Proof techniques
`kronForm_even` is proved by transporting `Lattice.Basic.even_quadratic_form_of_even_diag`
(already proved for a single-indexed Gram matrix `Gram (n*m)`) along the canonical
bijection `finProdFinEquiv : Fin n × Fin m ≃ Fin (n*m)`: reindex `kronForm L₁ L₂` by that
equivalence into an ordinary `Gram (n*m)`, check it inherits symmetry and even-diagonal-ness,
apply the general lemma, then transport the resulting evenness statement back along the
equivalence using `Matrix.submatrix_mulVec_equiv` and dot-product invariance under
reindexing (`comp_equiv_dotProduct_comp_equiv`). This avoids re-proving evenness-implies-even-
quadratic-form for the two-index Kronecker case from scratch.

### Related declarations
The predicate `Lattice.IsEvenDiag` is a hub used by 8 theorems across the project (atlas):
this file's `kronForm_even`/`kronForm_evenDiag`/`flux_half_selfIntersection_integral` are
three of them, and `Lattice.cartanE8_evenDiag`/`Lattice.hyperbolicU_evenDiag` — the concrete
facts that `E8(−1)` and `U` are even, cited in the module comment above — are among the
others: those lemmas are exactly the intended instantiations of `L₁` (or `L₂`) when this
generic file is applied to the actual K3 lattice `U^{⊕3} ⊕ E8(−1)^{⊕2}`, a **same-object**
dependency rather than an independent fact. `Lattice.Basic.even_quadratic_form_of_even_diag`
is reused, not re-proved, as the proof-technique paragraph above describes.
-/
import DualScaleStream2.Lattice.Basic
import Mathlib.LinearAlgebra.Matrix.Kronecker

namespace DualScaleStream2.Flux

open Matrix DualScaleStream2.Lattice

variable {n m : ℕ}

/-- Kronecker product of two integer forms, on `Fin n × Fin m`. -/
def kronForm (L₁ : Gram n) (L₂ : Gram m) : Matrix (Fin n × Fin m) (Fin n × Fin m) ℤ :=
  kroneckerMap (· * ·) L₁ L₂

/-- The Kronecker product of two symmetric forms is symmetric: `(L₁ ⊗ L₂)ᵀ = L₁ᵀ ⊗ L₂ᵀ = L₁ ⊗
L₂`. Needed so that `kronForm L₁ L₂` is itself a valid (symmetric) Gram matrix, e.g. for the
intersection form on `H²(K3) ⊗ H²(K3)`. -/
theorem kronForm_symm (L₁ : Gram n) (L₂ : Gram m) (h₁ : L₁ᵀ = L₁) (h₂ : L₂ᵀ = L₂) :
    (kronForm L₁ L₂)ᵀ = kronForm L₁ L₂ := by
  unfold kronForm
  rw [← Matrix.kroneckerMap_transpose, h₁, h₂]

/-- Every diagonal entry of `kronForm L₁ L₂` is even whenever `L₁`'s diagonal is even —
`(L₁ ⊗ L₂)_{(i,j),(i,j)} = L₁_{ii} · L₂_{jj}`, a product with an even factor. Note that no
hypothesis on `L₂` is used: only one of the two Kronecker factors needs to be even. -/
theorem kronForm_evenDiag (L₁ : Gram n) (L₂ : Gram m) (h₁ : IsEvenDiag L₁) :
    ∀ p, Even (kronForm L₁ L₂ p p) := by
  intro p
  obtain ⟨i, j⟩ := p
  unfold kronForm
  rw [Matrix.kroneckerMap_apply]
  exact (h₁ i).mul_right _

/-- **Flux self-intersection is even.** For *every* integer vector `x` (not just a basis
vector), the quadratic form `x ⬝ᵥ (kronForm L₁ L₂ *ᵥ x)` built from the Kronecker product is
even, given only that `L₁`, `L₂` are symmetric and `L₁` has even diagonal. Physically: the
self-intersection number of any flux class `x ∈ H²(K3)⊗H²(K3)` is even. Proof idea: relabel
the two-index Kronecker product as an ordinary single-indexed Gram matrix via the bijection
`Fin n × Fin m ≃ Fin (n*m)`, so the general fact "even diagonal + symmetric ⟹ even quadratic
form" (`Lattice.Basic.even_quadratic_form_of_even_diag`) applies directly. -/
theorem kronForm_even (L₁ : Gram n) (L₂ : Gram m) (h₁s : L₁ᵀ = L₁) (h₂s : L₂ᵀ = L₂)
    (h₁ : IsEvenDiag L₁) (x : Fin n × Fin m → ℤ) :
    Even (x ⬝ᵥ (kronForm L₁ L₂ *ᵥ x)) := by
  -- reindex the two-index Kronecker form as a single-index Gram matrix M, via the
  -- canonical bijection `finProdFinEquiv`, so the general single-index lemma applies.
  set e : Fin n × Fin m ≃ Fin (n * m) := finProdFinEquiv with he
  set M : Gram (n * m) := (kronForm L₁ L₂).submatrix e.symm e.symm with hM
  -- M inherits symmetry and even-diagonal-ness from kronForm L₁ L₂, since relabeling
  -- indices does not change either property.
  have hsymm : Mᵀ = M := by
    rw [hM, Matrix.transpose_submatrix, kronForm_symm L₁ L₂ h₁s h₂s]
  have heven : IsEvenDiag M := by
    intro i
    rw [hM, Matrix.submatrix_apply]
    exact kronForm_evenDiag L₁ L₂ h₁ _
  -- reindexing x by e.symm and back is the identity; needed to line up M's mulVec
  -- with kronForm L₁ L₂'s mulVec after transporting through the equivalence.
  have hxe : (x ∘ e.symm) ∘ (e.symm).symm = x := by
    funext i; simp
  have hMv : M *ᵥ (x ∘ e.symm) = (kronForm L₁ L₂ *ᵥ x) ∘ e.symm := by
    rw [hM, Matrix.submatrix_mulVec_equiv, hxe]
  -- apply the general even-quadratic-form lemma to M and the reindexed vector,
  -- then transport the resulting evenness statement back to the original x via
  -- dot-product invariance under reindexing by an equivalence.
  have key := even_quadratic_form_of_even_diag M hsymm heven (x ∘ e.symm)
  rwa [hMv, comp_equiv_dotProduct_comp_equiv] at key

/-- Hence the flux contribution `½ ∫ G ∧ G` is an integer. -/
theorem flux_half_selfIntersection_integral (L₁ : Gram n) (L₂ : Gram m) (h₁s : L₁ᵀ = L₁)
    (h₂s : L₂ᵀ = L₂) (h₁ : IsEvenDiag L₁) (x : Fin n × Fin m → ℤ) :
    ∃ k : ℤ, x ⬝ᵥ (kronForm L₁ L₂ *ᵥ x) = 2 * k := by
  obtain ⟨r, hr⟩ := kronForm_even L₁ L₂ h₁s h₂s h₁ x
  exact ⟨r, by rw [hr]; ring⟩

end DualScaleStream2.Flux
