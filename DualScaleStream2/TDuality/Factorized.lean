/-
Stream 2 · P2.2 — Factorized T-dualities and the charge norm of `Γ^{d,d}`.

## Physical background
This file formalizes the third of GPR's elementary `O(d,d,ℤ)` generators (`ODD.lean`
covers the first two): the *factorized duality* `D_k`, Source (Tier L): Giveon,
Porrati, Rabinovici, hep-th/9401139, §2.4, eq. (2.4.29)
(`papers/foundations/giveon_hep-th_9401139.txt`, lines 1399–1422):
`g_{D_i} = [[I − e_i, e_i],[e_i, I − e_i]]`, "a generalization of the R → 1/R circle
duality in the X^i direction" — i.e. `D_k` acts as ordinary circle T-duality on the
`k`-th compact direction alone, leaving the other `d-1` directions untouched. It also
formalizes the *charge norm* `Zᵀ η Z`, whose evenness is the statement that the
momentum-winding lattice `Γ^{d,d}` is an even lattice, a prerequisite for worldsheet
modular invariance of the toroidal CFT partition function. GPR's statement that the
Θ-shifts, basis changes and factorized dualities together *generate* `O(d,d,ℤ)`
(line 1422) is Tier L and not proved here.

## Mathematical content
For every `d`, proves:
* `factorized_isODD`: each `D_k` lies in `O(d,d;ℤ)`;
* `factorized_mul_self`: each `D_k` is an involution (`D_k² = 1`), matching the
  physical statement that dualizing the same circle twice is trivial;
* `factorized_comm`: distinct `D_k, D_l` commute (dualizing different circles is
  order-independent);
* `factorized_two`: on `T²` specifically, `D₀ D₁ = η`, i.e. dualizing both circles is
  the same as the full momentum ↔ winding swap from `ODD.lean`;
* `chargeNorm_sumElim`: `Zᵀ η Z = 2 n·w` when `Z` is split into momentum/winding
  parts `(n, w)`;
* `chargeNorm_even`: consequently `Zᵀ η Z` is always even — `Γ^{d,d}` is an even
  lattice, generalizing Stream 1's rank-1 `NarainLattice.narain_form_even` from
  `d = 1` to arbitrary `d`;
* `chargeNorm_invariant`: the charge norm is unchanged by any `g ∈ O(d,d;ℤ)`.
Not proved here: that `factorized`, together with `ODD.thetaShift`/`basisChange`,
generate all of `O(d,d;ℤ)` (Tier L, GPR line 1422, see above).

## Proof techniques
`proj k` (the matrix unit `e_k`) is built from Mathlib's `Matrix.single`, whose
algebra (`single_mul_single_same`, `single_mul_single_of_ne`, `transpose_single`)
handles the idempotence/commutativity lemmas about `proj` needed as inputs to the
block-matrix identities about `factorized`. Those identities themselves follow the
same pattern as `ODD.lean`: `unfold` to `fromBlocks`, apply `fromBlocks_multiply`/
`fromBlocks_inj` to reduce a `2×2` block-matrix equation to four ordinary matrix
equations, then close each with `simp` plus the commutative-group tactic `abel` (the
blocks involve only `+`, `-`, and already-known products, not division or inverses).
`factorized_two` and `chargeNorm_sumElim`/`chargeNorm_even`/`chargeNorm_invariant` use
`Matrix.mulVec`/`dotProduct` lemmas instead, since they are statements about the
action on vectors rather than matrix-matrix identities.

## Related declarations
* `StringTheory.UseCases.NarainLattice.narain_form_even` (`Even (Q n w)` for
  `Q n w := 2 * n * w`, `n w : ℤ`) is the `d = 1` special case of `chargeNorm_even`,
  proved independently in Stream 1 directly from the hard-coded formula `2nw`, rather
  than derived from the pairing `η` as `chargeNorm_even` does here; both are stated
  over `ℤ`, so `chargeNorm_even` is the intended generalization of the same fact from
  `d = 1` to arbitrary `d`, not merely a similar-looking statement.
* `DualScaleStream2.Flux.flux_half_selfIntersection_integral` (`Flux/Integrality.lean`)
  proves a different evenness fact — that `x ⬝ᵥ (kronForm L₁ L₂ *ᵥ x)` (a Kronecker
  product of two Gram matrices, one of which is required to have even diagonal) is
  even — by a genuinely different technique (reduction to a general
  even-diagonal-implies-even-quadratic-form lemma via reindexing, not the direct
  momentum/winding split used in `chargeNorm_even`). The atlas flags a dependency
  overlap between the two, but this reflects only that both conclude `∃ k, (…) = 2k`
  about a bilinear pairing, not a shared proof idea or object.
* `Mirror.lean`'s `mirror_conjugates_tauShift` uses `factorized (0 : Fin 2)` directly
  (the same definition proved to lie in `O(2,2;ℤ)` and be an involution here via
  `factorized_isODD`/`factorized_mul_self`) to build the mirror-symmetry identity on
  `T²`; `SL2Product.lean` and `Spectrum.lean` build further on `IsODD`/`chargeNorm`
  from this file and `ODD.lean`.
-/
import DualScaleStream2.TDuality.ODD
import Mathlib.Data.Matrix.Basis

namespace DualScaleStream2.TDuality

open Matrix

variable {d : ℕ}

/-- `e_k`: the matrix unit at `(k,k)`, i.e. the diagonal projector onto the `k`-th
    coordinate. Used to isolate "act on direction `k` only" in `factorized` below. -/
def proj (k : Fin d) : Matrix (Fin d) (Fin d) ℤ := single k k 1

/-- Factorized duality `D_k` (GPR eq. (2.4.29)): `[[I − e_k, e_k],[e_k, I − e_k]]`.
    Physically, `D_k` is ordinary circle T-duality `R_k ↦ 1/R_k` applied to the `k`-th
    compact direction only; on all other directions it acts as the identity. -/
def factorized (k : Fin d) : Matrix (Charge d) (Charge d) ℤ :=
  fromBlocks (1 - proj k) (proj k) (proj k) (1 - proj k)

/-- `e_k` is idempotent: `e_k² = e_k` (a projector projects onto its own image
    trivially). -/
theorem proj_mul_self (k : Fin d) : proj k * proj k = proj k := by
  unfold proj
  simp [single_mul_single_same]

/-- `e_k` is symmetric: `e_kᵀ = e_k` (a diagonal matrix unit is its own transpose). -/
theorem proj_transpose (k : Fin d) : (proj k)ᵀ = proj k := by
  unfold proj
  exact transpose_single k k 1

/-- Helper: `proj k` and `proj l` commute (they are `0` unless `k = l`). -/
theorem proj_comm (k l : Fin d) : proj k * proj l = proj l * proj k := by
  unfold proj
  by_cases h : k = l
  · rw [h]
  · simp [single_mul_single_of_ne, h, Ne.symm h]

/-- **`D_k` is an involution**: dualizing the `k`-th circle twice is the identity,
    matching the physical fact `R ↦ 1/R ↦ R`. Proof idea: expand `D_k · D_k` blockwise
    into a `2×2` matrix equation via `fromBlocks_multiply`/`fromBlocks_inj`, then reduce
    each of the four block identities to the single fact `e_k² = e_k` (`hp`) using ring
    normalization (`sub_mul`/`mul_sub`) and the abelian-group closer `abel`. -/
theorem factorized_mul_self (k : Fin d) : factorized k * factorized k = 1 := by
  have hp : proj k * proj k = proj k := proj_mul_self k
  unfold factorized
  -- reduce the matrix equation D_k·D_k = 1 to four scalar-block equations
  rw [fromBlocks_multiply, ← fromBlocks_one, fromBlocks_inj]
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp only [sub_mul, mul_sub, one_mul, mul_one, hp] <;> abel

/-- **`D_k` lies in `O(d,d;ℤ)`**, i.e. it is a genuine duality symmetry. Proof idea:
    `D_k` is itself symmetric (`ht`, from `e_k` being symmetric), which turns the
    defining condition `D_kᵀ η D_k = η` into `D_k η D_k = η`; expand that blockwise as
    in `factorized_mul_self`, again closing each block with `e_k² = e_k` and `abel`. -/
theorem factorized_isODD (k : Fin d) : IsODD (factorized k) := by
  have hp : proj k * proj k = proj k := proj_mul_self k
  have ht : (factorized k)ᵀ = factorized k := by
    unfold factorized
    rw [fromBlocks_transpose, transpose_sub, transpose_one, proj_transpose]
  unfold IsODD
  rw [ht]
  unfold factorized eta
  -- expand D_k η D_k blockwise; each of the four blocks reduces to e_k² = e_k
  rw [fromBlocks_multiply, fromBlocks_multiply, fromBlocks_inj]
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp only [mul_zero, one_mul, mul_one, add_zero, zero_add, sub_mul, mul_sub, hp] <;>
      abel

/-- **Factorized dualities on distinct circles commute**: order does not matter when
    dualizing different directions. Proof idea: `proj_comm` gives `e_k e_l = e_l e_k`;
    expand `D_k D_l` and `D_l D_k` blockwise and reduce both sides to the same
    expression using that single commutation fact. -/
theorem factorized_comm (k l : Fin d) :
    factorized k * factorized l = factorized l * factorized k := by
  have hkl : proj k * proj l = proj l * proj k := proj_comm k l
  unfold factorized
  -- reduce the matrix equation D_k D_l = D_l D_k to four scalar-block equations
  rw [fromBlocks_multiply, fromBlocks_multiply, fromBlocks_inj]
  -- each block equation is closed by substituting e_k e_l = e_l e_k (hkl) and
  -- normalizing the surrounding +/- ring structure with abel
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp only [sub_mul, mul_sub, one_mul, mul_one, hkl] <;> abel

/-- **On `T²`, dualizing both circles is the full duality `η`**: `D₀ D₁` swaps all
    momenta and windings at once, matching the general momentum ↔ winding swap of
    `ODD.eta`. Proof idea: both sides are fixed `4×4` integer matrices (`Charge 2` has
    four elements), so equality is checked entry-by-entry by exhaustive case split
    (`fin_cases`) followed by `rfl`. -/
theorem factorized_two : factorized (0 : Fin 2) * factorized 1 = eta 2 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

/-- Charge norm `Zᵀ η Z` of a charge vector `Z = (n, w)`: the quadratic form on the
    momentum-winding lattice `Γ^{d,d}` associated with the pairing `η`. Physically,
    for `Z = (n, w)` this equals `2 n·w` (see `chargeNorm_sumElim`) — twice the
    level-matching combination `N - Ñ = n·w`. -/
def chargeNorm (Z : Charge d → ℤ) : ℤ := Z ⬝ᵥ (eta d *ᵥ Z)

/-- Splitting `Z = (n, w)` into its momentum and winding parts, the charge norm is
    `2(n·w)`. Proof idea: expand `η *ᵥ Z` blockwise (`fromBlocks_mulVec`), which
    isolates `n` and `w` via `Sum.elim_comp_inl/inr`; the resulting dot product
    `n · w + w · n` collapses to `2(n·w)` by commutativity of `⬝ᵥ` and `ring`. -/
theorem chargeNorm_sumElim (n w : Fin d → ℤ) :
    chargeNorm (Sum.elim n w) = 2 * (n ⬝ᵥ w) := by
  unfold chargeNorm eta
  -- expand η *ᵥ (n,w) blockwise: the block form of η picks out (w, n) from (n, w)
  rw [fromBlocks_mulVec, Sum.elim_comp_inl, Sum.elim_comp_inr]
  -- the 0-blocks of η drop out, leaving η *ᵥ (n,w) = (w, n)
  simp only [Matrix.zero_mulVec, Matrix.one_mulVec, zero_add, add_zero]
  -- so chargeNorm = (n,w) ⬝ (w,n) = n·w + w·n = 2(n·w)
  rw [sumElim_dotProduct_sumElim, dotProduct_comm w n]
  ring

/-- **`Γ^{d,d}` is an even lattice**: every charge vector has even norm. Physically,
    this is the statement needed for worldsheet modular invariance of the toroidal CFT.
    Proof idea: write any `Z` as `Sum.elim n w` for its momentum/winding parts, apply
    `chargeNorm_sumElim` to get `2(n·w)`, which is even by definition (`2 * k` with
    `k = n·w`). -/
theorem chargeNorm_even (Z : Charge d → ℤ) : Even (chargeNorm Z) := by
  -- split the general charge Z into its momentum part n and winding part w
  let n := Z ∘ Sum.inl
  let w := Z ∘ Sum.inr
  have hz : Z = Sum.elim n w := by ext ⟨i⟩ <;> rfl
  -- rewrite chargeNorm Z as chargeNorm (Sum.elim n w) = 2(n·w), which is even by definition
  rw [hz, chargeNorm_sumElim]
  use n ⬝ᵥ w
  ring

/-- **The charge norm is `O(d,d;ℤ)`-invariant**: applying any duality symmetry `g` to
    a charge vector does not change its norm — physically, the level-matching /
    mass-norm data of a state is duality-invariant. Proof idea: unfold `chargeNorm` and
    push `g` through the pairing using `IsODD`'s defining identity `gᵀ η g = η`, so that
    `(gZ) ⬝ (η (gZ)) = Z ⬝ ((gᵀ η g) Z) = Z ⬝ (η Z)`. -/
theorem chargeNorm_invariant (g : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g)
    (Z : Charge d → ℤ) : chargeNorm (g *ᵥ Z) = chargeNorm Z := by
  unfold chargeNorm
  unfold IsODD at hg
  rw [mulVec_mulVec, dotProduct_mulVec, vecMul_mulVec, ← mul_assoc, hg, dotProduct_mulVec]

end DualScaleStream2.TDuality
