/-
Stream 4 · P4.5 — the forger's test: does this project's own "27720 lock" survive twining?

### The criterion (Tier L for its history, Tier C as a methodological rule adopted here)
`45 = 45` and `196884 = 196883 + 1` were hints. What made moonshine more than numerology was that the
coincidence **persists under twining**: replace each dimension by the trace of a group element `g`,
and the relation still holds, for every `g`. An identity between dimensions that is really a
statement about an `M₂₄`-module survives this replacement; an accident of two integers does not.
`Characters.lean` shows genuine moonshine passing the test at `2A` and `3A`.

### The relation under test
`DualScaleValidation.UseCase2.bps_cross_multiplication_lock` (paper 7, Theorem 6.1) states
`𝒜₂ · 60 = (4·𝒜₁) · 77 = 27720`, with `𝒜₁ = 90`, `𝒜₂ = 462`. Paper 7 already warns that
cross-multiplying any fraction in lowest terms gives such an identity, and that
`27720 = lcm(1, …, 12)`. This file adds a sharper test.

### Result (Tier A arithmetic)
The lock says `𝒜₂/(N_Q·𝒜₁) = 77/60`, where `60` and `77` are *derived from* `𝒜₁ = 90`, `𝒜₂ = 462`.
The fair twined version therefore keeps no frozen literals: it asks whether the ratio relation holds
for each series with its **own** coefficients, `𝒜₂(g)·(N_Q·𝒜₁(1A)) = 𝒜₂(1A)·(N_Q·𝒜₁(g))`, i.e. whether
`𝒜₂(g)/𝒜₁(g)` equals `𝒜₂/𝒜₁`.
* `lock_at_identity` — at `g = 1A` the original lock holds, with `𝒜₁`, `𝒜₂` taken from the series
  **computed** in `QSeries.lean` rather than typed.
* `ratio_fails_at_2A` … `ratio_fails_at_7AB` — the ratio relation is **false** at every class tested.
  At `2A`: `𝒜₁(2A) = −6`, `𝒜₂(2A) = 14`, and `14·360 = 5040` while `462·(4·(−6)) = −11088`.
* `literal_lock_fails_at_2A` — the weaker form with `60` and `77` frozen also fails; it is kept only
  because it is the form a reader of paper 7 would try first.

### Reading (Tier C)
Relations that encode module structure — a decomposition such as `A₆ = 3520 + 10395` — are linear in
the representation and survive twining; `Characters.lean` checks this for levels 1–7 at `2A` and `3A`.
The lock is a *ratio* between two dimensions with an auxiliary weight `N_Q = 4`; ratios are not module
statements, and this one does not survive twining at any class tested. By the twining criterion it is
numerology, not moonshine. This does **not** show that no relation between BPS counts and `M₂₄` exists;
it shows that *this* one is not such a relation. The same test should be applied to any integer
coincidence this project proposes before it is given a physical reading.
-/
import DualScaleMoonshine.Twining

namespace DualScaleMoonshine

/-- Coefficient `n` of a computed (24×) twined series; exact by `twined_div24`. -/
def coeff (s : List ℤ) (n : ℕ) : ℤ := s.getD n 0 / 24

/-- The untwined series `24·H`. -/
def untwined : List ℤ := twined24 9 24 1 0

/-- The ratio relation, with each series' own coefficients:
`𝒜₂(g)·(4·𝒜₁(1A)) = 𝒜₂(1A)·(4·𝒜₁(g))`. -/
def ratioTwines (s : List ℤ) : Prop :=
  coeff s 2 * (4 * coeff untwined 1) = coeff untwined 2 * (4 * coeff s 1)

instance (s : List ℤ) : Decidable (ratioTwines s) := by unfold ratioTwines; infer_instance

/-- The literal lock, `𝒜₂(g)·60 = 4·𝒜₁(g)·77`, with `60` and `77` frozen. -/
def literalLock (s : List ℤ) : Prop := coeff s 2 * 60 = 4 * coeff s 1 * 77

instance (s : List ℤ) : Decidable (literalLock s) := by unfold literalLock; infer_instance

/-- At the identity the original lock holds, from the computed series: `𝒜₁ = 90`, `𝒜₂ = 462`,
`462·60 = 4·90·77 = 27720`. -/
theorem lock_at_identity :
    coeff untwined 1 = 90 ∧ coeff untwined 2 = 462 ∧ literalLock untwined ∧
      coeff untwined 2 * 60 = 27720 := by decide

theorem ratio_fails_at_2A : ¬ ratioTwines (twined24 9 8 2 (-16)) := by decide
theorem ratio_fails_at_3A : ¬ ratioTwines (twined24 9 6 3 (-6)) := by decide
theorem ratio_fails_at_5A : ¬ ratioTwines (twined24 9 4 5 (-2)) := by decide
theorem ratio_fails_at_7AB : ¬ ratioTwines (twined24 9 3 7 (-1)) := by decide

/-- The weaker, frozen-literal form also fails at `2A`. -/
theorem literal_lock_fails_at_2A : ¬ literalLock (twined24 9 8 2 (-16)) := by decide

end DualScaleMoonshine
