# Stream 7 · C-A — frozen prediction (git tag `stream7-ca-frozen`)

**Frozen:** 2026-09-18, with the T0 owner's sign-off ("C-A puis C-B"). Any change after the tag is a new
prediction, not an edit of this one.

**Disclosure.** The authors know, before this freeze, that (i) Hubble-scale holographic dark energy is
classically objected to because it does not accelerate, and (ii) the present expansion is observed to
accelerate. This is therefore a **pre-registered record of a retrodiction with a foreseeable outcome**. Its
purpose is to close the Hubble-scale holographic reading of the programme explicitly, with the derivation
kernel-checked, rather than leave it as an informal remark.

## Statement (C-A)

Assumptions (Tier C, both stated):
* (A1) The vacuum energy saturates the Cohen–Kaplan–Nelson bound at all times with the programme's macro
  length as infrared length, `ℓ_macro = c/H(t)` (Stream 3, `SelfDualCutoff.ckn_iff_uvLength_ge_selfDual`):
  `ρ_Λ(t) = ε · 3H(t)²/(8πG)` with a constant `0 < ε < 1`.
* (A2) Flat Friedmann–Lemaître–Robertson–Walker expansion, `H² = (8πG/3)(ρ_m + ρ_Λ)`, with pressureless
  matter separately conserved, `ρ_m ∝ a⁻³` (radiation neglected at late times).

Derivation (to be kernel-checked in `DualScaleCosmology/Stream7CA.lean`): from (A1)–(A2),
`ρ_m = (1 − ε) · 3H²/(8πG)`, so `H(a)² = C/a³` for a constant `C > 0`, and the deceleration parameter
`q = −1 − d ln H / d ln a` equals **`q = +1/2` at all times, for every `ε`** (no free parameter).

**Observable:** the sign of the present deceleration parameter `q₀`.

## Test and decision rule (fixed before the verdict)

| Test | Data (Tier L) | C-A passes iff |
|---|---|---|
| TA | Present acceleration as inferred from Planck 2018 (flat ΛCDM, `Ω_Λ = 0.68885`, the value already used in `DualScaleCosmology/DarkEnergyScale.lean`): `q₀ = Ω_m/2 − Ω_Λ` with `Ω_m ≈ 1 − Ω_Λ` | `q₀ ≥ 0` |

**Outcome categories:** *consistent* if TA passes; *excluded* if it fails. Caveat recorded in advance: the
input `q₀` is model-dependent (a ΛCDM fit); the qualitative fact tested — that the expansion accelerates
today — does not rest on ΛCDM alone, but no model-independent source is pinned in `papers/foundations/`
for this freeze, so the verdict will be stated against the ΛCDM-derived value.
