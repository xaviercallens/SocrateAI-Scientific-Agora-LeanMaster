---
name: leanmaster-onboard
description: Start here when a task involves the LeanMaster repository (SocrateAI-Scientific-Agora-LeanMaster) or when another project wants to reuse its Lean 4 string-theory / lattice / T-duality theorems, its proof-gate tools, or its proving workflow. Explains where things are, what is verified, how to depend on it, and which other leanmaster skills to load.
---

# LeanMaster: orientation for a new Claude session

**Repo**: `xaviercallens/SocrateAI-Scientific-Agora-LeanMaster` — on the main VM at
`~/SocrateAI-Scientific-Agora-LeanMaster` (symlink to the data disk). Lean `v4.34.0-rc2`, Mathlib `v4.34.0-rc2`
(release tags up to v3.28.0: v4.33.1).
It is NOT "Stream 1" of the K3 DarkMatter programme and its internal "Stream 2" is not that
programme's Stream 2; do not mix ledgers.

## Read in this order (10 minutes)
1. `LL.md` **§S11** — read the header and its four rules before touching anything. Nine defects were found in
   one day **with every gate green**; they are the failure modes this repo actually has.
2. `docs/VERIFIED_FOUNDATION.md` — what is kernel-verified, at which commit, and how it was checked.
3. `docs/USING_LEANMASTER.md` — how to build on it from another project or session.
4. `LL.md` §S10 and §S2/§S2-I — agents misreport compiles; `lake env lean` ignores lakefile options;
   a "next formalization target" sentence is an unverified claim.
5. `docs/STREAM2_WORKFLOW.md` — the tiered proof pipeline.

## Libraries
| Library | Mathlib? | Content | Depth |
|---|---|---|---|
| `DualScaleStream2` | yes | lattices (E8, U, K3, Mukai), O(d,d;ℤ), generalized metric, section condition, `tr G + tr G⁻¹ ≥ 2d`, tadpole, EOT moonshine | real linear algebra over ℤ/ℝ |
| `StringTheoryFormalization` | yes | T-duality mass spectrum, Narain lattice, critical dimension, K3 signature, M24 tower, F-term potential, etc. | mixed |
| `DoubleFieldTheory`, `StringTheoryFoundation`, `DualScaleM24Formalization`, `DualScaleValidation`, `Lean5Corpus` | no | integer/rational models of physical statements ("arithmetic shadows") | shallow by design |

## Rules that are not optional
* Epistemic tiers: **A** kernel-checked (name the declaration), **L** literature (pin file + line in
  `papers/foundations/*.txt`), **C** conjecture. Identifying a Lean object with physics is never Tier A.
* Never write "zero axioms" / "100% verified" / "fully verified". The correct statement: depends only on
  `propext`, `Classical.choice`, `Quot.sound`. Enforced by `tools/phrasing_lint.py`, not by good intentions —
  39 violations survived in docstrings for months because the ban was a convention and never a check.
* **Read a gate's exit code, and make sure it is the gate's.** Piping into `grep`/`tail` gives you the
  filter's status: `lake build NoSuchTarget 2>&1 | grep "Build completed"; echo $?` → **0**.
* **A `sorry` does not fail the build** — it is a warning and `lake build` exits 0. That is why G2 and G3 exist.
* **Disclose in place.** A declaration that claims more than it proves gets a `Disclosure` note in **its own
  docstring**, statement unchanged and nothing deleted. A critique living only in the book or a README is an
  unlanded fix, and retrieval answers from the docstring, never from the chapter.
* **Never rewrite a published artifact to hide an error in it** — not a released tag, not a Zenodo paper.
  Append the correction beside it.
* Large data (Mathlib, `.lake`, clones, models) lives on `/mnt/disks/disk-socrateai-local-1/leanmaster/`.
* Single-file compiles: `lake env lean -DmaxHeartbeats=1000000 -DmaxRecDepth=8000 File.lean`.
* `rm -rf` is denied by this user's permission settings; move things aside instead.

## Tools (`tools/`, all take `--self-test` — run it first; an empty report is not a clean bill)
Gates: `axiom_audit.py`, `statement_lock.py`, `sorry_grep.py` (G2 — comment- and string-literal-aware).
Claim audits: `name_vs_statement.py`, `disclosure_reaches_source.py`, `book_vs_source.py`, `phrasing_lint.py`.

## Other skills
`lean-proof-gate` (verify any Lean project — **load before claiming anything is proved**) ·
`claim-audit` (does a declaration prove what its name says; did a critique reach the code; writing checkers
without fooling yourself) · `string-theory-foundation` (what you can import and cite) ·
`lean-tiered-proving` (get new theorems proved cheaply and safely) ·
`leanmaster-theorem-search` (find an existing theorem before proving a new one).

## If a sibling-repo session is live on this VM
Trade **audit questions**, not results — that mechanism produced every finding of `LL.md` §S11, and neither
session audited itself unprompted. Coordinate builds: two Lean processes here contend for **page cache**, not
CPU, and a full-library `lake env lean` can hold the Lake lock for ~10 minutes.
