/-
Stream 8 · P8.2 — attractor forms of explicit charges, and the smallest black hole (thought experiment G3).

A dyon of K3 × T² carries charges `(p, q)` in the K3 lattice. At the horizon the moduli flow to values fixed by
the charges: the K3 becomes the attractive surface with `T(S) = ⟨p, q⟩` and the `T²` gets the complex structure
`τ(p, q)`. Here the charge side is made explicit, and the smallest black hole is computed.

### Sources (Tier L)
* Moore, *Arithmetic and Attractors* (`hep-th_9807087.txt`):
  - (3.4)–(3.5), ll. 1104–1112: `Q_{p,q} = ½[[p², −p·q], [−p·q, q²]]`, `D = (p·q)² − p²q²`; supergravity needs
    `p² > 0`, `Q_{p,q} > 0`.
  - (3.11), ll. 1178–1190: for primitive `L_{p,q} = ⟨p, q⟩`, charges are U-dual iff their forms are
    `SL(2, ℤ)`-equivalent (Nikulin's uniqueness of the primitive embedding).
  - (3.17)–(3.18), ll. 1250–1262: `N(D) = Σ_m h(D/m²)`, the number of all form classes; "any form may be
    realized as `Q_{p,q}` for a primitive sublattice" (proved below for every form).
  - (4.4a)–(4.6), ll. 1356–1376: the attractor K3 has `Ω ∝ q − τ̄ p`, and `T²` has `τ = (p·q + √D)/p²`, the root
    of `p²τ² − 2p·qτ + q² = 0` (4.5); (4.8), ll. 1404–1409: `NS(S) = ⟨p, q⟩^⊥`, `T_S = ⟨p, q⟩`.
  - ll. 1480–1507: the abelian surfaces `A_Q = E_{τ₁} × E_{τ₂}` (4.15) with `ρ = 4` correspond one-to-one to
    `PSL(2, ℤ)` classes of `Q` (Shioda–Mitani); (4.27)–(4.29), ll. 1580–1600: the attractor variety is
    `S_{2Q} × E_{τ(p,q)}`, with `S_{2Q}` a double cover of `Km(E_τ × E_{τ'})`, `τ' = (−p·q + i√−D)/2`.
* DMZ (`1208_4074.txt`) (1.6), ll. 426–443: the Fourier coefficients of `ψ_m^F` count single-centred black holes
  (with the Stream 5 identity `∆ψ₁^F = 3E₄A − 648H`, `Immortal.immortal_m1`).
* Sen (`0708_1270.txt`) l. 6788: `d(Q, P) = 50064` for `Q² = P² = 2`, `Q·P = 0` (heterotic on `T⁶`).

### Conventions
Charges live in `U ⊕ U ⊂ U³ ⊕ E₈(−1)² = H²(K3, ℤ)` (a direct summand, so primitivity in `U ⊕ U` is primitivity in
`H²`), coordinates `(e₁, f₁, e₂, f₂)` with `eᵢ·fᵢ = 1`, `eᵢ² = fᵢ² = 0`. A form `(a, b, c)` means
`[[2a, b], [b, 2c]]`, discriminant `b² − 4ac`, as in `WhichK3`.

### What is proved (Tier A)
* `every_form_is_charged`: for all integers `a, b, c`, the charges `p = e₁ + a f₁`, `q = e₂ + b f₁ + c f₂` have
  Gram matrix `[[2a, b], [b, 2c]]` and span a primitive sublattice (every integral vector in their rational span is
  an integer combination of them). This is Moore's realisation claim, for every form.
* `charge_classes_small`: an independent enumeration of all charge pairs with coordinates in `{−1, 0, 1}`, primitive
  and positive definite, reduced under `SL(2, ℤ)`, finds exactly the reduced forms of `WhichK3` for `D = 3, 4, 7`
  and never a non-reduced or wrong one. (A larger box is in `tools/p82_charge_enumeration.py`, not kernel.)
* `discriminant_gap`: `4ac − b² > 0` forces `4ac − b² ≥ 3`, with `3` only for odd `b`.
* `smallest_black_hole`: `p² = q² = 2`, `p·q = 1` gives `T_S = [[2, 1], [1, 2]] = A₂ = T(X₃)`, `D = −3`, the unique
  class `(1, 1, 1)`; the Shioda–Inose tori of Moore (4.15) are `ω` and `ω + 1`.
* `attractor_tau`, `tau_minimal`: for every charge with `D < 0` the point `τ(p, q) = (p·q + i√−D)/p²` solves (4.5)
  and lies in the upper half plane; for the smallest black hole `τ = (1 + i√3)/2 = ω + 1`, `ω³ = 1`; for `D = −4`
  (`p·q = 0`), `τ = i`.
* `smallest_black_hole_index`: the Fourier coefficient of `ψ₁^F` at `(n, ℓ) = (1, 1)`, i.e. charges
  `(q²/2, p·q, p²/2) = (1, 1, 1)`, is `25353`; at `(1, 0)` (the `D = −4` black hole) it is `−50064`. Computed from
  Stream 5's series through `q³` and `1/η²⁴`. External anchor: Sen (`0708_1270.txt`, l. 6788) prints
  `d(Q, P) = 50064` for `Q² = P² = 2`, `Q·P = 0`, which matches the second value and fixes the sign convention
  `d = (−1)^{ℓ+1} c`; in that convention the `D = −3` black hole has `d = 25353` (not in Sen's table).

### Reading (Tier C) and scope
The smallest black hole with a horizon has near-horizon geometry `X₃ × E_ω`: the K3 of E2 ∩ G2, with the `T²` at
`τ = ω`, and the Shioda–Inose Kummer surface over `E_ω × E_ω` is the `D = 12` surface of Stream 8 §10. This breaks
G2's `i`/`ω` tie **for black holes**: the smallest horizon picks `ω`, the next one `i`. It says nothing about the
vacuum (E1's limit): the attractor fixes the near-horizon moduli of one black hole, not the asymptotic K3, and it
leaves the `T²` Kähler modulus free (Moore (4.3), ll. 1351–1353: an 88-dimensional attractor variety).
-/
import DualScaleDyons.WhichK3
import DualScaleDyons.Immortal

namespace DualScaleDyons.AttractorCharges

open DualScaleDyons DualScaleMoonshine

/-! ### Charges in `U ⊕ U` -/

/-- The pairing of `U ⊕ U` in coordinates `(e₁, f₁, e₂, f₂)`. -/
def pair (x y : Fin 4 → ℤ) : ℤ := x 0 * y 1 + x 1 * y 0 + x 2 * y 3 + x 3 * y 2

def chargeP (a : ℤ) : Fin 4 → ℤ := ![1, a, 0, 0]
def chargeQ (b c : ℤ) : Fin 4 → ℤ := ![0, b, 1, c]

/-- **Every form is the attractor form of a primitive charge pair** (Moore's realisation claim, (3.18)). -/
theorem every_form_is_charged (a b c : ℤ) :
    pair (chargeP a) (chargeP a) = 2 * a ∧ pair (chargeQ b c) (chargeQ b c) = 2 * c ∧
      pair (chargeP a) (chargeQ b c) = b ∧
      ∀ (x : Fin 4 → ℤ) (α β : ℚ), (∀ k, (x k : ℚ) = α * chargeP a k + β * chargeQ b c k) →
        ∀ k, x k = x 0 * chargeP a k + x 2 * chargeQ b c k := by
  refine ⟨by simp [pair, chargeP]; ring, by simp [pair, chargeQ]; ring, by simp [pair, chargeP, chargeQ], ?_⟩
  intro x α β hx k
  have h0 := hx 0
  have h2 := hx 2
  have hk := hx k
  simp [chargeP, chargeQ] at h0 h2
  have : ((x k : ℤ) : ℚ) = ((x 0 * chargeP a k + x 2 * chargeQ b c k : ℤ) : ℚ) := by
    push_cast
    rw [hk, h0, h2]
  exact_mod_cast this

/-! ### Enumeration: charge pairs versus reduced forms -/

/-- One step of Gauss reduction of a positive definite form. -/
def reduceStep (f : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  let (a, b, c) := f
  if c < a then (c, -b, a)
  else if a < b ∨ b < -a then
    let k := (a - b) / (2 * a)
    let b' := b + 2 * a * k
    (a, b', (b' * b' + (4 * a * c - b * b)) / (4 * a))
  else if b < 0 ∧ (b = -a ∨ a = c) then (a, -b, c)
  else f

/-- Gauss reduction (50 steps suffice for the forms below; the result is checked to be reduced). -/
def reduce (f : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ := (List.range 50).foldl (fun g _ => reduceStep g) f

/-- `L_{p,q}` is primitive iff the `2 × 2` minors of `(p, q)` have gcd 1. -/
def primitiveL (p q : Fin 4 → ℤ) : Bool :=
  ([(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)] : List (Fin 4 × Fin 4)).foldl
    (fun g ij => Int.gcd g (p ij.1 * q ij.2 - p ij.2 * q ij.1)) 0 == 1

def box1 : List (Fin 4 → ℤ) :=
  let r : List ℤ := [-1, 0, 1]
  r.flatMap fun a => r.flatMap fun b => r.flatMap fun c => r.map fun d => ![a, b, c, d]

/-- All `(D, reduced form)` from primitive, positive definite charge pairs in the box. -/
def chargeForms : List (ℕ × (ℤ × ℤ × ℤ)) :=
  box1.flatMap fun p => box1.filterMap fun q =>
    let a := pair p p / 2
    let b := pair p q
    let c := pair q q / 2
    if 0 < a ∧ 0 < c ∧ 0 < 4 * a * c - b * b ∧ primitiveL p q then
      some ((4 * a * c - b * b).toNat, reduce (a, b, c)) else none

/-- **Charges realise exactly the form classes.** In the box `{−1, 0, 1}⁴`, primitive positive definite charge pairs
give, after reduction, only reduced forms of the right discriminant, and for `D = 3, 4, 7` all of them. -/
theorem charge_classes_small :
    chargeForms.all (fun Df => (reducedForms Df.1).contains Df.2) = true ∧
      [3, 4, 7].all (fun D => (reducedForms D).all fun f => chargeForms.contains (D, f)) = true ∧
      (chargeForms.map (·.1)).min? = some 3 := by
  decide +kernel

/-! ### The smallest black hole -/

/-- **The discriminant gap.** A positive definite form has `4ac − b² ≥ 3`; `3` needs odd `b`. -/
theorem discriminant_gap (a b c : ℤ) (h : 0 < 4 * a * c - b * b) :
    3 ≤ 4 * a * c - b * b ∧ (4 * a * c - b * b = 3 → b % 2 = 1) := by
  rcases Int.emod_two_eq_zero_or_one b with hb | hb
  · obtain ⟨k, rfl⟩ : ∃ k, b = 2 * k := ⟨b / 2, by omega⟩
    have : 4 * a * c - 2 * k * (2 * k) = 4 * (a * c - k * k) := by ring
    constructor <;> [omega; omega]
  · obtain ⟨k, rfl⟩ : ∃ k, b = 2 * k + 1 := ⟨b / 2, by omega⟩
    have : 4 * a * c - (2 * k + 1) * (2 * k + 1) = 4 * (a * c - k * k - k) - 1 := by ring
    constructor <;> [omega; omega]

/-- **The smallest black hole.** `p = e₁ + f₁`, `q = e₂ + f₁ + f₂`: `p² = q² = 2`, `p·q = 1`, `T_S = A₂`, `D = −3`,
the single class `(1, 1, 1)`. Moore (4.15) for `(1, 1, 1)`: `τ₁ = (−1 + √−3)/2 = ω`, `τ₂ = (1 + √−3)/2 = ω + 1`. -/
theorem smallest_black_hole :
    (pair (chargeP 1) (chargeP 1), pair (chargeP 1) (chargeQ 1 1), pair (chargeQ 1 1) (chargeQ 1 1)) = (2, 1, 2) ∧
      (1 : ℤ) ^ 2 - 2 * 2 = -3 ∧ reducedForms 3 = [(1, 1, 1)] ∧ primitiveL (chargeP 1) (chargeQ 1 1) = true ∧
      reduce (1, -1, 1) = (1, 1, 1) := by
  decide +kernel

/-- **The attractor point of `T²`** (Moore (4.5)–(4.6)). For `p² > 0` and `D = (p·q)² − p²q² < 0`, the point
`τ = (p·q + i√−D)/p²` solves `p²τ² − 2(p·q)τ + q² = 0` and has `Im τ > 0`. -/
theorem attractor_tau (P2 PQ Q2 : ℝ) (hP : 0 < P2) (hD : PQ ^ 2 - P2 * Q2 < 0) :
    let τ : ℂ := ⟨PQ / P2, Real.sqrt (P2 * Q2 - PQ ^ 2) / P2⟩
    (P2 : ℂ) * τ ^ 2 - 2 * PQ * τ + Q2 = 0 ∧ 0 < τ.im := by
  intro τ
  have hs : Real.sqrt (P2 * Q2 - PQ ^ 2) ^ 2 = P2 * Q2 - PQ ^ 2 := Real.sq_sqrt (by linarith)
  have hpos : 0 < Real.sqrt (P2 * Q2 - PQ ^ 2) := Real.sqrt_pos.mpr (by linarith)
  refine ⟨?_, div_pos hpos hP⟩
  apply Complex.ext
  · simp only [τ, Complex.sub_re, Complex.add_re, Complex.mul_re, Complex.ofReal_re, Complex.ofReal_im,
      pow_two, Complex.zero_re, Complex.mul_im]
    norm_num
    field_simp
    nlinarith [hs]
  · simp only [τ, Complex.sub_im, Complex.add_im, Complex.mul_im, Complex.mul_re, Complex.ofReal_re,
      Complex.ofReal_im, pow_two, Complex.zero_im]
    norm_num
    field_simp
    ring

/-- **`τ` of the smallest black holes.** `(p², p·q, q²) = (2, 1, 2)` gives `τ = (1 + i√3)/2 = ω + 1` with
`ω = (−1 + i√3)/2`, `ω³ = 1`, `ω ≠ 1`; `(2, 0, 2)` (`D = −4`) gives `τ = i`. -/
theorem tau_minimal :
    ((⟨1 / 2, Real.sqrt (2 * 2 - 1 ^ 2) / 2⟩ : ℂ) = ⟨-1 / 2, Real.sqrt 3 / 2⟩ + 1) ∧
      (⟨-1 / 2, Real.sqrt 3 / 2⟩ : ℂ) ^ 3 = 1 ∧ (⟨-1 / 2, Real.sqrt 3 / 2⟩ : ℂ) ≠ 1 ∧
      ((⟨0 / 2, Real.sqrt (2 * 2 - 0 ^ 2) / 2⟩ : ℂ) = Complex.I) := by
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have h4 : Real.sqrt (2 * 2 - 0 ^ 2) = 2 := by
    rw [show (2 : ℝ) * 2 - 0 ^ 2 = 2 ^ 2 by norm_num]; exact Real.sqrt_sq (by norm_num)
  refine ⟨?_, ?_, ?_, ?_⟩
  · apply Complex.ext <;> simp <;> norm_num
  · apply Complex.ext
    · simp [pow_succ, Complex.mul_re, Complex.mul_im]; linear_combination (3 / 8 : ℝ) * h3
    · simp [pow_succ, Complex.mul_re, Complex.mul_im]; linear_combination (-(Real.sqrt 3) / 8) * h3
  · intro h
    have := congrArg Complex.re h
    simp at this
    norm_num at this
  · apply Complex.ext <;> simp

/-! ### How many single-centred states the smallest black holes carry -/

/-- Coefficient of `qⁿ yˡ` in `ψ₁^F = (∆ψ₁^F) · q⁻¹ Π(1 − qᵏ)⁻²⁴`, from `immortalM1` (valid for `n ≤ 2`). -/
def psi1F (n : ℕ) (l : ℤ) : ℤ :=
  (List.range (n + 2)).foldl (fun s k => s + p24 k * coefAt immortalM1 (n + 1 - k) l) 0

/-- **The smallest black holes are not empty.** `(n, ℓ, m) = (1, 1, 1)` (`D = −3`, `τ = ω`): `25353`;
`(1, 0, 1)` (`D = −4`, `τ = i`): `−50064`. The inputs are the coefficients of `3E₄A − 648H`
(`C(−1), C(3), C(7)` = 3, 528, 11709 and `C(0), C(4), C(8)` = 48, −1800, −22416). -/
theorem smallest_black_hole_index :
    [coefAt immortalM1 0 1, coefAt immortalM1 1 1, coefAt immortalM1 2 1] = [3, 528, 11709] ∧
      [coefAt immortalM1 0 0, coefAt immortalM1 1 0, coefAt immortalM1 2 0] = [48, -1800, -22416] ∧
      psi1F 1 1 = 25353 ∧ psi1F 1 0 = -50064 := by
  decide +kernel

end DualScaleDyons.AttractorCharges
