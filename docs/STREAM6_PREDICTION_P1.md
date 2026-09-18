# Stream 6 · P1 — frozen prediction (git tag `stream6-p1-frozen`)

**Frozen:** 2026-09-18, with the T0 owner's sign-off ("P6.1 puis P6.2"). Any change after the tag is a new
prediction (P1′), not an edit of this one.

**Disclosure.** The experimental bounds used below (Eöt-Wash 2020, MVV) were already read by the authors
of this document before the freeze (Stream 3, P3.8). This is therefore a **pre-registered record of a
retrodiction**, not a blind test: its purpose is to fix, once and for all, what the programme's one
observable prediction says and what the existing data say about it, so that no convention can later be
adjusted to move the number.

## Statement

**P1.** The K3 × T² dual-scale programme's micro and macro lengths `ℓ_micro = ℓ_P`, `ℓ_macro = c/H₀` (a
T-dual pair, Stream 3 P3.6, Tier C identification) define the self-dual length
`s = √(ℓ_P · c/H₀)`. P1 identifies `s` with the radius `R` of **one** large extra dimension, with the
KK-tower convention `m ~ 1/R` (MVV's `m⁻¹ ~ l`, `2205_12293.txt` l. 320), `R = s`, no additional factor.

**Inputs (fixed):** `ℓ_P = 1.616255 × 10⁻³⁵ m` (CODATA 2018), `c/H₀ = 1.3672 × 10²⁶ m`
(`H₀ = 67.66 km/s/Mpc`, Planck 2018 VI), as in `DualScaleCosmology/SelfDualCutoff.lean`. Hence
`s ≈ 47.0 μm` (`s² ≈ 2.2097 × 10⁻⁹ m²`).

## Tests and decision rules (fixed before the verdict is computed)

| Test | Bound (Tier L, pinned) | P1 passes iff |
|---|---|---|
| T1 laboratory, extra-dimension radius | Eöt-Wash 2020, `2002_11761.txt` ll. 285–289: "the largest extra dimension must have a toroidal radius less than 30 μm" | `R < 30 μm` |
| T2 laboratory, Yukawa range | same, ll. 283–285: any gravitational-strength Yukawa interaction has `λ < 38.6 μm` (2σ) | `R < 38.6 μm` (with `λ = R` for the lowest KK mode — Tier C) |
| T3 astrophysics | MVV `2205_12293.txt` ll. 320–327: heating of old neutron stars, one extra dimension, `l < 44 μm` | `R < 44 μm` |

**Outcome categories:** *consistent* if all three pass; *excluded* if T1 fails (the tightest, directly stated
radius bound); *in tension* if T1 passes but T2 or T3 fails.

The verdict is computed by kernel-checked arithmetic in `DualScaleCosmology/Stream6Verdict.lean` after
this tag, and recorded in `docs/STREAM6_EXPERIMENT_PLAN.md` whatever it is.
