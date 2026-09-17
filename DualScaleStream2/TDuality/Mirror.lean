/-
Stream 2 · P2.2 — On `T²`, the factorized duality `D₀` conjugates the τ-shift into a B-shift.

## Physical background
On a two-torus `T²`, the metric and `B`-field moduli `(G_11, G_12, G_22, B_12)` are
usually packaged into two complex numbers: the complex-structure modulus `τ` (the
shape of the torus as a Riemann surface) and the Kähler modulus `ρ = B + i√det G`
(its area, twisted by the `B`-field). Mirror symmetry for `T²` is the statement that
these two moduli, and the geometric data they parametrize, can be exchanged. Source
(Tier L, for the interpretation): Giveon–Porrati–Rabinovici hep-th/9401139
(`papers/foundations/giveon_hep-th_9401139.txt`, line 344): "For a complex torus,
mirror symmetry is identical to what is called 'factorized duality'" — i.e. on `T²`,
`Factorized.factorized 0` (the circle-duality generator `D₀` from `Factorized.lean`)
*is* the mirror map. This file exhibits a piece of what that means concretely at the
level of `O(2,2;ℤ)` generators: conjugating a `τ`-modulus symmetry by `D₀` produces a
`ρ`-modulus symmetry (a `B`-field shift).

## Mathematical content
Proves the exact integer matrix identity (independently checked with sympy before
formalization):
    `D₀ · basisChange(T, (Tᵀ)⁻¹) · D₀ = (g_Θ)ᵀ`,  `T = [[1,1],[0,1]]`, `Θ = [[0,−1],[1,0]]`
(`mirror_conjugates_tauShift`), i.e. conjugating the unimodular basis change `T` (the
`τ ↦ τ + 1` generator of `SL(2,ℤ)_τ`) by the factorized duality `D₀` gives the
transpose `Θ`-shift — which, by `DFT.BShift.genMetric_bshift`, is exactly the integer
matrix that acts on the Hull–Zwiebach generalized metric as a `B`-field shift
`B ↦ B + Θ`. Also proves the two supporting facts needed for this: `T` and its
declared dual `(Tᵀ)⁻¹` really are matrix-inverse-transpose (`tauShift_dual_spec`, so
`basisChange T (Tᵀ)⁻¹` is a legitimate `O(2,2;ℤ)` element by `ODD.basisChange_isODD`)
and `Θ = [[0,-1],[1,0]]` really is antisymmetric (`mirrorTheta_antisymm`, so
`thetaShift Θ` is a legitimate `O(2,2;ℤ)` element by `ODD.thetaShift_isODD`).
**Not claimed**: which *sign* of the `ρ`-shift this corresponds to (depends on an
orientation convention for `ρ` not fixed here), nor any statement about `τ`/`ρ`
themselves as complex numbers — everything here is an identity of integer `4×4`
matrices acting on the charge lattice, not yet a statement about the moduli.

## Proof techniques
All four proofs are decidable finite computations on fixed `4×4` (`Charge 2`) or
`2×2` integer matrices: `ext` reduces a matrix equation to one equation per entry,
`fin_cases` exhausts the finitely many index pairs, and each resulting numerical
identity closes by `rfl`, `decide`, or unfolding plus `simp`. No induction or general
`d`-reasoning is needed because every object in this file is a concrete `T²` (`d = 2`)
matrix.

## Related declarations
* `DualScaleStream2.DFT.BShift.genMetric_bshift` (`DFT/BShift.lean`) is the theorem
  that gives the physical meaning of `(thetaShift mirrorTheta)ᵀ`: conjugating the
  generalized metric `genMetric G B` by a `thetaShiftR Θ` produces `genMetric G (B+Θ)`.
  `mirror_conjugates_tauShift` is what identifies *this specific* `Θ`-shift as arising
  from a `τ`-modulus symmetry conjugated by mirror symmetry — the two theorems
  together, not either alone, justify calling this a "mirror ↔ B-shift" identity.
  `Factorized.factorized_two` is the companion `T²` fact that `D₀ D₁ = η`.
* The atlas records a strong dependency overlap (weighted Jaccard 0.891/0.883) between
  `tauShift_dual_spec` and `DualScaleStream2.Lattice.cartanE8Inv_mul`/
  `hyperbolicUNeg_mul_self`: these are unrelated lattices (the `E8` Cartan matrix and
  the negative hyperbolic plane, not the `T²` moduli here), but the proofs share the
  same small-fixed-matrix `ext`/`fin_cases`/`decide` idiom — a proof-technique
  coincidence, not a mathematical relation.
* Likewise `mirrorTheta_antisymm`'s dependencies overlap with the symmetry proofs
  `Lattice.hyperbolicU_symm`/`cartanE8_symm`/`e8Neg_symm` (Jaccard ≈ 0.82): those are
  statements that *other* lattices' Gram matrices are *symmetric*, the opposite
  algebraic property from `mirrorTheta`'s antisymmetry — again a shared proof idiom on
  unrelated objects, not a shared mathematical fact.
-/
import DualScaleStream2.TDuality.Factorized

namespace DualScaleStream2.TDuality

open Matrix

/-- `T = [[1,1],[0,1]]`: the standard `SL(2,ℤ)` generator implementing `τ ↦ τ + 1`
    (a unimodular change of basis of the `T²` lattice; `A = T` in `ODD.basisChange`). -/
def tauShift : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 0, 1]

/-- `(Tᵀ)⁻¹ = [[1,0],[-1,1]]`: the contragredient matrix `B` that must pair with
    `A = T` in `basisChange A B` for `Aᵀ B = 1` to hold (see `tauShift_dual_spec`),
    i.e. the action induced on windings by the momentum-side basis change `T`. -/
def tauShiftDual : Matrix (Fin 2) (Fin 2) ℤ := !![1, 0; -1, 1]

/-- **`T` and `tauShiftDual` satisfy the `Aᵀ B = 1` compatibility condition** required
    to build a valid `O(2,2;ℤ)` basis-change element out of them. Proof idea: both are
    fixed `2×2` integer matrices, so `Tᵀ · tauShiftDual = 1` is checked entry-by-entry
    by exhaustive case split (`fin_cases`) and numeral computation (`decide`). -/
theorem tauShift_dual_spec : tauShiftᵀ * tauShiftDual = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [tauShift, tauShiftDual, Matrix.mul_apply, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;> decide

/-- **The `τ`-shift is in `O(2,2;ℤ)`**: `basisChange T (Tᵀ)⁻¹` is a genuine T-duality
    symmetry. Direct instance of `ODD.basisChange_isODD` applied to `tauShift_dual_spec`. -/
theorem tauShift_isODD : IsODD (basisChange tauShift tauShiftDual) :=
  basisChange_isODD _ _ tauShift_dual_spec

/-- `Θ = [[0,−1],[1,0]]`: an antisymmetric integer matrix, i.e. a valid integer
    `B`-field shift `Θ` for `ODD.thetaShift`. This is the specific shift that turns out
    (see `mirror_conjugates_tauShift`) to be the mirror-conjugate of the `τ`-shift `T`. -/
def mirrorTheta : Matrix (Fin 2) (Fin 2) ℤ := !![0, -1; 1, 0]

/-- **`Θ` is antisymmetric**, `Θᵀ = -Θ`, the hypothesis `ODD.thetaShift_isODD` needs to
    conclude `thetaShift mirrorTheta ∈ O(2,2;ℤ)`. Proof idea: fixed `2×2` matrix, so
    checked entrywise by `fin_cases`/`rfl`. -/
theorem mirrorTheta_antisymm : mirrorThetaᵀ = -mirrorTheta := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- **Mirror identity**: `D₀ · basisChange(T,(Tᵀ)⁻¹) · D₀ = (thetaShift Θ)ᵀ`. Reading:
    conjugating the `τ ↦ τ+1` symmetry by the factorized (mirror) duality `D₀` produces
    the transpose of a `B`-field shift by `Θ` — the matrix-level shadow of "mirror
    symmetry exchanges `τ`- and `ρ`-type transformations" on `T²`. Proof idea: both
    sides are fixed `4×4` (`Charge 2`) integer matrices, so the identity is checked
    entry-by-entry via `fin_cases`/`rfl` after unfolding all four definitions. -/
theorem mirror_conjugates_tauShift :
    factorized (0 : Fin 2) * basisChange tauShift tauShiftDual * factorized 0 =
      (thetaShift mirrorTheta)ᵀ := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

end DualScaleStream2.TDuality
