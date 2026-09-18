/-
Stream 4 addendum (added with Stream 5, P5.7) — the `M₂₄`-modules `K_n` for `n ≤ 9`, decomposed.

`CharactersAll.trace_eq_twined_coeff_all` matched traces and twined coefficients at levels 1–7, where
Eguchi–Ooguri–Tachikawa give a decomposition. Levels 8 and 9 were left open. Here the direction is
reversed: from the **computed** twined series `H_g` (all 26 classes, `TwiningAll`), the multiplicity of
each irreducible `χ_i` in the virtual module `K_n` is `⟨T_n, χ_i⟩ = |M₂₄|⁻¹ Σ_g |g^G| T_n(g) χ̄_i(g)`, with
`T_n(g)` the coefficient of `q^{n−1/8}` in `H_g`. The theorem is that these inner products are integers,
non-negative for `n ≥ 1`, and equal to Cheng–Duncan–Harvey's printed decomposition.

### Sources (Tier L)
* CDH (`1204_2779.txt`) Table 48, ll. 5305–5330 ("Decomposition of `K₁⁽²⁾`"), rows `8n − 1 = −1, 7, …, 71`,
  columns `χ₁ … χ₂₆` in CDH's order (converted to this repository's `M24RepDim` order, which swaps
  `5544` and `5796`).
* Cheng (`1005_5415.txt`) ll. 533–549: EOT's original proposal `30843 = 10395 + 2·5796 + 5544 + 3312` for
  `n = 7` is inconsistent with the twined series; `30843 = 10395 + 5796 + 5544 + 5313 + 2024 + 1771` is.

### What is proved (Tier A)
* `moonshine_modules_decompose`: for `n = 0 … 9`, `⟨T_n, χ_i⟩` has vanishing irrational parts, is an
  integer, and equals CDH Table 48 — so the computed twined series at levels 8 and 9 are characters of
  genuine `M₂₄`-modules (multiplicities `≥ 0`), e.g. `K₈ = 990 ⊕ 9̅9̅0̅ ⊕ 1035′ ⊕ 1035″ ⊕ 2·1265 ⊕ …`.
* `eot_level7_proposal_inconsistent`: the class function of `10395 + 2·5796 + 5544 + 3312` (doubled)
  differs from the computed `T₇` (Cheng's observation, checked).

### Not proved
That these modules come from a vertex algebra or a K3 sigma model (Gannon's theorem, Tier L, gives the
existence of the modules; this file checks the first ten graded pieces).
-/
import DualScaleMoonshine.CharactersAll

namespace DualScaleMoonshine

/-- `|M₂₄|·⟨T_n, χ_i⟩`, with `T_n(g)` the computed coefficient of `q^{n−1/8}` in `H_g`. -/
def moonshineInner (n i : ℕ) : ℤ × ℤ × ℤ × ℤ :=
  inner4 ((List.range 26).map fun j => ((computedSeries.getD j []).getD n 0, 0)) (charTab.getD i [])

/-- CDH Table 48, rows `8n − 1` for `n = 0 … 9`, in `M24RepDim` order. -/
def table48 : List (List ℤ) :=
  [[-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2],
   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 2, 2, 2, 2],
   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 2, 0, 0, 2, 2, 2, 4, 2, 2, 6],
   [0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 2, 2, 2, 0, 2, 2, 2, 4, 4, 4, 8, 8, 10]]

/-- **The first ten graded pieces of the Mathieu moonshine module, from computed data.** For
`n = 0 … 9` every multiplicity is an integer (irrational parts vanish) and equals CDH Table 48; in
particular levels 8 and 9, which EOT do not decompose, are genuine `M₂₄`-modules. -/
theorem moonshine_modules_decompose :
    (List.range 10).all (fun n => (List.range 26).all fun i =>
      let v := moonshineInner n i
      v.2.1 == 0 && v.2.2.1 == 0 && v.2.2.2 == 0 && v.1 == 244823040 * ((table48.getD n []).getD i 0)) = true := by
  decide +kernel

/-- Multiplicities are non-negative from level 1 on (level 0 is the virtual `−2·1`). -/
theorem moonshine_multiplicities_nonneg :
    (table48.drop 1).all (fun row => row.all (0 ≤ ·)) = true := by decide

/-- **Cheng's observation**: EOT's proposed `K₇ = 10395 + 2·5796 + 5544 + 3312` (doubled, as `eotMult`)
does not reproduce the computed `T₇` at some class. -/
theorem eot_level7_proposal_inconsistent :
    ((List.range 26).map fun j =>
      traceQ j ((List.range 26).map fun i =>
        if i = 25 then 2 else if i = 23 then 4 else if i = 24 then 2 else if i = 20 then 2 else 0)) ≠
    (List.range 26).map fun j => ((computedSeries.getD j []).getD 7 0, 0) := by decide +kernel

end DualScaleMoonshine
