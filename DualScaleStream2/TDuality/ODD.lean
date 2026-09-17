/-
Stream 2 · The T-duality group `O(d,d;ℤ)` of a `d`-torus.

## Physical background
A closed string compactified on `d` circles carries `d` integer momentum numbers `n_i`
and `d` integer winding numbers `w_i`. T-duality and its close relatives (integer
`B`-field shifts, relabellings of the compactification lattice) act on the charge
vector `Z = (n, w)` while leaving the physical spectrum unchanged; the group of all
such symmetries is the integer orthogonal group `O(d,d;ℤ)`, "orthogonal" for the
momentum–winding pairing `η`. This file formalizes the two elementary families of
generators from Source (Tier L): Giveon, Porrati, Rabinovici, *Target Space Duality
in String Theory*, hep-th/9401139, §2.4 "O(d,d,Z) Duality for d-Dimensional Toroidal
Compactifications" (`papers/foundations/giveon_hep-th_9401139.txt`, lines 1355–1373):
the integer antisymmetric `Θ`-shift `g_Θ = [[I, Θ],[0, I]]` (eq. (2.4.25), an integer
`B`-field shift that changes the string action only by a multiple of `2π` and so is
invisible to the path integral) and the basis change `diag(A, (Aᵀ)⁻¹)`, `A ∈ GL(d,ℤ)`
(eq. (2.4.26), a relabelling of the compactification lattice). The third GPR generator,
factorized duality, is formalized separately in `Factorized.lean`.

## Mathematical content
Fixes the ambient data (charge index type, invariant form, membership predicate) used
by every file in this directory, and proves, for **every** `d` (not just the `d = 1, 2`
special cases that appear later in the directory):
* `thetaShift_isODD`: the `Θ`-shift preserves `η` whenever `Θ` is antisymmetric;
* `basisChange_isODD`: a basis change `diag(A, B)` preserves `η` whenever `Aᵀ B = 1`
  (so `B = (Aᵀ)⁻¹`, matching GPR's `gA`);
* `eta_mul_self`/`eta_isODD`: the full duality `n ↔ w` (i.e. `η` itself) preserves `η`
  and is its own inverse;
* `isODD_mul`: `O(d,d;ℤ)` (as a predicate on matrices) is closed under multiplication;
* `eta_one_reindex`: at `d = 1`, `η` is *literally* Stream 1's Narain Gram matrix,
  after reindexing `Charge 1 = Fin 1 ⊕ Fin 1` to `Fin 2`.

What is **not** proved: that `thetaShift`, `basisChange` and (from `Factorized.lean`)
`factorized` together generate all of `O(d,d;ℤ)` (Tier L, same reference, line 1422),
that these are group homomorphisms/a group structure is formalized anywhere, or
anything about the moduli-space quotient by this group.

## Proof techniques
Every proof here is a direct block-matrix computation: `unfold` the definitions down to
`Matrix.fromBlocks` expressions, apply Mathlib's `fromBlocks_transpose`/
`fromBlocks_multiply` to turn `2×2` block products into honest matrix arithmetic, and
close with `simp`/`ring`-style normalization on the four resulting blocks. Because `d`
stays an arbitrary free variable throughout, there is no case-splitting on indices
(`fin_cases`) anywhere in this file — that only becomes necessary once `d` is
specialized to a fixed small number in `Mirror.lean` and `SL2Product.lean`.

## Related declarations
* `DualScaleStream2.Lattice.hyperbolicU` (`Lattice/Hyperbolic.lean`) is, by
  `eta_one_reindex` composed with `Lattice.hyperbolicU_eq_narain_gram`, the same matrix
  as `eta 1`: `η` at `d = 1` and Stream 1's `StringTheory.UseCases.NarainLattice.gram`
  are one object reached by two independently-verified equalities, not merely analogous.
* `DoubleFieldTheory.GeneralizedGeometry.IsODD`/`ODD_Eta`/`odd_inversion_generator`
  (a different library) is an **independent re-proof** of exactly the `d = 1` special
  case of `IsODD`/`eta`/`eta_isODD` here, but coded against an ad-hoc `2×2` integer
  structure (`Mat2`) rather than Mathlib's general `Fin d ⊕ Fin d` block matrices — same
  mathematical object, a much narrower (fixed-size, hand-rolled-algebra) formalization.
* `DualScaleStream2.DFT.etaR`/`etaR_mul_self` and `DFT.BShift.thetaShiftR_preserves_eta`
  (`DFT/GeneralizedMetric.lean`, `DFT/BShift.lean`) restate `eta`/`thetaShift` and
  `eta_mul_self`/`thetaShift_isODD` verbatim over `ℝ` instead of `ℤ`, to phrase the
  Hull–Zwiebach generalized-metric `O(d,d)` constraint used by Stream 2's continuous DFT
  layer built on top of this discrete duality group.
-/
import DualScaleStream2.Lattice.Hyperbolic
import Mathlib.Data.Matrix.Block

namespace DualScaleStream2.TDuality

open Matrix

variable {d : ℕ}

/-- Charge-lattice index set: `d` momenta ⊕ `d` windings. As a Lean type this is
    `Fin d ⊕ Fin d`; physically it indexes the `2d` integers `(n_1,…,n_d,w_1,…,w_d)`
    labelling a state's momentum and winding around the `d` compactified circles. -/
abbrev Charge (d : ℕ) := Fin d ⊕ Fin d

/-- The `O(d,d)`-invariant form `η = [[0, I],[I, 0]]`. In coordinates,
    `⟨(n,w),(n',w')⟩_η = n·w' + n'·w`: the symmetric pairing that mixes momentum and
    winding. This is the bilinear form whose isometries are the T-duality group, and
    whose associated quadratic form `Z ⬝ (η Z)` is the charge norm computed in
    `Factorized.chargeNorm`. -/
def eta (d : ℕ) : Matrix (Charge d) (Charge d) ℤ := fromBlocks 0 1 1 0

/-- `g ∈ O(d,d;ℤ)`: the integer matrix `g` preserves the pairing `η`, i.e.
    `gᵀ η g = η`. Physically, this is exactly the condition for `g` to act on charge
    vectors as a symmetry of the string spectrum: it is the invariance of `η` under
    conjugation by `g` that later forces the charge norm and the mass spectrum to be
    unchanged after a duality transformation (see `Factorized.chargeNorm_invariant`
    and `Spectrum.spectrum_equivalence`). -/
def IsODD (g : Matrix (Charge d) (Charge d) ℤ) : Prop := gᵀ * eta d * g = eta d

/-- Θ-shift (Giveon–Porrati–Rabinovici eq. (2.4.25)): the block matrix
    `g_Θ = [[I, Θ],[0, I]]`. Physically, this is the integer shift `B ↦ B + Θ` of the
    Kalb–Ramond field by an antisymmetric integer matrix `Θ` — a symmetry because the
    constant `B`-term in the worldsheet action is a total derivative, so an integer
    shift changes the action by a multiple of `2π` and drops out of the path integral. -/
def thetaShift (Θ : Matrix (Fin d) (Fin d) ℤ) : Matrix (Charge d) (Charge d) ℤ :=
  fromBlocks 1 Θ 0 1

/-- Basis change of the compactification lattice, `diag(A, B)` (GPR eq. (2.4.26) with
    `B = (Aᵀ)⁻¹`). Physically, `A ∈ GL(d,ℤ)` relabels the `d` compact directions (e.g.
    permuting them, or any other unimodular change of basis of the lattice `Λ`); the
    contragredient action `B` on windings is forced by demanding `η`-invariance below. -/
def basisChange (A B : Matrix (Fin d) (Fin d) ℤ) : Matrix (Charge d) (Charge d) ℤ :=
  fromBlocks A 0 0 B

/-- The `Θ`-shift lies in `O(d,d;ℤ)` exactly when `Θ` is antisymmetric. Proof idea:
    expand `g_Θᵀ η g_Θ` blockwise; the antisymmetry `Θᵀ = -Θ` is precisely what is
    needed to cancel the off-diagonal `Θ + Θᵀ` term that would otherwise appear. -/
theorem thetaShift_isODD (Θ : Matrix (Fin d) (Fin d) ℤ) (hΘ : Θᵀ = -Θ) :
    IsODD (thetaShift Θ) := by
  unfold IsODD thetaShift eta
  -- turn the 2×2 block product gᵀ η g into ordinary matrix arithmetic on each block,
  -- then use antisymmetry (hΘ) to cancel the surviving Θ + Θᵀ term
  rw [fromBlocks_transpose, fromBlocks_multiply, fromBlocks_multiply, Matrix.transpose_one,
    Matrix.transpose_zero, hΘ]
  simp

/-- A basis change `diag(A,B)` lies in `O(d,d;ℤ)` exactly when `Aᵀ B = 1` (so
    `B = (Aᵀ)⁻¹` as in GPR's `gA`). Proof idea: `Aᵀ B = 1` also gives `Bᵀ A = 1` (take
    transposes), and both identities are exactly what makes the two off-diagonal blocks
    of `diag(A,B)ᵀ η diag(A,B)` reduce to the identity. -/
theorem basisChange_isODD (A B : Matrix (Fin d) (Fin d) ℤ) (h : Aᵀ * B = 1) :
    IsODD (basisChange A B) := by
  have h' : Bᵀ * A = 1 := by
    -- the mirror identity Bᵀ A = 1, obtained by transposing h : Aᵀ B = 1
    have hc := congrArg Matrix.transpose h
    simpa [Matrix.transpose_mul, Matrix.transpose_one, Matrix.transpose_transpose] using hc
  unfold IsODD basisChange eta
  -- expand the block product; h and h' close the two off-diagonal blocks to 1
  rw [fromBlocks_transpose, fromBlocks_multiply, fromBlocks_multiply, Matrix.transpose_zero]
  simp [h, h']

/-- **The full T-duality `n ↔ w` (i.e. `η` itself) is an involution**: swapping all
    momenta and windings twice returns the original charge. Proof idea: expand `η · η`
    blockwise (Mathlib's `fromBlocks_multiply`); each resulting block is a product of
    `0`s and `1`s that `simp` evaluates directly to the identity block matrix. -/
theorem eta_mul_self : eta d * eta d = 1 := by
  unfold eta
  -- rewrite the block product η·η as the explicit fromBlocks matrix of its four
  -- block-entries, so `simp` can finish by pure ring computation on 0s and 1s
  rw [show (fromBlocks (0 : Matrix (Fin d) (Fin d) ℤ) (1 : Matrix (Fin d) (Fin d) ℤ)
    (1 : Matrix (Fin d) (Fin d) ℤ) (0 : Matrix (Fin d) (Fin d) ℤ)) *
    (fromBlocks (0 : Matrix (Fin d) (Fin d) ℤ) (1 : Matrix (Fin d) (Fin d) ℤ)
    (1 : Matrix (Fin d) (Fin d) ℤ) (0 : Matrix (Fin d) (Fin d) ℤ)) =
    fromBlocks ((0 : Matrix (Fin d) (Fin d) ℤ) * 0 + 1 * 1) ((0 : Matrix (Fin d) (Fin d) ℤ) * 1 + 1 * 0)
    (1 * 0 + 0 * 1) (1 * 1 + 0 * 0) by exact Matrix.fromBlocks_multiply _ _ _ _ _ _ _ _]
  simp

/-- **The full duality itself lies in `O(d,d;ℤ)`**, i.e. `ηᵀ η η = η`: swapping
    momentum and winding is a genuine symmetry, not merely an involution on charges.
    Proof idea: `η` is symmetric (`ηᵀ = η`) and self-inverse (`eta_mul_self`), so
    `ηᵀ η η = η · η · η = η`. -/
theorem eta_isODD : IsODD (eta d) := by
  unfold IsODD
  simp only [mul_assoc, eta_mul_self, mul_one]
  simp only [eta, fromBlocks_transpose]
  simp

/-- **`O(d,d;ℤ)` is closed under composition**: duality symmetries can be chained.
    Proof idea: expand `(gh)ᵀ η (gh) = hᵀ (gᵀ η g) h` by associativity and
    `(gh)ᵀ = hᵀgᵀ`, then substitute `g`'s and `h`'s defining identities in turn. -/
theorem isODD_mul (g h : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g) (hh : IsODD h) :
    IsODD (g * h) := by
  unfold IsODD at *
  calc (g * h)ᵀ * eta d * (g * h)
    -- regroup so gᵀ η g (known to equal η by hg) appears as a sub-term
    = hᵀ * (gᵀ * eta d * g) * h := by simp [Matrix.transpose_mul, Matrix.mul_assoc]
    _ = hᵀ * eta d * h := by rw [hg]
    _ = eta d := by rw [hh]

/-- **Cross-link.** At `d = 1`, `η` is Stream 1's Narain Gram matrix `U`: after
    reindexing `Charge 1 = Fin 1 ⊕ Fin 1` to `Fin 2` via the canonical equivalence
    `finSumFinEquiv`, `eta 1` is literally equal (not just isomorphic) to
    `DualScaleStream2.Lattice.hyperbolicU`, which is in turn proved equal to Stream 1's
    `StringTheory.UseCases.NarainLattice.gram` in `Lattice.hyperbolicU_eq_narain_gram`.
    Proof idea: both sides are `2×2` integer matrices with finitely many entries, so
    checking equality entrywise (`fin_cases`, `rfl`) is a finite, decidable computation. -/
theorem eta_one_reindex :
    (eta 1).reindex finSumFinEquiv finSumFinEquiv = DualScaleStream2.Lattice.hyperbolicU := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

end DualScaleStream2.TDuality
