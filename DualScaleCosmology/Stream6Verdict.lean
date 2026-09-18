/-
Stream 6 · P6.1 — the verdict on the frozen prediction P1 (`docs/STREAM6_PREDICTION_P1.md`, tag
`stream6-p1-frozen`).

P1: one large extra dimension of radius `R = s = √(ℓ_P · c/H₀)` (KK convention `m ~ 1/R`), with the inputs
of `SelfDualCutoff.lean`. The three pre-registered tests compare `R` with Eöt-Wash 2020's toroidal-radius
bound (30 μm, T1) and Yukawa-range bound (38.6 μm, T2), and with MVV's neutron-star bound (44 μm, T3).
All comparisons are made on squares (`R² = ℓ_P · c/H₀`), so no square root enters.

### What is proved (Tier A arithmetic on Tier L inputs)
* `p1_fails_T1`, `p1_fails_T2`, `p1_fails_T3`: `R` exceeds each of the three bounds.
* `p1_verdict_excluded`: by the pre-registered decision rule (T1 fails), **P1 is excluded**.
* `p1_margin`: `R > 1.5 × 30 μm` and `R > 1.06 × 44 μm` — the failure is not a rounding effect.
* `p1_factor_needed`: a factor `κ` with `R = κ·s` would have to satisfy `κ < 0.64` to pass T1 (`κ = 0.64`
  fails, `κ = 0.63` passes). This records what a future derivation (P6.2) would have to produce; it does
  **not** choose `κ` (choosing it now, after the bounds are known, would be a post-hoc fit).

### P6.2 — is the factor `κ` free? (Tier A algebra; the physical reading is Tier C)
* `p62_selfdual_fixed_point`: for `α' = s²`, the T-duality map `R ↦ α'/R` has the unique positive fixed
  point `R = s`; `p62_towers_coincide`: there the KK scale `1/R` and the winding scale `R/α'` coincide. So
  within the programme's own T-duality, the self-dual radius is `√α' = s` with the standard KK
  normalisation `m_n = n/R`: `κ = 1`, not a free `O(1)` factor. P1 is the programme's prediction, not one
  convention among several.
* `p62_two_dims_excluded`: if both circles of `T²` are large (two extra dimensions), MVV's neutron-star
  bound `l < 1.6 × 10⁻⁴ μm` (`2205_12293.txt` l. 326) is missed by more than five orders of magnitude.

### Not claimed
That the K3 × T² programme predicts an extra dimension at all (Tier C identification), or anything about
other identifications. The bounds themselves are Tier L (pinned in `papers/foundations/`).
-/
import DualScaleCosmology.SelfDualCutoff

namespace DualScaleCosmology.Stream6Verdict

open DualScaleCosmology.SelfDualCutoff

/-- `R² = s² = ℓ_P · c/H₀` (m²), the frozen P1 value. -/
noncomputable def p1RadiusSq : ℝ := planckLength_m * hubbleRadius_m

/-- T1: `R ≥ 30 μm` (Eöt-Wash 2020 toroidal-radius bound) — fails. -/
theorem p1_fails_T1 : (30e-6 : ℝ) ^ 2 < p1RadiusSq := by
  unfold p1RadiusSq planckLength_m hubbleRadius_m; norm_num

/-- T2: `R ≥ 38.6 μm` (Eöt-Wash 2020 Yukawa-range bound, `λ = R`) — fails. -/
theorem p1_fails_T2 : (38.6e-6 : ℝ) ^ 2 < p1RadiusSq := by
  unfold p1RadiusSq planckLength_m hubbleRadius_m; norm_num

/-- T3: `R ≥ 44 μm` (MVV neutron-star bound, one extra dimension) — fails. -/
theorem p1_fails_T3 : (44e-6 : ℝ) ^ 2 < p1RadiusSq := by
  unfold p1RadiusSq planckLength_m hubbleRadius_m; norm_num

/-- **Verdict under the pre-registered rule**: T1 fails, so P1 is *excluded* (and T2, T3 fail too). -/
theorem p1_verdict_excluded :
    (30e-6 : ℝ) ^ 2 < p1RadiusSq ∧ (38.6e-6 : ℝ) ^ 2 < p1RadiusSq ∧ (44e-6 : ℝ) ^ 2 < p1RadiusSq :=
  ⟨p1_fails_T1, p1_fails_T2, p1_fails_T3⟩

/-- The margins: `R > 1.5 × 30 μm` and `R > 1.06 × 44 μm`. -/
theorem p1_margin : (1.5 * 30e-6 : ℝ) ^ 2 < p1RadiusSq ∧ (1.06 * 44e-6 : ℝ) ^ 2 < p1RadiusSq := by
  unfold p1RadiusSq planckLength_m hubbleRadius_m; constructor <;> norm_num

/-- What an `O(1)` factor `R = κ s` would need to be for T1 to pass: `κ = 0.64` still fails, `κ = 0.63`
passes. Recorded, not chosen. -/
theorem p1_factor_needed :
    (30e-6 : ℝ) ^ 2 < (0.64 : ℝ) ^ 2 * p1RadiusSq ∧ (0.63 : ℝ) ^ 2 * p1RadiusSq < (30e-6 : ℝ) ^ 2 := by
  unfold p1RadiusSq planckLength_m hubbleRadius_m; constructor <;> norm_num

/-- **P6.2**: `R ↦ s²/R` has the unique positive fixed point `R = s` (the self-dual radius `√α'`). -/
theorem p62_selfdual_fixed_point (R s : ℝ) (hR : 0 < R) (hs : 0 < s) : R = s ^ 2 / R ↔ R = s := by
  constructor
  · intro h
    have h2 : R ^ 2 = s ^ 2 := by field_simp at h; nlinarith
    nlinarith [sq_nonneg (R - s), sq_nonneg (R + s)]
  · intro h; subst h; field_simp

/-- At `R = s` (`α' = s²`), the KK scale `1/R` equals the winding scale `R/α'`. -/
theorem p62_towers_coincide (s : ℝ) (hs : 0 < s) : 1 / s = s / s ^ 2 := by
  field_simp

/-- Two large extra dimensions (both circles of `T²` at `R = s`): MVV's bound `l < 1.6 × 10⁻⁴ μm` fails by
more than `10⁵`. -/
theorem p62_two_dims_excluded : (1e5 * 1.6e-10 : ℝ) ^ 2 < p1RadiusSq := by
  unfold p1RadiusSq planckLength_m hubbleRadius_m; norm_num

end DualScaleCosmology.Stream6Verdict
