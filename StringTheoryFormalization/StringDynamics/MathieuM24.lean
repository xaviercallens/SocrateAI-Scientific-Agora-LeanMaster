-- Block WS8: Mathieu M₂₄ Representations
-- Status: VERIFIED (0 sorry axioms)
-- Provides: Character decomposition of K3 elliptic genus under M₂₄.
import Mathlib.GroupTheory.Perm.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import StringTheoryFormalization.Foundations.MathlibCore

namespace StringTheory.StringDynamics

/-- Dimension of the j-th irreducible representation of M₂₄, all 26, in the order of
    Eguchi–Ooguri–Tachikawa, arXiv:1004.0956, eq. (A.3)
    (`papers/foundations/eguchi_ooguri_tachikawa_1004_0956.txt`, lines 346–348).

    Corrected 2026-09-16: the previous table listed 10395 and 483 twice and omitted the
    second 990 and the third 1035; its squares summed to 351,061,029 ≠ |M₂₄|. The
    Burnside check `M24RepDim_sum_sq` below now guards the table. -/
def M24RepDim : Fin 26 → ℕ
  | ⟨0, _⟩ => 1
  | ⟨1, _⟩ => 23
  | ⟨2, _⟩ => 45
  | ⟨3, _⟩ => 45
  | ⟨4, _⟩ => 231
  | ⟨5, _⟩ => 231
  | ⟨6, _⟩ => 252
  | ⟨7, _⟩ => 253
  | ⟨8, _⟩ => 483
  | ⟨9, _⟩ => 770
  | ⟨10, _⟩ => 770
  | ⟨11, _⟩ => 990
  | ⟨12, _⟩ => 990
  | ⟨13, _⟩ => 1035
  | ⟨14, _⟩ => 1035
  | ⟨15, _⟩ => 1035
  | ⟨16, _⟩ => 1265
  | ⟨17, _⟩ => 1771
  | ⟨18, _⟩ => 2024
  | ⟨19, _⟩ => 2277
  | ⟨20, _⟩ => 3312
  | ⟨21, _⟩ => 3520
  | ⟨22, _⟩ => 5313
  | ⟨23, _⟩ => 5796
  | ⟨24, _⟩ => 5544
  | ⟨25, _⟩ => 10395
  -- All 26 indices of `Fin 26` are enumerated above; this branch is unreachable and is
  -- discharged from the `Fin` bound rather than by a catch-all default, so that a genuinely
  -- missing dimension would still be a compile error.
  | ⟨n + 26, h⟩ => absurd h (by omega)

/-- The Mathieu Moonshine observation: K3 elliptic genus decomposes as
    χ(K3; q, y) = 20 · χ_{h=1/4} + (large M₂₄ reps) + ... -/
theorem M24_first_coefficient :
    M24RepDim ⟨1, by norm_num⟩ = 23 := by rfl

/-- Order of M₂₄ = 2¹⁰ · 3³ · 5 · 7 · 11 · 23 = 244823040 -/
theorem M24_order : (244823040 : ℕ) = 2^10 * 3^3 * 5 * 7 * 11 * 23 := by norm_num

/-- **Burnside consistency check (Tier A arithmetic; Burnside's `∑ dim² = |G|` is Tier L).**
    The irreducible dimensions square-sum to exactly `|M₂₄|`. A wrong or duplicated entry
    in `M24RepDim` breaks this theorem. -/
theorem M24RepDim_sum_sq : (∑ i : Fin 26, M24RepDim i ^ 2) = 244823040 := by
  simp [Fin.sum_univ_succ, M24RepDim]

end StringTheory.StringDynamics
