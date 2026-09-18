/-
Stream 4 · P4.6 — Harvey–Murthy–Nazaroglu's double-scaled little string theories, reproduced.

HMN (`papers/foundations/1410_6174.txt`) compute the second helicity supertrace `χ₂^Y` — a BPS index —
of the double-scaled little string theory (DSLST) of `k` NS5-branes on K3, labelled by an ADE root
system `Y` with Coxeter number `k` (the lattice of vanishing `(−2)`-cycles). They relate it to umbral
moonshine for the Niemeier root system `X = Y^{24/rk(Y)}`, and observe a divisibility they call
unexplained. This file checks their arithmetic from both sides.

### Sources (Tier L)
* HMN (2.29), (2.36)–(2.37), ll. 745–770: `F₂^{(k,d)} = Σ_{rs=n} s·(d·[kr > d²s] − (k/d)·[d²r > ks]) qⁿ`
  and `χ₂^Y = rk(Y)·E₂ − 24·F₂^Y`, with `F₂^Y` the combination of Table 1 (ll. 596–603):
  `A_{k−1} : (k,1)`; `D_{m/2+1} : (m,1) + (m,m/2)`; `E₆ : (12,1)+(12,4)+(12,6)`;
  `E₇ : (18,1)+(18,6)+(18,9)`; `E₈ : (30,1)+(30,6)+(30,10)+(30,15)`.
  (HMN's (4.2), l. 1190, prints the opposite overall sign; (2.36), the printed series (4.10)–(4.11) and
  the count of `rk(Y)` massless vector multiplets all require the sign used here.)
* HMN (4.5), (4.9), ll. 1219–1262: `χ₂^X = Σ_r H_r^X S_{m,r}`, the first Taylor coefficient at `z = 0`
  of the finite part `ψ^X`, and `χ₂^Y = −(rk(Y)/2)·χ₂^X`.
* HMN (4.10)–(4.11), ll. 1290–1292: the printed series for `Y = A₃` and `Y = A₇`.
* HMN ll. 1280–1292: for umbral `Y` all coefficients of `χ₂^Y` are divisible by `rk(Y)`, "but it is
  not clear why"; for `Y = A₇` they are not.
* CDH (`1204_2779.txt`) (2.49)–(2.51), (2.62), ll. 1258–1285, 1397: the umbral Jacobi forms
  `Z⁽ℓ⁾ = 2φ₁⁽ℓ⁾` for `ℓ = 2, 3, 4, 5, 7, 13`, built from `f_i = θ_i(τ,z)/θ_i(τ,0)`; they belong to
  `X = A_{ℓ−1}^{24/(ℓ−1)}`; `χ⁽ℓ⁾ = Z⁽ℓ⁾(τ,0) = 24/(ℓ−1)`.

### Method for the umbral side
With `a₂ = 4f₂²`, `a₃ = f₃²`, `a₄ = f₄²` (integral series in `t = q^{1/2}`): `Z⁽²⁾ = 2a₂ + 8(a₃+a₄)`,
`Z⁽³⁾ = a₂(a₃+a₄) + 4a₃a₄`, `Z⁽⁴⁾ = 2a₂a₃a₄`, `8Z⁽⁵⁾ = Z⁽⁴⁾Z⁽²⁾ − Z⁽³⁾²`, `2Z⁽⁷⁾ = Z⁽³⁾Z⁽⁵⁾ − Z⁽⁴⁾²`,
`2Z⁽⁹⁾ = Z⁽³⁾Z⁽⁷⁾ − Z⁽⁵⁾²`, `2Z⁽¹³⁾ = Z⁽⁵⁾Z⁽⁹⁾ − 2Z⁽⁷⁾²` (the divisions are checked to be exact).
Then `X := (y−1)ψ^F = (y+1)E²B₂Z/B₁² − χ((y+1) + (y−1)R_ℓ)` as in `Shadow.lean`, with
`R_ℓ = Σ_{k≠0} q^{ℓk²} y^{2ℓk}(q^k y + 1)/(q^k y − 1)`. With `θ = y ∂_y`: `X(1) = 0` says the polar part
removes the pole, and `θψ^F(1) = (θ²X(1) − θX(1))/2`. Since `θ θ̂_r(1) = −2S_{ℓ,r}`,
`χ₂^X = −½ θψ^F(1)`, so (4.9) reads `4χ₂^Y = rk(Y)·θψ^F(1)` with `rk(A_{ℓ−1}) = ℓ − 1`.

### What is proved (Tier A)
* `hmn_A3_printed`, `hmn_A7_printed`: formula (2.36) reproduces the printed (4.10), (4.11).
* `hmn_k2_eq_moonshine`: at `k = 2`, `−2χ₂^{A₁} = η³H = −2E₂ + 48F₂`, the series of `QSeries.lean`
  (Cheng–Harrison), through `q⁹`; `f2kd_k2_eq_f2Coeff`: HMN's sum equals Cheng–Harrison's through `q⁴⁰`.
* `umbral_exact`, `umbral_chi`, `umbral_pole_removed(_13)`, `hmn_umbral_relation_ℓ`: for
  `ℓ = 2, 3, 4, 5, 7, 13`, the umbral forms built from theta functions are integral (the divisions by
  8 and 2 are exact), have `Z(τ,0) = 24/(ℓ−1)`, their polar part removes the pole, and HMN's (4.9)
  holds between the umbral form and the DSLST formula for `Y = A_{ℓ−1}`, all through `q⁶`.
  `hmn_umbral_relation_wrong_Y` is the negative control (`ℓ = 3` against `Y = A₃`).
  The three theorems involving `Z⁽¹³⁾` use `decide +kernel` (the kernel evaluates the decision
  procedure directly, adding no axiom and no compiled evaluation); this file takes about 17 minutes to
  check.
* `divisible_of_dvd_24`: for **every** `Y` and every `n`, `rk(Y) ∣ 24` implies `rk(Y) ∣ [qⁿ]χ₂^Y` —
  all coefficients, not a truncation: `[qⁿ]χ₂^Y = −24(rk(Y)σ(n) + F₂^Y(n))` with `F₂^Y(n) ∈ ℤ`.
* `A_divisible_iff`, `D_divisible_iff`: for every `A_{k−1}` (`k ≥ 2`) and every `D_{j+1}` (`j ≥ 3`),
  all coefficients are divisible by the rank **iff** the rank divides 24; the `q¹` coefficient is the
  witness (`−24(rk+1)` for `A`, `−24(rk−1)` for `D`). With `E₆, E₈` (divisible) and `E₇` (fails at `q¹`;
  `E_divisibility`), the divisible `Y` are exactly HMN's umbral list (4.7):
  `A₁,A₂,A₃,A₄,A₆,A₈,A₁₂,A₂₄,D₄,D₆,D₈,D₁₂,D₂₄,E₆,E₈`.

So, within HMN's own formula, the divisibility they found puzzling has an elementary cause: the
massive coefficients are `24 ×` integers, and `rk(Y)` divides every coefficient exactly when it divides
`24`. Why the factor in (2.36) is 24 is not addressed here (reading it as `χ(K3)` is Tier C).

### What is not proved, and the reflection question
That `χ₂^Y` is a BPS index of the DSLST, the completion and shadow (2.27)–(2.28), and HMN's equality of
(2.36) with the Appell–Lerch form (2.41) (Tier L). P4.6 asked to relate this counting to Stream 2's
`(−2)`-reflections **or show that no such formal relation is available**. It is not available here:
the link runs through the Niemeier lattice `L_X` and its Weyl group `W_X` (`G^X = Aut(L_X)/W_X`, HMN
(1.10)), a rank-24 even unimodular lattice this repository does not formalize; nothing computed above
involves a reflection or a lattice isometry. `rk(Y)` enters only as a number.
-/
import DualScaleMoonshine.Shadow

namespace DualScaleMoonshine

/-! ### HMN's closed formula (2.29), (2.36) -/

/-- Coefficient of `qⁿ` in `F₂^{(k,d)}` (HMN (2.29)), for `d ∣ k`. -/
def f2kd (k d n : ℕ) : ℤ :=
  ((List.range (n + 1)).filter fun r => 0 < r ∧ n % r = 0).foldl (fun acc r =>
    let s := n / r
    acc + (s : ℤ) * ((if d * d * s < k * r then (d : ℤ) else 0) -
      (if k * s < d * d * r then ((k / d : ℕ) : ℤ) else 0))) 0

/-- Coefficient of `qⁿ` in `χ₂^Y = rk·E₂ − 24F₂^Y` (HMN (2.36)); `Ys` lists the `(k, d)` of Table 1. -/
def chi2Y (Ys : List (ℕ × ℕ)) (rk : ℤ) (n : ℕ) : ℤ :=
  if n = 0 then rk else rk * (-24 * sigma n) - 24 * (Ys.map fun p => f2kd p.1 p.2 n).sum

def chi2YSer (Ys : List (ℕ × ℕ)) (rk : ℤ) (N : ℕ) : List ℤ := (List.range (N + 1)).map (chi2Y Ys rk)

/-- HMN Table 1. -/
def yA (k : ℕ) : List (ℕ × ℕ) := [(k, 1)]
def yD (j : ℕ) : List (ℕ × ℕ) := [(2 * j, 1), (2 * j, j)]
def yE6 : List (ℕ × ℕ) := [(12, 1), (12, 4), (12, 6)]
def yE7 : List (ℕ × ℕ) := [(18, 1), (18, 6), (18, 9)]
def yE8 : List (ℕ × ℕ) := [(30, 1), (30, 6), (30, 10), (30, 15)]

/-- HMN (4.10): `χ₂^{A₃} = 3 − 96q − 288q² − 384q³ − 576q⁴ − 360q⁵ + …`. -/
theorem hmn_A3_printed : chi2YSer (yA 4) 3 5 = [3, -96, -288, -384, -576, -360] := by decide
/-- HMN (4.11): `χ₂^{A₇} = 7 − 192q − 576q² − 768q³ − 1344q⁴ − 1152q⁵ + …`. -/
theorem hmn_A7_printed : chi2YSer (yA 8) 7 5 = [7, -192, -576, -768, -1344, -1152] := by decide

/-- HMN's sum `F₂^{(2,1)}` equals Cheng–Harrison's `F₂⁽²⁾` (`QSeries.f2Coeff`) through `q⁴⁰`. -/
theorem f2kd_k2_eq_f2Coeff : (List.range 41).all fun n => f2kd 2 1 n == f2Coeff n := by decide

/-- **The `k = 2` DSLST index is Mathieu moonshine's weight-2 form**: `−2χ₂^{A₁} = η³H = −2E₂ + 48F₂`,
the series `numer` of `QSeries.lean`, through `q⁹` (HMN (4.9) with `rk = 1`, `X = A₁²⁴`). -/
theorem hmn_k2_eq_moonshine : (chi2YSer (yA 2) 1 9).map (-2 * ·) = numer 9 := by decide

/-! ### The divisibility, both directions -/

/-- **Umbral ⇒ divisible, for every coefficient.** -/
theorem divisible_of_dvd_24 (Ys : List (ℕ × ℕ)) (rk : ℤ) (h : rk ∣ 24) (n : ℕ) :
    rk ∣ chi2Y Ys rk n := by
  unfold chi2Y
  split
  · exact dvd_refl rk
  · exact dvd_sub (dvd_mul_right rk _) (dvd_mul_of_dvd_left h _)

theorem sigma_one : sigma 1 = 1 := by decide

theorem f2kd_A_one (k : ℕ) (hk : 2 ≤ k) : f2kd k 1 1 = 1 := by
  have h1 : (1 : ℕ) < k := hk
  have h2 : ¬ k < 1 := by omega
  simp [f2kd, List.range_succ, h1, h2]

theorem f2kd_D_one (j : ℕ) (hj : 3 ≤ j) : f2kd (2 * j) 1 1 + f2kd (2 * j) j 1 = -1 := by
  have h1 : (1 : ℕ) < 2 * j := by omega
  have h2 : ¬ 2 * j < 1 := by omega
  have h3 : ¬ j * j < 2 * j := by nlinarith
  have h4 : 2 * j < j * j := by nlinarith
  have h5 : 2 * j / j = 2 := by
    rw [Nat.mul_div_cancel _ (by omega : 0 < j)]
  simp [f2kd, List.range_succ, h1, h2, h3, h4, h5]

/-- **`A_{k−1}`: divisible by the rank iff the rank divides 24** (all `k ≥ 2`). -/
theorem A_divisible_iff (k : ℕ) (hk : 2 ≤ k) :
    (∀ n, ((k : ℤ) - 1) ∣ chi2Y (yA k) ((k : ℤ) - 1) n) ↔ ((k : ℤ) - 1) ∣ 24 := by
  constructor
  · intro h
    have h1 := h 1
    have e : chi2Y (yA k) ((k : ℤ) - 1) 1 = ((k : ℤ) - 1) * (-24) - 24 := by
      have hsum : ((yA k).map fun p => f2kd p.1 p.2 1).sum = 1 := by
        simp [yA, f2kd_A_one k hk]
      simp only [chi2Y, if_neg (by norm_num : (1 : ℕ) ≠ 0), sigma_one, hsum]
      ring
    rw [e] at h1
    have := dvd_sub (dvd_mul_right ((k : ℤ) - 1) (-24)) h1
    simpa using this
  · intro h n; exact divisible_of_dvd_24 _ _ h n

/-- **`D_{j+1}`: divisible by the rank iff the rank divides 24** (all `j ≥ 3`, Coxeter number `2j`). -/
theorem D_divisible_iff (j : ℕ) (hj : 3 ≤ j) :
    (∀ n, ((j : ℤ) + 1) ∣ chi2Y (yD j) ((j : ℤ) + 1) n) ↔ ((j : ℤ) + 1) ∣ 24 := by
  constructor
  · intro h
    have h1 := h 1
    have e : chi2Y (yD j) ((j : ℤ) + 1) 1 = ((j : ℤ) + 1) * (-24) + 24 := by
      have hsum : ((yD j).map fun p => f2kd p.1 p.2 1).sum = -1 := by
        simpa [yD] using f2kd_D_one j hj
      simp only [chi2Y, if_neg (by norm_num : (1 : ℕ) ≠ 0), sigma_one, hsum]
      ring
    rw [e] at h1
    have := (dvd_add_right (dvd_mul_right ((j : ℤ) + 1) (-24))).mp h1
    exact this
  · intro h n; exact divisible_of_dvd_24 _ _ h n

/-- `E₆`, `E₈` are divisible (rank `6`, `8` divide 24); `E₇` fails at `q¹`. -/
theorem E_divisibility :
    (∀ n, (6 : ℤ) ∣ chi2Y yE6 6 n) ∧ (∀ n, (8 : ℤ) ∣ chi2Y yE8 8 n) ∧ ¬ (7 : ℤ) ∣ chi2Y yE7 7 1 :=
  ⟨divisible_of_dvd_24 _ _ (by decide), divisible_of_dvd_24 _ _ (by decide), by decide⟩

/-! ### The umbral side: `Z⁽ℓ⁾` from theta functions -/

def LP.mul (p r : LP) : LP :=
  (p.1 + r.1, (List.range (p.2.length + r.2.length - 1)).map fun n =>
    ((List.range (n + 1)).map fun k => p.2.getD k 0 * r.2.getD (n - k) 0).sum)

def Ser.mul (a b : Ser) : Ser :=
  (List.range a.length).map fun n =>
    (List.range (n + 1)).foldl (fun acc k => acc.add ((a.getD k LP.zero).mul (b.getD (n - k) LP.zero)))
      LP.zero

def Ser.sub (a b : Ser) : Ser := Ser.add a (Ser.scale (-1) b)
/-- Coefficientwise integer division by `c` (exactness checked by `umbral_exact`). -/
def Ser.divInt (c : ℤ) (a : Ser) : Ser := a.map fun p => (p.1, p.2.map (· / c))

/-- `a₂ = 4f₂²` as a series in `t = q^{1/2}` through `t^M`. -/
def a2T (M : ℕ) : Ser :=
  let ev := (List.range (M / 2)).map fun i => 2 * (i + 1)
  let fs (c a : ℤ) (e : ℕ) := ev.flatMap fun k => List.replicate e (k, c, a)
  ((((Ser.one M).mulBins (fs 1 1 2 ++ fs 1 (-1) 2)).divBins (fs 1 0 4)).mulBins
    [(0, 1, 1), (0, 1, 1)]).map (LP.mono 1 (-1))

/-- `f₃²` (`sg = 1`) or `f₄²` (`sg = −1`) in `t`. -/
def f34T (M : ℕ) (sg : ℤ) : Ser :=
  let odd := (List.range ((M + 1) / 2)).map fun i => 2 * i + 1
  let fs (c a : ℤ) (e : ℕ) := odd.flatMap fun k => List.replicate e (k, c, a)
  ((Ser.one M).mulBins (fs sg 1 2 ++ fs sg (-1) 2)).divBins (fs sg 0 4)

/-- The raw (undivided) combinations for `Z⁽ℓ⁾` in `t`, returned with their divisors. -/
def umbralRawT (M : ℕ) : List (ℕ × ℤ × Ser) :=
  let a2 := a2T M
  let a3 := f34T M 1
  let a4 := f34T M (-1)
  let s34 := Ser.add a3 a4
  let z2 := Ser.add (Ser.scale 2 a2) (Ser.scale 8 s34)
  let z3 := Ser.add (Ser.mul a2 s34) (Ser.scale 4 (Ser.mul a3 a4))
  let z4 := Ser.scale 2 (Ser.mul a2 (Ser.mul a3 a4))
  let r5 := Ser.sub (Ser.mul z4 z2) (Ser.mul z3 z3)
  let z5 := Ser.divInt 8 r5
  let r7 := Ser.sub (Ser.mul z3 z5) (Ser.mul z4 z4)
  let z7 := Ser.divInt 2 r7
  let r9 := Ser.sub (Ser.mul z3 z7) (Ser.mul z5 z5)
  let z9 := Ser.divInt 2 r9
  let r13 := Ser.sub (Ser.mul z5 z9) (Ser.scale 2 (Ser.mul z7 z7))
  [(2, 1, z2), (3, 1, z3), (4, 1, z4), (5, 8, r5), (7, 2, r7), (9, 2, r9), (13, 2, r13)]

/-- The divisions defining `Z⁽⁵⁾, Z⁽⁷⁾, Z⁽⁹⁾, Z⁽¹³⁾` are exact, and only even powers of `t` occur. -/
def umbralOK (M : ℕ) : Bool :=
  (umbralRawT M).all fun e =>
    (e.2.2.all fun p => p.2.all fun c => c % e.2.1 == 0) &&
      ((List.range (M + 1)).all fun i => i % 2 == 0 || (e.2.2.getD i LP.zero).isZero)

/-- `Z⁽ℓ⁾` as a series in `q` through `q^N`. -/
def umbralZ (N ℓ : ℕ) : Ser :=
  match (umbralRawT (2 * N)).find? (·.1 == ℓ) with
  | some e => (List.range (N + 1)).map fun n => ((Ser.divInt e.2.1 e.2.2).getD (2 * n) LP.zero)
  | none => []

/-- `R_ℓ = Σ_{k≠0} q^{ℓk²} y^{2ℓk}(q^k y + 1)/(q^k y − 1)` through `q^N`. -/
def appellRm (ℓ N : ℕ) : Ser :=
  (List.range N).foldl (fun s i =>
    let k := i + 1
    (List.range (N + 1)).foldl (fun s j =>
      let s := s.addMono (ℓ * k * k + k * j) (2 * ℓ * k + j) (-1)
      let s := s.addMono (ℓ * k * k + k * (j + 1)) (2 * ℓ * k + j + 1) (-1)
      let s := s.addMono (ℓ * k * k + k * j) (-2 * ℓ * k - j) 1
      s.addMono (ℓ * k * k + k * (j + 1)) (-2 * ℓ * k - j - 1) 1) s) (List.replicate (N + 1) LP.zero)

/-- `X = (y−1)ψ^F = (y+1)E²B₂Z/B₁² − χ((y+1) + (y−1)R_ℓ)`, `χ = Z(τ,0)`. -/
def finiteX (N ℓ : ℕ) : Ser :=
  let Z := umbralZ N ℓ
  let chi := (Z.getD 0 LP.zero).eval1
  let psi := (Z.mulBins (facs N (-1) 0 2 ++ facs N (-1) 2 1 ++ facs N (-1) (-2) 1 ++ [(0, 1, 1)])).divBins
    (facs N (-1) 1 2 ++ facs N (-1) (-1) 2)
  let polar : Ser := Ser.add ((Ser.one N).mulBin (0, 1, 1))
    (((appellRm ℓ N).mulBins [(0, -1, 1)]).map (LP.mono (-1) 0))
  Ser.sub psi (Ser.scale chi polar)

def LP.d1 (p : LP) : ℤ := ((List.range p.2.length).map fun i => (p.1 + i) * p.2.getD i 0).sum
def LP.d2 (p : LP) : ℤ := ((List.range p.2.length).map fun i => (p.1 + i) ^ 2 * p.2.getD i 0).sum

/-- `θψ^F(1) = (θ²X(1) − θX(1))/2`, coefficient by coefficient. -/
def thetaPsiF (N ℓ : ℕ) : List ℤ := (finiteX N ℓ).map fun p => (p.d2 - p.d1) / 2

/-! ### Theorems for the umbral side -/

/-- The divisions defining `Z⁽⁵⁾ … Z⁽¹³⁾` are exact and no odd power of `q^{1/2}` survives (through `q⁶`). -/
theorem umbral_exact : umbralOK 12 = true := by decide +kernel

/-- `χ⁽ℓ⁾ = Z⁽ℓ⁾(τ, 0) = 24/(ℓ−1)` for `ℓ = 2, 3, 4, 5, 7, 13` (and `0` at higher orders), through `q⁶`. -/
theorem umbral_chi :
    [2, 3, 4, 5, 7, 13].map (fun l => (umbralZ 6 l).map LP.eval1) =
      [24, 12, 8, 6, 4, 2].map fun c => [c, 0, 0, 0, 0, 0, 0] := by decide

/-- The polar part `χ·Av⁽ℓ⁾[(y+1)/(y−1)]` removes the pole of `Ψ₁,₁Z⁽ℓ⁾` at `z = 0` (`X(1) = 0`), and
`θ²X(1) − θX(1)` is even, for every `ℓ`, through `q⁶`. -/
theorem umbral_pole_removed :
    [2, 3, 4, 5, 7].all fun l =>
      (finiteX 6 l).all fun p => p.eval1 == 0 && (p.d2 - p.d1) % 2 == 0 := by decide
theorem umbral_pole_removed_13 :
    (finiteX 6 13).all fun p => p.eval1 == 0 && (p.d2 - p.d1) % 2 == 0 := by decide +kernel

/-- **HMN (4.9), umbral side = DSLST side**, `ℓ = 2`: `4χ₂^{A₁} = 1 · θψ^F(1)` through `q⁶`. -/
theorem hmn_umbral_relation_2 :
    (chi2YSer (yA 2) 1 6).map (4 * ·) = (thetaPsiF 6 2).map (1 * ·) := by decide
theorem hmn_umbral_relation_3 :
    (chi2YSer (yA 3) 2 6).map (4 * ·) = (thetaPsiF 6 3).map (2 * ·) := by decide
theorem hmn_umbral_relation_4 :
    (chi2YSer (yA 4) 3 6).map (4 * ·) = (thetaPsiF 6 4).map (3 * ·) := by decide
theorem hmn_umbral_relation_5 :
    (chi2YSer (yA 5) 4 6).map (4 * ·) = (thetaPsiF 6 5).map (4 * ·) := by decide
theorem hmn_umbral_relation_7 :
    (chi2YSer (yA 7) 6 6).map (4 * ·) = (thetaPsiF 6 7).map (6 * ·) := by decide
theorem hmn_umbral_relation_13 :
    (chi2YSer (yA 13) 12 6).map (4 * ·) = (thetaPsiF 6 13).map (12 * ·) := by decide +kernel

/-- **Negative control.** The umbral form at `ℓ = 3` does not match the DSLST of `Y = A₃` (`k = 4`):
the relation pairs `X = A_{ℓ−1}^{24/(ℓ−1)}` with `Y = A_{ℓ−1}`, not with a neighbour. -/
theorem hmn_umbral_relation_wrong_Y :
    (chi2YSer (yA 4) 3 6).map (4 * ·) ≠ (thetaPsiF 6 3).map (3 * ·) := by decide

end DualScaleMoonshine
