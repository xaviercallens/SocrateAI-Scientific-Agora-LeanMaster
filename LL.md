# Lessons Learned (LL)

**Most recent session first** — read §S2 and §S2-I (Stream 2 run + improvements, 2026-09-16/17) and §0
(2026-09-16) before anything below them.
Everything from §1 onward is the original "Phase 0" document and is kept for record, but
**its headline metrics are a known overclaim, not a mistake to repeat**: "125,790 files",
"961,898 theorems", "96.9% coverage" are aggregate counts across every vendored
`lean4basesource/` submodule (Mathlib, FLT, Navier-Stokes, …) — other people's proved
theorems, not this project's own content — presented as if they were this project's
foundation-theory coverage. Treat every number below the divider as unverified until
independently re-checked (the pattern is the same one `FOUNDATIONS.md`'s own correction
note and the root `README.md`'s "note on this revision" already flag elsewhere in this
repo) rather than as ground truth to build the next session's narrative on.

---

# §S2. Stream 2 autonomous run (2026-09-16 21:27 → 2026-09-17 UTC): tiered proof pipeline

**Scope**: new `DualScaleStream2` lean_lib (K3 × T² lattices, `O(d,d;ℤ)`, DFT generalized
metric, dual-scale bound, tadpole, moonshine). Full per-tier numbers:
`docs/STREAM2_WORKFLOW.md` §6. These lessons are the ones that should change how the *next*
run is organized.

## S2.1 Route every goal T3 → T2 → T1; the split is sharp and predictable
Local `DeepSeek-Prover-V2-7B` (Q8_0 on the T4, ~4 s/attempt) closed essentially every
*concrete* goal (fixed matrices, numerals, `fin_cases` tables, the 64-entry E8 inverse
check) and essentially none of the *symbolic* general-`n`/general-`d` goals. Haiku closed
most short symbolic algebra; Sonnet was needed for goals needing a real idea (block-matrix
identities with inverses, positive-definiteness, the diagonal + strict-upper decomposition).
**Do**: write statements so the concrete content is split into separate lemmas — they are
nearly free at T3.

## S2.2 A thinking prover model is useless if the budget can't reach the answer
`Goedel-Prover-V2-8B` closed 0 goals: with thinking on it spent 8192 tokens / 615 s without
emitting an answer; with thinking off it went off-target and emitted `sorry` scaffolds.
**Check `done_reason` and the separate `thinking` field before concluding a model can't
prove something.** It was a configuration failure at T4 speed, not a capability verdict.

## S2.3 Never count an agent's "SOLVED" or "0 errors" without recompiling it yourself
Two Haiku reports misstated compile status: "5 clean `sorry`s" was really 8 compile errors,
and "no compilation errors" was really 3. A third report said a definition "could not be
found" when it existed in a file this session had written. Recompile every report,
re-check that every statement and definition is byte-identical to what was designed, and
restore unsolved goals to exactly `sorry` before escalating. Put "unsolved = exactly
`sorry`, final compile 0 errors" in every prover prompt.

## S2.4 `lake env lean` does not apply `lakefile.lean` options
Package `leanOptions` (here `maxHeartbeats := 1000000`) apply to `lake build`, not to bare
`lake env lean file.lean`, which uses Lean's default 200000. Agents and
`tools/prover_loop.py` were running a stricter gate than the real build, and one Haiku agent
abandoned `e8_LDL` on a timeout the real budget doesn't hit. **Always pass
`-DmaxHeartbeats=1000000 -DmaxRecDepth=8000` to single-file compiles.** (A stricter gate
can reject valid proofs; it can never accept invalid ones, so no wrong result entered the
repo — it only cost time.)

## S2.5 A green build and zero `sorry` are not the whole gate — audit axioms
The new `tools/axiom_audit.py` (`#print axioms` over every theorem) found a `native_decide`
in the "clean" Stream 1 core (`bps_ratio_reduced`), which the build and every `sorry` grep
had passed. It also correctly propagates `sorryAx` to theorems that only *depend* on a
`sorry`. Run it at every gate; validate it with a positive control (a known-clean library)
and a negative control (a library with known `sorry`s) before trusting it.

## S2.6 Guard every data table with a theorem that would break if the table were wrong
Stream 1's `M24RepDim` table had been "verified" for months and was wrong (two entries
duplicated, two missing), because its only theorem checked a single entry. Burnside's
`∑ dim² = |G|` caught it in one line. For every hand-entered table, add the cheapest global
consistency theorem available (sum of squares, total count, known product, symmetry).

## S2.7 Pick the proof route before picking the tier
`cartanE8_posDef` failed at T2 through the literal 64-entry `L·D·Lᵀ` matrix product. It fell
to T1 once the orchestrator derived (and sympy-verified) the equivalent sum-of-squares
identity `xᵀ E8 x = Σ Dₖ yₖ²`, which `ring` checks directly. When a goal times out, look for a
formulation that avoids large definitional unfolding *before* escalating to a costlier model.

## S2.8 Bound agents by wall-clock, not just attempts
Several Haiku agents ran for hours on 1–3 goals (one took 6.7 h for 3 goals, all trivial
once found), dominated by CPU contention from up to six concurrent `lean` processes on one
VM. "At most N compile attempts" did not bound elapsed time. Give every agent a wall-clock
limit, and run at most 2–3 compile-heavy agents at once on this VM.

## S2.9 Pin citations to file + line, and grep them — even your own
A docstring drafted this run cited Huybrechts "Ch. 16 (§1.4?)"; grepping the downloaded
text showed the Mukai pairing is Ch. 9 §1 Def. 1.4 (heading at line 7352). Every Tier L
citation in `DualScaleStream2` now names a `papers/foundations/*.txt` file and line range, and
the papers' metadata came from the arXiv abstract pages, not memory.

## S2.10 Lock statements, not just proofs
The kernel checks that a proof proves its statement. It does not check that the statement is
still the one that was reviewed. `tools/statement_lock.py` hashes theorem statements (up to
the top-level `:=`) and full definition bodies into `docs/statement_lock.json`. Replacing
`sorry` with a proof leaves the hash unchanged; weakening a hypothesis changes it. Run
`--check` before accepting any agent's proof.

## S2.11 An audit that can't elaborate must fail loudly, not report "MISSING"
When the root `.olean` of `StringTheoryFormalization` was stale, the axiom audit printed
"89 theorems audited, 89 failing (MISSING)". That looks like a proof result, but it was an
infrastructure failure. The audit now exits 2 with `AUDIT ERROR` whenever the probe file has
any elaboration error. General rule: tools must tell "could not check" apart from "checked
and failed".

## S2.12 Pre-verify conventions symbolically before stating a theorem
Every block-matrix convention (sign of `B` in the generalized metric, the `η`-pairing, the
Θ-shift orientation) was checked in sympy before its Lean statement was written. A sign slip
caught this way costs minutes. The same slip caught only after an agent has spent an hour on
an unprovable statement costs far more. A sympy check is still **not**
Tier A: papers must label it as a symbolic check and must not quote it as a theorem (for
example, the converse "commutator ≠ 0 when det A ≠ 1" in `SL2Product`).

## S2.13 Docs drift into "iff" when the theorem is one direction
The revision brief said the Θ-shift preserves η "iff Θ antisymmetric". The Lean theorem proves
only the "if" direction. Before a claim goes into a paper, read the Lean statement itself, not
the prose that summarized it.

---

# §S2-I. Improvements for the next run (actionable)

1. **Statement design first, in one pass.** Write every statement with sympy-checked
   conventions and `sorry`, then run `lake build`, `statement_lock --update`, and T0 review.
   Only after that does any proving start. This run interleaved design and proving, which
   caused re-locks.
2. **Tier routing by goal shape, automatically.** Concrete goals (numerals, fixed matrices,
   `fin_cases`) go to T3 `prover_loop.py`. Short symbolic algebra goes to Haiku. Anything
   with inverses, positivity, or general `n` goes straight to Sonnet: Haiku's success rate
   there was low and its reports unreliable (S2.3).
3. **Concurrency budget.** Run at most 3 compile-heavy agents, each with a wall-clock limit
   (≈45 min Haiku, ≈90 min Sonnet), plus the prompt line "final compile 0 errors, paste the
   literal compiler output".
4. **Single gate script.** Wrap `lake build <lib>`, the sorry grep, `axiom_audit.py`,
   `statement_lock.py --check`, and the S8 refresh (`index_declarations.py`, `leangraph`,
   `socrateai_oracle.py export-json`) in one `tools/gate.sh`, so no gate is skipped under
   time pressure.
5. **Rebuild root oleans after module changes.** Build the library target itself, not only
   module targets, before auditing (S2.11).
6. **Paper claims come from the Lean source.** Generate the claim tables in papers from the
   declarations DB (`.leancache/declarations.db`) plus the statement lock, not from
   hand-written prose (S2.13).
7. **Next mathematics targets (Stream 3 candidates).** Narain lattice Γ^{d,d} even
   self-duality for general d; the full O(Γ^{4,20}) action on the Mukai lattice; the
   Siegel–Narain theta function's modular transformation (needs Mathlib modular-forms
   coverage); and a certified reduction of EOT A_n coefficients to M24 characters.

---

# §0. Session 2026-09-16: Recovery, Build-Fix, Use-Case, and RAG/Graph Wiring

**Project**: SocrateAI-Scientific-Agora-LeanMaster
**What happened this session, in order**: (1) the entire local checkout was missing from
disk and had to be re-cloned from GitHub; (2) `StringTheoryFormalization` had 8 real
build failures despite being self-documented as "26-28/30 modules, complete" — fixed to
3291/3291, 0 errors; (3) added 5 new, real, fully-proved "known complex" use cases (26
theorems, 0 sorry); (4) wired up the project's own RAG/graph/SQLite tooling for real,
since most of it was either unpopulated or scoped to a stale subset of the project.
**Final state**: `main` green, `lake build` 3353/3353 jobs, 0 errors, across all 6
first-party libraries.

## Lesson 0.1: A missing project is not always a missing project — check the disk before re-cloning
Home-directory symlinks to the data disk can silently disappear (a VM remount/relabel
event, cause unconfirmed) while the actual data survives one level down. **Before
concluding something needs re-cloning**, diff every top-level entry of the data-disk
directory against home's symlinks — a one-line loop, seconds to run — rather than trusting
`ls ~` alone. This session, doing that turned up 4 more silently-broken symlinks besides
the one initially reported, including the project's main Python venv (6.5GB, completely
unreachable at its expected path until checked). Only re-clone from GitHub once you've
confirmed via `find -L` (which follows symlinks; plain `find` gives false negatives) that
the data is genuinely gone from every disk, not just unlinked.

## Lesson 0.2: Self-reported "complete"/"N/M modules passing" status is a claim, not a fact — rerun the build
This repo's own session summaries have repeatedly stated build status that didn't match
running `lake build` fresh: "26-28/30 modules" was actually 22/30 failing-or-untested at
the start of this session (8 real failures once the full dependency chain was exercised,
not the "2 remaining" the docs named — those 2 had in fact been fixed; a different 8
had not). **The fix that generalizes**: after any claim of "X builds clean" from a
document, memory note, or your own earlier turn in a long session, re-run the actual
build before trusting it or building further work on top of it. This is cheap (`lake
build <target>`, background it, keep working) and it is the only way this session
caught real, previously-unreported failures.

## Lesson 0.3: A fix that "compiles" can still be hiding downstream breakage — fixing cascades
Fixing one broken file can *unblock* Lean from even attempting to elaborate files that
depend on it, which can surface entirely new failures that were always latently present
but never reached because the build stopped earlier. This session: fixing 4 modules
revealed a 5th (`ModuliGeodesics`) and 6th (`SwamplandSafe`, `FTermPotential`) that had
never actually been attempted in a full build before. **Rule**: after any fix, re-run
the *whole* target's build, not just the one file you touched — `lake build` on the
single file will look green and hide this.

## Lesson 0.4: A real, reproducible Lean 4 parser gotcha — parenthesize multi-name structure fields
`structure Foo where a b c d : T` (space-separated field names, **no parens**) is parsed
as ONE field `a` that is a *curried function* taking `b c d` as auto-bound implicit
arguments and returning `T` — not four scalar fields of type `T`. This reproduces in
vanilla Lean 4 with zero Mathlib imports (`structure Foo where a b c d : Nat`, then any
use of `a`,`b`,`c`,`d` as scalars fails with bizarre dependent-function-type errors whose
error messages give no hint of the real cause). **Fix**: parenthesize the group,
`(a b c d : T)`. This bug, once found in one file (`SL2CSymmetry.MobiusTransform`), was
found again independently in a second, unrelated file (`ModuliGeodesics.ModuliGeodesic`)
in the same corpus — **grep the whole codebase for `structure \w+ where\s*\n\s*\w+ \w+`
(two-or-more bare space-separated names before a bare `:`) as a class of latent bug**,
don't assume it's isolated once you've found and fixed one instance.

## Lesson 0.5: This project's automation tools are a mix of real and fabricated — audit each one before trusting or extending it
`leanautoresearch/evaluator.py`'s `LeanEvaluator` is real: it runs an actual `lake build`
subprocess and a real regex sorry/admit audit after stripping comments. `leangraph/`
(dependency graph extractor) and `tools/socrateai_oracle.py`/`tools/lean_cache_manager.py`
+ `leangraph/cache.py` (SQLite declaration index) are also real, working code. But:
- `leanautoresearch/prover.py` is a **hardcoded static list** of already-"PROVEN"
  experiments with **no actual proving logic** — pure mock data.
- `leanautoresearch/engine.py`'s `sync_epistemic_claims()` injects the **same 3
  hardcoded claims** into `ledger.jsonl` any time the *whole* corpus builds with
  aggregate zero-sorry, regardless of whether those 3 specific claims are what was
  actually just proved.
- `leangraph.build_graph`'s default module list and `socrateai_oracle.py`'s indexing
  scope both silently omitted `StringTheoryFormalization` — the single largest library
  in the project — until fixed this session (see §0.7). A "complete" RAG/graph export
  can still be silently missing most of the actual corpus; check the target/scope list,
  not just whether the tool ran successfully.
**Rule for next session**: before running or trusting output from any `tools/*.py` or
`*/engine.py`/`prover.py` script in this repo, read what it actually does (open the
file), don't assume the module or file name describes real behavior.

## Lesson 0.6: A local LLM is a second opinion, not an oracle — verify its claims like anyone else's
Asked the locally-hosted `qwen2.5-coder:7b-instruct` (Ollama, on the project's T4 GPU) to
sanity-check 5 new formalizations' physics claims. It correctly confirmed 2 of 3
spot-checked facts and **incorrectly disputed the third** (claimed the bosonic-string
ghost central charge was `c=-24` at weight `λ=2`; the correct, well-established value —
independently re-derived from the cited Polchinski formula and matching the famous
`D=26` bosonic-string result — is `c=-26`; the model likely conflated it with the
unrelated `D-2=24` light-cone transverse count). Useful as a fast first-pass check, not
as a substitute for deriving the answer yourself from a cited source.

## Lesson 0.7: "Ensure RAG/graph/DB is in place" means checking real data flows in, not that the script exists
Three separate indexing tools existed with real, working code, but each was either
never run (SQLite `declarations.db` didn't exist anywhere on disk) or scoped to a
subset of the project that excluded `StringTheoryFormalization`:
- `leangraph`'s declaration-graph builder defaults to `["DoubleFieldTheory",
  "DualScaleM24Formalization", "StringTheoryFoundation"]` only — re-run with an explicit
  `--target` listing all 6 first-party libraries to get real coverage (729 nodes / 1216
  edges vs. the stale 538/807 in the committed `graph/` from before this session).
- `tools/socrateai_oracle.py`'s `_load_corpus` had the same 5-library gap (missing
  `StringTheoryFormalization`) — one-line fix, then re-run `export-json`.
- No script existed that walked the *whole* corpus into `leangraph.cache.LeanCacheManager`
  (the real SQLite backend) — `leangraph/base_graph.py`'s `_index_key_declarations` only
  indexes ~27 hand-picked "landmark" files. Wrote `tools/index_declarations.py` to do a
  full walk; **first regex attempt (copied from `base_graph.py`) undercounted by >2x**
  (746 real declarations vs. 297 found) because it tried to capture the entire
  multi-line signature in one regex and silently dropped anything that didn't fit —
  switched to a line-anchored "match just the declaration head, treat the rest of the
  line as a preview" pattern and cross-checked the total against a plain
  `grep -c '^theorem '`-style count (matched exactly: 746 = 746) before trusting it.
  **General lesson**: when writing any extraction/counting tool over this corpus,
  cross-check its output against an independent, dumber method before trusting the count.

## Lesson 0.8: Keep large data off the root disk, always
Mathlib clones, git submodule clones, Lake build caches, and (new this session) Ollama
model weights all belong on `/mnt/disks/disk-socrateai-local-1/`, never the root disk —
even for a disposable, throwaway experiment (a stray 812MB test clone landed on root
disk under `/tmp` mid-session and had to be relocated). Set `OLLAMA_MODELS` /
`LAKE_ARTIFACT_CACHE` / clone target paths onto the second disk *before* running the
command that downloads, not after.

---

## 1. Executive Summary & Core Results

The **LeanMaster Extended Architecture** aims to mechanize String Theory, T-Duality, and Dual-Scale Generalized Geometry on $K3 \times T^2$ in Lean 4. Rather than writing foundational functional analysis and algebraic geometry from scratch, Phase 0 implemented an automated retrieval and grounding pipeline that harvests existing verified mathematical monoliths:
1. **OpenAI Navier-Stokes & Euler**: Continuous functional analysis on the 2-torus $T^2$.
2. **Anthropic & Callens Fermat's Last Theorem (FLT)**: Discrete algebraic geometry, Kummer surfaces, and modular forms on $K3$.
3. **Physlib, TNLean, LeanQuantum, and LeanStatLearning**: Spacetime gauge metrics, $O(D,D;\mathbb{Z})$ doubled geometry, and tensor networks.

### Ground Truth Census of Retrieved Foundations
Across 7 cloned repositories in [`lean4basesource/`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/lean4basesource):
- **Total Mechanized `.lean` Files**: **125,790**
- **Total Lines of Code**: **28,277,226**
- **Theorems and Lemmas**: **961,898**
- **Definitions and Structures**: **108,062**
- **Directly Verified Macroscopic Blocks**: **23 / 29 (79.3%)**
- **Weighted Foundation Theory Coverage**: **96.9%** (far exceeding the 60.0% milestone requirement)

---

## 2. Key Mathematical Insights: Continuous vs Discrete Duality

String compactification on $M_{10} = M_4 \times (K3 \times T^2)$ requires unifying two historically disconnected domains of mechanized mathematics:

### Lesson 1.1: The Continuous Sector ($T^2$) via OpenAI Navier-Stokes
- **Formal Bridging Module**: Implemented [`StringTheoryFormalization/NSMath/OpenAIBridging.lean`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/StringTheoryFormalization/NSMath/OpenAIBridging.lean), which formally links OpenAI's `NavierStokes.TorusInverse` and `Euler.ParentEulerSobolev` into Lean 4 string theory:
  - Frequencies in $\mathbb{Z} \times \mathbb{Z}$ (`TorusFrequency`) on the universal cover $\mathbb{R}^2$.
  - Polynomial weight function $w(k) = 1 + |k_1| + |k_2|$ (`torusWeight`) and rapid decay configurations (`IsRapid`).
  - Basis mode expansions $\exp(2\pi i (k_1 x_1 + k_2 x_2))$ and coordinate swap involution $\sigma: (x, y) \mapsto (y, x)$ (`swapTorusCoordinates`).
  - Continuous Sobolev path evolution classes (`ContinuousTorusEvolution`) with strong Euler regularity.
- **Sobolev Spaces $H^s(T^2)$**: Continuous target-space metric deformations and wave/heat flows require fractional Sobolev spaces for arbitrary $s \in \mathbb{R}$. OpenAI's Euler/NS formalization directly supplied:
  - $H^s$ norms and continuous embeddings $H^s(T^2) \hookrightarrow C^0(T^2)$ for $s > 1$.
  - Torus Fourier multipliers $\mathfrak{F}$ and Calderón-Zygmund singular integral bounds (`Rapid.mul_linear`).
  - Mild PDE solutions via Duhamel integrals $u(t) = e^{t\Delta} u_0 + \int_0^t e^{(t-s)\Delta} B(u(s), u(s)) ds$ with Banach-space Picard-Lindelöf contraction.
  - A priori energy dissipation inequalities $\frac{d}{dt} \|u\|_{L^2}^2 + 2\nu \|\nabla u\|_{L^2}^2 \le 0$ preventing metric blow-ups.
- **Moduli Dynamics & Cosmology**:
  - The Picard spectral radius iteration ($\rho = 18$) and stiff differential integrators (BDF2 / Implicit Euler A-stability) map cleanly to moduli space relaxation.
  - Primordial cosmological perturbations (Mukhanov-Sasaki) and Bunch-Davies vacuum normalization were established via Gaussian elliptic operators.

### Lesson 1.2: The Discrete Sector ($K3$) via Anthropic & Callens FLT
- **Kummer Orbifold Resolution**: The $T^4/\mathbb{Z}_2$ singular locus consists of 16 $A_1$ singularities. The Fermat formalization's modular curve blowup mechanisms provided:
  - Exceptional $(-2)$-curves $E_i$ with exact intersection matrix $E_i \cdot E_j = -2\delta_{ij}$.
  - The Kummer lattice contribution $\sum E_i^2 = -32$.
- **Lattices and Derived Auto-Equivalences**:
  - Mukai lattice $\widetilde{H}(K3, \mathbb{Z}) \cong \Gamma^{4,20} \cong 4U \oplus 2E_8(-1)$ with even unimodular signature $(4, 20)$ and inner product $\langle (r_1, c_1, s_1), (r_2, c_2, s_2) \rangle = c_1 c_2 - r_1 s_2 - r_2 s_1$.
  - Fourier-Mukai transforms $\Phi_{\mathcal{E}}: D^b(K3) \to D^b(K3)$ inducing isometries on the Mukai lattice.
- **Modular Forms & BPS Counting**:
  - Mathieu group $M_{24}$ (order 244,823,040), character tables, and elliptic genus $Z_{K3}(\tau)$.
  - Exact Rademacher expansion yielding the BPS invariant ratio $77/60$.
  - $SL(2, \mathbb{Z})$ modular transformations on the upper half-plane $\mathbb{H}$ ($\mathrm{Im}(\tau) > 0$).

### Lesson 1.3: The Doubled Metric & Dual Scale Synthesis
- Hitchin's Generalized Complex Geometry and T-duality on $K3 \times T^2$ require the doubled $O(D,D;\mathbb{Z})$ split-signature metric $\eta = \begin{pmatrix} 0 & I \\ I & 0 \end{pmatrix}$.
- In [`ODDMetric.lean`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/StringTheoryFormalization/StringDynamics/ODDMetric.lean), we verified $\eta^T = \eta$ and $\eta_{D=1} = \begin{pmatrix} 0 & 1 \\ 1 & 0 \end{pmatrix}$.
- In [`TDualityGysin.lean`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/StringTheoryFormalization/StringDynamics/TDualityGysin.lean), T-duality is proved as an involution $s \mapsto s$ swapping momentum $n$ and winding $w$, coupled with the Gysin pushforward $\pi_*: H^*(K3 \times S^1) \to H^*(K3)$.
- Gukov-Vafa-Witten superpotential $W = \int_{K3 \times T^2} (F_3 - \tau H_3) \wedge \Omega$ and Tadpole cancellation $\sum Q + \chi(K3)/24 = 0$ bridge the discrete Euler characteristic ($\chi = 24$) with continuous flux integrals.

---

## 3. Engineering & Toolchain Lessons Learned

### Lesson 2.1: The "Mathlib Clone Trap" in Lean 4 Projects
- **Issue**: Standard `lake build` or `lake test` invocations automatically check dependencies declared in `lakefile.toml`. If `mathlib` is listed as a remote git dependency, Lake will initiate a multi-gigabyte download and trigger a massive CPU build of Mathlib oleans.
- **Resolution**:
  - Pinned the toolchain to `leanprover/lean4:v4.33.1`.
  - Implemented decoupled symbolic checks in [`workflow.py`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/workflow.py) (`tool_run_cpu_aesop`), verifying `.lake/packages/mathlib` non-blockingly and avoiding unconstrained Lake runs until pre-compiled olean caches are hydrated.

### Lesson 2.2: Filesystem I/O with 120,000+ Files & Single-Theorem Architectures
- **Issue**: Anthropic's Fermat repository uses a modular, atomic design where **each theorem is an individual `.lean` file** (29,511 in `Theorems/`, 29,513 in `P2M/`). Naive recursive filesystem traversals (`Path.rglob("*.lean")`) entered deep `.git/` trees (thousands of packfiles/objects), causing `workflow.py` scans to take 20–40 seconds.
- **Resolution**:
  - Refactored `FoundationRetriever.get_available_repositories` to use `os.walk` with explicit in-place pruning (`dirs.remove(".git")`).
  - Added a cache file (`lean4basesource/.repo_counts.json`) that caches repo file counts, reducing subsequent status checks from ~15 seconds to **< 1 millisecond**.
  - Added `lean4basesource/` to [`.gitignore`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/.gitignore) to prevent Git from treating the subrepositories as dirty untracked submodules.

### Lesson 2.3: Comments vs Code in AST / Line Parsing
- **Issue**: In `pipeline_orchestrator.py`, a simple substring search for `"sorry"` matched documentation comments mentioning `sorry axioms` (e.g. `-- Status: VERIFIED (0 sorry axioms)`), falsely inflating the project's incomplete goal tally.
- **Resolution**:
  - Implemented single-line and multiline comment stripping (`--` and `/- ... -/`) prior to counting `sorry` tokens.
  - Pinned verified block tallies to strictly code-level axioms.

---

## 4. Antigravity Agent & Execution Architecture

### Lesson 3.1: Dual Local/Cloud Targeting
- The common agent in [`workflow.py`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/workflow.py) (`LeanMasterAntigravityAgent`) operates across three deployment targets:
  1. `DeploymentTarget.LOCAL`: Queries the local Ollama daemon (`deepseek-prover:7b-q4`) at `http://localhost:11434/v1`. If the model weights are not yet pulled, it alerts the user and falls back gracefully to deterministic symbolic tooling.
  2. `DeploymentTarget.GCP`: Integrates with Vertex AI / Cloud Composer to dispatch GKE Autopilot spot workers and trigger Cloud TPU v5e RL training cycles.
  3. `DeploymentTarget.API_ZERO_GPU`: Executes pure symbolic rules (`aesop`, `ring`, `positivity`, `omega`) and Blueprint DAG ingestion.

### Lesson 3.2: Replay Buffer & Reinforcement Learning Feedback
- Implemented persistent experience replay logging in `.replay_buffer.json` via `ProofTrajectory`.
- Each successful or attempted tactic sequence records the block ID, phase index, tactic array, outcome (`closed`, `failed`), and scalar reward. This provides direct ground truth for future PPO/DPO training cycles on Cloud TPUs.

---

## 5. Phased Roadmap Execution State

```
[Phase 0: Blueprint & Foundations]  =====> 100% COMPLETE (Released)
  ├── 125,790 foundational Lean 4 files indexed
  ├── 96.9% weighted foundation theory coverage
  ├── 23/29 blocks verified (0 sorry)
  └── Blueprint & RAG context exported to foundation_retrieval_map.json

[Phase 1: Local CPU Optimization]  =====> NEXT STEP
  ├── Mathlib cache hydration (lake exe cache get)
  ├── Micro-tactic Aesop rule generation for FR1-FR6
  └── Memory bounds (16-32GB CPU RAM)

[Phase 2: Edge LLM Prover]        =====> READY
  ├── Ollama deepseek-prover:7b-q4 local serving
  └── Streamed tactic generation with temperature 0.2

[Phase 3: GCP Swarm & TPU RL]     =====> SPECIFIED
  ├── GKE Autopilot spot vLLM workers
  ├── TPU v5e continuous PPO/DPO loop
  └── Weekly Hugging Face weight synchronization
```

---

## 6. Release Verification Checklist

- [x] All 7 foundational repositories cloned and indexed in `lean4basesource/`.
- [x] `foundation_retrieval_map.json` generated and verified (96.9% theory coverage).
- [x] `pipeline_orchestrator.py` accurately tracking 29 blocks (19 fully mechanized locally, 23 grounded in foundations).
- [x] `workflow.py` equipped with `--basesource`, `--retrieve`, `--coverage`, and `--phase` commands.
- [x] `.gitignore` updated to ignore `lean4basesource/` and `.replay_buffer.json`.
- [x] Git commits structured and pushed to `origin/main`.
- [x] Release tag `v0.1.0-phase0` created and pushed.

---

## 7. Lessons Learned: Phase 2 Dual-Scale Theory & Mathieu $M_{24}$ Moonshine

### Lesson 2.1: Pure Lean 4 Core vs. Heavy Monolithic Dependencies
- Monolithic Mathlib dependencies introduce gigabytes of remote network fetching and cache fragility that can block automated agents.
- Core algebraic, group-theoretic, and topological invariants (e.g. Diophantine tadpole equations, Gysin exact sequences, K-theory difference classes, and Mathieu $M_{24}$ cross-multiplications) can be formalized directly in pure Lean 4 core (`Init`, `Std`, `decide`, `omega`, `ac_rfl`).
- A self-contained package (`DualScaleM24Formalization`) cold-builds via Lake in **~7 seconds** across 14 targets with **zero sorry axioms**, ensuring deterministic and lightning-fast CI/CD certification.

### Lesson 2.2: Stream 0 Epistemic Governance (`SocrateAI-Mathesis`)
- The 5-tier calculus ($X < C < L < B < A$) prevents epistemic claim contamination across distributed agent sessions.
- The **Soundness Transitivity Theorem** (`no_kernel_claim_rests_on_weaker` and `tier_le_of_depends`) proved that if any dependency in the transitive closure of a claim has tier below A, the citing claim cannot be certified as Tier A.
- Enforcing Gate 1 (exact $\mathbb{Q}/\mathbb{Z}$ arithmetic with failing negative controls) immediately identified that un-doubled components $(45, 231)$ satisfy $231 / (4 \times 45) = 77/60$ identically, proving the deep structural consistency of the $M_{24}$ character decomposition.

### Lesson 2.3: Mechanized Triad Closed Loop & Graph Invariants
- In TDA Mapper 1-skeleton graph extraction from Langevin point clouds, the first Betti number requires accounting for the number of connected components $b_0$:
  $$\beta_1 = E - V + b_0$$
  For $V = 187$ nodes and $E = 557$ edges, the 6 isolated defect clusters ($b_0 = 6$) in the multi-well landscape rigorously account for the exact observed Betti number $\beta_1 = 557 - 187 + 6 = 376$.
- Singularity resolution in the dual-scale metric $R_{\text{eff}} = \max(R, \alpha'/R) \ge \sqrt{\alpha'} > 0$ is proved constructively as a geometric theorem (`genesis_no_singularity`), ensuring that **regularization is never an axiom**.

