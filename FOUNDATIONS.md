# Foundational Open-Source Corpora & Mathematical Engines

This repository (`SocrateAI-Scientific-Agora-LeanMaster`) vendors **8 open-source Lean 4 corpora**
as read-only git submodules under `lean4basesource/` and cites **4 foundational physics papers**.

> **Update (2026-09-16, verified directly against `lakefile.lean`/`lake-manifest.json`, not
> carried over from prior prose): the paragraph below is now stale on its central claim.**
> Storage was relocated to a second disk this session (`.lake` symlinked to
> `/mnt/disks/disk-socrateai-local-1/leanmaster/lake`), and this project's own `lakefile.lean`
> **does now require Mathlib** (`require "leanprover-community" / "mathlib" @ git "v4.33.1"`,
> resolved to commit `0df444a360eaa60ab8c11dca51a86af692955474`; `lake-manifest.json` lists 9
> packages: `mathlib, plausible, LeanSearchClient, importGraph, proofwidgets, aesop, Qq,
> batteries, Cli`). `StringTheoryFormalization` — the library that actually imports Mathlib
> throughout (`Complex`, `Real`, `Matrix`, …) — builds 100% clean against it: 3296/3296 jobs,
> 0 errors, 0 `sorry`/`admit` (verified this session, not asserted). **This does not, by
> itself, mean the 8 vendored `lean4basesource/` corpora below are importable** — each pins its
> *own* Mathlib commit/toolchain, and at least one (`openai-navierstokes`, toolchain
> `v4.34.0-rc2`) was empirically confirmed incompatible with this project's `v4.33.1` pin
> (attempted a real `lake update` fusing both as dependencies of one package; Lake resolved an
> inconsistent (toolchain, Mathlib-commit) pair and failed at the cache-fetch step before any
> compilation — see the LeanMaster session log for 2026-09-16). The six
> `StringTheoryFoundation/*Bridge.lean` files' `SCOPE NOTE`s (thematic parallel only, no
> compiled dependency on the named external corpus) are therefore **still accurate** and
> unaffected by the Mathlib fix above — only the *reason* they don't import has changed, from
> "no Mathlib at all" to "Mathlib present, but a version-pin mismatch with this specific
> external corpus."
>
> **Original paragraph (now superseded on the Mathlib claim, kept for record):** "every one of
> the 8 vendored corpora depends on Mathlib in its own `lakefile.lean`/`lakefile.toml`. This
> project's own `lakefile.lean` has zero external dependencies (`lake-manifest.json`:
> `"packages": []`) — no Mathlib, and therefore no `import` from any of these 8 corpora is
> possible today. Adding Mathlib as a root dependency is planned but deferred to a machine with
> adequate disk space (attempted this session; blocked at 2.2 GB free on a 100%-full disk)."

---

## 1. Registry of Foundational Repositories & Submodules

| Repository | Source / Institution | What's actually in it (verified) | Submodule Path |
| :--- | :--- | :--- | :--- |
| **OpenAI Navier-Stokes & Euler** | [OpenAI Research](https://github.com/openai/NavierStokesAndEuler) | 2,659 `.lean` files under `NavierStokes/` (incl. `NavierStokes/R3`), `Euler/`, `ComparatorChallenges/` — real fractional-Sobolev/mild-PDE formalization (e.g. `NavierStokes/TorusInverse.lean`'s `torusMeasure`, `liftX`/`liftY`, Laplacian eigenvalue machinery). Requires Mathlib. | `lean4basesource/openai-navierstokes` |
| **Anthropic Fermat's Last Theorem** | [Anthropic Research](https://github.com/anthropics/fermats-last-theorem) | 29,511 files under `Theorems/`, 1,450 under `Definitions/`, plus `P2M/`. A real, complete FLT proof (Frey-Serre-Ribet-Wiles-Taylor-Wiles route, largely following Darmon-Diamond-Taylor) — `PROOF-PATH.md` documents the exact theorem-by-theorem structure (`Theorems/Thm_X_y.lean` stated, `P2M/Sol/S_X_y.lean` proved). Requires Mathlib, pinned at `db584cd6d46c92f209a44c0f1c829460d327499d` on `leanprover/lean4:v4.33.1` — the same toolchain this project uses, making it the natural first target once Mathlib is added. | `lean4basesource/anthropics-flt` |
| **Callens xFermat Kummer Lattice** | [Xavier Callens](https://github.com/xaviercallens/xfermats-last-theorem) | Confirmed byte-identical to `anthropics-flt` at the same commit (`diff -rq` on `Theorems/` returns no differences) — an unmodified mirror/fork, not an independently-extended repo. It does **not** separately contain Kummer-surface or Mukai-lattice content; that content lives in this project's own `DualScaleM24Formalization`. | `lean4basesource/xaviercallens-xflt` |
| **Meta AI ATLAS-Lean** | [Meta AI Research AutoformBot](https://github.com/facebookresearch/atlas-lean) | Autoformalized-textbook corpus; requires Mathlib. Node/declaration counts here have not been independently re-verified this session (the "2,653 formalized papers, 46,000+ declarations" figure is carried over from an earlier, unaudited pass — treat as unverified until re-checked). | `lean4basesource/atlas-lean` |
| **PhysLib** | [leanprover-community](https://github.com/leanprover-community/physlib) | Real, substantial content in `Physlib/{Relativity,SpaceAndTime,Mathematics,QuantumMechanics,Particles,QFT}/` — e.g. `Relativity/MinkowskiMatrix.lean` genuinely defines and proves properties of the Minkowski matrix $\eta=\mathrm{diag}(1,-1,-1,\dots)$ (theorems `minkowskiMatrix`, `minkowskiMatrix.dual`). **`Physlib/StringTheory/Basic.lean` is explicitly a placeholder** per its own author's docstring ("This directory is currently a place holder. Please feel free to contribute!") — there is no real string-theory content here to bridge to yet. Requires Mathlib. | `lean4basesource/physlib` |
| **TNLean (Tensor Networks)** | [LionSR](https://github.com/LionSR/TNLean) | Real Matrix-Product-States/tensor-network formalization: `TNLean/{Algebra,MPS,PEPS,QCA,Spectral,Wielandt,PiAlgebra,Tactic}.lean` plus an `MPS/` subdirectory with `FundamentalTheorem.lean`, `ParentHamiltonian.lean`, `OpenBoundary.lean`, etc. (1,229 `.lean` files total). Also carries 16 real cited arXiv papers under `Papers/` (tensor-network/quantum-information literature, e.g. `1606.00608`, `2405.00439`). Requires Mathlib **and** two further dependencies (`checkdecls`, a `Brouwer`/game-theory repo) plus `QICLean`, on toolchain `v4.34.0-rc1` (one point release ahead of this project's `v4.33.1`). | `lean4basesource/tnlean` |
| **LeanQuantum** | [inQWIRE](https://github.com/inQWIRE/LeanQuantum) | Quantum gates, unitary state evolution, quantum error-correcting codes. Requires Mathlib. Not independently re-verified this session. | `lean4basesource/lean-quantum` |
| **Lean Stat Learning Theory** | [YuanheZ](https://github.com/YuanheZ/lean-stat-learning-theory) | Rademacher complexity, PAC bounds, empirical risk minimization. Requires Mathlib. Not independently re-verified this session. | `lean4basesource/lean-stat-learning-theory` |

---

## 2. Foundational Physics Monoliths (`papers/`)

| Monolith ID | Paper Title | Authors & Citation | Mathematical Contribution to Formalization |
| :--- | :--- | :--- | :--- |
| **`Witten1995`** | *String Theory Dynamics In Various Dimensions* | Edward Witten, Nucl. Phys. B 443 (1995) 85 | S/T/U dualities, strong-weak coupling, $K3 \times T^2$ 6D/4D $N=4$ compactifications. |
| **`Vafa2005`** | *The String Landscape and the Swampland* | Cumrun Vafa, hep-th/0509212 | Swampland Distance Conjecture, infinite tower of states, modulus bounds. |
| **`StromingerSYZ1996`** | *Mirror Symmetry is T-Duality* | A. Strominger, S.-T. Yau, E. Zaslow, Nucl. Phys. B 479 (1996) 243 | Special Lagrangian fibrations, fiberwise T-duality, dual torus inversion. |
| **`MetaATLAS2025`** | *Formalizing Mathematics at Scale with AutoformBot* | Meta AI Research Team (2025) | Large-scale automated differential geometry, intersection lattices, 4-manifolds. |

---

## 3. Named After, Not Yet Linked To: `StringTheoryFoundation`'s Six "Bridge" Files

None of the six files below **import** anything from the external submodule their name and
docstring cite — confirmed by reading every `import` line in all six (none beyond this project's
own `StringTheoryFoundation.Core.Topology`, and `AtlasGeometryBridge.lean` has no `import` at all).
This was found and corrected in-file (each carries a `SCOPE NOTE` comment) earlier this session; the
descriptions below replace this document's own earlier "ingests/connects/certifies" framing, which
made the same overclaim at the document level.

1. **`StringTheoryFoundation.FluidDynamics.NavierStokesBridge`**
   - Self-contained `Nat`/`Int` arithmetic (Laplacian eigenvalues on a torus, a dissipation-monotonicity
     lemma) named after and thematically inspired by `openai-navierstokes`'s real, Mathlib-dependent
     Sobolev/PDE formalization. No import; see §1 for what the real repo actually contains.

2. **`StringTheoryFoundation.ModularForms.FermatModularBridge`**
   - Self-contained Kummer-surface/Mukai-lattice integer arithmetic (fixed-point counts, lattice rank
     and signature). Its docstring's citations to Wiles/Taylor-Wiles and the Anthropic FLT
     formalization describe the mathematical *background* the Kummer-surface construction sits in
     (K3 as $\mathrm{Km}(T^4/\mathbb{Z}_2)$), not a machine-checked connection to `anthropics-flt`'s
     actual modularity-theorem proof — the two have no code-level relationship. No import.

3. **`StringTheoryFoundation.Atlas.AtlasGeometryBridge`**
   - Self-contained integer arithmetic (K3 Betti-number Euler characteristic, intersection-form
     signature, a hyperbolic-curvature constant) named after Meta's ATLAS autoformalization project.
     No import — and this file has no `import` statement at all, not even of another file in this
     project.

4. **`StringTheoryFoundation.PhysLib.PhysLibKinematicsBridge`**
   - Self-contained integer arithmetic for a Minkowski norm and a Lorentz-signature constant,
     modeled loosely on the real `physlib` repo's genuine (Mathlib-dependent) formalization of the
     same objects — specifically `Physlib/Relativity/MinkowskiMatrix.lean`'s `minkowskiMatrix` and
     `minkowskiMatrix.dual` theorems, which actually prove the properties (symmetry, involution,
     determinant) this file's docstring only asserts by analogy. No import.

5. **`StringTheoryFoundation.Quantum.TensorNetworkBridge`**
   - Self-contained Golay-code-parameter arithmetic and a toy Ryu-Takayanagi entropy formula, named
     after `tnlean`'s real Matrix-Product-State/tensor-network formalization
     (`TNLean/MPS/FundamentalTheorem.lean` etc.) and `lean-quantum`. No import.

6. **`StringTheoryFoundation.StatisticalLearning.StatisticalLearningBridge`**
   - Self-contained PAC-bound arithmetic (empirical risk, Rademacher complexity numerator), named
     after `lean-stat-learning-theory`. No import.

**What would make these genuine bridges rather than citations:** adding Mathlib as a dependency
(Phase 1a of the plan referenced above), then actually `import`-ing the specific real declarations
named for each file above and stating theorems that reference them, rather than a same-shaped
standalone arithmetic fact next to a citation.

---

## 4. BaseLean4 Graph & Knowledge Discovery

The base graph indexes foundational papers, repositories, and declarations:
- **Base Graph JSON**: `graph/base_graph/base_leangraph.json`
- **Base Graph NDJSON**: `graph/base_graph/base_leangraph.ndjson`
- **Base Graph DOT & GEXF**: `graph/base_graph/base_leangraph.dot`, `graph/base_graph/base_leangraph.gexf`
- **Interactive Base Graph Explorer**: `graph/base_graph/index.html`

To run the BaseLean4 Graph builder:
```bash
python3 -c "from leangraph.base_graph import BaseLeanGraphBuilder; from pathlib import Path; BaseLeanGraphBuilder(Path('.')).export_all(Path('graph/base_graph'))"
```

---

## 5. Lean Cache & Optimization Tools

To ensure instant (<100ms) re-indexing and optimal compilation performance across massive codebases:

1. **Lean Cache Manager (`tools/lean_cache_manager.py`)**:
   ```bash
   # Check Lake build cache and LeanGraph SQLite metrics
   python3 tools/lean_cache_manager.py status

   # Verify Lake build cache consistency
   python3 tools/lean_cache_manager.py verify

   # Clean build cache or declaration database
   python3 tools/lean_cache_manager.py clean --target lake
   ```

2. **Cross-Corpus Base Search (`prove2me_engine/tools/query_base.py`)**:
   ```bash
   # Query across all cached foundations and papers
   python3 prove2me_engine/tools/query_base.py "Sobolev"
   python3 prove2me_engine/tools/query_base.py "Kummer"
   python3 prove2me_engine/tools/query_base.py "Laplacian" --repo repo:openai-navierstokes
   ```

---

## 6. Submodule Maintenance & Git Operations

To clone this repository with all foundational corpora fully populated:

```bash
git clone --recursive https://github.com/xaviercallens/SocrateAI-Scientific-Agora-LeanMaster.git
cd SocrateAI-Scientific-Agora-LeanMaster
git submodule update --init --recursive
```

To verify the status of all submodules:

```bash
git submodule status
```
