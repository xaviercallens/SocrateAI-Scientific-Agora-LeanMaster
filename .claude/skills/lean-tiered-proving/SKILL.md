---
name: lean-tiered-proving
description: Use when you need to get a batch of new Lean 4 theorems proved (in any project) with AI provers at low cost — a local prover model for concrete goals, Haiku for short symbolic algebra, Sonnet for goals needing an idea — with the Lean kernel as the only judge. Encodes the measured lessons of the LeanMaster Stream 2 run.
---

# Tiered proving workflow (T0 orchestrator → T3 local → T2 Haiku → T1 Sonnet)

1. **Design statements first, in one pass (T0 = you).** Write every `def` and `theorem … := by sorry`.
   Pre-verify conventions symbolically (sympy: signs, block orders, normalizations) BEFORE stating.
   Split concrete content (fixed matrices, numerals, finite tables) into separate lemmas — they are
   nearly free for the local prover. `lake build`, then `statement_lock.py --update` (skill `lean-proof-gate`).
2. **T3 local prover** (Ollama `deepseek-prover-v2:7b-q8_0` on the T4; models under
   `/mnt/disks/disk-socrateai-local-1/leanmaster/ollama`):
   `python3 tools/prover_loop.py File.lean --models <model> --rounds 3`
   It replaces one `sorry` at a time, compiles with the real heartbeat flags, keeps only kernel-accepted
   proofs, logs to `.leancache/prover_attempts.jsonl`. Expect: closes concrete goals, not symbolic general-n ones.
   Thinking models (Goedel-Prover) are unusable at T4 speed — check `done_reason` before blaming capability.
3. **T2 Haiku** for short symbolic algebra; **T1 Sonnet** directly for anything with matrix inverses,
   positivity, general `n`, or that timed out. When a goal times out, change the *route* (e.g. sum of
   squares instead of a 64-entry matrix product) before changing the *tier*.
4. **Every agent prompt contains**: "unsolved goals stay exactly `sorry`; do not change any statement or
   definition; final compile 0 errors; paste the literal compiler output"; a wall-clock limit
   (≈45 min Haiku, ≈90 min Sonnet). At most 3 compile-heavy agents at once on the 8-core VM.
5. **Accept nothing on report.** Recompile each file yourself with
   `lake env lean -DmaxHeartbeats=1000000 -DmaxRecDepth=8000 File.lean`, run `statement_lock --check`,
   restore failed goals to `sorry`, escalate. **A pasted transcript is a claim about a run, not the run** —
   and the danger signature is not carelessness but *near-certainty*: a peer session once wrote out four
   `#print axioms` lines before executing them, and the invented values turned out correct. Require
   "pasted from a tool result in this session"; "pending" is always an available answer. (`LL.md` §S11.4)
5b. **Check the name, not only the goal.** An agent asked to prove `foo_is_bar` can return something true,
   compiling and axiom-clean, that proves less than `foo_is_bar` says — gates cannot see this. Ask: which
   theorem would be *false* if the name were wrong? See skill `claim-audit`. (`LL.md` §S11.1)
6. **Guard data tables with a global theorem** (sum of squares = group order, total count…): a wrong
   M24 table survived for months behind a one-entry check.
7. Finish with the full gate (`lean-proof-gate`) and refresh the search index (`leanmaster-theorem-search`).

Known Lean 4 trap: `structure S where a b c : T` parses as ONE curried field; write `(a b c : T)`.
Reference numbers and failures: `docs/STREAM2_WORKFLOW.md` §6, `LL.md` §S2.
