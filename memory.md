# SocrateAI-Scientific-Agora-LeanMaster Context Memory

**Last Updated:** September 2026 (post-audit revision — read this before repeating any of the
overclaiming this section used to contain)

## Project Mission
A Lean 4 companion formalization for a proposed Dual-Scale String Theory on $K3 \times T^2$. It
kernel-certifies (Tier A) exact integer/rational arithmetic used in the argument, with a strict
zero-`sorry`, zero-`admit`, standard-axioms-only invariant. **It does not certify the surrounding
physics** (Double Field Theory as a differential-geometric theory, moduli stabilization, the
zero-free-parameter claim, or any of the phenomenological predictions) — those are Tier L
(literature) or Tier C (this project's own conjectures), and are labeled as such throughout the
paper and README as of this revision. See `papers/publication/PAPER7_IMPROVEMENT_PROPOSAL.md` for
the audit that produced this framing and `papers/publication/PAPER7_ENGINE_LEAN_DOCS_REVIEW.md` for
the follow-up full-project review (engine, Lean, docs).

## Core Milestones Achieved
- **Lean 4 Mechanization:** 51 Lean 4 files, 554 declarations, 61 Lake compilation jobs, zero
  external dependencies (`lake-manifest.json` lists zero packages — no Mathlib). Recount with
  `find <libs> -name '*.lean' | wc -l` and the declaration-grep in
  `papers/publication/PAPER7_IMPROVEMENT_PROPOSAL.md` before quoting a number; these have drifted
  from stale prose at least twice already.
- **Strict Invariant, exhaustively verified (not just spot-checked):** 0 bare `sorry`/`admit`
  *tactics* (word-boundary + tactic-position grep, not a naive substring check — a substring check
  self-fails since docstrings say "0 sorry"), across all five primary libraries
  (`DoubleFieldTheory`, `DualScaleValidation`, `DualScaleM24Formalization`, `StringTheoryFoundation`,
  `Lean5Corpus`) **and** `prove2me_engine`'s own `Specs`/`Proofs` libraries. `#print axioms` run on
  **all 238** theorem/lemma declarations in the five main libraries (not just a paper-cited subset):
  all depend on nothing beyond `propext`, `Classical.choice`, `Quot.sound`. Zero literal `axiom`
  declarations anywhere in the live (built) corpus.
- **Known dead/orphaned Lean code (do not count toward the invariant above, and cannot currently
  build):** `StringTheoryFormalization/` (30 files) is **not** registered in the root
  `lakefile.lean` and imports Mathlib extensively, which this project has zero dependency on — it
  cannot compile as the project is currently configured. `Tests/Main.lean` imports 15 files from
  it and is itself unregistered. Confusingly similar name to the live `StringTheoryFoundation/`.
  Recommendation: archive or delete both, or add Mathlib as a real dependency and register the
  library — do not quietly leave it as ambiguous, unbuilt weight. Separately,
  `DualScaleM24Formalization/lakefile.lean` is a redundant, independently-buildable nested Lake
  package duplicating what the root lakefile already builds from the same source directory — low
  risk, but confusing; safe to delete (`lakefile.lean`, `lake-manifest.json`, `lean-toolchain`,
  `.lake/` inside that subdirectory) since the root build never uses it.
- **The "engine" (`prove2me_engine/`) was fully broken against its own live data as of the previous
  session, now fixed:** every write/execute path (`orchestrator.py`'s `run_full_schedule`,
  `recheck.py`'s `run_full_recheck`, and the CLI's `run`/`verify`/`prompt`/`recheck` subcommands)
  crashed with an unhandled `KeyError` against `dag_manifest.json` as checked in, because that file
  was silently regenerated from a 36-card "sprint" schema (`spec_file`/`proof_file` per card) to a
  385-card whole-corpus-index schema with neither field, without updating the code. Also fixed: a
  case-sensitivity bug (`"Verified"` vs. the code's `"PROVED"/"VERIFIED"`) that made the scheduler
  and the status display silently disagree about what was done; unqualified dependency names
  (`"DilatonMeasure"` vs. the real key `"DoubleFieldTheory.ActionCurvature.DilatonMeasure"`) that
  permanently deadlocked 243/385 cards with zero diagnostic; and hardcoded fake-looking fallback
  numbers (294.9 ms, 10.62 s, 7 iterations) that `run_full_schedule` printed as if freshly measured
  whenever nothing was actually verified. See commit `756fd95` for the fix and its verification.
- **Macroscopic Physics Discussed (tiered, not "certified"):**
  1. Epistemic-tier framing of the Landscape Problem (Tier C proposal, motivated by Tier A arithmetic).
  2. Double Field Theory and $O(D,D)$ geometry: Tier L theory, Tier A only for a 1D scalar-model
     instance of the algebraic shape (Courant bracket antisymmetry / Jacobiator vanishing).
  3. Effective dual scale / kinematic bounce: Tier L real bound (Brandenberger-Vafa, Giveon-Porrati-
     Rabinovici), Tier A only for the $\mathbb{N}$-valued instance $R\ge1\Rightarrow R^2+1\ge2$.
  4. TCC: Tier A arithmetic instance is *conditional* on an assumed sub-Planckian Hubble scale, not
     an unconditional proof.
  5. Moduli stabilization: **withdrawn as a theorem.** $\mathcal{N}=4$ non-renormalization forbids a
     potential without a flux/brane completion this corpus doesn't construct. The toy potential
     (`UseCase1_ModuliStabilization.moduli_potential`) had a real bug — `Nat` truncation made the
     "unique minimum" non-unique — fixed by moving to `Int` and adding a genuine
     `moduli_potential_zero_iff` uniqueness proof (commit `e831efb`).
  6. $M_{24}$ Mathieu Moonshine cross-multiplication and $|M_{24}|=27720\times8832$ ($8832=2^7\times
     3\times23$, corrected — an earlier revision had $2^6\times3\times23=4416\ne8832$): Tier A
     arithmetic; the "lock" framing is weakened by the fact that $27720=\mathrm{lcm}(1,\dots,12)$.
  7. Zero-free-parameter claim: **restated as Conjecture 7.1 (Tier C)**, not a theorem — no such
     theorem exists anywhere in this corpus.
  8. Phenomenology: $r=1/252\approx0.00397$ (exact fraction, not the old rounded/inconsistent
     $0.00396$); $\delta_{\mathrm{CP}}=283°$ (corrected — an earlier revision said $282.4°$, from
     silently mixing two different fractions, $77/360$ and $77/60$); $(w_0,w_a)=(-1,0)$ is **in
     tension with DESI DR2** (prefers $w_0>-1,w_a<0$ at $3.1\sigma$), not merely "to be tested."
- **Publication & Documentation:**
  - 7 LaTeX papers; paper 7 (`paper7_dual_scale_theory_master_demonstration.tex`) is now Revision 2
    with the tiered framing above throughout, a Claim Ledger appendix, and an Axiom Audit appendix
    reproducible via `papers/publication/axiom_audit_script.lean`. **Papers 1–6 have not been
    audited for the same issues and likely share some of them** (paper 1's title alone,
    "Certified Dual-Scale Moduli Stabilization," is exactly the claim withdrawn from paper 7) —
    flagged, not yet fixed; a natural next task.
  - README.md carries the same tiered-claims revision as of this session (title, badges, §3, code
    snippets that previously did not match the cited files verbatim — including one example that
    used `Matrix.identity`, an API this Mathlib-free project cannot have — and a "zero-sorry audit"
    shell snippet that actually raised `AssertionError` if you ran it).
  - `LEDGER.md`'s `OBS-VAL-0001` entry still needs the same $\delta_{\mathrm{CP}}$/window correction
    applied to `Observables.lean` in this session (theorem names there were also renamed:
    `tensor_to_scalar_in_litebird_window` → `tensor_to_scalar_in_illustrative_window`, etc.) —
    check whether that got fixed in this pass or is still open.

## Active Rules & Guidelines
1. **Strict Read-Only Guardrail:** `/home/xavkal/xdev` is strictly read-only.
2. **0-Sorry Invariant:** No Lean code will ever be pushed containing `sorry` or `admit`. All axioms
   must be restricted to standard Lean (`propext`, `Classical.choice`, `Quot.sound`). Verify this
   claim with a tactic-position grep and/or `#print axioms`, never a bare substring/keyword count.
3. **Tier discipline (new):** Tier A = Lean-kernel-checked with a statement-adequacy audit (the Lean
   type must actually say what the prose claims — check this explicitly, don't assume). Tier L =
   literature, quoted not re-derived. Tier C = this project's own conjecture/numerology, not proved.
   Never present Tier C as Tier A, and never let a headline claim (title, abstract, README badge)
   omit the tier a supporting claim needs.
4. **Artifact-Driven Workflow:** Major architectural planning and reporting are generated into `.md`
   artifacts within the agent environment.
5. **Epistemic Narrative:** Physics explanations should trace back to what's actually mechanically
   verified, and say plainly when they don't (this project has no Mathlib, hence no real numbers,
   manifolds, or differential geometry — every Lean proof here is over `Nat`/`Int`/a hand-rolled
   rational-pair structure).

## Additional fix (same day, follow-up to the engine/Lean/docs review above)
`StringTheoryFoundation` (one of the five live libraries — genuinely 0 sorry, standard axioms only,
per the review above) had a second, distinct honesty gap, found while evaluating "the state of the
string theory formalization": (a) 10 theorems across 8 files that proved nothing — a `structure`
field's *default value* checked against the same literal, e.g. `witten_6d_supercharges :
defaultSixDSusy.numSupercharges = 16 := by decide` where `numSupercharges := 16` was the field's own
default; (b) six "Bridge" files (`FermatModularBridge.lean`, `TensorNetworkBridge.lean`,
`AtlasGeometryBridge.lean`, `PhysLibKinematicsBridge.lean`, `StatisticalLearningBridge.lean`,
`NavierStokesBridge.lean`) whose names and docstrings invoke real external projects vendored as
`lean4basesource/` submodules (Wiles' FLT modularity theorem and "Anthropic Research, Formalizing
Fermat's Last Theorem in Lean 4" in the first case) but import nothing beyond this project's own
`Core.Topology` (or, for `AtlasGeometryBridge.lean`, nothing at all). Both fixed: the 10 theorems now
either compute genuinely (e.g. `numSupercharges := 32 / 2`) or are removed/annotated as definitional;
all 6 Bridge files carry an honest scope note. See
`papers/publication/PAPER7_ENGINE_LEAN_DOCS_REVIEW.md` §4 for full detail. `lake build` clean (61/61)
before and after; exhaustive sorry/admit and `#print axioms` sweeps re-run clean (237 theorems/lemmas
now, standard axioms only).

## Next Steps / Backlog
- Audit and fix papers 1–6 the way paper 7 was fixed (moduli-stabilization title claim in paper 1 is
  the most urgent).
- Decide and act on `StringTheoryFormalization/`, `Tests/Main.lean`, and the redundant nested
  `DualScaleM24Formalization/lakefile.lean` (archive/delete, or properly integrate with Mathlib).
- Apply the LEDGER.md `OBS-VAL-0001` fix if not already done.
- Continue to refine RAG & LeanGraph elements for physicist adoption; regenerate `graph/leangraph.json`
  before quoting its node/edge counts anywhere (they drift — this session found the README, paper,
  and internal `PEER_REVIEW_REPORT.md` all quoting three different numbers for the same graph).
- Onboard subsequent Lean 5 frontier problems into `Lean5Corpus`.
- Expand testing suite and performance cache optimizations for Lake CI/CD.
- If moduli stabilization is ever pursued for real: needs a concrete flux/brane completion consistent
  with $\mathcal{N}=4$ non-renormalization, not another toy potential.
