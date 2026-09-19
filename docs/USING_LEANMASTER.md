# Using LeanMaster from another Claude session or project

Audience: a Claude Code session (or a person) working on a *different* project that wants to reuse
LeanMaster's verified Lean 4 mathematics, its proof-gate tools, or its proving workflow.

## 1. Load the skills
| Situation | What to do |
|---|---|
| Session started **inside** this repo | Nothing. `.claude/skills/*` load automatically; `CLAUDE.md` points to them. |
| Session in **another project, same user/machine** | Run once: `bash ~/SocrateAI-Scientific-Agora-LeanMaster/tools/install_skills.sh` (symlinks into `~/.claude/skills`). Every new session of this user then lists them. Already done on the main VM (2026-09-17). |
| **Another machine** | `git clone https://github.com/xaviercallens/SocrateAI-Scientific-Agora-LeanMaster && bash SocrateAI-Scientific-Agora-LeanMaster/tools/install_skills.sh --copy` |
| Only one project should see them | Copy `.claude/skills/<name>/` into that project's `.claude/skills/`. |

Invoke a skill by typing `/<name>`, or just describe the task — Claude loads a skill when its
description matches. Check what is loaded with `/skills`.

| Skill | Use it when |
|---|---|
| `leanmaster-onboard` | first contact with the repo; orientation, rules, reading order |
| `string-theory-foundation` | you want to import, cite or extend the verified T-duality / lattice / DFT / dual-scale / moonshine results |
| `lean-proof-gate` | before saying anything in Lean is "proved" — in any Lake project |
| `lean-tiered-proving` | you have a batch of `sorry`s to close with AI provers, cheaply and safely |
| `leanmaster-theorem-search` | before stating a new theorem: find existing ones, their dependencies and near-duplicates |

## 2. Build on the Lean libraries
`examples/consumer_demo/` is a working downstream project (tested: builds, 3709 jobs; its theorem
`two_shifts_isODD` is proved from `thetaShift_isODD` and `isODD_mul`, audited by the gate tools: standard
axioms only, statement locked). Copy it and edit:
```bash
cp -r ~/SocrateAI-Scientific-Agora-LeanMaster/examples/consumer_demo /mnt/disks/disk-socrateai-local-1/<your_project>
cd /mnt/disks/disk-socrateai-local-1/<your_project> && lake build
```
* Same machine: keep the `packagesDir` line — it reuses LeanMaster's built Mathlib (no download, no rebuild).
  Keep large build trees on the data disk, not in `$HOME`.
* Other machine: use the `require … from git … @ "v2.1.0"` form, then `lake exe cache get`.
* Toolchain must equal LeanMaster's `lean-toolchain` at the revision you require: `leanprover/lean4:v4.34.0-rc2`
  (Mathlib `v4.34.0-rc2`) from the toolchain migration on, `leanprover/lean4:v4.33.1` (Mathlib `v4.33.1`) for
  release tags up to v3.28.0 (including v2.1.0). Do not require a different Mathlib revision.
* Import what you need (`import DualScaleStream2.DFT.GeneralizedMetric`), not the whole root, to keep
  rebuilds short.

## 3. Use the tools on your own project
```bash
export LEAN_PROJECT_ROOT=/path/to/your/project
LM=~/SocrateAI-Scientific-Agora-LeanMaster
python3 $LM/tools/axiom_audit.py MyLib            # or a list of .lean files
python3 $LM/tools/statement_lock.py --update MyLib/*.lean   # after statement review
python3 $LM/tools/statement_lock.py --check  MyLib/*.lean   # before accepting proofs
python3 $LM/tools/prover_loop.py MyLib/File.lean --models deepseek-prover-v2:7b-q8_0 --rounds 3
```
`tools/lean_depgraph.lean` + `tools/theorem_atlas.py` are LeanMaster-specific (library names are listed
at the top of each file); copy and edit the `ownRoots` / `LIBS` lists to analyse another project.

## 4. What you may claim
Read `docs/VERIFIED_FOUNDATION.md`. In one paragraph: 425 theorems, no `sorry`, only Lean's three standard
axioms, statements locked, downstream use tested. That certifies *mathematical statements*. It does not
certify that those statements are physics; keep the tiers (A kernel / L literature / C conjecture) in
anything you write on top of it, and re-run the five confirmation commands rather than trusting a number
in a document.

## 5. Working agreements for sessions that modify LeanMaster itself
* Work on a branch if another session may be active (`git status`, `git branch -vv` first); never edit
  `papers/publication/*` or compile there while another agent is — pdfLaTeX truncates PDFs on failure.
* New theorems enter through the pipeline of `lean-tiered-proving` and leave through `lean-proof-gate`;
  then refresh the index (`leanmaster-theorem-search`) and update `docs/VERIFIED_FOUNDATION.md` numbers.
* Record lessons in `LL.md`; commit + push per milestone.
