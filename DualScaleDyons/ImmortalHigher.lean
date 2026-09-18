/-
Stream 5 · P5.6 (part) — immortal dyons at `m = 2, 3`: class numbers through a Hecke-like operator.

### Sources (Tier L; DMZ, `papers/foundations/1208_4074.txt`)
* (9.11), ll. 3795–3815: `ϕ₂,₂^opt = (B³ − 3E₄A²B + 2E₆A³)/(12³A)`; its mock part `Φ₂,₂^opt` has coefficients
  `C(∆) = −H(∆)` if `∆ ≡ 7 (mod 8)`, `−H(∆) − 2H(∆/4)` if `4 | ∆` (`∆ = 8n − r²`), i.e. `Φ₂,₂^opt = −H|V₂`;
  printed table `C = 0, 0, 1/4, −1/2, −1, −1, −2, −2, −5/2` at `∆ = −4, −1, 0, 4, 7, 8, 12, 15, 16`.
* (9.12)–(9.13), ll. 3828–3846: `ψ₀,₄^opt = B⁴ − 6E₄A²B² + 8E₆A³B − 3E₄²A⁴`; `C(Φ₂,₃^opt; ∆) = −H(∆)` if
  `9 ∤ ∆`, `−H(∆) − 3H(∆/9)` if `9 | ∆`; printed `C = 0, 0, 0, 1/3, −1/3, −1, −1, −4/3, −2` at
  `∆ = −9, −4, −1, 0, 3, 8, 11, 12, 15`; `Φ₂,ₚ^opt = −H|V_p` for `p` prime (proved in DMZ §10).
* (5.16) and `p₂₄(3) = 3200`, `p₂₄(4) = 25650`. Combining (exact rational arithmetic, done by hand and
  checked by the theorems): `∆ψ₂ = 3200ϕ₂,₂^opt + (22/3)E₄AB − (10/3)E₆A²` and
  `∆ψ₃ = 25650ϕ₂,₃^opt + (467/48)E₄AB² − (215/24)E₆A²B + (203/48)E₄²A³`; taking finite parts,
  `3∆ψ₂^F = −9600·H|V₂ + 22E₄AB − 10E₆A²`, `48∆ψ₃^F = −1231200·H|V₃ + 467E₄AB² − 430E₆A²B + 203E₄²A³`.

### What is proved (Tier A, through `q²`)
* `dmz_911_table`, `dmz_912_table`: the class-number formulas reproduce DMZ's printed tables.
* `dmz_911_verified`, `dmz_913_verified_m3`: the finite parts of `ψ₀,₃^opt/A` and `ψ₀,₄^opt/A` (polar part
  `12^{m+1}A₂,ₘ` removed in the strip `|q| < |y| < 1`) are `−12^{m+1}·H|V_m` — DMZ's (9.11) and (9.13) at
  `m = 2, 3`, checked rather than cited.
* `immortal_m2`, `immortal_m3`: the single-centred counting functions `∆ψ_m^F`, computed from the DMVV
  product (i.e. from the K3 elliptic genus), equal `p₂₄(m+1)·(−H|V_m)` plus the weak Jacobi forms above.
  `immortal_exact_m23`: the divisions by `A` are exact.
* `immortal_m2_needs_V2`: with plain `H` instead of `H|V₂` (dropping `2H(∆/4)`) the identity fails.

### Not proved
Anything past `q²`; `m ≥ 4`; the general statement (9.13) (DMZ §10, Tier L).
-/
import DualScaleDyons.Immortal

namespace DualScaleDyons

open DualScaleMoonshine

/-- `12·(H|V_m)` for `m` prime: coefficient of `qⁿyʳ` is `12H(∆) + m·12H(∆/m²)·[m² ∣ ∆]`, `∆ = 4mn − r²`;
with `withV = false`, just `12H(∆)` (negative control). -/
def hurwitzVSer (m N : ℕ) (withV : Bool) : Ser :=
  (List.range (N + 1)).map fun n =>
    let w : ℕ := 2 * m * n + 1
    ((-(w : ℤ)), (List.range (2 * w + 1)).map fun i =>
      let r : ℤ := (i : ℤ) - (w : ℤ)
      let D : ℤ := 4 * (m : ℤ) * n - r ^ 2
      h12 D + (if withV ∧ 0 ≤ D ∧ D % ((m : ℤ) * m) = 0 then (m : ℤ) * h12 (D / ((m : ℤ) * m)) else 0))

/-- DMZ (9.11) printed table, times 12: `12C(Φ₂,₂^opt; ∆) = −(12H(∆) + 2·12H(∆/4))`. -/
theorem dmz_911_table :
    [-4, -1, 0, 4, 7, 8, 12, 15, 16].map (fun D : ℤ =>
      -(h12 D + (if 0 ≤ D ∧ D % 4 = 0 then 2 * h12 (D / 4) else 0))) =
      [0, 0, 3, -6, -12, -12, -24, -24, -30] := by decide

/-- DMZ (9.12) printed table, times 12: `12C(Φ₂,₃^opt; ∆) = −(12H(∆) + 3·12H(∆/9))`. -/
theorem dmz_912_table :
    [-9, -4, -1, 0, 3, 8, 11, 12, 15].map (fun D : ℤ =>
      -(h12 D + (if 0 ≤ D ∧ D % 9 = 0 then 3 * h12 (D / 9) else 0))) =
      [0, 0, 0, 4, -4, -12, -12, -16, -24] := by decide

/-- `ψ₀,₃^opt = B³ − 3E₄A²B + 2E₆A³` and `ψ₀,₄^opt = B⁴ − 6E₄A²B² + 8E₆A³B − 3E₄²A⁴`, through `q²`. -/
def psiOpt3 : Ser :=
  let A := phiA 2; let B := phiB 2; let E4 := e4 2; let E6 := e6 2
  Ser.add (Ser.add (mulAll [B, B, B] 2) (Ser.scale (-3) (mulAll [E4, A, A, B] 2))) (Ser.scale 2 (mulAll [E6, A, A, A] 2))
def psiOpt4 : Ser :=
  let A := phiA 2; let B := phiB 2; let E4 := e4 2; let E6 := e6 2
  Ser.add (Ser.add (mulAll [B, B, B, B] 2) (Ser.scale (-6) (mulAll [E4, A, A, B, B] 2)))
    (Ser.add (Ser.scale 8 (mulAll [E6, A, A, A, B] 2)) (Ser.scale (-3) (mulAll [E4, E4, A, A, A, A] 2)))

/-- **DMZ (9.11) checked**: `(ψ₀,₃^opt − 12³·A·A₂,₂)/A = −12³·H|V₂` (`12³/12 = 144`). -/
theorem dmz_911_verified :
    vanish2 (Ser.sub psiOpt3 (Ser.scale 1728 (aTimesA2m 2 2))) = true ∧
    Ser.eqB (divByA (Ser.sub psiOpt3 (Ser.scale 1728 (aTimesA2m 2 2))) 2)
      (Ser.scale (-144) (hurwitzVSer 2 2 true)) = true := by decide +kernel

/-- **DMZ (9.13) checked at `m = 3`**: `(ψ₀,₄^opt − 12⁴·A·A₂,₃)/A = −12⁴·H|V₃` (`12⁴/12 = 1728`). -/
theorem dmz_913_verified_m3 :
    vanish2 (Ser.sub psiOpt4 (Ser.scale 20736 (aTimesA2m 3 2))) = true ∧
    Ser.eqB (divByA (Ser.sub psiOpt4 (Ser.scale 20736 (aTimesA2m 3 2))) 2)
      (Ser.scale (-1728) (hurwitzVSer 3 2 true)) = true := by decide +kernel

/-- Numerator of `∆ψ_m^F`: `G_{m+1} − p₂₄(m+1)·A·A₂,ₘ`, through `q²`. -/
def immortalNumM (m : ℕ) : Ser := Ser.sub ((dmvv 4 2).getD (m + 1) []) (Ser.scale (p24 (m + 1)) (aTimesA2m m 2))

/-- `∆ψ_m^F`, through `q²`. -/
def immortalM (m : ℕ) : Ser := divByA (immortalNumM m) 2

theorem immortal_exact_m23 : vanish2 (immortalNumM 2) = true ∧ vanish2 (immortalNumM 3) = true := by
  decide +kernel

/-- **Immortal dyons at `m = 2`**: `3∆ψ₂^F = −800·(12H|V₂) + 22E₄AB − 10E₆A²` through `q²`. -/
theorem immortal_m2 :
    Ser.eqB (Ser.scale 3 (immortalM 2))
      (Ser.add (Ser.scale (-800) (hurwitzVSer 2 2 true))
        (Ser.add (Ser.scale 22 (mulAll [e4 2, phiA 2, phiB 2] 2)) (Ser.scale (-10) (mulAll [e6 2, phiA 2, phiA 2] 2)))) = true := by
  decide +kernel

/-- **Immortal dyons at `m = 3`**: `48∆ψ₃^F = −102600·(12H|V₃) + 467E₄AB² − 430E₆A²B + 203E₄²A³`. -/
theorem immortal_m3 :
    Ser.eqB (Ser.scale 48 (immortalM 3))
      (Ser.add (Ser.scale (-102600) (hurwitzVSer 3 2 true))
        (Ser.add (Ser.add (Ser.scale 467 (mulAll [e4 2, phiA 2, phiB 2, phiB 2] 2))
          (Ser.scale (-430) (mulAll [e6 2, phiA 2, phiA 2, phiB 2] 2)))
          (Ser.scale 203 (mulAll [e4 2, e4 2, phiA 2, phiA 2, phiA 2] 2)))) = true := by
  decide +kernel

/-- **Negative control**: with plain `H` instead of `H|V₂`, the `m = 2` identity fails. -/
theorem immortal_m2_needs_V2 :
    Ser.eqB (Ser.scale 3 (immortalM 2))
      (Ser.add (Ser.scale (-800) (hurwitzVSer 2 2 false))
        (Ser.add (Ser.scale 22 (mulAll [e4 2, phiA 2, phiB 2] 2)) (Ser.scale (-10) (mulAll [e6 2, phiA 2, phiA 2] 2)))) = false := by
  decide +kernel

end DualScaleDyons
