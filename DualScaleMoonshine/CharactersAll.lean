/-
Stream 4 · P4.3b completed — the group side at every conjugacy class of `M₂₄`.

`Characters.lean` used the three rational columns `1A, 2A, 3A`. This file uses the whole character
table, including the irrational values `b₇ = (−1+√−7)/2`, `b₁₅ = (−1+√−15)/2`, `b₂₃ = (−1+√−23)/2`,
and proves that for **every** class `g` and levels 1–7, the trace of `g` on EOT's representation
equals the coefficient of the twined series computed from modular data in `Twining.lean` and
`TwiningAll.lean`.

### Arithmetic in `ℤ[b_n]`
A value `a + b·ω` with `ω = b_n` is stored as `(a, b) : ℤ × ℤ`; `ω² = −ω − k` with `k = (n+1)/4`
(`k = 2, 4, 6` for `n = 7, 15, 23`), and `ω̄ = −1 − ω`. Each column of the table lives in one ring
(`colK`). An inner product of two rows is a sum over classes of values in `ℤ`, `ℤ[b₇]`, `ℤ[b₁₅]`,
`ℤ[b₂₃]`; it is accumulated as `(rational part, ω₇-part, ω₁₅-part, ω₂₃-part)`. Since `1, √−7, √−15,
√−23` are linearly independent over `ℚ` (standard; Tier L for this step of interpretation), the sum
equals the integer `m` exactly when the tuple is `(m, 0, 0, 0)`.

### Source (Tier L) and what the guards certify
Cheng–Duncan–Harvey, `1204_2779.txt`, Table 8, ll. 4170–4209 (GAP4 output). The flattened
`pdftotext` loses the overlines: `b₇` and `b̄₇` both print as `b7`. The reading used here puts `b_n`
on the first row of each complex-conjugate pair and in the first column of each algebraically
conjugate pair of classes where the table prints `b7`, `b15`, `b23`. The guards below (Tier A) are:
`charTab_col1A` (the `1A` column is `M24RepDim`), agreement with `chi2A`, `chi3A`; column norms equal
to the centralizer orders `cent`, each divisible by the element order and dividing `|M₂₄|`; the class
equation `Σ |M₂₄|/|C(g)| = |M₂₄|`; and **full row orthogonality** (`gram_ok`).

These guards pin the reading only up to relabelling. An exhaustive search over the ten independent
overline choices (Python, not a kernel proof) found 128 readings that pass orthogonality, and they are
exactly the orbit of this reading under renaming classes (`7A ↔ 7B`, `14A ↔ 14B`, `21A ↔ 21B`,
`15A ↔ 15B`, `23A ↔ 23B`) and characters (`45 ↔ 4̅5̅`, …). All 128 give the same traces. The control
`misread_fails_gram` shows that orthogonality does reject a reading outside that orbit.

### What is proved (Tier A)
* `trace_eq_twined_coeff_all`: for every class `g` (26 columns) and level `n = 1…7`, twice the trace
  of `g` on EOT's representation at level `n` is a rational integer (the `ω`-part vanishes) and equals
  the coefficient of `q^{n−1/8}` in the **computed** `H_g`.
* `trace_pairs_equal`: `7A, 7B` (and `14A/B, 15A/B, 21A/B, 23A/B`) have equal traces at levels 1–7,
  which is why a single column `7AB` of Table 20 serves both.
* `ratio_fails_at_every_class`: the ratio form of paper 7's "27720 lock" fails at all 25 non-identity
  classes (P4.5 extended from 4 classes to all).

### What is not proved
Levels 8–9 (EOT give no decomposition); the existence of an `M₂₄`-module with these graded traces
(Gannon, Tier L); that the table is the character table of `M₂₄` (Tier L, GAP4 via CDH) — the guards
are consistency checks that a character table must pass, not a construction of `M₂₄`.
-/
import DualScaleMoonshine.Characters
import DualScaleMoonshine.TwiningAll
import DualScaleMoonshine.ForgerTest

namespace DualScaleMoonshine

/-- Multiplication in `ℤ[ω]`, `ω² = −ω − k`. -/
def qmul (k : ℤ) (x y : ℤ × ℤ) : ℤ × ℤ :=
  (x.1 * y.1 - k * x.2 * y.2, x.1 * y.2 + x.2 * y.1 - x.2 * y.2)

/-- Complex conjugation, `ω̄ = −1 − ω`. -/
def qconj (x : ℤ × ℤ) : ℤ × ℤ := (x.1 - x.2, -x.2)

/-- Sanity: `b₇² = −b₇ − 2` and `b₇ + b̄₇ = −1`, `b₇·b̄₇ = 2`. -/
theorem qmul_sanity :
    qmul 2 (0, 1) (0, 1) = (-2, -1) ∧ qconj (0, 1) = (-1, -1) ∧ qmul 2 (0, 1) (qconj (0, 1)) = (2, 0) := by
  decide

/-- The classes, in CDH Table 8's column order. -/
def classNames : List String :=
  ["1A", "2A", "2B", "3A", "3B", "4A", "4B", "4C", "5A", "6A", "6B", "7A", "7B", "8A", "10A", "11A",
    "12A", "12B", "14A", "14B", "15A", "15B", "21A", "21B", "23A", "23B"]

/-- Element orders of the classes. -/
def classOrder : List ℤ :=
  [1, 2, 2, 3, 3, 4, 4, 4, 5, 6, 6, 7, 7, 8, 10, 11, 12, 12, 14, 14, 15, 15, 21, 21, 23, 23]

/-- The ring of each column: `k = 0` (rational), `2` (`ℤ[b₇]`), `4` (`ℤ[b₁₅]`), `6` (`ℤ[b₂₃]`). -/
def colK : List ℤ :=
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 2, 2, 4, 4, 2, 2, 6, 6]

/-- The character table of `M₂₄` (CDH Table 8), rows in this repository's `M24RepDim` order,
entries `(a, b) = a + b·b_n` with `n` given by `colK`. -/
def charTab : List (List (ℤ × ℤ)) := [
  [(1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0)],
  [(23, 0), (7, 0), (-1, 0), (5, 0), (-1, 0), (-1, 0), (3, 0), (-1, 0), (3, 0), (1, 0), (-1, 0), (2, 0), (2, 0), (1, 0), (-1, 0), (1, 0), (-1, 0), (-1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (-1, 0), (-1, 0), (0, 0), (0, 0)],
  [(45, 0), (-3, 0), (5, 0), (0, 0), (3, 0), (-3, 0), (1, 0), (1, 0), (0, 0), (0, 0), (-1, 0), (0, 1), (-1, -1), (-1, 0), (0, 0), (1, 0), (0, 0), (1, 0), (0, -1), (1, 1), (0, 0), (0, 0), (0, 1), (-1, -1), (-1, 0), (-1, 0)],
  [(45, 0), (-3, 0), (5, 0), (0, 0), (3, 0), (-3, 0), (1, 0), (1, 0), (0, 0), (0, 0), (-1, 0), (-1, -1), (0, 1), (-1, 0), (0, 0), (1, 0), (0, 0), (1, 0), (1, 1), (0, -1), (0, 0), (0, 0), (-1, -1), (0, 1), (-1, 0), (-1, 0)],
  [(231, 0), (7, 0), (-9, 0), (-3, 0), (0, 0), (-1, 0), (-1, 0), (3, 0), (1, 0), (1, 0), (0, 0), (0, 0), (0, 0), (-1, 0), (1, 0), (0, 0), (-1, 0), (0, 0), (0, 0), (0, 0), (0, 1), (-1, -1), (0, 0), (0, 0), (1, 0), (1, 0)],
  [(231, 0), (7, 0), (-9, 0), (-3, 0), (0, 0), (-1, 0), (-1, 0), (3, 0), (1, 0), (1, 0), (0, 0), (0, 0), (0, 0), (-1, 0), (1, 0), (0, 0), (-1, 0), (0, 0), (0, 0), (0, 0), (-1, -1), (0, 1), (0, 0), (0, 0), (1, 0), (1, 0)],
  [(252, 0), (28, 0), (12, 0), (9, 0), (0, 0), (4, 0), (4, 0), (0, 0), (2, 0), (1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (2, 0), (-1, 0), (1, 0), (0, 0), (0, 0), (0, 0), (-1, 0), (-1, 0), (0, 0), (0, 0), (-1, 0), (-1, 0)],
  [(253, 0), (13, 0), (-11, 0), (10, 0), (1, 0), (-3, 0), (1, 0), (1, 0), (3, 0), (-2, 0), (1, 0), (1, 0), (1, 0), (-1, 0), (-1, 0), (0, 0), (0, 0), (1, 0), (-1, 0), (-1, 0), (0, 0), (0, 0), (1, 0), (1, 0), (0, 0), (0, 0)],
  [(483, 0), (35, 0), (3, 0), (6, 0), (0, 0), (3, 0), (3, 0), (3, 0), (-2, 0), (2, 0), (0, 0), (0, 0), (0, 0), (-1, 0), (-2, 0), (-1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (1, 0), (1, 0), (0, 0), (0, 0), (0, 0), (0, 0)],
  [(770, 0), (-14, 0), (10, 0), (5, 0), (-7, 0), (2, 0), (-2, 0), (-2, 0), (0, 0), (1, 0), (1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (-1, 0), (1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 1), (-1, -1)],
  [(770, 0), (-14, 0), (10, 0), (5, 0), (-7, 0), (2, 0), (-2, 0), (-2, 0), (0, 0), (1, 0), (1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (-1, 0), (1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (-1, -1), (0, 1)],
  [(990, 0), (-18, 0), (-10, 0), (0, 0), (3, 0), (6, 0), (2, 0), (-2, 0), (0, 0), (0, 0), (-1, 0), (0, 1), (-1, -1), (0, 0), (0, 0), (0, 0), (0, 0), (1, 0), (0, 1), (-1, -1), (0, 0), (0, 0), (0, 1), (-1, -1), (1, 0), (1, 0)],
  [(990, 0), (-18, 0), (-10, 0), (0, 0), (3, 0), (6, 0), (2, 0), (-2, 0), (0, 0), (0, 0), (-1, 0), (-1, -1), (0, 1), (0, 0), (0, 0), (0, 0), (0, 0), (1, 0), (-1, -1), (0, 1), (0, 0), (0, 0), (-1, -1), (0, 1), (1, 0), (1, 0)],
  [(1035, 0), (27, 0), (35, 0), (0, 0), (6, 0), (3, 0), (-1, 0), (3, 0), (0, 0), (0, 0), (2, 0), (-1, 0), (-1, 0), (1, 0), (0, 0), (1, 0), (0, 0), (0, 0), (-1, 0), (-1, 0), (0, 0), (0, 0), (-1, 0), (-1, 0), (0, 0), (0, 0)],
  [(1035, 0), (-21, 0), (-5, 0), (0, 0), (-3, 0), (3, 0), (3, 0), (-1, 0), (0, 0), (0, 0), (1, 0), (0, 2), (-2, -2), (-1, 0), (0, 0), (1, 0), (0, 0), (-1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, -1), (1, 1), (0, 0), (0, 0)],
  [(1035, 0), (-21, 0), (-5, 0), (0, 0), (-3, 0), (3, 0), (3, 0), (-1, 0), (0, 0), (0, 0), (1, 0), (-2, -2), (0, 2), (-1, 0), (0, 0), (1, 0), (0, 0), (-1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (1, 1), (0, -1), (0, 0), (0, 0)],
  [(1265, 0), (49, 0), (-15, 0), (5, 0), (8, 0), (-7, 0), (1, 0), (-3, 0), (0, 0), (1, 0), (0, 0), (-2, 0), (-2, 0), (1, 0), (0, 0), (0, 0), (-1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (1, 0), (1, 0), (0, 0), (0, 0)],
  [(1771, 0), (-21, 0), (11, 0), (16, 0), (7, 0), (3, 0), (-5, 0), (-1, 0), (1, 0), (0, 0), (-1, 0), (0, 0), (0, 0), (-1, 0), (1, 0), (0, 0), (0, 0), (-1, 0), (0, 0), (0, 0), (1, 0), (1, 0), (0, 0), (0, 0), (0, 0), (0, 0)],
  [(2024, 0), (8, 0), (24, 0), (-1, 0), (8, 0), (8, 0), (0, 0), (0, 0), (-1, 0), (-1, 0), (0, 0), (1, 0), (1, 0), (0, 0), (-1, 0), (0, 0), (-1, 0), (0, 0), (1, 0), (1, 0), (-1, 0), (-1, 0), (1, 0), (1, 0), (0, 0), (0, 0)],
  [(2277, 0), (21, 0), (-19, 0), (0, 0), (6, 0), (-3, 0), (1, 0), (-3, 0), (-3, 0), (0, 0), (2, 0), (2, 0), (2, 0), (-1, 0), (1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (-1, 0), (-1, 0), (0, 0), (0, 0)],
  [(3312, 0), (48, 0), (16, 0), (0, 0), (-6, 0), (0, 0), (0, 0), (0, 0), (-3, 0), (0, 0), (-2, 0), (1, 0), (1, 0), (0, 0), (1, 0), (1, 0), (0, 0), (0, 0), (-1, 0), (-1, 0), (0, 0), (0, 0), (1, 0), (1, 0), (0, 0), (0, 0)],
  [(3520, 0), (64, 0), (0, 0), (10, 0), (-8, 0), (0, 0), (0, 0), (0, 0), (0, 0), (-2, 0), (0, 0), (-1, 0), (-1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (1, 0), (1, 0), (0, 0), (0, 0), (-1, 0), (-1, 0), (1, 0), (1, 0)],
  [(5313, 0), (49, 0), (9, 0), (-15, 0), (0, 0), (1, 0), (-3, 0), (-3, 0), (3, 0), (1, 0), (0, 0), (0, 0), (0, 0), (-1, 0), (-1, 0), (0, 0), (1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0)],
  [(5796, 0), (-28, 0), (36, 0), (-9, 0), (0, 0), (-4, 0), (4, 0), (0, 0), (1, 0), (-1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (1, 0), (-1, 0), (-1, 0), (0, 0), (0, 0), (0, 0), (1, 0), (1, 0), (0, 0), (0, 0), (0, 0), (0, 0)],
  [(5544, 0), (-56, 0), (24, 0), (9, 0), (0, 0), (-8, 0), (0, 0), (0, 0), (-1, 0), (1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (-1, 0), (0, 0), (1, 0), (0, 0), (0, 0), (0, 0), (-1, 0), (-1, 0), (0, 0), (0, 0), (1, 0), (1, 0)],
  [(10395, 0), (-21, 0), (-45, 0), (0, 0), (0, 0), (3, 0), (-1, 0), (3, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (1, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (-1, 0), (-1, 0)]]

/-- Column `j` of the table. -/
def charCol (j : ℕ) : List (ℤ × ℤ) := charTab.map fun r => r.getD j (0, 0)

/-! ### Guards on the transcription -/

theorem charTab_shape : charTab.length = 26 ∧ charTab.all (·.length = 26) := by decide

/-- The `1A`, `2A`, `3A` columns agree with `Characters.lean` (and so `1A` with `M24RepDim`). -/
theorem charTab_col1A : charCol 0 = chi1A.map (·, 0) := by decide
theorem charTab_col2A : charCol 1 = chi2A.map (·, 0) := by decide
theorem charTab_col3A : charCol 3 = chi3A.map (·, 0) := by decide

/-- Rational columns carry no `ω`-part. -/
theorem rational_cols :
    (List.range 26).all fun j => colK.getD j 0 ≠ 0 || (charCol j).all (·.2 = 0) := by decide

/-- `|χ(g)|²` summed over the irreducibles (second orthogonality relation: the centralizer order). -/
def colNorm (j : ℕ) : ℤ × ℤ :=
  (charCol j).foldl (fun acc x => let p := qmul (colK.getD j 0) x (qconj x); (acc.1 + p.1, acc.2 + p.2))
    (0, 0)

/-- Centralizer orders, as the column norms of the table give them. -/
def cent : List ℤ :=
  [244823040, 21504, 7680, 1080, 504, 384, 128, 96, 60, 24, 24, 42, 42, 16, 20, 11, 12, 12, 14, 14,
    15, 15, 21, 21, 23, 23]

theorem colNorm_eq_cent : (List.range 26).map colNorm = cent.map (·, 0) := by decide

/-- Each centralizer order divides `|M₂₄|` and is divisible by the element order. -/
theorem cent_divides :
    (List.range 26).all fun j =>
      244823040 % cent.getD j 1 = 0 ∧ cent.getD j 1 % classOrder.getD j 1 = 0 := by decide

/-- Class sizes `|M₂₄|/|C(g)|`. -/
def classSize : List ℤ := cent.map (244823040 / ·)

/-- **Class equation**: the class sizes add up to `|M₂₄| = 244823040`. -/
theorem class_equation : classSize.sum = 244823040 := by decide

/-- `Σ_g |g^G| · χ(g) · ψ̄(g)`, split as (rational part, `ω₇`, `ω₁₅`, `ω₂₃` parts). -/
def inner4 (r s : List (ℤ × ℤ)) : ℤ × ℤ × ℤ × ℤ :=
  (List.range 26).foldl (fun acc j =>
    let k := colK.getD j 0
    let c := classSize.getD j 0
    let p := qmul k (r.getD j (0, 0)) (qconj (s.getD j (0, 0)))
    (acc.1 + c * p.1, acc.2.1 + (if k = 2 then c * p.2 else 0),
      acc.2.2.1 + (if k = 4 then c * p.2 else 0), acc.2.2.2 + (if k = 6 then c * p.2 else 0)))
    (0, 0, 0, 0)

/-- Row orthogonality of a candidate table: `⟨χ_i, χ_j⟩ = δ_ij`, i.e. the sum is `|M₂₄|·δ_ij`. -/
def gramOK (t : List (List (ℤ × ℤ))) : Bool :=
  (List.range 26).all fun i => (List.range 26).all fun j =>
    inner4 (t.getD i []) (t.getD j []) = (if i = j then 244823040 else 0, 0, 0, 0)

/-- **First orthogonality relation**, all `26 × 26` pairs, irrational columns included. -/
theorem gram_ok : gramOK charTab = true := by decide

/-- **Negative control.** Reading `χ(14A)` and `χ(14B)` of the pair `45, 4̅5̅` the other way round (a
reading outside the relabelling orbit) violates orthogonality: the guard does discriminate. -/
theorem misread_fails_gram :
    gramOK (charTab.set 2 (((charTab.getD 2 []).set 18 (1, 1)).set 19 (0, -1)) |>.set 3
      (((charTab.getD 3 []).set 18 (0, -1)).set 19 (1, 1))) = false := by decide

/-! ### Traces = computed twined coefficients, at every class -/

/-- Normalise a computed `24·D·H_g` (exact by `twined_div24`, `twinedAll_div`). -/
def normS (d : ℕ × ℤ × List ℤ) : List ℤ := (twinedD d).map (· / (24 * d.1 : ℤ))
def normT (s : List ℤ) : List ℤ := s.map (· / 24)

/-- The **computed** series `q^{1/8}H_g`, one per column of Table 8 (so `7A` and `7B` share one). -/
def computedSeries : List (List ℤ) :=
  let s7 := normT (twined24 9 3 7 (-1))
  let s14 := normS dataF14AB
  let s15 := normS dataF15AB
  let s21 := normS dataF21AB
  let s23 := normS dataF23AB
  [normT (twined24 9 24 1 0), normT (twined24 9 8 2 (-16)), normS dataF2B, normT (twined24 9 6 3 (-6)),
    normS dataF3B, normS dataF4A, normS dataF4B, normS dataF4C, normT (twined24 9 4 5 (-2)),
    normS dataF6A, normS dataF6B, s7, s7, normS dataF8A, normS dataF10A, normS dataF11A,
    normS dataF12A, normS dataF12B, s14, s14, s15, s15, s21, s21, s23, s23]

/-- `Σ_i m_i · χ_i(g_j)` in `ℤ[b_n]`. -/
def traceQ (j : ℕ) (m : List ℤ) : ℤ × ℤ :=
  (List.zipWith (fun c x => (c * x.1, c * x.2)) m (charCol j)).foldl
    (fun acc p => (acc.1 + p.1, acc.2 + p.2)) (0, 0)

/-- **Mathieu moonshine at every class, levels 1–7.** For each of the 26 classes `g`, the trace of
`g` on EOT's representation (doubled, as in `eotMult`) is a rational integer and equals the
coefficient of the twined series computed from modular data. -/
theorem trace_eq_twined_coeff_all :
    ∀ j : Fin 26, eotMult.map (traceQ j) = (((computedSeries.getD j []).drop 1).take 7).map (·, 0) := by
  decide

/-- Algebraically conjugate classes have equal traces at levels 1–7. -/
theorem trace_pairs_equal :
    [(11, 12), (18, 19), (20, 21), (22, 23), (24, 25)].all
      fun p => eotMult.map (traceQ p.1) = eotMult.map (traceQ p.2) := by decide

/-- **Negative control.** Swapping the `7A` and `23A` series breaks the match: the agreement is
class by class. -/
theorem trace_7A_ne_series_23A :
    eotMult.map (traceQ 11) ≠ (((computedSeries.getD 24 []).drop 1).take 7).map (·, 0) := by decide

/-! ### The forger's test at every class (P4.5 extended) -/

/-- The ratio form of paper 7's lock fails at every one of the 25 non-identity classes, not only at
`2A, 3A, 5A, 7AB`. -/
theorem ratio_fails_at_every_class :
    ∀ j : Fin 26, j.val ≠ 0 → ¬ ratioTwines ((computedSeries.getD j []).map (24 * ·)) := by
  decide

end DualScaleMoonshine
