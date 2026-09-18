/-
Stream 3 · P3.5 — dual towers of states, and the shared structure with scale-factor duality.

**Question P3.5 asks** (`docs/STREAM3_WORKFLOW.md` §4): is the swampland distance route a
third, independent micro/macro relation, or a restatement of P3.1/P3.2? This file answers the
part of that question a kernel can answer: **the dual-tower structure behind the Swampland
Distance Conjecture is the same algebraic object as scale-factor duality** — an involution
`M ↦ M₀²/M` whose fixed point is a minimum of the sum — so it is *not* independent of P3.1 at
the level of algebra. Whether it is independent as *physics* is not something this file claims.

### Physical background (Tier L)
The Swampland Distance Conjecture (SDC) was proposed by Ooguri–Vafa (Palti's ref. [4]); it
is quoted here from the pinned review `papers/foundations/palti_swampland_1903_06239.txt`,
ll. 2167–2181: for a theory coupled to gravity with moduli space `M`, from any point `P` there
is a point `Q` at infinite geodesic distance, and an infinite tower of states with mass scale
`M(Q) ∼ M(P) e^{−α d(P,Q)}` (eq. (2.100)), `α > 0`. Palti motivates it just above the box
(ll. 2156–2162) from T-duality: there are dual towers, and "the product of the mass scale of
the dual towers stays constant and so one must become light in any direction."

### What is Tier C here — the modeling step, stated plainly
Eq. (2.100) is an **asymptotic** statement with an **unspecified** `α` and `∼`. Nothing about
it can be proved, and any theorem about the expression `M₀e^{−αd}` alone (positive,
decreasing, tends to zero) would be a fact about `Real.exp` and not about physics — this
project's sibling repo retracted exactly that kind of vacuous "verified" statement (its
`README.md`, errors E-002/E-005). So this file does **not** formalize eq. (2.100). It
formalizes Palti's *motivating remark* (ll. 2158–2161), and even that only under a modeling
assumption this project introduces: **a dual pair of towers `(M₁, M₂)` with `M₁M₂ = M₀²`**.
That hypothesis is Tier C — it is the informal "product stays constant" remark turned into an
exact equation — and it appears explicitly as `hprod` in every theorem that uses it.

### What is proved (Tier A), and the vacuity check each one passes
* `dualTower_invol` — `M ↦ M₀²/M` is an involution.
* `dualTower_sum_ge` — under `hprod`, `M₁ + M₂ ≥ 2M₀`. Proved by rescaling to
  `a = M₁/M₀` and applying `ScaleFactorDuality.cosmoDualScale_ge_two` **directly** (imported,
  not re-proved): that reuse is the shared-structure claim, made checkable.
* `dualTower_min_le` — under `hprod`, `min(M₁, M₂) ≤ M₀`: at least one tower of each dual
  pair sits at or below the self-dual scale — the exact (non-asymptotic) content of "one must
  become light in any direction".
* Negative controls `dualTower_sum_ge_needs_product` and `dualTower_min_le_needs_product`:
  each of the two statements above is **false** once `hprod` is dropped (explicit
  counterexamples, kernel-checked). So neither theorem restates its own definitions.
* `expTowerPair_product` — the bridge from the SDC's exponential form: the pair
  `(M₀e^{−αd}, M₀e^{αd})` satisfies `hprod`. This one *is* a fact about `Real.exp` and is named
  and documented as a bridge lemma only; it does not formalize the SDC.

**Not proved, not claimed:** eq. (2.100) itself; any value of `α`; that the dual pair in any
real compactification satisfies `hprod` exactly (it does on a circle, where `M_KK M_w = 1/α'`
— the Tier L fact behind Palti's remark — but that is not re-derived here); and that the SDC
supports the Stream 3 pairing `ℓ_micro ~ ℓ_P`, `ℓ_macro ~ H₀⁻¹` — see `SelfDualCutoff.lean`.
Theorem names are taken from the algebra (`dualTower_*`), never `sdc_*`, so that the
statement lock, the theorem atlas and any book chapter grepping names cannot read them as
"the conjecture is proved".
-/
import DualScaleCosmology.ScaleFactorDuality
import Mathlib.Analysis.SpecialFunctions.Exp

namespace DualScaleCosmology.DualTower

open DualScaleCosmology.ScaleFactorDuality

/-- The dual-tower map `M ↦ M₀²/M` is an involution. -/
theorem dualTower_invol (M0 M1 : ℝ) (h0 : M0 ≠ 0) (h1 : M1 ≠ 0) :
    M0 ^ 2 / (M0 ^ 2 / M1) = M1 := by
  field_simp

/-- Under the dual-pair model `M₁M₂ = M₀²` (Tier C, see module docstring), `M₁ + M₂ ≥ 2M₀`.
The proof rescales to `a = M₁/M₀` and invokes `cosmoDualScale_ge_two` from P3.1 unchanged. -/
theorem dualTower_sum_ge (M0 M1 M2 : ℝ) (h0 : 0 < M0) (h1 : 0 < M1)
    (hprod : M1 * M2 = M0 ^ 2) : 2 * M0 ≤ M1 + M2 := by
  have ha : 0 < M1 / M0 := div_pos h1 h0
  have hb := cosmoDualScale_ge_two ha
  have hM2 : M2 = M0 ^ 2 / M1 := by field_simp; linarith [hprod]
  have key : M1 + M2 = M0 * cosmoDualScale (M1 / M0) := by
    rw [hM2]; simp only [cosmoDualScale, scaleFactorDual]; field_simp
  rw [key]; nlinarith [hb, h0]

/-- Under the dual-pair model, at least one tower of the pair is at or below the self-dual
mass scale `M₀`: the exact form of "one must become light in any direction" (Palti l. 2161). -/
theorem dualTower_min_le (M0 M1 M2 : ℝ) (h0 : 0 < M0) (hprod : M1 * M2 = M0 ^ 2) :
    min M1 M2 ≤ M0 := by
  by_contra h
  have h' : M0 < min M1 M2 := not_le.mp h
  have a := lt_of_lt_of_le h' (min_le_left M1 M2)
  have b := lt_of_lt_of_le h' (min_le_right M1 M2)
  nlinarith [mul_lt_mul'' a b h0.le h0.le]

/-- **Negative control.** Without the dual-pair hypothesis, `dualTower_sum_ge` is false
(`M₀ = 1`, `M₁ = M₂ = 1/4`). -/
theorem dualTower_sum_ge_needs_product :
    ¬ ∀ M0 M1 M2 : ℝ, 0 < M0 → 0 < M1 → 2 * M0 ≤ M1 + M2 := by
  intro h
  have := h 1 (1 / 4) (1 / 4) (by norm_num) (by norm_num)
  norm_num at this

/-- **Negative control.** Without the dual-pair hypothesis, `dualTower_min_le` is false
(`M₀ = 1`, `M₁ = M₂ = 2`). -/
theorem dualTower_min_le_needs_product :
    ¬ ∀ M0 M1 M2 : ℝ, 0 < M0 → min M1 M2 ≤ M0 := by
  intro h
  have := h 1 2 2 (by norm_num)
  norm_num at this

/-- **Bridge lemma, not the SDC.** The exponential tower pair `(M₀e^{−αd}, M₀e^{αd})` — the
shape of eq. (2.100) and its dual — satisfies the dual-pair hypothesis `M₁M₂ = M₀²`. A fact
about `Real.exp`; see the module docstring. -/
theorem expTowerPair_product (M0 α d : ℝ) :
    (M0 * Real.exp (-(α * d))) * (M0 * Real.exp (α * d)) = M0 ^ 2 := by
  have h : Real.exp (-(α * d)) * Real.exp (α * d) = 1 := by
    rw [← Real.exp_add]; simp
  calc (M0 * Real.exp (-(α * d))) * (M0 * Real.exp (α * d))
      = M0 ^ 2 * (Real.exp (-(α * d)) * Real.exp (α * d)) := by ring
    _ = M0 ^ 2 := by rw [h, mul_one]

end DualScaleCosmology.DualTower
