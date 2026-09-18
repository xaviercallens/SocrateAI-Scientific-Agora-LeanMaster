/-
Stream 8 · which K3? — the attractive (ρ = 20) K3 surfaces, the dyon charges and the immortal index share
one object: reduced binary quadratic forms.

### Sources (Tier L)
* Huybrechts (`huybrechts_K3Global.txt`) Cor. 14.3.21, ll. 13658–13696: complex K3 surfaces with `ρ(X) = 20`
  are in bijection (via `T(X)`) with positive definite, even, oriented rank-2 lattices `[[2a, b], [b, 2c]]`,
  `Δ = b² − 4ac < 0`, up to `SL(2, ℤ)`; Remark 3.22: `X` is a double cover of the Kummer surface of `E₁ × E₂`,
  `τ₁ = (−b + √Δ)/2a`, `τ₂ = (b + √Δ)/2`; Remark 3.24 (with Cor. 3.20, ll. 13630–13633): `X` is a Kummer
  surface iff `(α)² ≡ 0 (mod 4)` for all `α ∈ T(X)`; ll. 2109–2112: the Fermat quartic has
  `T(X) ≅ ℤ(8) ⊕ ℤ(8)`.
* Moore, *Arithmetic and Attractors* (`hep-th_9807087.txt`): for black holes in K3 × T² the discriminant
  `D` controls the horizon area (ll. 1150–1160); the number of U-duality inequivalent charges is
  `N(D) = h(D)` for primitive charges (3.17) and `N(D) = Σ_m h(D/m²)` in general (3.18), ll. 1250–1262,
  i.e. the number of `SL(2, ℤ)`-classes of all forms (primitive or not) of discriminant `D`; the attractor
  K3 surfaces are the attractive (ρ = 20) ones (ll. 1410–1425).
* DMZ via `Immortal.lean`: the single-centred index at `m = 1` involves the Hurwitz class numbers
  `H(Δ)`, which weight the forms `a(x² + y²)` by `1/2` and `a(x² + xy + y²)` by `1/3`.

### What is proved (Tier A, finite checks)
* `nForms D` counts reduced forms of discriminant `−D` (= Moore's `N(−D)` = the number of attractive K3
  surfaces with `det T(X) = D`, by the two Tier L bijections above).
* `moore_vs_hurwitz`: for every `D ≤ 400`, `12·N(D) = 12·H(D) + 6·[D = 4f²] + 8·[D = 3f²]`: counting attractor
  backgrounds and the immortal index's class-number coefficient agree **except** at the discriminants of the
  two self-dual points of the torus, `τ = i` (`D = 4f²`) and `τ = e^{2πi/3}` (`D = 3f²`), where the extra
  automorphisms carry the weights `1/2`, `1/3`.
* `kummer_iff_even`, `first_kummer_attractive`: an attractive K3 is Kummer iff `a, b, c` are all even
  (Remark 3.24 on `[[2a,b],[b,2c]]`); the smallest discriminants with a Kummer attractive K3 are `12`
  (`2·(1,1,1)`, over `τ = e^{2πi/3}`) and `16` (`2·(1,0,1)`, over `τ = i`).
* `fermat_quartic_form`: the Fermat quartic's `T(X) = ℤ(8) ⊕ ℤ(8)` is the reduced form `(4,0,4)` of `D = 64`,
  a Kummer form on the `τ = i` ray.
* `most_attractive`: `D = 3` and `D = 4` each carry exactly one attractive K3 (`(1,1,1)`, `(1,0,1)`).

### Not claimed
Which K3 describes our universe (K3 × T² is `N = 4`, non-chiral, Stream 7); that the immortal index
"counts" attractor backgrounds (Tier C, a thought experiment: `docs/STREAM8_WHICH_K3.md`).
-/
import DualScaleDyons.Immortal

namespace DualScaleDyons

/-- Reduced forms `(a, b, c)` with `b² − 4ac = −D`: `|b| ≤ a ≤ c`, `b ≥ 0` if `|b| = a` or `a = c`. -/
def reducedForms (D : ℕ) : List (ℤ × ℤ × ℤ) :=
  ((List.range (D + 1)).filter fun a => 0 < a ∧ 3 * a * a ≤ D).flatMap fun a =>
    ((List.range (2 * a)).filterMap fun i =>
      let b : ℤ := (i : ℤ) - a + 1
      let num := b * b + D
      if num % (4 * a) ≠ 0 then none else
        let c := num / (4 * a)
        if c < a then none else
        if b < 0 ∧ c = a then none else some ((a : ℤ), b, c))

/-- `N(D)`: the number of reduced forms of discriminant `−D` (all classes, primitive or not). -/
def nForms (D : ℕ) : ℕ := (reducedForms D).length

/-- `D = k f²` for some `f`. -/
def isKSquare (k D : ℕ) : Bool := (List.range (D + 1)).any fun f => k * f * f = D

/-- **Moore's count vs Hurwitz's weighted count.** For `D ≤ 400` (`D ≡ 0, 3 mod 4`, `D ≥ 3`):
`12·N(D) = 12H(D) + 6·[D = 4f²] + 8·[D = 3f²]`. -/
theorem moore_vs_hurwitz :
    (List.range 401).all (fun D => D < 3 || D % 4 == 1 || D % 4 == 2 ||
      (12 * (nForms D : ℤ) == h12 D + (if isKSquare 4 D then 6 else 0) + (if isKSquare 3 D then 8 else 0))) = true := by
  decide +kernel

/-- An attractive K3 with `T(X) = [[2a,b],[b,2c]]` is Kummer iff all values of `T(X)` are `≡ 0 mod 4`,
i.e. iff `a, b, c` are even: checked on the generators `x² , y², (x+y)²` of the value set mod 4. -/
def isKummerForm (f : ℤ × ℤ × ℤ) : Bool :=
  (2 * f.1) % 4 == 0 && (2 * f.2.2) % 4 == 0 && (2 * f.1 + 2 * f.2.1 + 2 * f.2.2) % 4 == 0

theorem kummer_iff_even :
    (List.range 201).all (fun D => (reducedForms D).all fun f =>
      isKummerForm f == (f.1 % 2 == 0 && f.2.1 % 2 == 0 && f.2.2 % 2 == 0)) = true := by decide +kernel

/-- The smallest discriminants carrying a Kummer attractive K3 are `12` and `16`. -/
theorem first_kummer_attractive :
    ((List.range 17).filter fun D => (reducedForms D).any isKummerForm) = [12, 16] ∧
      reducedForms 12 = [(1, 0, 3), (2, 2, 2)] ∧ (reducedForms 16).contains (2, 0, 2) := by decide +kernel

/-- The two most attractive K3 surfaces: `D = 3` and `D = 4` each carry one form, neither Kummer. -/
theorem most_attractive :
    reducedForms 3 = [(1, 1, 1)] ∧ reducedForms 4 = [(1, 0, 1)] ∧
      isKummerForm (1, 1, 1) = false ∧ isKummerForm (1, 0, 1) = false := by decide +kernel

/-- The Fermat quartic, `T(X) = ℤ(8) ⊕ ℤ(8) = [[2·4, 0], [0, 2·4]]`: the reduced Kummer form `(4,0,4)` of `D = 64`. -/
theorem fermat_quartic_form : (reducedForms 64).contains (4, 0, 4) ∧ isKummerForm (4, 0, 4) = true := by
  decide +kernel

end DualScaleDyons
