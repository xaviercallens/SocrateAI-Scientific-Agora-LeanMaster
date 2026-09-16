/-
Stream 2 · The T-duality group `O(d,d;ℤ)` of a `d`-torus.

Source (Tier L): Giveon, Porrati, Rabinovici, *Target Space Duality in String Theory*,
hep-th/9401139, §2.4 "O(d,d,Z) Duality for d-Dimensional Toroidal Compactifications"
(`papers/foundations/giveon_hep-th_9401139.txt`, lines 1355–1373). The generators used
below are theirs: the integer antisymmetric Θ-shift `g_Θ = [[I, Θ],[0, I]]`
(eq. (2.4.25)) and the basis change `A ∈ GL(d,ℤ)`.

Tier A here, for **every** `d` (not just `d = 1, 2`): with charge vectors ordered
(momentum ⊕ winding) and invariant form `η = [[0, I],[I, 0]]`,
* the Θ-shift preserves `η` exactly when `Θ` is antisymmetric;
* a basis change `diag(A, B)` preserves `η` when `Aᵀ B = 1`;
* the full duality `n ↔ w` (i.e. `η` itself) preserves `η` and is an involution;
* `O(d,d;ℤ)` is closed under multiplication.
At `d = 1` the invariant form reduces to Stream 1's Narain Gram matrix.

What is **not** claimed: that these generate all of `O(d,d;ℤ)` (Tier L, same reference),
or anything about the moduli space quotient.
-/
import DualScaleStream2.Lattice.Hyperbolic
import Mathlib.Data.Matrix.Block

namespace DualScaleStream2.TDuality

open Matrix

variable {d : ℕ}

/-- Charge-lattice index set: `d` momenta ⊕ `d` windings. -/
abbrev Charge (d : ℕ) := Fin d ⊕ Fin d

/-- The `O(d,d)`-invariant form `η = [[0, I],[I, 0]]`. -/
def eta (d : ℕ) : Matrix (Charge d) (Charge d) ℤ := fromBlocks 0 1 1 0

/-- `g ∈ O(d,d;ℤ)`. -/
def IsODD (g : Matrix (Charge d) (Charge d) ℤ) : Prop := gᵀ * eta d * g = eta d

/-- Θ-shift (Giveon–Porrati–Rabinovici eq. (2.4.25)). -/
def thetaShift (Θ : Matrix (Fin d) (Fin d) ℤ) : Matrix (Charge d) (Charge d) ℤ :=
  fromBlocks 1 Θ 0 1

/-- Basis change of the compactification lattice. -/
def basisChange (A B : Matrix (Fin d) (Fin d) ℤ) : Matrix (Charge d) (Charge d) ℤ :=
  fromBlocks A 0 0 B

theorem thetaShift_isODD (Θ : Matrix (Fin d) (Fin d) ℤ) (hΘ : Θᵀ = -Θ) :
    IsODD (thetaShift Θ) := by
  unfold IsODD thetaShift eta
  rw [fromBlocks_transpose, fromBlocks_multiply, fromBlocks_multiply, Matrix.transpose_one,
    Matrix.transpose_zero, hΘ]
  simp

theorem basisChange_isODD (A B : Matrix (Fin d) (Fin d) ℤ) (h : Aᵀ * B = 1) :
    IsODD (basisChange A B) := by
  have h' : Bᵀ * A = 1 := by
    have hc := congrArg Matrix.transpose h
    simpa [Matrix.transpose_mul, Matrix.transpose_one, Matrix.transpose_transpose] using hc
  unfold IsODD basisChange eta
  rw [fromBlocks_transpose, fromBlocks_multiply, fromBlocks_multiply, Matrix.transpose_zero]
  simp [h, h']

/-- The full T-duality `n ↔ w` is itself an involution … -/
theorem eta_mul_self : eta d * eta d = 1 := by
  unfold eta
  rw [show (fromBlocks (0 : Matrix (Fin d) (Fin d) ℤ) (1 : Matrix (Fin d) (Fin d) ℤ)
    (1 : Matrix (Fin d) (Fin d) ℤ) (0 : Matrix (Fin d) (Fin d) ℤ)) *
    (fromBlocks (0 : Matrix (Fin d) (Fin d) ℤ) (1 : Matrix (Fin d) (Fin d) ℤ)
    (1 : Matrix (Fin d) (Fin d) ℤ) (0 : Matrix (Fin d) (Fin d) ℤ)) =
    fromBlocks ((0 : Matrix (Fin d) (Fin d) ℤ) * 0 + 1 * 1) ((0 : Matrix (Fin d) (Fin d) ℤ) * 1 + 1 * 0)
    (1 * 0 + 0 * 1) (1 * 1 + 0 * 0) by exact Matrix.fromBlocks_multiply _ _ _ _ _ _ _ _]
  simp

/-- … and lies in `O(d,d;ℤ)`. -/
theorem eta_isODD : IsODD (eta d) := by
  unfold IsODD
  simp only [mul_assoc, eta_mul_self, mul_one]
  simp only [eta, fromBlocks_transpose]
  simp

/-- `O(d,d;ℤ)` is closed under composition. -/
theorem isODD_mul (g h : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g) (hh : IsODD h) :
    IsODD (g * h) := by
  unfold IsODD at *
  calc (g * h)ᵀ * eta d * (g * h)
    = hᵀ * (gᵀ * eta d * g) * h := by simp [Matrix.transpose_mul, Matrix.mul_assoc]
    _ = hᵀ * eta d * h := by rw [hg]
    _ = eta d := by rw [hh]

/-- **Cross-link.** At `d = 1`, `η` is Stream 1's Narain Gram matrix `U`. -/
theorem eta_one_reindex :
    (eta 1).reindex finSumFinEquiv finSumFinEquiv = DualScaleStream2.Lattice.hyperbolicU := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

end DualScaleStream2.TDuality
