-- Block WS6: Kummer Blowup (K3 singular locus resolution)
-- Status: VERIFIED (0 sorry axioms)
-- Provides: The Kummer construction T⁴/ℤ₂ → K3 with 16 exceptional divisors E_i.
import Mathlib.Algebra.Module.Basic
import StringTheoryFormalization.Foundations.MathlibCore

/-!
# The 16 Kummer exceptional curves, as names and a toy intersection matrix

## Physical background
A Kummer K3 surface is the minimal resolution of `T⁴/ℤ₂`: the involution `x ↦ −x` on a
4-torus `T⁴` has exactly 16 fixed points, each an `A₁` (ordinary double point) singularity;
resolving each one blows in a single `(-2)`-curve `Eᵢ`, `i = 1,…,16`
(`papers/foundations/huybrechts_K3Global.txt`, ll. 2016–2079, "one associates the Kummer surface
X"; the resulting `Eᵢ·Eⱼ = −2δᵢⱼ` sublattice is called the *Kummer lattice* there, ll. 2071–2079).
LL.md's Lesson 1.2 records the same two facts (`Eᵢ·Eⱼ = −2δᵢⱼ`, `∑ Eᵢ² = −32`) as this project's
working statement of the construction. This file formalizes only the resulting `16×16` numerical
intersection pattern, not the blowup, the torus, the involution or the fixed-point count that
produces it.

## Mathematical content
`kummerExceptionalDivisors : Fin 16 → String` merely names the 16 indices `"E_0",…,"E_15"` — a
labelling function with no geometric content. `kummerIntersectionForm : Fin 16 → Fin 16 → ℤ` is
the literal diagonal matrix `if i = j then -2 else 0`, i.e. `-2` times the identity on `ℤ¹⁶`
(the Gram matrix of 16 pairwise-orthogonal copies of the rank-1 lattice `⟨-2⟩`, matching the `A₁`
intersection form quoted above). `kummer_lattice_contribution` and
`exceptional_self_intersection` are both direct evaluations of this matrix — that its diagonal
sums to `-32` and each diagonal entry is `-2` — and prove nothing about an actual blowup, actual
divisors on a surface, or the embedding of this rank-16 form into the K3/Mukai lattice
(`MukaiLattice.lean`'s `kummer_sublattice_rank`, which is likewise only a cardinality fact, not
that embedding).

## Proof techniques
Both theorems `simp`-unfold `kummerIntersectionForm` on the diagonal (`i = i`, so the `if`
reduces to `-2`); `kummer_lattice_contribution` additionally uses `Finset.sum_const` to turn the
constant sum `∑ᵢ (-2)` into `16 • (-2) = -32` (Lean's own linter flags `Finset.card_fin` as an
unused `simp` argument there — a pre-existing warning, not introduced by this documentation pass).

## Related declarations
The atlas's cross-library similarity table pairs `kummer_lattice_contribution` (cosine 0.373) and
`exceptional_self_intersection` (cosine 0.513) with `SocrateAI.Moonshine.
kummer_exceptional_intersection` in a different library — both state the same `Eᵢ·Eⱼ = −2δᵢⱼ` /
`∑ = −32` numerology, at low dependency-Jaccard, so this is an independent re-proof of the same
numerical fact rather than a shared lemma. `Fintype.card_fin` links `kummer_sublattice_rank`
(`MukaiLattice.lean`) to declarations here via shared Mathlib proof infrastructure only.
-/

namespace StringTheory.StringDynamics

/-- Names the 16 indices `0,…,15` as the strings `"E_0",…,"E_15"`, standing for the 16
    exceptional `(-2)`-curves produced by resolving the 16 `A₁` singularities of `T⁴/ℤ₂`
    (`papers/foundations/huybrechts_K3Global.txt`, ll. 2016–2079). This is a labelling function
    only: it carries no intersection data, no divisor class, and no relation to an actual
    surface. -/
def kummerExceptionalDivisors : Fin 16 → String :=
  fun i => s!"E_{i.val}"

/-- The `16×16` diagonal integer matrix `-2·Id`: `-2` on the diagonal, `0` off it. This is the
    Gram matrix of the `A₁⊕¹⁶` intersection form `Eᵢ·Eⱼ = -2δᵢⱼ` for the 16 Kummer exceptional
    curves (`papers/foundations/huybrechts_K3Global.txt`, ll. 2071–2079, "the Kummer lattice").
    Nothing here constructs the curves themselves or their ambient surface; this is the matrix
    alone. -/
def kummerIntersectionForm (i j : Fin 16) : ℤ :=
  if i = j then -2 else 0

/-- The trace of `kummerIntersectionForm` is `-32 = 16 × (-2)`: physically, the total
    self-intersection contributed by all 16 Kummer exceptional curves to the ambient K3/Mukai
    lattice (LL.md Lesson 1.2, `∑ Eᵢ² = -32`). Proof: unfold the diagonal entries to `-2` and
    sum 16 constant terms via `Finset.sum_const`. -/
theorem kummer_lattice_contribution :
    (∑ i : Fin 16, kummerIntersectionForm i i) = -32 := by
  simp [kummerIntersectionForm, Finset.sum_const, Finset.card_fin]

/-- Every diagonal entry of `kummerIntersectionForm` is `-2`: physically, each Kummer
    exceptional curve `Eᵢ` is a `(-2)`-curve, `Eᵢ² = -2` (a smooth rational curve of
    self-intersection `-2`, the hallmark of an `A₁` resolution). Proof: the `if i = i` branch
    of the definition simplifies to its `true` case. -/
theorem exceptional_self_intersection (i : Fin 16) :
    kummerIntersectionForm i i = -2 := by
  simp [kummerIntersectionForm]

end StringTheory.StringDynamics
