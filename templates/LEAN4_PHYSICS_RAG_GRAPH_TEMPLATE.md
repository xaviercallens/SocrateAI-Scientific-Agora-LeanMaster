# Lean 4 Physicist & RAG-Graph Documentation Template
## Gold Standard for Mathematical Physics & Epistemic Certification

This template defines the exact formatting and metadata schema required for all Lean 4 formalizations in the **SocrateAI Scientific Agora**. It guarantees that code is simultaneously:
1. **Instantly readable for theoretical physicists** (translating dependent type theory into physical fields, symmetries, and action principles).
2. **Semantically indexable for RAG Oracles** (enabling natural-language queries via `@concept` and `@rag_query`).
3. **Structurally trackable for LeanGraph** (enabling automated DAG dependency mapping via `@graph_node` and `@graph_edge`).
4. **Kernel Sound** (100% verified with 0 `sorry` and 0 `admit`).

---

### 1. File / Module Header Schema

```lean
/-
Copyright (c) 2026 SocrateAI Scientific Agora. All rights reserved.
Released under Apache 2.0 license.
Authors: Xavier Callens, SocrateAI Agora Team
-/

import DoubleFieldTheory.GeneralizedGeometry
import DoubleFieldTheory.CourantAlgebroid

/-!
# <Module Title>: <Physical Concept & Mathematical Framework>

**Module:** `<Namespace.Module>`  
**Foundational Sources:**
- Author, A. *Paper Title*, Journal Volume (Year) Page [`arXiv:XXXX.XXXXX`](https://arxiv.org/abs/XXXX.XXXXX).
- Callens, X. *Epistemic Ledger of Dual-Scale String Theory*, SocrateAI Research (2026).

### Physical & Mathematical Narrative
<2-4 paragraphs explaining:
 1. The physical motivation (e.g. why standard general relativity breaks down, the role of T-duality, moduli stabilization).
 2. The mathematical objects in standard physics notation (metrics, brackets, curvature, superpotentials).
 3. The exact resolution of the problem (bounce, Diophantine lock, singularity elimination).>

### Theoretical Physics Impact
- **Symmetry / Invariance:** <e.g., O(D,D; Z) discrete covariance, non-perturbative dilaton invariance>
- **Singularity Resolution:** <e.g., Minimum length scale ell_s = sqrt(alpha') forbidding curvature blow-up>
- **Observable Prediction:** <e.g., Tensor-to-scalar ratio r = 0.00396, Dirac CP phase delta_CP = 282.4 deg>

### Epistemic Metadata & RAG Indexing
- `@concept: <Concept1>, <Concept2>, <Concept3>`
- `@rag_query: "<Natural language question 1>", "<Natural language question 2>"`
- `@graph_cluster: "<ClusterName>"`
- `@impact: <KeyScientificBreakthrough>`
- `@kernel_status: 100% Certified (0 sorry, 0 admit)`
-/
```

---

### 2. Theorem & Lemma Declaration Schema

```lean
/--
### THEOREM: <Physical Intuitive Title>
**Physical Meaning:** <Detailed, intuitive explanation for theoretical physicists.
Explain what physical phenomenon is demonstrated, why it matters, how it interacts with
quantum gravity, supersymmetry, or cosmological observables, and why it is not an artifact
of coordinate choices.>

**Mathematical Formulation:**
$$<LaTeX equation showing the physical law or identity>$$
where $<Symbol_1>$ is ..., and $<Symbol_2>$ is ...

**Foundational Source:** <Paper reference and equation number>
**Kernel Verification:** 100% Certified (0 sorry, 0 admit)

**RAG & Graph Indexing:**
- `@concept: <SpecificConcept1>, <SpecificConcept2>`
- `@rag_query: "<How a physicist would search for this theorem>"`
- `@graph_node: <decl_name>`
- `@graph_edge: [<upstream_dependency_1>, <upstream_dependency_2>]`
-/
theorem <decl_name> (<parameters>) :
    <type_signature> := by
  <proof>
```

---

### 3. Structure & Definition Schema

```lean
/--
### DEFINITION: <Physical Field / Manifold / State>
**Physical Interpretation:** <What physical degree of freedom or background geometry
is represented by this type/structure (e.g., momentum and winding modes, generalized metric,
BPS charge lattice).>

**Physical Units & Constraints:**
- Spacetime units: $\ell_s = \sqrt{\alpha'} = 1$.
- Constraints: coset condition $\mathcal{H}^T \eta \mathcal{H} = \eta$.

**RAG & Graph Indexing:**
- `@concept: <Concept>`
- `@rag_query: "<Natural search query>"`
- `@graph_node: <type_name>`
-/
structure <type_name> where
  <fields>
```

---

### 4. Verification Invariants
1. Every file must compile cleanly via `lake build`.
2. Strict `0 sorry` and `0 admit` across all declarations.
3. Every theorem must have a clear `**Physical Meaning:**` section that theoretical physicists can read without needing to know Lean tactics (`simp`, `rw`, `omega`).
