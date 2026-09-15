# Documentation & RAG/Graph Coverage Campaign

**Goal:** raise the corpus's *composite* "Narrative-Complete" coverage — declarations that
simultaneously have a docstring, a genuine (non-template-copied) Physical Meaning narrative, and
`@concept`/`@rag_query`/`@graph_node` (or `@graph_edge`) tags — from a measured baseline of **5.7%**
to **≥80%**.

**Why composite, not marginal:** the corpus's four coverage numbers (docstring/phys-meaning/concept/
rag-query/graph-node) are usually quoted separately (e.g. "76.7% have docstrings"), but they are
*marginal*, not intersected — a declaration can have a docstring and still be missing every tag.
The number that actually matters for "is this theorem genuinely discoverable and explained" is the
intersection, which this session measured directly at **29/507 = 5.7%** before any work — bounded
above by the smallest marginal (`@rag_query`, 5.7%), meaning almost every tagged declaration already
had everything else too, but almost nothing had everything.

**Tooling:** `python3 tools/commentsworkflow.py audit --composite` reports the real, current
percentage (recompute before trusting any number in this file — it drifts as the corpus grows).
`--gap-list` lists, per file and per declaration, exactly what's missing, for batch planning.

**Scope note on `prove2me_engine/`:** deliberately *not* included in this campaign's denominator.
Its `specs/Specs/CardNN.lean` / `proofs/Proofs/ProofNN.lean` files are designed around
`orchestrator.py`'s `format_agent_prompt()` producing an *ultra-compact* (<800 token) prompt per
card — the whole design goal is minimal context, the opposite of the verbose physicist-narrative
template used elsewhere. Holding it to the same "Physical Meaning" narrative standard would work
against its own stated purpose; it should be tracked separately if it needs this at all.

**Scope note on `StringTheoryFormalization/`:** also excluded — it's not registered in any
`lakefile.lean` and doesn't currently compile (needs Mathlib, which the root package doesn't
depend on; see `/home/xavkal/.claude/plans/mighty-skipping-meadow.md` Phase 1a for that separate,
pending decision). Adding narrative to code that doesn't build would be polishing something whose
own soundness is still unresolved.

## Progress log

| Batch | Date | Files touched | Declarations completed | Composite before → after | Notes |
|---|---|---|---|---|---|
| 0 (baseline) | 2026-09-15 | — | — | — → 29/507 (5.7%) | Measured via the newly-added `--composite` flag; confirmed `lake build` clean and 0 sorry/admit (tactic-position grep, not inferred from build exit code — `commentsworkflow.py verify` also fixed this session to check both separately) |
| 1 | 2026-09-15 | `DoubleFieldTheory/ActionCurvature.lean` (4), `StringTheoryFoundation/StringTheory/VafaSwampland.lean` (3), `Lean5Corpus/Problems/Problem1_NavierStokesHelicity.lean` (4), `Lean5Corpus/Problems/Problem3_DualScaleTCC.lean` (4) | 15 | 29/507 (5.7%) → 44/507 (8.7%) | Cheapest tier: all 15 already had a genuine docstring + Physical Meaning narrative + `@concept` + `@graph_node`; only `@rag_query` was missing. Added one grounded in what the declaration actually states (not template text). `lake build` reconfirmed clean, 0 sorry/admit, after the edit. |

**Gap to target after batch 1: 362 of 507 declarations.**

## What's left, roughly by cost tier (re-run `--gap-list` for the current exact numbers)

1. **Tag-only completions** (declaration already has a real narrative, just needs `@concept`/
   `@rag_query`/`@graph_node`): cheapest, lowest-risk, mechanical once the narrative is read. Batch 1
   exhausted the files where *every* gap was this cheap; remaining files mix this with harder gaps.
2. **Narrative completions** (declaration has a docstring but no `**Physical Meaning:**` block, or a
   template-copied one): needs someone who can state precisely what the Lean statement proves,
   physically, without overclaiming — this is where the tautology-fixing discipline from this
   session's earlier `StringTheoryFoundation` pass applies directly. The riskiest sub-case is
   cross-domain physics (Moonshine/M24 representation theory, SYZ mirror symmetry, swampland
   distance bounds) — get these wrong and the fix is worse than the gap.
3. **Bare declarations** (no docstring at all — 507−389 = 118 of them): full narrative + tags from
   scratch. Highest cost per declaration, and the highest-risk tier for introducing exactly the kind
   of overclaiming this project's earlier audits (`PAPER7_IMPROVEMENT_PROPOSAL.md`,
   `PAPER7_ENGINE_LEAN_DOCS_REVIEW.md`) spent real effort removing — never write a `**Physical
   Meaning:**` claim broader than what the Lean type actually states, never paste
   `templates/LEAN4_PHYSICS_RAG_GRAPH_TEMPLATE.md`'s literal example text, and never state a number
   (a prediction, a group order, a topological invariant) without reading it from the Lean `def` that
   actually computes it.

## Honest scale estimate

At ~15 declarations per careful batch (batch 1's actual size), reaching 362 more declarations is
roughly **24 more batches** — this is a genuine multi-session campaign, not a one-sitting task.
Track it here rather than re-deriving the baseline each time.
