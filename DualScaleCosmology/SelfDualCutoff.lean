/-
Stream 3 · P3.6 (partial) — where scale-factor duality and the CKN bound meet.

**Question P3.6 asks** (`docs/STREAM3_WORKFLOW.md` §4): do P3.1 (a duality) and P3.2 (a bound)
combine into one micro/macro relation, or are they disjoint? P3.3 showed the *naive*
combination fails: CKN at horizon scale caps the UV cutoff ~10³⁰ below the Planck energy, so
`ℓ_micro ~ ℓ_P` is **not** the CKN cutoff. This file shows what *does* combine, exactly.

### The Tier C modeling step, stated plainly
Read the hypothesis's two scales as a **T-dual pair**: `ℓ_macro = α'/ℓ_micro` with
`α' := ℓ_micro · ℓ_macro`, i.e. the same `R ↦ α'/R` involution as Stream 1/2's Buscher map
and P3.1's `a ↦ a⁻¹`, whose fixed point is the self-dual length `s = √(ℓ_micro ℓ_macro)`. And
identify the CKN Planck mass with `1/ℓ_micro` (natural units, `ħ = c = 1`). Both identifications
are this project's choices, not results from any pinned source; they appear as explicit
hypotheses/definitions below.

### What is proved (Tier A)
* `selfDual_pair_is_scaleFactorDual` — in units of `s`, the pair `(ℓ_micro/s, ℓ_macro/s)` is
  exactly a `scaleFactorDual` pair (`x ↦ x⁻¹` from P3.1): the pairing really is P3.1's duality.
* `ckn_iff_uvLength_ge_selfDual` — the CKN bound (`CKNBound`, corrected form `L²Λ⁴ ≤ M²`)
  with IR scale `L = ℓ_macro`, `M = 1/ℓ_micro`, UV cutoff `Λ = 1/ℓ_UV` holds **if and only if**
  `ℓ_UV² ≥ ℓ_micro · ℓ_macro`, i.e. `ℓ_UV ≥ s`. An iff between two non-equivalent-looking
  statements, so it cannot be vacuous: it fails in both directions for suitable `ℓ_UV`.
* `ckn_saturated_at_selfDual` — at `ℓ_UV = s` the bound is saturated (equality).

**Reading (Tier C):** under the two identifications above, *the smallest UV length the CKN
bound permits is exactly the self-dual length of the T-dual pair (`ℓ_micro`, `ℓ_macro`)*.
This is the Stream 1 dual-scale principle — no duality-invariant scale below the self-dual one
(`R + α'/R ≥ 2√α'`) — reappearing as a statement about the CKN bound. It reframes P3.3: the
hypothesis's `ℓ_micro ~ ℓ_P` is not where the micro cutoff sits; the cutoff sits at the
*geometric mean* `√(ℓ_P · H₀⁻¹)`.

### Numeric cross-check (Tier A arithmetic on cited constants)
`selfDual_length_sq_bracket` and `cknHorizon_length_bracket` place two independently sourced
lengths in the same bracket `[40 μm, 70 μm]`:
* the self-dual length `√(ℓ_P · c/H₀) ≈ 47.0 μm`, with `ℓ_P = 1.616255 × 10⁻³⁵ m` (CODATA 2018)
  and `c/H₀ = 1.3672 × 10²⁶ m` for `H₀ = 67.66 km/s/Mpc` (Planck Collaboration 2018 VI,
  A&A 641, A6 (2020), Table 2, TT,TE,EE+lowE+lensing+BAO) — both read from `astropy`'s
  `Planck18` and `constants` objects, which carry those citations, not typed from memory;
* CKN's **own** horizon-scale cutoff length `ħc/Λ ≈ 62 μm` for `Λ ≈ 10⁻²·⁵ eV`
  (hep-th/9803132 l. 113–114; `ħc = 1.97327 × 10⁻⁷ eV·m`, CODATA 2018), computed from
  `CKNInstance.cknLambdaHorizon_eV`.
Agreement is to a factor ~1.3, within the O(1) ambiguity of reduced vs. non-reduced Planck mass
(a factor `(8π)^{1/4} ≈ 2.2` in this length) and of CKN's own `∼`. The theorems prove only the
bracket, not agreement to better than that.

**Not proved, not claimed:** that `ℓ_micro` and `ℓ_macro` *are* a T-dual pair in nature; that
a string scale of ~50 μm exists (the reading would require `√α' ~ 50 μm`, i.e. a string scale
near the meV dark-energy scale — a claim this project does not make); nor anything about the
"dark dimension" literature, which discusses a similar micron scale and is not pinned here.
-/
import DualScaleCosmology.ScaleFactorDuality
import DualScaleCosmology.CKNInstance

namespace DualScaleCosmology.SelfDualCutoff

open DualScaleCosmology.ScaleFactorDuality

/-- In units of the self-dual length `s` (`s² = ℓ_micro ℓ_macro`), the pair is exactly a
scale-factor-duality pair: `ℓ_macro/s = scaleFactorDual (ℓ_micro/s)`. -/
theorem selfDual_pair_is_scaleFactorDual (lmi lma s : ℝ) (h1 : 0 < lmi) (hs0 : 0 < s)
    (hs : s ^ 2 = lmi * lma) : lma / s = scaleFactorDual (lmi / s) := by
  unfold scaleFactorDual
  rw [inv_div]
  field_simp
  nlinarith [hs]

/-- **CKN ⟺ UV length at least the self-dual length.** With `L = ℓ_macro`, `M = 1/ℓ_micro`,
`Λ = 1/ℓ_UV`, the corrected CKN bound `L²Λ⁴ ≤ M²` holds iff `ℓ_micro ℓ_macro ≤ ℓ_UV²`. -/
theorem ckn_iff_uvLength_ge_selfDual (lmi lma lUV : ℝ) (h1 : 0 < lmi) (h2 : 0 < lma)
    (h3 : 0 < lUV) :
    lma ^ 2 * (1 / lUV) ^ 4 ≤ (1 / lmi) ^ 2 ↔ lmi * lma ≤ lUV ^ 2 := by
  have e : lma ^ 2 * (1 / lUV) ^ 4 ≤ (1 / lmi) ^ 2 ↔ (lmi * lma) ^ 2 ≤ (lUV ^ 2) ^ 2 := by
    rw [div_pow, div_pow, one_pow, one_pow, mul_one_div,
      div_le_div_iff₀ (by positivity) (by positivity)]
    constructor <;> intro h <;> nlinarith [h]
  rw [e]
  exact pow_le_pow_iff_left₀ (by positivity) (by positivity) (by norm_num)

/-- At the self-dual length the CKN bound is saturated. -/
theorem ckn_saturated_at_selfDual (lmi lma lUV : ℝ) (h1 : 0 < lmi) (h2 : 0 < lma)
    (hs : lUV ^ 2 = lmi * lma) : lma ^ 2 * (1 / lUV) ^ 4 = (1 / lmi) ^ 2 := by
  have h : (1 / lUV) ^ 4 = 1 / (lmi * lma) ^ 2 := by
    rw [show (1 / lUV) ^ 4 = 1 / (lUV ^ 2) ^ 2 by ring, hs]
  rw [h]; field_simp

/-- Planck length, m (CODATA 2018, via `astropy.constants`). -/
def planckLength_m : ℝ := 1.616255e-35

/-- Hubble radius `c/H₀`, m, for `H₀ = 67.66 km/s/Mpc` (Planck 2018 VI Table 2, via
`astropy.cosmology.Planck18`). -/
def hubbleRadius_m : ℝ := 1.3672e26

/-- `ħc`, eV·m (CODATA 2018, via `astropy.constants`). -/
def hbarC_eVm : ℝ := 1.97327e-7

/-- The squared self-dual length `ℓ_P · c/H₀` lies in `[(40 μm)², (70 μm)²]`. -/
theorem selfDual_length_sq_bracket :
    (4e-5 : ℝ) ^ 2 ≤ planckLength_m * hubbleRadius_m ∧
      planckLength_m * hubbleRadius_m ≤ (7e-5 : ℝ) ^ 2 := by
  unfold planckLength_m hubbleRadius_m; norm_num

/-- CKN's own horizon-scale UV cutoff length `ħc/Λ` lies in `[40 μm, 70 μm]`. -/
theorem cknHorizon_length_bracket :
    (4e-5 : ℝ) ≤ hbarC_eVm / DualScaleCosmology.CKNInstance.cknLambdaHorizon_eV ∧
      hbarC_eVm / DualScaleCosmology.CKNInstance.cknLambdaHorizon_eV ≤ 7e-5 := by
  unfold hbarC_eVm DualScaleCosmology.CKNInstance.cknLambdaHorizon_eV; norm_num

end DualScaleCosmology.SelfDualCutoff
