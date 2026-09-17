/-
Stream 2 · P2.3 — The Mukai pairing.

Source (Tier L): Huybrechts, *Lectures on K3 Surfaces*, Ch. 9 "Vector bundles on K3
surfaces", §1, Definition 1.4 (`papers/foundations/huybrechts_K3Global.txt`, chapter heading
line 7352, definition lines 7475–7482):
"the Mukai pairing on H*(X, Z) is ⟨α, β⟩ = (α₂.β₂) − (α₀.β₄) − (α₄.β₀)", and eq. (1.4),
Hirzebruch–Riemann–Roch in the form `χ(E, F) = −⟨v(E), v(F)⟩`. The extended (Mukai)
lattice is `H²(X,ℤ) ⊕ U` (line 13268; cf. Aspinwall's `Γ⁴'²⁰ ⊃ Γ³'¹⁹` in
`K3T2Signature`).

Here a Mukai vector over a rank-`n` lattice `L` (Gram matrix of `H²`) is `(r, c, s)` with
`r ∈ H⁰`, `c ∈ H²`, `s ∈ H⁴`.

Tier A: symmetry of the pairing, the self-pairing formula `v² = c·c − 2rs`, evenness of
the Mukai lattice whenever `H²` is even (reusing `Basic.even_quadratic_form_of_even_diag`),
unimodularity of the `H⁰ ⊕ H⁴` summand `U(−1)`, and the Riemann–Roch arithmetic for
`v = (1, 0, 1)` giving `χ = 2`.
Tier L: that `v(𝒪_X) = (1, 0, 1)` and that `χ(E,E) = −⟨v,v⟩`.
-/
import DualScaleStream2.Lattice.Basic

namespace DualScaleStream2.Lattice

open Matrix

/-- A Mukai vector `(r, c, s) ∈ H⁰ ⊕ H² ⊕ H⁴`. -/
structure MukaiVec (n : ℕ) where
  (r : ℤ)
  (c : Fin n → ℤ)
  (s : ℤ)

/-- Huybrechts Def. 1.4. -/
def mukaiPair {n : ℕ} (L : Gram n) (v w : MukaiVec n) : ℤ :=
  v.c ⬝ᵥ (L *ᵥ w.c) - v.r * w.s - v.s * w.r

theorem mukaiPair_symm {n : ℕ} (L : Gram n) (hL : Lᵀ = L) (v w : MukaiVec n) :
    mukaiPair L v w = mukaiPair L w v := by
  unfold mukaiPair
  have h1 : v.c ⬝ᵥ (L *ᵥ w.c) = w.c ⬝ᵥ (L *ᵥ v.c) := by
    have : v.c ⬝ᵥ (Lᵀ *ᵥ w.c) = w.c ⬝ᵥ (L *ᵥ v.c) :=
      Matrix.dotProduct_transpose_mulVec L v.c w.c
    rwa [hL] at this
  ring_nf
  rw [h1]
  ring

theorem mukaiPair_self {n : ℕ} (L : Gram n) (v : MukaiVec n) :
    mukaiPair L v v = v.c ⬝ᵥ (L *ᵥ v.c) - 2 * v.r * v.s := by
  simp [mukaiPair, Matrix.mul_apply, Finset.sum_sub_distrib, Finset.sum_add_distrib]
  <;> ring
  <;> simp_all [Matrix.mul_apply, Finset.sum_sub_distrib, Finset.sum_add_distrib]
  <;> linarith

/-- The Mukai lattice is even whenever `H²` is. -/
theorem mukaiPair_even {n : ℕ} (L : Gram n) (hL : Lᵀ = L) (heven : IsEvenDiag L)
    (v : MukaiVec n) : Even (mukaiPair L v v) := by
  rw [mukaiPair_self]
  have h1 : Even (v.c ⬝ᵥ (L *ᵥ v.c)) := even_quadratic_form_of_even_diag L hL heven v.c
  have h2 : Even (2 * v.r * v.s) := by
    show Even ((2 : ℤ) * v.r * v.s)
    have : Even (2 * (v.r * v.s)) := even_two_mul (v.r * v.s)
    convert this using 1
    ring
  exact Even.sub h1 h2

/-- The `H⁰ ⊕ H⁴` summand: `U(−1)`. -/
def hyperbolicUNeg : Gram 2 := !![0, -1; -1, 0]

theorem hyperbolicUNeg_mul_self : hyperbolicUNeg * hyperbolicUNeg = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [hyperbolicUNeg, Matrix.mul_apply, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;> rfl

theorem hyperbolicUNeg_unimodular : IsUnimodular hyperbolicUNeg :=
  isUnimodular_of_mul_eq_one _ _ hyperbolicUNeg_mul_self

/-- `v = (1, 0, 1)` (Tier L: the Mukai vector of `𝒪_X`) has `v² = −2`, so Riemann–Roch
    `χ = −⟨v,v⟩` gives `χ(𝒪_X, 𝒪_X) = 2`. -/
theorem structureSheaf_mukai_sq {n : ℕ} (L : Gram n) :
    mukaiPair L ⟨1, 0, 1⟩ ⟨1, 0, 1⟩ = -2 := by
  simp [mukaiPair, Matrix.mul_apply, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;> norm_num
  <;> rfl

end DualScaleStream2.Lattice
