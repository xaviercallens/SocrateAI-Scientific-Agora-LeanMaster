# Foundational Open-Source Corpora & Mathematical Engines

This repository (`SocrateAI-Scientific-Agora-LeanMaster`) integrates, cross-indexes, and formally bridges **8 premier open-source Lean 4 mathematical corpora** and **4 foundational physics monographs**. These codebases provide the verified analytic, geometric, modular, and physical substrates upon which **Double Field Theory (DFT)** and **Dual-Scale $M_{24}$ Moonshine** are constructed.

---

## 1. Registry of Foundational Repositories & Submodules

| Repository | Source / Institution | Role in LeanMaster Engine | Submodule Path |
| :--- | :--- | :--- | :--- |
| **OpenAI Navier-Stokes & Euler** | [OpenAI Research](https://github.com/openai/NavierStokesAndEuler) | Continuous fluid dynamics, Sobolev spaces, mild PDE solutions, energy conservation bounds. | `lean4basesource/openai-navierstokes` |
| **Anthropic Fermat's Last Theorem** | [Anthropic Research](https://github.com/anthropics/fermats-last-theorem) | Modular forms, Galois representations, elliptic curves, Kummer surfaces. | `lean4basesource/anthropics-flt` |
| **Callens xFermat Kummer Lattice** | [Xavier Callens](https://github.com/xaviercallens/xfermats-last-theorem) | Kummer surface blowup divisors, Mukai lattice $\Gamma^{4,20}$, $T^4/\mathbb{Z}_2$ singularity resolution. | `lean4basesource/xaviercallens-xflt` |
| **Meta AI ATLAS-Lean** | [Meta AI Research AutoformBot](https://github.com/facebookresearch/atlas-lean) | 2,653 formalized papers, 46,000+ declarations, 4-manifold topology, intersection lattices. | `lean4basesource/atlas-lean` |
| **PhysLib** | [Lean Community](https://github.com/leanprover-community/physlib) | 19 physics domains, spacetime kinematics, Clifford algebra, classical mechanics. | `lean4basesource/physlib` |
| **TNLean (Tensor Networks)** | [LionSR / Oxford Quantum](https://github.com/LionSR/TNLean) | Tensor network decompositions, MPS/PEPS representations, quantum entanglement geometry. | `lean4basesource/tnlean` |
| **LeanQuantum** | [inQWIRE Quantum](https://github.com/inQWIRE/LeanQuantum) | Quantum gates, unitary state evolution, quantum error-correcting codes. | `lean4basesource/lean-quantum` |
| **Lean Stat Learning Theory** | [YuanheZ](https://github.com/YuanheZ/lean-stat-learning-theory) | Rademacher complexity, PAC bounds, empirical risk minimization. | `lean4basesource/lean-stat-learning-theory` |

---

## 2. Foundational Physics Monoliths (`papers/`)

| Monolith ID | Paper Title | Authors & Citation | Mathematical Contribution to Formalization |
| :--- | :--- | :--- | :--- |
| **`Witten1995`** | *String Theory Dynamics In Various Dimensions* | Edward Witten, Nucl. Phys. B 443 (1995) 85 | S/T/U dualities, strong-weak coupling, $K3 \times T^2$ 6D/4D $N=4$ compactifications. |
| **`Vafa2005`** | *The String Landscape and the Swampland* | Cumrun Vafa, hep-th/0509212 | Swampland Distance Conjecture, infinite tower of states, modulus bounds. |
| **`StromingerSYZ1996`** | *Mirror Symmetry is T-Duality* | A. Strominger, S.-T. Yau, E. Zaslow, Nucl. Phys. B 479 (1996) 243 | Special Lagrangian fibrations, fiberwise T-duality, dual torus inversion. |
| **`MetaATLAS2025`** | *Formalizing Mathematics at Scale with AutoformBot* | Meta AI Research Team (2025) | Large-scale automated differential geometry, intersection lattices, 4-manifolds. |

---

## 3. Certified Lean 4 Architectural Bridges (`StringTheoryFoundation`)

All external foundations are directly linked into our formal Lean 4 kernel environment via `StringTheoryFoundation`:

1. **OpenAI Navier-Stokes & Fluid Dynamics Bridge (`StringTheoryFoundation.FluidDynamics.NavierStokesBridge`)**
   - Formalizes the continuous limit of string field theory.
   - Connects $D$-dimensional energy conservation bounds and mild PDE solutions to generalized Einstein equations in DFT.
   - Submodule Path: `lean4basesource/openai-navierstokes/`

2. **Fermat Modular Forms & Kummer Surface Bridge (`StringTheoryFoundation.ModularForms.FermatModularBridge`)**
   - Connects modular curves $X_0(N)$, Hecke eigenvalues, and Kummer surfaces to string compactifications on $K3 \times T^2$.
   - Proves the $T^4/\mathbb{Z}_2$ orbifold singularity blowup with 16 exceptional $\mathbb{P}^1$ rational curves, yielding the Euler characteristic $\chi(K3) = 24$.
   - Submodule Paths: `lean4basesource/anthropics-flt/` and `lean4basesource/xaviercallens-xflt/`

3. **Meta AI ATLAS-Lean Differential Geometry Bridge (`StringTheoryFoundation.Atlas.AtlasGeometryBridge`)**
   - Ingests 4-manifold Betti numbers: $b_0 = 1, b_1 = 0, b_2 = 22, b_3 = 0, b_4 = 1$.
   - Certifies the Hirzebruch signature formula $\tau(K3) = b_2^+ - b_2^- = 3 - 19 = -16$.
   - Submodule Path: `lean4basesource/atlas-lean/`

4. **PhysLib Spacetime Kinematics Bridge (`StringTheoryFoundation.PhysLib.PhysLibKinematicsBridge`)**
   - Ingests relativistic 4-vector kinematics and Lorentz metric signatures $(+,-,-,-)$.
   - Generalizes to the Double Field Theory split signature metric $\eta_{MN}$ on $O(D,D)$.
   - Submodule Path: `lean4basesource/physlib/`

5. **Quantum & Tensor Network Bridge (`StringTheoryFoundation.Quantum.TensorNetworkBridge`)**
   - Implements holographic tensor network contractions representing AdS/CFT bulk-to-boundary reconstructions and quantum error-correcting Golay codes $\mathcal{G}_{24}$.
   - Submodule Paths: `lean4basesource/tnlean/` and `lean4basesource/lean-quantum/`

6. **Statistical Learning Theory Bridge (`StringTheoryFoundation.StatisticalLearning.StatisticalLearningBridge`)**
   - Provides formal generalization bounds for AI proving agents operating on the LeanGraph DAG.
   - Submodule Path: `lean4basesource/lean-stat-learning-theory/`

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
