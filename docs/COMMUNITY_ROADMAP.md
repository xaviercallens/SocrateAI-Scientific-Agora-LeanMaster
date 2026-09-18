# Community roadmap — a mathematical track to pursue, a physical track to open

**Status (2026-09-18).** Written after Streams 1–7. The programme's testable physical hypothesis did not
survive data (papers 9, 11); its mathematics did (papers 8, 10). This document (i) sets the mathematical
track this repository will pursue, (ii) states the physical questions as open problems for the community,
and (iii) puts the most relevant published work in perspective. **Perspectives below are based on the
papers' abstracts (arXiv API) unless a line range is given; the PDFs are pinned in
`papers/foundations/MANIFEST.md` for deeper reading. Nobody listed here has been contacted or has
endorsed this project; they are listed as authors of the most relevant published work.**

## 1. Mathematical track (what this repository does next)

| # | Goal | Why | Builds on | Difficulty |
|---|---|---|---|---|
| M1 | Extended Golay code → Niemeier lattice `A₁²⁴`: even, unimodular, root system `A₁²⁴` (finite checks) | makes concrete the lattice behind `G^X = Aut(L_X)/W_X` (CDH 1307.5793); prerequisite to reopen Stream 4's reflection question | Stream 2 `Lattice.*`, `Reflection` | days |
| M2 | `M₂₄ ⊂ Aut(Golay)`: generators as permutations, code preserved, order and class data checked | turns the transcribed character table into a consequence of a constructed group | M1; CDH Table 8 | weeks |
| M3 | Twisted elliptic genera cross-checked against Eguchi–Hikami 1008.4924 (independent source) | second literature source for `TwistedDyons` | Stream 5 | days |
| M4 | Higher orders: moonshine levels 10–20, immortal dyons `m = 4, 5` (`H|V₄`-type operators, DMZ (9.14)) | tests of DMZ §9 beyond what is printed | Stream 5; needs faster series arithmetic | weeks |
| M5 | General (not truncated) statements: Jacobi's `η³` identity, the index-1 Jacobi property, `E₂`/`E₄`/`E₆` q-expansions in Mathlib's `ModularForm` API | replaces "checked through `q⁹`" by theorems; upstreamable to Mathlib | Mathlib `ModularForms`, `JacobiTheta` | months |
| M6 | Contribute reusable pieces upstream (q-series with Laurent coefficients, Hurwitz class numbers, `ℤ[(−1+√−n)/2]` arithmetic) to Mathlib / PhysLean (HepLean 2405.08863) | durable value independent of any physical claim | all streams | ongoing |

## 2. Physical track (open problems offered to the community)

The negative results are specific: the identification `α' = ℓ_P·c/H₀` either conflicts with data or hides
every stringy signal, and K3 × T² (type II) gives `N = 4` with no chiral matter. What remains open:

* **P-1. Leave `N = 4` without leaving K3 × T².** Heterotic strings on K3 × T² give `N = 2`, dual to type IIA on
  K3-fibred Calabi–Yau threefolds (Kachru–Vafa hep-th/9505105), and `M₂₄` reappears there in the new
  supersymmetric index and in Gromov–Witten invariants (Cheng–Dong–Duncan–Harvey–Kachru–Wrase 1306.4981).
  `N = 2` is still non-chiral in four dimensions, but this is the natural first step and its arithmetic
  (GW invariants, new supersymmetric index) is formalizable with this repository's methods. *Open:* is there
  any dual-scale statement (a T-duality-invariant combination of scales) in this `N = 2` setting that yields a
  dimensionful prediction without choosing `α'` by hand?
* **P-2. The dark dimension as the live neighbour of P1.** P1 (`R = 47 μm`) is excluded, but the
  Montero–Vafa–Valenzuela window `0.1–10 μm` is not; its phenomenology is being developed
  (Anchordoqui–Antoniadis–Lüst 2206.07071). *Open:* can a K3-based construction **derive** `λ` in
  `l = λ Λ^{−1/4}` rather than fit it? Any answer must be frozen before comparison (our protocol, paper 11).
* **P-3. Where does `M₂₄` act?** Gannon (1211.5531) proved the twined series are characters; symmetry
  surfing (Taormina–Wendland 1303.3221; Gaberdiel–Keller–Paul 1609.09302) and the GTVW model with its
  error-correcting-code structure (Harvey–Moore 2003.13700) look for the module. *Open, formalizable:* the
  Golay-code side of Harvey–Moore overlaps with M1–M2 above.
* **P-4. Single-centred black holes.** DMZ's finite part counts immortal dyons; Sen and collaborators
  (0708.1270, 1511.06978) test the microstate picture directly. *Open:* twisted immortal counts beyond
  `m = 1` (we have `m = 1` through `q²`), and whether their `M₂₄` decompositions are positive after the
  natural sign.
* **P-5. Method.** Pre-registration for theory: freeze the derivation and decision rule by a public tag
  before comparing (paper 11). We invite criticism of the protocol itself.

## 3. Whose work matters most here (by topic; public authorship only)

| Topic | Authors (papers pinned) | What they established | Relation to this repository |
|---|---|---|---|
| Mathieu moonshine: proof | T. Gannon (1211.5531) | twined series are true `M₂₄` characters; evenness | Tier L theorem behind Streams 4–5; we check levels 0–9 explicitly |
| Twisted elliptic genera | T. Eguchi, K. Hikami (1008.4924); M. Gaberdiel, S. Hohenegger, R. Volpato (1006.0221, 1106.4315); M. Cheng (1005.5415) | all 26 twisted genera; no K3 sigma model has `M₂₄` symmetry | source and cross-check for `TwiningAll`, `TwistedDyons` (M3) |
| Umbral moonshine | M. Cheng, J. Duncan, J. Harvey (1204.2779, 1307.5793); J. Duncan, M. Griffin, K. Ono (1503.01472) | 23 Niemeier cases; existence of modules | our HMN bridge covers `A₁²⁴ … A₁₂²`; M1 targets the lattice side |
| Little strings and mock modularity | J. Harvey, S. Murthy, C. Nazaroglu (1410.6174) | DSLST index = umbral forms | reproduced; divisibility `⇔ rk ∣ 24` proved |
| Dyons, wall-crossing, mock Jacobi forms | A. Dabholkar, S. Murthy, D. Zagier (1208.4074); A. Sen (0708.1270) | immortal vs multi-centred split; class numbers | Stream 5 (`m = 1, 2, 3`); M4 extends |
| `M₂₄` beyond `N = 4` | Cheng, Dong, Duncan, Harvey, S. Kachru, T. Wrase (1306.4981); Kachru–Vafa (hep-th/9505105) | `M₂₄` in heterotic K3 × T² and CY3 GW invariants | physical-track entry point P-1 |
| Where the module lives | A. Taormina, K. Wendland (1303.3221, 1107.3834); Gaberdiel, C. Keller, H. Paul (1609.09302); Harvey, G. Moore (2003.13700) | symmetry surfing; codes and the GTVW model | P-3; overlaps M1–M2 (Golay code) |
| Reviews | V. Anagiannis, M. Cheng (1807.00723); S. Kachru (1605.00697) | pedagogical state of the art | reading list for contributors |
| Dark dimension | M. Montero, C. Vafa, I. Valenzuela (2205.12293); L. Anchordoqui, I. Antoniadis, D. Lüst (2206.07071) | micron-scale extra dimension and its phenomenology | P-2; our P1 is the excluded edge of this window |
| Formalized physics in Lean | J. Tooby-Smith (2405.08863, HepLean/PhysLean); the Mathlib modular-forms contributors | Lean 4 infrastructure for HEP and modular forms | M5–M6: upstream targets |

## 4. How to contribute
Open problems are tracked here and in papers 10–11 ("open problems" sections). Rules: `docs/USING_LEANMASTER.md`
(gates: build, no `sorry`, axiom audit, statement lock), tiers A/L/C, literature pinned by file and line.
Physical predictions follow the pre-registration protocol of paper 11.
