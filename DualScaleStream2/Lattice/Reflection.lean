/-
Stream 2 · P2.3 — Reflections in `(−2)`-vectors are lattice isometries.

Sources (Tier L), Huybrechts, *Lectures on K3 Surfaces*
(`papers/foundations/huybrechts_K3Global.txt`):
* Ch. 7 §5.4 (lines 6031–6043): `s_δ(v) = v − 2 (v.δ)/(δ)² · δ`, which for `(δ)² = −2` is
  `v + (v.δ) δ` — the form used below — and elements of `O(Λ)` are written as products of
  reflections `s_{δᵢ}` with `(δᵢ)² = −2`;
* Ch. 6 (line 5400): for a degeneration smoothing an `A₁`-singularity "the monodromy T is the
  reflection s_δ with δ the cohomology class corresponding to the exceptional (−2)-curve"
  (Picard–Lefschetz).
That the simple reflections generate the Weyl group of `E8` is standard (Tier L, not
proved here).

Tier A here, any rank `n`, integer lattice with symmetric Gram matrix `L`:
* with `s_v = 1 + v vᵀ L`, the orchestrator verified symbolically (sympy, generic rank 3) that
  `s_vᵀ L s_v − L = (2 + vᵀLv) · L v vᵀ L` and `s_v² − 1 = (2 + vᵀLv) · v vᵀ L`;
  so for `vᵀ L v = −2`, `s_v` is an isometry of `L` and an involution;
* in `E8(−1)` every simple root `eᵢ` has norm `−2`, so each simple reflection is an
  isometry of `E8(−1)` — the Weyl reflections of the `E8(−1)` summand of the K3 lattice.
-/
import DualScaleStream2.Lattice.E8

namespace DualScaleStream2.Lattice

open Matrix

variable {n : ℕ}

/-- Reflection matrix `s_v = 1 + v vᵀ L` (so `s_v x = x + ⟨x, v⟩ v` with `⟨x, v⟩ = vᵀ L x`). -/
def reflection (L : Gram n) (v : Fin n → ℤ) : Gram n :=
  1 + vecMulVec v v * L

/-- Norm of `v` in the lattice. -/
def latticeNorm (L : Gram n) (v : Fin n → ℤ) : ℤ := v ⬝ᵥ (L *ᵥ v)

/-- **Key identity**: `v vᵀ L v vᵀ = (vᵀLv) • v vᵀ` as matrices, for any Gram matrix `L`
(no symmetry needed — both sides expand to `v i * (vᵀ L v) * v j`). -/
theorem vecMulVec_mul_self (L : Gram n) (v : Fin n → ℤ) :
    vecMulVec v v * L * vecMulVec v v = (latticeNorm L v) • vecMulVec v v := by
  unfold latticeNorm
  rw [vecMulVec_mul, vecMulVec_mul_vecMulVec, ← dotProduct_mulVec, vecMulVec_smul]

/-- **Isometry** for a `(−2)`-vector. -/
theorem reflection_isometry (L : Gram n) (hL : Lᵀ = L) (v : Fin n → ℤ)
    (hv : latticeNorm L v = -2) :
    (reflection L v)ᵀ * L * reflection L v = L := by
  have key := vecMulVec_mul_self L v
  have hPP : vecMulVec v v * L * (vecMulVec v v * L) = (-2 : ℤ) • (vecMulVec v v * L) := by
    rw [← mul_assoc, key, hv, smul_mul_assoc]
  have hT : (reflection L v)ᵀ = 1 + L * vecMulVec v v := by
    unfold reflection
    rw [transpose_add, transpose_one, transpose_mul, transpose_vecMulVec, hL]
  rw [hT]
  unfold reflection
  have expand : (1 + L * vecMulVec v v) * L * (1 + vecMulVec v v * L)
      = L + L * (vecMulVec v v * L) + L * (vecMulVec v v * L)
        + L * (vecMulVec v v * L * (vecMulVec v v * L)) := by
    noncomm_ring
  rw [expand, hPP, mul_smul_comm]
  abel

/-- **Involution** for a `(−2)`-vector. -/
theorem reflection_involution (L : Gram n) (v : Fin n → ℤ) (hv : latticeNorm L v = -2) :
    reflection L v * reflection L v = 1 := by
  have key := vecMulVec_mul_self L v
  have hPP : vecMulVec v v * L * (vecMulVec v v * L) = (-2 : ℤ) • (vecMulVec v v * L) := by
    rw [← mul_assoc, key, hv, smul_mul_assoc]
  show (1 + vecMulVec v v * L) * (1 + vecMulVec v v * L) = 1
  simp only [add_mul, mul_add, one_mul, mul_one, hPP]
  abel

/-- Each simple root of `E8(−1)` has norm `−2`. -/
theorem e8Neg_simpleRoot_norm (i : Fin 8) : latticeNorm e8Neg (Pi.single i 1) = -2 := by
  fin_cases i <;>
    simp [latticeNorm, Matrix.mulVec, dotProduct, e8Neg, cartanE8, Pi.single_apply]

/-- The simple Weyl reflections are isometries of `E8(−1)`. -/
theorem e8Neg_weyl_isometry (i : Fin 8) :
    (reflection e8Neg (Pi.single i 1))ᵀ * e8Neg * reflection e8Neg (Pi.single i 1) = e8Neg :=
  reflection_isometry e8Neg e8Neg_symm _ (e8Neg_simpleRoot_norm i)

end DualScaleStream2.Lattice
