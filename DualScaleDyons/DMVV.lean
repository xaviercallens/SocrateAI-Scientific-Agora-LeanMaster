/-
Stream 5 · P5.2–P5.4 — from the K3 elliptic genus to the dyon partition function `1/Φ₁₀`.

### Sources (Tier L; Dabholkar–Murthy–Zagier, `papers/foundations/1208_4074.txt`)
* (1.1), ll. 172–181: `1/Φ₁₀(Ω) = Σ_{m ≥ −1} ψ_m(τ, z) p^m` counts quarter-BPS dyons of type II string
  theory on K3 × T².
* (5.13)–(5.15), ll. 1816–1856: `Φ₁₀ = q y p Π_{(r,s,t)>0} (1 − q^s y^t p^r)^{2C₀(4rs−t²)}` (Gritsenko–Nikulin),
  the multiplicative lift of the K3 elliptic genus `2φ₀,₁ = Σ 2C₀(4n−l²) qⁿ yˡ`; hence
  `∆ψ_m = A⁻¹ · G_{m+1}` with `A = φ₋₂,₁` and `Σ_k G_k p^k = Π_{r≥1, s≥0, t} (1 − p^r q^s y^t)^{−c(4rs−t²)}`,
  `c = 2C₀` — the generating function of the elliptic genera of `Sym^k(K3)` (DMZ (4.52)).
* (5.16), ll. 1878–1886: `∆ψ₋₁ = A⁻¹`, `∆ψ₀ = 2A⁻¹B`, `4∆ψ₁ = 9A⁻¹B² + 3E₄A`,
  `27∆ψ₂ = 50A⁻¹B³ + 48E₄AB + 10E₆A²`, `384∆ψ₃ = 475A⁻¹B⁴ + 886E₄AB² + 360E₆A²B + 199E₄²A³`,
  `72∆ψ₄ = 51A⁻¹B⁵ + 155E₄AB³ + 93E₆A²B² + 102E₄²A³B + 31E₄E₆A⁴`, with `B = φ₀,₁`.
* l. 1070: `p₂₄(n)` is the number of 24-coloured partitions of `n`; l. 3639: `p₂₄(3) = 3200`.
* (1.2)–(1.3), (9.4), (9.55), ll. 196–205, 3661, 5199–5210: the polar part `ψ_m^P = p₂₄(m+1)/∆ · A₂,ₘ`,
  `A₂,ₘ = Σ_s q^{ms²+s} y^{2ms+1}/(1 − q^s y)²`, and its Fourier expansion
  `A₂,ₘ = Σ_{s,t} ½(sgn t − sgn(s + z₂/τ₂)) t q^{ms²−st} y^{2ms−t}`.

### What is proved (Tier A, exact integer arithmetic, through the orders stated)
* `c_depends_only_on_D`: the coefficients of the computed `Z_K3` depend only on `4n − l²` (the
  index-1 Jacobi property), so `c(D)` is well defined; `dmvv_reachable`: every `c(D)` the products below
  read is available from `Z_K3` through `q⁹` (the loop is enumerated, not estimated), and
  `dmvv_unreachable_example` shows the guard does fail for a too-deep truncation (`p⁴, q³`).
* `goettsche`: the coefficient `G_k` of `p^k`, at `z = 0`, is `p₂₄(k) = 1, 24, 324, 3200, 25650, 176256`
  for `k ≤ 5`, constant in `τ` (the Euler numbers of `Hilb^k(K3)`).
* `dmz_516_q1` (`k ≤ 5`, through `q¹`), `dmz_516_q2` (`k ≤ 4`, through `q²`): the six printed identities (5.16), with `A`, `B` from theta products and `E₄`, `E₆` from
  divisor sums — two independent routes to the dyon partition function meet.
* `a2m_strip_eq_955`: in the strip `|q| < |y| < 1`, the direct expansion of (1.3) equals (9.55).
* `polar_part_removes_pole`: `G_{m+1} − p₂₄(m+1)·A·A₂,ₘ` vanishes to second order at `y = 1` at every
  order in `q` (`m = 1, 2, 3`), i.e. `∆ψ_m − p₂₄(m+1)A₂,ₘ` has no pole at `z = 0`; `polar_coefficient_pinned`:
  the multiples `p₂₄(m+1) ± 1` fail. Caveat: the second-order condition (`d1 = 0`) holds automatically by
  the `y ↔ y⁻¹` symmetry, so what these two theorems discriminate is the first-order condition — the pole
  coefficient is `G_{m+1}(τ, 0) = p₂₄(m+1)`, constant in `τ`. The full second-order content (the division
  by `A` is exact at every coefficient) is carried by `Immortal.immortal_m1_exact` for `m = 1`.
* `negBinom_exact`: the integer divisions inside the product are exact at every pair used.

### Not proved
That `1/Φ₁₀` counts dyons, that `Φ₁₀` is a Siegel modular form or that the product converges (Tier L).
-/
import DualScaleMoonshine.HMNBridge

namespace DualScaleDyons

open DualScaleMoonshine

/-! ### The K3 elliptic genus as input -/

/-- `Z_K3 = 2φ₀,₁` through `q⁹`, computed from theta products in `DualScaleMoonshine.Shadow`. -/
def zK3 : Ser := ellipticGenus 9

/-- `c(D)`, read off `Z_K3` at `l ∈ {0, 1}` (`D ≡ 0, 3 mod 4`); zero for `D < −1` and `D ≡ 1, 2`. -/
def cK3 (D : ℤ) : ℤ :=
  if D < -1 then 0 else
    let l : ℤ := if D % 4 = 0 then 0 else 1
    if (D + l * l) % 4 ≠ 0 then 0 else (zK3.getD ((D + l * l) / 4).toNat LP.zero).coef l

/-- **Index-1 Jacobi property**: every coefficient of `Z_K3` through `q⁹` equals `c(4n − l²)`. -/
theorem c_depends_only_on_D :
    (List.range 10).all fun n => (List.range 25).all fun i =>
      let l : ℤ := (i : ℤ) - 12
      (zK3.getD n LP.zero).coef l == cK3 (4 * n - l * l) := by decide

/-- The first values: `c(−1) = 2`, `c(0) = 20`, `c(3) = −128`, `c(4) = 216`. -/
theorem c_first : [cK3 (-1), cK3 0, cK3 3, cK3 4] = [2, 20, -128, 216] := by decide

/-! ### The DMVV product -/

/-- A series in `p` (index `r`, `0 … K`) of series in `q` with Laurent coefficients in `y`. -/
abbrev Ser3 := List Ser

/-- Coefficient of `x^j` in `(1 − x)^{−e}`: `e(e+1)⋯(e+j−1)/j!`, for any integer `e`. -/
def negBinom (e : ℤ) (j : ℕ) : ℤ :=
  ((List.range j).foldl (fun acc i => acc * (e + i)) 1) / ((List.range j).foldl (fun acc i => acc * (i + 1)) 1 : ℕ)

/-- Multiply by `(1 − p^r q^s y^t)^{−e}` (`r ≥ 1`). -/
def mulFactor (G : Ser3) (r s : ℕ) (t e : ℤ) : Ser3 :=
  (List.range G.length).map fun R =>
    let row := G.getD R []
    (List.range row.length).map fun S =>
      (List.range (R / r + 1)).foldl (fun acc j =>
        if s * j ≤ S then
          acc.add (LP.mono (negBinom e j) (t * j) ((G.getD (R - r * j) []).getD (S - s * j) LP.zero))
        else acc) LP.zero

/-- `Σ_{k ≤ K} G_k p^k = Π_{1≤r≤K, 0≤s≤Q, t} (1 − p^r q^s y^t)^{−c(4rs−t²)}`, truncated at `p^K`, `q^Q`. -/
def dmvv (K Q : ℕ) : Ser3 :=
  let init : Ser3 := (List.range (K + 1)).map fun R => if R = 0 then Ser.one Q else List.replicate (Q + 1) LP.zero
  (List.range K).foldl (fun G i =>
    let r := i + 1
    (List.range (Q + 1)).foldl (fun G s =>
      let tm : ℕ := 2 * r * s + 1
      (List.range (2 * tm + 1)).foldl (fun G j =>
        let t : ℤ := (j : ℤ) - tm
        let D : ℤ := 4 * r * s - t * t
        if D < -1 then G else
          let e := cK3 D
          if e = 0 then G else mulFactor G r s t e) G) G) init

/-- The discriminants `D = 4rs − t² ≥ −1` at which `dmvv K Q` reads `c(D)` (same loops as `dmvv`). -/
def dmvvDs (K Q : ℕ) : List ℤ :=
  (List.range K).flatMap fun i =>
    let r := i + 1
    (List.range (Q + 1)).flatMap fun s =>
      let tm : ℕ := 2 * r * s + 1
      ((List.range (2 * tm + 1)).map fun j => 4 * (r : ℤ) * s - ((j : ℤ) - tm) ^ 2).filter (-1 ≤ ·)

/-- `c(D)` is read from `Z_K3` at `q^n` with `n = (D + l²)/4`; it is available iff `n ≤ 9`. -/
def cAvailable (D : ℤ) : Bool :=
  let l : ℤ := if D % 4 = 0 then 0 else 1
  (D + l * l) / 4 ≤ 9

/-- **Reachability guard**: every `c(D)` read by the products used in this stream is available from
`Z_K3` through `q⁹` (so no coefficient is silently taken as zero by truncation). -/
theorem dmvv_reachable :
    [(5, 1), (4, 2), (2, 3)].all (fun kq : ℕ × ℕ => (dmvvDs kq.1 kq.2).all cAvailable) = true := by decide

/-- **Negative control**: the truncation `p⁴, q³` would need `c(48)`, which is not available. -/
theorem dmvv_unreachable_example : (dmvvDs 4 3).all cAvailable = false := by decide

/-- The pairs `(e, j)` at which `dmvv K Q` evaluates `negBinom e j` (same loops as `dmvv`). -/
def negBinomPairs (K Q : ℕ) : List (ℤ × ℕ) :=
  (List.range K).flatMap fun i =>
    let r := i + 1
    (List.range (Q + 1)).flatMap fun s =>
      let tm : ℕ := 2 * r * s + 1
      ((List.range (2 * tm + 1)).filterMap fun j =>
        let D : ℤ := 4 * (r : ℤ) * s - ((j : ℤ) - tm) ^ 2
        if D < -1 then none else some (cK3 D)).flatMap fun e =>
          (List.range (K / r + 1)).map fun j => (e, j)

/-- **`negBinom` is an exact division** at every pair the products of this stream use: the integer
quotient `e(e+1)⋯(e+j−1)/j!` never truncates. -/
theorem negBinom_exact :
    [(5, 1), (4, 2), (2, 3)].all (fun kq : ℕ × ℕ => (negBinomPairs kq.1 kq.2).all fun p =>
      ((List.range p.2).foldl (fun acc i => acc * (p.1 + i)) 1) %
        (((List.range p.2).foldl (fun acc i => acc * (i + 1)) 1 : ℕ) : ℤ) == 0) = true := by decide

/-- `p₂₄(n)`: coefficient of `qⁿ` in `Π (1 − qᵏ)^{−24}` (24-coloured partitions). -/
def p24 (n : ℕ) : ℤ :=
  let s := (List.range n).foldl (fun s i =>
    (List.range 24).foldl (fun s _ =>
      (List.range (n + 1)).foldl (fun s k => if i + 1 ≤ k then s.set k (s.getD k 0 + s.getD (k - (i + 1)) 0) else s) s) s)
    ((List.range (n + 1)).map fun k => if k = 0 then (1 : ℤ) else 0)
  s.getD n 0

theorem p24_values : (List.range 6).map p24 = [1, 24, 324, 3200, 25650, 176256] := by decide

/-- **Göttsche**: `G_k(τ, 0) = p₂₄(k)` for `k ≤ 5`, and every higher `q`-coefficient vanishes. -/
theorem goettsche :
    (dmvv 5 1).map (fun Gk => Gk.map LP.eval1) =
      (List.range 6).map fun k => [p24 k, 0] := by decide +kernel

/-! ### DMZ (5.16) -/

/-- `A = φ₋₂,₁ = y⁻¹(y−1)² Π (1−yqⁿ)²(1−y⁻¹qⁿ)²/(1−qⁿ)⁴`. -/
def phiA (N : ℕ) : Ser :=
  ((((Ser.one N).mulBins ([(0, -1, 1), (0, -1, 1)] ++ facs N (-1) 1 2 ++ facs N (-1) (-1) 2)).divBins
    (facs N (-1) 0 4)).map (LP.mono 1 (-1)))

/-- `B = φ₀,₁ = Z_K3/2` (exact: `zK3_even`). -/
def phiB (N : ℕ) : Ser := Ser.divInt 2 ((ellipticGenus N))

theorem zK3_even : zK3.all (fun p => p.2.all fun c => c % 2 == 0) = true := by decide

def eis (N : ℕ) (k : ℕ) (c : ℤ) : Ser :=
  (List.range (N + 1)).map fun n =>
    if n = 0 then LP.const 1
    else LP.const (c * (((List.range (n + 1)).filter fun d => 0 < d ∧ n % d = 0).map fun d => (d : ℤ) ^ k).sum)

def e4 (N : ℕ) : Ser := eis N 3 240
def e6 (N : ℕ) : Ser := eis N 5 (-504)

def mulAll (xs : List Ser) (N : ℕ) : Ser := xs.foldl Ser.mul (Ser.one N)

/-- Right sides of (5.16) multiplied by `A`, as `(denominator, series)`, for `G₀ … G₅`. -/
def dmz516 (N : ℕ) : List (ℤ × Ser) :=
  let A := phiA N
  let B := phiB N
  let E4 := e4 N
  let E6 := e6 N
  let P := fun xs => mulAll xs N
  [ (1, Ser.one N),
    (1, Ser.scale 2 B),
    (4, Ser.add (Ser.scale 9 (P [B, B])) (Ser.scale 3 (P [E4, A, A]))),
    (27, Ser.add (Ser.add (Ser.scale 50 (P [B, B, B])) (Ser.scale 48 (P [E4, A, A, B])))
      (Ser.scale 10 (P [E6, A, A, A]))),
    (384, Ser.add (Ser.add (Ser.scale 475 (P [B, B, B, B])) (Ser.scale 886 (P [E4, A, A, B, B])))
      (Ser.add (Ser.scale 360 (P [E6, A, A, A, B])) (Ser.scale 199 (P [E4, E4, A, A, A, A])))),
    (72, Ser.add (Ser.add (Ser.scale 51 (P [B, B, B, B, B])) (Ser.scale 155 (P [E4, A, A, B, B, B])))
      (Ser.add (Ser.add (Ser.scale 93 (P [E6, A, A, A, B, B])) (Ser.scale 102 (P [E4, E4, A, A, A, A, B])))
        (Ser.scale 31 (P [E4, E6, A, A, A, A, A])))) ]

/-- **DMZ (5.16) through `q¹`, `k ≤ 5`**: `d_k · G_k = (right side) · A`, with `G_k` from the product. -/
theorem dmz_516_q1 :
    (List.range 6).all (fun k =>
      Ser.eqB (Ser.scale ((dmz516 1).getD k (1, [])).1 ((dmvv 5 1).getD k []))
        ((dmz516 1).getD k (1, [])).2) = true := by decide +kernel

/-- **DMZ (5.16) through `q²`, `k ≤ 4`.** -/
theorem dmz_516_q2 :
    (List.range 5).all (fun k =>
      Ser.eqB (Ser.scale ((dmz516 2).getD k (1, [])).1 ((dmvv 4 2).getD k []))
        ((dmz516 2).getD k (1, [])).2) = true := by decide +kernel

/-! ### The polar part and the strip -/

/-- `A₂,ₘ` minus its `s = 0` term `y/(1−y)²`, expanded from (1.3) in the strip `|q| < |y| < 1`. -/
def a2mRest (m Q : ℕ) : Ser :=
  (List.range (Q + 1)).foldl (fun S i =>
    let s := i + 1
    (List.range (Q + 1)).foldl (fun S j =>
      -- s ≥ 1:  q^{ms²+s} y^{2ms+1} Σ_j (j+1)(q^s y)^j
      let S := S.addMono (m * s * s + s + s * j) (2 * m * s + 1 + j) (j + 1)
      -- s ≤ −1 (write −s):  q^{ms²−s} y^{−2ms+1} (q^s y)^{−2} Σ_j (j+1)(q^s y)^{−j}
      S.addMono (m * s * s + s * (1 + j)) (-(2 * m * s : ℤ) - 1 - j) (j + 1)) S)
    (List.replicate (Q + 1) LP.zero)

/-- The same, from DMZ (9.55): `Σ_{s ≠ 0, t} ½(sgn t − sgn(s + ε)) t q^{ms²−st} y^{2ms−t}`, `0 < ε < 1`. -/
def a2m955 (m Q : ℕ) : Ser :=
  (List.range (Q + 1)).foldl (fun S i =>
    let s := i + 1
    (List.range (Q + 2)).foldl (fun S j =>
      let t := j + 1
      -- s > 0, t' = −t < 0: coefficient t, q^{ms² + st}, y^{2ms + t}
      let S := if m * s * s + s * t ≤ Q then S.addMono (m * s * s + s * t) (2 * m * s + t) t else S
      -- s' = −s < 0, t > 0: coefficient t, q^{ms² + st}, y^{−2ms − t}
      if m * s * s + s * t ≤ Q then S.addMono (m * s * s + s * t) (-(2 * m * s : ℤ) - t) t else S) S)
    (List.replicate (Q + 1) LP.zero)

/-- **The strip expansion of (1.3) is (9.55)** (`m = 1, 2, 3`, through `q⁶`). -/
theorem a2m_strip_eq_955 : [1, 2, 3].all (fun m => Ser.eqB (a2mRest m 6) (a2m955 m 6)) = true := by decide

/-- `R = Π (1−yqⁿ)²(1−y⁻¹qⁿ)²/(1−qⁿ)⁴`, so that `A = y⁻¹(y−1)² R` and `A · y/(1−y)² = R`. -/
def rPart (N : ℕ) : Ser :=
  ((Ser.one N).mulBins (facs N (-1) 1 2 ++ facs N (-1) (-1) 2)).divBins (facs N (-1) 0 4)

/-- `A · A₂,ₘ` in the strip. -/
def aTimesA2m (m N : ℕ) : Ser := Ser.add (rPart N) (Ser.mul (phiA N) (a2m955 m N))

/-- `G_{m+1} − coef · A · A₂,ₘ` (numerator of `∆ψ_m − coef · A₂,ₘ`). -/
def polarDefect (m : ℕ) (coef : ℤ) : Ser :=
  Ser.sub ((dmvv 4 2).getD (m + 1) []) (Ser.scale coef (aTimesA2m m 2))

/-- Vanishing to second order at `y = 1`, coefficientwise in `q`. -/
def vanish2 (s : Ser) : Bool := s.all fun p => p.eval1 == 0 && p.d1 == 0

/-- **The polar part `p₂₄(m+1)/∆ · A₂,ₘ` removes the double pole of `ψ_m`** (`m = 1, 2, 3`, through `q²`). -/
theorem polar_part_removes_pole : [1, 2, 3].all (fun m => vanish2 (polarDefect m (p24 (m + 1)))) = true := by
  decide +kernel

/-- **Negative control**: `p₂₄(m+1) ± 1` leave a pole. -/
theorem polar_coefficient_pinned :
    [1, 2, 3].all (fun m => !vanish2 (polarDefect m (p24 (m + 1) + 1)) &&
      !vanish2 (polarDefect m (p24 (m + 1) - 1))) = true := by decide +kernel

end DualScaleDyons
