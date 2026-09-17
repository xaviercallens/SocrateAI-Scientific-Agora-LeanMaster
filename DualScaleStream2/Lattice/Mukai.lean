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

## Physical background

A sheaf `E` on a K3 surface `X` has a Mukai vector `v(E) = ch(E)·√(td X) = (rk E, c₁(E),
ch₂(E) + rk E)` (Huybrechts, Def. 1.2, `papers/foundations/huybrechts_K3Global.txt`, line
7461), an element of the extended cohomology `H⁰ ⊕ H² ⊕ H⁴`. The point of the Mukai
*pairing* on this extended space is that Hirzebruch–Riemann–Roch, which ordinarily needs a
Todd-class correction, is exactly `χ(E,F) = −⟨v(E),v(F)⟩` (Def. 1.4 and eq. (1.4), lines
7475–7482): all the correction terms are absorbed by pairing on `H⁰⊕H²⊕H⁴` with a form
that differs from the naive intersection form only by a sign on the `H⁰⊕H⁴` part — "the
Mukai pairing differs from the intersection form only by a sign in the pairing on
`H⁰ ⊕ H⁴`" (lines 7479–7481). That sign flip is exactly why `hyperbolicUNeg =
!![0,-1;-1,0]` appears below rather than `hyperbolicU`. Moduli of sheaves with fixed
Mukai vector `v` (and `v² = −2`, `E` simple) are the natural deformation spaces studied via
this pairing: "`χ(E,E) = 2 − dim Ext¹(E,E) ≤ 2` and hence `⟨v(E),v(E)⟩ ≥ −2`" (same
chapter, lines 7486–7489).

## Mathematical content

`MukaiVec n` packages `(r, c, s)` with `r s : ℤ` and `c : Fin n → ℤ`. `mukaiPair L v w =
c_v · (L c_w) − r_v s_w − s_v r_w` is Huybrechts's Def. 1.4 written out for this
coordinate presentation. `mukaiPair_symm` proves the pairing is symmetric whenever `L`
is; `mukaiPair_self` specializes it to `v² = c·(Lc) − 2rs`; `mukaiPair_even` shows this
self-pairing is even whenever `L` is even (reusing `Basic.even_quadratic_form_of_even_diag`
for the `c·(Lc)` term and `even_two_mul` for the `2rs` term — no new evenness argument is
introduced here). `hyperbolicUNeg = !![0,-1;-1,0]` is the Gram matrix of the `H⁰⊕H⁴`
summand under the sign-flipped pairing; `hyperbolicUNeg_mul_self`/`hyperbolicUNeg_unimodular`
certify it exactly as `Hyperbolic.hyperbolicU_mul_self`/`hyperbolicU_unimodular` do for the
un-flipped `U`. `structureSheaf_mukai_sq` computes `⟨(1,0,1),(1,0,1)⟩ = −2` for *any*
ambient lattice `L` (the `H²`-component `c` is `0`, so `L` never enters the computation) —
combined with the Tier L identities `v(𝒪_X) = (1,0,1)` and `χ = −⟨v,v⟩`, this reproduces
the textbook fact `χ(𝒪_X,𝒪_X) = 2`.

**Not proved here**: that `mukaiPair` really computes Hirzebruch–Riemann–Roch's `χ(E,F)`
for actual sheaves (that identification, and `v(𝒪_X) = (1,0,1)`, are Tier L, quoted from
Huybrechts); nothing about moduli spaces of sheaves, stability, or the deformation theory
that Mukai vectors are used for in the source; and `structureSheaf_mukai_sq`'s independence
from `L` is a feature of the *specific* vector `(1,0,1)` (zero `H²`-component), not a
general fact about `mukaiPair`.

## Proof techniques

`mukaiPair_symm` reduces to `Matrix.dotProduct_transpose_mulVec` plus the hypothesis
`Lᵀ = L`, then closes the remaining integer rearrangement with `ring`. `mukaiPair_self`
and `structureSheaf_mukai_sq` are `simp`-then-`ring`/`norm_num` normalizations of the
definition once the `Finset.sum` over `Fin n` is unfolded via `Matrix.mul_apply`.
`mukaiPair_even` is a direct combination of two already-proved even facts (`Basic.
even_quadratic_form_of_even_diag` and `even_two_mul`) via `Even.sub`, not a new evenness
argument. `hyperbolicUNeg_mul_self` is the same `fin_cases`-brute-force recipe as
`Hyperbolic.hyperbolicU_mul_self`, on the sign-flipped matrix.

## Related declarations

`mukaiPair`, `MukaiVec.r/c/s` are atlas hubs local to this file (4 dependent theorems
each). `mukaiPair_self` has a notable dependency intersection (dep-Jaccard 0.684, cosine
0.0 — shared machinery, not shared statement) with `StringTheory.UseCases.NarainLattice.
B_is_polarization_of_Q`: both manipulate a bilinear form built from a quadratic form via
`Finset.sum`/`ring`, but one is Mukai self-pairing and the other is the Narain
polarization identity — unrelated content. `hyperbolicUNeg_mul_self`/`_unimodular` are the
direct sign-flipped analogues of `Hyperbolic.hyperbolicU_mul_self`/`_unimodular` (dep-
Jaccard 0.85, cosine 0.165 with the `U` versions in the atlas's "intersecting" list) — same
proof recipe, dual lattice (`U` vs `U(−1)`), reflecting the sign flip Huybrechts's Def. 1.4
introduces on `H⁰⊕H⁴`.
-/
import DualScaleStream2.Lattice.Basic

namespace DualScaleStream2.Lattice

open Matrix

/-- A Mukai vector `(r, c, s) ∈ H⁰ ⊕ H² ⊕ H⁴` (Huybrechts Def. 1.2): `r` the rank, `c`
the first Chern class (an `H²` vector in the ambient rank-`n` lattice), `s` the "reduced"
`H⁴`-component `ch₂(E) + rk(E)`. No relation to an actual coherent sheaf `E` is encoded in
this structure — it is bare data, matched to sheaves only by the Tier L identifications
quoted in the module docstring. -/
structure MukaiVec (n : ℕ) where
  (r : ℤ)
  (c : Fin n → ℤ)
  (s : ℤ)

/-- Huybrechts Def. 1.4: `⟨v,w⟩ = c_v·(L c_w) − r_v s_w − s_v r_w`, the intersection
form on `H²` paired with a *sign-flipped* pairing of the `H⁰` and `H⁴` components. This
sign flip (relative to naively extending `L` block-diagonally) is what makes
Hirzebruch–Riemann–Roch take the clean form `χ(E,F) = −⟨v(E),v(F)⟩`. -/
def mukaiPair {n : ℕ} (L : Gram n) (v w : MukaiVec n) : ℤ :=
  v.c ⬝ᵥ (L *ᵥ w.c) - v.r * w.s - v.s * w.r

/-- The Mukai pairing is symmetric whenever the ambient `H²` form `L` is — as a bilinear
form representing an intersection pairing must be. Proof idea: the `H²` part is symmetric
because `Lᵀ = L` lets `Matrix.dotProduct_transpose_mulVec` swap `v.c` and `w.c`; the
`H⁰⊕H⁴` part is symmetric by inspection of the formula (`r_v s_w + s_v r_w` is already
symmetric in `v ↔ w`). -/
theorem mukaiPair_symm {n : ℕ} (L : Gram n) (hL : Lᵀ = L) (v w : MukaiVec n) :
    mukaiPair L v w = mukaiPair L w v := by
  unfold mukaiPair
  -- transpose-symmetry of `L` lets the `H²` dot product be read with `v`, `w` swapped.
  have h1 : v.c ⬝ᵥ (L *ᵥ w.c) = w.c ⬝ᵥ (L *ᵥ v.c) := by
    have : v.c ⬝ᵥ (Lᵀ *ᵥ w.c) = w.c ⬝ᵥ (L *ᵥ v.c) :=
      Matrix.dotProduct_transpose_mulVec L v.c w.c
    rwa [hL] at this
  ring_nf
  rw [h1]
  ring

/-- Self-pairing formula: `⟨v,v⟩ = c·(Lc) − 2rs` — the `H⁰⊕H⁴` cross term collapses to a
single `2rs` since `r_v s_v + s_v r_v = 2rs` when `v = w`. This is the quantity computed
by `mukaiPair_even` and `structureSheaf_mukai_sq` below. -/
theorem mukaiPair_self {n : ℕ} (L : Gram n) (v : MukaiVec n) :
    mukaiPair L v v = v.c ⬝ᵥ (L *ᵥ v.c) - 2 * v.r * v.s := by
  simp [mukaiPair, Matrix.mul_apply, Finset.sum_sub_distrib, Finset.sum_add_distrib]
  <;> ring
  <;> simp_all [Matrix.mul_apply, Finset.sum_sub_distrib, Finset.sum_add_distrib]
  <;> linarith

/-- The Mukai lattice is even whenever `H²` is: `⟨v,v⟩` splits (via `mukaiPair_self`)
into the `H²` quadratic form `c·(Lc)` — even by `Basic.even_quadratic_form_of_even_diag`
whenever `L` is symmetric with even diagonal — plus `2rs`, even because it is twice
something (`even_two_mul`); an even plus an even is even. -/
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

/-- The `H⁰ ⊕ H⁴` summand under the Mukai pairing: `U(−1)`, the hyperbolic plane `U`
with its form negated — exactly the "sign in the pairing on `H⁰ ⊕ H⁴`" Huybrechts's Def.
1.4 describes (module docstring). -/
def hyperbolicUNeg : Gram 2 := !![0, -1; -1, 0]

/-- `U(−1)` is its own inverse, `U(−1)² = 1` — the sign-flipped analogue of
`Hyperbolic.hyperbolicU_mul_self`, and the certificate `hyperbolicUNeg_unimodular` below
is built from. -/
theorem hyperbolicUNeg_mul_self : hyperbolicUNeg * hyperbolicUNeg = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [hyperbolicUNeg, Matrix.mul_apply, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;> rfl

/-- `U(−1)` is unimodular, via the checked self-inverse `hyperbolicUNeg_mul_self` and
the general certificate lemma `Basic.isUnimodular_of_mul_eq_one`. -/
theorem hyperbolicUNeg_unimodular : IsUnimodular hyperbolicUNeg :=
  isUnimodular_of_mul_eq_one _ _ hyperbolicUNeg_mul_self

/-- `v = (1, 0, 1)` (Tier L: the Mukai vector of `𝒪_X`) has `v² = −2`, so Riemann–Roch
    `χ = −⟨v,v⟩` gives `χ(𝒪_X, 𝒪_X) = 2`. This holds for *any* ambient lattice `L` because
    the `H²`-component of `(1,0,1)` is the zero vector, so `c·(Lc) = 0` regardless of `L` —
    the whole computation reduces to the `H⁰⊕H⁴` part, `−2·1·1 = −2`. -/
theorem structureSheaf_mukai_sq {n : ℕ} (L : Gram n) :
    mukaiPair L ⟨1, 0, 1⟩ ⟨1, 0, 1⟩ = -2 := by
  simp [mukaiPair, Matrix.mul_apply, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;> norm_num
  <;> rfl

end DualScaleStream2.Lattice
