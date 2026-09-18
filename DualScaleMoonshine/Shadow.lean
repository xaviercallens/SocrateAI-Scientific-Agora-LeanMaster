/-
Stream 4 · P4.4 — where the `24` of the shadow comes from: the polar/finite decomposition of the
K3 elliptic genus, computed.

The literature (Tier L) says that `H⁽²⁾` is a mock modular form whose shadow is `24·η³`
(Harvey–Murthy–Nazaroglu, `1410_6174.txt` l. 246), and that the second helicity supertrace of the
double-scaled little string theory at `k = 2` is `−½ η³ Ĥ`, the completion of the mixed mock modular
form `η³H` whose shadow is `24 η³ η̄³` (same file, ll. 265–270). This file does **not** prove that
`24·η³` is a shadow: there is no completion, no non-holomorphic function and no modular
transformation here. What it proves is the arithmetic skeleton of that statement.

### The statement being checked (Cheng–Duncan–Harvey, `1204_2779.txt`)
* (2.49), (2.62), ll. 1258–1270, 1397: `Z⁽²⁾ = 2φ₁⁽²⁾ = 8(f₂² + f₃² + f₄²)`, `f_i = θ_i(τ,z)/θ_i(τ,0)`,
  the elliptic genus of K3 (l. 1386).
* (A.2), ll. 4062–4082: the product formulas for `θ₁ … θ₄`.
* (2.19)–(2.21), ll. 657–677: `ψ = Ψ₁,₁ · φ` with `Ψ₁,₁ = −i θ₁(τ,2z) η³ / θ₁(τ,z)²
  = (y+1)/(y−1) − (y² − y⁻²) q + …`, and `χ = φ(τ, 0)`.
* (2.22)–(2.25), ll. 681–711: `ψ = χ · Av⁽ᵐ⁾[(y+1)/(y−1)] + Σ_r h_r θ̂_r⁽ᵐ⁾` (polar part plus finite part), with
  `Av⁽ᵐ⁾[F](y) = Σ_k q^{mk²} y^{2mk} F(q^k y)` and `θ̂_r = θ_{−r} − θ_r` (2.18), `θ_r⁽ᵐ⁾` from (2.15).
* (2.26)–(2.30), ll. 716–768: the shadow of `h` is `χ · S⁽ᵐ⁾` with `S_r⁽ᵐ⁾ = Σ_n (2mn+r) q^{(2mn+r)²/4m}`.

### Clearing denominators (exact algebra, done by hand, checked by the theorems)
Write `E = Π(1−qⁿ)`, `B₁ = Π(1−yqⁿ)(1−y⁻¹qⁿ)`, `B₂ = Π(1−y²qⁿ)(1−y⁻²qⁿ)` (all `n ≥ 1`). From (A.2),
`Ψ₁,₁ = (y+1)/(y−1) · E² B₂ / B₁²`. For `m = 2`, `Av⁽²⁾[(y+1)/(y−1)] = (y+1)/(y−1) + R` with
`R = Σ_{k≠0} q^{2k²} y^{4k} (q^k y + 1)/(q^k y − 1)`, and `H·θ̂₁⁽²⁾ = h · T` with `h = q^{1/8}H` (the series of
`QSeries.lean`) and `T = Σ_n (q^{2n²−n} y^{4n−1} − q^{2n²+n} y^{4n+1})`. Multiplying (2.25) by `(y−1)B₁²`:

  `(y+1) E² B₂ Z  =  χ · B₁² ((y+1) + (y−1)R)  +  (y−1) B₁² h T`.                                (★)

Every term is a power series in `q` whose coefficients are Laurent polynomials in `y`.

### What is proved (Tier A, through `q⁹`, exact integer arithmetic)
* `ellipticGenus_z0`: `Z(τ, 0) = 24` — the constant term is `24 = χ(K3)` and every higher coefficient
  vanishes (the weak-Jacobi-form property `φ(τ,0) = const`, checked rather than assumed).
* `ellipticGenus_first_terms`: `Z = 2y + 20 + 2y⁻¹ + q(20y² − 128y + 216 − 128y⁻¹ + 20y⁻²) + …`.
* `psi11_expansion`: the cleared `Ψ₁,₁` reproduces CDH's printed `(y+1)/(y−1) − (y² − y⁻²)q`.
* `decomposition`: (★) holds with `χ = 24` and with `h` the series **computed** from
  `(−2E₂ + 48F₂)/η³` in `QSeries.lean`. So the mock modular form obtained from the K3 elliptic genus
  by removing its polar part is, through `q⁹`, the `H⁽²⁾` of Cheng–Harrison's closed formula.
* `decomposition_pins_chi`: (★) fails with `χ = 23` and `χ = 25`. Two independent facts meet at `24`:
  the value `Z(τ,0)` and the multiplicity of the polar part.
* `decomposition_needs_H`: (★) fails if `h` is replaced by the twined series `H_2A`.
* `shadowTheta_eq_eta3`: the unary theta series `S₁⁽²⁾ = Σ (4n+1) q^{(4n+1)²/8}` of (2.26) equals
  `η³ = q^{1/8}Π(1−qⁿ)³` through `q⁹` (Jacobi's identity, checked for ten coefficients, not proved).
* `shadow_coeff_eq_perm_trace`: for every class `g`, CDH's twined shadow multiplicity `χ_g`
  (Table 14, ll. 4349–4364) equals `χ₁(g) + χ₂(g)`, the trace of `g` on the 24-dimensional
  permutation representation `1 ⊕ 23`, computed from the character table of `CharactersAll.lean`.

### What is not proved
That `H⁽²⁾` is mock modular, that its shadow is `24·η³`, the completion (2.29), any modular
transformation, anything past `q⁹`. The step "multiplicity of the polar part = coefficient of the
shadow" is Zwegers' theorem as recast in CDH §2.3 (Tier L). HMN's identification of `η³Ĥ` with a
helicity supertrace of the double-scaled LST is Tier L; reading the polar part (`24·μ`, massless,
`χ(K3)`) and the finite part (`H`, massive) as "macro" and "micro" sectors is Tier C.
-/
import DualScaleMoonshine.CharactersAll

namespace DualScaleMoonshine

/-! ### Laurent polynomials in `y` and `q`-series of them -/

/-- `(e, [c₀, c₁, …])` stands for the Laurent polynomial `Σ cᵢ y^{e+i}` (exact, no truncation in `y`). -/
abbrev LP := ℤ × List ℤ

def LP.zero : LP := (0, [])
def LP.const (c : ℤ) : LP := (0, [c])
/-- Coefficient of `y^e`. -/
def LP.coef (p : LP) (e : ℤ) : ℤ := if e < p.1 then 0 else p.2.getD (e - p.1).toNat 0
def LP.add (p r : LP) : LP :=
  let lo := min p.1 r.1
  let hi := max (p.1 + p.2.length) (r.1 + r.2.length)
  (lo, (List.range (hi - lo).toNat).map fun i => p.coef (lo + i) + r.coef (lo + i))
/-- `c · y^a · p`. -/
def LP.mono (c a : ℤ) (p : LP) : LP := (p.1 + a, p.2.map (c * ·))
def LP.isZero (p : LP) : Bool := p.2.all (· == 0)
/-- Value at `y = 1` (i.e. `z = 0`). -/
def LP.eval1 (p : LP) : ℤ := p.2.sum

/-- A `q`-series truncated at `q^N`, coefficients in `LP`. -/
abbrev Ser := List LP

def Ser.one (N : ℕ) : Ser := (List.range (N + 1)).map fun n => if n = 0 then LP.const 1 else LP.zero
def Ser.add (a b : Ser) : Ser := List.zipWith LP.add a b
def Ser.scale (c : ℤ) (a : Ser) : Ser := a.map (LP.mono c 0)
/-- Equality of two truncated series, coefficient by coefficient. -/
def Ser.eqB (a b : Ser) : Bool :=
  a.length == b.length && (List.zipWith (fun p r => (LP.add p (LP.mono (-1) 0 r)).isZero) a b).all id

/-- Multiply by `1 + c·y^a·q^k`. -/
def Ser.mulBin (s : Ser) (f : ℕ × ℤ × ℤ) : Ser :=
  (List.range s.length).map fun n =>
    if f.1 ≤ n then (s.getD n LP.zero).add (LP.mono f.2.1 f.2.2 (s.getD (n - f.1) LP.zero))
    else s.getD n LP.zero

/-- Divide by `1 + c·y^a·q^k` (`k ≥ 1`). -/
def Ser.divBin (s : Ser) (f : ℕ × ℤ × ℤ) : Ser :=
  (List.range s.length).foldl (fun acc n =>
    acc ++ [if f.1 ≤ n then (s.getD n LP.zero).add (LP.mono (-f.2.1) f.2.2 (acc.getD (n - f.1) LP.zero))
      else s.getD n LP.zero]) []

def Ser.mulBins (s : Ser) (fs : List (ℕ × ℤ × ℤ)) : Ser := fs.foldl Ser.mulBin s
def Ser.divBins (s : Ser) (fs : List (ℕ × ℤ × ℤ)) : Ser := fs.foldl Ser.divBin s

/-- Add `c·y^e·q^n` to a series (ignored beyond the truncation). -/
def Ser.addMono (s : Ser) (n : ℕ) (e c : ℤ) : Ser :=
  (List.range s.length).map fun i =>
    if i = n then (s.getD i LP.zero).add (e, [c]) else s.getD i LP.zero

/-- Product with an integer series `h` (coefficients constant in `y`). -/
def Ser.scalMul (h : List ℤ) (s : Ser) : Ser :=
  (List.range s.length).map fun n =>
    (List.range (n + 1)).foldl (fun acc k => acc.add (LP.mono (h.getD k 0) 0 (s.getD (n - k) LP.zero)))
      LP.zero

/-- The factor list `Π_{n=1}^{N} (1 + c·y^a·qⁿ)^e` in the form used by `mulBins`. -/
def facs (N : ℕ) (c a : ℤ) (e : ℕ) : List (ℕ × ℤ × ℤ) :=
  (List.range N).flatMap fun i => List.replicate e (i + 1, c, a)

/-! ### The elliptic genus of K3 from theta functions -/

/-- `8 f₂²` as a series in `q`: `2 y⁻¹(y+1)² Π (1+yqⁿ)²(1+y⁻¹qⁿ)² / (1+qⁿ)⁴`. -/
def eightF2sq (N : ℕ) : Ser :=
  ((((Ser.one N).mulBins (facs N 1 1 2 ++ facs N 1 (-1) 2)).divBins (facs N 1 0 4)).mulBins
    [(0, 1, 1), (0, 1, 1)]).map (LP.mono 2 (-1))

/-- `f₃²` as a series in `t = q^{1/2}` through `t^M`: `Π (1+y t^{2n−1})²(1+y⁻¹t^{2n−1})² / (1+t^{2n−1})⁴`;
and `f₄²(t) = f₃²(−t)`. -/
def f3sqT (M : ℕ) : Ser :=
  let odd := (List.range ((M + 1) / 2)).map fun i => 2 * i + 1
  let fs (c a : ℤ) (e : ℕ) := odd.flatMap fun k => List.replicate e (k, c, a)
  ((Ser.one M).mulBins (fs 1 1 2 ++ fs 1 (-1) 2)).divBins (fs 1 0 4)

/-- `Z⁽²⁾ = 8(f₂² + f₃² + f₄²)` through `q^N`; `8(f₃² + f₄²)` is `16 ×` the even part of `f₃²(t)`. -/
def ellipticGenus (N : ℕ) : Ser :=
  let t := f3sqT (2 * N)
  (List.range (N + 1)).map fun n => ((eightF2sq N).getD n LP.zero).add (LP.mono 16 0 (t.getD (2 * n) LP.zero))

/-- **`Z(τ, 0) = 24`**: the Euler number of K3, and a constant (weak Jacobi form of weight 0). -/
theorem ellipticGenus_z0 : (ellipticGenus 9).map LP.eval1 = [24, 0, 0, 0, 0, 0, 0, 0, 0, 0] := by decide

/-- Transcription control: `Z = 2y + 20 + 2y⁻¹ + q(20y² − 128y + 216 − 128y⁻¹ + 20y⁻²) + O(q²)`. -/
theorem ellipticGenus_first_terms :
    Ser.eqB ((ellipticGenus 9).take 2) [(-1, [2, 20, 2]), (-2, [20, -128, 216, -128, 20])] = true := by
  decide

/-! ### The polar/finite decomposition (★) -/

/-- `R = Σ_{k≠0} q^{2k²} y^{4k} (q^k y + 1)/(q^k y − 1)` through `q^N`, expanded as geometric series. -/
def appellR (N : ℕ) : Ser :=
  (List.range N).foldl (fun s i =>
    let k := i + 1
    (List.range (N + 1)).foldl (fun s j =>
      -- k > 0 :  −(1 + q^k y) Σ_j (q^k y)^j
      let s := s.addMono (2 * k * k + k * j) (4 * k + j) (-1)
      let s := s.addMono (2 * k * k + k * (j + 1)) (4 * k + j + 1) (-1)
      -- k < 0 :  (1 + q^k y⁻¹) Σ_j (q^k y⁻¹)^j
      let s := s.addMono (2 * k * k + k * j) (-4 * k - j) 1
      s.addMono (2 * k * k + k * (j + 1)) (-4 * k - j - 1) 1) s) (List.replicate (N + 1) LP.zero)

/-- `T = q^{−1/8} θ̂₁⁽²⁾ = Σ_n (q^{2n²−n} y^{4n−1} − q^{2n²+n} y^{4n+1})` through `q^N`. -/
def thetaT (N : ℕ) : Ser :=
  (List.range (2 * N + 1)).foldl (fun s i =>
    let n : ℤ := (i : ℤ) - N
    let s := if 2 * n * n - n ≤ N then s.addMono (2 * n * n - n).toNat (4 * n - 1) 1 else s
    if 2 * n * n + n ≤ N then s.addMono (2 * n * n + n).toNat (4 * n + 1) (-1) else s)
    (List.replicate (N + 1) LP.zero)

/-- Left side of (★): `(y+1) E² B₂ Z`. -/
def starLHS (N : ℕ) : Ser :=
  (ellipticGenus N).mulBins (facs N (-1) 0 2 ++ facs N (-1) 2 1 ++ facs N (-1) (-2) 1 ++ [(0, 1, 1)])

/-- Right side of (★): `χ B₁² ((y+1) + (y−1)R) + (y−1) B₁² h T`. -/
def starRHS (N : ℕ) (chi : ℤ) (h : List ℤ) : Ser :=
  let b1sq := facs N (-1) 1 2 ++ facs N (-1) (-1) 2
  -- `(y−1)R` is `−(1 − y)R`; `mulBin (0, −1, 1)` gives `(1 − y)R`
  let polar : Ser := Ser.add ((Ser.one N).mulBin (0, 1, 1))
    (((appellR N).mulBins [(0, -1, 1)]).map (LP.mono (-1) 0))
  let polar : Ser := (Ser.mulBins polar b1sq).map (LP.mono chi 0)
  let finite : Ser := ((Ser.scalMul h (thetaT N)).mulBins ((0, -1, 1) :: b1sq)).map (LP.mono (-1) 0)
  Ser.add polar finite

/-- **The decomposition of the K3 elliptic genus** (CDH (2.19)–(2.25) at `m = 2`, cleared of
denominators): polar part with multiplicity `24`, finite part with theta-coefficient the series `h`
computed from `(−2E₂ + 48F₂)/η³`. -/
theorem decomposition : Ser.eqB (starLHS 9) (starRHS 9 24 (hComputed 9)) = true := by decide

/-- **Negative control.** The polar multiplicity is pinned: `23` and `25` fail. -/
theorem decomposition_pins_chi :
    Ser.eqB (starLHS 9) (starRHS 9 23 (hComputed 9)) = false ∧
      Ser.eqB (starLHS 9) (starRHS 9 25 (hComputed 9)) = false := by decide

/-- **Negative control.** The finite part is `H` itself, not a twined series. -/
theorem decomposition_needs_H :
    Ser.eqB (starLHS 9) (starRHS 9 24 ((twined24 9 8 2 (-16)).map (· / 24))) = false := by decide

/-- Transcription control for (2.20): the cleared `(y−1)Ψ₁,₁ = (y+1) E² B₂ / B₁²` begins
`(y+1) + (y−1)(y⁻² − y²) q`. -/
theorem psi11_expansion :
    Ser.eqB ((((Ser.one 9).mulBins (facs 9 (-1) 0 2 ++ facs 9 (-1) 2 1 ++ facs 9 (-1) (-2) 1 ++
        [(0, 1, 1)])).divBins (facs 9 (-1) 1 2 ++ facs 9 (-1) (-1) 2)).take 2)
      [(0, [1, 1]), (-2, [-1, 1, 0, 0, 1, -1])] = true := by decide

/-! ### The shadow's theta series and its multiplicities -/

/-- `q^{−1/8} S₁⁽²⁾ = Σ_n (4n+1) q^{2n²+n}` through `q^N` (CDH (2.26) at `m = 2`, `r = 1`). -/
def shadowTheta (N : ℕ) : List ℤ :=
  (List.range (N + 1)).map fun d =>
    ((List.range (2 * N + 1)).filter fun i =>
      let n : ℤ := (i : ℤ) - N
      2 * n * n + n = d).foldl (fun acc i => acc + (4 * ((i : ℤ) - N) + 1)) 0

/-- `S₁⁽²⁾ = η³` through `q⁹`: the shadow `χ S₁⁽²⁾` is `χ η³`. -/
theorem shadowTheta_eq_eta3 : shadowTheta 9 = eta3 9 := by decide

/-- CDH Table 14: the shadow multiplicities `χ_g`, in Table 8's column order (`7A, 7B` etc. share). -/
def chiShadow : List ℤ :=
  [24, 8, 0, 6, 0, 0, 4, 0, 4, 2, 0, 3, 3, 2, 0, 2, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1]

/-- **The twined shadow multiplicity is a trace.** For every class, `χ_g = χ₁(g) + χ₂(g)`, the trace of
`g` on the permutation representation `1 ⊕ 23` of `M₂₄` on 24 points; at `g = 1A` it is `24`. -/
theorem shadow_coeff_eq_perm_trace :
    (List.range 26).map (fun j => traceQ j ([1, 1] ++ List.replicate 24 0)) = chiShadow.map (·, 0) := by
  decide

end DualScaleMoonshine
