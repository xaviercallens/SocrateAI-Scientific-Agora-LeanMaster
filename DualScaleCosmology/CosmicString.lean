/-
Stream 3 · P3.4 (cosmic F-strings) and P3.7 (the Regge reading of the self-dual length).

Two separate questions, kept separate on purpose (`docs/STREAM3_WORKFLOW.md` §4):

**P3.4 — a micro object at macro scale.** A cosmic superstring is a fundamental string whose
tension is set by the micro scale `α'` but whose length is cosmological. Copeland–Myers–
Polchinski (CMP, `papers/foundations/hep-th_0312067.txt`) give the ten-dimensional `(p,q)`
string tension `μ̄_{p,q} = (1/2πα')·√((p − Cq)² + e^{−2Φ}q²)` (eq. (3.3), ll. 502–506) and the
four-dimensional tension `μ = e^{2A} μ̄` with warp factor `e^{2A}` (eq. (3.2), l. 497). For the
fundamental string, `(p,q) = (1,0)`, unwarped (`e^{2A} = 1` — a Tier C simplification; warping
only *lowers* `μ`), `μ = 1/(2πα')` in `ħ = c = 1`, so the dimensionless tension is
`Gμ/c² = ℓ_P²/(2πα')` (using `G = ℓ_P² c³/ħ`). `fStringGmu` is that expression, with `ℓ_P` and
`α'` in m and m². **What P3.4 does not do:** the roadmap also names the *mechanism* —
defects forming and scaling up to the horizon (Kibble mechanism, network scaling). That is
not formalized here and stays open.

**P3.7 — does the self-dual length survive as a Regge slope?** `SelfDualCutoff.lean` found the
CKN bound meets duality at `s = √(ℓ_P · c/H₀) ≈ 47 μm`, and disclaimed in prose that this is
a string length. This file turns that disclaimer into kernel-checked arithmetic, for one
explicitly named reading: **`α' = s²` as the fundamental string's Regge slope.** Tong,
`tong_string_theory_0908_0333.txt` ll. 3373–3377: at level `N` the open string has
`M² = (N − 1)/α'`, so Regge excitations are spaced by `~1/√α' = ħc/s ≈ 4 meV` — every quark
and gluon would carry meV excitations. CMS (`1911_03947.txt` ll. 1044–1048, CMS-EXO-19-012,
137 fb⁻¹ at 13 TeV) excludes string resonances below **7.9 TeV** at 95% CL. That limit is
**model-dependent**: it applies to the Regge excitations of quarks and gluons (l. 63) in the
low-string-scale models of its refs. [1, 2] (Anchordoqui et al.; Cullen–Perelstein–Peskin), not
to `√α'` in every string model. Tong's `M² ∝ 1/α'` is the model-independent backbone; the CMS
number is the concrete pinned value.

**Scope of the P3.7 exclusion — read this before citing it.** It excludes `s` as a **Regge
slope**. It says nothing about `s` as a **compactification radius**: a 47 μm radius sets a
Kaluza–Klein tower, which dijet searches do not probe, and which sits near the scale tested by
short-distance gravity experiments (not pinned here). CKN's `ℓ_UV` is a cutoff *length*, which
is closer in spirit to the KK reading. So P3.7 closes one reading of P3.6, not P3.6.

### What is proved (Tier A), with units on both sides of every inequality
* `fStringGmu_le_iff` — an observational bound `Gμ ≤ g` is equivalent to `ℓ_P² ≤ 2πgα'`, i.e.
  a **lower** bound on `α'` (`ℓ_P²` and `2πgα'` both in m², `g` dimensionless). Non-vacuous: it is an iff.
* `fStringGmu_selfDual` — with `α' = ℓ_P · L`, `Gμ = ℓ_P/(2πL)`: the cosmic-string tension of
  the self-dual pair is (1/2π times) the micro/macro ratio itself.
* `regge_window_nonempty` — the Planck XXV floor on `α'` (from `Gμ/c² < 1.5 × 10⁻⁷`,
  `1303_5085.txt` l. 53, Nambu–Goto, 95%) lies below the CMS ceiling `(ħc/7.9 TeV)²`: the two
  constraints leave a non-empty window for a Regge-slope `α'` (both sides m²).
* `selfDual_alphaPrime_exceeds_cms_ceiling` — `ℓ_P · c/H₀ ≥ 10³⁰ · (ħc/7.9 TeV)²` (both m²):
  as a Regge slope, the self-dual `α'` is excluded by 30 orders in `α'`, 15 in length.
* `selfDual_Gmu_below_cmp_window` — `Gμ ≤ 10⁻⁵⁰ · 10⁻¹¹` (dimensionless): cosmic F-strings of
  the self-dual `α'` would be more than 50 orders lighter than the lower end of CMP's
  brane-inflation window `10⁻¹¹ ≲ Gμ ≲ 10⁻⁶` (eq. (5.1), ll. 782–783). CMP's own caveat
  (ll. 809–811): that window assumes inflaton-driven perturbations, and "more general
  mechanisms would allow a wider range of scales".

**Deliberately not used as evidence:** the self-dual `Gμ ≈ 2 × 10⁻⁶²` also satisfies Planck's
`Gμ < 1.5 × 10⁻⁷` — by 55 orders. A bound passed by 55 orders cannot fail and tests nothing, so
no theorem here claims "consistency with Planck XXV" for the self-dual reading; the Planck bound
is used only for the generic floor on `α'` in `regge_window_nonempty`.
-/
import DualScaleCosmology.SelfDualCutoff
import Mathlib.Analysis.Real.Pi.Bounds

namespace DualScaleCosmology.CosmicString

open DualScaleCosmology.SelfDualCutoff Real

/-- Dimensionless tension `Gμ/c² = ℓ_P²/(2πα')` of an unwarped cosmic F-string
(CMP eq. (3.3) at `(p,q) = (1,0)`, eq. (3.2) with `e^{2A} = 1`); `ℓ_P` in m, `α'` in m². -/
noncomputable def fStringGmu (lP ap : ℝ) : ℝ := lP ^ 2 / (2 * π * ap)

/-- An upper bound `g` on `Gμ` is exactly a lower bound on `α'`: `Gμ ≤ g ↔ ℓ_P² ≤ 2πgα'`. -/
theorem fStringGmu_le_iff (lP ap g : ℝ) (ha : 0 < ap) :
    fStringGmu lP ap ≤ g ↔ lP ^ 2 ≤ 2 * π * g * ap := by
  unfold fStringGmu
  rw [div_le_iff₀ (by positivity)]
  constructor <;> intro h <;> linarith

/-- For the self-dual pair `α' = ℓ_P · L`, the F-string tension is `Gμ = ℓ_P/(2πL)`. -/
theorem fStringGmu_selfDual (lP L : ℝ) (hl : 0 < lP) (hL : 0 < L) :
    fStringGmu lP (lP * L) = lP / (2 * π * L) := by
  unfold fStringGmu
  field_simp

/-- Planck XXV Nambu–Goto bound `Gμ/c² < 1.5 × 10⁻⁷` (95% CL), `1303_5085.txt` l. 53. -/
def planckGmuBound : ℝ := 1.5e-7

/-- CMS 95% CL lower limit on string-resonance mass, eV (`1911_03947.txt` l. 1048). -/
def cmsStringResonanceMin_eV : ℝ := 7.9e12

/-- The Planck floor on a Regge-slope `α'` lies below the CMS ceiling `(ħc/7.9 TeV)²`
(both sides in m²): the allowed window is non-empty. -/
theorem regge_window_nonempty :
    planckLength_m ^ 2 / (2 * π * planckGmuBound) ≤
      (hbarC_eVm / cmsStringResonanceMin_eV) ^ 2 := by
  have hpi := Real.pi_gt_three
  have hb : (0 : ℝ) < planckGmuBound := by unfold planckGmuBound; norm_num
  rw [div_le_iff₀ (by positivity)]
  have h : planckLength_m ^ 2 ≤
      (hbarC_eVm / cmsStringResonanceMin_eV) ^ 2 * (6 * planckGmuBound) := by
    unfold planckLength_m hbarC_eVm cmsStringResonanceMin_eV planckGmuBound; norm_num
  have hpos : (0 : ℝ) ≤ (hbarC_eVm / cmsStringResonanceMin_eV) ^ 2 := by positivity
  nlinarith

/-- **P3.7.** Read as a Regge slope, the self-dual `α' = ℓ_P · c/H₀` exceeds the CMS ceiling
`(ħc/7.9 TeV)²` by a factor of at least `10³⁰` (both sides m²). -/
theorem selfDual_alphaPrime_exceeds_cms_ceiling :
    planckLength_m * hubbleRadius_m ≥
      (1e30 : ℝ) * (hbarC_eVm / cmsStringResonanceMin_eV) ^ 2 := by
  unfold planckLength_m hubbleRadius_m hbarC_eVm cmsStringResonanceMin_eV; norm_num

/-- **P3.7.** Cosmic F-strings with the self-dual `α'` have `Gμ ≤ 10⁻⁶¹`, more than 50 orders
below the lower end `10⁻¹¹` of CMP's brane-inflation window (dimensionless both sides). -/
theorem selfDual_Gmu_below_cmp_window :
    fStringGmu planckLength_m (planckLength_m * hubbleRadius_m) ≤ (1e-50 : ℝ) * 1e-11 := by
  rw [fStringGmu_selfDual _ _ (by unfold planckLength_m; norm_num)
    (by unfold hubbleRadius_m; norm_num)]
  have hpi := Real.pi_gt_three
  have hL : (0 : ℝ) < hubbleRadius_m := by unfold hubbleRadius_m; norm_num
  rw [div_le_iff₀ (by positivity)]
  have h : planckLength_m ≤ (1e-50 : ℝ) * 1e-11 * (6 * hubbleRadius_m) := by
    unfold planckLength_m hubbleRadius_m; norm_num
  nlinarith

end DualScaleCosmology.CosmicString
