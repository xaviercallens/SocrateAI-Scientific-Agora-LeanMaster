/-
Stream 2 · Lattice foundations for K3 × T² compactification.

Epistemic tiers (project convention): **A** = Lean-kernel-checked here; **L** = quoted
from literature, not re-derived; **C** = this project's conjecture.

This file carries only Tier A content: definitions, and two general lemmas that
every later lattice statement in Stream 2 reduces to.

## Physical background

The charge lattices that appear throughout string compactification — the
momentum/winding lattice of a compact boson, the K3 intersection lattice, the Mukai
lattice — are not arbitrary integral bilinear forms: consistency of the worldsheet CFT
forces them to be *even* (every vector has even self-intersection) and *unimodular*
(self-dual, Gram determinant `±1`). Giveon–Porrati–Rabinovici state this for the general
`(d,d)` Narain lattice of momenta/windings: "The `(d,d)` Lorentzian momenta ... form an
even self-dual Lorentzian lattice ..., namely, the Lorentzian length is even ... and the
Lorentzian lattice is self-dual" (`papers/foundations/giveon_hep-th_9401139.txt`, GPR,
lines 1249–1258). This file formalizes exactly those two conditions, `IsEvenDiag` and
`IsUnimodular`, and the two general lemmas every later "this specific lattice is even /
unimodular" claim in Stream 2 (`E8.lean`, `Hyperbolic.lean`, `Mukai.lean`, and the `Flux`
module) reduces to. Nothing here is specific to K3, T², or any one physical system — this
file is pure integral quadratic-form bookkeeping, applicable wherever such a lattice
shows up.

## Mathematical content

`Gram n` is a rank-`n` integral bilinear form, presented as its `n × n` Gram matrix in a
fixed basis (so "the lattice" and "its Gram matrix" are identified throughout; no
separate ℤ-module or abstract lattice type is introduced). `IsEvenDiag G` says every
diagonal entry `G i i` is even; this is necessary, but not by itself sufficient, for the
associated quadratic form `x ↦ xᵀGx` to take only even values on *all* integer vectors
`x` — that upgrade is exactly `even_quadratic_form_of_even_diag`, which additionally needs
`G` symmetric. `IsUnimodular G` says `det G = ±1`. `isUnimodular_of_mul_eq_one` shows that
any checked integer left inverse of `G` proves unimodularity, via multiplicativity of the
determinant over `ℤ`; this is how every unimodularity claim downstream is actually
discharged (an inverse the kernel checks), never by asserting a determinant value outright.

**Not proved here** (and not needed for Stream 2's purposes): the converse direction of
`even_quadratic_form_of_even_diag` (that an everywhere-even quadratic form forces an even
diagonal — true, by taking `x` to be a standard basis vector, but not stated); anything
about lattice isomorphism, genus, or classification; and no claim that `Gram n` faithfully
models a physical charge space beyond providing its bilinear form — the physical
identification (momentum/winding lattice, K3 lattice, ...) is supplied file by file below.

## Proof techniques

`isUnimodular_of_mul_eq_one` is pure algebra: `H * G = 1` gives `det G * det H = 1` in
`ℤ` (via `Matrix.det_mul` and commutativity), and `Int.eq_one_or_neg_one_of_mul_eq_one`
turns that into `det G = 1 ∨ det G = -1`. `even_quadratic_form_of_even_diag` splits the
symmetric matrix `G` as `D + U + Uᵀ` (diagonal, strict upper triangle, and its transpose,
which recovers the strict lower triangle using symmetry), so that
`xᵀGx = xᵀDx + 2·(xᵀUx)`: the diagonal part is even because each term is `G i i * x i ^ 2`
with `G i i` even, and the cross term is even because it is `2 ×` something.

## Related declarations

`Gram` and `IsEvenDiag` are the two largest hubs in the whole Stream 2 lattice/flux
codebase (atlas: used by 20 and 8 theorems respectively), reused verbatim — not
re-derived — in `DualScaleStream2.Flux` for the K3×T² flux lattice's own evenness claims
(`kronForm_even`, `kronForm_evenDiag`, `flux_half_selfIntersection_integral`): same
definitions, different Gram matrix, so those are genuine instances of this file's general
lemma, not independent re-proofs. `isUnimodular_of_mul_eq_one` is likewise instantiated,
never reproved, at four different Gram matrices later in this directory
(`cartanE8_unimodular`, `e8Neg_unimodular`, `hyperbolicU_unimodular`,
`hyperbolicUNeg_unimodular`).
-/
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Tactic

namespace DualScaleStream2.Lattice

open Matrix

/-- An integral lattice of rank `n`, presented by its Gram matrix in a chosen basis:
`G i j` is the bilinear-form pairing of basis vector `i` with basis vector `j`. Physically,
this is the matrix of pairwise inner products of the charge/momentum basis vectors of a
compactification lattice (a circle's momentum-winding lattice, the K3 intersection form,
...); the abstract ℤ-module is never introduced separately, only this matrix. -/
abbrev Gram (n : ℕ) := Matrix (Fin n) (Fin n) ℤ

/-- Even diagonal: every basis vector has even self-pairing `G i i = (eᵢ, eᵢ)`. For a
symmetric integral Gram matrix this is *necessary* for the lattice being *even* (every
vector, not just basis vectors, has even norm); the harder direction — that it is also
*sufficient* — is `even_quadratic_form_of_even_diag`. Physically, evenness of the charge
lattice is what worldsheet modular invariance requires (see "Physical background" above). -/
def IsEvenDiag {n : ℕ} (G : Gram n) : Prop := ∀ i, Even (G i i)

/-- Unimodular (self-dual): the Gram determinant is a unit of `ℤ`, i.e. `±1`. Physically,
this is the self-duality of the charge lattice under `Z ↦ Z*` (the lattice equals its own
dual under the pairing) — the other worldsheet-consistency condition alongside evenness. -/
def IsUnimodular {n : ℕ} (G : Gram n) : Prop := G.det = 1 ∨ G.det = -1

/-- **Certificate lemma (Tier A).** Exhibiting an *integer* left inverse proves
unimodularity: `det H · det G = 1` in `ℤ` forces `det G = ±1`. This is how every
unimodularity claim in Stream 2 is discharged — by a checked inverse, never by
asserting the determinant. Proof idea: determinants are multiplicative, so
`H * G = 1` forces `det G * det H = 1` in `ℤ`, and the only factorizations of `1` in `ℤ`
are `1·1` and `(-1)·(-1)`. -/
theorem isUnimodular_of_mul_eq_one {n : ℕ} (G H : Gram n) (h : H * G = 1) :
    IsUnimodular G := by
  unfold IsUnimodular
  -- `det` is multiplicative and `H * G = 1`, so `det G * det H = det 1 = 1` in `ℤ`.
  have h_det : G.det * H.det = 1 := by
    rw [mul_comm, ← Matrix.det_mul, h]
    exact Matrix.det_one
  -- the only integer factorizations of `1` are `1 * 1` and `(-1) * (-1)`.
  exact Int.eq_one_or_neg_one_of_mul_eq_one h_det

/-- **Evenness from the diagonal (Tier A).** For symmetric `G` with even diagonal,
`xᵀ G x` is even for every integer vector `x`: the off-diagonal terms come in
equal pairs `Gᵢⱼ xᵢ xⱼ + Gⱼᵢ xⱼ xᵢ`. Physical reading: if a lattice's basis vectors all
have even self-pairing (its Gram diagonal is even), then *every* charge vector, not just
basis vectors, has even norm — the full "even lattice" condition needed for worldsheet
modular invariance. Proof idea: split `G` into its diagonal part `D` and strictly
upper/lower triangular parts `U, Uᵀ`; the diagonal contributes `xᵀDx = Σᵢ G i i · xᵢ²`,
manifestly even since each `G i i` is; the off-diagonal part contributes `2·(xᵀUx)`,
even because it is twice something. -/
theorem even_quadratic_form_of_even_diag {n : ℕ} (G : Gram n) (hsymm : Gᵀ = G)
    (heven : IsEvenDiag G) (x : Fin n → ℤ) : Even (x ⬝ᵥ (G *ᵥ x)) := by
  classical
  -- `D` = diagonal part of `G`; `U` = strict upper triangle; symmetry (`hsymm`) makes
  -- the strict lower triangle exactly `Uᵀ`, so `G = D + U + Uᵀ` accounts for every entry.
  let D : Gram n := Matrix.diagonal (fun i => G i i)
  let U : Gram n := fun i j => if i < j then G i j else 0
  have hGDU : G = D + U + Uᵀ := by
    ext i j
    simp only [Matrix.add_apply, Matrix.transpose_apply]
    show G i j = Matrix.diagonal (fun i => G i i) i j + (if i < j then G i j else 0)
        + (if j < i then G j i else 0)
    -- case on how `i`, `j` compare: on the diagonal, above it, or below it (where
    -- symmetry `hsymm` is what lets us read `G j i` off of `G i j`).
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
  -- the quadratic form doesn't see the difference between `U` and `Uᵀ` (it's the same
  -- bilinear pairing read from either side), so the two off-diagonal contributions
  -- combine into a single factor of `2`, not into two independent pieces.
  have hUt : x ⬝ᵥ (Uᵀ *ᵥ x) = x ⬝ᵥ (U *ᵥ x) := by
    rw [Matrix.mulVec_transpose, dotProduct_comm, ← Matrix.dotProduct_mulVec]
  -- assemble: `xᵀGx = xᵀDx + 2·(xᵀUx)`, using the decomposition `hGDU` and `hUt`.
  have key : x ⬝ᵥ (G *ᵥ x) = x ⬝ᵥ (D *ᵥ x) + 2 * (x ⬝ᵥ (U *ᵥ x)) := by
    conv_lhs => rw [hGDU]
    rw [Matrix.add_mulVec, Matrix.add_mulVec, dotProduct_add, dotProduct_add, hUt]
    ring
  rw [key]
  -- the diagonal contribution `xᵀDx = Σᵢ G i i · xᵢ²` is a sum of terms each even by
  -- hypothesis (`heven i` says `G i i` is even, hence so is `G i i * xᵢ²`).
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
  -- even (diagonal part) + even (twice the off-diagonal part) = even.
  exact hD_even.add (even_two_mul _)

end DualScaleStream2.Lattice
