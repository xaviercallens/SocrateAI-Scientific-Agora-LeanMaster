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

The critical dimension of string theory is not an input but a *derived*
consequence of Weyl-anomaly (conformal ghost) cancellation: the total Virasoro
central charge of matter + reparametrization ghosts must vanish for the
worldsheet theory to be well-defined on a curved worldsheet.

For a first-order `(b,c)`-type conformal system of weights `(λ, 1-λ)`, the
central charge is (Polchinski (2.7.20) for anticommuting systems, (10.4.10)
for the sign-reversed commuting case):
  fermionic (anticommuting, e.g. the `bc` reparametrization ghosts): `c = 1 - 3(2λ-1)²`
  bosonic   (commuting, e.g. the `βγ` superconformal ghosts):        `c = 3(2λ-1)² - 1`

This file certifies both the general formula's sign relationship and its two
standard textbook instances: the bosonic string's `bc` ghosts (`λ=2`, giving
`c=-26`, cancelling `D=26` free bosons) and the superstring's combined
`bc`+`βγ` ghosts (`λ=2` and `λ=3/2` respectively), cancelling `D=10` free
bosons plus their NSR superpartner fermions.
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
