# Stream 3 Workflow — Micro/Macro Dual-Scale Cosmology

**Status: complete (2026-09-18, release `v3.4.0`)** by the definition of done in §6: every roadmap
row is either closed with kernel-checked theorems or closed as out of scope with a stated reason, and
the results are recorded in `docs/VERIFIED_FOUNDATION.md` and `README.md`. "Complete" means *the
formalization programme for this hypothesis is finished* — not that the hypothesis is proved; its
physical content stays Tier C (see the conclusion at the end of §6). Measured results are in §5. Sections 2–3 (hard constraints, model tiers) are the *same rules* Stream 2
uses — restated here only where Stream 3 narrows or adds to them, not duplicated in full.

## 1. The hypothesis, and what "formalizing" it can honestly mean

**The hypothesis (as given, Tier C):** instead of a single string length `l_s ~ l_P`, a
dual-scale framework pairs a microscopic scale `ℓ_micro ~ ℓ_P` (quantum gravity corrections,
UV completion) with a macroscopic scale `ℓ_macro ~ H₀⁻¹` or an intermediate galactic/dark-
sector scale, linked by "non-perturbative duality transformations, scale-invariance
breaking, or topological defects".

This is **not** a theorem anywhere in the literature, and this project does not treat it as
one. What *is* in the literature, and can be formalized today with the same discipline as
Streams 1–2, is two independent pieces that a Stream 3 hypothesis would have to be built
from:

1. **Scale-factor duality** (Gasperini–Veneziano, `papers/foundations/hep-th_9211021.txt`,
   "Pre-Big-Bang in String Cosmology", ll. 372–373, 639–640): the scale factor `a(t)` of an
   FRW background is odd under `a ↦ a⁻¹` in exactly the same `O(d,d)` sense that a
   compactification radius is odd under Buscher T-duality `R ↦ α'/R` (already Tier A in this
   project, paper 1). This is a genuine *duality* — an involution — but it is a symmetry of
   the *early-universe* string effective action, not a statement relating today's Hubble
   scale to the Planck scale.
2. **The Cohen–Kaplan–Nelson bound** (`papers/foundations/hep-th_9803132.txt`, eq. (2),
   l. 77–78): `L³Λ⁴ ≲ L·M_P²`, i.e. `L²Λ⁴ ≲ M_P²`, for a UV cutoff `Λ` and IR box size `L`
   (corrected 2026-09-18 from a dimensionally wrong first transcription — see §5), i.e. an actual inequality
   —not a duality— that ties a micro (UV) scale to a macro (IR/cosmological) scale, and
   which CKN themselves (l. 113–117) instantiate with `L` at "the current horizon size". If
   any published result deserves the name "micro/macro dual scale", this is it — and it
   predates this project's hypothesis by 28 years.

**What this pilot formalizes** (Tier A, `DualScaleCosmology/`): the algebra of (1) — the
involution, its fixed point, the induced bound `a + a⁻¹ ≥ 2`, and (as of the 2026-09-18
update below) the genuine calculus fact that the Hubble parameter `H(t) = a'(t)/a(t)` is odd
under the duality, `H(a⁻¹) = −H(a)` — and the algebra of (2) — the bound solved for each
variable. Later work packages (P3.3–P3.9, §4–§6) test the numbers, connect (1) and (2) at the
pair's self-dual length, and identify that length as the dark-energy length — see the conclusion
at the end of §6.

### Update, 2026-09-18: `H → −H` upgraded from Tier L to Tier A
The pilot originally left "the Hubble parameter is odd under duality" as Tier L, reasoning
that a real differentiation argument was out of scope for this project's usual
arithmetic-shadow style. That reasoning was checked against confirmed, sorry-free proof
work already sitting in a sibling project on the same disk —
`SocrateAI-Scientific-Agora-K3-DarkMatter/lean4_formal_proofs/Agora/Discovery/HubbleTension.lean`
— which proves a harder Mathlib `HasDerivAt`/chain-rule calculation in the same physics
style (an Early Dark Energy potential's derivative). That file was recompiled from scratch
against *this* project's own Mathlib v4.33.1 pin (not trusted from its own v4.33.0-rc1 pin)
before anything was ported, confirming the technique transfers. `hubble_dual` in
`ScaleFactorDuality.lean` now proves `H(a⁻¹) = −H(a)` directly, in four lines
(`HasDerivAt.inv` + `field_simp`), closing the gap the original pilot had left open.

## 2. Hard constraints

Identical to Stream 2 §2 (`docs/STREAM2_WORKFLOW.md`): kernel is the only accept gate,
producer ≠ verifier, no citation from memory (every Tier L docstring cites a pinned
`papers/foundations/*.txt` file and line range), ledger entries pin commit + job count,
separate `lean_lib` (`DualScaleCosmology` imports neither Stream 1 nor Stream 2, and is
imported by neither — a Stream 3 failure cannot turn Streams 1/2 red), large artifacts on
the second disk.

One addition specific to Stream 3: **identifier ASCII-only**. `tools/axiom_audit.py`'s
declaration regex (`[A-Za-z0-9_'.]+`) does not match Greek letters; an early draft of
`CKNBound.lean` named a theorem `ckn_Λ_le`, which the audit silently truncated to `ckn_` and
then failed to find. No existing declaration in this repo uses a non-ASCII identifier (verified
by grep before writing this rule); Stream 3 keeps that invariant — Greek letters belong in
comments and docstrings, never in a `theorem`/`lemma`/`def` name.

## 3. Model tiers and pipeline

Same T0–T3 tiers and S0–S9 pipeline as Stream 2 (§3–§4). P3.1–P3.7 were small enough that T0
(orchestrator) wrote and closed every goal directly rather than routing through T3→T2→T1 — a
pilot-scale shortcut, not a change to the routing rule. P3.8 was routed T3-first as the rule says
(stubs → `tools/prover_loop.py` → T0 for the residue); its measured result is in §5.

**Correction (2026-09-18) — the T3 host was misconfigured for most of this stream.** Ollama
runs as the system service `ollama.service` (user `ollama`), whose drop-in
`/etc/systemd/system/ollama.service.d/override.conf` sets
`OLLAMA_MODELS=/mnt/disks/disk-socrateai-local-1/leanmaster/ollama` (also `docs/INFRA_SETUP.md`
l. 136). The stream-start "restart" killed that service's process and launched a user-level
`ollama serve` with the *default* model directory (`~/.ollama/models`, "total blobs: 0" in its
log); the service then crash-looped on "address already in use" for ~2 h 20 min. An earlier
version of this paragraph said both prover models "were still resident" — **that was false**:
the `/api/tags` check that appeared to confirm it was taken before the restart. No P3.1–P3.7 goal
was ever sent to a local prover (all were closed by T0 directly, as §5 records), so no result
depends on this; it was found when `tools/prover_loop.py` on P3.8's stubs returned `HTTP 404` for
every attempt in 4 s. Fixed by stopping the user-level server and `systemctl restart ollama`:
13 blobs, `DeepSeek-Prover-V2-7B-GGUF:Q8_0`, `Goedel-Prover-V2-8B-GGUF:Q6_K` and
`qwen2.5-coder:7b-instruct` listed. **Restart procedure for future sessions:
`sudo systemctl restart ollama`, then confirm the model list — never a bare `ollama serve`.**
Lean tactics were smoke-tested post-restart (`ring`, `omega`, `#print axioms` under
`import Mathlib`) before any proof work began; that check was unaffected.

## 4. Phases

| Phase | Content | Pinned sources |
|---|---|---|
| **P3.1 Scale-factor duality** (pilot) | `a ↦ a⁻¹` involution; unique positive fixed point `a = 1`; `ln(a⁻¹) = −ln a`; `H(a⁻¹) = −H(a)` via `HasDerivAt` (`hubble_dual`); transferred dual-scale bound `a + a⁻¹ ≥ 2` | Gasperini–Veneziano hep-th/9211021 ll. 372–373, 639–640 |
| **P3.2 CKN micro/macro bound** (pilot; corrected 2026-09-18) | `L³Λ⁴ ≲ L·M_P²` → `L²Λ⁴ ≤ M_P²` → `LΛ² ≤ M_P`, solved for `L` and for `Λ²` (no `rpow` needed once the exponent was right) | Cohen–Kaplan–Nelson hep-th/9803132 eq. (2) l. 77–78, l. 80 |
| **P3.3 Numeric instantiation** (closed 2026-09-18) | used CKN's own l. 113–114 horizon-scale worked example (`Λ ~ 10⁻²·⁵ eV`) directly, rather than re-deriving `H₀⁻¹` in Planck units from scratch — avoids re-doing a unit conversion this project's own incident history warns against; compared to the CODATA Planck energy: a ≥`10^30` gap, Tier A (`CKNInstance.planckEnergy_gt_ckn_horizon_cutoff`) | CKN ll. 113–114; CODATA 2018 Planck mass energy equivalent |
| **P3.4 Cosmic F-strings** (closed 2026-09-18) | a fundamental string is a micro object (tension `1/(2πα')`) that can be cosmologically long: `Gμ/c² = ℓ_P²/(2πα')` for an unwarped F-string; an observational bound on `Gμ` is exactly a lower bound on `α'` (iff); for the self-dual pair `Gμ = ℓ_P/(2πL)`. **Mechanism closed as out of scope** — see P3.9 (`CosmicString.lean`) | Copeland–Myers–Polchinski hep-th/0312067 eqs. (3.2)–(3.3), ll. 497–506; Planck 2013 XXV (1303.5085) l. 53 |
| **P3.7 Regge reading of the self-dual length** (closed 2026-09-18) | if `α' = s² = ℓ_P · c/H₀` is taken as the fundamental string's **Regge slope**, string resonances sit at `ħc/s ≈ 4 meV`; CMS excludes them below 7.9 TeV (model-dependent, low-string-scale models) — excluded by ≥`10³⁰` in `α'`; cosmic F-strings of that `α'` would be >50 orders below CMP's brane-inflation window. **Does not touch** the compactification-radius (KK) reading of `s`. The Planck `Gμ` bound, passed by 55 orders, is deliberately not cited as evidence | Tong 0908.0333 ll. 3373–3377; CMS-EXO-19-012 (1911.03947) ll. 63, 1044–1048; CMP eq. (5.1) ll. 782–783, caveat ll. 809–811 |
| **P3.5 Dual towers / swampland distance** (closed 2026-09-18) | eq. (2.100) itself is asymptotic with unspecified `α` — not formalizable without vacuity, so *not* formalized. Formalized instead: Palti's motivating remark (dual towers, constant product) under an explicit Tier C model `M₁M₂ = M₀²`; result: the dual-tower structure is **the same involution as P3.1** (`dualTower_sum_ge` is proved by invoking `cosmoDualScale_ge_two` unchanged), with kernel-checked negative controls showing each statement fails without the model hypothesis (`DualTower.lean`) | Ooguri–Vafa (SDC), quoted at `palti_swampland_1903_06239.txt` ll. 2156–2181 |
| **P3.6 Combination of P3.1 and P3.2** (closed 2026-09-18, with P3.7–P3.8) | under two explicit Tier C identifications (`ℓ_micro`, `ℓ_macro` a T-dual pair with `α' = ℓ_micro ℓ_macro`; CKN's `M = 1/ℓ_micro`), the CKN bound holds **iff** the UV length is at least the pair's self-dual length `√(ℓ_micro ℓ_macro)` (`SelfDualCutoff.ckn_iff_uvLength_ge_selfDual`), saturated exactly there. Numerically `√(ℓ_P · c/H₀) ≈ 47 μm` and CKN's own horizon cutoff length ≈ 62 μm lie in the same `[40, 70] μm` bracket (kernel-checked). What that length *is*: P3.7 (not a Regge slope) and P3.8 (the dark-energy length) | CKN l. 77–78, 113–114; Planck 2018 VI Table 2 (via astropy); CODATA 2018 |
| **P3.8 What the self-dual length is** (closed 2026-09-18) | exact identity: with `ρ_Λ = Ω_Λ · 3H₀²/(8πG)`, `ρ_Λ⁻¹ = (8π/3Ω_Λ) · s⁴`, i.e. **the self-dual length is the dark-energy length** up to `(8π/3Ω_Λ)^{1/4}`; in MVV's `l = λΛ^{−1/4}` it has `λ_s = (3Ω_Λ/8π)^{1/4} ≈ 0.535`, a pure number. So CKN's horizon cutoff, `s`, and `Λ^{−1/4}` are one formula — their agreement is algebra, not corroboration. KK reading: `s` sits above the Eöt-Wash 30 μm radius bound by ~1.6× and above MVV's neutron-star estimate by ~7% — **disfavored by O(1), not excluded**; MVV's λ-suppressed dark dimension (0.1–10 μm) remains live (`DarkEnergyScale.lean`) | Montero–Vafa–Valenzuela 2205.12293 ll. 67, 303, 313–316, 327, 424–427; Lee et al. 2002.11761 ll. 285–289; Copeland–Kibble 0911.1345 eq. (4.1) ll. 430–434; Planck 2018 VI via astropy |
| **P3.9 Defect-network mechanism and domain walls** (closed as out of scope 2026-09-18) | how defects grow to horizon size is a **simulation result**: string networks reach a scaling regime `ξ/t ≈` const by "general agreement from several simulations" (Copeland–Kibble ll. 421–423; `ρ_str/ρ = 8πGμγ²/(3ν²)`, eq. (4.1)), and walls reach `ρ_wall = Aσ/t` with `A ≃ 0.8` from field-theory simulations (Saikawa eqs. (2.17)–(2.18), ll. 269–283). Formalizing `ρ = μ/ξ²` or `ρ = Aσ/t` would only restate those definitions — the vacuity failure §2's rules exist to catch — so neither is formalized. The one structural point, quoted not proved (Tier L): a defect network carries the macro scale **by causality** (`ξ ≲ t`, Kibble, CK ll. 272–276), while the micro scale enters only through the tension; the two are not related by a duality | Copeland–Kibble 0911.1345 ll. 266–276, 418–446; Saikawa 1703.02576 ll. 269–305 |

## 5. Pilot results — measured

**P3.1 – P3.8 (44 declarations, 7 files) — 44/44 closed, gate G3 passed; P3.9 closed as out of scope.**

| Declaration | Kind | Closed by |
|---|---|---|
| `ScaleFactorDuality.scaleFactorDual` | def | T0 |
| `ScaleFactorDuality.scaleFactorDual_invol` | theorem | T0, `simp [inv_inv]` |
| `ScaleFactorDuality.scaleFactorDual_fixed_iff` | theorem | T0, `field_simp` + `nlinarith` |
| `ScaleFactorDuality.log_scaleFactorDual` | theorem | T0, `simp [Real.log_inv]` |
| `ScaleFactorDuality.hubble` | def | T0 (added 2026-09-18) |
| `ScaleFactorDuality.hubble_dual` | theorem | T0 (added 2026-09-18), `HasDerivAt.inv` + `field_simp`; technique confirmed working under this project's Mathlib pin by first recompiling `SocrateAI-Scientific-Agora-K3-DarkMatter`'s `HubbleTension.lean` standalone |
| `ScaleFactorDuality.cosmoDualScale` | def | T0 |
| `ScaleFactorDuality.cosmoDualScale_ge_two` | theorem | T0, same algebraic identity as Stream 2 `TraceBound.circle_effective_scale_ge_two` |
| `CKNBound.ckn_bound` | theorem | T0 (rewritten 2026-09-18 — see correction below), `le_of_mul_le_mul_left` |
| `CKNBound.ckn_L_Lambda_sq_le` | theorem | T0, `nlinarith` on `(a−b)(a+b) ≤ 0` — no `rpow` needed once the correct exponent was used |
| `CKNBound.ckn_L_le` | theorem | T0, `le_div_iff₀` |
| `CKNBound.ckn_Lambda_sq_le` | theorem | T0, `le_div_iff₀` |
| `CKNInstance.cknLambdaHorizon_eV` | def | T0 (added 2026-09-18), CKN's own l. 113–114 number |
| `CKNInstance.planckEnergy_eV` | def | T0 (added 2026-09-18), CODATA 2018 |
| `CKNInstance.planckEnergy_gt_ckn_horizon_cutoff` | theorem | T0, `norm_num` |
| `DualTower.dualTower_invol` | theorem | T0, `field_simp` |
| `DualTower.dualTower_sum_ge` | theorem | T0 — proved *by invoking* `ScaleFactorDuality.cosmoDualScale_ge_two` after rescaling `a = M₁/M₀` |
| `DualTower.dualTower_min_le` | theorem | T0, `nlinarith` by contradiction |
| `DualTower.dualTower_sum_ge_needs_product` | theorem (negative control) | T0, explicit counterexample |
| `DualTower.dualTower_min_le_needs_product` | theorem (negative control) | T0, explicit counterexample |
| `DualTower.expTowerPair_product` | theorem (bridge, a fact about `exp`) | T0, `Real.exp_add` |
| `SelfDualCutoff.selfDual_pair_is_scaleFactorDual` | theorem | T0, `field_simp` + `nlinarith` |
| `SelfDualCutoff.ckn_iff_uvLength_ge_selfDual` | theorem | T0, `div_le_div_iff₀` + `pow_le_pow_iff_left₀` |
| `SelfDualCutoff.ckn_saturated_at_selfDual` | theorem | T0, `field_simp` |
| `SelfDualCutoff.planckLength_m`, `hubbleRadius_m`, `hbarC_eVm` | defs | cited constants, read from `astropy` |
| `SelfDualCutoff.selfDual_length_sq_bracket`, `cknHorizon_length_bracket` | theorems | T0, `norm_num` |
| `CosmicString.fStringGmu` | def | T0 — `Gμ/c² = ℓ_P²/(2πα')`, CMP eq. (3.3) at `(p,q) = (1,0)`, unwarped |
| `CosmicString.fStringGmu_le_iff` | theorem | T0, `div_le_iff₀` |
| `CosmicString.fStringGmu_selfDual` | theorem | T0, `field_simp` |
| `CosmicString.planckGmuBound`, `cmsStringResonanceMin_eV` | defs | pinned numbers (Planck XXV l. 53; CMS l. 1048) |
| `CosmicString.regge_window_nonempty` | theorem | T0, `Real.pi_gt_three` + `nlinarith` |
| `CosmicString.selfDual_alphaPrime_exceeds_cms_ceiling` | theorem | T0, `norm_num` |
| `CosmicString.selfDual_Gmu_below_cmp_window` | theorem | T0, `Real.pi_gt_three` + `nlinarith` |
| `DarkEnergyScale.rhoLambda` | def | T0 |
| `DarkEnergyScale.rhoLambda_inv_eq` | theorem | **T3** (DeepSeek-Prover-V2-7B, round 0, kernel-accepted); proof body then shortened by T0 to `unfold; field_simp`, statement unchanged |
| `DarkEnergyScale.selfDual_lambda4_eq` | theorem | **T3** (same), same shortening |
| `DarkEnergyScale.omegaLambda` | def | cited constant (astropy `Planck18.Ode0`) |
| `DarkEnergyScale.darkEnergyLength4_bracket`, `selfDual_lambda_above_mvv_range` | theorems | T0 after T3 failed (2 rounds each), `Real.pi_gt_d2`/`pi_lt_d2` + `nlinarith` |
| `DarkEnergyScale.selfDual_above_torsion_radius_bound` | theorem | T0 after T3 failed (no proof extracted), `norm_num` |

### Correction, 2026-09-18: `CKNBound.lean`'s original equation was dimensionally wrong
While doing P3.3's numeric instantiation, re-reading CKN's eq. (2) with `pdftotext -layout`
(rather than trusting the first, unlayouted extraction from commit `2989a74`) showed the
pilot's original `L³Λ⁴ ≤ M_P²` doesn't type-check dimensionally (`[L³Λ⁴] = GeV`,
`[M_P²] = GeV²`). The actual eq. (2), l. 77–78, is `L³Λ⁴ ≲ L·M_P²`, which — dividing by
`L > 0` — is the standard holographic-dark-energy scaling `L²Λ⁴ ≤ M_P²`. `CKNBound.lean` was
rewritten for the correct exponent; the fix turned out to *simplify* the proofs (no `rpow`
cube/fourth-roots needed — `L²Λ⁴ ≤ M²` is literally `(LΛ²)² ≤ M²`, one `nlinarith` step from
`LΛ² ≤ M`). See that file's own correction note for the full account, including the
citation-transcription-error precedent this matches in a sibling project
(`SocrateAI-DualScaleTopologicalUniverseModel-LeanProposal`, errors E-007/E-010).

Gate G3: `lake build DualScaleCosmology` green, 0 `sorry`/`admit` (source grep);
`tools/axiom_audit.py DualScaleCosmology`: 31 theorems, 0 failing, standard axioms only
(`propext`, `Classical.choice`, `Quot.sound`); full 8-library rebuild
(`DualScaleStream2 StringTheoryFormalization StringTheoryFoundation DualScaleM24Formalization
DoubleFieldTheory DualScaleValidation Lean5Corpus DualScaleCosmology`) green, 3781 jobs — no
regression to Streams 1–2 (axiom audit re-run on all eight libraries: 456 theorems, 0 failing);
`tools/statement_lock.py --update` locked all 44 declarations.

**First real T3 measurement for Stream 3 (P3.8).** Once the Ollama service was restored (§3), the local
prover closed **2 of 5** goals: both pure algebraic identities, round 0, in ~8.5 min wall-clock including
the cold model load; it failed on all three goals needing `π` bounds (compile errors or no proof extracted).
That matches Stream 2's finding (T3 is good on concrete algebra, weak where a specific library lemma is
needed). Its accepted proofs were correct but padded with a long repeated tactic chain — kernel acceptance
does not imply readable proofs, so T3 output should be reviewed and shortened before commit.

**Tiering conclusion so far**: every work package here was small, self-contained algebra or
arithmetic from a single pinned equation or citation — exactly the shape Stream 2 found T2
(Haiku) or T1 (Sonnet) closes, not T3 (local prover) territory (effective only on
concrete/computational goals, per Stream 2 §6). The one genuinely T1-level step was
`hubble_dual`'s differentiation, and even that closed in four lines once the right combinator
(`HasDerivAt.inv`) was confirmed working via the sibling-repo precedent — the rest is
`simp`/`field_simp`/`nlinarith`/`norm_num` shape.

## 6. Roadmap coverage checklist

"Done" = every theorem for the item is committed, sorry-free and axiom-audited — the same
honest-progress convention as Stream 2 §5.1.

| Phase | Item | Status |
|---|---|---|
| P3.1 | scale-factor-duality involution, fixed point, log-oddness, `H → −H`, transferred bound | ✅ closed 2026-09-18 |
| P3.2 | CKN bound (corrected exponent) solved for `L` and for `Λ²` | ✅ closed 2026-09-18 |
| P3.3 | numeric instantiation at CKN's own horizon example vs. the Planck energy | ✅ closed 2026-09-18 — **result: a ≥`10³⁰` gap, not a match**; the CKN route does not support `ℓ_micro ~ ℓ_P` at `ℓ_macro ~ H₀⁻¹` |
| P3.4 | cosmic F-strings: tension relation `Gμ = ℓ_P²/(2πα')` | ✅ closed 2026-09-18 (mechanism moved to P3.9) |
| P3.5 | dual towers behind the swampland distance conjecture | ✅ closed 2026-09-18 — **not an independent third route at the level of algebra**: the same involution as P3.1, under an explicit Tier C model; eq. (2.100) itself deliberately not formalized |
| P3.6 | statement review: do P3.1/P3.2 combine into one micro/macro relation, or are they disjoint? | ✅ closed 2026-09-18 — they combine at the **self-dual length** `√(ℓ_micro ℓ_macro)`, not at `ℓ_micro`; that length is not a Regge slope (P3.7) and is the dark-energy length (P3.8) |
| P3.7 | Regge-slope reading of the self-dual length | ✅ closed 2026-09-18 — **excluded** (CMS, ≥`10³⁰` in `α'`); turns `SelfDualCutoff.lean`'s prose disclaimer into kernel-checked arithmetic |
| P3.8 | what the self-dual length is; the KK / dark-dimension reading | ✅ closed 2026-09-18 — **the dark-energy length** (identity); KK reading disfavored by O(1) only, MVV's λ-suppressed dark dimension live |
| P3.9 | defect-network scaling mechanism; domain walls | ⛔ closed as out of scope 2026-09-18 — simulation results; formalizing their defining formulas would be vacuous (reason in §4) |

**Definition of done (fixed 2026-09-18, before the last work package):** every row above is ✅ (Tier A
theorems committed, zero `sorry`/`admit`/`native_decide`/`axiom`, axiom-audited, statement-locked) or ⛔
(closed as out of scope with the reason written in §4); the eight-library build, the axiom audit of all
eight libraries and the statement lock pass on the release tag; and `docs/VERIFIED_FOUNDATION.md` and
`README.md` state the Stream 3 gate results and headline claims with tier labels. All three hold at `v3.4.0`.

**Conclusion of Stream 3 (the sentence to cite).** *Scale-factor duality and the Cohen–Kaplan–Nelson bound
are formalized from pinned sources, and the dual-tower structure behind the swampland distance conjecture
is the same involution as scale-factor duality. Taken literally — `ℓ_micro ~ ℓ_P` as the UV cutoff at
`ℓ_macro ~ H₀⁻¹` — the hypothesis fails the CKN test by ≥ 10³⁰. Taken as a T-dual pair, `ℓ_P` and `c/H₀`
meet the CKN bound exactly at their self-dual length `√(ℓ_P · c/H₀) ≈ 47 μm`, which is the dark-energy
length up to the factor `(8π/3Ω_Λ)^{1/4}`. That length cannot be the string (Regge) scale — excluded by
≥ 10³⁰ in `α'` — and as the radius of one extra dimension it is disfavored by O(1) factors only, with the
λ-suppressed "dark dimension" of Montero–Vafa–Valenzuela still experimentally live. Every physical
identification used is Tier C.* Not "the dual-scale cosmology hypothesis is formalized", and not "the
hypothesis is false".
