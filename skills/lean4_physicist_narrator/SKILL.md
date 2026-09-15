---
name: lean4-physicist-narrator
description: "Transforms raw Lean 4 formal math and string theory code into rigorous, literate theoretical physics docstrings with RAG query keys, LeanGraph metadata, and LaTeX formulas."
---

# Lean 4 Physicist Narrator & Epistemic Graph Skill

## Purpose
This skill equips Antigravity AI agents to bridge the semantic gap between Lean 4 dependent type theory and intuitive theoretical physics. It reads Lean 4 definitions, inductive types, and theorems, extracting their physical significance, and formats them according to `templates/LEAN4_PHYSICS_RAG_GRAPH_TEMPLATE.md`.

## Core Responsibilities

1. **Extract Physical Intuition:**
   - Map Lean types to physics concepts (e.g. `GenVector` -> generalized tangent bundle $\mathbb{T}M = TM \oplus T^*M$, `CourantPairing` -> canonical split-signature metric $\eta_{MN}$, `dim_A1` -> $M_{24}$ Moonshine primary representation $\mathbf{45} \oplus \overline{\mathbf{45}}$).
   - Explain *why* a theorem holds physically (e.g., absence of singularities, cosmic bounce, quantum error correction, absence of tachyons).

2. **Embed RAG & LeanGraph Metadata:**
   - Ensure every theorem docstring includes:
     - `@concept: <Concepts>`: Comma-separated domain terms for BM25 and semantic embedding.
     - `@rag_query: "<Questions>"`: 1-3 natural-language queries that a researcher would type.
     - `@graph_node: <decl_name>`: Unique identifier in LeanGraph.
     - `@graph_edge: [<dependencies>]`: Causal/deductive upstream dependencies.

3. **Adhere to the Physicist Schema:**
   - Format each theorem as:
     ```lean
     /--
     ### THEOREM: Physical Name
     **Physical Meaning:** Intuitive narrative explaining the physical mechanism.
     **Mathematical Formulation:**
     $$...$$
     **Foundational Source:** Citation and equation reference.
     **Kernel Verification:** 100% Certified (0 sorry, 0 admit)
     **RAG & Graph Indexing:**
     - `@concept: ...`
     - `@rag_query: "..."`
     - `@graph_node: ...`
     - `@graph_edge: [...]`
     -/
     ```

4. **Preserve Kernel Soundness:**
   - Never alter the theorem signatures or proof bodies (`:= by ...`) in a way that breaks Lean 4 type-checking.
   - Always verify that `lake build` exits with code 0 and 0 sorry.
