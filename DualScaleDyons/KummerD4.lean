/-
Stream 8 · G2 — "trapping in four dimensions": the `D₄` torus, its `ω` complex structure, and the Kummer surface.

Thought experiment G2 (`docs/STREAM8_WHICH_K3.md` §9) applies E2's trapping principle to the `T⁴` inside a Kummer
K3. The point of `T⁴` moduli with the most massless gauge bosons is `D₄` (24 roots). Its lattice is the Hurwitz
order, which contains both `i` and `ω = (−1 + i + j + k)/2`. With the complex structure that commutes with `ω`,
the torus has transcendental lattice `A₂`, the lattice `T(X₃)` of the most attractive K3. Its Kummer surface
therefore has `T = A₂(2)`, `D = 12`, the E2 ∩ E3 candidate.

### Sources (Tier L)
* GPR (`giveon_hep-th_9401139.txt`) ll. 1843–1847, 2510–2514: at a point of maximally enhanced symmetry of the
  Narain moduli of `T^d`, the enhanced group is simply laced of rank `d`, with `G = ½ Cartan`. The ADE list itself
  is standard.
* Aspinwall (`aspinwall_hep-th_9611137.txt`) ll. 474–482, 864–874, 1866–1868: a hyperkähler metric carries an `S²`
  of complex structures `q = bI + cJ + dK`, `b² + c² + d² = 1`. The positive 3-plane `Σ` spanned by the three
  Kähler forms splits into the holomorphic 2-plane `Ω` and the Kähler direction `J ⊥ Ω`, and the complex structure
  2-plane is `Ω = Σ ∩ (Λ ⊗ ℝ)` in the attractive case. For a flat `T⁴ = ℍ/Λ`, `Σ` is spanned by the Kähler forms
  `ω_X(v, w) = ⟨X v, w⟩` of left multiplication by `X = i, j, k`.
* Huybrechts ll. 13643–13644 and Remark 3.24 (ll. 13694–13697): `T(Km A) = T(A)(2)`, and Kummer iff `T = T'(2)`.
* Taormina–Wendland (`1107_3834.txt`) (3.3), ll. 1044–1055, and ll. 1961–1970: the Kummer surfaces of the square
  torus and of the `D₄` torus with the standard complex structure have `T = diag(4, 4)`.

### Conventions
`H²(ℝ⁴/Λ, ℤ)` = integer-valued alternating forms on `Λ`, stored by their values on the basis pairs
`(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)`. The intersection form is `α ∧ β` evaluated on `(e₀, e₁, e₂, e₃)`
(`wedge`).

### What is proved (Tier A)
* `trapping_rank_table`: the largest root system of rank `≤ d` in the ADE list has 2, 6, 12, 24, 40, 72, 126, 240
  roots for `d = 1 … 8`. For `d = 4` it is `D₄` alone: `A₄` has 20, and every non-simple choice has at most 14.
* `hurwitz_units`: the Hurwitz lattice has exactly 24 vectors of norm 1, the 24 roots of `D₄` (rescaled).
* `omega_symmetry`: `ω = (−1 + i + j + k)/2` lies in the lattice, `ω³ = 1`, left multiplication by `ω` maps the
  lattice into itself, and `ω` commutes with `i + j + k`. So the complex structure `u = (i+j+k)/√3` has an
  order-3 symmetry.
* `sigma_plane`: on the Hurwitz lattice the three Kähler forms are wedge-orthogonal with equal squares 1. The two
  forms `g₁ = ω_i − ω_j`, `g₂ = ω_i + ω_j − 2ω_k` are wedge-orthogonal to the Kähler direction `ω_i + ω_j + ω_k`.
  They span the holomorphic plane `Ω` of `u`.
* `transcendental_omega`: `t₁ = ½g₁ − ½g₂` and `t₂ = −½g₁ − ½g₂` are integral 2-forms with Gram `[[2, 1], [1, 2]]`
  (`= A₂`), and `transcendental_omega_saturated` shows **every** integral 2-form in `span_ℚ(g₁, g₂)` is an integer
  combination of `t₁, t₂`. So `T(A) ≅ A₂`, the Gram matrix of `T(X₃)` (`WhichK3.most_attractive`).
* `kummer_d4_omega`: doubling gives `A₂(2)`, the form `(2, 2, 2)` of discriminant `−12`.
* `sanity_standard_structure`: the same construction with `u = i` gives `diag(2, 2)` both for `ℤ⁴` and for
  `D₄`, i.e. Kummer `diag(4, 4)`, reproducing TW (3.3) and their statement on the `D₄` torus.

### Reading (Tier C) and scope
Trapping in dimension 4 selects `D₄`. With the `ω` complex structure, which consistency with E2's `T²` at `(ω, ω)`
requires, the Kummer surface over it is the `D = 12` surface of E2 ∩ E3. Not settled here:
* trapping does not choose between the `i` and `ω` structures (a hyperkähler rotation);
* the ESP carries a `B`-field, and orbifold CFT points have `B = ½` (Aspinwall ll. 2540–2544);
* vector-multiplet couplings do not see the K3 point (Henningson–Moore, Stream 8 §8).
-/
import Mathlib

namespace DualScaleDyons.KummerD4

/-! ### Trapping: the largest simply-laced root system of each rank -/

/-- Simple ADE components `(rank, number of roots)` of rank `≤ 8`. -/
def adeSimple : List (ℕ × ℕ) :=
  ((List.range 8).map fun n => (n + 1, (n + 1) * (n + 2))) ++          -- A₁ … A₈
  ((List.range 5).map fun n => (n + 4, 2 * (n + 4) * (n + 3))) ++      -- D₄ … D₈
  [(6, 72), (7, 126), (8, 240)]                                        -- E₆, E₇, E₈

/-- `bestTable D = [b₀, b₁, …, b_D]`, `b_k` = most roots of a semisimple simply-laced system of rank `≤ k`
(dynamic programming over the simple components). -/
def bestTable (D : ℕ) : List ℕ :=
  (List.range D).foldl (fun b k =>
    b ++ [max (b.getD k 0) ((adeSimple.filter (·.1 ≤ k + 1)).foldl
      (fun m c => max m (c.2 + b.getD (k + 1 - c.1) 0)) 0)]) [0]

/-- **Trapping picks `A₂` in rank 2 and `D₄` in rank 4.** The maxima are the kissing numbers `2, 6, 12, 24, 40, 72,
126, 240`. In rank 4: the simple candidates are `A₄` (20) and `D₄` (24); splitting into two parts gives at most 14. -/
theorem trapping_rank_table :
    bestTable 8 = [0, 2, 6, 12, 24, 40, 72, 126, 240] ∧
      (adeSimple.filter (·.1 = 4)).map (·.2) = [20, 24] ∧
      [(1, 3), (2, 2), (3, 1)].map (fun r => (bestTable 8).getD r.1 0 + (bestTable 8).getD r.2 0) = [14, 12, 14] ∧
      (adeSimple.filter (·.1 = 2)).map (·.2) = [6] := by
  decide

/-! ### Quaternions and the Hurwitz lattice -/

/-- Quaternion product, coordinates `(1, i, j, k)`. -/
def qmul (p q : Fin 4 → ℚ) : Fin 4 → ℚ :=
  ![p 0 * q 0 - p 1 * q 1 - p 2 * q 2 - p 3 * q 3, p 0 * q 1 + p 1 * q 0 + p 2 * q 3 - p 3 * q 2,
    p 0 * q 2 - p 1 * q 3 + p 2 * q 0 + p 3 * q 1, p 0 * q 3 + p 1 * q 2 - p 2 * q 1 + p 3 * q 0]

def dot (v w : Fin 4 → ℚ) : ℚ := v 0 * w 0 + v 1 * w 1 + v 2 * w 2 + v 3 * w 3

def qI : Fin 4 → ℚ := ![0, 1, 0, 0]
def qJ : Fin 4 → ℚ := ![0, 0, 1, 0]
def qK : Fin 4 → ℚ := ![0, 0, 0, 1]

/-- The Hurwitz order (the `D₄` lattice, rescaled): basis `(1+i+j+k)/2, i, j, k`. -/
def hurwitz : Fin 4 → Fin 4 → ℚ := ![![1/2, 1/2, 1/2, 1/2], qI, qJ, qK]

/-- The standard lattice `ℤ⁴`. -/
def square : Fin 4 → Fin 4 → ℚ := ![![1, 0, 0, 0], qI, qJ, qK]

/-- Coordinates of `v` in the Hurwitz basis. -/
def hurwitzCoords (v : Fin 4 → ℚ) : Fin 4 → ℚ := ![2 * v 0, v 1 - v 0, v 2 - v 0, v 3 - v 0]

def inHurwitz (v : Fin 4 → ℚ) : Bool := (List.finRange 4).all fun m => (hurwitzCoords v m).den == 1

/-- **24 units.** Among the `v` with coordinates in `{−1, −½, 0, ½, 1}`, which contains every vector of norm 1,
exactly 24 lie in the Hurwitz lattice with norm 1: the 24 roots of `D₄`. -/
theorem hurwitz_units :
    (let r : List ℚ := [-1, -1/2, 0, 1/2, 1]
     (r.flatMap fun a => r.flatMap fun b => r.flatMap fun c => r.map fun d => (![a, b, c, d] : Fin 4 → ℚ)).filter
       (fun v => inHurwitz v && dot v v == 1)).length = 24 ∧
      (List.finRange 4).all (fun m => inHurwitz (hurwitz m)) = true := by
  decide +kernel

/-- `ω = (−1 + i + j + k)/2`. -/
def omega : Fin 4 → ℚ := ![-1/2, 1/2, 1/2, 1/2]

/-- The complex structure `u = (i + j + k)/√3`, up to the positive factor `√3`. -/
def uOmega : Fin 4 → ℚ := ![0, 1, 1, 1]

/-- **An order-3 symmetry of the `ω` torus.** `ω` is a lattice vector, `ω³ = 1`, left multiplication by `ω` maps
the lattice to itself, and `ω` commutes with `u`. -/
theorem omega_symmetry :
    inHurwitz omega = true ∧ qmul omega (qmul omega omega) = ![1, 0, 0, 0] ∧
      (List.finRange 4).all (fun m => inHurwitz (qmul omega (hurwitz m))) = true ∧
      qmul omega uOmega = qmul uOmega omega := by
  decide +kernel

/-! ### 2-forms, the 3-plane `Σ` and the transcendental lattice

To stay in `ℤ`, lattice vectors are written with doubled coordinates, so `kahler4 L X = 4 ω_X` on the basis pairs.
-/

def qmulZ (p q : Fin 4 → ℤ) : Fin 4 → ℤ :=
  ![p 0 * q 0 - p 1 * q 1 - p 2 * q 2 - p 3 * q 3, p 0 * q 1 + p 1 * q 0 + p 2 * q 3 - p 3 * q 2,
    p 0 * q 2 - p 1 * q 3 + p 2 * q 0 + p 3 * q 1, p 0 * q 3 + p 1 * q 2 - p 2 * q 1 + p 3 * q 0]

def dotZ (v w : Fin 4 → ℤ) : ℤ := v 0 * w 0 + v 1 * w 1 + v 2 * w 2 + v 3 * w 3

def zI : Fin 4 → ℤ := ![0, 1, 0, 0]
def zJ : Fin 4 → ℤ := ![0, 0, 1, 0]
def zK : Fin 4 → ℤ := ![0, 0, 0, 1]

/-- Hurwitz basis, doubled: `1+i+j+k, 2i, 2j, 2k`. -/
def hurwitz2 : Fin 4 → Fin 4 → ℤ := ![![1, 1, 1, 1], ![0, 2, 0, 0], ![0, 0, 2, 0], ![0, 0, 0, 2]]

/-- Standard basis of `ℤ⁴`, doubled. -/
def square2 : Fin 4 → Fin 4 → ℤ := ![![2, 0, 0, 0], ![0, 2, 0, 0], ![0, 0, 2, 0], ![0, 0, 0, 2]]

def pairs : Fin 6 → Fin 4 × Fin 4 := ![(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]

/-- `4 ω_X` on the basis pairs of the lattice with doubled basis `L`. -/
def kahler4 (L : Fin 4 → Fin 4 → ℤ) (X : Fin 4 → ℤ) : Fin 6 → ℤ :=
  fun k => dotZ (qmulZ X (L (pairs k).1)) (L (pairs k).2)

/-- `α ∧ β` on the fundamental class. -/
def wedge (a b : Fin 6 → ℤ) : ℤ :=
  a 0 * b 5 - a 1 * b 4 + a 2 * b 3 + a 3 * b 2 - a 4 * b 1 + a 5 * b 0

/-- `4(ω_i − ω_j)`, `4(ω_i + ω_j − 2ω_k)`: they span the holomorphic plane of `u = (i+j+k)/√3`. -/
def G1 : Fin 6 → ℤ := fun k => kahler4 hurwitz2 zI k - kahler4 hurwitz2 zJ k
def G2 : Fin 6 → ℤ := fun k => kahler4 hurwitz2 zI k + kahler4 hurwitz2 zJ k - 2 * kahler4 hurwitz2 zK k

/-- `4(ω_i + ω_j + ω_k)`: the Kähler direction of `u`. -/
def Kdir : Fin 6 → ℤ := fun k => kahler4 hurwitz2 zI k + kahler4 hurwitz2 zJ k + kahler4 hurwitz2 zK k

/-- **`Σ` is round and `Ω_u ⊥ ω_u`.** The three Kähler forms are wedge-orthogonal with equal squares
(`16 · 1`, i.e. `ω_X ∧ ω_X = 1` on the Hurwitz lattice, of covolume ½), and `G₁, G₂` are orthogonal to the Kähler direction and to each other. -/
theorem sigma_plane :
    wedge (kahler4 hurwitz2 zI) (kahler4 hurwitz2 zI) = 16 * 1 ∧
      wedge (kahler4 hurwitz2 zJ) (kahler4 hurwitz2 zJ) = 16 * 1 ∧
      wedge (kahler4 hurwitz2 zK) (kahler4 hurwitz2 zK) = 16 * 1 ∧
      wedge (kahler4 hurwitz2 zI) (kahler4 hurwitz2 zJ) = 0 ∧ wedge (kahler4 hurwitz2 zI) (kahler4 hurwitz2 zK) = 0 ∧
      wedge (kahler4 hurwitz2 zJ) (kahler4 hurwitz2 zK) = 0 ∧
      wedge Kdir G1 = 0 ∧ wedge Kdir G2 = 0 ∧ wedge G1 G2 = 0 := by
  decide

def t1 : Fin 6 → ℤ := ![-1, 0, 1, 1, 1, 0]
def t2 : Fin 6 → ℤ := ![-1, 1, 0, 1, 0, -1]

/-- **`T(A) ≅ A₂` for the `ω` structure on the `D₄` torus**: `t₁ = ½g₁ − ½g₂`, `t₂ = −½g₁ − ½g₂` (with `Gᵢ = 4gᵢ`),
integral, with Gram matrix `[[2, 1], [1, 2]]`. -/
theorem transcendental_omega :
    (∀ k, 8 * t1 k = G1 k - G2 k) ∧ (∀ k, 8 * t2 k = -G1 k - G2 k) ∧
      wedge t1 t1 = 2 ∧ wedge t1 t2 = 1 ∧ wedge t2 t2 = 2 := by
  decide

/-- **Saturation**: every integral 2-form in `span_ℚ(G₁, G₂)` is an integer combination of `t₁, t₂`; they form a
basis of `T(A)`. -/
theorem transcendental_omega_saturated (x : Fin 6 → ℤ) (α β : ℚ)
    (hx : ∀ k, (x k : ℚ) = α * G1 k + β * G2 k) :
    ∀ k, x k = (-x 0 - x 1) * t1 k + x 1 * t2 k := by
  have hg : ∀ k, G1 k = 4 * (t1 k - t2 k) ∧ G2 k = -4 * (t1 k + t2 k) := by decide
  have c0 : t1 0 = -1 ∧ t2 0 = -1 ∧ t1 1 = 0 ∧ t2 1 = 1 := by decide
  intro k
  have h0 := hx 0
  have h1 := hx 1
  have hk := hx k
  rw [(hg 0).1, (hg 0).2, c0.1, c0.2.1] at h0
  rw [(hg 1).1, (hg 1).2, c0.2.2.1, c0.2.2.2] at h1
  rw [(hg k).1, (hg k).2] at hk
  push_cast at h0 h1 hk
  have : ((x k : ℤ) : ℚ) = ((-x 0 - x 1) * t1 k + x 1 * t2 k : ℤ) := by
    push_cast
    rw [hk, h0, h1]
    ring
  exact_mod_cast this

/-- **The Kummer surface on the `ω` ray.** `T(Km A) = T(A)(2) = A₂(2)`: the form `(2, 2, 2)`, discriminant `−12`. -/
theorem kummer_d4_omega :
    (2 * wedge t1 t1, 2 * wedge t1 t2, 2 * wedge t2 t2) = (4, 2, 4) ∧ (2 : ℤ) ^ 2 - 4 * 2 * 2 = -12 := by
  decide

/-! ### Sanity check against Taormina–Wendland: the standard complex structure `u = i` -/

/-- With `u = i`, `Ω` is spanned by `ω_j, ω_k`. For `ℤ⁴` and for `D₄` the integral forms below lie in it, have
Gram `diag(2, 2)` and a `2 × 2` minor `1` (so they span a saturated sublattice): the Kummer surfaces have
`T = diag(4, 4)`, TW (3.3) and ll. 1961–1970. -/
theorem sanity_standard_structure :
    let s1 : Fin 6 → ℤ := ![0, -1, 0, 0, 1, 0]
    let s2 : Fin 6 → ℤ := ![0, 0, -1, -1, 0, 0]
    let d1 : Fin 6 → ℤ := ![-1, 0, 1, 1, 1, 0]
    let d2 : Fin 6 → ℤ := ![0, -1, 0, -1, 1, 0]
    (∀ k, 4 * s1 k = -kahler4 square2 zJ k ∧ 4 * s2 k = -kahler4 square2 zK k) ∧
      (∀ k, 4 * d1 k = -kahler4 hurwitz2 zJ k + kahler4 hurwitz2 zK k ∧
        4 * d2 k = -kahler4 hurwitz2 zJ k - kahler4 hurwitz2 zK k) ∧
      (wedge s1 s1, wedge s1 s2, wedge s2 s2) = (2, 0, 2) ∧ (wedge d1 d1, wedge d1 d2, wedge d2 d2) = (2, 0, 2) ∧
      s1 1 * s2 2 - s1 2 * s2 1 = 1 ∧ d1 0 * d2 1 - d1 1 * d2 0 = 1 := by
  decide

end DualScaleDyons.KummerD4
