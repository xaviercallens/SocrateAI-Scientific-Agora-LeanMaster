/-
Stream 4 · P4.2 — the Mathieu-moonshine coefficients, computed rather than typed.

Until now this repository's moonshine check compared one typed-in table (`eotA`, the coefficients
`A₁ … A₉` of Eguchi–Ooguri–Tachikawa) with another (`M24RepDim`). This file **computes** the
coefficients from a closed formula and proves the result equals the table.

### Sources (Tier L; files in `papers/foundations/`)
* Cheng–Harrison, `1406_0619.txt`, eq. (3.5)–(3.6), ll. 800–813:
  `H⁽²⁾(τ) = (−2E₂(τ) + 48F₂⁽²⁾(τ)) / η(τ)³ = 2q^{−1/8}(−1 + 45q + 231q² + 770q³ + O(q⁴))`, with
  `F₂⁽²⁾(τ) = Σ_{r>s>0, r−s odd} (−1)^r s q^{rs/2} = q + q² − q³ + q⁴ + …`.
* Harvey–Murthy–Nazaroglu, `1410_6174.txt`, eq. (2.37), l. 736: `E₂ = 1 − 24 Σ σ₁(n) qⁿ`.
* Cheng–Duncan–Harvey, `1204_2779.txt`, App. A.1, ll. 4020–4027: `η(τ) = q^{1/24} Π (1 − qⁿ)`.

### What is computed
Power series are truncated lists of integers (degrees `0…N`). `eta3 N` is `Π_{n≤N}(1−qⁿ)³`, i.e.
`η³/q^{1/8}`, from the product definition — *not* from Jacobi's identity, which is instead checked
as a theorem (`eta3_jacobi`). `numer N` is `−2E₂ + 48F₂`. `hComputed N` is their truncated quotient,
i.e. `q^{1/8}H⁽²⁾`. Everything is decided by the kernel with `decide`; no compiled-code evaluation is trusted.

### What is proved (Tier A)
* `f2_control` — the first coefficients of `F₂` match the series printed in the source
  (`q + q² − q³ + q⁴`): a check on the transcription of the summation condition.
* `eta3_jacobi` — the product agrees with Jacobi's series `1 − 3q + 5q³ − 7q⁶` through `q⁹`. This
  is a finite check of ten coefficients, **not** a proof of Jacobi's identity.
* `hComputed_eq_table` — **the computed series equals `−2, 2A₁, …, 2A₉` read from `eotA`**, all nine
  coefficients. (Paper 7's convention `𝒜ₙ = 2Aₙ` is this factor 2.)

### What is not proved
That the formula *is* the mock modular form of the K3 elliptic genus (Tier L); anything beyond `q⁹`;
modularity or mock modularity of anything. This is exact arithmetic on a finite truncation.
-/
import DualScaleStream2.Moonshine.EOT

namespace DualScaleMoonshine

open DualScaleStream2.Moonshine

/-- Truncated Cauchy product, degrees `0…N`. -/
def mulTrunc (N : ℕ) (a b : List ℤ) : List ℤ :=
  (List.range (N + 1)).map fun n =>
    ((List.range (n + 1)).map fun k => a.getD k 0 * b.getD (n - k) 0).sum

/-- Truncated quotient `r / p` for a series `p` with constant term `1`. -/
def divTrunc (N : ℕ) (r p : List ℤ) : List ℤ :=
  (List.range (N + 1)).foldl
    (fun acc n =>
      acc ++ [r.getD n 0 - ((List.range n).map fun k => acc.getD k 0 * p.getD (n - k) 0).sum]) []

/-- `1 − qⁿ` truncated (`n = 0` gives the series `1`). -/
def oneMinusQ (N n : ℕ) : List ℤ :=
  (List.range (N + 1)).map fun k => if k = 0 then 1 else if k = n then -1 else 0

/-- `Π_{n=1}^{N} (1 − qⁿ)³` truncated at `q^N`: `η(τ)³ / q^{1/8}`. -/
def eta3 (N : ℕ) : List ℤ :=
  (List.range N).foldl (fun acc i =>
    let f := oneMinusQ N (i + 1)
    mulTrunc N (mulTrunc N (mulTrunc N acc f) f) f) (oneMinusQ N 0)

/-- Divisor sum `σ₁(n)`. -/
def sigma (n : ℕ) : ℤ :=
  (((List.range (n + 1)).filter fun d => 0 < d ∧ n % d = 0).map fun d => (d : ℤ)).sum

/-- Coefficient of `qⁿ` in `F₂⁽²⁾`: sum over `r > s > 0`, `r − s` odd, `rs = 2n`, of `(−1)^r s`. -/
def f2Coeff (n : ℕ) : ℤ :=
  (((List.range (2 * n + 1)).filter fun s =>
      0 < s ∧ (2 * n) % s = 0 ∧ s < 2 * n / s ∧ (2 * n / s - s) % 2 = 1).map
    fun s => if (2 * n / s) % 2 = 0 then (s : ℤ) else -(s : ℤ)).sum

/-- `−2E₂ + 48F₂`: `−2` at `q⁰`, `48(σ₁(n) + F₂(n))` at `qⁿ`. -/
def numer (N : ℕ) : List ℤ :=
  (List.range (N + 1)).map fun n => if n = 0 then -2 else 48 * (sigma n + f2Coeff n)

/-- `q^{1/8} H⁽²⁾(τ)`, computed from the formula. -/
def hComputed (N : ℕ) : List ℤ := divTrunc N (numer N) (eta3 N)

/-- The same series read off EOT's typed-in table: `−2, 2A₁, 2A₂, …, 2A₉`. -/
def hFromTable : List ℤ := (-2) :: (List.ofFn fun i : Fin 9 => 2 * (eotA i : ℤ))

/-- Transcription check: `F₂ = q + q² − q³ + q⁴ + …` as printed in Cheng–Harrison. -/
theorem f2_control : (List.range 5).map f2Coeff = [0, 1, 1, -1, 1] := by decide

/-- Jacobi's series `Σ (−1)ⁿ(2n+1) q^{n(n+1)/2}` agrees with `Π(1−qⁿ)³` through `q⁹` (a check of
ten coefficients, not a proof of the identity). -/
theorem eta3_jacobi : eta3 9 = [1, -3, 0, 5, 0, 0, -7, 0, 0, 0] := by decide

/-- **The coefficients computed from the formula equal EOT's table**, `A₁ … A₉`. -/
theorem hComputed_eq_table : hComputed 9 = hFromTable := by decide

end DualScaleMoonshine
