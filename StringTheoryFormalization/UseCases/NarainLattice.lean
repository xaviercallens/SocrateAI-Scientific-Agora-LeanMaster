-- Use Case 3: The Narain Lattice Γ^{1,1} is Even, Self-Dual, and R-Independent
-- Status: VERIFIED (0 sorry, 0 admit)
-- Source: Narain (1986) Phys.Lett.B 169; Narain-Sarmadi-Witten (1987);
--         Polchinski Vol.1 §8.4; Ginsparg (1988) hep-th/8809176.
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic

namespace StringTheory.UseCases.NarainLattice

/-!
# The Narain Lattice `Γ^{1,1}`: Radius-Independence, Evenness, Self-Duality

## Physical background

A closed string on a circle of radius `R` (units `α'=1`) has left/right target-space
momenta `P_L = n/R + wR`, `P_R = n/R - wR` built from integer momentum `n` and winding
`w` (Tong §8.2, ll.11381-11395 of `papers/foundations/tong_string_theory_0908_0333.txt`,
which writes this with general `α'`; here `α'=1`). The Lorentzian quadratic form
`Q(n,w) = (P_L²-P_R²)/2` on these charges is the norm on the **Narain lattice**
`Γ^{1,1}` — the abstract charge lattice underlying every toroidal compactification.
Three structural facts about it matter physically: (1) `Q` turns out not to depend on
`R` at all, which is the algebraic seed of T-duality's `R ↦ α'/R` symmetry (Tong §8.3,
ll.11627-11640: the spectrum at radius `R` matches the spectrum at radius `α'/R` under
`n ↔ w`); (2) `Q` is *even* (`Q(n,w) ∈ 2ℤ`), needed for one-loop modular invariance of
the string partition function on this compactification (Narain 1986; Narain-Sarmadi-
Witten 1987; Polchinski Vol.1 §8.4 — none of these three are in this book's source
library, so their claims are not independently checked here beyond what Tong §8.2/8.3
already supports); (3) the lattice is *unimodular* (self-dual), Gram determinant `±1`,
the standard hyperbolic plane `U`.

## Mathematical content

`pL`, `pR` are the momentum functions above (over `ℚ`, restated independently of
`UseCases.TDuality`'s copy so this file's claims don't inherit that file's exact
lemma statements); `narainNorm` is `Q` built from them. `narain_norm_R_independent`
proves `narainNorm n w R = 2nw` for every `R ≠ 0` — the momentum-space form of fact (1)
above, for the specific closed-string momenta, not a general lattice-theory statement.
`Q`, `B`, `gram` then restate the *same* quadratic form abstractly as an integer bilinear
form and its Gram matrix, independent of any embedding into a `(P_L,P_R)` plane:
`narain_form_even` proves `Q` is even (fact 2, an exhibited witness `n*w` with
`Q(n,w)=2(n*w)`); `B_is_polarization_of_Q` checks `B` really is the polarization of `Q`;
`gram_eq_hyperbolic` computes the Gram matrix of `B` in the standard basis to be exactly
`!![0,1;1,0]`; and `narain_gram_unimodular` computes *that specific `2×2` matrix's*
determinant to be `-1` (fact 3). This last step is a statement about one fixed integer
matrix, not a general unimodularity theorem for lattices of arbitrary rank.

## Proof techniques

`field_simp` + `ring` clears denominators and verifies the polynomial identity for
`narain_norm_R_independent`; `Even` is witnessed directly by `⟨n*w, by ring⟩`; `B`'s
polarization identity and the Gram matrix computation are both closed by `unfold` +
`ring`/`norm_num`; the final determinant uses Mathlib's `Matrix.det_fin_two` formula
after rewriting the matrix to its explicit hyperbolic form.

## Related declarations

* `StringTheory.UseCases.TDuality.leftMomentum`/`rightMomentum` (`TDualityMassSpectrum.lean`)
  define the *identical* `pL`, `pR` formulas independently (deliberately not imported —
  see the docstring on `pL` below) and prove the T-duality transformation law that this
  file's fact (1) explains algebraically; the atlas records
  `narain_norm_R_independent ∩ tduality_flips_right_momentum` at dep-Jaccard 0.721 and
  `∩ tduality_fixes_left_momentum` at 0.626, both genuine mathematical kinship (same
  momenta, complementary claims), not shared-tactic noise.
* `DualScaleStream2.Lattice.hyperbolicU_eq_narain_gram` (bridge, per the atlas) proves
  a lattice defined independently in `DualScaleStream2` equals this file's `gram` — an
  external cross-check that two different modules' conventions for the hyperbolic plane
  agree, not a re-derivation of `gram` itself.
* `DualScaleStream2.TDuality.chargeNorm_even` (dep-Jaccard 0.187 with `narain_form_even`)
  is an independent evenness proof for a related but distinct charge-norm construction
  in the `DualScaleStream2` DFT formalism.
* `DualScaleStream2.Lattice.mukaiPair_self` (dep-Jaccard 0.684 with `B_is_polarization_of_Q`)
  is the analogous self-pairing fact for the rank-24 Mukai lattice, a different (though
  related) bilinear form on a different space.
-/

/-- Left-moving momentum (see also `UseCases.TDuality.leftMomentum`, restated
    self-contained here so this file's Narain-specific claims don't
    accidentally depend on the T-duality file's conventions). -/
def pL (n w R : ℚ) : ℚ := n / R + w * R

/-- Right-moving momentum. -/
def pR (n w R : ℚ) : ℚ := n / R - w * R

/-- The Narain quadratic form, as actually realized by the momenta. -/
def narainNorm (n w R : ℚ) : ℚ := (pL n w R ^ 2 - pR n w R ^ 2) / 2

/-- **Fact 1**: `narainNorm` equals `2nw` for *every* nonzero radius `R` — the
    quadratic form on the lattice carries no memory of the compactification
    radius. -/
theorem narain_norm_R_independent (n w R : ℚ) (hR : R ≠ 0) :
    narainNorm n w R = 2 * n * w := by
  unfold narainNorm pL pR
  field_simp
  ring

/-- The abstract integer-valued quadratic form on `Γ^{1,1}`, independent of
    any embedding: literally the closed-form value `2nw` that
    `narain_norm_R_independent` shows `narainNorm` always reduces to. -/
def Q (n w : ℤ) : ℤ := 2 * n * w

/-- **Fact 2**: `Γ^{1,1}` is an even lattice. -/
theorem narain_form_even (n w : ℤ) : Even (Q n w) := ⟨n * w, by unfold Q; ring⟩

/-- The associated symmetric bilinear form, obtained from `Q` by
    polarization: `B(v,v') = (Q(v+v') - Q(v) - Q(v'))/2`. -/
def B (n w n' w' : ℤ) : ℤ := n * w' + n' * w

/-- `B` really is the polarization of `Q`, i.e. `2B(v,v') = Q(v+v')-Q(v)-Q(v')`
    for `v=(n,w)`, `v'=(n',w')` — the standard way to recover a symmetric
    bilinear form from its associated quadratic form. -/
theorem B_is_polarization_of_Q (n w n' w' : ℤ) :
    2 * B n w n' w' = Q (n + n') (w + w') - Q n w - Q n' w' := by
  unfold B Q; ring

/-- The Gram matrix of `B` in the standard integer basis `(1,0), (0,1)`. -/
def gram : Matrix (Fin 2) (Fin 2) ℤ :=
  !![B 1 0 1 0, B 1 0 0 1; B 0 1 1 0, B 0 1 0 1]

/-- Evaluating `B` on the basis vectors `(1,0), (0,1)` gives exactly the
    standard hyperbolic form `[[0,1],[1,0]]`, i.e. the off-diagonal pairing
    of momentum and winding. -/
theorem gram_eq_hyperbolic : gram = !![0, 1; 1, 0] := by
  unfold gram B
  norm_num

/-- **Fact 3**: `Γ^{1,1}` is unimodular (self-dual) — its Gram determinant is
    `±1`. -/
theorem narain_gram_unimodular : gram.det = -1 := by
  rw [gram_eq_hyperbolic]
  simp [Matrix.det_fin_two]

end StringTheory.UseCases.NarainLattice
