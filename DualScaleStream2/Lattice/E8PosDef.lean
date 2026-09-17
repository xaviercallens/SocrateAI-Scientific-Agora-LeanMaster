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

## Physical background

`K3T2Signature.lean` needs `sigE8Neg = (0, 8)` — that `E8(−1)` is *purely negative*
definite — to make the K3 lattice's arithmetic signature `(3,19)` match the Lorentzian
`H²(X,ℤ)` of an actual K3 surface (Huybrechts Ch. 1, eq. (3.4), line 603, same pin as
`E8.lean`). `E8.lean` only proves `cartanE8` symmetric, even-diagonal, and unimodular —
none of which pins down the *sign* of the form (a unimodular even lattice could in
principle be indefinite). This file closes exactly that gap for the `E8` summand: an
explicit rational `LDLᵀ` factorization with strictly positive pivots is a completely
elementary (if computational) way to certify definiteness, one that a student who has
seen Sylvester's criterion or Gaussian elimination with pivoting will recognize directly.

## Mathematical content

`e8L` (unit lower triangular) and `e8D` (diagonal, entries
`2, 3/2, 4/3, 5/4, 6/5, 7/6, 8/7, 1/8`, all positive) are an explicit `LDLᵀ` factorization
of `cartanE8R` (the real cast of `cartanE8`), computed outside Lean by sympy and used only
as a certificate — exactly the same pattern as `cartanE8Inv` in `E8.lean`. `e8_LDL` is the
kernel check `e8L * e8D * e8Lᵀ = cartanE8R`. From it: `cartanE8_det` (the integer
determinant is exactly `1`, via multiplicativity of `det` across the factorization and the
fact that a unit-triangular matrix and its transpose both have determinant `1`) and
`cartanE8_posDef` (`cartanE8R` is positive definite over `ℝ`).

**Not proved here**: the abstract statement "signature `(8,0)`" as a `K3T2Signature.
Signature` value — only `PosDef` (over `ℝ`) and `det = 1` (over `ℤ`) are proved; that a
symmetric positive-definite matrix has signature `(n,0)` is basic linear algebra, used
informally in the header comment but not stated as a Lean theorem in this file. Also not
proved: anything about `E8` as an abstract root system beyond this one matrix, and no
claim that the *rational* `LDLᵀ` factors `e8L`/`e8D` have any meaning beyond being a
positive-definiteness certificate (they are not, e.g., claimed to be integral or related
to a sublattice).

## Proof techniques

`e8_LDL` is a `fin_cases`-and-compute check identical in spirit to `E8.cartanE8Inv_mul`,
except over `ℝ` and closed with `ring` instead of `rfl`/`decide` (needed because the
entries are rational, not just integer, literals). `cartanE8_det` chains three facts about
determinants of triangular matrices (a unit-upper-triangular matrix has determinant `1`;
transpose preserves determinant; determinant is multiplicative) to get `det cartanE8R = 1`
over `ℝ`, then transports that back to `ℤ` via `Int.cast_det` and `exact_mod_cast`.
`cartanE8_posDef` is the file's substantial proof — see the inline comments in the body
below for the step-by-step "complete the square along the `LDLᵀ` pivots, then argue a sum
of positive-weighted squares vanishes only when every term does, then back-substitute"
argument.

## Related declarations

`cartanE8_posDef` is not an atlas hub or bridge target itself, but shares several
foundational Mathlib lemmas (`IsStrictOrderedRing.toIsOrderedRing`, `Even.pow_nonneg`,
`PosMulReflectLE.toPosMulReflectLT`, ...) with unrelated positivity arguments elsewhere in
the project — `StringTheory.Frontier.fterm_potential_nonneg`,
`StringTheory.Frontier.poincare_geodesic_kinetic_energy_nonneg`,
`StringTheory.NSMath.energy_dissipation` (atlas "shared foundations"): all are instances
of the same "sum of squares/positive terms is positive unless every term vanishes"
proof pattern, applied to unrelated physical quantities (a flux potential, kinetic energy
along a geodesic, a dissipation rate) — shared proof shape, no shared physics with `E8`.
`cartanE8_det`/`e8_LDL` have no listed atlas relations beyond generic matrix-computation
lemmas (`Matrix.cons_val_succ`, `Finset.sum_const`, ...) also used throughout `E8.lean`
and `Hyperbolic.lean`'s brute-force checks.
-/
import DualScaleStream2.Lattice.E8
import Mathlib.LinearAlgebra.Matrix.PosDef

namespace DualScaleStream2.Lattice

open Matrix

/-- Unit lower-triangular `LDLᵀ` factor of `cartanE8` (Gaussian elimination with no
pivoting needed, since all pivots turn out positive). Produced outside Lean (sympy); only
`e8_LDL` below gives it any certified meaning. -/
noncomputable def e8L : Matrix (Fin 8) (Fin 8) ℝ :=
  !![1, 0, 0, 0, 0, 0, 0, 0;
     -1/2, 1, 0, 0, 0, 0, 0, 0;
     0, -2/3, 1, 0, 0, 0, 0, 0;
     0, 0, -3/4, 1, 0, 0, 0, 0;
     0, 0, 0, -4/5, 1, 0, 0, 0;
     0, 0, 0, 0, -5/6, 1, 0, 0;
     0, 0, 0, 0, 0, -6/7, 1, 0;
     0, 0, 0, 0, -5/6, -5/7, -5/8, 1]

/-- The `LDLᵀ` pivots, all strictly positive — this is the numerical fact that will
certify positive-definiteness once `e8_LDL` is checked. Their product is exactly `1`
(used in `cartanE8_det`). -/
noncomputable def e8D : Matrix (Fin 8) (Fin 8) ℝ :=
  Matrix.diagonal ![2, 3/2, 4/3, 5/4, 6/5, 7/6, 8/7, 1/8]

/-- `cartanE8`, cast entrywise from `ℤ` to `ℝ`, so that real linear-algebra facts
(determinants of real triangular matrices, positive-definiteness) can be applied to it. -/
noncomputable def cartanE8R : Matrix (Fin 8) (Fin 8) ℝ := cartanE8.map (Int.cast : ℤ → ℝ)

/-- **The `LDLᵀ` certificate.** `e8L`, `e8D` really do factor `cartanE8R` — this is what
upgrades the sympy-produced `e8L`/`e8D` from "claimed" to "kernel-checked", exactly as
`cartanE8Inv_mul` does for the integer inverse in `E8.lean`. -/
theorem e8_LDL : e8L * e8D * e8Lᵀ = cartanE8R := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [e8L, e8D, cartanE8R, cartanE8, Matrix.mul_apply, Matrix.transpose_apply,
      Matrix.vecMul_diagonal, Fin.sum_univ_succ] <;> ring

/-- `det E8 = 1` exactly (the product of the pivots), as an *integer* fact about
`cartanE8`, even though the proof passes through the real factorization `e8_LDL`.
Proof idea: a triangular matrix's determinant is the product of its diagonal, which is
`1` for both unit-triangular factors `e8L`, `e8Lᵀ`; the pivot diagonal `e8D` has
determinant `2 · 3/2 · 4/3 ⋯ 1/8 = 1` (telescoping product); multiplicativity of `det`
across `e8L * e8D * e8Lᵀ` then gives `det cartanE8R = 1` over `ℝ`, which is cast back
down to the integer statement about `cartanE8`. -/
theorem cartanE8_det : cartanE8.det = 1 := by
  -- `e8Lᵀ` is upper triangular (since `e8L` is lower triangular by construction).
  have hUtri : e8Lᵀ.IsUpperTriangular := by
    intro i j hij
    simp only [Matrix.transpose_apply]
    fin_cases i <;> fin_cases j <;> simp_all [e8L]
  -- determinant of a triangular matrix = product of its diagonal entries, which are all `1`
  -- for `e8Lᵀ` (unit triangular).
  have hLTdet : e8Lᵀ.det = 1 := by
    rw [Matrix.det_of_isUpperTriangular hUtri]
    simp [Matrix.transpose_apply, e8L, Fin.prod_univ_succ]
  -- transpose doesn't change the determinant, so `e8L` also has determinant `1`.
  have hLdet : e8L.det = 1 := (Matrix.det_transpose e8L).symm.trans hLTdet
  -- `e8D` is diagonal, so its determinant is the (telescoping) product of the pivots,
  -- which is exactly `1`.
  have hDdet : e8D.det = 1 := by
    rw [e8D, Matrix.det_diagonal]
    simp [Fin.prod_univ_succ]
    norm_num
  -- assemble via multiplicativity of `det` across the `LDLᵀ` factorization.
  have hR : cartanE8R.det = 1 := by
    rw [← e8_LDL, Matrix.det_mul, Matrix.det_mul, hLdet, hDdet, hLTdet]
    ring
  -- transport the real-valued determinant fact back down to the integer statement.
  have hcast : (cartanE8.det : ℝ) = cartanE8R.det := Int.cast_det cartanE8
  rw [hR] at hcast
  exact_mod_cast hcast

/-- **`E8` is positive definite.** A theorem about this one fixed `8 × 8` real matrix
`cartanE8R` (not about "all rank-8 even unimodular lattices" or any other generality):
`xᵀ · cartanE8R · x > 0` for every nonzero real vector `x`. Combined with
`cartanE8_symm`/`cartanE8_evenDiag`/`cartanE8_det` this is what licenses reading `E8` as
positive definite of signature `(8,0)`, and hence `E8(−1)` as negative definite — the
Tier A input `K3T2Signature.sigE8Neg = (0,8)` relies on.

Proof idea: the `LDLᵀ` factorization `e8_LDL` says the quadratic form equals a weighted
sum of squares `Σᵢ (pivot)ᵢ · yᵢ²` in new coordinates `y` obtained from `x` by the same
elimination steps as the factorization (this is literally "completing the square" along
the pivots computed in `E8.lean`/above). Since every pivot is strictly positive, this sum
is nonnegative, and it can vanish only if every `yᵢ` vanishes; back-substituting through
the (invertible, unit-triangular) change of variables `y ↦ x` then forces `x = 0`,
contradicting `x ≠ 0`. -/
theorem cartanE8_posDef : cartanE8R.PosDef := by
  have hHerm : cartanE8R.IsHermitian :=
    isHermitian_iff_isSymm.mpr (Matrix.IsSymm.map cartanE8_symm (Int.cast : ℤ → ℝ))
  refine Matrix.PosDef.of_dotProduct_mulVec_pos hHerm ?_
  intro x hx
  simp [Pi.star_apply, star_trivial, dotProduct, Matrix.mulVec, cartanE8R, cartanE8,
    Fin.sum_univ_succ]
  -- `y0, ..., y7` are exactly the `LDLᵀ` elimination variables: `yᵢ` is `xᵢ` corrected by
  -- the pivot-row multiples of the later coordinates, in the same order `e8L` encodes.
  set y0 := x 0 - x 1 / 2 with hy0def
  set y1 := x 1 - 2 * x 2 / 3 with hy1def
  set y2 := x 2 - 3 * x 3 / 4 with hy2def
  set y3 := x 3 - 4 * x 4 / 5 with hy3def
  set y4 := x 4 - 5 * x 5 / 6 - 5 * x 7 / 6 with hy4def
  set y5 := x 5 - 6 * x 6 / 7 - 5 * x 7 / 7 with hy5def
  set y6 := x 6 - 5 * x 7 / 8 with hy6def
  set y7 := x 7 with hy7def
  -- the quadratic form `xᵀ cartanE8 x`, rewritten purely algebraically (`ring`, using
  -- only the `set` definitions above), equals the pivot-weighted sum of squares —
  -- this is the `LDLᵀ` identity `e8_LDL` transported into coordinate form.
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
  -- it suffices to show the sum-of-squares form is positive (`hqeq` then transfers this
  -- to the original quadratic form via `linarith`).
  suffices h : (0:ℝ) < 2 * y0 ^ 2 + (3 / 2) * y1 ^ 2 + (4 / 3) * y2 ^ 2 + (5 / 4) * y3 ^ 2 +
      (6 / 5) * y4 ^ 2 + (7 / 6) * y5 ^ 2 + (8 / 7) * y6 ^ 2 + (1 / 8) * y7 ^ 2 by
    linarith [hqeq]
  -- suppose instead it is `≤ 0`; since it is manifestly a sum of nonneg terms
  -- (`positivity`), that forces it to be exactly `0`.
  by_contra hle
  push_neg at hle
  have hnn : (0:ℝ) ≤ 2 * y0 ^ 2 + (3 / 2) * y1 ^ 2 + (4 / 3) * y2 ^ 2 + (5 / 4) * y3 ^ 2 +
      (6 / 5) * y4 ^ 2 + (7 / 6) * y5 ^ 2 + (8 / 7) * y6 ^ 2 + (1 / 8) * y7 ^ 2 := by positivity
  have hz := le_antisymm hle hnn
  -- a sum of nonnegative terms is `0` only if every term is `0` — extract each `yᵢ² = 0`
  -- in turn (each of the 8 identical `linarith` calls isolates one term using the
  -- nonnegativity of all the others together with the total being `0`).
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
  -- a real square is `0` only if the number itself is `0`.
  have hy0z : y0 = 0 := sq_eq_zero_iff.mp e0
  have hy1z : y1 = 0 := sq_eq_zero_iff.mp e1
  have hy2z : y2 = 0 := sq_eq_zero_iff.mp e2
  have hy3z : y3 = 0 := sq_eq_zero_iff.mp e3
  have hy4z : y4 = 0 := sq_eq_zero_iff.mp e4
  have hy5z : y5 = 0 := sq_eq_zero_iff.mp e5
  have hy6z : y6 = 0 := sq_eq_zero_iff.mp e6
  have hy7z : y7 = 0 := sq_eq_zero_iff.mp e7
  -- climb back up the pivot chain (reverse of the elimination order used to define the
  -- `yᵢ`): `y7 = x7` gives `x7 = 0` directly, then each `yᵢ = 0` combined with the
  -- already-known vanishing of the later coordinates it depends on gives `xᵢ = 0`.
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
  -- all 8 coordinates of `x` vanish, contradicting the standing hypothesis `hx : x ≠ 0`.
  apply hx
  funext i
  fin_cases i <;> simp_all

end DualScaleStream2.Lattice
