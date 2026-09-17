-- Use Case 2: Critical Dimensions of the Bosonic String (D=26) and Superstring (D=10)
-- Status: VERIFIED (0 sorry, 0 admit)
-- Source: Polchinski Vol.1 §2.7, eq.(2.7.20); Vol.2 §10.4, eq.(10.4.10);
--         GSW Vol.1 §3.2-3.3 (BRST anomaly cancellation).
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith

namespace StringTheory.UseCases.CriticalDimension

/-!
# Critical Dimension from Ghost Central-Charge Cancellation

## Physical background

Quantizing the string requires gauge-fixing worldsheet diffeomorphisms and Weyl
rescalings. The Faddeev-Popov procedure for this trades the gauge symmetry for a pair
of anticommuting reparametrization ghosts `(b,c)` (Tong §5.2, ll.6614-6620 in
`papers/foundations/tong_string_theory_0908_0333.txt`). Any such first-order conformal
system contributes a definite piece of Virasoro central charge, and the *total* central
charge of matter plus ghosts must vanish, or the Weyl symmetry used to gauge-fix in the
first place is anomalous and the theory is inconsistent off the classical worldsheet
(Tong §5.3, "We've also learnt that the Weyl symmetry is anomalous unless c = 0", l.6836).
Tong computes the `bc` ghost system's `T(z)T(w)` OPE explicitly and reads off
`c = -26` (l.6832-6838); adding `D` free worldsheet bosons, each contributing `c = 1`
(the general `T(z)T(w)` central term is defined at Tong §4.4, ll.4903-4915), forces
`D = 26` (l.6849). Repeating this with the superstring's extra `βγ` superconformal
ghost system (`c = +11`) forces the matched boson+fermion content down to `D = 10`
(Tong §5.3.1, ll.6884-6890). This is the textbook derivation of the two critical
dimensions of string theory: not an input postulate, but the unique cure for the
conformal (Weyl) anomaly.

## Mathematical content

`fermionicGhostCharge`/`bosonicGhostCharge` are the two central-charge formulas for a
weight-`(λ, 1-λ)` first-order system (Polchinski (2.7.20)/(10.4.10); GSW Vol.1 §3.2-3.3),
as rational functions of the weight `λ : ℚ`. The file proves:
* the two formulas are exact negatives of each other at every weight
  (`bosonic_eq_neg_fermionic`) — a purely algebraic fact about the two polynomials,
  reflecting (but not itself a proof of) the opposite-statistics origin of the sign;
* their values at the two textbook weights, `λ=2 ↦ -26` and `λ=3/2 ↦ 11`;
* that these numbers make the stated linear combinations of `D` (or `D` and `D/2`)
  vanish for `D=26` and `D=10` respectively;
* `bosonic_dimension_unique`: *within the bosonic-string ghost sector*, `D=26` is the
  only rational solution of the matter+ghost cancellation equation.
None of this proves that a consistent bosonic CFT of central charge `D` actually exists
for `D=26` (that is a separate, much harder statement about actual worldsheet theories,
not addressed here), nor does it derive the ghost central-charge formulas themselves
from a path integral or BRST computation — they are asserted, exactly as stated in the
sources above, and only their arithmetic consequences are checked.

## Proof techniques

Every theorem here is arithmetic on `ℚ` once the two ghost-charge definitions are
`unfold`ed: `ring` for the polynomial identity, `norm_num` for evaluating at a fixed
rational weight, and `linarith` for solving the single linear equation in
`bosonic_dimension_unique`. No case analysis, induction or non-arithmetic Mathlib lemma
is needed — the substantive input is entirely the two definitions.

## Related declarations

* `StringTheory.Frontier.central_charge_k3_eq_six` (`Frontier/CentralCharge.lean`) proves
  a structurally identical statement — a hard-coded sum of free-field central charges
  equalling a fixed rational number (dep-Jaccard 0.144 with `superstring_critical_dimension`,
  reflecting the shared `centralChargeBoson = 1` convention) — but for the K3 *internal*
  CFT (`c=6`) rather than the full critical dimension; the two are complementary halves
  of the same total-central-charge bookkeeping (`26 = 20 + 6` for the compactified string).
* No other declaration in the atlas shares nontrivial machinery with this file: its
  ghost-charge formulas are used nowhere else in the project (`fermionicGhostCharge` is a
  hub only within this file, per the atlas hub listing).
-/

/-- Central charge of an anticommuting first-order `(b,c)` system of weight
    `(λ, 1-λ)`. -/
def fermionicGhostCharge (lam : ℚ) : ℚ := 1 - 3 * (2 * lam - 1) ^ 2

/-- Central charge of a commuting first-order `(β,γ)` system of weight
    `(λ, 1-λ)` — the same formula with the overall sign reversed, reflecting
    the opposite statistics. -/
def bosonicGhostCharge (lam : ℚ) : ℚ := 3 * (2 * lam - 1) ^ 2 - 1

/-- The two ghost-charge formulas are exact negatives of one another at every
    weight — commuting vs. anticommuting first-order systems always
    contribute with opposite sign. -/
theorem bosonic_eq_neg_fermionic (lam : ℚ) :
    bosonicGhostCharge lam = - fermionicGhostCharge lam := by
  unfold bosonicGhostCharge fermionicGhostCharge
  ring

/-- The reparametrization `bc` ghosts (weight `λ=2`, i.e. `b` has weight 2 and
    `c` has weight `-1`) contribute central charge `-26`. -/
theorem bc_ghost_charge_eq : fermionicGhostCharge 2 = -26 := by
  unfold fermionicGhostCharge; norm_num

/-- The superconformal `βγ` ghosts (weight `λ=3/2`) contribute central charge
    `+11`. -/
theorem betagamma_ghost_charge_eq : bosonicGhostCharge (3 / 2) = 11 := by
  unfold bosonicGhostCharge; norm_num

/-- **Bosonic string critical dimension**: `D=26` free worldsheet bosons
    (`c=1` each) exactly cancel the `bc`-ghost anomaly. -/
theorem bosonic_string_critical_dimension :
    (26 : ℚ) * 1 + fermionicGhostCharge 2 = 0 := by
  rw [bc_ghost_charge_eq]; norm_num

/-- **Superstring critical dimension**: `D=10` free worldsheet bosons
    (`c=1` each) plus their `D=10` NSR fermion superpartners (`c=1/2` each)
    exactly cancel the combined `bc` + `βγ` ghost anomaly. -/
theorem superstring_critical_dimension :
    (10 : ℚ) * 1 + 10 * (1 / 2) + fermionicGhostCharge 2 + bosonicGhostCharge (3 / 2) = 0 := by
  rw [bc_ghost_charge_eq, betagamma_ghost_charge_eq]; norm_num

/-- No other integer spacetime dimension makes the *bosonic* string
    anomaly-free: matter central charge `D` cancels the ghosts only at
    `D = 26`. -/
theorem bosonic_dimension_unique (D : ℚ) (h : D * 1 + fermionicGhostCharge 2 = 0) :
    D = 26 := by
  rw [bc_ghost_charge_eq] at h; linarith

end StringTheory.UseCases.CriticalDimension
