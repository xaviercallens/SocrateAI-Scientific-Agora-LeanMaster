/-
Stream 7 · C-B — pre-big-bang relic gravitons at the programme's string scale, and the verdict
(frozen prediction `docs/STREAM7_PREDICTION_CB.md`, tag `stream7-cb-frozen`, made before any detector
sensitivity was pinned).

Assumptions (Tier C): (B1) scale-factor duality realised as a pre-big-bang phase; (B2) `α' = s² = ℓ_P c/H₀`,
so `g₁ = H₁/M_P ≃ M_s/M_P = ℓ_P/s`, i.e. `g₁² = ℓ_P/(c/H₀)`. Tier L (Gasperini–Veneziano,
`gasperini_veneziano_pbb_hep-th_0207130.txt`): `Ω ∼ ω^{3−2ν}`, `ν = |α − 1/2|` (Table 2, ll. 4467–4485);
`ω₁ ≃ g₁^{1/2} 10¹¹ Hz`, `Ω(ω₁) ≃ 10⁻⁴ g₁²` ((5.16), ll. 5056–5058). Detector (pinned after the freeze):
LISA mission proposal `1702_00786.txt` ll. 692–699 (OR7.2): measure `Ω = 1.3 × 10⁻¹¹ (f/10⁻⁴ Hz)⁻¹` for
`0.1 mHz < f < 2 mHz`, i.e. at best `Ω ≈ 6.5 × 10⁻¹³` in that band.

### What is proved (Tier A arithmetic)
* `cb_slope`: the spectral slope `3 − 2|α − 1/2|` is `3` in the dilaton phase (`α = 1/2`) and `0` (flat) in
  de Sitter (`α = −1`, control).
* `cb_g1_sq_bracket`: `g₁² ∈ [1.1, 1.3] × 10⁻⁶¹`.
* `cb_peak_below_lisa_band`: `ω₁ < 10⁻⁴ Hz` (compared as `ω₁⁴ = g₁² · 10⁴⁴ < 10⁻¹⁶`): there are no relic
  gravitons at all in LISA's stochastic-background band `f > 0.1 mHz`.
* `cb_peak_amplitude_unreachable`: even the peak `Ω(ω₁) ≃ 10⁻⁴ g₁² < 10⁻⁶⁴` lies more than fifty orders of
  magnitude below LISA's best `6.5 × 10⁻¹³`.
* **Verdict** (`cb_not_testable`): by the pre-registered rule TB, C-B is **not falsifiable in practice** —
  neither confirmed nor excluded. The reason is the programme's own string scale (`M_s ~ 1/s`, meV range):
  it puts every stringy relic of this kind out of reach, as it did for cosmic F-strings (C-C).
-/
import DualScaleCosmology.SelfDualCutoff

namespace DualScaleCosmology.Stream7CB

open DualScaleCosmology.SelfDualCutoff

/-- `g₁² = ℓ_P / (c/H₀)` (from `α' = s² = ℓ_P · c/H₀` and `g₁ = ℓ_P/s`). -/
noncomputable def g1Sq : ℝ := planckLength_m / hubbleRadius_m

/-- The Gasperini–Veneziano slope `3 − 2ν`, `ν = |α − 1/2|`. -/
noncomputable def slope (α : ℝ) : ℝ := 3 - 2 * |α - 1 / 2|

theorem cb_slope : slope (1 / 2) = 3 ∧ slope (-1) = 0 := by
  unfold slope; constructor <;> norm_num [abs_of_neg, abs_of_nonneg]

theorem cb_g1_sq_bracket : (1.1e-61 : ℝ) ≤ g1Sq ∧ g1Sq ≤ 1.3e-61 := by
  unfold g1Sq planckLength_m hubbleRadius_m
  constructor
  · rw [le_div_iff₀ (by norm_num)]; norm_num
  · rw [div_le_iff₀ (by norm_num)]; norm_num

/-- `ω₁ < 10⁻⁴ Hz`: with `ω₁ = g₁^{1/2} 10¹¹ Hz`, `ω₁⁴ = g₁² · 10⁴⁴ < (10⁻⁴)⁴`. -/
theorem cb_peak_below_lisa_band : g1Sq * (1e11 : ℝ) ^ 4 < (1e-4 : ℝ) ^ 4 := by
  have h := cb_g1_sq_bracket.2
  nlinarith [h]

/-- `Ω(ω₁) ≃ 10⁻⁴ g₁² < 10⁻⁶⁴`, far below LISA's best `6.5 × 10⁻¹³` in its band. -/
theorem cb_peak_amplitude_unreachable : 1e-4 * g1Sq < (1e-64 : ℝ) ∧ (1e-64 : ℝ) * 1e50 < 6.5e-13 := by
  have h := cb_g1_sq_bracket.2
  constructor
  · nlinarith [h]
  · norm_num

/-- **Verdict (rule TB): not testable** — the spectrum ends below LISA's band and its peak is below LISA's
sensitivity by more than fifty orders of magnitude. -/
theorem cb_not_testable :
    g1Sq * (1e11 : ℝ) ^ 4 < (1e-4 : ℝ) ^ 4 ∧ 1e-4 * g1Sq * 1e50 < (6.5e-13 : ℝ) := by
  have h := cb_g1_sq_bracket.2
  constructor
  · nlinarith [h]
  · nlinarith [h]

end DualScaleCosmology.Stream7CB
