# Stream 7 — Can the programme derive a second observable? (inventory before any new hypothesis)

**Status (2026-09-18, release `v3.15.0`):** the T0 owner chose "C-A puis C-B". **C-A: frozen
(`docs/STREAM7_PREDICTION_CA.md`, tag `stream7-ca-frozen`), derived and excluded** (§6). **C-B: frozen
(`docs/STREAM7_PREDICTION_CB.md`, tag `stream7-cb-frozen`) before any sensitivity was pinned; verdict: not
falsifiable in practice** (§7).

## 1. The question, and why it comes first

Stream 6 showed (P6.2) that the programme's T-duality fixes the one free `O(1)` factor of P1, and that P1 is
excluded. A new hypothesis must come with a new observable, **derived** from the programme — not chosen —
and frozen before comparison. The Home repository already recorded (`NO_PREDICTION_BRANCH.md`, F5b) that
physical coefficients of a string model need an explicit compactification (flux quanta, brane wrapping,
moduli stabilisation) that has never been constructed for this geometry. So the first question is:

> What in Streams 1–5 yields a number **with units**, by a derivation that does **not** pass through an
> unconstructed compactification?

## 2. Inventory

| Stream | Output | Number with units? | Derivable without a compactification? |
|---|---|---|---|
| 1–2 | lattices, `O(d,d;ℤ)`, DFT, dual-scale bound, flux/tadpole arithmetic | no | — |
| 3 | self-dual length `s = √(ℓ_P c/H₀)` | yes (≈ 47 μm) | yes — **P1, excluded** (Stream 6) |
| 3 | CKN saturation `L³Λ⁴ ~ L M_P²` at the self-dual length (`SelfDualCutoff`) | yes, if the IR length is allowed to follow `H(t)` | yes, given a Tier C identification (candidate C-A below) |
| 3 | cosmic F-string tension from `α' = s²` (`CosmicString`) | yes (`Gμ`) | yes (candidate C-C) |
| 3 | scale-factor duality `a ↔ 1/a` (`ScaleFactorDuality`) | only with dynamics (dilaton gravity) | only with literature not yet pinned (candidate C-B) |
| 4–5 | moonshine, HMN, dyons: `24`, `p₂₄`, class numbers, `M₂₄` characters | **no** — dimensionless, and properties of `N = 4` string theory, not of our universe | — |

## 3. Candidates (derivations only; no comparison made here)

For each: inputs **measured** (M), **derived in Lean** (D), **assumed** (A). A non-empty (A) makes the
prediction Tier C, stated as such.

**C-A. Holographic saturation with the programme's macro length.** Assume (A) that the vacuum energy
saturates the CKN bound at all times with the programme's macro length `ℓ_macro = c/H(t)` as IR length, so
`ρ_Λ(t) = ε · 3H(t)²/(8πG)` with `ε` constant, and matter is separately conserved (A). Then (D, elementary
Friedmann algebra to be formalised) `Ω_Λ` is constant, `ρ_m ∝ H²` as well, and the dark component redshifts
like matter: effective `w = 0`, deceleration parameter `q = 1/2 > 0` — **no present acceleration**, with no
free parameter. Inputs: (M) none beyond the existence of `H(t)`; (A) two identifications. **Disclosure:**
the authors know this outcome is the classic objection to Hubble-scale holographic dark energy and know that
cosmic acceleration is observed; a comparison would be a retrodiction with a foreseeable result.

**C-B. Scale-factor duality as cosmological dynamics (pre-big-bang).** Assume (A) that the programme's
`a ↔ 1/a` duality is realised dynamically by the low-energy string effective action (dilaton gravity). The
literature then predicts a blue-tilted relic gravitational-wave spectrum whose low-frequency slope is fixed
while its amplitude and peak frequency depend on unfixed parameters (duration of the dilaton phase, string
scale). Status: **not yet derivable here** — the slope must be pinned to a source (a pre-big-bang review in
`papers/foundations/`) and the parameters are free, so only a conditional test ("if the band lies below the
peak, then the slope is …") is available. Falsifiability: weak unless the programme fixes the parameters,
which it cannot today.

**C-C. Cosmic F-strings at `α' = s²`.** (D) `Gμ = ℓ_P²/(2π α') = ℓ_P H₀/(2π c) ~ 10⁻⁶²`. Inputs (M): `ℓ_P`,
`H₀`; (A): the dual-scale identification of `α'`. **Not falsifiable in practice**: many orders of magnitude
below any foreseeable sensitivity (already recorded in Stream 3, `selfDual_Gmu_below_cmp_window`). A
prediction that no experiment can reach is not a test.

## 4. Assessment

* **No candidate gives a clean, blind, falsifiable test today.** C-A is parameter-free but its comparison
  is a foreseeable retrodiction; C-B has free parameters and unpinned sources; C-C is out of reach.
* The honest reading is the Home repository's F5b branch extended to Stream 7: **without an explicit
  compactification, the programme cannot derive a second observable that is both new and testable.**
* What would change this: an explicit construction (flux quanta, moduli stabilisation) for a K3-based
  compactification with a chiral spectrum — note that K3 × T² itself gives `N = 4` in four dimensions,
  with no chiral matter, so it cannot be our universe as it stands (Tier L, standard); a realistic model
  would need a different geometry (e.g. a K3-fibred Calabi–Yau threefold), which is new research.

## 5. Options for the T0 owner

1. **Freeze C-A** (P1′), formalise its Friedmann algebra in Lean, and record the (disclosed, foreseeable)
   verdict — cheap, honest, closes the Hubble-scale holographic reading explicitly.
2. **Develop C-B**: pin a pre-big-bang source, derive the conditional slope prediction, freeze it as a
   *forward* prediction for future spectral measurements (LISA/PTA), with its conditions stated.
3. **Record F5b for Stream 7** and redirect effort to a new geometry (K3-fibred threefold) — research-level.

## 6. Result for C-A (`v3.15.0`, `DualScaleCosmology/Stream7CA.lean`)

Derivation (Tier A given the Tier C assumptions A1–A2): CKN saturation with infrared length `c/H` and
conserved matter force `ρ_m = (1 − ε)H²/k` (`ca_matter_fraction`), hence `H² = C/a³` (`ca_hubble_scaling`),
hence the deceleration parameter is `q = 1/2` at every epoch and for every `ε` (`ca_deceleration`) — a
parameter-free prediction of no acceleration. Verdict: with Planck 2018's `Ω_Λ = 0.68885` (flat ΛCDM),
`q₀ = Ω_m/2 − Ω_Λ < 0` (`ca_verdict_excluded`): **C-A is excluded** by the pre-registered rule. As disclosed
in advance, this is a retrodiction with a foreseeable outcome, and the input `q₀` is model-dependent.
Together with Stream 6, both the extra-dimension reading and the Hubble-scale holographic reading of the
dual-scale idea are now closed by recorded, kernel-checked verdicts.

## 7. Result for C-B (`v3.16.0`, `DualScaleCosmology/Stream7CB.lean`)

Frozen before any detector document was pinned. With the programme's own string scale (`α' = s²`, so
`g₁² = ℓ_P H₀/c ∈ [1.1, 1.3] × 10⁻⁶¹`, `cb_g1_sq_bracket`), the pre-big-bang relic spectrum (slope `ω³` in the
dilaton phase, `cb_slope`) ends at `ω₁ ≈ 6 × 10⁻⁵ Hz`, below LISA's stochastic band `f > 0.1 mHz`
(`cb_peak_below_lisa_band`), and peaks at `Ω ≃ 10⁻⁶⁵`, more than fifty orders of magnitude below LISA's best
`≈ 6.5 × 10⁻¹³` (`1702_00786.txt` ll. 692–699; `cb_peak_amplitude_unreachable`). By rule TB: **not falsifiable
in practice** (`cb_not_testable`) — neither confirmed nor excluded by that rule.

**Stronger, recorded separately (`v3.16.1`).** C-B's premise (B2) — `α' = s²` as the string's Regge slope, i.e.
string resonances at `ħc/s ≈ 4 meV` — was already **excluded** in Stream 3 (P3.7: CMS excludes such resonances
below 7.9 TeV, by `≥ 10³⁰` in `α'`). The same applies to C-C, which uses the same `α'`. So C-B and C-C fail at the
level of their assumption, not only for lack of sensitivity.

## 8. Where Stream 7 leaves the hypothesis

Every observable the programme can derive without an unconstructed compactification has now been frozen
and confronted: P1 (extra dimension) and C-A (holographic dark energy) are **excluded**; C-B (relic gravitons)
and C-C (cosmic F-strings) are **out of reach**, and their shared premise (a meV string scale) is itself excluded
by Stream 3's P3.7.
The common cause is the dual-scale identification `α' = ℓ_P · c/H₀` itself: it either conflicts with data or
pushes every stringy signal below any conceivable sensitivity. A new hypothesis worth testing would have to
drop or replace that identification — and, for a realistic universe, use a geometry with a chiral spectrum
(K3 × T² gives `N = 4` in four dimensions). That is new research, recorded here as the open direction.
