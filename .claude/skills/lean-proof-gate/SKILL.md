---
name: lean-proof-gate
description: Use before claiming that any Lean 4 result is proved, verified, complete or sorry-free, in LeanMaster or in any other Lake project. Runs the five gates (build, sorry, axiom audit, statement lock, producer≠verifier) with the reusable LeanMaster tools, reads their exit codes correctly, and reports results honestly.
---

# The proof gate

A green build is not the gate. Run all five, **read the exit code, and report each literally.**

```bash
LM=~/SocrateAI-Scientific-Agora-LeanMaster            # tools live here
export LEAN_PROJECT_ROOT=/path/to/your/lake/project   # omit when working inside LeanMaster
cd "$LEAN_PROJECT_ROOT"

lake build MyLib      > build.log 2>&1 ; echo "G1 $?"   # LIBRARY target, not only modules:
                                                        # a stale root .olean breaks the audit
python3 $LM/tools/sorry_grep.py     MyLib ; echo "G2 $?"
python3 $LM/tools/axiom_audit.py    MyLib ; echo "G3 $?"
python3 $LM/tools/statement_lock.py --check MyLib/**/*.lean ; echo "G4 $?"
```

## Read the exit code, and make sure the exit code is the tool's

**Never pipe a gate into `grep`/`tail`/`head` and then read `$?`** — you get the filter's status, not the
tool's. Both audit tools return `1` on failure (`sys.exit(main())`), and this was silently discarded for a
whole session on both sides of a two-repo exchange. The live trap:

```bash
lake build NoSuchTarget 2>&1 | grep "Build completed" ; echo $?   # → 0   reads as SUCCESS
lake build NoSuchTarget      > log 2>&1              ; echo $?   # → 1   error: unknown target
```

Use `> log 2>&1; echo $?`, or `${PIPESTATUS[0]}`. A bare `lake build` with no target builds nothing and
exits 0 — always name the library.

## What each gate does and does not catch

* **G1 does not catch a `sorry`.** A `sorry` is a *warning*; the build says `Build completed successfully`
  and exits 0. That is the entire reason G2 and G3 exist — demonstrated, not assumed (LL.md §S11.9).
  The warning text uses a typographic backtick, so `grep "declaration uses 'sorry'"` finds nothing.
* **G2**: use `tools/sorry_grep.py`, not a shell grep. It strips block comments, line comments **and string
  literals** first; a naive grep returns ~20 docstring false positives and one string-literal hit, which makes
  the gate permanently red — a signal engineered to be ignored.
* **G3** fails on `sorryAx` (including when a theorem merely *depends* on a sorry) and on `Lean.ofReduceBool`
  (`native_decide`). "AUDIT ERROR" / exit 2 means it could not run (library not built) — not a proof result.
  **Its exit code is only a pass/fail signal in a repo that registers no axioms of its own:** it returns
  non-zero whenever any theorem depends on *any* non-standard axiom, including registered and disclosed ones,
  so in a repo with registered axioms it is permanently red. Ask of every gate: *can it go green in this
  repository's steady state?*
* **G4**: lock statements only after review — `statement_lock.py --update <files>`. Proof and comment changes
  do not affect it; a change to a statement or a definition body does. **Verify the update by diffing
  `docs/statement_lock.json` before and after**, not by trusting the summary line: expect ADDED only, and treat
  any CHANGED as needing a written reason at the declaration.
* **G5 producer ≠ verifier**: whoever wrote the proof does not certify it. Recompile agent output yourself.
  If no second party checked it, **say so** — write "producer = verifier for X, not externally checked", and
  name exactly what *was* externally checked and at what width. Sympy-before-Lean is one author with two tools.
  A peer's pasted transcript is a claim about a run, not the run.

## Negative-control every gate before quoting it

**A gate never seen go red is a gate you are trusting, not running.** One mutation exercises three:

```lean
-- append to a SMALL library (cheap to rebuild), then revert
theorem g3_negative_control : (0 : Nat) = 1 := by sorry
```

Expect **G1 exit 0** (build succeeds, warning only), **G2 exit 1**, **G3 exit 1** with `['sorryAx']`. For G4,
mutate one locked statement (e.g. `= 1` → `= 2`) and expect `CHANGED …` and exit 1. Revert and confirm all
return to 0. Do this *before* a release, not after.

## Reporting

Report jobs built, G2 result, `N theorems audited, M failing`, the lock result, and G5's honest status — each
with the exit code you actually read. **Never carry a repository total forward and increment it**; re-measure
all libraries and state the total as a sum of runs from this session. Keep numerator and denominator over the
same population (audited theorems ≠ parsed declarations ≠ locked declarations). If something was skipped,
say so.

**Never write "zero axioms", "100% verified" or "fully verified"** — `tools/phrasing_lint.py` enforces this.
Tier A certifies the Lean **statement**, never its physical meaning.
