/-
Block WS19: TDA Mapper — definitions only, and a correction.

**Correction (2026-09-20).** This file previously carried a theorem named `mapper_nerve_theorem` with the
docstring "The Mapper construction preserves connected components in the limit of fine covers (nerve theorem
analog)" and the statement `∀ (G : MapperGraph), G.nodes.card ≥ 0`, proved by `Nat.zero_le`. That statement is
**vacuous**: it holds of every `Finset` whatever, and it does not prove — does not even mention — the claim in
its docstring. The file header read "Status: VERIFIED (0 sorry axioms)" and a scorecard recorded the block at
100%. Both were true and both were beside the point: the gates check which axioms a proof *depends on*, never
whether the statement is worth proving or whether the docstring matches it.

This is the second instance in this repository of the same blind spot (the first: the `φ(n) ≤ d` claim refuted in
`DualScaleStream2/Orientifold/CrystallographicOrders.lean`, `LL.md` §S10.1). The pattern worth recording: an
automated verification apparatus certifies *dependencies*, so it is structurally blind to a vacuous statement and
to prose that overclaims what a statement says. Both must be caught by reading.

### What this file now provides
Definitions for a Mapper construction (`OpenCover`, `MapperNode`, `MapperGraph`) and **one theorem that is
actually about the structure it names** (`mapper_edge_bound`). The nerve theorem is **not** proved here, and no
statement in this file should be read as evidence for it. A real Mapper formalization needs the pull-back cover,
a clustering functor, the nerve of the cover and a comparison map; none of that is here.

### Tier
Tier A for `mapper_edge_bound` (kernel-checked, and non-vacuous: its bound is attained). The nerve theorem is
Tier L — standard in the TDA literature, cited nowhere in this repository because nothing here depends on it.
-/
import Mathlib.Topology.Basic
import Mathlib.Topology.Covering.Basic
import StringTheoryFormalization.Foundations.MathlibCore

namespace StringTheory.StringDynamics

/-- A cover of a topological space by open sets. -/
structure OpenCover (X : Type*) [TopologicalSpace X] where
  index : Type*
  sets : index → Set X
  isOpen : ∀ i, IsOpen (sets i)
  covers : ∀ x : X, ∃ i, x ∈ sets i

/-- A Mapper graph node: cluster of points in a pull-back cover element. -/
structure MapperNode where
  coverIndex : ℕ
  clusterIndex : ℕ
  deriving DecidableEq

/-- A Mapper graph: nodes connected when clusters share points. -/
structure MapperGraph where
  nodes : Finset MapperNode
  edges : Finset (MapperNode × MapperNode)
  /-- Edges join nodes of the graph. -/
  edges_mem : ∀ e ∈ edges, e.1 ∈ nodes ∧ e.2 ∈ nodes

/-- **The edge count of a Mapper graph is bounded by the square of its node count.**
Non-vacuous, and the bound is attained by the complete graph with all loops. Stated because it is what the
`edges_mem` field actually gives; it is *not* a nerve theorem and must not be cited as one. -/
theorem mapper_edge_bound (G : MapperGraph) : G.edges.card ≤ G.nodes.card * G.nodes.card := by
  have hsub : G.edges ⊆ G.nodes ×ˢ G.nodes := by
    intro e he
    exact Finset.mem_product.mpr (G.edges_mem e he)
  calc G.edges.card ≤ (G.nodes ×ˢ G.nodes).card := Finset.card_le_card hsub
    _ = G.nodes.card * G.nodes.card := Finset.card_product _ _

/-- The number of **nodes** of the Mapper graph. Deliberately *not* called `mapperComponents`: the previous
version of this file returned exactly this number under that name, which is wrong — the node count is not the
number of connected components. Counting components needs a union-find over `edges`, which is not implemented
here. -/
def mapperNodeCount (G : MapperGraph) : ℕ := G.nodes.card

end StringTheory.StringDynamics
