# LeanMaster — instructions for Claude sessions

Lean 4 (v4.33.1) + Mathlib (v4.33.1) formalization of the mathematics around T-duality, K3 × T² lattices,
double field theory and the dual-scale bound. Skills in `.claude/skills/` load automatically:
start with `/leanmaster-onboard`.

* Verified status and the exact statements others may build on: `docs/VERIFIED_FOUNDATION.md`.
* How other projects/sessions reuse this repo: `docs/USING_LEANMASTER.md`. Lessons: `LL.md` §S2, §S2-I.
* Before claiming anything is proved: build the library target, `sorry` grep, `tools/axiom_audit.py`,
  `tools/statement_lock.py --check`; recompile subagent output yourself.
* Single-file compile: `lake env lean -DmaxHeartbeats=1000000 -DmaxRecDepth=8000 File.lean`
  (`lake env lean` ignores `lakefile.lean` options).
* Tiers in all prose: A kernel-checked / L literature (pin `papers/foundations/<file>.txt` + lines) /
  C conjecture. Never "zero axioms" or "100% verified"; the axioms are `propext`, `Classical.choice`,
  `Quot.sound`.
* Large data (`.lake`, Mathlib, clones, models, scratch projects) → `/mnt/disks/disk-socrateai-local-1/leanmaster/`.
* Book: `papers/book/` (`BOOK_BIBLE.md` is binding for chapter work; build with `papers/book/build_book.sh`).
