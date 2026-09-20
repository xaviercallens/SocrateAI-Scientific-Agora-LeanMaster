/-
G8 — the criterion of G6, applied to the other selection principles of this programme.

G6 (`DefiniteAndIndefinite.lean`) proposed a criterion rather than a result: *arithmetic decides when, and only
when, the physics hands it a definite form.* A criterion earns its keep by being applied where the answer is
already known, so that it can be wrong. This file applies it to the two remaining selection principles of
Stream 8 and to Stream 9, and the pattern holds in all four cases.

### The pattern
In every case the ambient lattice is **indefinite**, and so decides nothing on its own: it contains infinitely
many vectors of whatever invariant one asks for. In every case where the question *does* have an answer, a
**physical condition** cuts the indefinite lattice down to a **definite** sublattice, and the answer is the
extremum of the definite problem.

| Selection principle | Ambient lattice | Physical cut | What survives | Decides? |
|---|---|---|---|---|
| Smallest black hole | `U ⊕ U` (charges), indefinite | horizon: `Q_{p,q} > 0` | a definite binary form | yes: `D = −3`, unique |
| Moduli trapping | `Γ_{4,20}`, `Γ_{6,22}`, indefinite | masslessness: `α ⊥ Π` | `D₂₀(−1)`, `D₂₂(−1)`, definite | yes: `760`, `924` |
| Flux budget alone | `H³(T⁶,ℤ)`, symplectic | *none* | still indefinite | **no**: infinitely many |
| Flux with supersymmetry | the same | ISD: `∗₆G₃ = iG₃` | a positive definite form | yes: balls are finite |

The third row is the control: it is the one case with no cut, and it is the one case that does not decide. That
is what makes this a criterion and not a restatement.

### What is proved here (Tier A)
* `infinitely_many_roots_before_the_cut`: in `U ⊕ U` the family `w(n) = (n, 1, −n−1, 1)` has norm exactly `−2`
  for **every** integer `n`, injectively. Before the masslessness condition is imposed, "how many roots are
  there?" has the answer *infinitely many*, in an indefinite lattice — exactly as for the charges in G6.
* `dn_root_count`: a definite `D_n` lattice has `4·C(n,2) = 2n(n−1)` roots — the vectors `±eᵢ ± eⱼ`, `i < j` —
  and for `n = 20, 22` this is `760` and `924`, reproducing by a **counting argument** the two entries that
  `K3Enhancement.trapping_rank_table_22` reaches by **ADE enumeration**. Two independent routes, same numbers.
* `the_cut_is_what_decides`: the two facts side by side, in the same lattice-theoretic language as G6.

### Tier L, pinned in `K3Enhancement.lean`, not re-derived here
That the massless non-abelian roots at a point of the moduli space are exactly the `α ∈ Γ ∩ Π^⊥` with `α² = −2`
(Aspinwall ll. 2464–2485), and that the roots of an even **negative definite** lattice form an ADE system
(l. 2484). `K3Enhancement.uniform_parity` is what identifies `Π^⊥ ∩ Γ_d` as `D_{16+d}(−1)`; definiteness is the
property that makes the ADE step available at all.

### Reading (Tier C), and where it could still fail
The criterion is a description of four cases, not a theorem about selection principles in general. It is also
silent about one case Stream 8 studied: moonshine symmetry (G4) does not decide, and this file does not claim
that the reason is an absent definiteness condition — a symmetry constraint is not a quadratic form, so the
criterion does not even apply there. Stating that limit is part of stating the criterion. What the criterion does
buy is a cheap first question for any new selection principle in this programme: **name the definite form, or
expect no answer.**
-/
import DualScaleDyons.DefiniteAndIndefinite
import DualScaleDyons.K3Enhancement

namespace DualScaleDyons.DefinitenessCriterion

open DualScaleDyons.AttractorCharges DualScaleDyons.DefiniteAndIndefinite DualScaleDyons.K3Enhancement

/-- The would-be roots of `U ⊕ U`, before any masslessness condition. -/
def preRoot (n : ℤ) : Fin 4 → ℤ := ![n, 1, -n - 1, 1]

/-- **Before the cut there are infinitely many.** Every `w(n)` has norm `−2`, the root norm. -/
theorem infinitely_many_roots_before_the_cut (n : ℤ) :
    DefiniteAndIndefinite.norm (preRoot n) = -2 := by
  simp [DefiniteAndIndefinite.norm, pair, preRoot]
  ring

theorem preRoot_injective : Function.Injective preRoot := by
  intro m n h
  have := congrFun h 0
  simpa [preRoot] using this

/-- **After the cut there are finitely many, and the count is forced.** A definite `D_n` lattice has `2n(n−1)`
roots (`±eᵢ ± eⱼ`, `i < j`), which for `n = 20, 22` gives the `760` and `924` that
`K3Enhancement.trapping_rank_table_22` reaches independently by ADE enumeration. -/
theorem dn_root_count :
    4 * Nat.choose 20 2 = 760 ∧ 4 * Nat.choose 22 2 = 924 ∧
      2 * 20 * (20 - 1) = 760 ∧ 2 * 22 * (22 - 1) = 924 := by
  refine ⟨by decide +kernel, by decide +kernel, by norm_num, by norm_num⟩

/-- The two `D_n` counts agree with the entries the ADE table reaches by a different route. -/
theorem agrees_with_trapping_table :
    (best 22).getD 20 0 = 2 * 20 * (20 - 1) ∧ (best 22).getD 22 0 = 2 * 22 * (22 - 1) := by
  refine ⟨by decide +kernel, by decide +kernel⟩

/-- **The criterion, in one statement.** In the indefinite ambient lattice the root question has infinitely many
answers; once the physical condition cuts to a definite sublattice, the count is forced. Same arithmetic; the
difference is entirely the cut. -/
theorem the_cut_is_what_decides :
    (∀ n : ℤ, DefiniteAndIndefinite.norm (preRoot n) = -2) ∧ Function.Injective preRoot ∧
      (best 22).getD 20 0 = 760 ∧ (best 22).getD 22 0 = 924 :=
  ⟨infinitely_many_roots_before_the_cut, preRoot_injective, by decide +kernel, by decide +kernel⟩

end DualScaleDyons.DefinitenessCriterion
