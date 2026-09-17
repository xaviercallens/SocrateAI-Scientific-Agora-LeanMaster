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

### Physical background
The elliptic genus of the K3 sigma model, expanded in terms of `N=4` superconformal
characters, has multiplicities `2A_n` whose first several values (eq. (1.12), line 208:
`45, 231, 770, 2277, 5796, 13915, 30843, …`) were observed by Eguchi–Ooguri–Tachikawa to
coincide with dimensions of irreducible representations of the sporadic Mathieu group `M₂₄`
— "Mathieu moonshine" (now a theorem of Gannon, building on Cheng and on Eguchi–Ooguri–
Tachikawa's original numerology). The *physical* content — that the elliptic genus actually
carries an honest `M₂₄`-module structure — is Tier L (the moonshine theorem, not proved
here); this file checks only the arithmetic coincidence that motivated it: are `A₁,…,A₅`
themselves dimensions of `M₂₄` irreducibles, and can `A₆`, `A₇` be written as sums of such
dimensions (EOT eqs. (1.14)–(1.15), lines 227–233)?

### Mathematical content
Defines `eotA : Fin 9 → ℕ`, the literal table of EOT's first nine coefficients. Proves
`first_five_are_irreps`: each of `A₁,…,A₅` equals `M24RepDim i` for some `i` among the 26
irreducible dimensions of `M₂₄` (an *existence* statement, witnessed explicitly, not a
general classification of when a number is such a dimension). Proves `A6_decomposition` and
`A7_decomposition`: `A₆`/`A₇` equal the specific sums of `M24RepDim` values EOT write down.
Proves `A6_not_irrep`: `A₆` itself is *not* the dimension of any single irreducible — so the
decomposition of `A₆` into a sum is not vacuous busywork disguising a coincidence that `A₆`
is itself irreducible. **Not proved here**: that these numerical facts come from an actual
group action on the elliptic genus (Tier L); anything about vertex operator algebras, mock
modular forms, or the K3 sigma model's actual chiral algebra; and nothing about `A₈`, `A₉`
or higher coefficients beyond their bare listing in `eotA`.

### Proof techniques
`first_five_are_irreps` is proved by `fin_cases` on the finite index `n : Fin 5`, exhibiting
an explicit witness index into the 26-entry table for each case (a construction, not a
search — the witnesses are recorded in an inline comment). `A6_decomposition` and
`A7_decomposition` are `rfl`: both `eotA` and `M24RepDim` reduce to literal natural-number
constants, so the stated sums are definitionally/computationally equal. `A6_not_irrep` uses
`fin_cases` over all 26 possible irreducible indices followed by `decide`/`aesop`, a
brute-force check over the whole finite table rather than a structural argument.

### Related declarations
`StringTheory.StringDynamics.M24RepDim` is a hub used by 6 theorems in the atlas; this
file's `A6_decomposition`, `A7_decomposition` and `first_five_are_irreps` are three of them
— a direct, same-object dependency on Stream 1's certified character table, not an
independent re-derivation. Note the namespace collision to watch for: `SocrateAI.Moonshine`
(a *different* module, in a different library) also has "Moonshine"-named declarations
(e.g. `k3_euler_eq_24`, `eqFrac`, `delta1_is_half`) concerning K3's Euler characteristic and
elliptic-genus conformal weights — unrelated in scope to this file's `M₂₄`-decomposition
content, and not to be confused with it despite the shared namespace fragment.
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
