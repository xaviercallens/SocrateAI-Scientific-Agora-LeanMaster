/-
Stream 4 · P4.3 completed — the twined series at every conjugacy class of `M₂₄`.

`Twining.lean` treated the four classes whose correction term `F_g` is a multiple of a single `Λ_N`.
This file treats the remaining sixteen columns of Cheng–Duncan–Harvey's Table 20. Their `F_g` need
eta quotients, several `Λ_d`, the newforms `f₁₁, f₁₄, f₁₅, f₂₃,ₐ, f₂₃,ᵦ`, and the rational prefactors
`2/5, 1/3, 1/4, 1/3, 1/11`.

### Sources (Tier L; `papers/foundations/1204_2779.txt`, Cheng–Duncan–Harvey)
* eq. (4.18), ll. 2931–2936: `H_g⁽²⁾ = (χ_g/24) H⁽²⁾ + F_g/η³`.
* Table 3, ll. 2882–2910: the forms `F_g`. For `12A` the exponent of `η(τ)` is displaced in the
  flattened text (the `3` stands on the next line, l. 2901); the value `3` was inferred from the weight
  (`F_g` has weight 2, so the exponents sum to 4) and is confirmed by `twined_12A`.
* eq. (A.3), ll. 4100–4104: `Λ_N` (already used via `lambda24`); eqs. (A.4)–(A.6), ll. 4115–4123:
  `f₁₁ = η(τ)²η(11τ)²`, `f₁₄ = η(τ)η(2τ)η(7τ)η(14τ)`, `f₁₅ = η(τ)η(3τ)η(5τ)η(15τ)`; eq. (A.8),
  ll. 4134–4137: `f₂₃,ₐ`, `f₂₃,ᵦ`, with the printed normalisations `f₂₃,ₐ = q + O(q³)`,
  `f₂₃,ᵦ = q² + O(q³)` (checked as `f23_normalisation`).
* Table 14, ll. 4349–4362: `χ_g`.
* Table 20, ll. 4494–4506: the printed coefficients (columns `2B … 23AB`, `q^{-1/8}` through `q^{71/8}`).

### Method
An eta quotient `Π η(kτ)^{e_k}` is `q^{Σ k e_k / 24}` times the power series `Π (1 − q^{kn})^{e_k}`;
every quotient used here has `Σ k e_k ≡ 0 (mod 24)` (`etaShift_exact`), so the shift is an integer
power of `q`. To stay in `ℤ` with a prefactor `1/D`, the file computes `24·D·H_g =
(D·χ_g·numer + 24·D·F_g)/η³` and compares with `24·D` times the printed column.

### What is proved (Tier A)
For each of the sixteen classes: the computed series equals the printed column through `q⁹`
(`twined_2B … twined_23AB`); its coefficients are divisible by `24·D` (`twinedAll_div`). Negative
controls: dropping the newform breaks `11A` and `23AB`; the `14AB` data do not give the `15AB` column.

### What is not proved
That these series are mock modular, that the `F_g` are modular forms for `Γ₀(N_g)`, or anything past
`q⁹`. The group-theoretic side for all classes is `CharactersAll.lean`.
-/
import DualScaleMoonshine.Twining

namespace DualScaleMoonshine

/-- `Π_{n ≥ 1} (1 − q^{kn})^e`, truncated at `q^N`. -/
def etaPow (N k e : ℕ) : List ℤ :=
  (List.range (N / k)).foldl (fun acc i =>
    (List.range e).foldl (fun a _ => mulTrunc N a (oneMinusQ N (k * (i + 1)))) acc) (oneMinusQ N 0)

/-- Product of `etaPow` over a list of `(k, e)`. -/
def etaProd (N : ℕ) (fs : List (ℕ × ℕ)) : List ℤ :=
  fs.foldl (fun a f => mulTrunc N a (etaPow N f.1 f.2)) (oneMinusQ N 0)

/-- `Σ k·e` over a list of `(k, e)`: 24 times the power of `q` carried by the eta product. -/
def etaWeight (fs : List (ℕ × ℕ)) : ℕ := (fs.map fun f => f.1 * f.2).sum

/-- The eta quotient `Π_{num} η(kτ)^e / Π_{den} η(kτ)^e` as a power series truncated at `q^N`,
including its shift `q^{(Σ_num k e − Σ_den k e)/24}`. -/
def etaQ (N : ℕ) (num den : List (ℕ × ℕ)) : List ℤ :=
  let s := (etaWeight num - etaWeight den) / 24
  List.replicate s 0 ++ (divTrunc N (etaProd N num) (etaProd N den)).take (N + 1 - s)

/-- Coefficientwise sum and scalar multiple of truncated series. -/
def addS (a b : List ℤ) : List ℤ := List.zipWith (· + ·) a b
def scS (c : ℤ) (a : List ℤ) : List ℤ := a.map (c * ·)

/-- Newforms of CDH Appendix A, truncated at `q⁹`. -/
def f11 : List ℤ := etaQ 9 [(1, 2), (11, 2)] []
def f14 : List ℤ := etaQ 9 [(1, 1), (2, 1), (7, 1), (14, 1)] []
def f15 : List ℤ := etaQ 9 [(1, 1), (3, 1), (5, 1), (15, 1)] []
def f23a : List ℤ :=
  addS (addS (etaQ 9 [(1, 3), (23, 3)] [(2, 1), (46, 1)]) (scS 3 (etaQ 9 [(1, 2), (23, 2)] [])))
    (addS (scS 4 (etaQ 9 [(1, 1), (2, 1), (23, 1), (46, 1)] [])) (scS 4 (etaQ 9 [(2, 2), (46, 2)] [])))
def f23b : List ℤ := etaQ 9 [(1, 2), (23, 2)] []

/-- Every eta quotient used in this file carries an integer power of `q` (and a non-negative one). -/
theorem etaShift_exact :
    ([([(1, 2), (11, 2)], []), ([(1, 1), (2, 1), (7, 1), (14, 1)], []),
      ([(1, 1), (3, 1), (5, 1), (15, 1)], []), ([(1, 3), (23, 3)], [(2, 1), (46, 1)]),
      ([(1, 2), (23, 2)], []), ([(1, 1), (2, 1), (23, 1), (46, 1)], []), ([(2, 2), (46, 2)], []),
      ([(1, 8)], [(2, 4)]), ([(1, 6)], [(3, 2)]), ([(2, 8)], [(4, 4)]), ([(1, 4), (2, 2)], [(4, 2)]),
      ([(1, 2), (2, 2), (3, 2)], [(6, 2)]), ([(1, 3), (2, 1), (5, 1)], [(10, 1)]),
      ([(1, 3), (4, 2), (6, 3)], [(2, 1), (3, 1), (12, 2)]), ([(1, 4), (4, 1), (6, 1)], [(2, 1), (12, 1)]),
      ([(1, 3), (7, 3)], [(3, 1), (21, 1)])] : List (List (ℕ × ℕ) × List (ℕ × ℕ))).all
      fun p => etaWeight p.2 ≤ etaWeight p.1 ∧ (etaWeight p.1 - etaWeight p.2) % 24 = 0 := by decide

/-- The printed normalisations of CDH (A.8): `f₂₃,ₐ = q + O(q³)`, `f₂₃,ᵦ = q² + O(q³)`; and
`f₁₁ = q − 2q² − …`. -/
theorem f23_normalisation :
    f23a.take 3 = [0, 1, 0] ∧ f23b.take 3 = [0, 0, 1] ∧ f11.take 3 = [0, 1, -2] := by decide

/-- `24·D·F_g` for the sixteen classes of this file (CDH Table 3), as `(D, χ_g, 24·D·F_g)`. -/
def dataF2B  : ℕ × ℤ × List ℤ := (1, 0, addS (lambda24 9 2 24) (lambda24 9 4 (-8)))
def dataF3B  : ℕ × ℤ × List ℤ := (1, 0, scS (-48) (etaQ 9 [(1, 6)] [(3, 2)]))
def dataF4A  : ℕ × ℤ × List ℤ :=
  (1, 0, addS (addS (lambda24 9 2 (-4)) (lambda24 9 4 6)) (lambda24 9 8 (-2)))
def dataF4B  : ℕ × ℤ × List ℤ := (1, 4, addS (lambda24 9 2 4) (lambda24 9 4 (-4)))
def dataF4C  : ℕ × ℤ × List ℤ := (1, 0, scS (-48) (etaQ 9 [(1, 4), (2, 2)] [(4, 2)]))
def dataF6A  : ℕ × ℤ × List ℤ :=
  (1, 2, addS (addS (lambda24 9 2 2) (lambda24 9 3 2)) (lambda24 9 6 (-2)))
def dataF6B  : ℕ × ℤ × List ℤ := (1, 0, scS (-48) (etaQ 9 [(1, 2), (2, 2), (3, 2)] [(6, 2)]))
def dataF8A  : ℕ × ℤ × List ℤ := (1, 2, addS (lambda24 9 4 1) (lambda24 9 8 (-1)))
def dataF10A : ℕ × ℤ × List ℤ := (1, 0, scS (-48) (etaQ 9 [(1, 3), (2, 1), (5, 1)] [(10, 1)]))
/-- `F_11A = (2/5)(−Λ₁₁ + 11 f₁₁)`, so `24·5·F = −2·(24Λ₁₁) + 2·11·24·f₁₁`. -/
def dataF11A : ℕ × ℤ × List ℤ := (5, 2, addS (lambda24 9 11 (-2)) (scS 528 f11))
def dataF12A : ℕ × ℤ × List ℤ :=
  (1, 0, scS (-48) (etaQ 9 [(1, 3), (4, 2), (6, 3)] [(2, 1), (3, 1), (12, 2)]))
def dataF12B : ℕ × ℤ × List ℤ := (1, 0, scS (-48) (etaQ 9 [(1, 4), (4, 1), (6, 1)] [(2, 1), (12, 1)]))
/-- `F_14AB = (1/3)(Λ₂ + Λ₇ − Λ₁₄ + 14 f₁₄)`. -/
def dataF14AB : ℕ × ℤ × List ℤ :=
  (3, 1, addS (addS (addS (lambda24 9 2 1) (lambda24 9 7 1)) (lambda24 9 14 (-1))) (scS 336 f14))
/-- `F_15AB = (1/4)(Λ₃ + Λ₅ − Λ₁₅ + 15 f₁₅)`. -/
def dataF15AB : ℕ × ℤ × List ℤ :=
  (4, 1, addS (addS (addS (lambda24 9 3 1) (lambda24 9 5 1)) (lambda24 9 15 (-1))) (scS 360 f15))
/-- `F_21AB = (1/3)(−7η(τ)³η(7τ)³/(η(3τ)η(21τ)) + η(τ)⁶/η(3τ)²)`. -/
def dataF21AB : ℕ × ℤ × List ℤ :=
  (3, 0, addS (scS (-168) (etaQ 9 [(1, 3), (7, 3)] [(3, 1), (21, 1)])) (scS 24 (etaQ 9 [(1, 6)] [(3, 2)])))
/-- `F_23AB = (1/11)(−Λ₂₃ + 23 f₂₃,ₐ + 69 f₂₃,ᵦ)`. -/
def dataF23AB : ℕ × ℤ × List ℤ :=
  (11, 1, addS (addS (lambda24 9 23 (-1)) (scS 552 f23a)) (scS 1656 f23b))

/-- `24·D·q^{1/8}H_g = (D·χ_g·numer + 24·D·F_g)/η³`, truncated at `q⁹`. -/
def twinedD (d : ℕ × ℤ × List ℤ) : List ℤ :=
  divTrunc 9 (addS (scS ((d.1 : ℤ) * d.2.1) (numer 9)) d.2.2) (eta3 9)

/-- CDH Table 20, `q^{-1/8}` through `q^{71/8}`. -/
def table2B  : List ℤ := [-2, 10, -18, 20, -38, 72, -90, 118, -180, 258]
def table3B  : List ℤ := [-2, 6, 0, -14, 12, 0, -16, 30, 0, -42]
def table4A  : List ℤ := [-2, -6, -2, 4, -6, -8, 6, 6, -4, -14]
def table4B  : List ℤ := [-2, 2, -2, -4, 2, 8, -2, -10, 4, 10]
def table4C  : List ℤ := [-2, 2, 6, -4, -6, 0, 6, -2, -12, 10]
def table6A  : List ℤ := [-2, 0, 2, 2, 0, -2, -4, 0, 2, 2]
def table6B  : List ℤ := [-2, -2, 0, 2, 4, 0, 0, -2, 0, 6]
def table8A  : List ℤ := [-2, -2, -2, 0, -2, 0, 2, -2, 0, -2]
def table10A : List ℤ := [-2, 0, 2, 0, 2, 2, 0, -2, 0, -2]
def table11A : List ℤ := [-2, 2, 0, 0, 0, -2, 0, -2, 2, 0]
def table12A : List ℤ := [-2, 0, -2, -2, 0, -2, 0, 0, 2, -2]
def table12B : List ℤ := [-2, 2, 0, 2, 0, 0, 0, -2, 0, -2]
def table14AB : List ℤ := [-2, 1, 0, 0, 0, 0, 2, 2, -1, 0]
def table15AB : List ℤ := [-2, 0, -1, 0, 0, 2, 0, 0, 0, 2]
def table21AB : List ℤ := [-2, -1, 0, 0, -2, 0, -2, 2, 0, 0]
def table23AB : List ℤ := [-2, -2, 2, -1, 0, 0, 0, 0, 0, 0]

/-- The table, scaled as the computed series: `24·D·t`. -/
def scaled (d : ℕ × ℤ × List ℤ) (t : List ℤ) : List ℤ := scS (24 * d.1) t

theorem twined_2B  : twinedD dataF2B  = scaled dataF2B  table2B  := by decide
theorem twined_3B  : twinedD dataF3B  = scaled dataF3B  table3B  := by decide
theorem twined_4A  : twinedD dataF4A  = scaled dataF4A  table4A  := by decide
theorem twined_4B  : twinedD dataF4B  = scaled dataF4B  table4B  := by decide
theorem twined_4C  : twinedD dataF4C  = scaled dataF4C  table4C  := by decide
theorem twined_6A  : twinedD dataF6A  = scaled dataF6A  table6A  := by decide
theorem twined_6B  : twinedD dataF6B  = scaled dataF6B  table6B  := by decide
theorem twined_8A  : twinedD dataF8A  = scaled dataF8A  table8A  := by decide
theorem twined_10A : twinedD dataF10A = scaled dataF10A table10A := by decide
/-- `11A`: needs the newform `f₁₁` and the prefactor `2/5`. -/
theorem twined_11A : twinedD dataF11A = scaled dataF11A table11A := by decide
/-- `12A`: confirms the exponent `3` on `η(τ)` inferred from the weight. -/
theorem twined_12A : twinedD dataF12A = scaled dataF12A table12A := by decide
theorem twined_12B : twinedD dataF12B = scaled dataF12B table12B := by decide
theorem twined_14AB : twinedD dataF14AB = scaled dataF14AB table14AB := by decide
theorem twined_15AB : twinedD dataF15AB = scaled dataF15AB table15AB := by decide
theorem twined_21AB : twinedD dataF21AB = scaled dataF21AB table21AB := by decide
/-- `23AB`: needs both newforms `f₂₃,ₐ`, `f₂₃,ᵦ` and the prefactor `1/11`. -/
theorem twined_23AB : twinedD dataF23AB = scaled dataF23AB table23AB := by decide

/-- Every coefficient of `24·D·H_g` is divisible by `24·D`, so the quotients used downstream
(`CharactersAll`, `ForgerTest`) are exact. -/
theorem twinedAll_div :
    [dataF2B, dataF3B, dataF4A, dataF4B, dataF4C, dataF6A, dataF6B, dataF8A, dataF10A, dataF11A,
      dataF12A, dataF12B, dataF14AB, dataF15AB, dataF21AB, dataF23AB].all
      fun d => (twinedD d).all (· % (24 * d.1 : ℤ) = 0) := by decide

/-- CDH Table 3 prints two forms twice, as a `Λ`-combination and as an eta quotient:
`24Λ₂ − 8Λ₄ = −2η(τ)⁸/η(2τ)⁴` (`2B`) and `−4Λ₂ + 6Λ₄ − 2Λ₈ = −2η(2τ)⁸/η(4τ)⁴` (`4A`). The two
readings agree through `q⁹` (a finite check of the printed identities, not a proof of them). -/
theorem eta_lambda_agree_2B : dataF2B.2.2 = scS (-48) (etaQ 9 [(1, 8)] [(2, 4)]) := by decide
theorem eta_lambda_agree_4A : dataF4A.2.2 = scS (-48) (etaQ 9 [(2, 8)] [(4, 4)]) := by decide

/-- **Negative control.** Without the newform, `11A` fails: `F_11A` is not a multiple of `Λ₁₁`. -/
theorem twined_11A_needs_newform :
    twinedD (5, 2, lambda24 9 11 (-2)) ≠ scaled dataF11A table11A := by decide

/-- **Negative control.** Without the newforms, `23AB` fails. -/
theorem twined_23AB_needs_newforms :
    twinedD (11, 1, lambda24 9 23 (-1)) ≠ scaled dataF23AB table23AB := by decide

/-- **Negative control.** With exponent `2` instead of `3` on `η(τ)`, the computed series differs from
the `12A` column. (That quotient has weight `3/2` and `Σ k e = −1`, so it is not a weight-2 form at
all; `etaQ` then applies no shift.) -/
theorem twined_12A_exponent_matters :
    twinedD (1, 0, scS (-48) (etaQ 9 [(1, 2), (4, 2), (6, 3)] [(2, 1), (3, 1), (12, 2)])) ≠
      scaled dataF12A table12A := by decide

/-- **Negative control.** The `14AB` data do not reproduce the `15AB` column. -/
theorem twined_14AB_ne_table15AB : twinedD dataF14AB ≠ scaled dataF14AB table15AB := by decide

end DualScaleMoonshine
