# Stream 2 Workflow — Dual-Scale String Theory on K3 × T² and T-Duality

**Status**: proposal + pilot (2026-09-16). The pilot (§5) exercised this workflow end to end
on the lattice/T-duality layer; its measured per-tier results are in §6, and the design in
§3–§4 was adjusted to match what actually closed goals, not what was expected to.

## 1. What Stream 2 is (and is not)

Goal: a kernel-checked Lean 4 layer for the *mathematical skeleton* of type II / heterotic
string theory on `K3 × T²` — charge lattices, their duality groups, the doubled (DFT)
algebra, flux/tadpole counting, and the Mathieu-moonshine numerics — each theorem
labelled **A** (kernel-checked here), **L** (quoted from a pinned paper line), or **C**
(project conjecture).

Not a goal, and never to be claimed: "formalizing string theory" as physics. Moduli-space
quotients, Sylvester's law of inertia for non-diagonal forms, the classification of even
unimodular lattices, Fourier–Mukai transforms, etc. stay **Tier L** unless and until a
specific work package proves them.

## 2. Hard constraints (from this repo's own incident history — see `LL.md` §0)

1. **Kernel is the only accept gate.** A goal is closed when `lake build DualScaleStream2`
   is green, the zero-`sorry` audit passes, and `#print axioms` shows only
   `propext`, `Classical.choice`, `Quot.sound`. No `native_decide`.
2. **Producer ≠ verifier.** No agent or model grades its own output; the gate runs
   separately.
3. **No citation from memory.** Every Tier L docstring cites a file in
   `papers/foundations/` *and a line range* that a script can `grep`.
4. **Ledger entries pin a commit hash and build job count.** (`leanautoresearch/engine.py`'s
   `sync_epistemic_claims` wrote hardcoded claims on any green build — the exact failure
   this rule exists to prevent.)
5. **Separate `lean_lib`.** Stream 2 lives in `DualScaleStream2`, imports Stream 1, never the
   reverse; Stream 1's green core cannot be turned red by Stream 2 work.
6. **External corpora are read-only references, never dependencies.** `atlas-lean`
   (Lean v4.29.0, 3,579 `sorry` lines) and `openai-navierstokes` (v4.34.0-rc2) cannot be
   `require`d at this project's v4.33.1 pin (empirically confirmed for NS). Mirror a
   *statement shape* with our own proof; never cite them as certified.
7. **Large artifacts on the second disk** (Mathlib, clones, `.lake`, model weights).

## 3. Model tiers

| Tier | Model | Cost | Used for |
|---|---|---|---|
| **T0** | Opus (orchestrator) | highest | selecting the work package, the *statement review* (does the Lean say what the paper says?), tier labels A/L/C, commit. Kept to a few calls per package. |
| **T1** | Sonnet | medium | proof bodies that need a real idea (block-matrix algebra, involution arguments); residual goals after T3/T2. |
| **T2** | **Haiku** (default worker) | low | statement extraction from pinned paper lines into `sorry`-stubs; residual *mechanical* goals; paper fetch + manifest; RAG/graph/SQLite refresh; citation-line checks. |
| **T3** | Local provers on the T4 (Ollama): `DeepSeek-Prover-V2-7B` Q8_0, `Goedel-Prover-V2-8B` Q6_K | free (GPU) | first pass on every open goal via `tools/prover_loop.py`. |

Default routing: **T3 → T2 → T1**, escalating a goal only after the cheaper tier has failed
under the kernel gate. T0 never writes proofs in the steady state.

## 4. Per-work-package pipeline

| Step | Who | Output | Gate |
|---|---|---|---|
| S0 Select | T0 | one paper section → one module; list of target statements | — |
| S1 Pin sources | T2 | `grep`-verifiable line ranges in `papers/foundations/*.txt` | lines exist |
| S2 Extract | T2 | Lean statements with `sorry`, tier-labelled docstrings | **G1**: builds with only `sorry` warnings |
| S3 Statement review | **T0** | approve / correct each statement | **G2**: recorded sign-off (the one step no kernel can check: mis-formalization) |
| S4 Local search | T3 | `tools/prover_loop.py --rounds 2` over both models | kernel, per candidate |
| S5 Residual (mechanical) | T2 | proofs for goals T3 missed | kernel |
| S6 Residual (conceptual) | T1 | proofs for goals T2 missed | kernel |
| S7 Verify | independent agent | full 7-library build, sorry audit, axiom audit | **G3** |
| S8 Record | T2 | `tools/index_declarations.py`, `leangraph` (all libraries), oracle export, narrative update | **G4**: counts cross-checked against `grep` |
| S9 Commit | T0 | commit + push, ledger entry pinned to hash + job count | — |

## 5. Phases

| Phase | Content | Pinned sources |
|---|---|---|
| **P2.1 Lattice layer** (pilot, this session) | `U`, `E8`/`E8(−1)` even + unimodular via integer-inverse certificate; K3 → Mukai → `Γ⁶'²²` signatures cross-checked with Stream 1 Hodge numbers; general-`d` `O(d,d;ℤ)` generators | Huybrechts Ch. 1 eq. (3.4); Aspinwall hep-th/9611137 ll. 705–766, 1737–1748; GPR hep-th/9401139 §2.4 eq. (2.4.25) |
| P2.2 T² moduli & dualities | factorized dualities on each circle; `SL(2,ℤ)_τ × SL(2,ℤ)_ρ` inside `O(2,2;ℤ)`; mirror `τ ↔ ρ` as a lattice automorphism; mass-spectrum invariance generalizing Stream 1 `TDualityMassSpectrum` | GPR §2.4–2.5 |
| P2.3 K3 moduli & dualities | `E8` positive-definiteness via an LDLᵀ rational witness; Mukai pairing on `(r, c, s)`; `O(Γ⁴'²⁰)` generators preserving it | Aspinwall §2–§4; Huybrechts Ch. 14, 16 |
| P2.4 DFT algebra | generalized metric `H` with `H η H = η`; strong constraint as `η`-null momenta; `O(d,d)` action on `(G, B)` | Hull–Zwiebach 0904.4664 |
| P2.5 Flux & tadpole on K3 × T² | `χ(K3)/24` counting; flux quanta integrality | Dasgupta–Rajesh–Sethi hep-th/9908088; GVW hep-th/9906070 |
| P2.6 Moonshine interface | elliptic-genus coefficient decompositions into `M₂₄` irreps, checked against the paper's tables | Eguchi–Ooguri–Tachikawa 1004.0956 |

### 5.1 Roadmap coverage checklist (updated at each gate)

"Done" = every theorem for the item is committed, sorry-free and axiom-audited. This is the
only honest progress measure for Stream 2: it counts items of *this plan*, not a fraction of
"string theory".

| Phase | Item | Status |
|---|---|---|
| P2.1 | `U` even + unimodular | ✅ `d7c483b` |
| P2.1 | `E8` / `E8(−1)` even + unimodular | ✅ `d7c483b` |
| P2.1 | K3 → Mukai → `Γ⁶'²²` signatures, cross-checked with Hodge numbers | ✅ `d7c483b` |
| P2.1 | general-`d` `O(d,d;ℤ)` generators (Θ-shift, basis change, `η`) | ✅ `d7c483b` |
| P2.2 | factorized dualities `D_k` (GPR 2.4.29), charge norm even + invariant | ✅ `TDuality.Factorized` |
| P2.2 | spectrum equivalence of `O(d,d;ℤ)`-dual backgrounds | ✅ `TDuality.Spectrum` |
| P2.2 | T²: mirror `D₀` conjugates the τ-shift to a B-shift (matrix identity; sympy-verified) | ✅ `TDuality.Mirror` |
| P2.2 | `SL(2,ℤ)_τ` commutes with the ρ-translations inside `O(2,2;ℤ)` (scope narrowed from the full `SL(2,ℤ)_ρ`; GPR ll. 1874–1884) | ✅ `TDuality.SL2Product` |
| P2.3 | `E8` positive definite (LDLᵀ), `det = 1` | ✅ `036329e` |
| P2.3 | Mukai pairing: symmetric, even, `U(−1)`, `v(𝒪_X)² = −2` | ✅ `036329e` |
| P2.3 | `(−2)`-reflections are lattice isometries (Weyl / Picard–Lefschetz), `E8(−1)` Weyl reflections | ✅ `Lattice.Reflection` |
| P2.4 | generalized metric: `(ηH)² = 1`, symmetric, T-duality = `G ↦ G⁻¹`, mass covariance, circle cross-link | ✅ `036329e` |
| P2.4 | integer B-shift acts on `H` by the Θ-shift (sympy-verified convention) | ✅ `DFT.BShift` |
| P2.4 | dual-scale bound `tr G + tr G⁻¹ ≥ 2d`, T-duality invariance, circle case | ✅ `DualScale.TraceBound` |
| P2.4 | level matching `n·w = 0` and the section condition: momentum/winding frames totally null, swapped by `η`, preserved by `O(d,d;ℤ)` (HZ eq. 1.3, ll. 339–342, 3930–3940) | ✅ `DFT.SectionCondition` |
| P2.5 | `χ/24` counting on K3×K3, `χ(K3×T²) = 0`, D3 budget | ✅ `036329e` |
| P2.5 | flux integrality: Kronecker product of an even form is even, so `½∫G∧G ∈ ℤ` (DRS ll. 230–232) | ✅ `Flux.Integrality` |
| P2.6 | EOT `A₁…A₇` decompositions vs. Burnside-checked `M₂₄` table | ✅ `036329e` |

## 6. Pilot results — measured

### P2.1 Lattice layer (26 goals) — **26/26 closed**, gate G3 passed

| Tier | Model | Goals attempted | Closed | Notes |
|---|---|---|---|---|
| T3 | DeepSeek-Prover-V2-7B Q8_0 (T4) | 26 | **18** | every concrete goal (fixed matrices, numerals, the 64-entry E8 inverse check, cross-links to Stream 1); **0** of the 8 general-`n`/general-`d` goals. Median LLM latency 4.4 s/attempt (after a ~170 s cold load). |
| T3 | Goedel-Prover-V2-8B Q6_K (T4) | 8 | 0 | not a capability verdict: with thinking on it spent 8192 tokens / 615 s without emitting an answer; with thinking off it drifted off-target and emitted `sorry` scaffolds. **Dropped from routing** at T4 speed. |
| T2 | Haiku | 8 (no math hints) | **5** | `isUnimodular_of_mul_eq_one`, `e8Neg_unimodular`, `eta_mul_self`, `eta_isODD`, `isODD_mul` |
| T1 | Sonnet | 3 | **3** | `even_quadratic_form_of_even_diag` (diagonal + strict-upper decomposition), `thetaShift_isODD`, `basisChange_isODD`. The prompt included a strategy hint for the first goal that the Haiku run did not get — not a like-for-like comparison. |

Gate G3: `lake build` of the five P2.1 modules green, 0 `sorry` warnings; `tools/axiom_audit.py`:
28 theorems, 0 failing (standard axioms only). Producer ≠ verifier held throughout: every
agent report was re-compiled and statement-integrity-checked by the orchestrator before
counting.

**Tiering conclusion so far**: the local prover is a very cheap, very reliable closer for
concrete/computational goals and useless for symbolic ones; Haiku closes most short
symbolic algebra; Sonnet was needed only for goals requiring a genuine proof idea. Routing
T3 → T2 → T1 put Sonnet on 3 of 26 goals (11.5%).

### Side findings the gates caught in Stream 1 (fixed)
- `StringDynamics.bps_ratio_reduced` used `native_decide` (the new axiom audit flagged
  `…_native.native_decide.ax_…`); replaced with a kernel `norm_num` proof.
- `StringDynamics.M24RepDim` (the M₂₄ irreducible-dimension table) was wrong: 10395 and 483
  duplicated, second 990 and third 1035 missing; squares summed to 351,061,029 ≠ |M₂₄|.
  Replaced with Eguchi–Ooguri–Tachikawa (A.3) and guarded by a new theorem
  `M24RepDim_sum_sq : ∑ dim² = 244823040` (Burnside).

### P2.3 / P2.4-core / P2.5 / P2.6 (23 goals) — **23/23 closed**, gate G3 passed

| Module | Goals | T3 DeepSeek | T2 Haiku | T1 Sonnet |
|---|---|---|---|---|
| `Lattice.Mukai` (Huybrechts Ch. 9 Def. 1.4) | 5 | 3 | 2 | — |
| `Lattice.E8PosDef` (LDLᵀ certificate, `det = 1`, positive definite) | 3 | 0 | 0 | 3 |
| `DFT.GeneralizedMetric` (Hull–Zwiebach eq. 2.17: `(ηH)² = 1`, symmetry, T-duality = `G ↦ G⁻¹`, mass covariance, circle cross-link to Stream 1) | 6 | 0 | 1 | 5 |
| `Flux.Tadpole` (DRS: `χ(K3×K3)/24 = 24`, `χ(K3×T²) = 0`, D3 budget) | 5 | 4 | 1 | — |
| `Moonshine.EOT` (EOT (1.12), (1.14), (1.15) vs. the Burnside-checked M₂₄ table) | 4 | 2 | 2 | — |
| **Total** | **23** | **9** | **6** | **8** |

Gate G3: `lake build` of the five modules green (0 `sorry`); `tools/axiom_audit.py`: 24 theorems,
0 failing. The brute-force `first_five_are_irreps` proof the local prover produced (26 blind
`try use i; rfl` branches) was replaced by the orchestrator with the five explicit irrep
witnesses — kernel-valid proofs are not automatically readable ones.

**Process findings this round (measured, not anticipated):**
- **From P2.2 on, T2/T1 prompts carried orchestrator-written math sketches** (P2.1's Haiku run
  had none). Closure rates above are therefore *with* sketches.
- **Two Haiku reports misstated compile status**: one claimed 5 clean `sorry`s but left
  8 compile errors (`GeneralizedMetric`); one claimed "no compilation errors" with 3 errors
  (`Factorized`). Both caught only because the orchestrator recompiles every report
  (producer ≠ verifier); both files were restored to a clean `sorry` baseline before
  escalation. Prompts now require "unsolved goal = exactly `sorry`, final compile 0 errors".
- **Harness–build config mismatch**: `lake env lean` ignores `lakefile.lean`'s
  `maxHeartbeats := 1000000`, so agents and `tools/prover_loop.py` compiled under Lean's
  default 200000 — stricter than `lake build` (can reject valid proofs, never accept invalid
  ones). A Haiku agent abandoned `e8_LDL` on a heartbeat timeout that the real budget does not
  hit. Fixed in `prover_loop.py` (passes `-DmaxHeartbeats=1000000 -DmaxRecDepth=8000`) and in
  all later prompts.
- **Wall-clock**: several Haiku agents ran for hours on a handful of goals (one: 3 goals,
  6.7 h), dominated by CPU contention from up to six concurrent `lean` processes on one VM,
  not by reasoning. Timeboxes stated as "compile attempts" did not bound wall-clock time;
  prompts now also carry a wall-clock limit.
- **Route choice beats tier**: `cartanE8_posDef` failed at T2 via the 64-entry `LDLᵀ` matrix
  product; T1 closed it via the orchestrator-derived (sympy-verified) sum-of-squares identity
  `xᵀE8x = Σ Dₖ yₖ²`, checked by `ring`, plus back-substitution.

### P2.2 factorized dualities (10 goals incl. helper `proj_comm`) — **10/10 closed**, gate G3 passed

T3 DeepSeek 1 (`factorized_two`), T2 Haiku 2 kept (`proj_transpose`, `chargeNorm_even`; its
other claimed solutions did not compile and were reset), T1 Sonnet 7 (6 goals + helper
`proj_comm`), ~6 compile runs in under 7 minutes once given the real heartbeat flags and a
wall-clock limit — compare hours for the earlier unbounded Haiku agents.

### Dual-scale trace bound (6 goals) — **6/6 closed**, gate G3 passed

T3 DeepSeek 1 (`dualScale_eq`), T2 Haiku 3 (`dualScale_one`, `dualScale_inv`,
`circle_effective_scale_ge_two`; the agent ran ~6.6 h wall-clock and needed a deadline),
T1 Sonnet 2 (`dualScale_ge` via `tr((G−1)G⁻¹(G−1)) ≥ 0`, `dualScale_circle`) in ~6 min.

### Final gate (2026-09-17 05:07 UTC) — **roadmap 18/18, designed goals 99/99**

`lake build DualScaleStream2`: 3670 jobs, 0 `sorry`; `tools/axiom_audit.py DualScaleStream2`:
99 theorems, 0 failing. Stream 1 re-gated in the same session: 3353 jobs, 326 theorems, 0
failing. Statements locked in `docs/statement_lock.json` (`tools/statement_lock.py`).

Last round, by tier: local DeepSeek-Prover closed the Mirror identity (3), `genMetric_bshift_cancel`,
`mul_jMat_mul_transpose`, `basisChange_mul`; Haiku closed 1 Spectrum lemma and the SL(2,ℤ)
product (2) plus 5 of 6 section-condition goals — its report again claimed "0 errors" while one
proof failed to parse (operator precedence), repaired by the orchestrator; Sonnet closed
reflections (4 + helper), B-shift covariance (2), spectrum equivalence (3 + helper) and flux
integrality (4), each in under 7 minutes.

## 7. Running this as an orchestrated workflow

Each work package is independent after S3, so P2.x packages parallelize naturally
(S4 serializes on the single T4). When explicitly requested ("use a workflow"), the
pipeline in §4 maps directly to a multi-agent workflow: T2 (Haiku) agents for S1/S2/S5/S8
fanned out per package, one T3 queue, T1 only for residuals, and an independent verifier
agent for S7.
