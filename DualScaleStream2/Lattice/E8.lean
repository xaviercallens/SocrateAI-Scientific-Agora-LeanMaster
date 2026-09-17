/-
Stream 2 · The E8 lattice and E8(−1).

Source (Tier L, for *why this lattice matters*): Huybrechts, *Lectures on K3 Surfaces*,
Ch. 1, eq. (3.4): `H²(X,ℤ) ≅ E8(−1) ⊕ E8(−1) ⊕ U ⊕ U ⊕ U`
(`papers/foundations/huybrechts_K3Global.txt`, line 603).

Tier A here: the Cartan matrix below is symmetric, has even diagonal, and is
unimodular — the last via an explicit integer inverse checked by the kernel, not by
quoting `det = 1`. The inverse was computed with sympy and is *not trusted*: if it
were wrong, `cartanE8Inv_mul` would fail to compile.

Dynkin labelling: chain `0—1—2—3—4—5—6`, extra node `7` attached to `4`
(arms of length 4, 2, 1 from the branch node: the `T₂,₃,₅` tree = E8).

## Physical background

`E8(−1)` is one of the two rank-8 negative-definite summands of `H²(K3,ℤ)` in the
decomposition `H²(X,ℤ) ≅ E8(−1)⊕2 ⊕ U⊕3` (Huybrechts, Ch. 1, eq. (3.4), line 603, read
for this file — the same pin `Hyperbolic.lean` reads for its `U` summands). Algebraically
it is fixed, among rank-8 lattices, by being the unique even unimodular *positive*-definite
one (with sign flipped here to negative-definite, matching the Lorentzian `(3,19)`
signature the full K3 lattice must have — `E8PosDef.lean` proves the positive-definiteness
of `cartanE8` that this characterization needs). This file does not construct any
geometric picture of how the `(−2)`-curve classes generating `E8(−1)` sit inside an actual
K3 surface (that would need a source beyond the ones read for this file) — it only
produces, and certifies, the integer Cartan matrix representing the abstract root lattice
`E8`, and its sign flip `E8(−1)`.

## Mathematical content

`cartanE8 : Gram 8` is the Cartan matrix of the `E8` root system in the Dynkin labelling
fixed above (diagonal `2`, off-diagonal `−1` exactly along the edges of that Dynkin
diagram, `0` elsewhere). `cartanE8Inv` is a claimed integer inverse, produced outside Lean
(by sympy) and used only as a certificate. `cartanE8Inv_mul` is the kernel check that this
candidate really is a two-sided inverse over `ℤ` (a left inverse of a square matrix over a
commutative ring is automatically two-sided, but the statement here is proved directly by
computation, not by that general fact). From it: `cartanE8_symm` (the matrix is symmetric,
as a Cartan matrix of a simply-laced root system must be), `cartanE8_evenDiag` (diagonal
entries are all `2`, hence even), and `cartanE8_unimodular` (via `Basic.
isUnimodular_of_mul_eq_one` applied to the checked inverse). `e8Neg := -cartanE8` is the
sign-flipped lattice, and `e8Neg_symm`/`e8Neg_evenDiag`/`e8Neg_unimodular` transfer the same
three properties to it by direct recomputation (not by a generic "negation preserves these
properties" lemma).

**Not proved here**: that `cartanE8` is positive definite as a real quadratic form (that is
`E8PosDef.lean`); that this specific 8×8 integer matrix is, up to lattice isomorphism, *the*
`E8` root lattice in the sense of Lie theory (asserted via the Dynkin-diagram description
above, not derived from a Lean definition of a root system); nothing about the `E8` Weyl
group beyond the 8 simple reflections treated in `Reflection.lean`; and no heterotic-string
or gauge-theory role for `E8` — this file's only certified physical role for `E8(−1)` is as
a summand of `H²(K3,ℤ)`.

## Proof techniques

Every theorem in this file is decided by brute enumeration: `fin_cases i <;> fin_cases j`
(64 cases for the `8 × 8` matrix identities `cartanE8Inv_mul`/`cartanE8_symm`/`e8Neg_symm`)
or `fin_cases i` (8 cases for the diagonal-only claims `cartanE8_evenDiag`/`e8Neg_evenDiag`),
each case closed by unfolding the literal matrix entries and `simp`/`decide`/`rfl`. This
works because every matrix here is a fully literal `!![...]` array of small integers — it
is a decision procedure, not an argument that would extend to a symbolic Cartan matrix.
`cartanE8_unimodular`/`e8Neg_unimodular` are the only non-brute-force steps: they invoke
the general certificate lemma `Basic.isUnimodular_of_mul_eq_one` rather than re-deriving
unimodularity from scratch.

## Related declarations

`cartanE8` is an atlas hub (7 dependent theorems, all in this file). `cartanE8_symm` and
`e8Neg_symm` have very high dependency overlap with `Hyperbolic.hyperbolicU_symm`
(dep-Jaccard ≈ 0.90, cosine ≈ 0.28–0.29): identical brute-force "this literal matrix equals
its own transpose" proof recipe, applied to a different Gram matrix — shared machinery, not
shared mathematical content. The same three symmetry theorems also intersect heavily
(dep-Jaccard ≈ 0.81–0.82, cosine ≈ 0.0) with `StringTheory.Frontier.k3_hodge_symmetry` and
`DualScaleStream2.TDuality.mirrorTheta_antisymm` — the zero cosine says these are
*textually* dissimilar statements (Hodge-diamond symmetry and an antisymmetry of a
mirror-map matrix, respectively) that merely lean on the same finite-case-split tactics,
not a mathematical relation to `E8`. `cartanE8Inv_mul` shares even more proof machinery
(dep-Jaccard 0.891, cosine 0.0) with `DualScaleStream2.TDuality.tauShift_dual_spec` — again
a shared certificate-by-computation style, not a shared statement. `cartanE8_evenDiag` and
`e8Neg_evenDiag` are genuine parallel instantiations of `Basic.IsEvenDiag` alongside
`Hyperbolic.hyperbolicU_evenDiag`, all three feeding the same `sigK3` bookkeeping in
`K3T2Signature.lean`.
-/
import DualScaleStream2.Lattice.Basic

namespace DualScaleStream2.Lattice

open Matrix

/-- The Cartan matrix of the root system `E8`, in the Dynkin labelling fixed in the
module docstring: `2` on the diagonal (each simple root has norm `2` before the sign
flip to `E8(−1)`), `−1` exactly where two nodes of the Dynkin diagram are joined by an
edge, `0` otherwise. Positive-definiteness of this matrix over `ℝ` is proved separately
in `E8PosDef.lean`, not here. -/
def cartanE8 : Gram 8 :=
  !![ 2, -1,  0,  0,  0,  0,  0,  0;
     -1,  2, -1,  0,  0,  0,  0,  0;
      0, -1,  2, -1,  0,  0,  0,  0;
      0,  0, -1,  2, -1,  0,  0,  0;
      0,  0,  0, -1,  2, -1,  0, -1;
      0,  0,  0,  0, -1,  2, -1,  0;
      0,  0,  0,  0,  0, -1,  2,  0;
      0,  0,  0,  0, -1,  0,  0,  2]

/-- Claimed integer inverse of `cartanE8` (certificate; checked by `cartanE8Inv_mul`).
Produced by an external computer-algebra computation (sympy) — this definition carries
no mathematical guarantee on its own; `cartanE8Inv_mul` is what the Lean kernel actually
verifies. -/
def cartanE8Inv : Gram 8 :=
  !![2,  3,  4,  5,  6,  4,  2,  3;
     3,  6,  8, 10, 12,  8,  4,  6;
     4,  8, 12, 15, 18, 12,  6,  9;
     5, 10, 15, 20, 24, 16,  8, 12;
     6, 12, 18, 24, 30, 20, 10, 15;
     4,  8, 12, 16, 20, 14,  7, 10;
     2,  4,  6,  8, 10,  7,  4,  5;
     3,  6,  9, 12, 15, 10,  5,  8]

/-- **The kernel-checked certificate.** `cartanE8Inv` really is a two-sided inverse of
`cartanE8` over `ℤ` — this is what upgrades the sympy-produced candidate from "claimed"
to "proved": if `cartanE8Inv` were wrong this `rfl`/`simp` computation would simply fail
to close, since both sides are fully literal `8 × 8` integer matrices. -/
theorem cartanE8Inv_mul : cartanE8Inv * cartanE8 = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [cartanE8, cartanE8Inv, Matrix.mul_apply, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;> rfl

/-- `cartanE8` is symmetric, `Gᵀ = G` — as any Cartan matrix of a simply-laced root
system must be. Proof: entrywise comparison of the two literal matrices. -/
theorem cartanE8_symm : cartanE8ᵀ = cartanE8 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- `cartanE8` has even diagonal: every simple root has norm `2`. This is the
`Basic.IsEvenDiag` hypothesis needed (together with symmetry) to conclude, via
`Basic.even_quadratic_form_of_even_diag`, that `E8` is an even lattice. -/
theorem cartanE8_evenDiag : IsEvenDiag cartanE8 := by
  intro i
  fin_cases i <;> simp [cartanE8]
  <;> decide
  <;> rfl

/-- **`E8` is unimodular (Tier A, via the checked inverse).** Physically, `E8` being
even and unimodular (jointly with `cartanE8_evenDiag`) is exactly the consistency
condition a summand of a worldsheet charge lattice must satisfy. Proof: the certified
inverse `cartanE8Inv` from `cartanE8Inv_mul`, fed into the general certificate lemma
`Basic.isUnimodular_of_mul_eq_one`. -/
theorem cartanE8_unimodular : IsUnimodular cartanE8 :=
  isUnimodular_of_mul_eq_one _ _ cartanE8Inv_mul

/-- `E8(−1)`: the same lattice with its bilinear form negated — the (negative-definite)
summand appearing twice in `H²(K3,ℤ) ≅ E8(−1)⊕2 ⊕ U⊕3` (Huybrechts, eq. (3.4), see the
module docstring). Negating the form does not change symmetry, evenness, or
unimodularity, but each of those is re-verified below by direct computation on `e8Neg`
rather than inferred from a general "negation preserves these" lemma. -/
def e8Neg : Gram 8 := -cartanE8

/-- `e8Neg` is symmetric (same content as `cartanE8_symm`, recomputed on the negated
matrix). -/
theorem e8Neg_symm : e8Negᵀ = e8Neg := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- `e8Neg` has even diagonal: each simple root now has norm `−2` (the standard
normalization for `(−2)`-curve classes used again in `Reflection.lean`). -/
theorem e8Neg_evenDiag : IsEvenDiag e8Neg := by
  intro i
  fin_cases i <;> simp [e8Neg, cartanE8, IsEvenDiag]
  <;> decide
  <;> rfl

/-- `E8(−1)` is unimodular. Proof: negating both `cartanE8` and its inverse
`cartanE8Inv` preserves the inverse relationship (`(-A)⁻¹ = -A⁻¹`), then apply the same
certificate lemma as `cartanE8_unimodular`. -/
theorem e8Neg_unimodular : IsUnimodular e8Neg := by
  unfold e8Neg
  have h_inv : (-cartanE8Inv) * (-cartanE8) = 1 := by
    simp only [neg_mul, mul_neg, neg_neg]
    exact cartanE8Inv_mul
  exact isUnimodular_of_mul_eq_one (-cartanE8) (-cartanE8Inv) h_inv

end DualScaleStream2.Lattice
