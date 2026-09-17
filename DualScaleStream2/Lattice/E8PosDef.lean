/-
Stream 2 · P2.3 — `E8` is positive definite, with `det = 1` exactly.

`Lattice.E8` proved `E8` unimodular (`det = ±1`) via an integer inverse. This file fixes the
sign and the signature `(8, 0)` via an exact rational `LDLᵀ` factorization (computed with
sympy; *not trusted* — the kernel checks `L D Lᵀ = E8` entry by entry):
`D = diag(2, 3/2, 4/3, 5/4, 6/5, 7/6, 8/7, 1/8)`, all pivots positive, product `1`.

Tier A: the factorization, `det E8 = 1`, and positive-definiteness over `ℝ`.
Tier L (why it matters): `E8(−1)⊕2 ⊕ U⊕3 ≅ H²(K3,ℤ)` (Huybrechts Ch. 1 eq. (3.4)) — with
`E8` positive definite, `E8(−1)` is negative definite, which is the input to
`K3T2Signature.sigE8Neg = (0, 8)`; this file upgrades that input from Tier L to Tier A for
the `E8` summand.
-/
import DualScaleStream2.Lattice.E8
import Mathlib.LinearAlgebra.Matrix.PosDef

namespace DualScaleStream2.Lattice

open Matrix

/-- Unit lower-triangular factor. -/
noncomputable def e8L : Matrix (Fin 8) (Fin 8) ℝ :=
  !![1, 0, 0, 0, 0, 0, 0, 0;
     -1/2, 1, 0, 0, 0, 0, 0, 0;
     0, -2/3, 1, 0, 0, 0, 0, 0;
     0, 0, -3/4, 1, 0, 0, 0, 0;
     0, 0, 0, -4/5, 1, 0, 0, 0;
     0, 0, 0, 0, -5/6, 1, 0, 0;
     0, 0, 0, 0, 0, -6/7, 1, 0;
     0, 0, 0, 0, -5/6, -5/7, -5/8, 1]

/-- Positive pivots. -/
noncomputable def e8D : Matrix (Fin 8) (Fin 8) ℝ :=
  Matrix.diagonal ![2, 3/2, 4/3, 5/4, 6/5, 7/6, 8/7, 1/8]

/-- `E8` over `ℝ`. -/
noncomputable def cartanE8R : Matrix (Fin 8) (Fin 8) ℝ := cartanE8.map (Int.cast : ℤ → ℝ)

/-- The `LDLᵀ` certificate. -/
theorem e8_LDL : e8L * e8D * e8Lᵀ = cartanE8R := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [e8L, e8D, cartanE8R, cartanE8, Matrix.mul_apply, Matrix.transpose_apply,
      Matrix.vecMul_diagonal, Fin.sum_univ_succ] <;> ring

/-- `det E8 = 1` exactly (the product of the pivots). -/
theorem cartanE8_det : cartanE8.det = 1 := by
  have hUtri : e8Lᵀ.IsUpperTriangular := by
    intro i j hij
    simp only [Matrix.transpose_apply]
    fin_cases i <;> fin_cases j <;> simp_all [e8L]
  have hLTdet : e8Lᵀ.det = 1 := by
    rw [Matrix.det_of_isUpperTriangular hUtri]
    simp [Matrix.transpose_apply, e8L, Fin.prod_univ_succ]
  have hLdet : e8L.det = 1 := (Matrix.det_transpose e8L).symm.trans hLTdet
  have hDdet : e8D.det = 1 := by
    rw [e8D, Matrix.det_diagonal]
    simp [Fin.prod_univ_succ]
    norm_num
  have hR : cartanE8R.det = 1 := by
    rw [← e8_LDL, Matrix.det_mul, Matrix.det_mul, hLdet, hDdet, hLTdet]
    ring
  have hcast : (cartanE8.det : ℝ) = cartanE8R.det := Int.cast_det cartanE8
  rw [hR] at hcast
  exact_mod_cast hcast

/-- **`E8` is positive definite.** -/
theorem cartanE8_posDef : cartanE8R.PosDef := by
  have hHerm : cartanE8R.IsHermitian :=
    isHermitian_iff_isSymm.mpr (Matrix.IsSymm.map cartanE8_symm (Int.cast : ℤ → ℝ))
  refine Matrix.PosDef.of_dotProduct_mulVec_pos hHerm ?_
  intro x hx
  simp [Pi.star_apply, star_trivial, dotProduct, Matrix.mulVec, cartanE8R, cartanE8,
    Fin.sum_univ_succ]
  set y0 := x 0 - x 1 / 2 with hy0def
  set y1 := x 1 - 2 * x 2 / 3 with hy1def
  set y2 := x 2 - 3 * x 3 / 4 with hy2def
  set y3 := x 3 - 4 * x 4 / 5 with hy3def
  set y4 := x 4 - 5 * x 5 / 6 - 5 * x 7 / 6 with hy4def
  set y5 := x 5 - 6 * x 6 / 7 - 5 * x 7 / 7 with hy5def
  set y6 := x 6 - 5 * x 7 / 8 with hy6def
  set y7 := x 7 with hy7def
  have hqeq :
      x 0 * (2 * x 0 + -x 1) +
        (x 1 * (-x 0 + (2 * x 1 + -x 2)) +
          (x 2 * (-x 1 + (2 * x 2 + -x 3)) +
            (x 3 * (-x 2 + (2 * x 3 + -x 4)) +
              (x 4 * (-x 3 + (2 * x 4 + (-x 5 + -x 7))) +
                (x 5 * (-x 4 + (2 * x 5 + -x 6)) +
                  (x 6 * (-x 5 + 2 * x 6) + x 7 * (-x 4 + 2 * x 7)))))))
      = 2 * y0 ^ 2 + (3 / 2) * y1 ^ 2 + (4 / 3) * y2 ^ 2 + (5 / 4) * y3 ^ 2 + (6 / 5) * y4 ^ 2 +
          (7 / 6) * y5 ^ 2 + (8 / 7) * y6 ^ 2 + (1 / 8) * y7 ^ 2 := by
    rw [hy0def, hy1def, hy2def, hy3def, hy4def, hy5def, hy6def, hy7def]
    ring
  suffices h : (0:ℝ) < 2 * y0 ^ 2 + (3 / 2) * y1 ^ 2 + (4 / 3) * y2 ^ 2 + (5 / 4) * y3 ^ 2 +
      (6 / 5) * y4 ^ 2 + (7 / 6) * y5 ^ 2 + (8 / 7) * y6 ^ 2 + (1 / 8) * y7 ^ 2 by
    linarith [hqeq]
  by_contra hle
  push_neg at hle
  have hnn : (0:ℝ) ≤ 2 * y0 ^ 2 + (3 / 2) * y1 ^ 2 + (4 / 3) * y2 ^ 2 + (5 / 4) * y3 ^ 2 +
      (6 / 5) * y4 ^ 2 + (7 / 6) * y5 ^ 2 + (8 / 7) * y6 ^ 2 + (1 / 8) * y7 ^ 2 := by positivity
  have hz := le_antisymm hle hnn
  have e0 : y0 ^ 2 = 0 := by
    linarith [sq_nonneg y0, sq_nonneg y1, sq_nonneg y2, sq_nonneg y3, sq_nonneg y4,
      sq_nonneg y5, sq_nonneg y6, sq_nonneg y7]
  have e1 : y1 ^ 2 = 0 := by
    linarith [sq_nonneg y0, sq_nonneg y1, sq_nonneg y2, sq_nonneg y3, sq_nonneg y4,
      sq_nonneg y5, sq_nonneg y6, sq_nonneg y7]
  have e2 : y2 ^ 2 = 0 := by
    linarith [sq_nonneg y0, sq_nonneg y1, sq_nonneg y2, sq_nonneg y3, sq_nonneg y4,
      sq_nonneg y5, sq_nonneg y6, sq_nonneg y7]
  have e3 : y3 ^ 2 = 0 := by
    linarith [sq_nonneg y0, sq_nonneg y1, sq_nonneg y2, sq_nonneg y3, sq_nonneg y4,
      sq_nonneg y5, sq_nonneg y6, sq_nonneg y7]
  have e4 : y4 ^ 2 = 0 := by
    linarith [sq_nonneg y0, sq_nonneg y1, sq_nonneg y2, sq_nonneg y3, sq_nonneg y4,
      sq_nonneg y5, sq_nonneg y6, sq_nonneg y7]
  have e5 : y5 ^ 2 = 0 := by
    linarith [sq_nonneg y0, sq_nonneg y1, sq_nonneg y2, sq_nonneg y3, sq_nonneg y4,
      sq_nonneg y5, sq_nonneg y6, sq_nonneg y7]
  have e6 : y6 ^ 2 = 0 := by
    linarith [sq_nonneg y0, sq_nonneg y1, sq_nonneg y2, sq_nonneg y3, sq_nonneg y4,
      sq_nonneg y5, sq_nonneg y6, sq_nonneg y7]
  have e7 : y7 ^ 2 = 0 := by
    linarith [sq_nonneg y0, sq_nonneg y1, sq_nonneg y2, sq_nonneg y3, sq_nonneg y4,
      sq_nonneg y5, sq_nonneg y6, sq_nonneg y7]
  have hy0z : y0 = 0 := sq_eq_zero_iff.mp e0
  have hy1z : y1 = 0 := sq_eq_zero_iff.mp e1
  have hy2z : y2 = 0 := sq_eq_zero_iff.mp e2
  have hy3z : y3 = 0 := sq_eq_zero_iff.mp e3
  have hy4z : y4 = 0 := sq_eq_zero_iff.mp e4
  have hy5z : y5 = 0 := sq_eq_zero_iff.mp e5
  have hy6z : y6 = 0 := sq_eq_zero_iff.mp e6
  have hy7z : y7 = 0 := sq_eq_zero_iff.mp e7
  have hxx7 : x 7 = 0 := hy7def.symm.trans hy7z
  have hxx6 : x 6 = 0 := by
    have h6 : x 6 - 5 * x 7 / 8 = 0 := hy6def.symm.trans hy6z
    linarith [hxx7]
  have hxx5 : x 5 = 0 := by
    have h5 : x 5 - 6 * x 6 / 7 - 5 * x 7 / 7 = 0 := hy5def.symm.trans hy5z
    linarith [hxx6, hxx7]
  have hxx4 : x 4 = 0 := by
    have h4 : x 4 - 5 * x 5 / 6 - 5 * x 7 / 6 = 0 := hy4def.symm.trans hy4z
    linarith [hxx5, hxx7]
  have hxx3 : x 3 = 0 := by
    have h3 : x 3 - 4 * x 4 / 5 = 0 := hy3def.symm.trans hy3z
    linarith [hxx4]
  have hxx2 : x 2 = 0 := by
    have h2 : x 2 - 3 * x 3 / 4 = 0 := hy2def.symm.trans hy2z
    linarith [hxx3]
  have hxx1 : x 1 = 0 := by
    have h1 : x 1 - 2 * x 2 / 3 = 0 := hy1def.symm.trans hy1z
    linarith [hxx2]
  have hxx0 : x 0 = 0 := by
    have h0 : x 0 - x 1 / 2 = 0 := hy0def.symm.trans hy0z
    linarith [hxx1]
  apply hx
  funext i
  fin_cases i <;> simp_all

end DualScaleStream2.Lattice
