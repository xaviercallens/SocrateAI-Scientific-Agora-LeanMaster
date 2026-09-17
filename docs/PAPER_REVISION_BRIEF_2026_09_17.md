# Paper revision brief — verified facts only (2026-09-17)

Everything below was verified by the orchestrator against the Lean kernel (build + `sorry` count
+ `#print axioms` via `tools/axiom_audit.py`) or against the downloaded paper text in
`papers/foundations/` (file + line). **Writers must not add any claim that is not in this brief
or directly readable from the cited Lean source / paper line.** When unsure, say less.

## 0. Epistemic vocabulary (use exactly)

- **Tier A** — statement proved in Lean 4 (v4.33.1, Mathlib v4.33.1), kernel-checked, no `sorry`,
  and `#print axioms` shows only `propext`, `Classical.choice`, `Quot.sound`.
- **Tier L** — quoted from the literature (cite paper + section/equation), not re-derived.
- **Tier C** — this project's conjecture / physical interpretation; not derived, not proved.

**Forbidden phrasings** (all were used in earlier revisions and are false or unverifiable):
"zero axioms", "zero unproven axioms", "100% mathematical rigor", "certifies stability",
"robust moduli stabilization is proved", "formalizes string theory", "first fully certified",
"all of physics". Correct form: "proved in Lean 4 with no axioms beyond Lean's three standard
axioms (`propext`, `Classical.choice`, `Quot.sound`)", and physical conclusions are Tier L or C.

Every Lean mathematical statement is about finite-dimensional lattices, matrices, real and
integer arithmetic. The *identification* with string-theory objects (charge lattices, moduli,
fluxes) is Tier L (sourced) unless stated otherwise.

## 1. Verified audit numbers (quote these, nothing else)

- Stream 1 (six libraries `StringTheoryFoundation`, `DualScaleM24Formalization`,
  `DoubleFieldTheory`, `DualScaleValidation`, `Lean5Corpus`, `StringTheoryFormalization`):
  `lake build` green (3296 jobs for `StringTheoryFormalization`, 3353 for all six);
  axiom audit: **326 theorems**, 0 failing
  (DualScaleValidation 23, Lean5Corpus 53, DoubleFieldTheory 44, StringTheoryFoundation 56,
  DualScaleM24Formalization 61, StringTheoryFormalization 89).
- Stream 2 (`DualScaleStream2`, new library, 19 modules): `lake build DualScaleStream2` green
  (3670 jobs), 0 `sorry`; axiom audit **99 theorems**, 0 failing. Roadmap: 18 of 18 planned items
  of `docs/STREAM2_WORKFLOW.md` §5.1 (this is 100% *of that plan*, not of string theory).

## 2. Corrections that MUST appear in the revised papers

1. **M₂₄ irreducible dimension table** (Stream 1 `StringDynamics.M24RepDim`) was wrong until
   2026-09-16: 10395 and 483 were duplicated and the second 990 and third 1035 were missing
   (sum of squares 351,061,029 ≠ |M₂₄|). Replaced by Eguchi–Ooguri–Tachikawa eq. (A.3)
   (`eguchi_ooguri_tachikawa_1004_0956.txt` ll. 346–349) and guarded by the Tier A theorem
   `M24RepDim_sum_sq : ∑ dim² = 244823040` (Burnside identity is Tier L).
2. **`native_decide` removed**: `StringDynamics.bps_ratio_reduced` (77/60 in lowest terms) had
   relied on `native_decide` (trusts compiled code, not the kernel); it is now a kernel proof.
3. **Moonshine normalization and a notation error** (paper 7 §"Mathieu M24 Moonshine", paper 2).
   EOT eq. (1.11) (ll. 175–195): `Z_ell(K3) = 20 ch_{1/4,0} − 2 ch_{1/4,1/2} + 2 Σ_{n≥1} A_n q^{n−1/8} θ₁²/η³`
   with **A_n = 45, 231, 770, 2277, 5796, 13915, …** (eq. (1.12), l. 208). The multiplicities
   of massive representations are therefore **2A_n = 90, 462, 1540, 4554**. Papers 2 and 7 use
   the symbol `A_n` for these doubled multiplicities; state this convention explicitly
   ("we write $\mathcal{A}_n := 2A_n^{\mathrm{EOT}}$") so it does not clash with EOT.
   **Error**: paper 7 wrote `4554 = 2277 ⊕ \overline{2277}`. EOT eq. (A.4) (ll. 352–356): only the
   irreps of dimensions **45, 231, 770, 990, 1035** come in complex-conjugate pairs; 2277 is real.
   Correct: `4554 = 2 · 2277` (two copies of the real 2277), while `90 = 45 ⊕ \overline{45}`,
   `462 = 231 ⊕ \overline{231}`, `1540 = 770 ⊕ \overline{770}` are correct.
   The 77/60 ratio and `462·60 = 360·77 = 27720` arithmetic are unaffected.
4. The **Tier A** status of the EOT arithmetic now has a Lean anchor:
   `DualScaleStream2.Moonshine.EOT` — `first_five_are_irreps` (A₁…A₅ = dims of irreps, witnesses
   45→index 2, 231→4, 770→9, 2277→19, 5796→23), `A6_decomposition` (13915 = 3520 + 10395, EOT
   (1.14)), `A7_decomposition` (30843 = 10395+5796+5544+5313+2024+1771, EOT (1.15)),
   `A6_not_irrep`. That the elliptic genus carries an actual M₂₄ action is Tier L (EOT
   observation; proved by Gannon, already cited in paper 7).

## 3. Stream 2 content (for the new paper 8 and paper 7's new section)

Library `DualScaleStream2`, one module per bullet group, all Tier A unless marked.
Charge ordering (momentum ⊕ winding), `η = [[0, I],[I, 0]]`.

### 3.1 Lattice layer (K3 × T²)
- `Lattice.Basic`: `isUnimodular_of_mul_eq_one` — an integer left inverse certifies det = ±1;
  `even_quadratic_form_of_even_diag` — for symmetric integer G with even diagonal, xᵀGx is
  even for every integer x (proof: G = D + U + Uᵀ, xᵀUᵀx = xᵀUx).
- `Lattice.E8`: Cartan matrix of E₈ symmetric, even, unimodular via an explicit integer
  inverse (checked entrywise by the kernel); same for E₈(−1).
- `Lattice.E8PosDef`: exact LDLᵀ factorization with pivots 2, 3/2, 4/3, 5/4, 6/5, 7/6, 8/7, 1/8;
  **det E₈ = 1** exactly; **E₈ positive definite** (sum-of-squares identity
  xᵀE₈x = 2y₀² + (3/2)y₁² + … + (1/8)y₇², each yₖ an explicit linear form, then back-substitution).
- `Lattice.Hyperbolic`: U = [[0,1],[1,0]] even, unimodular, congruent to diag(2,−2) over ℚ
  (Sylvester's law of inertia to conclude signature (1,1) is Tier L); **proved equal** to Stream 1's
  Narain Gram matrix.
- `Lattice.K3T2Signature`: signature arithmetic K3 lattice E₈(−1)^⊕2 ⊕ U^⊕3 = (3,19), rank 22;
  Mukai lattice Γ^{4,20} = (4,20); K3×T² charge lattice Γ^{6,22} = (6,22), rank 28; b₊ − b₋ ≡ 0
  mod 8 for all three; **cross-check**: lattice (3,19) equals the Hodge-theoretic
  (2h^{2,0}+1, h^{1,1}−1) from Stream 1. Tier L: H²(K3,ℤ) ≅ E₈(−1)^⊕2 ⊕ U^⊕3 (Huybrechts Ch. 1
  eq. (3.4), `huybrechts_K3Global.txt` l. 603); Γ^{3,19}, Γ^{4,20} even self-dual and the K3 moduli
  space O⁺(Γ^{3,19})\O⁺(3,19)/(O(2)×O(1,19))⁺ (Aspinwall hep-th/9611137 ll. 705–766, 1737–1748);
  mod-8 theorem for even unimodular indefinite lattices (Milnor/Serre, not downloaded).
- `Lattice.Mukai`: Mukai pairing ⟨(r,c,s),(r',c',s')⟩ = c·L·c' − rs' − sr' (Huybrechts Ch. 9 §1
  Def. 1.4, ll. 7475–7482): symmetric; v² = c·L·c − 2rs; even whenever H² is even; the H⁰⊕H⁴
  summand U(−1) is unimodular; v = (1,0,1) has v² = −2, so χ(𝒪_X,𝒪_X) = −v² = 2 (the
  identification v(𝒪_X) = (1,0,1) and HRR χ = −⟨v,v⟩ are Tier L).
- `Lattice.Reflection`: for any symmetric integer Gram L and v with vᵀLv = −2, the reflection
  s_v = 1 + v vᵀ L (x ↦ x + ⟨x,v⟩v) is an isometry and an involution (via v vᵀ L v vᵀ =
  (vᵀLv)·v vᵀ); each simple root of E₈(−1) has norm −2, so every simple Weyl reflection is an
  isometry of E₈(−1). Tier L: Huybrechts Ch. 7 §5.4 ll. 6031–6043 (reflection formula), Ch. 6
  l. 5400 (Picard–Lefschetz monodromy of an A₁ degeneration is s_δ).

### 3.2 T-duality group O(d,d;ℤ) — every d
- `TDuality.ODD`: Θ-shift g_Θ = [[I,Θ],[0,I]] (Giveon–Porrati–Rabinovici hep-th/9401139 eq.
  (2.4.25), ll. 1355–1373) preserves η whenever Θ is antisymmetric (only this direction is proved); basis change diag(A,B) preserves η
  when AᵀB = 1; η is an involution in O(d,d;ℤ); O(d,d;ℤ) closed under products; at d = 1, η = U.
- `TDuality.Factorized`: factorized dualities D_k = [[I−e_k, e_k],[e_k, I−e_k]] (GPR eq. (2.4.29),
  ll. 1399–1422, "a generalization of the R → 1/R circle duality") are in O(d,d;ℤ), involutions,
  mutually commuting; on T², D₀D₁ = η; the charge norm Zᵀ η Z = 2 n·w is **even** (Γ^{d,d} is an
  even lattice) and **invariant** under all of O(d,d;ℤ). That these generators *generate*
  O(d,d;ℤ) is Tier L (GPR l. 1422).
- `TDuality.Spectrum`: every g ∈ O(d,d;ℤ) is invertible over ℤ with inverse η gᵀ η, again in
  O(d,d;ℤ); **spectrum equivalence**: for any background H there is an explicit bijection of the
  integer charge lattice under which (mass² = ZᵀHZ, level Zᵀ η Z) of the background gᵀHg equals
  that of H, charge by charge. Invariance of the full partition function (oscillators, modular
  integral; GPR l. 1417) is Tier L.
- `TDuality.Mirror`: on T², D₀ · diag(T, (Tᵀ)⁻¹) · D₀ = (g_Θ)ᵀ with T = [[1,1],[0,1]],
  Θ = [[0,−1],[1,0]] — the factorized duality turns the τ ↦ τ+1 generator into the form that acts
  on the generalized metric as an integer B-shift. The identification "factorized duality =
  mirror symmetry for a complex torus" is Tier L (GPR l. 344). The sign of the induced ρ-shift is
  convention-dependent and **not claimed**.
- `TDuality.SL2Product`: A J Aᵀ = det(A)·J for 2×2 integer A; basis changes and Θ-shifts obey
  their product laws; **a basis change with det A = 1 commutes with every ρ-translation g_{tJ}** (Tier A, this
  direction only; that the commutator is nonzero when det A ≠ 1 was checked symbolically with sympy
  and is NOT a Lean theorem — do not present it as Tier A). GPR "The d = 2 Example" (ll. 1874–1884): the
  duality group is SL(2,ℤ)×SL(2,ℤ) ⊗_S [Z₂×Z₂] — **not** claimed in full; only SL(2,ℤ)_τ commuting
  with the ρ-translations is Tier A.

### 3.3 Double Field Theory layer (over ℝ, every d)
- `DFT.GeneralizedMetric`: Hull–Zwiebach generalized metric
  H(G,B) = [[G − BG⁻¹B, BG⁻¹],[−G⁻¹B, G⁻¹]] (arXiv:0904.4664 eq. (2.17), ll. 662–672, with
  "H(E) satisfies the constraint H⁻¹ = ηHη"): **(ηH)² = 1 for any B** given G invertible (sharper
  than the source's statement); H symmetric for symmetric G and antisymmetric B; **T-duality is
  metric inversion**: η H(G,0) η = H(G⁻¹,0); mass form ZᵀHZ covariant under any g; on a circle
  (G = R², B = 0) the mass form equals half of Stream 1's P_L² + P_R², so Stream 2's DFT layer
  and Stream 1's circle computation provably agree.
- `DFT.BShift`: g_Θ · H(G,B) · g_Θᵀ = H(G, B+Θ) for antisymmetric Θ — integer B-field shifts act as
  O(d,d) conjugation; the convention was checked with sympy before formalization (exactly one
  of four candidate sign/transpose variants holds).
- `DFT.SectionCondition`: level matching L₀ − L̄₀ = N − N̄ − p·w = 0 (HZ eq. (1.3), l. 231) at N = N̄
  is exactly n·w = 0; the pure-momentum frame and the pure-winding frame are totally η-null
  (they solve the section condition; HZ ll. 339–342: "solutions independent of x̃ give the gravity
  field …; independent of xᵃ give dual versions"; ll. 3930–3940 "totally null d-dimensional
  subspaces"); η maps the momentum frame to the winding frame; O(d,d;ℤ) maps sections to sections.

### 3.4 Dual-scale bound (the project's central principle, generalized)
- `DualScale.TraceBound`: dual scale 𝒟(G) = tr H(G,0) = tr G + tr G⁻¹;
  **𝒟(G⁻¹) = 𝒟(G)** (T-duality invariant); **𝒟(G) ≥ 2d for every positive-definite G**
  (proof: tr((G−1)G⁻¹(G−1)) ≥ 0 expands to tr G + tr G⁻¹ − 2d; no eigenvalue decomposition);
  attained at the self-dual point G = 1; on a circle 𝒟(R²) = (R + 1/R)² − 2, recovering
  R + 1/R ≥ 2 — the d = 1 statement behind Stream 1's `EffectiveMetric.genesis_no_singularity`
  (R_eff = R + α'/R ≥ 2√α'). Cosmological readings (singularity resolution, minimum length)
  remain **Tier C**.

### 3.5 Flux and tadpole on K3 × T² / K3 × K3
- `Flux.Tadpole`: χ(T²) = 0 and χ(K3) = 24 from Hodge tables (K3's reused from Stream 1);
  χ(K3×K3)/24 = 24 and integral; χ(K3×T²) = 0; D3 budget: flux + n = 24 with flux ≥ 0 gives
  n ≤ 24, and n = 24 without flux. Tier L: Dasgupta–Rajesh–Sethi hep-th/9908088 §3.1 l. 640
  ("The anomaly χ/24 = 24"), ll. 1265–1275 (type IIB on an orientifold of K3×T²; with no flux,
  "type I on K3 × T² with 24 D5-branes"), ll. 1366–1370 (½∫G∧G + n = 24); Künneth.
- `Flux.Integrality`: the Kronecker product of an even symmetric integer form with any symmetric
  integer form is even; hence for G ∈ H²(K3)⊗H²(K3), ½∫G∧G ∈ ℤ. Tier L: DRS ll. 230–232 (Dirac
  quantization of [G/π], integrality of [G/2π] when χ/24 ∈ ℤ); Künneth identification of the form.

### 3.6 Moonshine
- see §2 item 4.

## 4. How it was produced (methods paragraph — keep factual)

Statements designed by the orchestrating model with every Tier L source pinned to a file and
line; proofs searched in tiers — a local 7B prover model (DeepSeek-Prover-V2, on a single T4 GPU)
first, then Claude Haiku, then Claude Sonnet — each candidate accepted only if the Lean kernel
compiled it; every agent report recompiled and statement-checked by the orchestrator (two
agent reports misstated compile status and were caught); final gate = build + `sorry` count +
`#print axioms`. Measured split and lessons: `docs/STREAM2_WORKFLOW.md` §6, `LL.md` §S2.
Mention AI assistance explicitly (paper 7 already has an "AI-assisted tooling" subsection).

## 5. Build instructions for the PDFs

`cd papers/publication && pdflatex -interaction=nonstopmode <file>.tex` twice (no bibtex:
papers use `thebibliography`). A PDF counts as regenerated only if the second pass exits 0 and
the log has no `! ` error lines and no undefined references (`LaTeX Warning: Reference`...).
