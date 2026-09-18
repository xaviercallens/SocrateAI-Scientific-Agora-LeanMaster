/-
Stream 4 · P4.3a — twined series: the test that separates moonshine from numerology.

A numerical coincidence `45 = 45` proves little. The historical test of genuine moonshine is
*twining*: replace the dimension by the trace of a group element `g`, and ask whether the resulting
series is again a distinguished function. This file computes the twined series of Mathieu moonshine
from their formula and compares them with the coefficients printed in the literature.

### Sources (Tier L; `papers/foundations/1204_2779.txt`, Cheng–Duncan–Harvey)
* eq. (4.18), ll. 2931–2936: `H_g⁽²⁾ = (χ_g/24) H⁽²⁾ + F_g/η³`, with `χ⁽²⁾ = 24`.
* Table 3, ll. 2882–2915: `F_2A = −16Λ₂`, `F_3A = −6Λ₃`, `F_5A = −2Λ₅`, `F_7AB = −Λ₇`.
* eq. (A.3), ll. 4100–4104: `Λ_N = N(N−1)/24 · (1 + 24/(N−1) · Σ_k σ(k)(q^k − N q^{Nk}))`.
* Table 14, ll. 4349–4362: `χ_g = 24, 8, 6, 4, 3` for `1A, 2A, 3A, 5A, 7AB`.
* Table 20, ll. 4494–4512: the printed coefficients of `H_g` (columns `2A, 3A, 5A, 7AB`).

### What is computed and proved (Tier A)
To stay in `ℤ`, the file computes `24·H_g = (χ_g · numer + 24·F_g)/η³`. For each of the four classes:
* the result is divisible by 24 coefficient by coefficient (`twined_div24`; not obvious from the
  formula), and
* the quotient equals the printed column of CDH Table 20 through `q⁹`
  (`twined_2A`, `twined_3A`, `twined_5A`, `twined_7AB`).
The four columns were read from a flattened `pdftotext` table; a misread column would make the
corresponding theorem fail, so the theorems also certify the transcription.

### What is not proved
That these series are mock modular, or that an `M₂₄`-module with these graded traces exists (Gannon's
theorem, Tier L). `Characters.lean` checks the group-theoretic side for `2A` and `3A`.
-/
import DualScaleMoonshine.QSeries

namespace DualScaleMoonshine

/-- `24·c·Λ_N` truncated, from CDH (A.3): constant term `c·N(N−1)`, then
`24·c·N·(σ(n) − N·σ(n/N))` (second term only when `N ∣ n`). -/
def lambda24 (N Nlev : ℕ) (c : ℤ) : List ℤ :=
  (List.range (N + 1)).map fun n =>
    if n = 0 then c * (Nlev * (Nlev - 1) : ℤ)
    else c * 24 * Nlev * (sigma n - (if n % Nlev = 0 then (Nlev : ℤ) * sigma (n / Nlev) else 0))

/-- `24 · q^{1/8} H_g`, from CDH (4.18) with `F_g = c·Λ_N`. -/
def twined24 (N : ℕ) (chi : ℤ) (Nlev : ℕ) (c : ℤ) : List ℤ :=
  divTrunc N (List.zipWith (· + ·) ((numer N).map (chi * ·)) (lambda24 N Nlev c)) (eta3 N)

/-- CDH Table 20, column 2A. -/
def table2A : List ℤ := [-2, -6, 14, -28, 42, -56, 86, -138, 188, -238]
/-- CDH Table 20, column 3A. -/
def table3A : List ℤ := [-2, 0, -6, 10, 0, -18, 20, 0, -30, 42]
/-- CDH Table 20, column 5A. -/
def table5A : List ℤ := [-2, 0, 2, 0, -6, 2, 0, 6, 0, -10]
/-- CDH Table 20, column 7AB. -/
def table7AB : List ℤ := [-2, -1, 0, 0, 4, 0, -2, 2, -3, 0]

/-- Every coefficient of `24·H_g` is divisible by 24, so the integer quotients used downstream
(`ForgerTest.coeff`, `Characters`) are exact, not truncated. -/
theorem twined_div24 :
    (twined24 9 8 2 (-16)).all (· % 24 = 0) ∧ (twined24 9 6 3 (-6)).all (· % 24 = 0) ∧
    (twined24 9 4 5 (-2)).all (· % 24 = 0) ∧ (twined24 9 3 7 (-1)).all (· % 24 = 0) ∧
    (twined24 9 24 1 0).all (· % 24 = 0) := by decide

/-- Sanity: with `χ = 24` and `F = 0` the twined series is the untwined one. -/
theorem twined_1A : twined24 9 24 1 0 = (hComputed 9).map (24 * ·) := by decide

theorem twined_2A : twined24 9 8 2 (-16) = table2A.map (24 * ·) := by decide
theorem twined_3A : twined24 9 6 3 (-6) = table3A.map (24 * ·) := by decide
theorem twined_5A : twined24 9 4 5 (-2) = table5A.map (24 * ·) := by decide
theorem twined_7AB : twined24 9 3 7 (-1) = table7AB.map (24 * ·) := by decide

/-- **Negative control.** Without the correction `F_g/η³` the formula does not reproduce the table:
`H_2A ≠ (χ_2A/24)·H`. So `twined_2A` is not an artefact of rescaling the untwined series. -/
theorem twined_2A_needs_F : twined24 9 8 1 0 ≠ table2A.map (24 * ·) := by decide

/-- **Negative control.** The `3A` data do not reproduce the `2A` column. -/
theorem twined_3A_ne_table2A : twined24 9 6 3 (-6) ≠ table2A.map (24 * ·) := by decide

end DualScaleMoonshine
