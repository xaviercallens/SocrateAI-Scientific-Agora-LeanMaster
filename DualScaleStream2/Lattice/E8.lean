/-
Stream 2 · The E8 lattice and E8(−1).

Source (Tier L, for *why this lattice matters*): Huybrechts, *Lectures on K3 Surfaces*,
Ch. 1, eq. (3.4): `H²(X,ℤ) ≅ E8(−1) ⊕ E8(−1) ⊕ U ⊕ U ⊕ U`
(`papers/foundations/huybrechts_K3Global.txt`, line 603).

Tier A here: the Cartan matrix below is symmetric, has even diagonal, and is
unimodular — the last via an explicit integer inverse checked by the kernel, not by
quoting `det = 1`. The inverse was computed with sympy and is *not trusted*: if it
were wrong, `cartanE8Inv_mul` would fail to compile.

Dynkin labelling: chain `0—1—2—3—4—5—6`, extra node `7` attached to `4`
(arms of length 4, 2, 1 from the branch node: the `T₂,₃,₅` tree = E8).
-/
import DualScaleStream2.Lattice.Basic

namespace DualScaleStream2.Lattice

open Matrix

/-- Cartan matrix of `E8` (positive definite form). -/
def cartanE8 : Gram 8 :=
  !![ 2, -1,  0,  0,  0,  0,  0,  0;
     -1,  2, -1,  0,  0,  0,  0,  0;
      0, -1,  2, -1,  0,  0,  0,  0;
      0,  0, -1,  2, -1,  0,  0,  0;
      0,  0,  0, -1,  2, -1,  0, -1;
      0,  0,  0,  0, -1,  2, -1,  0;
      0,  0,  0,  0,  0, -1,  2,  0;
      0,  0,  0,  0, -1,  0,  0,  2]

/-- Claimed integer inverse of `cartanE8` (certificate; checked by `cartanE8Inv_mul`). -/
def cartanE8Inv : Gram 8 :=
  !![2,  3,  4,  5,  6,  4,  2,  3;
     3,  6,  8, 10, 12,  8,  4,  6;
     4,  8, 12, 15, 18, 12,  6,  9;
     5, 10, 15, 20, 24, 16,  8, 12;
     6, 12, 18, 24, 30, 20, 10, 15;
     4,  8, 12, 16, 20, 14,  7, 10;
     2,  4,  6,  8, 10,  7,  4,  5;
     3,  6,  9, 12, 15, 10,  5,  8]

theorem cartanE8Inv_mul : cartanE8Inv * cartanE8 = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [cartanE8, cartanE8Inv, Matrix.mul_apply, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;> rfl

theorem cartanE8_symm : cartanE8ᵀ = cartanE8 := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

theorem cartanE8_evenDiag : IsEvenDiag cartanE8 := by
  intro i
  fin_cases i <;> simp [cartanE8]
  <;> decide
  <;> rfl

/-- `E8` is unimodular (Tier A, via the checked inverse). -/
theorem cartanE8_unimodular : IsUnimodular cartanE8 :=
  isUnimodular_of_mul_eq_one _ _ cartanE8Inv_mul

/-- `E8(−1)`: the same lattice with the form negated — the summand appearing twice in
the K3 lattice. -/
def e8Neg : Gram 8 := -cartanE8

theorem e8Neg_symm : e8Negᵀ = e8Neg := by
  ext i j
  fin_cases i <;> fin_cases j <;> rfl

theorem e8Neg_evenDiag : IsEvenDiag e8Neg := by
  intro i
  fin_cases i <;> simp [e8Neg, cartanE8, IsEvenDiag]
  <;> decide
  <;> rfl

theorem e8Neg_unimodular : IsUnimodular e8Neg := by
  unfold e8Neg
  have h_inv : (-cartanE8Inv) * (-cartanE8) = 1 := by
    simp only [neg_mul, mul_neg, neg_neg]
    exact cartanE8Inv_mul
  exact isUnimodular_of_mul_eq_one (-cartanE8) (-cartanE8Inv) h_inv

end DualScaleStream2.Lattice
