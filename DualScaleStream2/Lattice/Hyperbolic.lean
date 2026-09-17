/-
Stream 2 · The hyperbolic plane `U`.

`U` is the rank-2 lattice with an isotropic basis `e, f`, `(e·f) = 1` — Huybrechts,
*Lectures on K3 Surfaces*, Ch. 1, proof of eq. (3.4) (Tier L definition source).

Tier A here: symmetric, even, unimodular; a rational congruence witness
`Pᵀ U P = diag(2, −2)`. That witness shows `U` has one positive and one negative
direction; the step "diagonal congruence determines the signature" is Sylvester's law
of inertia, which is **Tier L** (not re-proved here).

Cross-link to Stream 1: `U` *is* the Narain lattice `Γ¹'¹` already certified in
`StringTheoryFormalization.UseCases.NarainLattice` — proved equal below, so Stream 2
builds on that result instead of restating it.

## Physical background

`U` with Gram matrix `[[0,1],[1,0]]` is, in string-theory language, the charge lattice
of a single compact boson: a state has integer momentum `n` and winding `w`, and the
bilinear form pairing `(n,w)` against `(n',w')` is exactly `n w' + n' w` — the polarization
of the quadratic form `Q(n,w) = 2nw` used in Stream 1's `NarainLattice.lean`. T-duality
`R ↦ α′/R` exchanges momentum and winding, `n ↔ w` (GPR §2.2, eq. (2.2.11)–(2.2.12),
`papers/foundations/giveon_hep-th_9401139.txt`, lines 745–761): this is exactly the
symmetry `!![0,1;1,0]` already has under swapping its two basis vectors. That the resulting
lattice must be even and self-dual (unimodular) is not a bookkeeping convenience but a
consistency requirement of the worldsheet CFT: GPR states the general fact for the
`(d,d)` Narain lattice of `d` compact bosons — "The `(d,d)` Lorentzian momenta ... form an
even self-dual Lorentzian lattice ... namely, the Lorentzian length is even ... and the
Lorentzian lattice is self-dual" (same file, lines 1249–1258). `U` is the `d = 1` case of
that same statement, and three copies of `U` appear (Tier L, quoted below) inside
`H²(K3,ℤ)` for the same structural reason lattices of this shape recur throughout the
compactification.

## Mathematical content

`hyperbolicU : Gram 2` is the literal matrix `!![0,1;1,0]`, nothing more. Proved here,
all by direct computation on this one 2×2 integer matrix: it is symmetric
(`hyperbolicU_symm`); it has even diagonal (`hyperbolicU_evenDiag`, trivially — both
diagonal entries are `0`); it is its own inverse, `U·U = 1` (`hyperbolicU_mul_self`),
which is a coincidence of this specific matrix (not a fact about hyperbolic planes over
other rings) and immediately gives unimodularity via `Basic.isUnimodular_of_mul_eq_one`
(`hyperbolicU_unimodular`); and a rational congruence `Pᵀ U P = diag(2,−2)` witnessing
one positive and one negative real eigenvalue (`hyperbolicU_congruence`). Finally
`hyperbolicU_eq_narain_gram` identifies this matrix, entry by entry, with the Gram matrix
Stream 1 builds independently by polarizing `Q(n,w) = 2nw`.

**Not proved here**: that `hyperbolicU` is isomorphic, as an abstract ℤ-lattice with
bilinear form, to "the" hyperbolic plane in Huybrechts's sense (an isotropic basis with
`e·f = 1`) — that identification is asserted in the Tier L source, not re-derived from a
Lean definition of "isotropic basis"; the passage from the diagonal congruence witness to
"the signature of `U` is `(1,1)`" (Sylvester's law of inertia, Tier L); and nothing about
`U`'s role in Witt cancellation or the K3 period-domain Grassmannian (Aspinwall,
`papers/foundations/aspinwall_hep-th_9611137.txt`, lines 705–766, read for
`K3T2Signature.lean`).

## Proof techniques

Every theorem about `hyperbolicU` itself is decided by `fin_cases i <;> fin_cases j`
(there are only `2 × 2 = 4` matrix entries) followed by `simp`/`norm_num`/`rfl` to
evaluate both sides as concrete integers. This is a decision procedure that works
*because* the matrix is small and fully literal — it does not generalize to a rank-`n`
hyperbolic-plane family. `hyperbolicU_eq_narain_gram` uses the same enumeration, comparing
against Stream 1's `gram` after both definitions are unfolded.

## Related declarations

`hyperbolicU` is an atlas hub (7 dependent theorems, including `hyperbolicU_eq_narain_gram`
below and further uses in `Mukai.lean`/`K3T2Signature.lean` as one of the three `U`
summands). `hyperbolicU_symm` has very high dependency overlap with `E8.cartanE8_symm`
and `E8.e8Neg_symm` (dep-Jaccard ≈ 0.90–0.904, cosine ≈ 0.28) — same brute-force
transpose check, different literal matrix: shared *proof recipe*, not shared mathematical
content beyond "this literal symmetric matrix is its own transpose". `hyperbolicU_evenDiag`
instead shares both proof *and* statement shape with `cartanE8_evenDiag`/`e8Neg_evenDiag`
(dep-Jaccard 0.77/0.60, cosine 0.51/0.50 — markedly higher cosine): all three are the same
`IsEvenDiag` predicate, a genuine parallel instantiation of one definition across the
three Gram matrices making up `H²(K3,ℤ)`. `hyperbolicU_eq_narain_gram` is the one atlas
*cross-library bridge* out of this file, into
`StringTheoryFormalization.UseCases.NarainLattice.gram` — a genuine "same object, two
constructions" identification (Stream 1 builds it from the momentum/winding quadratic
form; Stream 2 posits it as a literal matrix), not merely shared machinery.
-/
import DualScaleStream2.Lattice.Basic
import StringTheoryFormalization.UseCases.NarainLattice

namespace DualScaleStream2.Lattice

open Matrix

/-- The hyperbolic plane `U`, as a Gram matrix: `!![0,1;1,0]`. In string-theory terms
this is the momentum/winding pairing `(n,w)·(n',w') = n w' + n' w` of one compact boson
(§"Physical background" above); as pure lattice theory it is the standard rank-2 lattice
with an isotropic basis `e, f` and `e·f = 1`. -/
def hyperbolicU : Gram 2 := !![0, 1; 1, 0]

/-- `U` is symmetric, i.e. its bilinear form is genuinely symmetric (`(v,w) = (w,v)`), as
a bilinear form / inner product must be. Proof: the four entries of `Uᵀ` and `U` agree by
direct inspection (`fin_cases` enumerates all `2 × 2` index pairs; each case is `rfl`). -/
theorem hyperbolicU_symm : hyperbolicUᵀ = hyperbolicU := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- `U` has even diagonal — both diagonal entries are `0`, the base case of the general
"even Gram diagonal ⇒ even quadratic form" fact (`Basic.even_quadratic_form_of_even_diag`).
Physically: momentum `n` alone (`w = 0`) or winding `w` alone (`n = 0`) always has norm
`Q(n,0) = Q(0,w) = 0`, which is (trivially) even. -/
theorem hyperbolicU_evenDiag : IsEvenDiag hyperbolicU := by
  intro i
  fin_cases i <;> simp [hyperbolicU]
  <;> rfl

/-- **`U` is its own inverse** as a matrix (`U² = 1`), a coincidence special to this
2×2 matrix, not a fact about hyperbolic planes in general. Combined with
`isUnimodular_of_mul_eq_one` (taking `H = U`) this is how `hyperbolicU_unimodular` below
gets its certificate. -/
theorem hyperbolicU_mul_self : hyperbolicU * hyperbolicU = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [hyperbolicU, Matrix.mul_apply, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;>
    norm_num
  <;> rfl

/-- `U` is unimodular (self-dual): immediate from `hyperbolicU_mul_self` via the general
certificate lemma `Basic.isUnimodular_of_mul_eq_one`, using `U` itself as its own
inverse. -/
theorem hyperbolicU_unimodular : IsUnimodular hyperbolicU :=
  isUnimodular_of_mul_eq_one _ _ hyperbolicU_mul_self

/-- **Congruence witness**: `Pᵀ U P = diag(2, −2)` with `P = [[1,1],[1,−1]]`. Over `ℝ`
(or `ℚ`) this exhibits one positive and one negative direction for the quadratic form of
`U`; concluding from it that "the signature of `U` is `(1,1)`" also invokes Sylvester's
law of inertia (uniqueness of the number of positive/negative diagonal entries under
congruence), which is Tier L — quoted, not proved in this file. -/
theorem hyperbolicU_congruence :
    (!![1, 1; 1, -1] : Gram 2)ᵀ * hyperbolicU * !![1, 1; 1, -1] = !![2, 0; 0, -2] := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [hyperbolicU, Matrix.mul_apply, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;>
    norm_num
  <;>
    rfl

/-- **Cross-link.** Stream 2's `U` is exactly Stream 1's Narain Gram matrix: two
independently written-down objects (this file's literal `!![0,1;1,0]` versus
`NarainLattice.gram`, built there by polarizing the momentum/winding quadratic form
`Q(n,w) = 2nw`) turn out to be the same matrix. Proof: unfold both sides to concrete
integers and check the four entries agree (`fin_cases` + `rfl`), exactly as in
`hyperbolicU_symm`. -/
theorem hyperbolicU_eq_narain_gram :
    hyperbolicU = StringTheory.UseCases.NarainLattice.gram := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

end DualScaleStream2.Lattice
