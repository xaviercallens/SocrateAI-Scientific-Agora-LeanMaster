/-
Stream 4 · P4.3b — the group side: traces of `2A` and `3A` on EOT's representations.

`Twining.lean` computes the twined series from modular data. This file computes the *same numbers*
from group theory — the trace of `g` on the `M₂₄`-representation that Eguchi–Ooguri–Tachikawa attach
to each level — and proves the two agree for levels 1–7 and `g ∈ {2A, 3A}`. Two independent
computations meeting is what "moonshine" means; a table matching a table is not.

### Sources (Tier L)
* Character values: Cheng–Duncan–Harvey, `1204_2779.txt`, Table 8, ll. 4170–4209 (columns `1A`, `2A`,
  `3A`; these three columns are rational integers). The rows are re-ordered to this repository's
  `M24RepDim` ordering, which differs from CDH's in one place (`5796` before `5544`); the theorem
  `chi1A_eq_dim` pins the ordering.
* Decompositions: EOT eqs. (1.14)–(1.15) and the first five levels, as already formalized in
  `DualScaleStream2.Moonshine` (`first_five_are_irreps`, `A6_decomposition`, `A7_decomposition`). For
  levels 1–3 the representation is a complex-conjugate pair (`45 ⊕ 4̅5̅`, …); for level 4 it is
  `2·2277`, for level 5 `2·5796` (paper 8, §7).

### Guards on the transcription (Tier A)
A mistyped character table is exactly how this project's earlier `M₂₄` dimension table went wrong.
So, before any use: `chi1A_eq_dim`; column orthogonality `Σχ(1A)χ(2A) = Σχ(1A)χ(3A) = Σχ(2A)χ(3A) = 0`;
and `Σχ(2A)² = 21504`, `Σχ(3A)² = 1080`, each dividing `|M₂₄|` (they are centralizer orders, by the
second orthogonality relation — Tier L for the interpretation, Tier A for the arithmetic).

### What is proved (Tier A)
`trace_2A_eq_twined_coeff`, `trace_3A_eq_twined_coeff`: for levels 1–7, twice the trace of `g` on EOT's representation equals
the coefficient of the twined series **computed** in `Twining.lean`.

### What is not proved
Levels 8–9 (EOT give no decomposition there); classes other than `2A`, `3A` (irrational character
values need `ℤ[(−1+√−7)/2]` etc.); existence of the module (Gannon, Tier L).
-/
import DualScaleMoonshine.Twining

namespace DualScaleMoonshine

open DualScaleStream2.Moonshine StringTheory.StringDynamics

/-- `χ_i(1A)`, in this repository's `M24RepDim` ordering. -/
def chi1A : List ℤ := [1, 23, 45, 45, 231, 231, 252, 253, 483, 770, 770, 990, 990, 1035, 1035, 1035,
  1265, 1771, 2024, 2277, 3312, 3520, 5313, 5796, 5544, 10395]
/-- `χ_i(2A)` (CDH Table 8). -/
def chi2A : List ℤ := [1, 7, -3, -3, 7, 7, 28, 13, 35, -14, -14, -18, -18, 27, -21, -21,
  49, -21, 8, 21, 48, 64, 49, -28, -56, -21]
/-- `χ_i(3A)` (CDH Table 8). -/
def chi3A : List ℤ := [1, 5, 0, 0, -3, -3, 9, 10, 6, 5, 5, 0, 0, 0, 0, 0,
  5, 16, -1, 0, 0, 10, -15, -9, 9, 0]

def dot (a b : List ℤ) : ℤ := (List.zipWith (· * ·) a b).sum

/-- The `1A` column is this repository's dimension table, in the same order. -/
theorem chi1A_eq_dim : chi1A = List.ofFn fun i : Fin 26 => (M24RepDim i : ℤ) := by decide

theorem orth_1A_2A : dot chi1A chi2A = 0 := by decide
theorem orth_1A_3A : dot chi1A chi3A = 0 := by decide
theorem orth_2A_3A : dot chi2A chi3A = 0 := by decide
theorem norm_1A : dot chi1A chi1A = 244823040 := by decide
theorem norm_2A : dot chi2A chi2A = 21504 ∧ (244823040 : ℤ) % 21504 = 0 := by decide
theorem norm_3A : dot chi3A chi3A = 1080 ∧ (244823040 : ℤ) % 1080 = 0 := by decide

/-- Multiplicities of the 26 irreducibles in EOT's representation at levels 1–7, already doubled
(so that level `n` has dimension `2Aₙ`), in `M24RepDim` ordering. -/
def eotMult : List (List ℤ) :=
  let e (is : List ℕ) : List ℤ := (List.range 26).map fun i => 2 * (is.count i : ℤ)
  [ (List.range 26).map fun i => if i = 2 ∨ i = 3 then 1 else 0,      -- 45 ⊕ 45bar
    (List.range 26).map fun i => if i = 4 ∨ i = 5 then 1 else 0,      -- 231 ⊕ 231bar
    (List.range 26).map fun i => if i = 9 ∨ i = 10 then 1 else 0,     -- 770 ⊕ 770bar
    e [19], e [23], e [21, 25], e [25, 23, 24, 22, 18, 17] ]

/-- The multiplicities reproduce the dimensions `2A₁ … 2A₇` computed in `QSeries.lean`. -/
theorem eotMult_dim : eotMult.map (dot chi1A) = ((hComputed 9).drop 1).take 7 := by decide

/-- **Moonshine at `2A`, levels 1–7**: group-theoretic trace = computed twined coefficient. -/
theorem trace_2A_eq_twined_coeff :
    eotMult.map (dot chi2A) = (((twined24 9 8 2 (-16)).map (· / 24)).drop 1).take 7 := by decide

/-- **Moonshine at `3A`, levels 1–7.** -/
theorem trace_3A_eq_twined_coeff :
    eotMult.map (dot chi3A) = (((twined24 9 6 3 (-6)).map (· / 24)).drop 1).take 7 := by decide

/-- **Negative control.** Traces at `3A` do not match the `2A` series: the agreement in
`trace_2A_eq_twined_coeff` depends on using the right conjugacy class on both sides. -/
theorem trace_3A_ne_twined_2A :
    eotMult.map (dot chi3A) ≠ (((twined24 9 8 2 (-16)).map (· / 24)).drop 1).take 7 := by decide

end DualScaleMoonshine
