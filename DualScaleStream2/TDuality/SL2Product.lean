/-
Stream 2 · P2.2 — On `T²`, the τ-modular group commutes with the ρ-translations.

Source (Tier L): Giveon–Porrati–Rabinovici hep-th/9401139, "The d = 2 Example"
(`papers/foundations/giveon_hep-th_9401139.txt`, lines 1874–1884): "the duality symmetry group
turns out to be isomorphic to SL(2, Z) × SL(2, Z) ⊗S [Z2 × Z2]" — explicitly *not* a naive
factorization of `O(2,2,Z)` — with the four real data `G₁₁, G₁₂, G₂₂, B₁₂` organized into
complex coordinates `ρ` and `τ`. Basis changes act on τ; integer B-shifts are the translations
`ρ ↦ ρ + t`.

Tier A here (the scope is deliberately narrower than the full `SL(2,ℤ)_ρ`):
* `A J Aᵀ = det(A) · J` for every `2×2` integer `A`, with `J = [[0,1],[-1,0]]` (verified with
  sympy first);
* the basis changes `diag(A, B)` (`AᵀB = 1`) form a monoid under multiplication, and the
  Θ-shifts form the additive group of antisymmetric `Θ`;
* **a basis change with `det A = 1` commutes with every ρ-translation** `g_{tJ}` — so
  `SL(2,ℤ)_τ` and the ρ-translations generate a commuting product inside `O(2,2;ℤ)`
  (sympy: the commutator vanishes exactly when `det A = 1`).
Not claimed: the `ρ ↦ −1/ρ` generator or the full `SL(2,ℤ)_ρ`.
-/
import DualScaleStream2.TDuality.ODD

namespace DualScaleStream2.TDuality

open Matrix

/-- `J = [[0,1],[-1,0]]`. -/
def jMat : Matrix (Fin 2) (Fin 2) ℤ := !![0, 1; -1, 0]

theorem mul_jMat_mul_transpose (A : Matrix (Fin 2) (Fin 2) ℤ) :
    A * jMat * Aᵀ = A.det • jMat := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, jMat, Matrix.det_fin_two, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;>
    ring_nf <;>
    aesop

theorem basisChange_mul {d : ℕ} (A B A' B' : Matrix (Fin d) (Fin d) ℤ) :
    basisChange A B * basisChange A' B' = basisChange (A * A') (B * B') := by
  ext i j
  simp [basisChange, Matrix.mul_apply, Finset.sum_mul, Finset.mul_sum]
  <;> ring
  <;> aesop

theorem thetaShift_mul {d : ℕ} (Θ Θ' : Matrix (Fin d) (Fin d) ℤ) :
    thetaShift Θ * thetaShift Θ' = thetaShift (Θ + Θ') := by
  unfold thetaShift
  rw [fromBlocks_multiply]
  simp [add_comm]

/-- **`SL(2,ℤ)_τ` commutes with the ρ-translations.** -/
theorem basisChange_comm_thetaShift (A B : Matrix (Fin 2) (Fin 2) ℤ) (hAB : Aᵀ * B = 1)
    (hdet : A.det = 1) (t : ℤ) :
    basisChange A B * thetaShift (t • jMat) = thetaShift (t • jMat) * basisChange A B := by
  have hjMat : A * jMat * Aᵀ = jMat := by
    rw [mul_jMat_mul_transpose A, hdet]; simp
  have hcomm : A * jMat = jMat * B := by
    have h1 : A * jMat = A * jMat * (Aᵀ * B) := by simp [hAB]
    rw [h1]
    rw [show A * jMat * (Aᵀ * B) = (A * jMat * Aᵀ) * B by simp [Matrix.mul_assoc]]
    simp [hjMat]
  unfold basisChange thetaShift
  ext i j
  simp only [fromBlocks_multiply, Matrix.mul_smul, Matrix.smul_mul]
  fin_cases i <;> fin_cases j <;> simp [hcomm]

end DualScaleStream2.TDuality
