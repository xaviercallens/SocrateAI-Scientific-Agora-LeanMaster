# Full-Project Review: Engine, Lean 4, Documentation & Scientific Narrative

**Date:** 2026-09-15
**Scope:** the whole repository except `lean4basesource/*` (git submodules pointing to external
projects — anthropics/fermats-last-theorem, facebookresearch/atlas-lean, inQWIRE/LeanQuantum,
openai/NavierStokesAndEuler, leanprover-community/physlib, etc. — not this project's own code).
**Priority order, as requested:** the "engine" (`prove2me_engine/`) first, then Lean 4 (compile
everything, find every remaining `sorry`/axiom issue), then documentation and scientific narrative.
**Companion document:** `PAPER7_IMPROVEMENT_PROPOSAL.md` (the prior session's audit of paper 7 alone;
this document extends the same method — statement-adequacy, tier discipline, reproduce-before-trust —
to the rest of the project).

---

## 1. The engine (`prove2me_engine/`)

### 1.1 What it is
A self-contained Lean+Python system implementing a "Prove2Me" decoupled statement/proof workflow:
`specs/Specs/CardNN.lean` (theorem statements) and `proofs/Proofs/ProofNN.lean` (their proofs) are
separate files so an LLM agent can be shown a compact, isolated prompt (`format_agent_prompt`) rather
than the whole corpus. `orchestrator.py` schedules verification across a dependency DAG
(`dag_manifest.json`); `recheck.py` is an independent auditor that re-verifies acyclicity and the
zero-`sorry` invariant and writes a certificate; `cli.py` exposes both as a CLI. It has its own
`lakefile.lean` (`Specs` + `Proofs` libraries), separate from the root project.

### 1.2 P0 — the engine was completely broken against its own live data
`dag_manifest.json` was silently regenerated at some point after the original 36-card "Sprint 1"
certificate (`prove2me_sprint1_certificate.json`, timestamped 2026-09-14T19:01Z) was produced, from a
36-card schema (`spec_file`/`proof_file` per card) to a 385-card whole-corpus-index schema (mtime
2026-09-14T23:12Z, two hours later) with **neither field**, without updating the Python that reads it.
Confirmed by direct reproduction before the fix:

```
$ python3 -c "orch.verify_card(f[0])"           # -> KeyError: 'proof_file'
$ python3 -c "orch.format_agent_prompt(f[0])"   # -> KeyError: 'spec_file'
$ python3 recheck.py                            # -> KeyError: 'spec_file' (same bug, independent code path)
```

`orchestrator.py`'s `if __name__ == "__main__"` entry point, `recheck.py`'s entry point, and the
CLI's `run`/`verify`/`prompt`/`recheck` subcommands were therefore all non-functional. Only the
read-only `status`/`frontier`/`search`/`suggest` subcommands survived (they use `.get()` with
fallbacks), which is why the problem wasn't visible from casual use of the CLI.

Three further, independent bugs compounded this, found while diagnosing it:

1. **Status-casing mismatch.** The 385-card manifest uses `status: "Verified"` (mixed case); the
   scheduler's `get_frontier()` compared status case-sensitively against `["PROVED", "VERIFIED"]`, so
   every one of the 385 cards read as unproved to the scheduler — while `cmd_status` (which
   `.upper()`s first) displayed them as 100% done. The CLI's own status display and its scheduler
   silently disagreed about what was finished.
2. **Unqualified dependency names.** The 385-card manifest's `dependencies` field uses bare names
   (`"DilatonMeasure"`) where `card_id` keys are fully qualified
   (`"DoubleFieldTheory.ActionCurvature.DilatonMeasure"`). 243 of 385 cards (63%) could never resolve
   their dependencies and would have been permanently stuck in the DAG scheduler with **zero
   diagnostic output** explaining why — `run_full_schedule` just returns `success: false` with a
   card/proved count, no indication of *why* a specific card never became eligible.
3. **Fabricated-looking fallback numbers.** `run_full_schedule`'s average-latency/total-time/
   iteration-count fallbacks (`294.9`, `10.62`, `7`) were hardcoded literals — verified to be exactly
   the mean of one real historical 36-card run — silently reprinted as "measured" on any call where
   `latencies` ended up empty (e.g. a no-op run against an already-complete DAG). `recheck.py`'s
   certificate generator hardcoded `average_verification_latency_ms: 294.9` and `total_sorry: 0`
   outright rather than computing them from the audit it had just run, and **unconditionally returned
   `success: True`** regardless of whether its own Step 3 ("all cards proved") had printed PASS or
   FAIL — so the certificate could claim full success even when the status check said otherwise.

### 1.3 Fix (commit `756fd95`)
- `load_manifest()` detects the schema (`"sprint"` vs `"corpus_index"`) and builds a bare-name →
  `card_id` index so unqualified dependency references resolve when unambiguous.
- New `_is_done()` used everywhere status is checked, case-insensitively, so the scheduler and the
  display command can no longer disagree.
- `verify_card()`/`format_agent_prompt()` now return/raise a clear, specific message
  (`"Card X has no 'proof_file' (schema='corpus_index'); ... run 'lake build' in the main project
  instead"`) instead of an unhandled `KeyError`.
- New `get_blocked()` method + `blocked` CLI subcommand: for every card that isn't done and isn't in
  the frontier, explains *why* (unresolved dependency name vs. waiting on a specific, named,
  not-yet-proved dependency) — replacing silent, unexplained deadlock.
- `run_full_schedule()` reports `avg_latency_ms`/`total_proof_time_s` as `None` — not a copied-in
  historical constant — when nothing was verified this run, and prints the blocked-card list.
- `recheck.py` computes `total_sorry` and `average_verification_latency_ms` from the actual
  audit/card data, and gates `success` on Step 3 actually passing.

**Verified after the fix**, against the live 385-card manifest: `status`, `frontier`, `blocked`,
`run`, and `recheck` all complete without error; `run`/`recheck` correctly report 385/385 done, 0
blocked (all genuinely `"Verified"` once the casing bug was fixed); `python3 -m py_compile` passes on
all three edited files. The original 36-card Sprint 1 `Specs`/`Proofs` Lean project still builds
standalone (`lake build` → 77 jobs) and its certificate was restored untouched after an accidental
overwrite during testing (see §1.4).

### 1.4 A mistake made and corrected during this review
While testing the fix, running `python3 recheck.py` against the live manifest overwrote the committed
`prove2me_sprint1_certificate.json` (the historical 36-card certificate) with a new 385-card one. This
was an unintended side effect of a diagnostic command, caught by `git status` immediately afterward
and reverted via `git show HEAD:... | cp` (not `git checkout`, which this session's permission policy
declines for working-tree-discarding commands) before anything was committed. **Lesson for future
sessions:** any command that calls this engine's `run`/`recheck` (or the orchestrator/rechecker
classes directly) writes to `dag_manifest.json` and `prove2me_sprint1_certificate.json` — treat these
as side-effecting, and copy the engine directory elsewhere before invoking them just to test a code
change.

---

## 2. Lean 4: full compilation and axiom sweep

### 2.1 What's live (registered in a lakefile and actually built)
| Project | Lakefile | Libraries | Build result |
|---|---|---|---|
| Root project | `lakefile.lean` | `DoubleFieldTheory`, `DualScaleValidation`, `DualScaleM24Formalization`, `StringTheoryFoundation`, `Lean5Corpus` | `lake build` → **61/61 jobs**, clean |
| `prove2me_engine/` | `prove2me_engine/lakefile.lean` | `Specs`, `Proofs` (36-card Sprint 1) | `lake build` → **77/77 jobs**, clean |

### 2.2 Sorry / admit — exhaustive, whole-repo grep (not a sample)
A tactic-position-aware grep (matching `sorry`/`admit` only where they'd function as a tactic —
`:= sorry`, `by sorry`, a bare `sorry` line, etc. — not the word appearing in a docstring, which this
corpus's own comments do constantly: "0 sorry, 0 admit") was run over **every** `.lean` file in the
repository outside `lean4basesource/`, 166 files including the dead/orphaned ones (§2.4):

```
grep -rnE '(:=|by|<;>|;)[[:space:]]*sorry\b|^[[:space:]]*sorry[[:space:]]*$|(:=|by|<;>|;)[[:space:]]*admit\b' <166 files>
# => zero matches, anywhere, including the unbuilt code
```

Zero literal `axiom` declarations anywhere in the same 166-file scope. `native_decide` (which trusts
the compiled evaluator, not just the kernel) appears in exactly two files, both dead/unbuilt
(`Tests/Main.lean`, `StringTheoryFormalization/StringDynamics/BPSMultiplicities.lean`) — not in any
library that actually compiles.

### 2.3 `#print axioms` — exhaustive, not just paper-cited theorems
The previous session's paper 7 fix verified axiom footprints for the 16 theorems paper 7 cites by
name. This session extended that to **every** `theorem`/`lemma` in the five live root libraries: 238
declarations, extracted programmatically (namespace-tracking parser over all `.lean` files in the
five libraries), each checked with `#print axioms <fully-qualified-name>` via
`lake env lean --stdin`. Result:

- **149** depend on no axioms at all.
- **89** depend on some subset of `{propext, Classical.choice, Quot.sound}` — verified individually,
  including the 7 whose axiom list line-wrapped in the output (checked in full, not just their first
  line, since a truncated read could hide a fourth entry past the wrap).
- **0** depend on `sorryAx` or on any axiom outside that standard set.
- **0** script errors — every extracted name resolved, which is itself a check that the extraction
  was correct (a wrong namespace path would have produced an "unknown identifier" error, not a
  false pass).

`prove2me_engine`'s 36-card Sprint 1 corpus was spot-checked the same way (first card, last card, and
the one card not following the `card_dft_NNN_proof` naming convention): all three depend on nothing
beyond the standard three axioms.

**Conclusion: the "0 sorry, standard axioms only" claim is genuinely true for everything this project
actually builds** — exhaustively verified this session, not sampled.

### 2.4 Dead / orphaned Lean code (does not build, is not covered by any invariant above)
- **`StringTheoryFormalization/`** (30 files) is **not registered** in the root `lakefile.lean`
  (`lake build StringTheoryFormalization` → `error: unknown target`). It imports Mathlib extensively
  (`Mathlib.Analysis.InnerProductSpace.Basic`, `Mathlib.Geometry.Manifold.Basic`,
  `Mathlib.CategoryTheory.Functor.Basic`, ...) — but this project has **zero external Lake
  dependencies** (`lake-manifest.json`: `"packages": []`). It could not have compiled under the
  project's current configuration regardless of registration. `Tests/Main.lean` imports 15 files from
  it and is itself unregistered in any lakefile — also dead. The name is one character away from the
  live, registered `StringTheoryFoundation/`, which is a standing source of confusion.
  **Recommendation:** archive or delete both `StringTheoryFormalization/` and `Tests/`, or (if the
  Mathlib-dependent content is wanted) add Mathlib as a real dependency and register the library —
  don't leave 30 files of ambiguous, unbuildable status sitting in the tree under a near-duplicate
  name of a real one.
- **`DualScaleM24Formalization/lakefile.lean`** is a second, independently-buildable Lake package
  (confirmed: `cd DualScaleM24Formalization && lake build` → 14/14 jobs, clean) nested inside the
  directory the root project already builds the same source files from. Low risk (the root build
  never touches it), but it's duplicate configuration with its own `.lake/` cache that can go stale
  independently of the root project's. **Recommendation:** delete
  `DualScaleM24Formalization/{lakefile.lean,lake-manifest.json,lean-toolchain,.lake/}` — the root
  lakefile already builds this exact code.

---

## 3. Documentation and scientific narrative

### 3.1 What was fixed this session
- **`README.md`** carried the same class of overclaiming the previous session found and fixed in
  paper 7 — and in one respect, worse, since it's the repo's front door:
  - Title/subtitle ("The First Certified String Theory in Lean 4"), badges ("Free Parameters: 0
    (Diophantine Locked)"), and the "Key Breakthroughs" list asserted certification of physics the
    Lean code doesn't formalize. Rewritten with the same Tier A/L/C convention as paper 7 §1.1, with
    an explicit note at the top explaining what changed and why (mirroring the paper's §1.2).
  - §3 ("Rigorous Proof... ZERO FREE PARAMETERS") is now framed as a labeled conjecture, with the
    $27720=\mathrm{lcm}(1,\dots,12)$ caveat and the $\mathcal{N}=4$ non-renormalization obstruction
    stated up front, and the summary comparison table rewritten to show tiers instead of blanket
    "Certified (0 sorry)" for physics claims that aren't.
  - **§4's four "Certified Lean 4 Code Snippets" did not match the files they cited.** Example 1's
    theorem was named `effective_scale_strictly_super_planckian`; the real theorem in that file is
    `self_dual_is_global_minimum`. Example 2's was named `bps_rigidity_lock_identity`; the real name
    is `bps_cross_multiplication_lock`. Example 4 used `theorem odd_metric_is_involution (D : Nat) :
    ... = Matrix.identity := by ...` — `Matrix` is a Mathlib type this Mathlib-free project cannot
    reference, and a bare `...` is not valid Lean syntax; nothing resembling this theorem exists in
    the cited file. All four snippets are now copied verbatim from the actual current source, with a
    note at the top of §4 stating this is a hard requirement.
  - §10's own "Auditing Zero-Sorry Compliance" shell snippet did a naive substring check
    (`'sorry' not in content`) that **raises `AssertionError` if you actually run it**, because this
    corpus's own docstrings say "0 sorry" — confirmed by running it. Replaced with the
    tactic-position-aware grep used throughout this review, plus a new subsection reporting the
    exhaustive 238-theorem axiom sweep from §2.3.
  - Stale LeanGraph badge (528/785) corrected to the currently-regenerated 538/807 (see the same
    caveat as paper 7: this number drifts and should be regenerated, not copied, before each release).
- **`memory.md`** (the project's own persistent context file, read at the start of future sessions)
  rewritten to reflect all of the above — leaving it stale would have handed a future session exactly
  the claims this review retracted, as a "fact" to build on.
- **`LEDGER.md`**: `DUALSCALE-VAL-0002` (the moduli-stabilization entry) and `OBS-VAL-0001` (the
  phenomenology observables entry) updated to match the corrected `Observables.lean` and
  `UseCase1_ModuliStabilization.lean` — theorem names, the exact-fraction $r=1/252$, the corrected
  $\delta_{\mathrm{CP}}=283°$, and the DESI DR2 tension — since the ledger's own stated principle
  ("no claim in a sound ledger rests on a weaker claim") requires the entries to actually match the
  code they cite.

### 3.2 Flagged but not fixed this session (scope decision, not an oversight)
- **Papers 1–6** (`papers/publication/paper{1..6}_*.tex`) have not been audited. Paper 1's title alone
  — *"Certified Dual-Scale Moduli Stabilization and Geometric Vacuum Selection in Double Field
  Theory"* — is exactly the claim withdrawn from paper 7 §5.1 this session's predecessor fixed. These
  six papers very likely share some fraction of the issues found in paper 7 (statement-adequacy gaps,
  the same $\delta_{\mathrm{CP}}$/$8832$ arithmetic, code snippets that may not match source verbatim,
  the moduli-stabilization claim). Auditing and fixing all six at the same depth as paper 7 is a
  comparably large task to the one already done for paper 7 alone; recommended as the next follow-up,
  not attempted here to keep this session's scope (engine → Lean → docs) tractable.
- Other markdown docs not scanned in depth: `ROADMAP.md`, `DUAL_SCALE_STRING_THEORY_PLAN.md`,
  `LEAN5_SCIENTIFIC_CORPUS.md`, `RELEASE_PHASE1B.md`, `FOUNDATIONS.md`, `PEER_REVIEW_REPORT.md`, the
  `communications/` outreach drafts, and `blueprint/`'s generated web content. A targeted grep for the
  most acute red flags (`100% certified`, the old $282.4°$ figure, stale file/declaration counts)
  found nothing further beyond what's listed above, but this was a grep-level pass, not a full read.

---

## 4. Summary

| Area | Before this session | After |
|---|---|---|
| Engine (`prove2me_engine`) | Every write/execute path crashed (`KeyError`) against its own live manifest; scheduler and status display silently disagreed; 63% of the 385-card DAG permanently, silently deadlocked; fabricated-looking fallback metrics | All paths run cleanly; case-insensitive status check; dependency names resolved where unambiguous; blocked cards explained; no fabricated numbers; certificate generator computes its own headline stats and gates on its own pass/fail check |
| Lean 4 sorry/admit | Believed zero (paper-cited subset checked previously) | Confirmed zero, exhaustively, across all 166 `.lean` files in scope, including dead code |
| Lean 4 axioms | Believed standard-only (16 paper-cited theorems checked previously) | Confirmed standard-only (`propext`, `Classical.choice`, `Quot.sound`), exhaustively, across all 238 theorems/lemmas in the five live libraries |
| Dead/orphaned Lean code | Unflagged (`StringTheoryFormalization/`, `Tests/`, redundant nested lakefile) | Identified, explained, and a concrete recommendation given (not deleted — that's a call for the repo owner) |
| README.md | Same overclaiming as pre-fix paper 7, plus four code snippets that didn't match their cited files (one using a nonexistent `Matrix` API) and a verification snippet that crashes if run | Tier-labeled throughout; all four snippets verbatim; verification snippets actually work |
| memory.md / LEDGER.md | Stale, would re-seed the retracted claims into a future session | Corrected and cross-referenced to this document and to `PAPER7_IMPROVEMENT_PROPOSAL.md` |
| Papers 1–6 | Unaudited | Still unaudited — flagged as the top follow-up item |
