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

### P2.2 – P2.6 — in progress (results appended at each gate)

## 7. Running this as an orchestrated workflow

Each work package is independent after S3, so P2.x packages parallelize naturally
(S4 serializes on the single T4). When explicitly requested ("use a workflow"), the
pipeline in §4 maps directly to a multi-agent workflow: T2 (Haiku) agents for S1/S2/S5/S8
fanned out per package, one T3 queue, T1 only for residuals, and an independent verifier
agent for S7.
