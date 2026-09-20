/-
Stream 8 · V3 — the decision rule for "dark energy is the bulk viscosity of a stretched defect network".

The vortex-core pivot (`docs/THOUGHT_EXPERIMENT_VORTEX_CORE.md`) proposes that the self-dual length is the core
size of primordial defects, and that dark energy is the bulk viscosity produced when expansion stretches that
network. This file does **not** derive that proposal. It fixes the arithmetic that any such proposal has to meet,
so that the claim becomes falsifiable instead of being an analogy:

* what bulk viscosity does to the effective equation of state, and exactly what `ζ` would have to be for
  `w_eff = −1`;
* what a frozen defect network gives instead, from its own scaling;
* the gap between the two, as a number that a measurement can close or refuse.

### Sources (Tier L)
* Viscous cosmology is textbook: in a FLRW background a bulk viscosity `ζ ≥ 0` shifts the pressure to
  `p_eff = p − 3ζH` (Eckart/Landau first-order form). Nothing else about `ζ` is assumed here.
* Frozen-network scaling is standard: a network of `n`-dimensional defects with energy density `ρ ∝ a^{-(3-n)}`
  has `w = −n/3`: `n = 1` (strings) gives `−1/3`, `n = 2` (walls) `−2/3`, `n = 3` (a cosmological constant) `−1`.
* The observational target is `w ≈ −1` (Planck/DESI); this file states the arithmetic, not the data.

### What is proved (Tier A, all elementary algebra over `ℝ`)
* `wEff_def`, `wEff_of_visc`: with `p_eff = p − 3ζH` and `w_eff = p_eff/ρ`, `w_eff = w − 3ζH/ρ`.
* `visc_for_wEff_neg_one`: `w_eff = −1` **iff** `3ζH = ρ(1 + w)`, i.e. `ζ = ρ(1+w)/(3H)`. So a constant `ζ`
  cannot give `w_eff = −1` through an epoch in which `ρ/H` changes: the required `ζ` tracks `ρ(1+w)/H`.
* `frozen_network_w`: a frozen network of `n`-dimensional defects has `w = −n/3`; in particular strings give
  `−1/3` and walls `−2/3`, neither of which is `−1`.
* `network_gap`: the gap a network of strings must close to reach `w_eff = −1` is `3ζH/ρ = 2/3`, and for walls
  `1/3` — the dissipative term has to supply that much, not a small correction.
* `wEff_monotone`: `w_eff` decreases as `ζ` grows, so the sign of the required correction is fixed: viscosity can
  only push `w_eff` down.

### What is NOT claimed
That the programme's defect network exists, that its `ζ` has this form, or that any of this describes dark energy.
`ζ` here is a free function; the physics would be a derivation of `ζ` from the core dynamics, which does not exist.
Entropy production by a viscous fluid is a further constraint not modelled here. If a derivation is ever produced,
the resulting `w(z)` must be frozen by git tag before comparison with data (the Stream 6–7 protocol,
`docs/STREAM6_EXPERIMENT_PLAN.md`); this file is the decision rule, prepared in advance of any such fit.
-/
import Mathlib

namespace DualScaleCosmology.ViscousDefectNetwork

/-- Effective pressure of a fluid with bulk viscosity `ζ` in a FLRW background: `p_eff = p − 3ζH`. -/
noncomputable def pEff (p ζ H : ℝ) : ℝ := p - 3 * ζ * H

/-- Effective equation of state `w_eff = p_eff / ρ`. -/
noncomputable def wEff (p ζ H ρ : ℝ) : ℝ := pEff p ζ H / ρ

theorem wEff_def (p ζ H ρ : ℝ) : wEff p ζ H ρ = (p - 3 * ζ * H) / ρ := rfl

/-- With `p = w ρ` and `ρ ≠ 0`: `w_eff = w − 3ζH/ρ`. -/
theorem wEff_of_visc (w ζ H ρ : ℝ) (hρ : ρ ≠ 0) :
    wEff (w * ρ) ζ H ρ = w - 3 * ζ * H / ρ := by
  unfold wEff pEff
  field_simp

/-- **The tuned relation.** `w_eff = −1` exactly when `3ζH = ρ(1 + w)`. -/
theorem visc_for_wEff_neg_one (w ζ H ρ : ℝ) (hρ : ρ ≠ 0) :
    wEff (w * ρ) ζ H ρ = -1 ↔ 3 * ζ * H = ρ * (1 + w) := by
  rw [wEff_of_visc w ζ H ρ hρ]
  constructor
  · intro h
    field_simp at h
    linarith
  · intro h
    field_simp
    linarith

/-- The same relation solved for `ζ`, when `H ≠ 0`: `ζ = ρ(1+w)/(3H)`. -/
theorem visc_value (w ζ H ρ : ℝ) (hρ : ρ ≠ 0) (hH : H ≠ 0) :
    wEff (w * ρ) ζ H ρ = -1 ↔ ζ = ρ * (1 + w) / (3 * H) := by
  rw [visc_for_wEff_neg_one w ζ H ρ hρ]
  constructor <;> intro h
  · field_simp; linarith
  · rw [h]; field_simp

/-- **Frozen network scaling.** A network whose energy density scales as `a^{-(3-n)}` has `w = −n/3`:
the continuity equation `ρ' = −3(1+w)ρ` with `ρ = ρ₀ a^{-(3-n)}` forces `1 + w = (3−n)/3`. -/
theorem frozen_network_w (n : ℝ) : (3 - n) / 3 - 1 = -(n / 3) := by ring

/-- Strings (`n = 1`) give `−1/3`, walls (`n = 2`) give `−2/3`, and neither is `−1`. -/
theorem string_wall_w :
    (3 - 1) / 3 - 1 = -(1 / 3 : ℝ) ∧ (3 - 2) / 3 - 1 = -(2 / 3 : ℝ) ∧
      -(1 / 3 : ℝ) ≠ -1 ∧ -(2 / 3 : ℝ) ≠ -1 := by
  norm_num

/-- **The gap.** For a frozen network with `w = −n/3`, reaching `w_eff = −1` needs `3ζH/ρ = 1 − n/3`:
`2/3` for strings, `1/3` for walls. The dissipative term is not a correction; it carries most of the effect. -/
theorem network_gap (n ζ H ρ : ℝ) (hρ : ρ ≠ 0) :
    wEff ((-(n / 3)) * ρ) ζ H ρ = -1 ↔ 3 * ζ * H / ρ = 1 - n / 3 := by
  rw [wEff_of_visc (-(n / 3)) ζ H ρ hρ]
  constructor <;> intro h <;> linarith

theorem network_gap_values : (1 : ℝ) - 1 / 3 = 2 / 3 ∧ (1 : ℝ) - 2 / 3 = 1 / 3 := by norm_num

/-- **Monotonicity.** For `ρ > 0` and `H > 0`, more viscosity means smaller `w_eff`: dissipation can only push
the effective equation of state down, never up. -/
theorem wEff_monotone (w H ρ : ℝ) (hρ : 0 < ρ) (hH : 0 < H) {ζ₁ ζ₂ : ℝ} (h : ζ₁ < ζ₂) :
    wEff (w * ρ) ζ₂ H ρ < wEff (w * ρ) ζ₁ H ρ := by
  rw [wEff_of_visc w ζ₁ H ρ (ne_of_gt hρ), wEff_of_visc w ζ₂ H ρ (ne_of_gt hρ)]
  have hnum : 3 * ζ₁ * H < 3 * ζ₂ * H := by nlinarith
  have hdiv : 3 * ζ₁ * H / ρ < 3 * ζ₂ * H / ρ := by
    rw [div_lt_div_iff_of_pos_right hρ]
    exact hnum
  linarith

end DualScaleCosmology.ViscousDefectNetwork
