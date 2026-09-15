# Roadmap: A Rigor-Complete, Full-Kernel-Compiling String Theory Formalization

**Status as of 2026-09-15.** This document is the ground-truth resume point for the next session
(planned to run on a machine with adequate disk/CPU/GPU). It supersedes `ROADMAP.md`'s Phase 0–3
vision doc as the source of *current, verified* state — `ROADMAP.md` describes a long-horizon
aspirational architecture (GCP TPU swarms, edge GPU inference, etc.) that has not been built or
attempted; nothing in it should be read as a claim about what exists today. This document only
records what has actually been checked with `lake build`, a tactic-position `sorry`/`admit` grep, or
`#print axioms`, and lays out the concrete next steps to close the gap between the two.

## 1. What "rigor-complete" means here

A declaration only counts as done when all four hold:
1. It is registered in a `lakefile.lean` that is actually built (`lake build <target>` exits 0).
2. A tactic-position grep (not substring match) finds no `sorry`/`admit` in its proof.
3. `#print axioms` on it reports only `{propext, Classical.choice, Quot.sound}`.
4. Its Lean *type* actually states what its docstring/paper prose claims (statement-adequacy audit —
   the recurring failure mode this session found and fixed is a declaration that compiles cleanly but
   proves something trivial or unrelated to its name/docstring, e.g. a `structure` field checked
   against its own default value).

Everything below is organized around closing gaps against this bar, not around adding volume.

## 2. Current verified state (honest baseline)

- **5 live, registered libraries**, all `lake build` clean, **zero Mathlib dependency**
  (`lake-manifest.json`: `"packages": []`): `StringTheoryFoundation`, `DualScaleValidation`,
  `DoubleFieldTheory`, `Lean5Corpus`, `DualScaleM24Formalization`. 237 theorems/lemmas, all
  standard-axioms-only, zero `sorry`/`admit` (tactic-position grep, re-verified this session).
- **1 large, unreachable library**: `StringTheoryFormalization` (30 modules, 63 theorems,
  29/30 files `import Mathlib.*`) is **not registered in any `lakefile.lean`** and cannot build —
  this project has no Mathlib dependency at all. It was previously folded into combined "verified"
  totals by `workflowphase1run3.py`'s regex-only auditor; this is fixed at the reporting layer
  (`UNREACHABLE`, excluded from totals) but the library itself still doesn't build. This is the
  single largest concrete step toward "full kernel compiling" — see §3 Phase A.
- **6 "Bridge" files** in `StringTheoryFoundation/` (named after vendored external repos) now carry
  honest SCOPE NOTEs stating they import nothing from those repos and are self-contained
  Nat/Int arithmetic inspired by, not derived from, the cited work. 10 previously-tautological
  theorems (a struct field checked against its own default) were fixed or removed.
- **8 vendored git submodules** under `lean4basesource/` (`anthropics-flt`, `xaviercallens-xflt`,
  `openai-navierstokes`, `physlib`, `tnlean`, `atlas-lean`, `lean-quantum`,
  `lean-stat-learning-theory`) are all real, non-trivial formalizations — but **all 8 require Mathlib
  in their own build**, so none can be imported by this project today regardless of which one is
  picked first. Verified pointers to real declarations in 4 of them (real theorem/def names, not
  vague citations) are now recorded in `FOUNDATIONS.md` and the corresponding Bridge files.
- **Documentation/RAG-tag coverage**: composite (docstring + `@rag_query`/`@graph_node`/`@graph_edge`
  tags all present, and not copy-pasted from the template) is **44/507 = 8.7%**, up from a 5.7%
  baseline, against an (out-of-scope-for-now) 80% aspiration. See `docs/DOC_COVERAGE_CAMPAIGN.md`.
- **Papers 1–6** (`papers/publication/paper{1..6}_*.tex`) are **unaudited** — only paper 7 has been
  brought to tier-discipline. Paper 1's title is known to repeat the withdrawn moduli-stabilization
  claim paper 7 corrected.

## 3. Phased plan to close the gap

### Phase A — Register `StringTheoryFormalization` with Mathlib (needs the powerful server)

**Blocked this session on disk space** (2.2 GB free on a 100%-full 234 GB filesystem — insufficient
for Mathlib's source + compiled `.olean` cache; attempting it risked a corrupted Lake manifest/cache
rather than a clean failure). **Not abandoned** — resume here first on the new machine.

The Mathlib commit to use is already determined, no re-investigation needed:
`db584cd6d46c92f209a44c0f1c829460d327499d` from `leanprover-community/mathlib4`. This is not a
guess: both `lean4basesource/anthropics-flt` and `lean4basesource/xaviercallens-xflt` pin exactly
this commit on `leanprover/lean4:v4.33.1` — the identical toolchain this project already uses
(`lean-toolchain`), eliminating version-skew risk.

Steps:
1. Add `require mathlib from git "https://github.com/leanprover-community/mathlib4" @
   "db584cd6d46c92f209a44c0f1c829460d327499d"` to the root `lakefile.lean`.
2. Add `StringTheoryFormalization` (and `Tests/Main.lean`, previously dead for the same reason) as
   `lean_lib` targets, mirroring the existing 5 entries.
3. `lake update`, then `lake build StringTheoryFormalization` **in isolation** first.
4. **Decision rule**: clean build (or a small, enumerable set of fixes — renamed lemmas, API drift) →
   fix and proceed. Large/systemic failures (this file set has never been checked against a real
   Mathlib) → stop, report actual scope found, do not grind through it as an open-ended task.
5. Once it builds: run the tactic-position `sorry`/`admit` grep and a full `#print axioms` sweep
   against it — a clean build alone does not guarantee either. Pay specific attention to
   `StringTheoryFormalization/NSMath/FractionalSobolev.lean`: its header comment claims "2 sorry
   axioms" while grep finds zero (stale/contradictory metadata), and its `sobolev_embedding` theorem
   takes `Summable` hypotheses as **assumed, not proved** — a hypothesis-smuggling pattern invisible
   to both a sorry-grep and a bare axiom check. Any theorem like this should be reported as
   **conditional Tier A** (compiles, standard axioms, but rests on an unproved hypothesis), never
   folded into a plain "verified" count.
6. Only after this is known does any combined theorem-count/coverage number get updated — see §1's
   four-part bar.

### Phase B — Build `tools/verify_corpus.py` (the consolidated auditor)

A standalone script codifying this session's manual method so it never has to be redone by hand:
per-library `lake build` + tactic-position sorry/admit grep + `#print axioms` sweep + transitive
import-closure check (flags any file outside `lean4basesource/` that no registered library imports —
this is what would have caught `StringTheoryFormalization` automatically) + a `.tex` → real-
declaration cross-check for every `\lean{...}`/`\texttt{...}` reference under `blueprint/` and
`papers/`. Also add the hypothesis-smuggling check from Phase A step 5, generalized (flag any
theorem with an undischarged `Summable`/`Continuous`/`Integrable`-style hypothesis), and a
stale-status-comment check (header comment's claimed sorry/axiom count vs. actual grep result).

**Validate before trusting it**: run against the current repo state first. It must reproduce, without
being told: `StringTheoryFormalization` as `UNREACHABLE`, and 8 of `blueprint/src/content.tex`'s 10
`\lean{}` tags as broken (exact wrong→correct table already in the plan file, §"Phase 3 step 1"
below). If it doesn't reproduce both exactly, the tool is wrong, not the repo.

### Phase C — Wire the verifier into `workflowphase1run3.py` and the 29-block coverage table

`SkillPhase1Run3Auditor.audit_library()` and `Phase1Run3CoverageEngine.evaluate_coverage()` both
currently do their own regex scans and never call `lake build`; ~13 of the 29 coverage blocks cite
`StringTheoryFormalization` files and report `coverage_score: 1.0` for code that cannot compile.
Both should delegate to `verify_corpus.py`'s index instead, so post-Phase-A reality (whatever it
turns out to be — clean build, conditional Tier A, or still-blocked) is reflected automatically
rather than requiring another manual correction pass.

### Phase D — Fix the remaining specific overclaiming (each independently verifiable, low risk)

1. **`blueprint/src/content.tex`**: 8 of 10 `\lean{}` labels point at renamed/nonexistent
   declarations (full wrong→correct table is in
   `/home/xavkal/.claude/plans/mighty-skipping-meadow.md`, "Phase 3 step 1" — carry it over
   verbatim). One was broken by this session's own `Observables.lean` rename
   (`observables_falsifiable_master_contract` → `observables_windows_master_contract`). Also narrow
   `thm:coset_involution`'s prose — the theorem only holds at the self-dual point (`h : g = 1`), not
   the general coset statement currently claimed.
2. **`tools/socrateai_oracle.py`** / **`tools/build_blueprint.py`**: both hardcode a stale physics
   ledger (`r=0.00396`, `δ_CP=282.4°`, no DESI tension) that this session's `Observables.lean`/
   `LEDGER.md` fixes already superseded (`r=1/252≈0.00397`, `δ_CP=283°`). Add
   `tools/ledger_facts.py` (~20 lines, reads the `def`s directly from `Observables.lean`/
   `UseCase2_MoonshineBPS.lean` plus the `LEDGER.md` tier-caveat string) and point both at it instead
   of hardcoded literals.
3. **`FOUNDATIONS.md`** §1 row 3 and §3 — already substantially fixed this session; recheck after
   Phase A in case the Mathlib registration changes what's importable.
4. **`LEAN5_SCIENTIFIC_CORPUS.md`** — replace the "100% CERTIFIED (0 SORRY / 0 ADMIT)" banner with
   the tier vocabulary already used in README.md.
5. **`RELEASE_PHASE1B.md`** — add a one-line "⚠️ Historical snapshot" banner; do not rewrite its
   historical numbers (it's a tagged release note).
6. **`communications/*.md`** (4 unpublished outreach drafts) — append a caveat line to each.

### Phase E — Skills and agents (codify the discipline so it isn't re-derived by hand again)

4 Claude Code skills (`.claude/skills/`): `lean-corpus-verifier`, `tier-discipline`,
`bridge-integration-honesty`, `rag-graph-coverage`. 2 read-only subagents (`.claude/agents/`):
`lean-verifier` (runs Phase B's tool, reports verbatim, never rounds a partial failure up),
`claim-auditor` (given one file, produces a referee-style P0/P1/P2 report). Mirror both into the
project's own existing convention: `skills/lean-corpus-verifier/SKILL.md` and a 5th agent spec in
`tools/antigravity_agent_swarm.py` (`corpus_auditor`), while also fixing that swarm script's "🎉 100%
SUCCESS" print to actually check all subprocess return codes, not just the first. Full design (exact
skill procedures, agent tool allowlists) is in
`/home/xavkal/.claude/plans/mighty-skipping-meadow.md` Phases 4–6 — carry it over unchanged.

### Phase F — Continue the documentation-coverage campaign (deferred, not cancelled)

Currently 44/507 = 8.7% composite coverage (docstring + all three RAG/Graph tags present + not a
template copy-paste). Reaching the 80% aspiration is an estimated ~24 more batches of the kind
`docs/DOC_COVERAGE_CAMPAIGN.md`'s batch 1 already demonstrated is safe (grounded per-declaration,
not templated). This remains explicitly **out of the critical path** to "full kernel compiling" —
documentation coverage and proof-kernel rigor are separate axes — but should resume once Phases A–D
are stable, using `tools/commentsworkflow.py --composite --gap-list` to pick the next batch.

### Phase G — Audit papers 1–6 the way paper 7 was audited

Apply the same process used for paper 7 (`papers/publication/PAPER7_IMPROVEMENT_PROPOSAL.md` is the
template): tier-badge every claim, cross-check `\lean{}`/numeric citations against real declarations
post-Phase-A, and specifically fix paper 1's title, which currently repeats the moduli-stabilization
claim paper 7 already walked back to a Tier C conjecture.

## 4. Order of operations for the next session

Phase A must come first — it is the only step that changes what's actually kernel-checked, and it
determines whether Phases B–D operate on "StringTheoryFormalization now compiles" or "still
blocked, documented why." Do not start Phase E (skills/agents) until Phase B's tool is built and
validated against known-bad ground truth (§3 Phase B's validation step) — building automation on top
of an unverified checker just relocates the overclaiming risk into the tool itself.

Suggested sequence: **A → B (validate) → C → D → E → G**, with **F** picked up opportunistically
whenever there's a natural pause, since it's fully decoupled from the others.

## 5. Full verification gate before any future release tag

Run, in order, and confirm all agree with each other:
```
python3 tools/verify_corpus.py --strict
lake build                              # root, now including StringTheoryFormalization
lake build                              # in prove2me_engine/
python3 tools/commentsworkflow.py audit
python3 workflowphase1run3.py --verify-all
python3 tools/antigravity_agent_swarm.py audit
```
No release should claim a theorem/coverage count that doesn't trace to this sequence's actual output.

## 6. Source documents

- `/home/xavkal/.claude/plans/mighty-skipping-meadow.md` — the full detailed plan (exact tables,
  file-by-file specifics) this roadmap summarizes and sequences; not superseded, just prioritized.
- `memory.md` — session-by-session state log, "Mathlib registration" section has the same disk-space
  blocker detail as §3 Phase A above.
- `papers/publication/PAPER7_ENGINE_LEAN_DOCS_REVIEW.md` — the full engine/Lean/docs audit this
  roadmap's §2 baseline is drawn from.
- `docs/DOC_COVERAGE_CAMPAIGN.md` — Phase F's tracking document.
