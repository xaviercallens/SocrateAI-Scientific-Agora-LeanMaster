# Improvement Proposal — Paper 7: *The Dual-Scale String Theory: Master Demonstration*

**Target file:** `papers/publication/paper7_dual_scale_theory_master_demonstration.tex` (v1.2.0, 512 lines, 10 sections)
**Date:** 2026-09-15
**Method:** Referee-level audit of the manuscript, checked line by line against the Lean sources it cites, using the publication and rigor skills from the sibling projects in `~/xdev` (read-only).
**Verdict (as a journal submission today):** **Reject / desk-reject risk.** The problem is not the typesetting. The paper claims much more than its Lean artifact proves, and several of its numbers are arithmetically wrong. The fixes below would turn it into a defensible and citable paper.

---

## 0. Skills leveraged from `~/xdev`

| Skill (source project) | What it contributes to this proposal |
|---|---|
| `scientific-paper-rigor-auditor` (SocrateAIShared/foundationpaper2) | Report structure: P0 blockers / P1 major / P2 minor, and a final recommendation |
| `mathesis-tier-gate` (SocrateAI-Mathesis) | Epistemic tiers A/B/L/C/X; "`#print axioms`, not grep for `sorry`"; statement-adequacy audit; "a claim may not sit above what it rests on" |
| `adversarial-defense-agent` (SocrateAIShared/speculativepapers) | Anti-math-washing protocol: never write "Lean verified the physics" |
| `string-compactification` (foundationpaper2/.claude) | Supercharge bookkeeping on K3×T², N = 4 non-renormalization, requirements for a "moduli stabilized" claim, swampland conjectures stay Tier B |
| `quantum-gravity-phenomenology` (foundationpaper2/.claude) | Data provenance line `value ± σ \| dataset+release \| measures \| role`; falsification table contract |
| `observational-data-rigor` (foundationpaper2) | Benchmark vs. forecast vs. measurement; no tautological likelihoods |
| `peer-review-defense` (SocrateAI-Scientific-DualScaleSimulator) | Four referee demographics (DFT, topological T-duality, swampland phenomenology, AI-for-science) and their predicted objections |
| `algorithmic-duality-bridge` (DualScaleSimulator) | How to present DFT honestly when the implementation is 0D/1D |
| `publication-submission-strategist` (DualScaleSimulator) | Venue matrix (JHEP / SciPost / CPC / NeurIPS-AI4Science), pre-submission checklist, cover-letter templates |
| `academic-publication`, `epistemic-debate` (OpenAI-NSE-Epistemic-Audit) | Tier A/B/C demarcation; **your own Navier–Stokes position**, which Paper 7's abstract currently contradicts |
| `scientific-publication` (foundationpaper2/.claude) | Gate zero ("do not publish a claim the review rejected"), concept DOI, PDF fidelity gate, verbatim-listing check |
| `universal-literature-grounding`, `lean-reference-demonstration-engine` (foundationpaper2) | Zero orphan citations; no placeholder theorems passed off as formalizations |
| `scientific-paper-engineer`, `journal-selector` (AutoEvolve-K3×T2) | `references.bib` hygiene, overfull-box hygiene, venue scope matching |
| `decisive-experiment` (SocrateAI-Scientific-Measure) | Adversarial refute step: check the *positive* claims as hard as the negative ones |

---

## 1. Summary of claims vs. what the artifact actually establishes

The manuscript says (abstract, §9, §10) that **"every mathematical definition, lemma, and master theorem"** is Lean-certified and that the framework is **"100% machine-certified."** A statement-adequacy audit (per `mathesis-tier-gate`) of each cited module finds the following:

| § | Paper claim | Cited Lean declaration | What the Lean statement actually is | Adequacy |
|---|---|---|---|---|
| 3 | ∀ R > 0 (real), R + α′/R ≥ 2√α′, unique minimum at √α′ | `UseCase1.self_dual_is_global_minimum` | `R : Nat`, `R ≥ 1 → R*R + 1 ≥ 2` | ❌ Different theorem: naturals only, α′ = 1, no √, no minimality |
| 3 | Genesis No-Singularity (bounce) | `SocrateAI.DualScale.genesis_no_singularity` | Numerator and denominator of a `PosScale` are positive, which the structure's own fields already guarantee. It also uses a *piecewise* `if R < cutoff then α/R else R`, not R + α′/R | ❌ True by construction (tautology) |
| 4 | TCC satisfied unconditionally | `DualScaleTCC.tcc_cosmic_protection_contract` | `(R*R+1)*λ₀ ≥ 2` for Nat R, λ₀ ≥ 1, plus `M/H ≥ 1`, where `H < M` is an *assumed field* of `InflationParameters` | ❌ Does not encode the TCC (a bound on a_f/a_i relative to H), drops the 1/R, and excludes R < 1, which is exactly the regime of the bounce |
| 5 | Moduli stabilized, no flat directions, Hessian = 2 | `UseCase1.moduli_vacuum_stability` | `phi = phi_0 → (phi - phi_0)*(phi - phi_0) = 0` over **Nat** | ❌ Trivial substitution. **Bug:** Nat subtraction truncates, so `moduli_potential 3 5 = 0`. In the formalization the minimum is *not* unique. No Hessian, and no link to 𝓡_DFT |
| 2 | Courant bracket, Jacobiator, section condition | `DoubleFieldTheory.CourantAlgebroid` | `CourantSection := {v : Int, alpha : Int}`; the "Lie bracket" is `X.v*Y.v − Y.v*X.v`, which is 0 by commutativity | ❌ 1-dimensional scalar toy. The Jacobiator result holds only because every bracket is zero |
| 5 | Dirac index on K3 = 2 | `K3Topology.k3_atiyah_singer_dirac_index` | `(-(-16))/8 = 2` via `decide` | ⚠️ Arithmetic instance of Â = −σ/8 (Tier A arithmetic; the index theorem itself is Tier L) |
| 6 | 462·60 = 360·77 = 27720; \|M24\|/27720 = 8832 | `UseCase2.bps_cross_multiplication_lock` | `decide` on integer products | ✅ Correct arithmetic. Physical significance not established (see P0-4) |
| 6 | Golay code protects BPS microstates against Hawking decoherence | `Problem8_GolayHolography` | Codeword count, error radius 3 | ❌ Coding-theory arithmetic only; the holographic claim is Tier C |
| 7 | dim 𝓜_phys = 0 (Zero Free Parameter Theorem) | `DualScaleValidation.Observables` | No such theorem exists | ❌ No formal statement anywhere |
| 8 | r = 1/252, δ_CP = 282.4°, w₀ = −1 derived | `DualScaleValidation.Observables` | `def tensor_to_scalar_ratio_scaled : Nat := 396` followed by `300 ≤ 396 ≤ 500` | ❌ Hard-coded constants checked against hand-picked windows. Nothing is derived |
| 9 | Only standard axioms | (none) | **Mathlib is not a dependency** (0 files import it). No `#print axioms` log is shipped | ⚠️ Probably true (no `axiom` declarations found), but unevidenced |

**Consequence:** the library contains **no real numbers, manifolds, tensors, or bundles**. The accurate description is *"Nat/Int arithmetic consistency checks of numerical identities that appear in the argument."* That is Tier A for the arithmetic and Tier C for the physics. The paper's framing ("the correctness of our algebra is not an object of subjective debate") is exactly the math-washing that `adversarial-defense-agent` §4 prohibits, and a DFT or formal-methods referee will find it within minutes.

> The internal `PEER_REVIEW_REPORT.md` ("ACCEPTED & FULLY CERTIFIED") ran three gates: 0 sorry, symbol concordance, and DAG acyclicity. All three test *syntax and bookkeeping*. None tests whether a Lean statement means what the paper says it means. That missing gate is the root cause of every P0 below.

---

## 2. P0 — Blockers (must fix before any submission)

### P0-1. Replace "100% machine-certified physics" with tiered claims
- Remove or rewrite: "first quantum gravity framework to be 100% machine-certified", "Every mathematical definition, lemma, and master theorem has been certified", "Scientific Truth is Epistemically Secured", "The era of heuristic… has ended".
- Put a **tier badge** on every theorem environment (see §5.2) and add a **Claim Ledger table** (Appendix A), with each row giving the claim, tier, Lean declaration, and adequacy note, taken from the table in §1.
- Required wording (from `adversarial-defense-agent`): *"Lean 4 certifies the integer and rational arithmetic identities used in the argument (Tier A). The differential-geometric, index-theoretic and cosmological statements are drawn from the literature (Tier L) or are proposals of this work (Tier C)."*

### P0-2. Arithmetic errors in the text
| Location | As written | Correct |
|---|---|---|
| l.322 | 8832 = 2⁶ × 3 × 23 | 2⁶·3·23 = 4416. **8832 = 2⁷ × 3 × 23** |
| l.399 | 360°·(1 − 77/360) = 282.4° | = **283°** exactly. The derivation also uses 77/**360**, while the "BPS lock" is 77/**60**, so the two are inconsistent |
| l.392 vs `Observables.lean` | r = 1/252 ≈ 0.003968; table says 0.00396; Lean stores 396·10⁻⁵ | 1/252 = 0.0039683… rounds to **0.00397**. Pick one value and make Lean store the rational 1/252 |
| l.394 vs Lean | Falsification window 0.0035–0.0045 | Lean certifies 0.003–0.005. The windows disagree |
| l.264 | ind(D̸) = (1/24)∫c₂ = (24/24)×2 = 2 | ∫c₂ = χ = 24, so (1/24)∫c₂ = 1. The "×2" is unexplained. Correct form: **Â(K3) = −p₁/24 = −σ/8 = 2** |
| l.295 | χ = 24 ch₀ − 2 Σₙ≥₁ Aₙ ch | EOT form: χ = 24 ch_{1/4,0} + Σ_{n≥0} Aₙ ch_{n+1/4,1/2}, with **A₀ = −2** as the first coefficient, not an overall multiplier (check against arXiv:1004.0956, eq. for Z_K3) |
| l.371 | "By Theorem 3.1" | Definition and theorem share a counter, so the Genesis theorem is **Theorem 3.2** (3.1 is the Definition). Use `\label`/`\cref` throughout |

### P0-3. Physics contradictions a string referee will raise immediately
1. **N = 4 moduli cannot be lifted this way.** Type II on K3×T² has 16 supercharges. Its moduli space is exact, and no potential is generated perturbatively or non-perturbatively (`string-compactification` §1: *"if a proposed effect would renormalize an N = 4 protected quantity, that is a contradiction, not a prediction"*). To stabilize moduli the paper must introduce fluxes, branes/orientifolds, or SUSY breaking, with tadpole bookkeeping. Otherwise Theorem 5.1 has to be withdrawn. A toy V(φ) = (φ − φ₀)² with no derivation from 𝓡_DFT does not stabilize the 80 + 1 K3 σ-model moduli plus the T² moduli.
2. **V(φ₀) = 0 gives Λ = 0, not dark energy.** A Minkowski minimum has no cosmological constant, so "w₀ = −1 exact topological cosmological constant" contradicts the paper's own potential.
3. **"Fixing chiral fermion generations"** (§7 proof, step 5): 4D N = 4 is non-chiral, and Â(K3) = 2 counts parallel spinors (6D SUSY), not generations.
4. **"Unique stationary point… bounce"**: R_eff(R) → ∞ as R → 0 is a statement about a function of R. No dynamics (no equations of motion or Friedmann analogue) is given, so "guaranteeing a safe bounce *regardless* of the equations of motion" (l.200) cannot hold. Cite Brandenberger–Vafa (1989) string-gas cosmology as the established precedent and scope the claim to kinematics.
5. **TCC** constrains the *duration of expansion* (a_f/a_i < M_Pl/H_f). A lower bound on a wavelength does not by itself satisfy it. Either state the dynamical assumption explicitly or downgrade the corollary to Tier C.

### P0-4. The "27720 BPS Lock" and "zero free parameters" are numerology as presented
- For any fraction in lowest terms a/b = p/q, a·q = b·p = lcm(a, b). Here 27720 = lcm(462, 360) = **lcm(1,…,12)**. That any group order divisible by 2³·3²·5·7·11 is a multiple of 27720 is automatic, and \|M24\| = 2¹⁰·3³·5·7·11·23. This is not a topological invariant and not a "lock".
- The weighting N_Q = 4 in A₂/(N_Q·A₁) is unmotivated. The dyon-counting literature (Dijkgraaf–Verlinde–Verlinde; Cheng 2010, which is in the bibliography but never cited) should be engaged.
- The factors behind r = 2/(27720/55) (why 55? why 2?) and δ_CP (why a phase of 1 − 77/360?) are **not derived**. Under `quantum-gravity-phenomenology` rules these are post-hoc numerical matches and must be labeled so, or the derivation must be supplied.
- "dim 𝓜 = 0" needs a formal definition of the parameter space and a proof. The five "locks" are facts about fixed integers and do not constrain g_s, the volume, or any continuous parameter.
- **Recommendation:** rename the section "Arithmetic Coincidences in the K3 Elliptic Genus" (Tier A arithmetic plus Tier C interpretation), or remove it from the main line and move it to a speculative appendix.

### P0-5. The falsifiability matrix already has live tensions and wrong provenance
Every number gets a provenance line: `value ± σ | dataset + release | measures | role (measurement/benchmark/forecast)`. Verify each value against the primary source rather than from memory (`universal-literature-grounding`):
- **DESI DR2 (2025) with CMB + SNe prefers w₀ > −1, w_a < 0 at roughly 3–4σ** (depending on the SN sample). The prediction (−1, 0) is *already in tension* and cannot be presented as "will test". Address it head-on.
- **NuFIT:** "280° ± 30°" does not match the NuFIT 5.2 normal-ordering best fit (≈ 232°). It resembles the *inverted*-ordering value. State the release, the ordering, and the 1σ/3σ ranges exactly.
- **LiteBIRD:** σ(r) ≈ 10⁻³ cannot "decisively falsify" a window ±5×10⁻⁴ wide, which is narrower than 1σ. Also recheck the launch date (currently slipped to the early 2030s) and the DUNE/Hyper-K timelines (DUNE beam physics starts ~2031, not 2026).
- Add the required table columns: *current bound | required sensitivity | verdict (consistent / tension / untestable now)*.

### P0-6. The abstract contradicts the author's own published position
The abstract and §1 say that *"recent AI breakthroughs demonstrat[e] that Navier-Stokes equations inevitably blow up."* Your `OpenAI-NSE-Epistemic-Audit` project (skills `epistemic-debate`, `scientific-communication`) argues the opposite: the Lean blow-up uses a manufactured forcing (Fefferman Statements C/D) and says nothing about the unforced problem (A/B). A referee who knows both works will treat this as a credibility failure. It is also uncited and a non sequitur, since the paper itself relies on continuum DFT. **Delete it**, or replace it with one sentence consistent with the NSE audit.

---

## 3. P1 — Major revisions

1. **Literature grounding (zero orphans, zero missing anchors).**
   - Cited in the bibliography but never used in the text: `Buscher1987`, `Witten1995`, `Cheng2010`, `Callens2026`. Either cite them or remove them.
   - Missing anchors for claims the text makes (retrieve the metadata; do not type it from memory):
     KKLT (2003), LVS (2005), Bousso–Polchinski (2000); Hawking–Penrose singularity theorems; Brandenberger–Vafa (1989); minimal-length / T-duality zero-point length (Amati–Ciafaloni–Veneziano; Gross–Mende; Padmanabhan 1997; Nicolini–Spallucci–Wondrak 2019); Giveon–Porrati–Rabinovici (1994); Atiyah–Singer (1968); Gannon (2016, proof of M24 moonshine); Conway–Sloane (Golay/M24); Almheiri–Dong–Harlow / Pastawski et al. (holographic QEC); Planck 2018, LiteBIRD (PTEP 2023), DESI DR2, NuFIT, DUNE TDR; Hull–Zwiebach eq. numbers for 𝓡_DFT.
   - **Related work in formalized physics** is absent and required for any formal-methods referee: PhysLean (formerly HepLean, Tooby-Smith 2024), Mathlib's differential geometry, and prior physics formalizations in Isabelle/Coq.
   - Move to `references.bib` + `biblatex`/`natbib`, with `AuthorYear` keys (`scientific-paper-engineer`).
2. **Rename "Callens Effective Dual Metric."** An eponym chosen by the author for a function already in the string-gas and minimal-length literature will be read as a priority claim. Use "effective dual scale R_eff" and cite the precedents. The same applies to "Callens Dual-Scale String Theory" in §7.
3. **Reproducibility appendix** (`scientific-publication` §5, `publication-submission-strategist` §2):
   - Commit hash, toolchain, `lake build` job count, and the **verbatim `#print axioms` output** for every cited theorem.
   - Recount the inconsistent figures: the paper says 50 files / 503 declarations / 528 DAG nodes / 785 edges, `PEER_REVIEW_REPORT.md` says 422 nodes / 554 edges, and a quick recount gives **51 `.lean` files**. Generate the numbers with one script and quote its output.
   - Lean listings typeset with `fancyvrb` (not `listings`), plus the automated check that every listed line exists verbatim in the source.
   - A concept DOI (Zenodo) rather than a bare GitHub URL, and a data/code availability statement.
4. **Authorship and AI disclosure.** arXiv and most journals do not allow AI systems or unnamed "collaborations" of agents as authors, and they require disclosure of AI use. List human authors only. Add an "AI assistance" statement describing the agent swarm's role. Replace "Directorate of Epistemic Software & Autonomous Multi-Agent Swarms" with the real affiliation (`academic-publication`: Socrate AI Lab, French association loi 1901). Drop "v1.2.0 Certified Release" from the date line.
5. **Anticipated referee objections** (`peer-review-defense`). Pre-empt each in the text:
   - *DFT referee:* "The Courant bracket is on 1-component integers; the bracket is identically zero." → State the scalar-toy scope explicitly and give a roadmap to Mathlib `VectorBundle` (see `algorithmic-duality-bridge` §3).
   - *Topology referee:* "Where is the index theorem, where is the lattice Γ³'¹⁹?" → Declare them Tier L inputs, taken as explicit hypothesis parameters, never as axioms (`mathesis-tier-gate`).
   - *Swampland referee:* N = 4 non-renormalization, TCC dynamics, DESI tension (P0-3, P0-5).
   - *AI-for-science referee:* this referee is your natural champion, *if* the claims are honest. Emphasize the reproducible pipeline and the LeanGraph DAG.
6. **Strengthen the Lean side for the two claims that can be made genuinely Tier A soon** (requires adding Mathlib). Sketches below have **not** been compiled:
   ```lean
   import Mathlib
   /-- Real AM-GM form of the dual-scale bound, with equality iff self-dual. -/
   theorem reff_lower_bound {α R : ℝ} (hα : 0 < α) (hR : 0 < R) :
       2 * Real.sqrt α ≤ R + α / R := by
     have hs : Real.sqrt α ^ 2 = α := Real.sq_sqrt hα.le
     have h := sq_nonneg (R - Real.sqrt α)
     rw [le_add_div_iff_mul_le_of_pos hR] -- adjust to current Mathlib lemma name
     nlinarith [hs, h]

   /-- Toy potential over ℝ: vanishes exactly at φ₀ (fixes the Nat-truncation bug). -/
   theorem toy_potential_zero_iff (φ φ₀ : ℝ) : (φ - φ₀) ^ 2 = 0 ↔ φ = φ₀ := by
     simp [sub_eq_zero]
   ```
   Also store r as the rational `(1 : ℚ) / 252` and prove `r ∈ [lo, hi]` using the same window the text states.

---

## 4. P2 — Minor / typographical

- **6 overfull hboxes** in the current log. The worst is **191 pt** at l.202–203 (long `\texttt` module names), then 90 pt (l.136), 70 pt (l.438), 32 pt (Table 2), 24 pt (Table 1), 15 pt (l.244). Fix with `\path{}`/`\url{}`-style breaking, `tabularx`, or `\footnotesize` for identifiers.
- Preamble: `inputenc` is redundant on modern engines; replace `color` with `xcolor`; `tcolorbox` and `array` are loaded but never used; load `hyperref` last and add `cleveref`; use `\slashed{D}` (package `slashed`) instead of `\not{D}`; use `siunitx` (`\num{244823040}`) instead of `244,823,040` in math mode, which spaces badly.
- Table 2 header "Experimental Experiment" should be "Experiment". Replace `[h!]` with `[htbp]`.
- The abstract's enumerated list of 10 items reads as a table of contents. Replace it with a ≤ 250-word prose abstract (§5.1).
- Avoid adjectives that stand in for tiers: "profound", "triumph", "rigorous", "absolute", "decisively", "striking alignment" (`mathesis-tier-gate`: *"What never gets a tier: adjectives"*).
- M_{10} = ℝ^{3,1} × K3 × T²: state the duality frame (IIA vs IIB vs heterotic) in the first sentence of §5 (`string-compactification`). The mass formula at l.149 is the *bosonic* closed-string formula; say so, or give the superstring one.
- Add `\label` to every theorem and equation, and remove hard-coded "Theorem 6.2" references.

---

## 5. Proposed rewrites (drop-in LaTeX)

### 5.1 Abstract (honest framing, ~200 words)
```latex
\begin{abstract}
We present a Lean~4 companion formalization for a dual-scale scenario of type~II
string theory on $K3\times T^2$ and state precisely what is, and is not,
machine-checked. The Lean artifact (51 files, toolchain v4.33.1, no Mathlib,
standard axioms only; \texttt{\#print axioms} logs in Appendix~B) certifies the
integer and rational identities used in the argument: the positivity of the
dual scale $R+\alpha'/R$ on integer radii, the $K3$ invariants
$\chi=24$, $\sigma=-16$, $\hat A=2$, and the elliptic-genus arithmetic
$A_2\cdot 60 = 4A_1\cdot 77 = 27720$ with $|M_{24}| = 27720\cdot 8832$.
The continuous statements (the real-analytic bound $R_{\mathrm{eff}}\ge 2\sqrt{\alpha'}$,
double field theory, index theory, cosmological dynamics) are taken from the
literature or proposed here, and are labeled by epistemic tier throughout.
We discuss the obstruction that $\mathcal N=4$ non-renormalization poses for
moduli stabilization, confront speculative numerical relations for $r$,
$\delta_{\mathrm{CP}}$ and $(w_0,w_a)$ with current data, including the DESI DR2
preference for evolving dark energy, and give a roadmap for promoting the
central claims to kernel-checked real-analytic theorems in Mathlib.
\end{abstract}
```

### 5.2 Tier badges on theorem environments
```latex
\usepackage{xcolor}
\newcommand{\tierA}{\textsf{\small\colorbox{green!15}{Tier A: Lean kernel}}}
\newcommand{\tierL}{\textsf{\small\colorbox{blue!10}{Tier L: literature}}}
\newcommand{\tierC}{\textsf{\small\colorbox{orange!15}{Tier C: conjecture/proposal}}}
% usage:
\begin{theorem}[Dual-scale lower bound]\label{thm:reff} \tierL\ (real form) / \tierA\ (integer form, \texttt{self\_dual\_is\_global\_minimum})
...
\end{theorem}
```

### 5.3 "What Lean checks" box, placed at the end of every section
```latex
\begin{remark}[Scope of formal verification]
The Lean declaration \texttt{DualScaleValidation.UseCase1.self\_dual\_is\_global\_minimum}
states $\forall R\in\mathbb N,\ R\ge1 \Rightarrow R^2+1\ge 2$. It does not
formalize real radii, the square root, minimality, or any dynamics.
\end{remark}
```

### 5.4 Restructured outline (≈ 14 pp + appendices)
1. Introduction: the landscape and verification problems, the scope of this paper, the tier convention
2. Formalization methodology: tiers, statement-adequacy audit, axiom footprint, limits of a Mathlib-free library
3. T-duality and the effective dual scale (Tier L + A integer instance; Brandenberger–Vafa precedent; kinematic scope only)
4. K3×T² bookkeeping: supercharges, invariants, Â = 2 (Tier L + A arithmetic)
5. Moduli: why N = 4 forbids a potential; what fluxes/breaking would be needed (Tier C roadmap). *Replaces the current Theorem 5.1*
6. Elliptic genus arithmetic and M24 (Tier A arithmetic, with the lcm observation stated openly)
7. Speculative phenomenology and confrontation with data (Tier C, full provenance table, DESI tension)
8. The Lean artifact: DAG, DSL, reproducibility
9. Limitations and roadmap to Tier A promotion
- App. A: Claim ledger (mirrors `LEDGER.md` / `ledger.jsonl`)
- App. B: `#print axioms` logs + build manifest
- App. C: Verbatim Lean listings (fancyvrb, auto-checked)

---

## 6. Venue strategy (`publication-submission-strategist`, `journal-selector`)

| Option | Framing | Fit **after** the P0 fixes | Fit **today** |
|---|---|---|---|
| **A. Recommended:** arXiv `cs.LO` + cross-list `hep-th`; then CICM / ITP workshop track, or a *SciPost Physics Codebases*-style artifact paper | "A tiered Lean 4 companion to a dual-scale string scenario: what can and cannot be checked without Mathlib" | Good: honest, novel as methodology, reproducible | Desk reject |
| B. NeurIPS/ICLR AI-for-Science workshop | Agent swarm + Lean gate + statement-adequacy failure as a *finding* | Good, especially if it reports the adequacy gap as a lesson | Reject |
| C. JHEP / JCAP | Physics results | Only after the moduli obstruction is resolved and derivations for r, δ_CP exist | Reject |
| D. Zenodo archival deposit only | "Archival deposit, not peer-reviewed" | Always acceptable (`scientific-publication` gate zero), provided withdrawn claims are stated in the README, DOI description, and paper | Acceptable only with that framing |

**Recommendation:** fix P0 → pursue **A**, with **D** in parallel. Keep the physics ambitions as the "Roadmap" section and as a separate later paper (option C) once the Mathlib real-analytic promotions and a flux-based stabilization mechanism exist.

---

## 7. Action plan

| Phase | Work | Output | Gate |
|---|---|---|---|
| **1. Correct** (1–2 days) | P0-2 arithmetic fixes; delete the NSE sentence (P0-6); fix Theorem 3.1 ref; remove/cite orphan bibitems | Patch to `.tex` | `pdflatex` ×2: 0 undefined refs, 0 overfull > 5 pt |
| **2. Reframe** (3–5 days) | New abstract (5.1), tier badges (5.2), scope remarks (5.3), Claim Ledger appendix, rename eponyms, AI/authorship disclosure | Revised manuscript v1.3 | Every theorem has a tier; every Lean ID in the text resolves (existing concordance check) **and passes a human statement-adequacy review** |
| **3. Physics honesty** (1 week) | Rewrite §5 around the N = 4 obstruction; demote §7 locks to "arithmetic observations"; rebuild §8 with provenance and DESI DR2 / NuFIT / LiteBIRD values checked against primary sources | §5, §7, §8 rewritten | Red-team pass with the four `peer-review-defense` referee personas; refute step checks the *favorable* claims too (`decisive-experiment` §6) |
| **4. Artifact** (1–2 weeks) | Add Mathlib; fix the Nat-truncation bug in `moduli_potential`; prove `reff_lower_bound` over ℝ; store r as ℚ; generate `#print axioms` logs; single script for file/declaration/DAG counts; Zenodo concept DOI | Lean PR + Appendix B | `lake build` green; `#print axioms` shows only `propext`, `Classical.choice`, `Quot.sound` |
| **5. Submit** | arXiv (cs.LO + hep-th) → workshop/codebase venue; Zenodo archival | Submission package + cover letter (adapt Template B from `publication-submission-strategist`) | `scientific-publication` gate zero + PDF fidelity gate |

Also add a fourth gate to the internal pipeline (`PEER_REVIEW_REPORT.md` / `polishworkflow.py`): a **statement-adequacy audit** that, for each theorem cited in a paper, compares the Lean type signature with the LaTeX statement and fails if their domains (ℕ vs ℝ), quantifiers, or conclusions differ. That gate would have caught every ❌ in §1.

---

## 8. Pre-submission checklist

- [ ] No sentence says Lean verified physics, geometry, or dynamics
- [ ] Every theorem/corollary carries a tier; no claim sits above anything it rests on (transitively)
- [ ] 8832 = 2⁷·3·23; δ_CP arithmetic consistent; r value identical in text, table, and Lean
- [ ] N = 4 non-renormalization addressed; V(φ₀) = 0 vs dark energy resolved
- [ ] 27720 = lcm(1..12) stated openly; "zero free parameters" either formalized or withdrawn
- [ ] Every experimental number has `value ± σ | release | measures | role`, verified against the primary source
- [ ] DESI DR2 tension with (w₀, w_a) = (−1, 0) discussed
- [ ] Navier–Stokes sentence removed or made consistent with the NSE-Epistemic-Audit
- [ ] 0 orphan bibitems; related formal-physics work (PhysLean, Mathlib) cited
- [ ] `#print axioms` logs + commit hash + concept DOI in the appendix
- [ ] Human authors only; AI-assistance statement; real affiliation
- [ ] 0 overfull boxes > 5 pt; `\cref` everywhere; `fancyvrb` listings auto-checked against the source
