# Stream 7 · C-B — frozen prediction (git tag `stream7-cb-frozen`)

**Frozen:** 2026-09-18, with the T0 owner's sign-off ("C-A puis C-B"), **before** any detector sensitivity
was pinned or compared. Any change after the tag is a new prediction.

**Disclosure.** The authors have general knowledge of gravitational-wave detector sensitivities (no
document of that kind is pinned in `papers/foundations/` at the time of the freeze). The derivation below
uses only the pre-big-bang review (pinned) and the programme's own inputs; no detector number enters it.

## Statement (C-B)

Assumptions (Tier C, stated):
* (B1) The programme's scale-factor duality `a ↔ 1/a` (`DualScaleCosmology/ScaleFactorDuality.lean`) is
  realised dynamically as a pre-big-bang phase of the low-energy string effective action, followed by a
  high-curvature string phase and the transition to radiation at `t₁`.
* (B2) The programme's dual-scale identification fixes the string scale: `α' = s² = ℓ_P · c/H₀`
  (Stream 3), so `M_s ~ 1/√α'` and the transition curvature `g₁ = H₁/M_P ≃ M_s/M_P = ℓ_P/s`.

Tier L formulas (Gasperini–Veneziano, `gasperini_veneziano_pbb_hep-th_0207130.txt`): `Ω(ω) ∼ ω^{3−2ν}`,
`ν = |α − 1/2|` for `a = |η|^α` (Table 2, (4.105), ll. 4467–4485); the dilaton-driven phase has `α = 1/2`,
hence `Ω ∼ ω³` (l. 4505) in the low-frequency band `ω < ω_s` ((5.15), ll. 5040–5053, modulo logarithms);
end point `ω₁ ≃ g₁^{1/2} · 10¹¹ Hz`, `Ω(ω₁) ≃ 10⁻⁴ g₁²` with `g₁ ≃ M_s/M_P` ((5.16), ll. 5056–5058).

**Derived prediction (inputs: `ℓ_P` CODATA 2018, `c/H₀` Planck 2018, as in `SelfDualCutoff.lean`):**
* `g₁² = ℓ_P H₀/c ≈ 1.18 × 10⁻⁶¹` (`g₁ ≈ 3.4 × 10⁻³¹`);
* peak frequency `ω₁ ≈ 6 × 10⁻⁵ Hz` (no relic gravitons above it);
* peak amplitude `Ω_GW(ω₁) ≈ 1.2 × 10⁻⁶⁵`; below the break `ω_s ≤ ω₁`, `Ω_GW ∝ ω³` and smaller still.
The only free element is the break position `ω_s`, which can only lower the spectrum below `ω₁`.

## Test and decision rule (fixed before any sensitivity is pinned)

**TB.** Let `Ω_det` be the best design sensitivity to a stochastic background of the most sensitive
detector for which a design document is pinned **after** this freeze (intended: the LISA mission
proposal), in its most sensitive band. Then:
* *testable* iff the predicted `Ω_GW` in that band reaches `Ω_det`;
* if not testable, the prediction is recorded as **not falsifiable in practice** (neither confirmed nor
  excluded), which by the programme's own rules is not a test.

Everything about the relic spectrum's shape (the `ω³` slope) is Tier L; `g₁` and the numbers are Tier A
arithmetic on (B2), which is Tier C.
