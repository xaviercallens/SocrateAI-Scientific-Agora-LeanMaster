/-
Stream 5 · P5.7 — `M₂₄`-twisted dyons: the twining test on the dyon partition function itself.

### Sources (Tier L)
* Cheng (`papers/foundations/1005_5415.txt`) (3.9)–(3.11), ll. 916–975: the twisted denominator
  `Φ_g(Ω) = e^{4πi(ρ,Ω)} Π_α exp(−Σ_{k≥1} (1/k) c_{g^k}(|α|²) e^{2πi k(α,Ω)})`, built from the twisted K3
  elliptic genera `Z_{g^k}`; `1/Φ_g` is proposed as the generating function of `g`-twisted quarter-BPS
  indices, and its pole at `ν → 0` factorises into two twisted half-BPS functions `1/η_g`.
* Cheng (2.5)–(2.9), ll. 415–457: `Z_g = (χ(g)/12)φ₀,₁ + (…)φ₋₂,₁`, `χ(g) = Z_g(τ,0) = Tr_{1⊕23}(g)`.
  Equivalently (CDH (4.18) with `Shadow.lean`'s decomposition, as derived there): `Z_g = (χ_g/24)Z − F_g·A`,
  with `F_g` the weight-2 forms of CDH Table 3 (`TwiningAll`).

### Method
`24D·Z_g = Dχ_g·Z − (24D·F_g)·A` for each of the 26 classes, from Stream 4's data; `c_g(D)` read off `Z_g`.
For each root `(r, s, t)` the twisted factor is `Σ_n h_n x^n` with `h_n` the complete homogeneous
functions of the "eigenvalues", from the power sums `p_k = c_{g^k}(4rs − t²)` by Newton's identities
`n·h_n = Σ_{k ≤ n} p_k h_{n−k}` (exact integer divisions, checked); `g^k` from CDH's power maps.

### What is proved (Tier A; `p ≤ p²`, `q ≤ q²`)
* `twined_genus_exact`, `twined_genus_index1`, `twined_genus_z0`: the 26 twisted elliptic genera are
  integral, index-1 (coefficients depend only on `4n − l²`), and `Z_g(τ,0) = χ_g`.
* `twisted_product_untwisted`: at `g = 1A` the twisted product is `dmvv 2 2`.
* `twisted_goettsche`: at `z = 0` the `p`-coefficients are the twined Göttsche numbers of
  `TwinedHilbert` (the `p`-side of Cheng's factorisation (3.11) into `1/η_g`).
* `twisted_dyons_are_characters`: every coefficient of `G₁^{(g)}, G₂^{(g)}` is a virtual character of `M₂₄`.
* `twisted_polar_removes_pole`: for all 26 classes, the polar part `T₂(g)·A₂,₁` removes the double pole.
* `twisted_immortal_are_characters`: every coefficient of the twisted single-centred counting function
  `∆ψ₁,g^F` is a virtual character of `M₂₄`; `twisted_immortal_example`: the `q¹y⁰` coefficient `−1800` is
  `2·1 + 2·23 + 2·45 + 2·4̅5̅ − 231 − 2̅3̅1̅ + 2·252 − 1035′ − 1035″`.

Honest scope: given that the twisted genera are characters (Gannon's theorem, Tier L), the later steps
are linear and class-independent, so character-valuedness is expected; the content is the certified
end-to-end computation from Stream 4's modular data and CDH's power maps. That `1/Φ_g` counts twisted
dyons, and any `M₂₄` action on black-hole microstates, is Tier L/C.
-/
import DualScaleDyons.Immortal
import DualScaleDyons.TwinedHilbert
import DualScaleMoonshine.TwiningAll

namespace DualScaleDyons

open DualScaleMoonshine

/-- `(D, χ_g, 24D·F_g)` for the 26 classes in Table 8's column order (Stream 4 data, through `q⁹`). -/
def classData : List (ℕ × ℤ × List ℤ) :=
  let z : List ℤ := List.replicate 10 0
  [ (1, 24, z), (1, 8, lambda24 9 2 (-16)), dataF2B, (1, 6, lambda24 9 3 (-6)), dataF3B, dataF4A, dataF4B,
    dataF4C, (1, 4, lambda24 9 5 (-2)), dataF6A, dataF6B, (1, 3, lambda24 9 7 (-1)), (1, 3, lambda24 9 7 (-1)),
    dataF8A, dataF10A, dataF11A, dataF12A, dataF12B, dataF14AB, dataF14AB, dataF15AB, dataF15AB,
    dataF21AB, dataF21AB, dataF23AB, dataF23AB ]

/-- `24D·Z_g` through `q^N`. -/
def zTwRaw (j N : ℕ) : Ser :=
  let d := classData.getD j (1, 0, [])
  let F : Ser := (List.range (N + 1)).map fun n => LP.const (d.2.2.getD n 0)
  Ser.sub (Ser.scale ((d.1 : ℤ) * d.2.1) (ellipticGenus N)) (Ser.mul F (phiA N))

/-- `Z_g` through `q^N`. -/
def zTw (j N : ℕ) : Ser := Ser.divInt (24 * ((classData.getD j (1, 0, [])).1 : ℤ)) (zTwRaw j N)

theorem twined_genus_exact :
    (List.range 26).all (fun j => (zTwRaw j 4).all fun p =>
      p.2.all fun c => c % (24 * ((classData.getD j (1, 0, [])).1 : ℤ)) == 0) = true := by decide +kernel

/-- `c_g(D)` from `Z_g` (at `l ∈ {0, 1}`). -/
def cTw (j : ℕ) (D : ℤ) : ℤ :=
  if D < -1 then 0 else
    let l : ℤ := if D % 4 = 0 then 0 else 1
    if (D + l * l) % 4 ≠ 0 then 0 else ((zTw j 4).getD ((D + l * l) / 4).toNat LP.zero).coef l

theorem twined_genus_index1 :
    (List.range 26).all (fun j => (List.range 5).all fun n => (List.range 13).all fun i =>
      let l : ℤ := (i : ℤ) - 6
      ((zTw j 4).getD n LP.zero).coef l == cTw j (4 * n - l * l)) = true := by decide +kernel

theorem twined_genus_z0 :
    (List.range 26).all (fun j => (zTw j 4).map LP.eval1 == [chiShadow.getD j 0, 0, 0, 0, 0]) = true := by
  decide +kernel

/-- Newton: complete homogeneous `h₀ … h_J` from power sums `p₁ … p_J` (`n·h_n = Σ p_k h_{n−k}`). -/
def newtonH (ps : List ℤ) (J : ℕ) : List ℤ :=
  (List.range J).foldl (fun h i =>
    let n := i + 1
    h ++ [((List.range n).foldl (fun acc k => acc + ps.getD k 0 * h.getD (n - 1 - k) 0) 0) / n]) [1]

/-- The same sums, before division, to check exactness. -/
def newtonExact (ps : List ℤ) (J : ℕ) : Bool :=
  let h := newtonH ps J
  (List.range J).all fun i =>
    let n := i + 1
    ((List.range n).foldl (fun acc k => acc + ps.getD k 0 * h.getD (n - 1 - k) 0) 0) % n == 0

/-- Class of `g^k`, `k ≤ 2` (power maps of CDH Table 8). -/
def powClass (j k : ℕ) : ℕ := if k ≤ 1 then j else ((powerMaps.getD 0 (2, [])).2).getD j 0

/-- Multiply by `Σ_n h_n x^n`, `x = p^r q^s y^t`. -/
def mulSeriesFactor (G : Ser3) (r s : ℕ) (t : ℤ) (h : List ℤ) : Ser3 :=
  (List.range G.length).map fun R =>
    let row := G.getD R []
    (List.range row.length).map fun S =>
      (List.range (R / r + 1)).foldl (fun acc j =>
        if s * j ≤ S then acc.add (LP.mono (h.getD j 0) (t * j) ((G.getD (R - r * j) []).getD (S - s * j) LP.zero))
        else acc) LP.zero

/-- The power sums `p_k = c_{g^k}(D)`, `k = 1 … J`. -/
def powerSums (j : ℕ) (D : ℤ) (J : ℕ) : List ℤ := (List.range J).map fun i => cTw (powClass j (i + 1)) D

/-- The twisted DMVV product `Σ_k G_k^{(g)} p^k`, truncated at `p^K`, `q^Q` (`K ≤ 2`). -/
def dmvvTw (j K Q : ℕ) : Ser3 :=
  let init : Ser3 := (List.range (K + 1)).map fun R => if R = 0 then Ser.one Q else List.replicate (Q + 1) LP.zero
  (List.range K).foldl (fun G i =>
    let r := i + 1
    (List.range (Q + 1)).foldl (fun G s =>
      let tm : ℕ := 2 * r * s + 1
      (List.range (2 * tm + 1)).foldl (fun G jj =>
        let t : ℤ := (jj : ℤ) - tm
        let D : ℤ := 4 * r * s - t * t
        if D < -1 then G else mulSeriesFactor G r s t (newtonH (powerSums j D (K / r)) (K / r))) G) G) init

theorem newton_exact :
    (List.range 26).all (fun j => (dmvvDs 2 2).all fun D => newtonExact (powerSums j D 2) 2) = true := by
  decide +kernel

theorem twisted_product_untwisted :
    (List.range 3).all (fun k => Ser.eqB ((dmvvTw 0 2 2).getD k []) ((dmvv 2 2).getD k [])) = true := by
  decide +kernel

/-- At `z = 0`, the twisted product gives the twined Göttsche numbers (`TwinedHilbert.twinedHilb`). -/
theorem twisted_goettsche :
    (List.range 26).all (fun j => (List.range 3).all fun k =>
      ((dmvvTw j 2 2).getD k []).map LP.eval1 == [twinedHilb j k, 0, 0]) = true := by decide +kernel

/-- Is the class function `f` (values at the 26 classes) a virtual character? -/
def isVirtualChar (f : List ℤ) : Bool :=
  (List.range 26).all fun i =>
    let v := inner4 (f.map fun a => (a, 0)) (charTab.getD i [])
    v.2.1 == 0 && v.2.2.1 == 0 && v.2.2.2 == 0 && v.1 % 244823040 == 0

/-- Coefficient `q^n y^l` of a family of series indexed by class. -/
def classFn (fam : ℕ → Ser) (n : ℕ) (l : ℤ) : List ℤ := (List.range 26).map fun j => ((fam j).getD n LP.zero).coef l

/-- **Every coefficient of the twisted dyon functions `G₁^{(g)}, G₂^{(g)}` is a virtual `M₂₄`-character.** -/
theorem twisted_dyons_are_characters :
    [1, 2].all (fun k => (List.range 3).all fun n => (List.range 17).all fun i =>
      isVirtualChar (classFn (fun j => (dmvvTw j 2 2).getD k []) n ((i : ℤ) - 8))) = true := by decide +kernel

/-- `T₂(g)·A·A₂,₁` removes the double pole of every twisted `ψ₁,g`. -/
def twistedNum (j : ℕ) : Ser :=
  Ser.sub ((dmvvTw j 2 2).getD 2 []) (Ser.scale (twinedHilb j 2) (aTimesA2m 1 2))

theorem twisted_polar_removes_pole : (List.range 26).all (fun j => vanish2 (twistedNum j)) = true := by
  decide +kernel

/-- The twisted single-centred counting function `∆ψ₁,g^F`, through `q²`. -/
def twistedImmortal (j : ℕ) : Ser := divByA (twistedNum j) 2

/-- **The twisted immortal (single-centred) dyon coefficients at `m = 1` are virtual `M₂₄`-characters.** -/
theorem twisted_immortal_are_characters :
    (List.range 3).all (fun n => (List.range 17).all fun i =>
      isVirtualChar (classFn twistedImmortal n ((i : ℤ) - 8))) = true := by decide +kernel

/-- The `q¹y⁰` coefficient `−1800 = 2·1 + 2·23 + 2·45 + 2·4̅5̅ − 231 − 2̅3̅1̅ + 2·252 − 1035′ − 1035″`. -/
theorem twisted_immortal_example :
    (List.range 26).map (fun i =>
      (inner4 ((classFn twistedImmortal 1 0).map fun a => (a, 0)) (charTab.getD i [])).1 / 244823040) =
      [2, 2, 2, 2, -1, -1, 2, 0, 0, 0, 0, 0, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] := by decide +kernel

end DualScaleDyons
