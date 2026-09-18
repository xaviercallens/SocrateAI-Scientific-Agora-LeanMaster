/-
Stream 3 · P3.8 — the self-dual length is the dark-energy length (and what that does and does
not imply for a Kaluza–Klein reading).

**Question P3.8 answers** — the open half of P3.6 (`docs/STREAM3_WORKFLOW.md` §4): P3.6 found that
CKN and scale-factor duality meet at the self-dual length `s = √(ℓ_P · L_H)` (`L_H = c/H₀`), and
P3.7 excluded `s` as a Regge slope. Does `s` have any physical meaning? **Yes — it is the
dark-energy length, exactly, up to a fixed O(1) factor**, and that factor is the only thing
separating it from the scale on which the "dark dimension" proposal is built.

### The identity (Tier A), and why it is not a coincidence
With `G = ℓ_P²` (`ħ = c = 1`) and `H₀ = 1/L_H`, the dark-energy density is
`ρ_Λ = Ω_Λ · 3H₀²/(8πG) = 3Ω_Λ/(8π ℓ_P² L_H²)` (`rhoLambda`; the critical density
`3H²/(8πG)` is the one used in Copeland–Kibble eq. (4.1), `0911_1345.txt` ll. 430–434, with
`H = ν/t`). Then
* `rhoLambda_inv_eq`: `ρ_Λ⁻¹ = (8π/(3Ω_Λ)) · s⁴`, i.e. `ρ_Λ^{−1/4} = (8π/(3Ω_Λ))^{1/4} · s`;
* `selfDual_lambda4_eq`: `s⁴ · ρ_Λ = 3Ω_Λ/(8π)` — in Montero–Vafa–Valenzuela's (MVV)
  parameterization `l = λ Λ^{−1/4}` (`2205_12293.txt` l. 67), the self-dual length has
  `λ_s = (3Ω_Λ/(8π))^{1/4}`, **a pure number independent of `ℓ_P` and `H₀`**.
So the CKN horizon cutoff (their eq. (2) saturated, `SelfDualCutoff.ckn_saturated_at_selfDual`),
the self-dual length of the pair `(ℓ_P, L_H)`, and `Λ^{−1/4}` are **one formula** with different
O(1) conventions. That is exactly why they agree numerically — it is algebra, not three
independent confirmations, and no document should cite it as such.

### Numbers (Tier A arithmetic on cited constants; `Ω_Λ = 0.68885` from `astropy`'s `Planck18`,
Planck 2018 VI Table 2)
* `darkEnergyLength4_bracket`: `(8π/(3Ω_Λ)) · s⁴ ∈ [(85 μm)⁴, (90 μm)⁴]` — i.e. the identity
  reproduces MVV's quoted `Λ^{−1/4} ≈ 88 μm` (`2205_12293.txt` l. 303). This is a
  **transcription check** (MVV's number is the same formula), not corroboration.
* `selfDual_lambda_above_mvv_range`: `λ_s⁴ ∈ [0.5⁴, 1)`, i.e. `λ_s ≈ 0.535` lies inside MVV's
  broad range `10⁻⁴ < λ < 1` (l. 424) but **at least 5×** above the upper end `10⁻¹` of their
  central estimate `λ ~ 10⁻¹ − 10⁻³` (ll. 424–427).
* `selfDual_above_torsion_radius_bound`: `s ≥ 1.5 × 30 μm`, where 30 μm is the Eöt-Wash bound on
  the toroidal radius of the largest extra dimension (Lee et al., `2002_11761.txt` ll. 285–289;
  gravitational-strength Yukawa range `< 38.6 μm`, same lines).

### The Kaluza–Klein reading — stated with its real margin
Identifying `s` directly with the radius of one large extra dimension puts it **above** the
torsion-balance bound by a factor ~1.6 and above MVV's neutron-star estimate `l < 44 μm`
(l. 327, itself an `∼`-level astrophysical estimate from their ref. [33]) by ~7%. Both margins are
O(1), and `s` itself carries a `(8π)^{1/4} ≈ 2.2` reduced-vs-non-reduced-Planck-mass convention
ambiguity, so **this file does not claim the KK reading is excluded**; it is disfavored by factors
of a few, not orders of magnitude (contrast P3.7's `10³⁰`). What survives is MVV's λ-suppressed
version, `l ~ λ Λ^{−1/4} ~ 0.1–10 μm` — a Tier L proposal, pinned, experimentally live, and
related to the self-dual length through the identity above. MVV also exclude a light *string*
tower at this scale (ll. 313–316), independently of P3.7.

### Relevance to K3 × T² (Tier C, not formalized)
MVV's scenario has exactly one mesoscopic extra dimension. On `K3 × T²` the only natural candidate
for a single large direction is one circle of the `T²`; its T-dual partner `R ↦ α'/R` would then be
tiny, and Stream 2's torus bound `tr G + tr G⁻¹ ≥ 2d` (`DualScaleStream2.DualScale.TraceBound`)
still applies to the `T²` metric. Nothing in this repository derives such a decompactification
limit; it is recorded here only as the point where Stream 3 touches the `K3 × T²` setting.

### Provenance of the proofs
The five goals were first stubbed as unfinished proofs and sent to the local prover
(`tools/prover_loop.py`, DeepSeek-Prover-V2-7B Q8_0, 2 rounds, kernel-gated): it closed
`rhoLambda_inv_eq` and `selfDual_lambda4_eq` and failed on the three `π`-bounded numeric goals.
Its accepted proof bodies (a long repeated `field_simp`/`ring`/`norm_num` chain) were then
replaced by the equivalent `unfold rhoLambda; field_simp`; statements unchanged, re-checked by the
kernel. The three numeric goals were closed by the orchestrator with `Real.pi_gt_d2`/`pi_lt_d2`.
-/
import DualScaleCosmology.SelfDualCutoff
import Mathlib.Analysis.Real.Pi.Bounds

namespace DualScaleCosmology.DarkEnergyScale

open DualScaleCosmology.SelfDualCutoff Real

/-- Dark-energy density `ρ_Λ = 3Ω_Λ/(8π ℓ_P² L_H²)` in `ħ = c = 1` (`G = ℓ_P²`, `H₀ = 1/L_H`). -/
noncomputable def rhoLambda (lP L Om : ℝ) : ℝ := 3 * Om / (8 * π * lP ^ 2 * L ^ 2)

/-- **The self-dual length is the dark-energy length:** `ρ_Λ⁻¹ = (8π/(3Ω_Λ)) · (ℓ_P L_H)²`. -/
theorem rhoLambda_inv_eq (lP L Om : ℝ) (hl : 0 < lP) (hL : 0 < L) (hO : 0 < Om) :
    1 / rhoLambda lP L Om = 8 * π / (3 * Om) * (lP * L) ^ 2 := by
  unfold rhoLambda; field_simp

/-- In MVV's `l = λ Λ^{−1/4}`, the self-dual length has `λ⁴ = s⁴ ρ_Λ = 3Ω_Λ/(8π)`. -/
theorem selfDual_lambda4_eq (lP L Om : ℝ) (hl : 0 < lP) (hL : 0 < L) :
    (lP * L) ^ 2 * rhoLambda lP L Om = 3 * Om / (8 * π) := by
  unfold rhoLambda; field_simp

/-- `Ω_Λ` from `astropy.cosmology.Planck18` (Planck 2018 VI, Table 2), rounded. -/
def omegaLambda : ℝ := 0.68885

/-- `Λ^{−1/4}` from the identity lies in `[85 μm, 90 μm]` (stated for the fourth powers, m⁴). -/
theorem darkEnergyLength4_bracket :
    (85e-6 : ℝ) ^ 4 ≤ 8 * π / (3 * omegaLambda) * (planckLength_m * hubbleRadius_m) ^ 2 ∧
      8 * π / (3 * omegaLambda) * (planckLength_m * hubbleRadius_m) ^ 2 ≤ (90e-6 : ℝ) ^ 4 := by
  have h1 := pi_gt_d2; have h2 := pi_lt_d2
  unfold omegaLambda planckLength_m hubbleRadius_m
  constructor
  · rw [div_mul_eq_mul_div, le_div_iff₀ (by norm_num)]; nlinarith
  · rw [div_mul_eq_mul_div, div_le_iff₀ (by norm_num)]; nlinarith

/-- `λ_s⁴ = 3Ω_Λ/(8π) ∈ [0.5⁴, 1)`: inside MVV's broad range, ≥ 5× their central upper end. -/
theorem selfDual_lambda_above_mvv_range :
    (0.5 : ℝ) ^ 4 ≤ 3 * omegaLambda / (8 * π) ∧ 3 * omegaLambda / (8 * π) < 1 := by
  have h1 := pi_gt_d2; have h2 := pi_lt_d2
  unfold omegaLambda
  constructor
  · rw [le_div_iff₀ (by positivity)]; nlinarith
  · rw [div_lt_one (by positivity)]; nlinarith

/-- `s ≥ 1.5 × 30 μm`, the Eöt-Wash toroidal-radius bound (both sides m², squared). -/
theorem selfDual_above_torsion_radius_bound :
    (1.5 * 30e-6 : ℝ) ^ 2 ≤ planckLength_m * hubbleRadius_m := by
  unfold planckLength_m hubbleRadius_m; norm_num

end DualScaleCosmology.DarkEnergyScale
