/-
Copyright (c) 2026 Xavier Callens / SocrateAI Scientific Agora Collaboration. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Xavier Callens, SocrateAI Mathematical Physics Team
-/
import DualScaleValidation.UseCase1_ModuliStabilization
import DualScaleValidation.UseCase2_MoonshineBPS

/-!
# Observables: Exact-Arithmetic Consistency Checks for Speculative Phenomenological Relations

### Scope and Epistemic Tier (see `docs/PAPER7_IMPROVEMENT_PROPOSAL.md`, `mathesis-tier-gate`)
This module is **Tier A for its arithmetic only**: it certifies exact rational identities and
inequalities with the Lean 4 kernel. It is **not** a derivation of any physical observable from
first principles, and it does not certify that the dual-scale framework has "zero free parameters"
— no such theorem is stated or proved anywhere in this repository. The numerical relations below
(§1–§3) are **Tier C**: post-hoc numerical matches between a string-theoretic invariant computed
elsewhere in this corpus (the BPS lock ratio $77/60$, or the integer $27720 = \mathrm{lcm}(1,\dots,12)$)
and an observational quantity, with no dynamical or field-theoretic derivation connecting the two.
They are presented as falsifiable conjectures to be confronted with data, not as consequences of the
formalized mathematics. §4 is likewise **Tier C**: it is contingent on the (currently unformalized,
and in tension with $\mathcal{N}=4$ non-renormalization — see `UseCase1_ModuliStabilization`) moduli
stabilization scenario.

### 1. Primordial Tensor-to-Scalar Ratio $r$ (Tier C)
Speculative relation to the BPS lock integer $27720$ (via $A_2 = 462$, the conformal weight
normalization $55$, and $\mathcal{K}_{\mathrm{BPS}} = 27720$):
$$r = \frac{2}{27720/55} = \frac{110}{27720} = \frac{1}{252} \approx 0.0039683$$
stored below as the **exact reduced fraction** $1/252$ rather than a rounded decimal, to avoid the
rounding drift ($0.00396$ vs.\ $0.00397$) present in an earlier revision of this module.
LiteBIRD targets a total (systematics-inclusive) sensitivity $\delta r \approx 0.001$
(Ghigna et al., *The LiteBIRD mission to explore cosmic inflation*, PTEP 2023, arXiv:2406.02724),
so a $\pm 0.0005$ discovery window around the prediction is narrower than LiteBIRD's own $1\sigma$
and cannot by itself be called a "decisive" falsification test; see the paper for the honest
quantitative framing.

### 2. Scalar Spectral Index $n_s$ (Tier C)
$$n_s = 0.965 = \frac{965}{1000}$$
consistent with the Planck 2018 value $n_s = 0.9649 \pm 0.0042$ (Planck Collaboration, A&A 641,
A10 (2020), arXiv:1807.06211) — a **benchmark comparison**, not a joint fit.

### 3. Leptonic Dirac CP-Violating Phase $\delta_{CP}$ (Tier C)
Corrected arithmetic (an earlier revision of this module mixed the fractions $77/60$ and $77/360$
and rounded inconsistently to $282.4^\circ$; the exact value of the stated formula is $283^\circ$):
$$\delta_{CP} = 360^\circ \times \left(1 - \frac{77}{360}\right) = 283^\circ$$
NuFIT 5.2 (without Super-Kamiokande atmospheric data; Esteban et al., JHEP 09 (2020) 178,
arXiv:2007.14792; table at nu-fit.org/sites/default/files/v52.tbl-parameters.pdf) reports, for
**normal ordering**, $\delta_{CP} = 197^{\circ\,+42}_{\ \ -25}$ ($3\sigma$: $108^\circ$–$404^\circ$),
and for **inverted ordering**, $\delta_{CP} = 286^{\circ\,+27}_{\ \ -32}$ ($3\sigma$: $192^\circ$–$360^\circ$).
The prediction $283^\circ$ sits close to the *inverted*-ordering best fit and far from the
*normal*-ordering best fit (which current global data mildly prefer); it is not a "striking
alignment" with the headline neutrino fit.

### 4. Dark Energy Equation of State ($w_0, w_a$) (Tier C, contingent)
If the moduli potential of `UseCase1_ModuliStabilization` reached an exact minimum $V(\phi_0) = 0$,
the semiclassical vacuum energy would be exactly zero ($\Lambda = 0$), which is a Minkowski vacuum,
not de Sitter, and is not by itself a prediction of $w_0 = -1, w_a = 0$ with a *nonzero* dark-energy
density; matching observed dark energy would require an additional, undetermined source of vacuum
energy not derived in this corpus. Independently of that gap, DESI DR2 (BAO; Abbott et al. 2025,
arXiv:2503.14738 and arXiv:2503.14743) finds the time-varying quadrant $w_0 > -1$, $w_a < 0$
preferred over $\Lambda$CDM at $3.1\sigma$ for DESI BAO combined with CMB and supernovae — i.e.
current leading data are in tension with $(w_0, w_a) = (-1, 0)$, not merely "to be tested" by it.

- `@concept: SpeculativePhenomenology, TierCNumerology, PopperianFalsifiability, ObservationalCosmology`
- `@paper: Callens2026, LiteBIRD2023, Planck2018, NuFIT52, DESI2025DR2`
- `@impact: HonestFalsifiability`
-/

namespace DualScaleValidation.Observables

/-- Exact numerator of the speculative tensor-to-scalar ratio $r = 1/252$ (see module docstring §1). -/
def tensor_to_scalar_ratio_num : Nat := 1

/-- Exact denominator of the speculative tensor-to-scalar ratio $r = 1/252$. -/
def tensor_to_scalar_ratio_den : Nat := 252

/--
### THEOREM: Exact Reduction of the Speculative Tensor-to-Scalar Formula
**What this certifies:** the arithmetic identity $110/27720 = 1/252$ (by cross-multiplication,
avoiding floating-point division), i.e. that the ratio computed from the BPS lock integer reduces
exactly to the stored fraction. **What this does not certify:** that $r$ takes this value in nature,
or that $110/27720$ is the correct formula for the tensor-to-scalar ratio — both are Tier C.
-/
theorem tensor_to_scalar_ratio_reduction :
    110 * tensor_to_scalar_ratio_den = 27720 * tensor_to_scalar_ratio_num := by
  dsimp [tensor_to_scalar_ratio_den, tensor_to_scalar_ratio_num]

/-- Scaled Scalar Spectral Tilt: $n_s \times 10^3 = 965$ (corresponding to $n_s = 0.965$). -/
def spectral_index_scaled : Nat := 965

/-- Exact numerator of the leptonic Dirac CP phase in degrees: $\delta_{CP} = 283^\circ$
    (see module docstring §3 for the corrected arithmetic). -/
def neutrino_cp_phase_deg : Nat := 283

/-- Dark energy equation of state parameters: $w_0 = -1, w_a = 0$ (contingent Tier C claim;
    see module docstring §4 for the Minkowski-vacuum gap and the DESI DR2 tension). -/
def dark_energy_w0 : Int := -1
def dark_energy_wa : Int := 0

/-- Master Theorem 1: the fraction $1/252$ lies within LiteBIRD's plausible detection window
    $0.003 \le r \le 0.005$ (a wide illustrative window, not LiteBIRD's own $1\sigma$ — see docstring). -/
theorem tensor_to_scalar_in_illustrative_window :
    3 * tensor_to_scalar_ratio_den ≤ 1000 * tensor_to_scalar_ratio_num ∧
    1000 * tensor_to_scalar_ratio_num ≤ 5 * tensor_to_scalar_ratio_den := by
  dsimp [tensor_to_scalar_ratio_den, tensor_to_scalar_ratio_num]
  omega

/-- Master Theorem 2: Planck / ACT Spectral Index Consistency (benchmark comparison).
    The predicted tilt $n_s = 0.965$ is consistent with Planck 2018 ($0.950 \le n_s \le 0.980$). -/
theorem spectral_index_in_planck_window :
    950 ≤ spectral_index_scaled ∧ spectral_index_scaled ≤ 980 := by
  dsimp [spectral_index_scaled]
  omega

/-- Master Theorem 3: the corrected phase $283^\circ$ lies in a wide illustrative discovery window
    $270^\circ \le \delta_{CP} \le 295^\circ$ (not a NuFIT confidence interval — see docstring §3
    for the actual normal/inverted-ordering ranges, which this narrower window does not represent). -/
theorem neutrino_cp_phase_in_illustrative_window :
    270 ≤ neutrino_cp_phase_deg ∧ neutrino_cp_phase_deg ≤ 295 := by
  dsimp [neutrino_cp_phase_deg]
  omega

/-- Master Theorem 4: Pure Cosmological Constant Parametrization.
    $w_0 = -1$ and $w_a = 0$ (contingent Tier C claim in tension with DESI DR2 — see docstring §4). -/
theorem dark_energy_cosmological_constant :
    dark_energy_w0 = -1 ∧ dark_energy_wa = 0 := by
  dsimp [dark_energy_w0, dark_energy_wa]
  exact ⟨rfl, rfl⟩

/-- Master Theorem 5: Conjunction of the Four Tier-C Numerical Windows.
    Simultaneous certification that all four illustrative arithmetic windows hold for the stated
    exact values. This is a statement about arithmetic consistency between numbers appearing in the
    text, **not** a "zero free parameters" theorem — no such theorem is stated in this corpus. -/
theorem observables_windows_master_contract :
    (3 * tensor_to_scalar_ratio_den ≤ 1000 * tensor_to_scalar_ratio_num ∧
     1000 * tensor_to_scalar_ratio_num ≤ 5 * tensor_to_scalar_ratio_den) ∧
    (950 ≤ spectral_index_scaled ∧ spectral_index_scaled ≤ 980) ∧
    (270 ≤ neutrino_cp_phase_deg ∧ neutrino_cp_phase_deg ≤ 295) ∧
    (dark_energy_w0 = -1 ∧ dark_energy_wa = 0) := by
  refine ⟨tensor_to_scalar_in_illustrative_window,
          spectral_index_in_planck_window,
          neutrino_cp_phase_in_illustrative_window,
          dark_energy_cosmological_constant⟩

end DualScaleValidation.Observables
