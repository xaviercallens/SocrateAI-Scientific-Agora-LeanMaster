/-
Stream 9 · S9.5b — the `ℤ₂ × ℤ₂`-invariant part of `H³(T⁶, ℤ)`: rank 8, symplectic, and still unbounded by the
tadpole.

S9.5 showed that the tadpole bounds the integer `½N_flux` and never the flux quanta, working in the full
`H³(T⁶, ℤ)` of rank 20. The obvious objection is that an orbifold/orientifold keeps only the invariant fluxes, so
maybe the projection is what restores finiteness. It does not, and this file says exactly why: the invariant part
is itself a unimodular symplectic lattice, of rank 8, in which the same infinite family lives.

### The invariant sublattice
`T⁶` is three 2-tori: `{x₁, x₂}`, `{x₃, x₄}`, `{x₅, x₆}`. The `ℤ₂ × ℤ₂` of `NarainT6.lean` acts by `θ₁ = −1` on
`x₁ … x₄` and `θ₂ = −1` on `x₃ … x₆`. A basis 3-form `dx_S` picks up `(−1)^{|S ∩ A|}` under `θ₁` and
`(−1)^{|S ∩ B|}` under `θ₂`, with `A = {1,2,3,4}`, `B = {3,4,5,6}`.

### What is proved (Tier A)
* `invariant_triples_eq`, `invariant_mem_iff`: among the `20` index triples, those invariant under both signs
  are **exactly** the `8` with one index from each 2-torus — `{1,2} × {3,4} × {5,6}`.
* `invariant_rank`: `8 = 2³`, against `20 = C(6,3)` for the full `H³`.
* `invariant_closed_under_complement`: the complement of an invariant triple is invariant, which is what allows
  the wedge pairing to restrict to a perfect pairing.
* `symJ8_is_wedge`: **the `8 × 8` matrix below is not an assertion.** All `64` entries — the zeros included — are
  checked against `wedgeSign`, which is the definition of the pairing (`0` when an index repeats, otherwise the
  signature of the permutation `S ++ T` of `1 … 6`).
* `restricted_antisymm`, `restricted_sq`, `restricted_unimodular`: the restricted pairing `J₈` satisfies
  `J₈ᵀ = −J₈`, `J₈ · J₈ = −1`, hence is unimodular: the invariant sublattice is a symplectic unimodular lattice
  of rank 8.
* `invariant_flux_family`, `invariant_family_injective`: inside the invariant sublattice, for every `k` the family
  `F(m) = k·(second basis vector) + m·(third)` has pairing `k` with the first basis vector, for every `m`, and is
  injective in `m`.

### Reading
The orbifold projection cuts `20` down to `8` — a real reduction — but what remains is again a unimodular
symplectic lattice, so the argument of S9.5 applies verbatim inside it: **the tadpole bounds an integer, not a
set of fluxes, before or after projection.** Finiteness has to come from the supersymmetry conditions and the
duality quotient. Not modelled here: the orientifold projection on top of the orbifold, the quantisation
conditions (whether the invariant fluxes are integral or half-integral in a given convention), and the
`D3`-charge normalisation. Those are the next Tier L inputs.
-/
import DualScaleStream2.Flux.FluxLattice

namespace DualScaleStream2.Flux.InvariantH3

open Matrix DualScaleStream2.Lattice

/-- The `20` index triples of `H³(T⁶, ℤ)`, as sorted lists. -/
def triples : List (List ℕ) :=
  ((List.range 6).map (· + 1)).sublists.filter fun s => s.length == 3

/-- `θ₁` flips `x₁ … x₄`, `θ₂` flips `x₃ … x₆`; a triple is invariant iff both intersections are even. -/
def isInvariant (s : List ℕ) : Bool :=
  ((s.filter fun i => i ≤ 4).length % 2 == 0) && ((s.filter fun i => 3 ≤ i).length % 2 == 0)

/-- The eight invariant triples: one index from each 2-torus. -/
def invTriples : List (List ℕ) :=
  [[1, 3, 5], [1, 3, 6], [1, 4, 5], [1, 4, 6], [2, 3, 5], [2, 3, 6], [2, 4, 5], [2, 4, 6]]

/-- **The invariant part is exactly the eight "one index per torus" triples.** (`List.sublists` enumerates in
its own order, so the equality is up to permutation; the sorted order of `invTriples` is the one the pairing
matrix `symJ8` below is written in.) -/
theorem invariant_triples_eq : (triples.filter isInvariant).Perm invTriples := by decide +kernel

/-- The same statement as a membership criterion, order-free: a triple is invariant iff it is one of the eight. -/
theorem invariant_mem_iff (s : List ℕ) (hs : s ∈ triples) : isInvariant s = true ↔ s ∈ invTriples := by
  revert hs; revert s; decide +kernel

/-- Rank `8 = 2³` out of `20 = C(6,3)`. -/
theorem invariant_rank : invTriples.length = 8 ∧ 2 ^ 3 = 8 ∧ triples.length = 20 := by decide +kernel

/-- The complement of an invariant triple is invariant: the pairing can restrict. -/
theorem invariant_closed_under_complement :
    invTriples.all (fun s => invTriples.contains (((List.range 6).map (· + 1)).filter fun i => !s.contains i))
      = true := by decide +kernel

/-- Inversion count of a list: the length of the permutation, when the list is a permutation. -/
def inversions : List ℕ → ℕ
  | [] => 0
  | a :: l => (l.filter (fun b => b < a)).length + inversions l

/-- The wedge pairing sign of two index sets: `dx_S ∧ dx_T` is `0` unless `S ++ T` is a permutation of `1 … 6`
(a repeated index kills the wedge), and otherwise it is `sgn(S ++ T)` times the volume form. -/
def wedgeSign (S T : List ℕ) : ℤ :=
  let u := S ++ T
  if (u.length == 6) && (((List.range 6).map (· + 1)).all fun i => u.count i == 1) then
    (if inversions u % 2 == 0 then 1 else -1)
  else 0

/-- The restricted wedge pairing on the eight invariant classes, signs from the permutation `(S, Sᶜ)`. -/
def symJ8 : Gram 8 :=
  !![0, 0, 0, 0, 0, 0, 0, -1;
      0, 0, 0, 0, 0, 0, 1, 0;
      0, 0, 0, 0, 0, 1, 0, 0;
      0, 0, 0, 0, -1, 0, 0, 0;
      0, 0, 0, 1, 0, 0, 0, 0;
      0, 0, -1, 0, 0, 0, 0, 0;
      0, -1, 0, 0, 0, 0, 0, 0;
      1, 0, 0, 0, 0, 0, 0, 0]

/-- **The literal is the restriction.** Every one of the `64` entries of `symJ8` — the zeros included — is the
wedge sign of the corresponding pair of invariant triples. Without this the matrix below would be an assertion;
with it, `symJ8` is computed from the definition of the pairing. -/
theorem symJ8_is_wedge :
    (List.finRange 8).all (fun i => (List.finRange 8).all fun j =>
      symJ8 i j == wedgeSign (invTriples.getD i.val []) (invTriples.getD j.val [])) = true := by
  decide +kernel

theorem restricted_antisymm : symJ8ᵀ = -symJ8 := by decide +kernel

theorem restricted_sq : symJ8 * symJ8 = -1 := by decide +kernel

theorem restricted_unimodular : IsUnimodular symJ8 := by
  have h : (-symJ8) * symJ8 = 1 := by rw [Matrix.neg_mul, restricted_sq]; simp
  exact isUnimodular_of_mul_eq_one symJ8 (-symJ8) h

/-- The flux pairing inside the invariant sublattice. -/
def invPairing (H F : Fin 8 → ℤ) : ℤ := H ⬝ᵥ (symJ8 *ᵥ F)

def hInv : Fin 8 → ℤ := fun i => if i = 7 then 1 else 0
def fInv (k m : ℤ) : Fin 8 → ℤ := fun i => if i = 0 then k else if i = 1 then m else 0

/-- **The same infinite family survives the projection.** -/
theorem invariant_flux_family (k m : ℤ) : invPairing hInv (fInv k m) = k := by
  simp [invPairing, hInv, fInv, symJ8, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]

theorem invariant_family_injective (k : ℤ) : Function.Injective (fInv k) := by
  intro m₁ m₂ h
  have := congrFun h 1
  simpa [fInv] using this

end DualScaleStream2.Flux.InvariantH3
