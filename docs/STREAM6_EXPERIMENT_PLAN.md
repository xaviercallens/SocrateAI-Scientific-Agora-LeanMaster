# Stream 6 — Experimental confrontation of the K3 × T² dual-scale hypothesis

**Status (2026-09-18, release `v3.14.0`):** P6.1 and P6.2 done with the T0 owner's sign-off ("P6.1 puis
P6.2"). **Verdict: P1 is excluded by existing data, and the programme's own T-duality leaves no `O(1)`
freedom to rescue it** (§7). Frozen prediction: `docs/STREAM6_PREDICTION_P1.md`, tag `stream6-p1-frozen`.
The freeze was made after the bounds were known (disclosed): a pre-registered record of a retrodiction.

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
`R = s ≈ 47 μm` (the convention `m⁻¹ ~ l` is MVV's, `2205_12293.txt` l. 327).

**Existing data (Tier L, pinned):**
* Eöt-Wash 2020 (`2002_11761.txt` ll. 283–289): any gravitational-strength Yukawa interaction has
  `λ < 38.6 μm` (2σ); the largest extra dimension has toroidal radius `< 30 μm`.
* MVV (`2205_12293.txt` ll. 320–327): heating of old neutron stars gives `l < 44 μm` for one extra
  dimension.

**Pre-freeze assessment (kept as written before the freeze): in tension with both bounds** (`47/30 ≈ 1.6`, `47/44 ≈ 1.07`). Stream 3 records
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

## 5. Phases (P6.1, P6.2 done at `v3.14.0`; P6.3 not applicable since P6.2 gives `κ = 1`)

| Phase | Content | Needs |
|---|---|---|
| P6.1 | Freeze P1 as stated (convention `m⁻¹ ~ R`, `α` of a KK graviton), git tag, then record the verdict against Eöt-Wash 2020 and MVV — expected: **excluded/disfavoured**, and recorded as such | T0 sign-off only |
| P6.2 | Attempt a derivation of `κ`, `α` from the K3 × T² data of Streams 2–3 (Tier A where possible) | new theory work; may end in "not derivable" (F5b) |
| P6.3 | If P6.2 yields numbers: freeze, compare, record | P6.2 |

## 6. Recommendation

Do P6.1 now (it is cheap and honest: it turns "disfavoured by `O(1)`" into a recorded, pre-registered
outcome), and treat P6.2 as a research question with "not derivable" as an acceptable, recorded result.
Do not select conventions to land inside allowed windows.

## 7. Results (`v3.14.0`, `DualScaleCosmology/Stream6Verdict.lean`, Tier A arithmetic on Tier L bounds)

**P6.1 — verdict on P1 (frozen before this computation).** `R = s ≈ 47.0 μm` fails all three
pre-registered tests: T1 (Eöt-Wash toroidal radius `< 30 μm`), T2 (Yukawa range `< 38.6 μm`), T3 (MVV
neutron stars `< 44 μm`) — `p1_fails_T1/T2/T3`. By the pre-registered rule, **P1 is excluded**
(`p1_verdict_excluded`), with margins `R > 1.5 × 30 μm` and `R > 1.06 × 44 μm` (`p1_margin`). Passing T1
would need `R = κ s` with `κ < 0.64` (`p1_factor_needed`) — recorded, not chosen.

**P6.2 — can `κ` be derived?** Within the programme's own T-duality `R ↦ α'/R` with `α' = s²` (the Tier C
dual-scale identification of Stream 3), the self-dual radius is the unique positive fixed point `R = s`
(`p62_selfdual_fixed_point`), where the KK and winding scales coincide (`p62_towers_coincide`). With the
standard KK normalisation `m_n = n/R`, this gives **`κ = 1`**: P1 is the programme's prediction, not one
convention among several. Taking both circles of `T²` large (two extra dimensions) is worse: MVV's
`l < 1.6 × 10⁻⁴ μm` is missed by more than `10⁵` (`p62_two_dims_excluded`).

**Conclusion.** The one experimental prediction of the K3 × T² dual-scale programme — its self-dual length
as the radius of a large extra dimension — is excluded by Eöt-Wash 2020 and disfavoured by neutron-star
heating, and the programme's T-duality fixes the `O(1)` factor that could have rescued it. Together with
Stream 3's CKN result, **the dual-scale hypothesis as an extra-dimension or UV/IR statement does not
survive the existing data.** What survives is mathematics (Streams 1, 2, 4, 5), whose results are Tier A
and independent of this verdict. A new hypothesis would need a new, independently derived observable,
frozen before any comparison (P1′), not a re-tuning of P1.
