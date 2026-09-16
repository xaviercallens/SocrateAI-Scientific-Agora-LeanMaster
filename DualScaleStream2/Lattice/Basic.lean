/-
Stream 2 · Lattice foundations for K3 × T² compactification.

Epistemic tiers (project convention): **A** = Lean-kernel-checked here; **L** = quoted
from literature, not re-derived; **C** = this project's conjecture.

This file carries only Tier A content: definitions, and two general lemmas that
every later lattice statement in Stream 2 reduces to.
-/
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Tactic

namespace DualScaleStream2.Lattice

open Matrix

/-- An integral lattice of rank `n`, presented by its Gram matrix in a chosen basis. -/
abbrev Gram (n : ℕ) := Matrix (Fin n) (Fin n) ℤ

/-- Even diagonal. For a symmetric integral Gram matrix this is equivalent to the
lattice being *even* (every vector has even norm) — see
`even_quadratic_form_of_even_diag`. -/
def IsEvenDiag {n : ℕ} (G : Gram n) : Prop := ∀ i, Even (G i i)

/-- Unimodular (self-dual): Gram determinant is a unit of `ℤ`. -/
def IsUnimodular {n : ℕ} (G : Gram n) : Prop := G.det = 1 ∨ G.det = -1

/-- **Certificate lemma (Tier A).** Exhibiting an *integer* left inverse proves
unimodularity: `det H · det G = 1` in `ℤ` forces `det G = ±1`. This is how every
unimodularity claim in Stream 2 is discharged — by a checked inverse, never by
asserting the determinant. -/
theorem isUnimodular_of_mul_eq_one {n : ℕ} (G H : Gram n) (h : H * G = 1) :
    IsUnimodular G := by
  unfold IsUnimodular
  have h_det : G.det * H.det = 1 := by
    rw [mul_comm, ← Matrix.det_mul, h]
    exact Matrix.det_one
  exact Int.eq_one_or_neg_one_of_mul_eq_one h_det

/-- **Evenness from the diagonal (Tier A).** For symmetric `G` with even diagonal,
`xᵀ G x` is even for every integer vector `x`: the off-diagonal terms come in
equal pairs `Gᵢⱼ xᵢ xⱼ + Gⱼᵢ xⱼ xᵢ`. -/
theorem even_quadratic_form_of_even_diag {n : ℕ} (G : Gram n) (hsymm : Gᵀ = G)
    (heven : IsEvenDiag G) (x : Fin n → ℤ) : Even (x ⬝ᵥ (G *ᵥ x)) := by
  classical
  let D : Gram n := Matrix.diagonal (fun i => G i i)
  let U : Gram n := fun i j => if i < j then G i j else 0
  have hGDU : G = D + U + Uᵀ := by
    ext i j
    simp only [Matrix.add_apply, Matrix.transpose_apply]
    show G i j = Matrix.diagonal (fun i => G i i) i j + (if i < j then G i j else 0)
        + (if j < i then G j i else 0)
    rcases lt_trichotomy i j with h | h | h
    · rw [Matrix.diagonal_apply_ne _ (ne_of_lt h), if_pos h, if_neg (not_lt.mpr h.le)]
      ring
    · subst h
      rw [Matrix.diagonal_apply_eq, if_neg (lt_irrefl i)]
      ring
    · have hji : G j i = G i j := by
        have h' : Gᵀ i j = G i j := by rw [hsymm]
        rw [Matrix.transpose_apply] at h'
        exact h'
      rw [Matrix.diagonal_apply_ne _ (ne_of_lt h).symm, if_neg (not_lt.mpr h.le), if_pos h, hji]
      ring
  have hUt : x ⬝ᵥ (Uᵀ *ᵥ x) = x ⬝ᵥ (U *ᵥ x) := by
    rw [Matrix.mulVec_transpose, dotProduct_comm, ← Matrix.dotProduct_mulVec]
  have key : x ⬝ᵥ (G *ᵥ x) = x ⬝ᵥ (D *ᵥ x) + 2 * (x ⬝ᵥ (U *ᵥ x)) := by
    conv_lhs => rw [hGDU]
    rw [Matrix.add_mulVec, Matrix.add_mulVec, dotProduct_add, dotProduct_add, hUt]
    ring
  rw [key]
  have hD_even : Even (x ⬝ᵥ (D *ᵥ x)) := by
    rw [even_iff_two_dvd]
    have hsum : x ⬝ᵥ (D *ᵥ x) = ∑ i, G i i * (x i * x i) := by
      unfold dotProduct
      apply Finset.sum_congr rfl
      intro i _
      rw [Matrix.mulVec_diagonal]
      ring
    rw [hsum]
    apply Finset.dvd_sum
    intro i _
    exact (heven i).two_dvd.mul_right _
  exact hD_even.add (even_two_mul _)

end DualScaleStream2.Lattice
