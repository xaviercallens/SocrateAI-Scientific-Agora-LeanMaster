# Stream 6 — Experimental confrontation of the K3 × T² dual-scale hypothesis (plan, awaiting sign-off)

**Status (2026-09-18):** PLAN ONLY. Nothing is frozen, no data has been fetched for this stream. The
freeze of any prediction (§3) requires the T0 owner's sign-off, as in the Home repository's
pre-registration protocol (`SocrateAI-Scientific-Agora-Home/PREDICTION.md`, `NO_PREDICTION_BRANCH.md`).

## 1. What experiment can and cannot do here

An experiment cannot be asked to *confirm* a hypothesis. It can only test a prediction that was fixed
before the data were looked at and that could have come out wrong. A prediction chosen after seeing the
data (for instance an `O(1)` convention picked so that a number falls inside an allowed window) is not a
test. This stream is designed so that every outcome — support, tension, exclusion — is recorded.

## 2. Inventory: which results of Streams 1–5 are observables?

| Stream | Result | Observable? |
|---|---|---|
| 1–2 | lattices, `O(d,d;ℤ)`, DFT, the dual-scale bound, flux/tadpole arithmetic | **no** — mathematical structure; no number with units |
| 3 | literal hypothesis vs CKN | already **refuted** (by `≥ 10³⁰` in `α'`), Tier A arithmetic on Tier L inputs |
| 3 | self-dual length `s = √(ℓ_P c/H₀) ≈ 47 μm` = dark-energy length up to `(8π/3Ω_Λ)^{1/4}` (an identity) | **yes**, if identified with the radius `R` of one large extra dimension (Tier C identification) |
| 4 | Mathieu/umbral moonshine computed; HMN bridge | **no** — properties of BPS counting in `N = 4` string theory, not of our universe |
| 5 | dyons on K3 × T²: two-centred vs single-centred, class numbers, `M₂₄` twining | **no** — same (`N = 4`, `d = 4` compactification; not a model of our universe) |

So the programme has exactly **one** candidate observable, and it comes with a Tier C identification.

## 3. The one testable prediction and the data that already exist

**Prediction P1 (candidate for freezing).** One large extra dimension with KK tower scale `m ~ 1/R` and
`R = s ≈ 47 μm` (the convention `m⁻¹ ~ l` is MVV's, `2205_12293.txt` l. 320).

**Existing data (Tier L, pinned):**
* Eöt-Wash 2020 (`2002_11761.txt` ll. 283–289): any gravitational-strength Yukawa interaction has
  `λ < 38.6 μm` (2σ); the largest extra dimension has toroidal radius `< 30 μm`.
* MVV (`2205_12293.txt` ll. 320–327): heating of old neutron stars gives `l < 44 μm` for one extra
  dimension.

**Verdict on P1 as stated: in tension with both bounds** (`47/30 ≈ 1.6`, `47/44 ≈ 1.07`). Stream 3 records
this as "disfavored by `O(1)`" because the identification `R ↔ s` carries an unfixed `O(1)` factor
(`2π`, the Yukawa strength `α`, the number of extra dimensions). That factor must be fixed **from the
theory**, not chosen now — with `R = s/2π ≈ 7.5 μm` the number would fall inside MVV's window
`0.1–10 μm` (ll. 424–427), and choosing that convention after reading the bounds would be exactly the
post-hoc fit the protocol forbids.

## 4. What a real test would need (the honest gap)

1. **A derivation of the `O(1)` identification** `R = κ·s` from the K3 × T² construction (which cycle, which
   normalisation, the Yukawa coupling `α` of the lightest KK mode). This is the same missing ingredient the
   Home repository recorded in `NO_PREDICTION_BRANCH.md` (F5b): physical coefficients need an explicit
   compactification (fluxes, brane wrapping, moduli stabilisation) that does not exist yet.
2. **A freeze** of `κ` and `α` (git tag, T0 sign-off) before comparing with data.
3. **The comparison**, done mechanically against the pinned bounds, with the outcome recorded whatever it is.
   Kernel-checked arithmetic is available (Stream 3's `DarkEnergyScale.lean` style).

Without (1), Stream 6 ends in the Home repository's F5b branch: **no pre-registerable prediction beyond
P1, and P1 is already disfavoured by existing data.**

## 5. Proposed phases (not started)

| Phase | Content | Needs |
|---|---|---|
| P6.1 | Freeze P1 as stated (convention `m⁻¹ ~ R`, `α` of a KK graviton), git tag, then record the verdict against Eöt-Wash 2020 and MVV — expected: **excluded/disfavoured**, and recorded as such | T0 sign-off only |
| P6.2 | Attempt a derivation of `κ`, `α` from the K3 × T² data of Streams 2–3 (Tier A where possible) | new theory work; may end in "not derivable" (F5b) |
| P6.3 | If P6.2 yields numbers: freeze, compare, record | P6.2 |

## 6. Recommendation

Do P6.1 now (it is cheap and honest: it turns "disfavoured by `O(1)`" into a recorded, pre-registered
outcome), and treat P6.2 as a research question with "not derivable" as an acceptable, recorded result.
Do not select conventions to land inside allowed windows.
