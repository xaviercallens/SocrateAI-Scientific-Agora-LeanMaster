# Stream 5 Workflow — Dyons on K3 × T²: from the K3 elliptic genus to single-centred black holes

**Status (2026-09-18, release `v3.11.0`):** P5.1–P5.5 closed (Tier A, 17 theorems, 0 failing,
`propext` only; 48 declarations locked in 2 files); P5.6 open. Library `DualScaleDyons` (separate `lean_lib`, imports
`DualScaleMoonshine` for its exact `q`-series with Laurent-polynomial coefficients). Rules are those of
Streams 2–4: the kernel is the only accept gate; no citation from memory; ASCII identifiers; every
printed number that is used is pinned to a file and line range.

## 1. Why this stream exists

Stream 4 ended with a precise version of the "micro/macro" intuition that motivated the programme: a
mock modular form is a "micro" sector (bound states) that becomes modular only together with a
"macro" sector (a continuum), and for K3 the coupling is fixed by topology (`24 = χ(K3)`, which also
passes the twining test). The setting where this split has the clearest physical meaning **is
K3 × T² itself**: quarter-BPS dyons of type II string theory on K3 × T², counted by `1/Φ₁₀`
(Dabholkar–Murthy–Zagier, DMZ, `papers/foundations/1208_4074.txt`). There the Fourier–Jacobi
coefficients `ψ_m` split canonically into

* a **polar part** `ψ_m^P = p₂₄(m+1)/Δ · A₂,ₘ` counting **two-centred** bound states, which appear and
  disappear across walls of marginal stability (wall-crossing), and
* a **finite part** `ψ_m^F`, a mock Jacobi form counting **single-centred ("immortal") black holes**.

`Φ₁₀` is itself a Borcherds product whose input is the K3 elliptic genus `2φ₀,₁` computed in
`DualScaleMoonshine/Shadow.lean`. So this stream continues Stream 4 inside the programme's own
geometry. What it does **not** do: say anything about cosmological scales, or rescue the literal
dual-scale hypothesis `R ↔ α'/R` (refuted in Stream 3). Any reading in those terms is Tier C.

## 2. Phases

| Phase | Content | Sources | Status |
|---|---|---|---|
| **P5.1 Pin sources** | DMZ 1208.4074 (sha256 in `MANIFEST.md`) | DMZ | ✅ |
| **P5.2 DMVV / Göttsche** | the product `Π_{r≥1,s≥0,t}(1 − p^r q^s y^t)^{−c(4rs−t²)}` with `c` the coefficients of **our computed** `Z_K3`: coefficient of `p^k` is `χ(Sym^k K3; τ, z)`; at `z = 0` it is `p₂₄(k) = 1, 24, 324, 3200, 25650, 176256` (Göttsche), constant in `τ`; `c` depends only on `4n − l²` (index-1 Jacobi property, checked); reachability guard: the `c(D)` needed are all available | DMZ (4.52), (5.13)–(5.15), l. 1070 (`p₂₄`), l. 3639 (`p₂₄(3) = 3200`) | ✅ `DMVV.lean` |
| **P5.3 DMZ (5.16)** | the six printed identities `∆ψ₋₁ = A⁻¹`, …, `72∆ψ₄ = 51A⁻¹B⁵ + …` hold, with `A = φ₋₂,₁`, `B = φ₀,₁` from theta products and `E₄`, `E₆` from divisor sums | DMZ (5.16)–(5.17), ll. 1880–1900 | ✅ `DMVV.lean` (`dmz_516_q1`, `dmz_516_q2`) |
| **P5.4 Polar part** | the double pole of `ψ_m` at `z = 0` is removed by `p₂₄(m+1)·A₂,ₘ` and by no other multiple (`m = 1, 2, 3`); the Fourier expansion of `A₂,ₘ` in the strip `|q| < |y| < 1` equals DMZ (9.55) | DMZ (1.2)–(1.4), (9.4), (9.55), ll. 196–213, 3655–3700, 5199–5210 | ✅ `DMVV.lean` |
| **P5.5 Immortal dyons, `m = 1`** | the single-centred counting function `∆ψ₁^F = ∆ψ₁ − 324·A₂,₁` equals `3E₄A − 648·H`, with `H` the generating function of Hurwitz class numbers, computed independently by counting reduced binary quadratic forms; DMZ's printed tables of Example 5 as transcription control | DMZ Example 5 (ll. 3530–3558), (9.8), (9.10) | ✅ `Immortal.lean` |
| P5.6 Further | `m = 2` (`Φ₂,₂^opt = −H|V₂`, (9.11)); twined dyon counting (CHL); the twining test on any integer coincidence found here | DMZ §9.2 | ⬜ open |

## 3. Reading notes (recorded, not corrections)
* DMZ (1.4), l. 211, as printed, lists the terms `ℓ q^{(r²−ℓ²)/4m} y^r` with `r ≥ ℓ > 0` for the strip
  `0 < Im z < Im τ`. The direct expansion of (1.3) in that strip, and DMZ's own general formula (9.55),
  also contain the mirror terms `ℓ q^{(r²−ℓ²)/4m} y^{−r}` with `r > ℓ > 0` (from `s ≤ −1`). The
  formalization uses (9.55).
* The strip matters: `A₂,ₘ` has different Fourier expansions in different strips (wall-crossing); every
  statement about the polar part names the strip `|q| < |y| < 1`. The finite part does not depend on it.

## 4. Tier discipline
Tier A: the finite identities above, through the orders stated in each theorem. Tier L: that `1/Φ₁₀`
counts quarter-BPS dyons, that `ψ_m^P` counts two-centred and `ψ_m^F` single-centred configurations, the
mock modularity of `ψ_m^F` and its completion (DMZ (1.7)). Tier C: any reading of the polar/finite split
as the programme's "macro/micro" or "dual-scale" structure.

## 5. Definition of done
Every row ✅ with Tier A theorems (no `sorry`/`admit`/`native_decide`/`axiom`, audited, locked) or ⛔ with
a written reason; nine+1-library build, axiom audit and statement lock pass on the release tag;
`VERIFIED_FOUNDATION.md` and `README.md` updated with tiers.

## 6. Results at `v3.11.0`
From the K3 elliptic genus of Stream 4 alone (no transcribed coefficient enters the computation):

* `1/Φ₁₀` through the Borcherds/DMVV product; `Z_K3`'s coefficients depend only on `4n − l²`; every
  coefficient the truncated products read is available (`dmvv_reachable`, with a failing example).
* `χ(Hilb^k K3) = p₂₄(k) = 1, 24, 324, 3200, 25650, 176256` (`goettsche`), constant in `τ`.
* DMZ's six printed identities (5.16) (`dmz_516_q1`, `dmz_516_q2`): the product and the additive formulas
  in `A = φ₋₂,₁`, `B = φ₀,₁`, `E₄`, `E₆` agree.
* The two-centred part `p₂₄(m+1)·A₂,ₘ`, expanded in the strip `|q| < |y| < 1` (equal to (9.55)), removes
  the double pole of `ψ_m` — with exactly that coefficient (`m = 1, 2, 3`).
* **The single-centred ("immortal") dyons at `m = 1`**: `∆ψ₁^F = 3E₄A − 648H` through `q³`, with `H` the
  Hurwitz class numbers counted from reduced binary quadratic forms (`immortal_m1`); dropping `H` fails.
  DMZ's printed tables of Example 5 are reproduced from our series (`example5_tables`).

Again the number 24 is structural: it is `χ(K3)`, it sets the 24 colours of `p₂₄`, and `p₂₄(m+1)` is the
multiplicity of the two-centred (wall-crossing) sector. Reading the two-centred/single-centred split as
the programme's "macro/micro" structure is Tier C.

## 7. Gates at `v3.11.0`
Ten-library build 3795 jobs, 0 errors. `tools/axiom_audit.py DualScaleDyons`: 17 theorems, 0 failing
(`propext` or no axiom at all). Repository total 572 theorems, 0 failing. Statement lock: 48
declarations in 2 files. Heavy theorems use `decide +kernel`; the library checks in about 4 minutes.
