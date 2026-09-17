/-
Stream 2 · P2.2b — T-dual backgrounds have identical perturbative spectra.

## Physical background
The point of a T-duality symmetry `g ∈ O(d,d;ℤ)` is not just that it preserves the
abstract pairing `η` (`ODD.IsODD`), but that it relates two seemingly different string
backgrounds `H` and `gᵀHg` (different metric/`B`-field data) whose physical content is
identical: every charge in one background has a dual charge in the other with the same
mass² and the same level-matching data. Source (Tier L, for the physical statement):
Giveon, Porrati, Rabinovici, hep-th/9401139, §2.4
(`papers/foundations/giveon_hep-th_9401139.txt`): after eq. (2.4.29), "It can be shown
straightforwardly that this transformation leaves the partition function invariant"
(line 1417). This file formalizes exactly the charge-by-charge shadow of that
statement: not the partition function itself, but the bijection on charges that
reproduces the mass and level-matching data on the nose. The mass form used is the one
built from the Hull–Zwiebach generalized metric, eq. (2.17) (see `DFT.GeneralizedMetric`).

## Mathematical content
For every `d` and every real background matrix `H`:
* `isODD_left_inv`/`isODD_right_inv`: every `g ∈ O(d,d;ℤ)` is invertible over `ℤ`, with
  two-sided inverse `η gᵀ η`;
* `isODD_inv_isODD`: that inverse is itself in `O(d,d;ℤ)`;
* `spectrum_equivalence` (**main result**): for any `H : Matrix (Charge d) (Charge d) ℝ`
  and any `g ∈ O(d,d;ℤ)`, there is an explicit bijection `e` of the integer charge
  lattice (namely `Z ↦ g *ᵥ Z`) such that `massForm (gᵀHg) Z = massForm H (e Z)` *and*
  `chargeNorm (e Z) = chargeNorm Z` for every charge `Z` — i.e. the backgrounds `H` and
  `gᵀHg` have exactly the same multiset of (mass², charge-norm) pairs, matched charge
  by charge, not merely the same total spectrum in some statistical sense.
**Not claimed**: invariance of the full string partition function (oscillator sums,
modular integrals over the worldsheet torus) — only the classical momentum/winding
contribution to the mass and the level-matching charge norm.

## Proof techniques
`isODD_left_inv`/`isODD_right_inv` are short algebraic manipulations of the defining
equation `gᵀ η g = η`, using associativity and `eta_mul_self` to cancel `η`s.
`isODD_inv_isODD` composes these with a transpose computation. `spectrum_equivalence`
is the longest proof in this directory: it builds an explicit `Equiv` (the two
`mulVec` maps together with `isODD_left_inv`/`isODD_right_inv` as the two inverse
laws), then separately discharges the `massForm` equality (by relating `mulVec` over
`ℤ`, cast to `ℝ` via `toReal`, to `mulVec` over `ℝ`, then invoking the already-proved
covariance lemma `DFT.massForm_covariant` — which holds for *any* real matrix `g`,
with no `η`-preservation hypothesis needed for the mass identity itself; it is only
the accompanying `Equiv`/`chargeNorm` half of this theorem that needs `g ∈ O(d,d;ℤ)`)
and the `chargeNorm` equality (by direct appeal to `Factorized.chargeNorm_invariant`).

## Related declarations
* `DualScaleStream2.DFT.massForm_covariant` (`DFT/GeneralizedMetric.lean`) is the
  general-`H`, general-`g` covariance fact this file specializes to integer `O(d,d;ℤ)`
  elements and integer charges; `spectrum_equivalence` packages it together with
  `chargeNorm_invariant` (`Factorized.lean`) into a single "same spectrum" bijection.
* The cross-library bridge `DualScaleStream2.DFT.massForm_circle → StringTheory.
  UseCases.TDuality.{leftMomentum, rightMomentum, momentumMassSq}` (atlas) records
  that `DFT.massForm_circle` (`DFT/GeneralizedMetric.lean`) is stated to match Stream
  1's `d = 1` circle mass formula `StringTheory.UseCases.TDuality.momentumMassSq`. No
  Lean declaration derives `StringTheory.UseCases.TDuality.tduality_invariant_mass_squared`
  from `spectrum_equivalence` or vice versa — the two are proved independently, in
  different files, over different coefficient conventions (`ℚ` there, `ℝ` here) — but
  mathematically `spectrum_equivalence` is the intended generalization of that `d = 1`,
  single-duality (`R ↦ 1/R`) fact to arbitrary `d` and arbitrary `g ∈ O(d,d;ℤ)`, via
  the shared `massForm`/`massForm_circle` machinery in `DFT.GeneralizedMetric`.
* `isODD_left_inv`/`isODD_right_inv`/`isODD_inv_isODD` are the general-`d` analogues of
  the very concrete `d = 1` fact `eta_mul_self`/`ODD.eta_isODD` (`η` is its own
  inverse); here the inverse of a general `g` is built *from* `η`, rather than `η`
  being self-inverse, which is why `eta_mul_self` reappears as a lemma inside the
  proof of `isODD_left_inv`.
-/
import DualScaleStream2.TDuality.Factorized
import DualScaleStream2.DFT.GeneralizedMetric

namespace DualScaleStream2.TDuality

open Matrix DualScaleStream2.DFT

variable {d : ℕ}

/-- **`η gᵀ η` is a left inverse of `g`** for any `g ∈ O(d,d;ℤ)`: `(η gᵀ η) g = 1`.
    Proof idea: regroup as `η (gᵀ η g) = η η` using `hg : gᵀ η g = η`, which collapses
    to `1` by `eta_mul_self`. -/
theorem isODD_left_inv (g : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g) :
    (eta d * gᵀ * eta d) * g = 1 := by
  rw [Matrix.mul_assoc, Matrix.mul_assoc]
  unfold IsODD at hg
  -- substitute gᵀ η g = η, so the expression becomes η · η = 1
  rw [← Matrix.mul_assoc gᵀ, hg, eta_mul_self]

/-- **`η gᵀ η` is also a right inverse of `g`**: `g (η gᵀ η) = 1`. A one-sided inverse
    in a matrix ring (over a commutative ring, with `Matrix.mul_eq_one_comm`) is
    automatically two-sided, so this follows immediately from `isODD_left_inv`. -/
theorem isODD_right_inv (g : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g) :
    g * (eta d * gᵀ * eta d) = 1 := by
  exact mul_eq_one_comm.mp (isODD_left_inv g hg)

/-- Helper: `η` is symmetric. -/
theorem eta_transpose : (eta d)ᵀ = eta d := by
  unfold eta
  rw [fromBlocks_transpose]
  simp

/-- **The inverse `η gᵀ η` of a duality symmetry `g` is itself a duality symmetry**:
    `O(d,d;ℤ)` is closed under this inversion, not just under multiplication
    (`isODD_mul` in `ODD.lean`). Proof idea: transpose `η gᵀ η` (using `eta_transpose`)
    to get `η g η`, then check the `IsODD` condition for it reduces, via two
    applications of `eta_mul_self` (once on each side) and the right-inverse fact `hr`
    from `isODD_right_inv`, to the trivial identity `η = η`. -/
theorem isODD_inv_isODD (g : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g) :
    IsODD (eta d * gᵀ * eta d) := by
  have hr := isODD_right_inv g hg
  have ht : (eta d * gᵀ * eta d)ᵀ = eta d * g * eta d := by
    -- transpose the candidate inverse: (η gᵀ η)ᵀ = ηᵀ g ηᵀ = η g η, using η symmetric
    rw [Matrix.transpose_mul, Matrix.transpose_mul, Matrix.transpose_transpose, eta_transpose,
      Matrix.mul_assoc]
  unfold IsODD
  -- (η gᵀ η)ᵀ η (η gᵀ η) = (η g η) η (η gᵀ η); simplify η η = 1 on the left,
  -- then use hr : g(ηgᵀη) = 1 to collapse the right factor to η
  rw [ht, Matrix.mul_assoc (eta d * g) (eta d) (eta d), eta_mul_self, Matrix.mul_one,
    Matrix.mul_assoc (eta d) g (eta d * gᵀ * eta d), hr, Matrix.mul_one]

/-- Real image of an integer matrix, obtained by casting each entry `ℤ → ℝ`. Needed
    because `massForm`/the generalized metric are defined over `ℝ` (Hull–Zwiebach's
    continuous moduli `G, B`), while the duality group `IsODD`/`chargeNorm` here are
    defined over `ℤ` (the discrete symmetry and the lattice-valued charges); `toReal`
    is the bridge that lets `spectrum_equivalence` compare the two. -/
noncomputable def toReal (g : Matrix (Charge d) (Charge d) ℤ) : Matrix (Charge d) (Charge d) ℝ :=
  g.map (Int.cast : ℤ → ℝ)

/-- **T-dual backgrounds have identical (mass², level) spectra.** For any background
    `H` and any T-duality `g ∈ O(d,d;ℤ)`, the map `Z ↦ g *ᵥ Z` is a bijection of the
    integer charge lattice under which the mass² computed in the dual background
    `gᵀHg` at charge `Z` equals the mass² computed in `H` at the dual charge `e Z`, and
    the two charges have the same charge norm — i.e. `H` and `gᵀHg` describe the same
    physics, charge by charge. Proof idea: exhibit the bijection explicitly, as `g`
    acting by `mulVec` with two-sided inverse `η gᵀ η` (`isODD_left_inv`/
    `isODD_right_inv` supply the two `Equiv` inverse laws); then prove the mass
    equality by casting `g`'s action to `ℝ` (`toReal`) and invoking the
    already-established general covariance of `massForm` under any `η`-preserving real
    matrix (`DFT.massForm_covariant`); and get the charge-norm equality directly from
    `Factorized.chargeNorm_invariant`. -/
theorem spectrum_equivalence (g : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g)
    (H : Matrix (Charge d) (Charge d) ℝ) :
    ∃ e : (Charge d → ℤ) ≃ (Charge d → ℤ), ∀ Z : Charge d → ℤ,
      massForm ((toReal g)ᵀ * H * toReal g) (fun i => (Z i : ℝ)) =
        massForm H (fun i => (e Z i : ℝ)) ∧
      chargeNorm (e Z) = chargeNorm Z := by
  -- the bijection e is g acting by mulVec; its inverse is η gᵀ η acting the same way
  refine ⟨⟨fun Z => g *ᵥ Z, fun Z => (eta d * gᵀ * eta d) *ᵥ Z, ?_, ?_⟩, fun Z => ⟨?_, ?_⟩⟩
  · -- left-inverse law for the Equiv: (η gᵀ η)(g Z) = Z, from isODD_left_inv
    intro Z
    show (eta d * gᵀ * eta d) *ᵥ (g *ᵥ Z) = Z
    rw [Matrix.mulVec_mulVec, isODD_left_inv g hg, Matrix.one_mulVec]
  · -- right-inverse law for the Equiv: g((η gᵀ η) Z) = Z, from isODD_right_inv
    intro Z
    show g *ᵥ ((eta d * gᵀ * eta d) *ᵥ Z) = Z
    rw [Matrix.mulVec_mulVec, isODD_right_inv g hg, Matrix.one_mulVec]
  · -- mass-form equality: first show casting-then-acting agrees with acting-then-casting
    have hcast : toReal g *ᵥ (fun i => (Z i : ℝ)) = fun i => ((g *ᵥ Z) i : ℝ) := by
      funext i
      simp only [toReal, Matrix.mulVec, dotProduct, Matrix.map_apply]
      push_cast
      rfl
    show massForm ((toReal g)ᵀ * H * toReal g) (fun i => (Z i : ℝ)) =
      massForm H (fun i => ((g *ᵥ Z) i : ℝ))
    -- rewrite the real target as `toReal g *ᵥ (cast Z)`, then apply general covariance
    rw [← hcast]
    exact massForm_covariant (toReal g) H (fun i => (Z i : ℝ))
  · -- charge-norm equality: this is exactly chargeNorm_invariant applied to g, hg, Z
    exact chargeNorm_invariant g hg Z

end DualScaleStream2.TDuality
