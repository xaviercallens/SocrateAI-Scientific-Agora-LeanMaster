-- Use Case 3: The Narain Lattice Γ^{1,1} is Even, Self-Dual, and R-Independent
-- Status: VERIFIED (0 sorry, 0 admit)
-- Source: Narain (1986) Phys.Lett.B 169; Narain-Sarmadi-Witten (1987);
--         Polchinski Vol.1 §8.4; Ginsparg (1988) hep-th/8809176.
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic

namespace StringTheory.UseCases.NarainLattice

/-!
# The Narain Lattice `Γ^{1,1}`: Radius-Independence, Evenness, Self-Duality

A closed string compactified on a circle of radius `R` carries left/right
momenta `P_L = n/R + wR`, `P_R = n/R - wR` for integer momentum/winding
`(n, w)`. The Lorentzian inner product `Q(n,w) = (P_L² - P_R²)/2` is the norm
on the **Narain lattice** `Γ^{1,1}`. Three facts make this lattice the basic
building block of all Narain (toroidal) compactifications:

1. `Q` does not actually depend on `R` — the *same* abstract lattice underlies
   every radius; only its embedding into the `(P_L,P_R)` plane moves with `R`.
   This is precisely why the T-duality moduli space of a single compact boson
   is trivial (a point, modulo `R ↔ 1/R`).
2. `Q` is **even**: `Q(n,w) ∈ 2ℤ` for every lattice vector, a prerequisite for
   worldsheet modular invariance of the associated CFT partition function.
3. The lattice is **unimodular** (self-dual): its Gram matrix in the natural
   `(n,w)` integer basis has determinant `-1`.
-/

/-- Left-moving momentum (see also `UseCases.TDuality.leftMomentum`, restated
    self-contained here so this file's Narain-specific claims don't
    accidentally depend on the T-duality file's conventions). -/
def pL (n w R : ℚ) : ℚ := n / R + w * R

/-- Right-moving momentum. -/
def pR (n w R : ℚ) : ℚ := n / R - w * R

/-- The Narain quadratic form, as actually realized by the momenta. -/
def narainNorm (n w R : ℚ) : ℚ := (pL n w R ^ 2 - pR n w R ^ 2) / 2

/-- **Fact 1**: `narainNorm` equals `2nw` for *every* nonzero radius `R` — the
    quadratic form on the lattice carries no memory of the compactification
    radius. -/
theorem narain_norm_R_independent (n w R : ℚ) (hR : R ≠ 0) :
    narainNorm n w R = 2 * n * w := by
  unfold narainNorm pL pR
  field_simp
  ring

/-- The abstract integer-valued quadratic form on `Γ^{1,1}`, independent of
    any embedding. -/
def Q (n w : ℤ) : ℤ := 2 * n * w

/-- **Fact 2**: `Γ^{1,1}` is an even lattice. -/
theorem narain_form_even (n w : ℤ) : Even (Q n w) := ⟨n * w, by unfold Q; ring⟩

/-- The associated symmetric bilinear form, obtained from `Q` by
    polarization: `B(v,v') = (Q(v+v') - Q(v) - Q(v'))/2`. -/
def B (n w n' w' : ℤ) : ℤ := n * w' + n' * w

theorem B_is_polarization_of_Q (n w n' w' : ℤ) :
    2 * B n w n' w' = Q (n + n') (w + w') - Q n w - Q n' w' := by
  unfold B Q; ring

/-- The Gram matrix of `B` in the standard integer basis `(1,0), (0,1)`. -/
def gram : Matrix (Fin 2) (Fin 2) ℤ :=
  !![B 1 0 1 0, B 1 0 0 1; B 0 1 1 0, B 0 1 0 1]

/-- The Gram matrix is exactly the standard hyperbolic form `[[0,1],[1,0]]`. -/
theorem gram_eq_hyperbolic : gram = !![0, 1; 1, 0] := by
  unfold gram B
  norm_num

/-- **Fact 3**: `Γ^{1,1}` is unimodular (self-dual) — its Gram determinant is
    `±1`. -/
theorem narain_gram_unimodular : gram.det = -1 := by
  rw [gram_eq_hyperbolic]
  simp [Matrix.det_fin_two]

end StringTheory.UseCases.NarainLattice
