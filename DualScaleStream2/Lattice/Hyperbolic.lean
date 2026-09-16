/-
Stream 2 · The hyperbolic plane `U`.

`U` is the rank-2 lattice with an isotropic basis `e, f`, `(e·f) = 1` — Huybrechts,
*Lectures on K3 Surfaces*, Ch. 1, proof of eq. (3.4) (Tier L definition source).

Tier A here: symmetric, even, unimodular; a rational congruence witness
`Pᵀ U P = diag(2, −2)`. That witness shows `U` has one positive and one negative
direction; the step "diagonal congruence determines the signature" is Sylvester's law
of inertia, which is **Tier L** (not re-proved here).

Cross-link to Stream 1: `U` *is* the Narain lattice `Γ¹'¹` already certified in
`StringTheoryFormalization.UseCases.NarainLattice` — proved equal below, so Stream 2
builds on that result instead of restating it.
-/
import DualScaleStream2.Lattice.Basic
import StringTheoryFormalization.UseCases.NarainLattice

namespace DualScaleStream2.Lattice

open Matrix

/-- Hyperbolic plane `U`. -/
def hyperbolicU : Gram 2 := !![0, 1; 1, 0]

theorem hyperbolicU_symm : hyperbolicUᵀ = hyperbolicU := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

theorem hyperbolicU_evenDiag : IsEvenDiag hyperbolicU := by
  intro i
  fin_cases i <;> simp [hyperbolicU]
  <;> rfl

/-- `U` is its own inverse, hence unimodular. -/
theorem hyperbolicU_mul_self : hyperbolicU * hyperbolicU = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [hyperbolicU, Matrix.mul_apply, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;>
    norm_num
  <;> rfl

theorem hyperbolicU_unimodular : IsUnimodular hyperbolicU :=
  isUnimodular_of_mul_eq_one _ _ hyperbolicU_mul_self

/-- Congruence witness: `Pᵀ U P = diag(2, −2)` with `P = [[1,1],[1,−1]]`. -/
theorem hyperbolicU_congruence :
    (!![1, 1; 1, -1] : Gram 2)ᵀ * hyperbolicU * !![1, 1; 1, -1] = !![2, 0; 0, -2] := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [hyperbolicU, Matrix.mul_apply, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;>
    norm_num
  <;>
    rfl

/-- **Cross-link.** Stream 2's `U` is exactly Stream 1's Narain Gram matrix. -/
theorem hyperbolicU_eq_narain_gram :
    hyperbolicU = StringTheory.UseCases.NarainLattice.gram := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

end DualScaleStream2.Lattice
