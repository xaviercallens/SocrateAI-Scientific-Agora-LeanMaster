---
name: leanmaster-onboard
description: Start here when a task involves the LeanMaster repository (SocrateAI-Scientific-Agora-LeanMaster) or when another project wants to reuse its Lean 4 string-theory / lattice / T-duality theorems, its proof-gate tools, or its proving workflow. Explains where things are, what is verified, how to depend on it, and which other leanmaster skills to load.
---

# LeanMaster: orientation for a new Claude session

**Repo**: `xaviercallens/SocrateAI-Scientific-Agora-LeanMaster` — on the main VM at
`~/SocrateAI-Scientific-Agora-LeanMaster` (symlink to the data disk). Lean `v4.33.1`, Mathlib `v4.33.1`.
It is NOT "Stream 1" of the K3 DarkMatter programme and its internal "Stream 2" is not that
programme's Stream 2; do not mix ledgers.

## Read in this order (10 minutes)
1. `docs/VERIFIED_FOUNDATION.md` — what is kernel-verified, at which commit, and how it was checked.
2. `docs/USING_LEANMASTER.md` — how to build on it from another project or session.
3. `LL.md` §S2 and §S2-I — lessons that change how you should work (agents misreport compiles;
   `lake env lean` ignores lakefile options; audit axioms; lock statements).
4. `docs/STREAM2_WORKFLOW.md` — the tiered proof pipeline.

## Libraries
| Library | Mathlib? | Content | Depth |
|---|---|---|---|
| `DualScaleStream2` | yes | lattices (E8, U, K3, Mukai), O(d,d;ℤ), generalized metric, section condition, `tr G + tr G⁻¹ ≥ 2d`, tadpole, EOT moonshine | real linear algebra over ℤ/ℝ |
| `StringTheoryFormalization` | yes | T-duality mass spectrum, Narain lattice, critical dimension, K3 signature, M24 tower, F-term potential, etc. | mixed |
| `DoubleFieldTheory`, `StringTheoryFoundation`, `DualScaleM24Formalization`, `DualScaleValidation`, `Lean5Corpus` | no | integer/rational models of physical statements ("arithmetic shadows") | shallow by design |

## Rules that are not optional
* Epistemic tiers: **A** kernel-checked (name the declaration), **L** literature (pin file + line in
  `papers/foundations/*.txt`), **C** conjecture. Identifying a Lean object with physics is never Tier A.
* Never write "zero axioms" / "100% verified". The correct statement: depends only on `propext`,
  `Classical.choice`, `Quot.sound`.
* Large data (Mathlib, `.lake`, clones, models) lives on `/mnt/disks/disk-socrateai-local-1/leanmaster/`.
* Single-file compiles: `lake env lean -DmaxHeartbeats=1000000 -DmaxRecDepth=8000 File.lean`.
* `rm -rf` is denied by this user's permission settings; move things aside instead.

## Other skills
`string-theory-foundation` (what you can import and cite) · `lean-proof-gate` (verify any Lean
project) · `lean-tiered-proving` (how to get new theorems proved cheaply and safely) ·
`leanmaster-theorem-search` (find an existing theorem before proving a new one).
