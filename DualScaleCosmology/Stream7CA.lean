/-
Stream 7 · C-A — the Hubble-scale holographic reading, derived and confronted
(frozen prediction `docs/STREAM7_PREDICTION_CA.md`, tag `stream7-ca-frozen`).

Assumptions (Tier C, stated in the frozen document): (A1) `ρ_Λ = ε · 3H²/(8πG)` at all times (CKN
saturation with infrared length `c/H`), `0 < ε < 1`; (A2) flat FRW, `H² = (8πG/3)(ρ_m + ρ_Λ)`, with matter
separately conserved, `ρ_m = ρ_{m0}/a³`. Write `k = 8πG/3 > 0`.

### What is proved (Tier A)
* `ca_matter_fraction`: (A1)–(A2) force `ρ_m = (1 − ε) H²/k`.
* `ca_hubble_scaling`: hence `H(a)² = C/a³` with `C = k ρ_{m0}/(1 − ε) > 0`.
* `ca_deceleration`: for `E(a) = C/a³`, the deceleration parameter `q = −1 − a E′(a)/(2E(a))` equals
  **`1/2`** at every `a > 0` and for every `C > 0` — hence for every `ε`: no free parameter, no acceleration.
* `ca_verdict_excluded`: with Planck 2018's `Ω_Λ = 0.68885` (flat ΛCDM, `Ω_m = 1 − Ω_Λ`), `q₀ = Ω_m/2 − Ω_Λ < 0`,
  while C-A requires `q₀ = 1/2`; by the pre-registered rule, **C-A is excluded**. (The input `q₀` is
  model-dependent, as recorded in advance.)
-/
import DualScaleCosmology.DarkEnergyScale

namespace DualScaleCosmology.Stream7CA

/-- (A1)–(A2) force the matter density `ρ_m = (1 − ε) H²/k`. -/
theorem ca_matter_fraction (k H2 rm rL eps : ℝ) (hk : 0 < k)
    (hF : H2 = k * (rm + rL)) (hL : rL = eps * H2 / k) : rm = (1 - eps) * H2 / k := by
  field_simp
  subst hL
  field_simp at hF
  linarith

/-- With `ρ_m = ρ_{m0}/a³`, the Hubble rate scales as `H² = C/a³`, `C = k ρ_{m0}/(1 − ε)`. -/
theorem ca_hubble_scaling (k a H2 rm0 eps : ℝ) (hk : 0 < k) (ha : 0 < a) (he : eps < 1)
    (h : rm0 / a ^ 3 = (1 - eps) * H2 / k) : H2 = (k * rm0 / (1 - eps)) / a ^ 3 := by
  have h1 : (0 : ℝ) < 1 - eps := by linarith
  field_simp at h ⊢
  linarith

theorem hasDerivAt_E (C a : ℝ) (ha : a ≠ 0) :
    HasDerivAt (fun x : ℝ => C / x ^ 3) (-3 * C / a ^ 4) a := by
  have h := ((hasDerivAt_pow 3 a).inv (pow_ne_zero 3 ha)).const_mul C
  have h2 : HasDerivAt (fun x : ℝ => C / x ^ 3) (C * (-(↑3 * a ^ (3 - 1)) / (a ^ 3) ^ 2)) a :=
    h.congr_of_eventuallyEq (Filter.Eventually.of_forall fun x => by simp [div_eq_mul_inv])
  refine h2.congr_deriv ?_
  norm_num
  field_simp

/-- **The deceleration parameter is `1/2`** for `H² = C/a³`, at every `a > 0`. -/
theorem ca_deceleration (C a : ℝ) (hC : 0 < C) (ha : 0 < a) :
    -1 - a * deriv (fun x : ℝ => C / x ^ 3) a / (2 * (C / a ^ 3)) = 1 / 2 := by
  rw [(hasDerivAt_E C a ha.ne').deriv]
  field_simp
  ring

/-- **Verdict**: Planck 2018 (flat ΛCDM) gives `q₀ = (1 − Ω_Λ)/2 − Ω_Λ < 0 < 1/2`: C-A is excluded. -/
theorem ca_verdict_excluded :
    (1 - DualScaleCosmology.DarkEnergyScale.omegaLambda) / 2 - DualScaleCosmology.DarkEnergyScale.omegaLambda < 0 ∧
      (1 - DualScaleCosmology.DarkEnergyScale.omegaLambda) / 2 - DualScaleCosmology.DarkEnergyScale.omegaLambda
        ≠ 1 / 2 := by
  unfold DualScaleCosmology.DarkEnergyScale.omegaLambda; constructor <;> norm_num

end DualScaleCosmology.Stream7CA
