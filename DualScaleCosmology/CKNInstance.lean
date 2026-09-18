/-
Stream 3 · P3.3 — numeric instantiation of the CKN bound at the cosmological horizon.

**What this file answers:** does the Cohen–Kaplan–Nelson bound (`CKNBound.lean`), evaluated
at a macro scale `ℓ_macro ~ H₀⁻¹`, permit a micro/UV cutoff anywhere near `ℓ_P` — the reading
the Stream 3 hypothesis (`docs/STREAM3_WORKFLOW.md` §1) would need for its "`ℓ_micro ~ ℓ_P`,
`ℓ_macro ~ H₀⁻¹`, linked by duality" picture to be consistent with CKN's own bound? **No,**
by about 30 orders of magnitude — and this is not a new calculation, it is CKN's *own*
worked example (hep-th/9803132 l. 113–114), quoted directly, not re-derived from `G`/`ħ`/`c`
here (that unit conversion is exactly the kind of arithmetic this project's own incident
history (`LL.md`) warns against re-deriving from memory instead of citing).

### Physical background (Tier L)
CKN, l. 113–114: "if we choose an IR cutoff comparable to the current horizon size, the
corresponding UV cutoff from eq. (2) is `Λ ∼ 10⁻²·⁵ eV`" — i.e. evaluating their own bound
(`CKNBound.ckn_L_le`/`ckn_Lambda_sq_le`) at `L ~ H₀⁻¹` (this project's `ℓ_macro`) gives a UV
cutoff `Λ ~ 3 × 10⁻³ eV`, not anywhere near the Planck scale. The Planck energy
`M_P c² ≈ 1.22 × 10¹⁹ GeV = 1.22 × 10²⁸ eV` (CODATA 2018, "Planck mass energy equivalent in
GeV", `physics.nist.gov/cgi-bin/cuu/Value?plkmc2gev`) is the standard stand-in for
`1/ℓ_micro` when `ℓ_micro ~ ℓ_P` (Stream 3 hypothesis, §1). These two numbers are ~31 orders
of magnitude apart.

### What is and is not proved here (Tier A vs. Tier L/C)
Tier A: `planckEnergy_gt_ckn_horizon_cutoff`, a `norm_num`-checked numeric inequality
between two literature-cited real-number constants — pure arithmetic, no physics content
beyond correctly transcribing CKN's own quoted number and the CODATA Planck energy. Both
constants are recorded with a deliberately *conservative* rounding (CKN's `~10⁻²·⁵ eV`
rounded **up** to `3.2 × 10⁻³ eV`; the Planck energy rounded **down** to `1.2 × 10²⁸ eV`),
so the proved gap of `10^30` is, if anything, an understatement of the true ~`10^30.6` ratio
(`1.22×10²⁸ / 3.16×10⁻³ ≈ 3.9×10³⁰`) — the conservative direction never favors the
conclusion being drawn.

**Not proved, and not claimed as anything beyond Tier L/C:** that `L ~ H₀⁻¹` is the *only*
or even the *right* macro scale to test (CKN's own choice, not re-derived or independently
justified here); that this closes P3.3 for every possible macro/micro pairing the Stream 3
hypothesis could mean — only the specific reading "the CKN bound's implied UV cutoff at
horizon scale is near `ℓ_P`" is tested and falsified. **Conclusion for
`docs/STREAM3_WORKFLOW.md` §6 (P3.3, now closed; feeds directly into P3.6):** the CKN route
(P3.2) does not support pairing `ℓ_micro ~ ℓ_P` with `ℓ_macro ~ H₀⁻¹` — if anything, CKN's
own bound argues the *opposite*, that consistency at horizon scale caps the UV cutoff far
*below* the Planck scale. Whether the scale-factor-duality route (P3.1) fares any
differently is untested by this file and remains open.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.NormNum

namespace DualScaleCosmology.CKNInstance

/-- CKN's own worked numeric example (hep-th/9803132 l. 113–114): the UV cutoff implied by
eq. (2) when the IR cutoff `L` is set to the current cosmological horizon size,
`Λ ~ 10⁻²·⁵ eV ≈ 3.16 × 10⁻³ eV`, rounded **up** to `3.2 × 10⁻³ eV` (a conservative bound —
see the module docstring). -/
def cknLambdaHorizon_eV : ℝ := 0.0032

/-- The Planck energy `M_P c² ≈ 1.22 × 10¹⁹ GeV = 1.22 × 10²⁸ eV` (CODATA 2018, "Planck mass
energy equivalent in GeV"), rounded **down** to `1.2 × 10²⁸ eV` (conservative). -/
def planckEnergy_eV : ℝ := 12 * (10 : ℝ) ^ 27

/-- **The Planck energy exceeds CKN's own horizon-scale UV cutoff by a factor of at least
`10³⁰`.** See the module docstring for the reading of this as a numeric test — and
falsification, at the order-of-magnitude level — of the Stream 3 hypothesis's CKN-based
reading. -/
theorem planckEnergy_gt_ckn_horizon_cutoff :
    planckEnergy_eV ≥ (10 : ℝ) ^ 30 * cknLambdaHorizon_eV := by
  unfold planckEnergy_eV cknLambdaHorizon_eV
  norm_num

end DualScaleCosmology.CKNInstance
