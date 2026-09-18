# Stream 5 Workflow — Dyons on K3 × T²: from the K3 elliptic genus to single-centred black holes

**Status (2026-09-18, release `v3.13.1`):** P5.1–P5.7 closed (Tier A, 44 theorems, 0 failing,
`propext` or no axiom; locked in 5 files). No open phase; next directions in §10. Library `DualScaleDyons` (separate `lean_lib`, imports
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
| **P5.6 Higher `m`, twining test** | `m = 2, 3`: DMZ (9.11), (9.13) checked; immortal counting functions `= p₂₄(m+1)(−H|V_m) +` weak Jacobi forms; the twining test on `24` and the Göttsche numbers: traces on `H*(Hilbᵏ K3)`, `k ≤ 4`, are `M₂₄`-characters; Frame shapes vs power maps | DMZ (9.11)–(9.13); CDH Table 8 (power maps), Table 14 (Frame shapes) | ✅ `ImmortalHigher.lean`, `TwinedHilbert.lean` |
| **P5.7 Twisted dyons** | Cheng's twisted denominators `1/Φ_g` for all 26 classes from Stream 4's twisted genera and CDH's power maps; coefficients (including the twisted single-centred counts at `m = 1`) are virtual `M₂₄`-characters; Stream 4's levels 8–9 closed (CDH Table 48) | Cheng 1005.5415 (2.5)–(2.9), (3.9)–(3.11), ll. 533–549; CDH Table 48 | ✅ `TwistedDyons.lean`, `DualScaleMoonshine/Decompositions.lean` |

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
  the double pole of `ψ_m` — with exactly that coefficient (`m = 1, 2, 3`). (The second-order condition
  is automatic by `y ↔ y⁻¹` symmetry; the discriminating content is the first-order one. The full
  second-order content, exact division by `A`, is `immortal_m1_exact` at `m = 1`.)
* **The single-centred ("immortal") dyons at `m = 1`**: `∆ψ₁^F = 3E₄A − 648H` through `q³`, with `H` the
  Hurwitz class numbers counted from reduced binary quadratic forms (`immortal_m1`); dropping `H` fails.
  DMZ's printed tables of Example 5 are reproduced from our series (`example5_tables`).

Again the number 24 is structural: it is `χ(K3)`, it sets the 24 colours of `p₂₄`, and `p₂₄(m+1)` is the
multiplicity of the two-centred (wall-crossing) sector. Reading the two-centred/single-centred split as
the programme's "macro/micro" structure is Tier C.

## 7. Gates at `v3.11.1`
Ten-library build 3795 jobs, 0 errors. `tools/axiom_audit.py DualScaleDyons`: 18 theorems, 0 failing
(`propext` or no axiom at all). Repository total 573 theorems, 0 failing. Statement lock: 50
declarations in 2 files (`v3.11.1` added `negBinomPairs`, `negBinom_exact`: the integer divisions in the
product are exact; the pre-update check showed exactly these two ADDED). Heavy theorems use `decide +kernel`; the library checks in about 4 minutes.

## 8. Results at `v3.12.0` (P5.6)
* **Immortal dyons at `m = 2, 3`** (through `q²`): `3∆ψ₂^F = −800·(12H|V₂) + 22E₄AB − 10E₆A²` and
  `48∆ψ₃^F = −102600·(12H|V₃) + 467E₄AB² − 430E₆A²B + 203E₄²A³`, with `12(H|V_p)` having coefficients
  `12H(∆) + p·12H(∆/p²)`. DMZ's (9.11) and (9.13) at `m = 2, 3` are checked directly, and their printed
  tables reproduced. Dropping the Hecke correction breaks `m = 2`.
* **The twining test on the dyon sector's integers.** CDH's Frame shapes have degree 24, fixed points
  `χ_g`, and agree with the power maps for `p = 2, 3, 5, 7, 11, 23`. The twined Göttsche numbers
  `Tr(g | H*(Hilbᵏ K3))` decompose, for `k ≤ 4`, with non-negative integer multiplicities
  (`H*(Hilb² K3) = 3·1 ⊕ 3·23 ⊕ 252`). These integers pass the test paper 7's 27720 lock failed; the
  result is mathematically expected (symmetric powers of a permutation module), and its value is the
  certified cross-check of three transcribed tables and the contrast with the lock.

## 9. Gates at `v3.12.0`
Ten-library build 3797 jobs, 0 errors. `DualScaleDyons`: 32 theorems, 0 failing. Repository total 587.
Statement lock: 74 declarations in 4 files (pre-update check: only `ImmortalHigher.lean` and
`TwinedHilbert.lean` new).

## 10. Results at `v3.13.0` (P5.7) and what next
* **Twisted genera.** `Z_g = (χ_g/24)Z − F_g·A` for all 26 classes, integral, index 1 (`c_g` depends only on
  `4n − l²`), `Z_g(τ,0) = χ_g`. (Cheng prints `c_g(−1) = −2` at l. 968; in the normalisation used here and
  in his own (2.5), the coefficient of `y^{±1}q⁰` is `+2`; checked for all 26 classes in `TwistedNotes.lean`
  (`c_minus_one`, `twisted_genus_q0`), so the printed `−2` is a sign convention or misprint.)
* **Twisted dyon partition functions.** Cheng's (3.10) by Newton's identities (exact divisions checked):
  `g = 1A` recovers `dmvv`; at `z = 0` the `p`-coefficients are the twined Göttsche numbers (the `p`-side
  of Cheng's factorisation (3.11)); every coefficient of `G₁^{(g)}, G₂^{(g)}` through `q²` is a virtual
  character; for all 26 classes `T₂(g)·A₂,₁` removes the double pole, and the twisted single-centred
  counting function at `m = 1` has virtual-character coefficients (`−1800 = 2·1 + 2·23 + 2·45 + 2·4̅5̅ −
  231 − 2̅3̅1̅ + 2·252 − 1035′ − 1035″`). Expected once the twisted genera are characters (Gannon); the
  content is the certified end-to-end computation.
* **Stream 4 closed at levels 8–9.** From the computed twined series, `K₀ … K₉` decompose with integer
  multiplicities, equal to CDH Table 48; EOT's original level-7 proposal is inconsistent (Cheng).

**Possible next directions** (not started): higher `m` and `q` for the twisted immortal counts (cost grows
quickly); the Siegel-modular properties of `Φ₁₀` (would need analytic Siegel forms, not in Mathlib);
formalising the Niemeier lattices that would reopen Stream 4's reflection question.
