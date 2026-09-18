/-
Stream 5 · P5.5 — the single-centred ("immortal") dyons at `m = 1` are counted by class numbers.

### Sources (Tier L; DMZ, `papers/foundations/1208_4074.txt`)
* (1.6), ll. 424–443: `ψ_m = ψ_m^F + ψ_m^P`; `ψ_m^F` counts single-centred (immortal) black holes,
  `ψ_m^P` multi-centred configurations; the Fourier coefficients of `ψ_m^F` do not depend on moduli.
* Example 5, ll. 3530–3558: for `ϕ = B²/A`, the finite part has coefficients `C(∆)`
  `= 1, 22, 152, −636, 3831, −7544, 33224, −53392, 191937` (`∆ = −1, 0, 3, 4, 7, 8, 11, 12, 15`), those of
  `E₄A` are `C*(∆) = 1, −2, 248, −492, 4119, −7256, 33512, −53008, 192513`, and `C − C* = −288·H(∆)`
  with `H(∆)` the Hurwitz–Kronecker class numbers; so `ϕ^F = E₄A − 288H`.
* (9.8), (9.10), ll. 3740–3780: `Φ₂,₁^opt = −2H`.
* (5.16), l. 1880: `4∆ψ₁ = 9A⁻¹B² + 3E₄A`, i.e. `∆ψ₁ = (9/4)·B²/A + (3/4)·E₄A`. Taking finite parts
  with Example 5 (`E₄A` has no pole): `∆ψ₁^F = (9/4)(E₄A − 288H) + (3/4)E₄A = 3E₄A − 648H` — the form
  checked below, where the polar part removed is `(9/4)·144·A₂,₁ = 324·A₂,₁ = p₂₄(2)·A₂,₁`.

### Hurwitz class numbers (computed, not transcribed)
`12H(D)` for `D > 0` counts the reduced binary quadratic forms `(a, b, c)`, `b² − 4ac = −D`
(`|b| ≤ a ≤ c`, `b ≥ 0` if `|b| = a` or `a = c`; all forms, not only primitive ones) with weight 12,
except weight 6 for `a(x² + y²)` and 4 for `a(x² + xy + y²)`; `12H(0) = −1`.

### What is proved (Tier A)
* `hurwitz_values`: `H(0), H(3), H(4), H(7), H(8), H(11), H(12), H(15) = −1/12, 1/3, 1/2, 1, 1, 1, 4/3, 2`.
* `example5_tables`: from our series, the coefficients of `E₄A` are DMZ's printed `C*(∆)`, those of the
  finite part of `B²/A` are the printed `C(∆)`, and `C − C* = −288H` — a transcription control.
* `immortal_m1`: the single-centred counting function `∆ψ₁^F = (G₂ − 324·A·A₂,₁)/A`, computed from the
  DMVV product (i.e. from the K3 elliptic genus) with the two-centred part removed in the strip
  `|q| < |y| < 1`, equals `3E₄A − 648H` through `q³`. The division by `A` is exact (`immortal_m1_exact`).
* `immortal_m1_needs_H`: without the class-number term the identity fails.

### Not proved
That `ψ₁^F` counts single-centred black holes, its mock modularity, or anything past `q³` (Tier L).
-/
import DualScaleDyons.DMVV

namespace DualScaleDyons

open DualScaleMoonshine

/-- `12·H(D)`, Hurwitz–Kronecker class number times 12, by counting reduced forms. -/
def h12 (D : ℤ) : ℤ :=
  if D = 0 then -1 else
  if D < 0 ∨ D % 4 = 1 ∨ D % 4 = 2 then 0 else
  ((List.range (D.toNat + 1)).filter fun a => 0 < a ∧ 3 * a * a ≤ D.toNat).foldl (fun tot a =>
    (List.range (2 * a)).foldl (fun tot i =>
      let b : ℤ := (i : ℤ) - a + 1
      let num := b * b + D
      if num % (4 * a) ≠ 0 then tot else
        let c := num / (4 * a)
        if c < a then tot else
        if b < 0 ∧ c = a then tot else
          tot + (if b = 0 ∧ c = a then 6 else if b = a ∧ c = a then 4 else 12)) tot) 0

theorem hurwitz_values :
    [0, 3, 4, 7, 8, 11, 12, 15].map h12 = [-1, 4, 6, 12, 12, 12, 16, 24] := by decide

/-- Coefficient of the monomial `qⁿ yʳ`. -/
def coefAt (s : Ser) (n : ℕ) (r : ℤ) : ℤ := (s.getD n LP.zero).coef r

/-- Divide a Laurent polynomial by `(y − 1)`; exact when `p(1) = 0`. -/
def LP.divYm1 (p : LP) : LP :=
  (p.1, (List.range (p.2.length - 1)).map fun i => -(((p.2.take (i + 1)).sum)))

/-- `y · p / (y − 1)²`. -/
def LP.divA0 (p : LP) : LP := LP.divYm1 (LP.divYm1 (LP.mono 1 1 p))

/-- Divide a series by `A = y⁻¹(y−1)² R`: first by `R` (series), then by `(y−1)²/y` coefficientwise. -/
def divByA (s : Ser) (N : ℕ) : Ser :=
  ((s.mulBins (facs N (-1) 0 4)).divBins (facs N (-1) 1 2 ++ facs N (-1) (-1) 2)).map LP.divA0

/-- Numerator of `∆ψ₁^F`: `G₂ − 324·A·A₂,₁`, through `q³`. -/
def immortalNum : Ser := Ser.sub ((dmvv 2 3).getD 2 []) (Ser.scale (p24 2) (aTimesA2m 1 3))

/-- `∆ψ₁^F`. -/
def immortalM1 : Ser := divByA immortalNum 3

/-- `H(τ, z) = Σ H(4n − r²) qⁿ yʳ`, times 12, through `q^N`. -/
def hurwitzSer (N : ℕ) : Ser :=
  (List.range (N + 1)).map fun n =>
    let w : ℕ := 2 * n + 1
    ((-(w : ℤ)), (List.range (2 * w + 1)).map fun i => h12 (4 * (n : ℤ) - ((i : ℤ) - (w : ℤ)) ^ 2))

/-- The division by `A` is exact: `immortalNum` vanishes to second order at `y = 1`. -/
theorem immortal_m1_exact : vanish2 immortalNum = true := by decide +kernel

/-- **Immortal dyons at `m = 1` are counted by class numbers**: `∆ψ₁^F = 3E₄A − 648H` through `q³`. -/
theorem immortal_m1 :
    Ser.eqB immortalM1 (Ser.sub (Ser.scale 3 (Ser.mul (e4 3) (phiA 3))) (Ser.scale 54 (hurwitzSer 3))) = true := by
  decide +kernel

/-- **Negative control**: without the class-number term, the finite part is not `3E₄A`. -/
theorem immortal_m1_needs_H :
    Ser.eqB immortalM1 (Ser.scale 3 (Ser.mul (e4 3) (phiA 3))) = false := by decide +kernel

/-- `(B²/A)^F = (B² − 144·A·A₂,₁)/A`, DMZ's Example 5. -/
def example5F : Ser := divByA (Ser.sub (Ser.mul (phiB 3) (phiB 3)) (Ser.scale 144 (aTimesA2m 1 3))) 3

/-- **DMZ Example 5, transcription control**: the coefficients at `∆ = 0, 3, 4, 7, 8, 11, 12` of `E₄A`
and of `(B²/A)^F` (read at `(n, r) = (0,0), (1,1), (1,0), (2,1), (2,0), (3,1), (3,0)`) are the printed
`C*(∆)` and `C(∆)`, and `C − C* = −288H`. -/
theorem example5_tables :
    let pts : List (ℕ × ℤ) := [(0, 0), (1, 1), (1, 0), (2, 1), (2, 0), (3, 1), (3, 0)]
    pts.map (fun p => coefAt (Ser.mul (e4 3) (phiA 3)) p.1 p.2) = [-2, 248, -492, 4119, -7256, 33512, -53008] ∧
    pts.map (fun p => coefAt example5F p.1 p.2) = [22, 152, -636, 3831, -7544, 33224, -53392] ∧
    pts.all (fun p => 12 * (coefAt example5F p.1 p.2 - coefAt (Ser.mul (e4 3) (phiA 3)) p.1 p.2) ==
      -288 * h12 (4 * p.1 - p.2 * p.2)) := by decide +kernel

end DualScaleDyons
