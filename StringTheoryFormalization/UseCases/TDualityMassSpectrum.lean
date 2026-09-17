-- Use Case 1: T-Duality Invariance of the Closed String Mass Spectrum
-- Status: VERIFIED (0 sorry, 0 admit)
-- Source: Polchinski Vol.1 §8.1-8.2; Giveon-Porrati-Rabinovici (1994) hep-th/9401139.
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace StringTheory.UseCases.TDuality

/-!
# T-Duality Invariance of the Closed-String Mass Spectrum

## Physical background

A closed string on a circle of radius `R` (Tong §8.2, ll.11351-11395 of
`papers/foundations/tong_string_theory_0908_0333.txt`; units `α'=1` here, so this
file's `n/R + wR` is Tong's `n/R + wR/α'` with `α'` set to `1`) has quantized
momentum `n ∈ ℤ` and winding `w ∈ ℤ`, with left/right target-space momenta
`P_L = n/R + wR`, `P_R = n/R - wR` and mass formula `M² = P_L² + (2/α')(N-1) =
P_R² + (2/α')(Ñ-1)` (Tong eq. following l.11458, symmetrized here as
`P_L²+P_R²` plus the level-matched oscillator piece). T-duality is the exchange
`R ↦ α'/R`, `n ↔ w` (Tong §8.3, ll.11627-11640): Tong shows directly that under
this exchange `P_L → P_L` and `P_R → -P_R` (ll.11665-11670). This file certifies
exactly that momentum-level statement — not merely that `M²` is invariant (which
is the weaker, more commonly quoted fact) but that `P_L` is *fixed* and `P_R`
is *negated*, individually, before squaring. `DoubleFieldTheory.TDualityBuscher`
asserts the analogous invariance for the dilaton/Buscher-rule sector of double
field theory without proving the momentum-space statement itself; this file
supplies that missing piece for the free-boson toy model.

## Mathematical content

`leftMomentum`, `rightMomentum` are `P_L`, `P_R` above as functions `ℚ → ℚ → ℚ → ℚ`;
`momentumMassSq` is `P_L² + P_R²`, the momentum contribution to `M²` (the
`(2/α')(N+Ñ-2)` oscillator term is not modeled in this file at all — it is
duality-invariant on its own and so does not affect the argument, but no
statement here should be read as being *about* the oscillator sector).
`tduality_fixes_left_momentum` and `tduality_flips_right_momentum` are the two
individual momentum transformation laws; `tduality_invariant_mass_squared`
combines them to get invariance of the momentum-squared sum (the sign flip on
`P_R` cancels under squaring). `self_dual_radius_unique` is a separate, smaller
fact: `R=1` (i.e. `R=√α'` in the `α'=1` convention) is the *unique positive*
fixed point of `R ↦ 1/R` — the self-dual radius where T-duality acts trivially
on the geometry. None of these four theorems say anything about the oscillator
spectrum, interacting strings, or whether the full CFT (not just its momentum
zero-modes) is T-duality invariant — that stronger statement (extending to the
whole worldsheet theory) is asserted by Tong via the free-field OPE match but is
not formalized here.

## Proof techniques

`tduality_fixes_left_momentum`/`tduality_flips_right_momentum`: `unfold` the
momentum definitions, then `field_simp` (clearing the `1/R` and `1/(1/R)`
denominators using `hR : R ≠ 0`) followed by `ring` to match the resulting
polynomial identity. `tduality_invariant_mass_squared` chains both of these
`rw`s into the squared sum and closes with `ring` (the `-P_R` sign disappears
under squaring — this is the one-line computation making the whole file work).
`self_dual_radius_unique` clears the fraction `1/R = R` with `field_simp` to get
a polynomial equation in `R`, then uses `nlinarith` with the two auxiliary
square hints `(R-1)² ≥ 0` and `(R+1)² ≥ 0` to pin down `R=1` among the two
algebraic roots `±1`, using positivity `R>0` to discard `R=-1`.

## Related declarations

* `StringTheory.UseCases.NarainLattice.pL`/`pR` (`NarainLattice.lean`) restate the
  *identical* formulas independently (see that file's docstring) and prove the
  complementary fact that the resulting quadratic form is `R`-independent; the
  atlas records `narain_norm_R_independent ∩ tduality_flips_right_momentum` at
  dep-Jaccard 0.721 and `∩ tduality_fixes_left_momentum` at 0.626 — genuine shared
  content (the same momenta), from two files kept deliberately un-coupled.
* `DualScaleStream2.DFT.massForm_circle` (bridge, per the atlas) is an external
  consumer: a theorem in the `DualScaleStream2` double-field-theory formalism
  directly uses this file's `leftMomentum`, `rightMomentum` and `momentumMassSq`,
  so this file's momentum conventions are load-bearing for that module's own
  circle mass-formula theorem, not merely thematically related to it.
* `DoubleFieldTheory.TDualityBuscher` (imported nowhere in this file, referenced
  only in prose above) states T-duality invariance for the DFT dilaton/generalized
  metric sector; it is a different (Buscher-rule) formalization of the same
  physical symmetry, not built on this file or vice versa.
-/

/-- Left-moving momentum: combination of momentum and winding that survives
    T-duality unchanged. -/
def leftMomentum (n w R : ℚ) : ℚ := n / R + w * R

/-- Right-moving momentum: the combination that flips sign under T-duality
    (this sign flip is the defining, non-trivial content of Buscher's rule). -/
def rightMomentum (n w R : ℚ) : ℚ := n / R - w * R

/-- Momentum-squared contribution to `M²`. -/
def momentumMassSq (n w R : ℚ) : ℚ := (leftMomentum n w R) ^ 2 + (rightMomentum n w R) ^ 2

/-- **T-duality on the left-mover**: exchanging `(n,w) ↦ (w,n)` and `R ↦ 1/R`
    leaves `P_L` exactly fixed. -/
theorem tduality_fixes_left_momentum (n w R : ℚ) (hR : R ≠ 0) :
    leftMomentum w n (1 / R) = leftMomentum n w R := by
  unfold leftMomentum
  field_simp
  ring

/-- **T-duality on the right-mover**: the same exchange flips the *sign* of
    `P_R`. This sign flip is what makes T-duality a genuine ℤ₂ symmetry of the
    worldsheet theory (a parity on the right-moving sector) rather than a
    trivial relabeling. -/
theorem tduality_flips_right_momentum (n w R : ℚ) (hR : R ≠ 0) :
    rightMomentum w n (1 / R) = - rightMomentum n w R := by
  unfold rightMomentum
  field_simp
  ring

/-- **Main result**: the momentum contribution to `M²` is exactly invariant
    under T-duality, since it only ever sees `P_L²` and `P_R²`, and squaring
    erases the sign flip on `P_R`. -/
theorem tduality_invariant_mass_squared (n w R : ℚ) (hR : R ≠ 0) :
    momentumMassSq w n (1 / R) = momentumMassSq n w R := by
  unfold momentumMassSq
  -- replace the dual-frame P_L, P_R by their known images (fixed, resp. negated)
  rw [tduality_fixes_left_momentum n w R hR, tduality_flips_right_momentum n w R hR]
  -- (-P_R)^2 = P_R^2: the sign flip cancels once squared, giving invariance of M^2
  ring

/-- The self-dual radius `R = 1` is the unique positive fixed point of `R ↦ 1/R`. -/
theorem self_dual_radius_unique (R : ℚ) (hR : 0 < R) (hFix : (1 : ℚ) / R = R) :
    R = 1 := by
  have hR' : R ≠ 0 := ne_of_gt hR
  -- clear the denominator: hFix becomes the polynomial equation 1 = R^2
  field_simp at hFix
  -- R^2 = 1 has roots ±1; the two square hints let nlinarith rule out R = -1 using hR : 0 < R
  nlinarith [sq_nonneg (R - 1), sq_nonneg (R + 1)]

end StringTheory.UseCases.TDuality
