# Verified foundation — what other projects and sessions may build on

**Status as of 2026-09-17.** Release tag `v2.1.0` (commit `46af79b`) passed the full gate; the key-theorem
probe below was re-run on the working tree at `0b8215b` + documentation-only edits (statement lock OK).
Toolchain `leanprover/lean4:v4.33.1`, Mathlib tag `v4.33.1` (`0df444a3…`).

**Re-gated 2026-09-17 after the documentation pass** (40 `.lean` files, docstrings and comments only):
comment-stripped code byte-identical to the gated version for all 40 files; `lake build DualScaleStream2
StringTheoryFormalization` 3708 jobs, 0 errors; axiom audit 99 + 89 theorems, 0 failing; statement lock OK.

**Re-gated 2026-09-18 with Stream 3** (`DualScaleCosmology`, eighth library; release `v3.4.0`): all eight
libraries built together, 3781 jobs, 0 errors; axiom audit re-run on every library (counts below unchanged
for the first seven); `DualScaleCosmology` 31 theorems, 0 failing; its statement lock covers 44 declarations
in 7 files. Total audited: **425 + 31 = 456 theorems**.

**`v3.5.0` (2026-09-18) changes no `.lean` file**: it revises paper 7 (Revision 4, external peer review), a
figure caption in papers 1/7/8, book chapter 38, and `tools/check_book_lean_names.py`. Every gate result above
applies unchanged.

**`v3.6.0` (2026-09-18): one theorem added to `DualScaleStream2`**, `dualScale_eq_iff` (uniqueness of the
dual-scale minimizer), in response to an external review recorded in `docs/reviews/`. Gates re-run on that
tree: eight-library build 3781 jobs, 0 errors; `DualScaleStream2` audit 100 theorems, 0 failing; statement
lock reported exactly one change (`ADDED dualScale_eq_iff`) before it was locked. Total audited: **457**.
Earlier paragraphs above record the counts at their own dates (99 / 425 / 456) and are left as written.

**`v3.7.0` (2026-09-18): ninth library `DualScaleMoonshine` (Stream 4, `docs/STREAM4_WORKFLOW.md`)**,
importing Stream 2. It computes the Mathieu-moonshine coefficients from a closed formula instead of
reading them from a table, twines them, checks them against the `M₂₄` character table, and applies the
twining test to paper 7's "27720 lock", which fails it. Gates: nine-library build 3787 jobs, 0 errors;
`DualScaleMoonshine` 28 theorems, 0 failing (axioms: `propext` only); statement lock 52 declarations in 4
files; no file of the other eight libraries changed. Total audited: **485**.

**`v3.8.0`, `v3.8.1` (2026-09-18): Stream 4 phase P4.3 completed at every conjugacy class.** Two files added to
`DualScaleMoonshine`: `TwiningAll.lean` computes the sixteen remaining twined series of Cheng–Duncan–Harvey's
Table 20 (eta quotients, the newforms `f₁₁, f₁₄, f₁₅, f₂₃,ₐ, f₂₃,ᵦ`, prefactors `2/5, 1/3, 1/4, 1/3, 1/11`)
and proves each equal to the printed column through `q⁹`; `CharactersAll.lean` transcribes the full `M₂₄`
character table over `ℤ[b₇]`, `ℤ[b₁₅]`, `ℤ[b₂₃]`, guards it (centralizer orders from column norms, class
equation, full row orthogonality), and proves that at **all 26 classes** and levels 1–7 the traces on EOT's
representations equal the computed twined coefficients. The forger's test now fails at all 25 non-identity
classes. Gates: nine-library build 3789 jobs, 0 errors; `DualScaleMoonshine` 68 theorems, 0 failing
(axioms: `propext` only); statement lock 153 declarations in 6 files (the pre-update check showed the four
existing files unchanged and only the two new files unlocked); no file of the other eight libraries
changed. Counts are those of `v3.8.1`, which adds `eta_lambda_agree_2B/4A` (CDH's two forms printed both as
`Λ`-combinations and as eta quotients agree through `q⁹`); `v3.8.0` had 66 / 523. Total audited: **525**.

**`v3.9.0` (2026-09-18): Stream 4 phase P4.4 — the arithmetic skeleton of the shadow.** `Shadow.lean`
computes the K3 elliptic genus from theta products (`Z(τ,0) = 24`), and proves that its polar/finite
decomposition `Ψ₁,₁Z = 24·Av⁽²⁾[(y+1)/(y−1)] + H·θ̂₁` (CDH §2.3, cleared of denominators) holds through `q⁹`
with the independently computed `H`, and fails for polar multiplicity `23` or `25`; the shadow theta
series `S₁⁽²⁾` equals `η³`; the twined shadow multiplicities are traces on `1 ⊕ 23`. The shadow property
itself (completion, modularity) remains Tier L. Gates: nine-library build 3790 jobs, 0 errors;
`DualScaleMoonshine` 76 theorems, 0 failing (axioms: `propext` only); statement lock 190 declarations in
7 files (pre-update check: only `Shadow.lean` new). Total audited: **533**.

**`v3.10.0` (2026-09-18): Stream 4 phase P4.6 — Harvey–Murthy–Nazaroglu's DSLST index reproduced; Stream 4
complete.** `HMNBridge.lean`: HMN's closed formula for the BPS index `χ₂^Y` reproduces their printed series;
at `k = 2` it equals `−½η³H`; their umbral relation (4.9) holds for `ℓ = 2, 3, 4, 5, 7, 13` through `q⁶`
with umbral forms built from theta functions; their divisibility observation is proved in both directions
(`rk(Y) ∣` all coefficients iff `rk(Y) ∣ 24`) for all `A`, all `D` and `E₆₇₈`. The link to Stream 2's
`(−2)`-reflections is closed as not available (it needs Niemeier lattices). Gates: nine-library build
3791 jobs, 0 errors; `DualScaleMoonshine` 98 theorems, 0 failing; statement lock 234 declarations in
8 files (pre-update check: only `HMNBridge.lean` new). Total audited: **555**.

**`v3.11.0` (2026-09-18): tenth library `DualScaleDyons` (Stream 5, `docs/STREAM5_WORKFLOW.md`)**, importing
Stream 4. From the K3 elliptic genus computed in Stream 4 it builds the DMVV/Borcherds product for the
quarter-BPS dyon partition function `1/Φ₁₀` on K3 × T² (Dabholkar–Murthy–Zagier) and proves, through the
orders stated: the index-1 Jacobi property of `Z_K3`; an enumerated reachability guard for the truncated
product; Göttsche's `p₂₄(k)` for `k ≤ 5`; DMZ's six printed identities (5.16); the strip expansion (9.55);
that the polar part `p₂₄(m+1)A₂,ₘ` removes the double pole of `ψ_m` (and `p₂₄ ± 1` do not), `m = 1, 2, 3`;
and that the single-centred counting function `∆ψ₁^F` equals `3E₄A − 648H` with `H` the Hurwitz class
numbers, counted independently. Gates: ten-library build 3795 jobs, 0 errors; `DualScaleDyons` 17
theorems, 0 failing (axioms: `propext` only); statement lock 48 declarations in 2 files; no file of the
other nine libraries changed. Total audited: **572**. `v3.11.1` adds `negBinom_exact` (the integer
divisions inside the product are exact; 18 theorems, 50 declarations) and clarifies that the polar-part
theorems discriminate the first-order pole condition. Total audited: **573**.

**`v3.12.0` (2026-09-18): Stream 5 phase P5.6 — immortal dyons at `m = 2, 3`, and the twining test.**
`ImmortalHigher.lean`: DMZ's (9.11) and (9.13) at `m = 2, 3` checked (the finite parts of `ψ₀,₃^opt/A`,
`ψ₀,₄^opt/A` are `−12^{m+1}·H|V_m`); the single-centred counting functions `∆ψ₂^F`, `∆ψ₃^F` from the product
equal `p₂₄(m+1)·(−H|V_m)` plus explicit weak Jacobi forms; without the Hecke correction the `m = 2`
identity fails. `TwinedHilbert.lean`: CDH's Frame shapes cross-checked against the power maps; for
`k ≤ 4` the twined Göttsche numbers `Tr(g | H*(Hilbᵏ K3))` are characters of `M₂₄` (non-negative integer
multiplicities over all 26 irreducibles). Gates: ten-library build 3797 jobs, 0 errors; `DualScaleDyons`
32 theorems, 0 failing (`propext` or none); statement lock 74 declarations in 4 files (pre-update check:
only the two new files). Total audited: **587**.

**`v3.13.0` (2026-09-18): Stream 5 phase P5.7 — `M₂₄`-twisted dyons; Stream 4 levels 8–9 closed.**
`DualScaleDyons/TwistedDyons.lean`: the 26 twisted K3 elliptic genera `Z_g = (χ_g/24)Z − F_g·A` from Stream 4's
data (integral, index 1, `Z_g(τ,0) = χ_g`); Cheng's twisted denominators `1/Φ_g` by the plethystic product
with Newton's identities and CDH's power maps (untwisted case recovered; `z = 0` gives the twined Göttsche
numbers); all coefficients of `G₁^{(g)}, G₂^{(g)}` and of the twisted single-centred counting function at
`m = 1` are virtual characters of `M₂₄` (through `q²`). `DualScaleMoonshine/Decompositions.lean`: for
`n = 0 … 9` the computed twined series decompose with integer multiplicities equal to CDH Table 48 (levels
8, 9 were open in Stream 4); EOT's original level-7 proposal is inconsistent (Cheng). Gates: ten-library
build 3799 jobs, 0 errors; `DualScaleMoonshine` 101 theorems, `DualScaleDyons` 42 theorems, 0 failing;
statement locks: only the two new files added. Total audited: **600**. `v3.13.1` adds `TwistedNotes.lean`
(`c_g(−1) = +2` for all 26 classes, checked; Cheng's printed `−2` at l. 960 is a sign convention or misprint).
Total audited: **602**.

**`v3.14.0` (2026-09-18): Stream 6 — experimental verdict.** `DualScaleCosmology/Stream6Verdict.lean` (9 theorems):
the frozen prediction P1 (`docs/STREAM6_PREDICTION_P1.md`, tag `stream6-p1-frozen`), `R = s = √(ℓ_P c/H₀) ≈ 47 μm`
for one large extra dimension, fails Eöt-Wash 2020's radius (`30 μm`) and Yukawa-range (`38.6 μm`) bounds and
MVV's neutron-star bound (`44 μm`): **excluded** by the pre-registered rule; the programme's T-duality fixes the
`O(1)` factor at `κ = 1`. `DualScaleCosmology` 40 theorems, 0 failing. Total audited: **611**.

**`v3.15.0` (2026-09-18): Stream 7, candidate C-A.** `DualScaleCosmology/Stream7CA.lean` (5 theorems): frozen C-A
(tag `stream7-ca-frozen`) — CKN saturation with infrared length `c/H` and conserved matter give `H² = C/a³` and
`q = 1/2` for every `ε`; Planck 2018 (flat ΛCDM) gives `q₀ < 0`: **excluded** (retrodiction, disclosed).
`DualScaleCosmology` 45 theorems, 0 failing. Total audited: **616**.

**`v3.16.0` (2026-09-18): Stream 7, candidate C-B.** `DualScaleCosmology/Stream7CB.lean` (5 theorems): frozen C-B (tag
`stream7-cb-frozen`, before any sensitivity was pinned) — pre-big-bang relic gravitons with `α' = s²`: `g₁² ≈ 1.2 × 10⁻⁶¹`,
spectrum ending at `≈ 6 × 10⁻⁵ Hz` with peak `Ω ≈ 10⁻⁶⁵`; LISA (`1702_00786.txt` ll. 692–699) cannot reach it: **not
falsifiable in practice**. `DualScaleCosmology` 50 theorems, 0 failing. Total audited: **621**.

**Book name checker — a latent bug found and fixed (2026-09-18).** `tools/check_book_lean_names.py` sends every
name it cannot resolve locally to Lean in one probe file. Lean stops reporting after `maxErrors` (default 100)
errors, so **every name after the 100th error in the probe passed silently**; earlier "0 unknown to Lean"
reports were therefore incomplete for books whose probe exceeded 100 errors. Fix: the probe now runs with
`-DmaxErrors=1000000` and the tool aborts if Lean reports hitting the limit; chapters 39–41 and the Streams 4–5
libraries were added to its scope. After the fix it flagged 51 names; triage found **no name presented as a real
library result that does not exist** (all were exercise/hypothetical names, tactics, options, versions, files,
locals, or real declarations cited by short names); 45 allowlist entries with reasons were added, 7 of them with a
target that the tool verifies with `#check`. Negative controls (a bogus name appended to a chapter) are flagged.

**`v3.18.0` (2026-09-18): book Part IX (ch39–41, 753 pages) and Stream 8 (`docs/STREAM8_WHICH_K3.md`).**
`DualScaleDyons/WhichK3.lean` (5 theorems): attractive (ρ = 20) K3s, dyon charges (Moore) and the immortal index
share the reduced binary forms; `12·N(D) = 12·H(D) + 6·[D = 4f²] + 8·[D = 3f²]` for `D ≤ 400` — the counts differ only
at the self-dual points of the torus; Kummer criterion; the first Kummer attractive K3s (`D = 12, 16`); the Fermat
quartic's form. `DualScaleDyons` 49 theorems, 0 failing. Total audited: **626**.

**`v3.19.0` (2026-09-18): Stream 8 E2.** `DualScaleDyons/SelfDualT2.lean` (7 theorems): exact, complete counts of
massless gauge bosons — circle at the self-dual radius 2, T² at `(i, i)` 4 + 4, T² at `(ω, ω)` 6 + 6 (completeness by a
sum-of-squares bound); the `(ω, ω)` roots span `A₂`, isometric to `T(X₃)` of the most attractive K3. With moduli
trapping (hep-th/0403001, Tier L) this selects `(ω, ω)` for T². `DualScaleDyons` 56 theorems, 0 failing. Total
audited: **633**.

**`v3.20.0` (2026-09-18): Stream 8 E3.** `DualScaleDyons/KummerE3.lean` (7 theorems): the Kummer glue code on `𝔽₂⁴`
(30 affine hyperplanes, rank 5, weights `0/8/16` with multiplicities `1/30/1`, `disc Π = 2⁶`); **every** root of the
Kummer lattice is one of the 32 vectors `±E_a` (`A₁¹⁶`, proof for all integer vectors, not a search); the extended
Golay code built from quadratic residues mod 23 (rank 12, weights `1/759/2576/759/1`); for an explicit octad, the 32
Golay words disjoint from it are, through an explicit bijection of the complement with `𝔽₂⁴`, exactly the Kummer
glue code — the Kummer split `24 = 8 + 16` is the octad split (Taormina–Wendland 1107.3834, Tier L for the lattice
embedding). `DualScaleDyons` 63 theorems, 0 failing. Total audited: **640**. `v3.16.1`: two C-B
statements restated with named quantities (`omegaPeak`, `omegaLisaBest`) after review — the statement lock reported
exactly these two CHANGED plus the two new definitions ADDED; C-B's premise noted as already excluded (Stream 3 P3.7).

## 1. Gate results (run by the orchestrator, not reported by a subagent)
| Gate | `DualScaleStream2` | `StringTheoryFormalization` | Mathlib-free core (5 libraries) | `DualScaleCosmology` (Stream 3) | `DualScaleMoonshine` (Stream 4) |
|---|---|---|---|---|---|
| `lake build <lib>` | 3670 jobs, 0 errors | 3296 jobs, 0 errors | 61 jobs, 0 errors | built with all nine: 3791 jobs, 0 errors | built with all nine: 3791 jobs, 0 errors |
| `sorry` in source | 0 | 0 | 0 | 0 (also no `admit`, `native_decide`, `axiom`) | 0 (also no `admit`, `native_decide`, `axiom`) |
| `tools/axiom_audit.py` | 100 theorems, 0 failing | 89 theorems, 0 failing | 23 + 53 + 44 + 56 + 61 = 237 theorems, 0 failing | 31 theorems, 0 failing | 98 theorems, 0 failing |
| `tools/statement_lock.py --check` | OK (151 declarations) | locked 2026-09-17 (205 declarations) | not locked | OK (44 declarations, 7 files) | OK (234 declarations, 8 files) |

"0 failing" means: every theorem depends on no axioms beyond `propext`, `Classical.choice`, `Quot.sound`
(no `sorryAx`, no `native_decide`/`Lean.ofReduceBool`). Total audited: 100 + 326 + 31 = 457 theorems.

**Downstream use is tested**: `examples/consumer_demo/` is a separate Lake project that `require`s this
package, imports `DualScaleStream2` and `StringTheoryFormalization`, and proves a new statement from
`thetaShift_isODD` and `isODD_mul` (build: 3709 jobs, 0 errors; axioms of the reused theorem: the standard three).

## 2. What "verified" does and does not cover
* **Tier A (kernel-checked)**: exactly the Lean statements, as written. Section 3 prints them verbatim
  from `#check`. Read the statement, not its name or docstring.
* **Not Tier A**: that these matrices, lattices and inequalities *are* string theory. The physical
  identification is Tier L (literature; pinned in `papers/foundations/`) or Tier C (conjecture, in
  particular every cosmological use of the dual-scale bound).
* **Signature theorems are bookkeeping**: `sigK3_eq` / `sigMukai_eq` / `sigK3T2_eq` add signature records whose
  inputs `sigU = (1,1)` and `sigE8Neg = (0,8)` are definitions marked Tier L in the source; they are not computed
  from the Gram matrices. (Positive definiteness of `E8` is proved separately: `cartanE8_posDef`.)
* **One-direction results stay one-direction**: `thetaShift_isODD` (antisymmetric Θ ⇒ O(d,d), not ⇔);
  `basisChange_comm_thetaShift` (det A = 1 ⇒ commute; the converse was only checked symbolically);
  `dualScale_one` (bound attained at G = 1) — uniqueness of the minimizer *was* one-directional until
  `v3.6.0`, and is now proved as `dualScale_eq_iff` (at B = 0 only; nothing is proved for B ≠ 0);
  generation of O(d,d;ℤ) by the exhibited elements is Tier L (GPR), not proved.
* **Depth differs by library**: `DualScaleStream2` and much of `StringTheoryFormalization` are genuine linear
  algebra over ℤ/ℝ with Mathlib. The five Mathlib-free libraries model physical quantities by integers or
  rationals ("arithmetic shadows"): kernel-checked, but thin. Several facts are proved more than once in
  different libraries (see `papers/book/generated/atlas.md`, "Unification candidates"); build on the
  `DualScaleStream2` version.

* **Stream 3 (`DualScaleCosmology`) is mostly identifications, and they are Tier C.** Its theorems are real
  algebra and calculus over ℝ, plus `norm_num` arithmetic on constants read from pinned sources and `astropy`.
  Every *physical* reading — the two scales as a T-dual pair, CKN's `M = 1/ℓ_micro`, `ρ_Λ` as `Ω_Λ` times the
  critical density, the dual-tower product `M₁M₂ = M₀²` — enters as an explicit hypothesis or definition and is
  labelled Tier C in the source. Headline results, with their honest scope, are in `docs/STREAM3_WORKFLOW.md` §6:
  the self-dual length `√(ℓ_P · c/H₀) ≈ 47 μm` is the dark-energy length up to `(8π/3Ω_Λ)^{1/4}` (an identity,
  so CKN's and MVV's numbers agreeing with it is algebra, not corroboration); it is **excluded as a Regge slope**
  (≥ 10³⁰ in `α'`, CMS dijets, model-dependent); it is **not excluded** as a single extra-dimension radius
  (disfavored by O(1) factors only).

## 3. Key theorems, verbatim from Lean (`#check`), with their axioms (`#print axioms`)


### `DualScaleStream2.Lattice.E8`

* **`DualScaleStream2.Lattice.cartanE8_unimodular`**  
  `DualScaleStream2.Lattice.IsUnimodular DualScaleStream2.Lattice.cartanE8`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.Lattice.E8PosDef`

* **`DualScaleStream2.Lattice.cartanE8_posDef`**  
  `DualScaleStream2.Lattice.cartanE8R.PosDef`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Lattice.cartanE8_det`**  
  `Matrix.det DualScaleStream2.Lattice.cartanE8 = 1`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.Lattice.Hyperbolic`

* **`DualScaleStream2.Lattice.hyperbolicU_unimodular`**  
  `DualScaleStream2.Lattice.IsUnimodular DualScaleStream2.Lattice.hyperbolicU`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Lattice.hyperbolicU_eq_narain_gram`**  
  `DualScaleStream2.Lattice.hyperbolicU = StringTheory.UseCases.NarainLattice.gram`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.Lattice.K3T2Signature`

* **`DualScaleStream2.Lattice.sigK3_eq`**  
  `DualScaleStream2.Lattice.sigK3 = { pos := 3, neg := 19 }`  
  axioms: none
* **`DualScaleStream2.Lattice.sigMukai_eq`**  
  `DualScaleStream2.Lattice.sigMukai = { pos := 4, neg := 20 }`  
  axioms: none
* **`DualScaleStream2.Lattice.sigK3T2_eq`**  
  `DualScaleStream2.Lattice.sigK3T2 = { pos := 6, neg := 22 }`  
  axioms: none
* **`DualScaleStream2.Lattice.index_mod_eight`**  
  `DualScaleStream2.Lattice.sigK3.index % 8 = 0 ∧ DualScaleStream2.Lattice.sigMukai.index % 8 = 0 ∧ DualScaleStream2.Lattice.sigK3T2.index % 8 = 0`  
  axioms: none

### `DualScaleStream2.Lattice.Mukai`

* **`DualScaleStream2.Lattice.mukaiPair_even`**  
  `∀ {n : ℕ} (L : DualScaleStream2.Lattice.Gram n), Matrix.transpose L = L → DualScaleStream2.Lattice.IsEvenDiag L → ∀ (v : DualScaleStream2.Lattice.MukaiVec n), Even (DualScaleStream2.Lattice.mukaiPair L v v)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Lattice.structureSheaf_mukai_sq`**  
  `∀ {n : ℕ} (L : DualScaleStream2.Lattice.Gram n), DualScaleStream2.Lattice.mukaiPair L { r := 1, c := 0, s := 1 } { r := 1, c := 0, s := 1 } = -2`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.Lattice.Reflection`

* **`DualScaleStream2.Lattice.reflection_isometry`**  
  `∀ {n : ℕ} (L : DualScaleStream2.Lattice.Gram n), Matrix.transpose L = L → ∀ (v : Fin n → ℤ), DualScaleStream2.Lattice.latticeNorm L v = -2 → Matrix.transpose (DualScaleStream2.Lattice.reflection L v) * L * DualScaleStream2.Lattice.reflection L v = L`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Lattice.reflection_involution`**  
  `∀ {n : ℕ} (L : DualScaleStream2.Lattice.Gram n) (v : Fin n → ℤ), DualScaleStream2.Lattice.latticeNorm L v = -2 → DualScaleStream2.Lattice.reflection L v * DualScaleStream2.Lattice.reflection L v = 1`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Lattice.e8Neg_weyl_isometry`**  
  `∀ (i : Fin 8), Matrix.transpose (DualScaleStream2.Lattice.reflection DualScaleStream2.Lattice.e8Neg (Pi.single i 1)) * DualScaleStream2.Lattice.e8Neg * DualScaleStream2.Lattice.reflection DualScaleStream2.Lattice.e8Neg (Pi.single i 1) = DualScaleStream2.Lattice.e8Neg`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.TDuality.ODD`

* **`DualScaleStream2.TDuality.thetaShift_isODD`**  
  `∀ {d : ℕ} (Θ : Matrix (Fin d) (Fin d) ℤ), Θ.transpose = -Θ → DualScaleStream2.TDuality.IsODD (DualScaleStream2.TDuality.thetaShift Θ)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.TDuality.basisChange_isODD`**  
  `∀ {d : ℕ} (A B : Matrix (Fin d) (Fin d) ℤ), A.transpose * B = 1 → DualScaleStream2.TDuality.IsODD (DualScaleStream2.TDuality.basisChange A B)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.TDuality.eta_isODD`**  
  `∀ {d : ℕ}, DualScaleStream2.TDuality.IsODD (DualScaleStream2.TDuality.eta d)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.TDuality.isODD_mul`**  
  `∀ {d : ℕ} (g h : Matrix (DualScaleStream2.TDuality.Charge d) (DualScaleStream2.TDuality.Charge d) ℤ), DualScaleStream2.TDuality.IsODD g → DualScaleStream2.TDuality.IsODD h → DualScaleStream2.TDuality.IsODD (g * h)`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.TDuality.Factorized`

* **`DualScaleStream2.TDuality.factorized_isODD`**  
  `∀ {d : ℕ} (k : Fin d), DualScaleStream2.TDuality.IsODD (DualScaleStream2.TDuality.factorized k)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.TDuality.factorized_mul_self`**  
  `∀ {d : ℕ} (k : Fin d), DualScaleStream2.TDuality.factorized k * DualScaleStream2.TDuality.factorized k = 1`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.TDuality.chargeNorm_invariant`**  
  `∀ {d : ℕ} (g : Matrix (DualScaleStream2.TDuality.Charge d) (DualScaleStream2.TDuality.Charge d) ℤ), DualScaleStream2.TDuality.IsODD g → ∀ (Z : DualScaleStream2.TDuality.Charge d → ℤ), DualScaleStream2.TDuality.chargeNorm (g.mulVec Z) = DualScaleStream2.TDuality.chargeNorm Z`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.TDuality.Spectrum`

* **`DualScaleStream2.TDuality.spectrum_equivalence`**  
  `∀ {d : ℕ} (g : Matrix (DualScaleStream2.TDuality.Charge d) (DualScaleStream2.TDuality.Charge d) ℤ), DualScaleStream2.TDuality.IsODD g → ∀ (H : Matrix (DualScaleStream2.TDuality.Charge d) (DualScaleStream2.TDuality.Charge d) ℝ), ∃ e, ∀ (Z : DualScaleStream2.TDuality.Charge d → ℤ), ((DualScaleStream2.DFT.massForm ((DualScaleStream2.TDuality.toReal g).transpose * H * DualScaleStream2.TDuality.toReal g) fun i ↦ ↑(Z i)) = DualScaleStream2.DFT.massForm H fun i ↦ ↑(e Z i)) ∧ DualScaleStream2.TDuality.chargeNorm (e Z) = DualScaleStream2.TDuality.chargeNorm Z`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.TDuality.Mirror`

* **`DualScaleStream2.TDuality.mirror_conjugates_tauShift`**  
  `DualScaleStream2.TDuality.factorized 0 * DualScaleStream2.TDuality.basisChange DualScaleStream2.TDuality.tauShift DualScaleStream2.TDuality.tauShiftDual * DualScaleStream2.TDuality.factorized 0 = (DualScaleStream2.TDuality.thetaShift DualScaleStream2.TDuality.mirrorTheta).transpose`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.TDuality.SL2Product`

* **`DualScaleStream2.TDuality.basisChange_comm_thetaShift`**  
  `∀ (A B : Matrix (Fin 2) (Fin 2) ℤ), A.transpose * B = 1 → A.det = 1 → ∀ (t : ℤ), DualScaleStream2.TDuality.basisChange A B * DualScaleStream2.TDuality.thetaShift (t • DualScaleStream2.TDuality.jMat) = DualScaleStream2.TDuality.thetaShift (t • DualScaleStream2.TDuality.jMat) * DualScaleStream2.TDuality.basisChange A B`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.DFT.GeneralizedMetric`

* **`DualScaleStream2.DFT.etaR_genMetric_sq`**  
  `∀ {d : ℕ} (G B : Matrix (Fin d) (Fin d) ℝ), IsUnit G.det → DualScaleStream2.DFT.etaR d * DualScaleStream2.DFT.genMetric G B * (DualScaleStream2.DFT.etaR d * DualScaleStream2.DFT.genMetric G B) = 1`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DFT.genMetric_symm`**  
  `∀ {d : ℕ} (G B : Matrix (Fin d) (Fin d) ℝ), IsUnit G.det → G.transpose = G → B.transpose = -B → (DualScaleStream2.DFT.genMetric G B).transpose = DualScaleStream2.DFT.genMetric G B`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DFT.tduality_inverts_metric`**  
  `∀ {d : ℕ} (G : Matrix (Fin d) (Fin d) ℝ), IsUnit G.det → DualScaleStream2.DFT.etaR d * DualScaleStream2.DFT.genMetric G 0 * DualScaleStream2.DFT.etaR d = DualScaleStream2.DFT.genMetric G⁻¹ 0`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DFT.massForm_covariant`**  
  `∀ {d : ℕ} (g H : Matrix (DualScaleStream2.TDuality.Charge d) (DualScaleStream2.TDuality.Charge d) ℝ) (Z : DualScaleStream2.TDuality.Charge d → ℝ), DualScaleStream2.DFT.massForm (g.transpose * H * g) Z = DualScaleStream2.DFT.massForm H (g.mulVec Z)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DFT.massForm_circle`**  
  `∀ (n w R : ℚ), R ≠ 0 → DualScaleStream2.DFT.massForm (DualScaleStream2.DFT.genMetric !![↑R ^ 2] 0) (Sum.elim ![↑w] ![↑n]) = ↑(StringTheory.UseCases.TDuality.momentumMassSq n w R) / 2`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.DFT.BShift`

* **`DualScaleStream2.DFT.genMetric_bshift`**  
  `∀ {d : ℕ} (G B Θ : Matrix (Fin d) (Fin d) ℝ), IsUnit G.det → G.transpose = G → B.transpose = -B → Θ.transpose = -Θ → DualScaleStream2.DFT.thetaShiftR Θ * DualScaleStream2.DFT.genMetric G B * (DualScaleStream2.DFT.thetaShiftR Θ).transpose = DualScaleStream2.DFT.genMetric G (B + Θ)`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.DFT.SectionCondition`

* **`DualScaleStream2.DFT.isSection_image`**  
  `∀ {d : ℕ} (g : Matrix (DualScaleStream2.TDuality.Charge d) (DualScaleStream2.TDuality.Charge d) ℤ), DualScaleStream2.TDuality.IsODD g → ∀ (S : Set (DualScaleStream2.TDuality.Charge d → ℤ)), DualScaleStream2.DFT.IsSection S → DualScaleStream2.DFT.IsSection ((fun Z ↦ g.mulVec Z) '' S)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DFT.momentumFrame_isSection`**  
  `∀ {d : ℕ}, DualScaleStream2.DFT.IsSection (DualScaleStream2.DFT.momentumFrame d)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DFT.levelMatching_iff`**  
  `∀ {d : ℕ} (n w : Fin d → ℤ), DualScaleStream2.TDuality.chargeNorm (Sum.elim n w) = 0 ↔ n ⬝ᵥ w = 0`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.DualScale.TraceBound`

* **`DualScaleStream2.DualScale.dualScale_ge`**  
  `∀ {d : ℕ} (G : Matrix (Fin d) (Fin d) ℝ), G.PosDef → 2 * ↑d ≤ DualScaleStream2.DualScale.dualScale G`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DualScale.dualScale_inv`**  
  `∀ {d : ℕ} (G : Matrix (Fin d) (Fin d) ℝ), IsUnit G.det → DualScaleStream2.DualScale.dualScale G⁻¹ = DualScaleStream2.DualScale.dualScale G`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DualScale.dualScale_one`**  
  `∀ {d : ℕ}, DualScaleStream2.DualScale.dualScale 1 = 2 * ↑d`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DualScale.circle_effective_scale_ge_two`**  
  `∀ (R : ℝ), 0 < R → 2 ≤ R + R⁻¹`  
  axioms: Classical.choice, Quot.sound, propext

* **`DualScaleStream2.DualScale.dualScale_eq_iff`** (added `v3.6.0`)  
  `∀ {d : ℕ} (G : Matrix (Fin d) (Fin d) ℝ), G.PosDef → (DualScaleStream2.DualScale.dualScale G = 2 * ↑d ↔ G = 1)`  
  axioms: propext, Classical.choice, Quot.sound

### `DualScaleStream2.Flux.Tadpole`

* **`DualScaleStream2.Flux.k3k3_anomaly`**  
  `DualScaleStream2.Flux.chiK3K3 % 24 = 0 ∧ DualScaleStream2.Flux.chiK3K3 / 24 = 24`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Flux.tadpole_budget`**  
  `∀ (flux n : ℕ), flux + n = 24 → n ≤ 24 ∧ (flux = 0 → n = 24)`  
  axioms: Quot.sound, propext
* **`DualScaleStream2.Flux.k3t2_euler_zero`**  
  `DualScaleStream2.Flux.eulerFromHodge StringTheory.Frontier.k3HodgeNumber * DualScaleStream2.Flux.eulerFromHodge DualScaleStream2.Flux.t2HodgeNumber = 0`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.Flux.Integrality`

* **`DualScaleStream2.Flux.flux_half_selfIntersection_integral`**  
  `∀ {n m : ℕ} (L₁ : DualScaleStream2.Lattice.Gram n) (L₂ : DualScaleStream2.Lattice.Gram m), Matrix.transpose L₁ = L₁ → Matrix.transpose L₂ = L₂ → DualScaleStream2.Lattice.IsEvenDiag L₁ → ∀ (x : Fin n × Fin m → ℤ), ∃ k, x ⬝ᵥ (DualScaleStream2.Flux.kronForm L₁ L₂).mulVec x = 2 * k`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.Moonshine.EOT`

* **`DualScaleStream2.Moonshine.first_five_are_irreps`**  
  `∀ (n : Fin 5), ∃ i, StringTheory.StringDynamics.M24RepDim i = DualScaleStream2.Moonshine.eotA (Fin.castLE ⋯ n)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Moonshine.A6_decomposition`**  
  `DualScaleStream2.Moonshine.eotA 5 = StringTheory.StringDynamics.M24RepDim 21 + StringTheory.StringDynamics.M24RepDim 25`  
  axioms: Quot.sound, propext

### `StringTheoryFormalization.UseCases.TDualityMassSpectrum`

* **`StringTheory.UseCases.TDuality.tduality_invariant_mass_squared`**  
  `∀ (n w R : ℚ), R ≠ 0 → StringTheory.UseCases.TDuality.momentumMassSq w n (1 / R) = StringTheory.UseCases.TDuality.momentumMassSq n w R`  
  axioms: Classical.choice, Quot.sound, propext
* **`StringTheory.UseCases.TDuality.self_dual_radius_unique`**  
  `∀ (R : ℚ), 0 < R → 1 / R = R → R = 1`  
  axioms: Classical.choice, Quot.sound, propext

### `StringTheoryFormalization.UseCases.NarainLattice`

* **`StringTheory.UseCases.NarainLattice.narain_form_even`**  
  `∀ (n w : ℤ), Even (StringTheory.UseCases.NarainLattice.Q n w)`  
  axioms: propext
* **`StringTheory.UseCases.NarainLattice.narain_gram_unimodular`**  
  `StringTheory.UseCases.NarainLattice.gram.det = -1`  
  axioms: Classical.choice, Quot.sound, propext

### `StringTheoryFormalization.UseCases.CriticalDimension`

* **`StringTheory.UseCases.CriticalDimension.bosonic_string_critical_dimension`**  
  `26 * 1 + StringTheory.UseCases.CriticalDimension.fermionicGhostCharge 2 = 0`  
  axioms: Classical.choice, Quot.sound, propext
* **`StringTheory.UseCases.CriticalDimension.superstring_critical_dimension`**  
  `10 * 1 + 10 * (1 / 2) + StringTheory.UseCases.CriticalDimension.fermionicGhostCharge 2 + StringTheory.UseCases.CriticalDimension.bosonicGhostCharge (3 / 2) = 0`  
  axioms: Classical.choice, Quot.sound, propext

### `StringTheoryFormalization.UseCases.K3SignatureTheorem`

* **`StringTheory.UseCases.K3Signature.k3_signature_eq_neg_sixteen`**  
  `↑StringTheory.UseCases.K3Signature.bPlus - ↑StringTheory.UseCases.K3Signature.bMinus = -16`  
  axioms: Classical.choice, Quot.sound, propext

### `StringTheoryFormalization.StringDynamics.MathieuM24`

* **`StringTheory.StringDynamics.M24_order`**  
  `244823040 = 2 ^ 10 * 3 ^ 3 * 5 * 7 * 11 * 23`  
  axioms: propext
* **`StringTheory.StringDynamics.M24RepDim_sum_sq`**  
  `∑ i, StringTheory.StringDynamics.M24RepDim i ^ 2 = 244823040`  
  axioms: Classical.choice, Quot.sound, propext

### `StringTheoryFormalization.UseCases.MathieuTower`

* **`StringTheory.UseCases.MathieuTower.mathieu_tower_consistent`**  
  `24 * (23 * (22 * StringTheory.UseCases.MathieuTower.orderM21)) = 244823040`  
  axioms: propext

### `StringTheoryFormalization.Frontier.FTermPotential`

* **`StringTheory.Frontier.fterm_potential_nonneg`**  
  `∀ (W : StringTheory.Frontier.GVWSuperpotential) (τ : ℂ), 0 < τ.im → 0 ≤ ‖StringTheory.Frontier.fTermCondition W τ‖ ^ 2`  
  axioms: Classical.choice, Quot.sound, propext
* **`StringTheory.Frontier.no_scale_identity`**  
  `3 = 3`  
  axioms: Quot.sound, propext

### `DualScaleCosmology` (Stream 3; probe re-run 2026-09-18 on the `v3.4.0` tree)
* **`ScaleFactorDuality.hubble_dual`**  
  `∀ (a : ℝ → ℝ) (t : ℝ), a t ≠ 0 → DifferentiableAt ℝ a t → ScaleFactorDuality.hubble (fun s => ScaleFactorDuality.scaleFactorDual (a s)) t = -ScaleFactorDuality.hubble a t`  
  axioms: propext, Classical.choice, Quot.sound
* **`ScaleFactorDuality.cosmoDualScale_ge_two`**  
  `∀ {a : ℝ}, 0 < a → 2 ≤ ScaleFactorDuality.cosmoDualScale a`  
  axioms: propext, Classical.choice, Quot.sound
* **`CKNBound.ckn_bound`**  
  `∀ (L Λ M : ℝ), 0 < L → L ^ 3 * Λ ^ 4 ≤ L * M ^ 2 → L ^ 2 * Λ ^ 4 ≤ M ^ 2`  
  axioms: propext, Classical.choice, Quot.sound
* **`CKNBound.ckn_L_Lambda_sq_le`**  
  `∀ (L Λ M : ℝ), 0 < L → 0 < Λ → 0 < M → L ^ 2 * Λ ^ 4 ≤ M ^ 2 → L * Λ ^ 2 ≤ M`  
  axioms: propext, Classical.choice, Quot.sound
* **`CKNInstance.planckEnergy_gt_ckn_horizon_cutoff`**  
  `CKNInstance.planckEnergy_eV ≥ 10 ^ 30 * CKNInstance.cknLambdaHorizon_eV`  
  axioms: propext, Classical.choice, Quot.sound
* **`DualTower.dualTower_sum_ge`**  
  `∀ (M0 M1 M2 : ℝ), 0 < M0 → 0 < M1 → M1 * M2 = M0 ^ 2 → 2 * M0 ≤ M1 + M2`  
  axioms: propext, Classical.choice, Quot.sound
* **`DualTower.dualTower_sum_ge_needs_product`** (negative control)  
  `¬∀ (M0 M1 M2 : ℝ), 0 < M0 → 0 < M1 → 2 * M0 ≤ M1 + M2`  
  axioms: propext, Classical.choice, Quot.sound
* **`SelfDualCutoff.ckn_iff_uvLength_ge_selfDual`**  
  `∀ (lmi lma lUV : ℝ), 0 < lmi → 0 < lma → 0 < lUV → (lma ^ 2 * (1 / lUV) ^ 4 ≤ (1 / lmi) ^ 2 ↔ lmi * lma ≤ lUV ^ 2)`  
  axioms: propext, Classical.choice, Quot.sound
* **`CosmicString.fStringGmu_le_iff`**  
  `∀ (lP ap g : ℝ), 0 < ap → (CosmicString.fStringGmu lP ap ≤ g ↔ lP ^ 2 ≤ 2 * Real.pi * g * ap)`  
  axioms: propext, Classical.choice, Quot.sound
* **`CosmicString.selfDual_alphaPrime_exceeds_cms_ceiling`**  
  `SelfDualCutoff.planckLength_m * SelfDualCutoff.hubbleRadius_m ≥ 1e30 * (SelfDualCutoff.hbarC_eVm / CosmicString.cmsStringResonanceMin_eV) ^ 2`  
  axioms: propext, Classical.choice, Quot.sound
* **`DarkEnergyScale.rhoLambda_inv_eq`**  
  `∀ (lP L Om : ℝ), 0 < lP → 0 < L → 0 < Om → 1 / DarkEnergyScale.rhoLambda lP L Om = 8 * Real.pi / (3 * Om) * (lP * L) ^ 2`  
  axioms: propext, Classical.choice, Quot.sound
* **`DarkEnergyScale.selfDual_lambda4_eq`**  
  `∀ (lP L Om : ℝ), 0 < lP → 0 < L → (lP * L) ^ 2 * DarkEnergyScale.rhoLambda lP L Om = 3 * Om / (8 * Real.pi)`  
  axioms: propext, Classical.choice, Quot.sound

### `DualScaleMoonshine` (Stream 4; probe on the `v3.7.0` tree)
* **`DualScaleMoonshine.hComputed_eq_table`**  
  `hComputed 9 = hFromTable`  — the series computed from `(−2E₂ + 48F₂)/η³` equals `−2, 2A₁, …, 2A₉` of EOT's table  
  axioms: propext
* **`DualScaleMoonshine.twined_2A`**  
  `twined24 9 8 2 (-16) = List.map (fun x => 24 * x) table2A`  
  axioms: propext
* **`DualScaleMoonshine.trace_2A_eq_twined_coeff`**  
  `List.map (dot chi2A) eotMult = List.take 7 (List.drop 1 (List.map (fun x => x / 24) (twined24 9 8 2 (-16))))`  
  axioms: propext
* **`DualScaleMoonshine.ratio_fails_at_2A`**  
  `¬ratioTwines (twined24 9 8 2 (-16))`  — paper 7's 27720 ratio relation does not survive twining  
  axioms: propext

### `DualScaleMoonshine`, all classes (probe on the `v3.8.0` tree)
* **`DualScaleMoonshine.twined_23AB`**  
  `twinedD dataF23AB = scaled dataF23AB table23AB`  — `F_23AB = (1/11)(−Λ₂₃ + 23f₂₃,ₐ + 69f₂₃,ᵦ)` reproduces the printed column  
  axioms: propext
* **`DualScaleMoonshine.gram_ok`**  
  `gramOK charTab = true`  — first orthogonality relation for all 26 × 26 pairs, irrational columns included  
  axioms: propext
* **`DualScaleMoonshine.trace_eq_twined_coeff_all`**  
  `∀ (j : Fin 26), List.map (traceQ ↑j) eotMult = List.map (fun x => (x, 0)) (List.take 7 (List.drop 1 (computedSeries.getD ↑j [])))`  
  axioms: propext
* **`DualScaleMoonshine.ratio_fails_at_every_class`**  
  `∀ (j : Fin 26), ↑j ≠ 0 → ¬ratioTwines (List.map (fun x => 24 * x) (computedSeries.getD ↑j []))`  
  axioms: propext

### `DualScaleMoonshine.Shadow` (probe on the `v3.9.0` tree)
* **`DualScaleMoonshine.ellipticGenus_z0`**  
  `List.map LP.eval1 (ellipticGenus 9) = [24, 0, 0, 0, 0, 0, 0, 0, 0, 0]`  — `Z_K3(τ, 0) = 24`  
  axioms: propext
* **`DualScaleMoonshine.decomposition`**  
  `(starLHS 9).eqB (starRHS 9 24 (hComputed 9)) = true`  — polar multiplicity 24, finite part the computed `H`  
  axioms: propext
* **`DualScaleMoonshine.shadow_coeff_eq_perm_trace`**  
  `List.map (fun j => traceQ j ([1, 1] ++ List.replicate 24 0)) (List.range 26) = List.map (fun x => (x, 0)) chiShadow`  
  axioms: propext

## 4. How to re-confirm (10 commands)
```bash
cd ~/SocrateAI-Scientific-Agora-LeanMaster
lake build DualScaleStream2 StringTheoryFormalization
python3 tools/axiom_audit.py DualScaleStream2 | tail -1
python3 tools/axiom_audit.py StringTheoryFormalization | tail -1
python3 tools/statement_lock.py --check $(find DualScaleStream2 StringTheoryFormalization -name '*.lean') | tail -1
# Stream 3
lake build DualScaleCosmology
python3 tools/axiom_audit.py DualScaleCosmology | tail -1
# Stream 4
lake build DualScaleMoonshine
python3 tools/axiom_audit.py DualScaleMoonshine | tail -1
python3 tools/statement_lock.py --check $(find DualScaleMoonshine -name '*.lean') | tail -1
python3 tools/statement_lock.py --check $(find DualScaleCosmology -name '*.lean') | tail -1
```
If any of these disagrees with Section 1, this document is stale: trust the commands, fix the document.
