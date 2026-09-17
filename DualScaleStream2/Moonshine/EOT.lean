/-
Stream 2 · P2.6 — Mathieu moonshine coefficients of the K3 elliptic genus.

Source (Tier L): Eguchi, Ooguri, Tachikawa, *Notes on the K3 Surface and the Mathieu group
M24*, arXiv:1004.0956 (`papers/foundations/eguchi_ooguri_tachikawa_1004_0956.txt`):
* eq. (1.12), line 208: `A_n = 45, 231, 770, 2277, 5796, 13915, 30843, 65550, 132825`;
* lines 227–233: "the first 5 coefficients, A1, ..., A5, are equal to dimensions of
  irreducible representations of M24", and eqs. (1.14)–(1.15):
  `A6 = 3520 + 10395`, `A7 = 10395 + 5796 + 5544 + 5313 + 2024 + 1771`;
* eq. (A.3), lines 346–349: the 26 irreducible dimensions.
The *meaning* (the elliptic genus actually carries an `M₂₄` action) is Tier L / the moonshine
conjecture-then-theorem; not claimed here.

Tier A here: the arithmetic content of the observation, checked against Stream 1's
`MathieuM24.M24RepDim` table (itself Burnside-checked against `|M₂₄|`): each of `A₁…A₅` is
an entry of the table, and `A₆`, `A₇` equal the stated sums of table entries.
-/
import StringTheoryFormalization.StringDynamics.MathieuM24

namespace DualScaleStream2.Moonshine

open StringTheory.StringDynamics

/-- EOT eq. (1.12): `A₁, …, A₉`. -/
def eotA : Fin 9 → ℕ := ![45, 231, 770, 2277, 5796, 13915, 30843, 65550, 132825]

/-- `A₁ … A₅` are each the dimension of an irreducible representation of `M₂₄`. -/
theorem first_five_are_irreps :
    ∀ n : Fin 5, ∃ i : Fin 26, M24RepDim i = eotA (Fin.castLE (by norm_num) n) := by
  intro n
  -- Witnesses: A₁ = 45 (index 2), A₂ = 231 (4), A₃ = 770 (9), A₄ = 2277 (19), A₅ = 5796 (23).
  fin_cases n
  · exact ⟨2, rfl⟩
  · exact ⟨4, rfl⟩
  · exact ⟨9, rfl⟩
  · exact ⟨19, rfl⟩
  · exact ⟨23, rfl⟩

/-- EOT eq. (1.14): `A₆ = 3520 + 10395`, both irreducible dimensions (indices 21, 25). -/
theorem A6_decomposition :
    eotA 5 = M24RepDim 21 + M24RepDim 25 := rfl

/-- EOT eq. (1.15): `A₇ = 10395 + 5796 + 5544 + 5313 + 2024 + 1771`. -/
theorem A7_decomposition :
    eotA 6 = M24RepDim 25 + M24RepDim 23 + M24RepDim 24 + M24RepDim 22 +
      M24RepDim 18 + M24RepDim 17 := rfl

/-- `A₆` is *not* a single irreducible dimension (so a decomposition is genuinely needed). -/
theorem A6_not_irrep : ∀ i : Fin 26, M24RepDim i ≠ eotA 5 := by
  intro i
  fin_cases i <;> simp [eotA, M24RepDim]
  <;> decide
  <;> aesop

end DualScaleStream2.Moonshine
