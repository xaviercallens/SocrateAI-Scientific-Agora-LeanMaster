---
name: lean-proof-gate
description: Use before claiming that any Lean 4 result is proved, verified, complete or sorry-free, in LeanMaster or in any other Lake project. Runs the five gates (build, sorry count, axiom audit, statement lock, producer≠verifier) with the reusable LeanMaster tools and reports results honestly.
---

# The proof gate

A green build is not the gate. Run all five and report each literally.

```bash
LM=~/SocrateAI-Scientific-Agora-LeanMaster          # tools live here
export LEAN_PROJECT_ROOT=/path/to/your/lake/project   # omit when working inside LeanMaster
cd "$LEAN_PROJECT_ROOT"

lake build MyLib                                      # G1: build the LIBRARY target (not only modules:
                                                      #     a stale root .olean breaks the audit)
grep -rn "sorry\|admit" MyLib --include=*.lean | grep -v "^\s*--"    # G2: must be empty
python3 $LM/tools/axiom_audit.py MyLib                # G3: every theorem ⊆ {propext, Classical.choice, Quot.sound}
python3 $LM/tools/statement_lock.py --check MyLib/**/*.lean           # G4: reviewed statements unchanged
```

* **G3** fails on `sorryAx` (also when a theorem merely *depends* on a sorry) and on
  `Lean.ofReduceBool` (`native_decide`). Exit code 2 / "AUDIT ERROR" means the audit could not run
  (library not built) — that is not a proof result; fix the build and rerun.
* **G4**: after a human/orchestrator has reviewed the statements, lock them with
  `statement_lock.py --update <files>`; the lock is stored in `$LEAN_PROJECT_ROOT/docs/statement_lock.json`.
  Proof and comment changes do not affect it; any change to a theorem statement or a definition body does.
  Run `--check` before accepting any proof produced by an agent — agents make goals "provable" by
  weakening them.
* **G5 producer ≠ verifier**: whoever wrote the proof does not certify it. Recompile subagent output
  yourself; subagent reports of "0 errors" were wrong three times in one run (LL.md S2.3).
* Validate the audit once per project with a positive control (a clean library) and a negative
  control (a file with a `sorry`).

Report format: jobs built, sorry count, "N theorems audited, M failing", lock result. If something
was skipped, say so.
