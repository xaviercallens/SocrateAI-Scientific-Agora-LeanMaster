/-
Stream 8 · G5 — the maximal-symmetry principle: the GTVW model is the Kummer surface of the `D₄` torus.

The earlier selection principles picked a black hole (P8.2) or a singular point (P8.4c). Here the principle is
"the most symmetric non-singular K3 model". Among the symmetry groups GHV allow for non-singular K3 sigma models,
`ℤ₂⁸ : M₂₀` is maximal, and Gaberdiel–Taormina–Volpato–Wendland realise it as the `ℤ₂` orbifold of the `D₄`-torus
model at its `so(8)₁` point, with a specific `B`-field. This file checks their `D₄` data, and asks which complex
structure on that torus the `B`-field singles out.

### Sources (Tier L)
* GTVW (`1309_4127.txt`), abstract and ll. 138–149: the `ℤ₂`-orbifold of the `D₄`-torus theory has `N = (4, 4)`
  preserving symmetry group `ℤ₂⁸ : M₂₀`, "one of the largest maximal symmetry groups of K3 sigma models";
  geometrically a sigma model on the tetrahedral Kummer surface of TW. ll. 1509–1514: maximal, i.e. no larger
  symmetry group contains it. (2.2)–(2.6), ll. 236–283: the basis of `L_{D₄}` (the `D₄` lattice with norm-1
  roots), the `B`-field, and the 24 charges `(m, l) = (B l + l, l)` of the left `so(8)₁` currents.
  (A.3), ll. 2104–2107: `Q = (m − Bl + l)/√2`, `Q̄ = (m − Bl − l)/√2`, `(m, l) ∈ L* ⊕ L`.
* Harvey–Moore (`2003_13700.txt`) ll. 735–742: "a distinguished K3 because it has the maximal group `2⁸ : M₂₀`
  allowed by … GHV"; the target `T⁴` is the Spin(8) maximal torus; equivalently six `SU(2)` level-1 WZW models,
  i.e. six circles at the T-duality self-dual radius `R = 1`.
* GHV (`1106_4315.txt`) ll. 144–159: the possible groups are (i) `G'.G''` with `G' ⊂ ℤ₂¹¹`, `G'' ⊂ M₂₄` with at
  least four orbits, (ii) `5^{1+2}.ℤ₄`, (iii) `ℤ₃⁴.A₆`, (iv) `3^{1+4}.ℤ₂.G''`, `|G''| ≤ 4`; l. 1206 predicts
  `ℤ₂⁸ ⋊ M₂₀`, "that might correspond to a certain `T⁴/ℤ₂` orbifold".

### Conventions
GTVW's lattice vectors are `v/√2` with `v` in the `D₄` root lattice of `ℤ⁴`; we work with the integer vectors `v`
(`gtvwBasis` is GTVW (2.2) times `√2`). Inner products of actual vectors are half of `dotZ`. 2-forms are stored by
their values on the basis pairs, as in `KummerD4`; `kahler4 gtvwBasis X` is twice the Kähler form of left
multiplication by `X`.

### What is proved (Tier A)
* `gtvw_so8_point`: for each of the 24 roots `l`, `m = (B + 1) l` lies in the dual lattice `L*`, so the charges
  `(m, l)` exist and give `Q = √2 l`, `Q̄ = 0`, the left `so(8)₁` currents. With `B = 0` the condition fails: the
  `B`-field is needed for the enhancement.
* `gtvw_B_is_I`: GTVW's `B` is left multiplication by `i`, and its 2-form is the Kähler form `ω_I`.
* `gtvw_complex_structures`: on the same torus, `u = i` gives `T(A) = diag(2, 2)` (Kummer `D = 16`, the tetrahedral
  surface) and `u = (i+j+k)/√3` gives `T(A) = A₂` (Kummer `D = 12`); both lattices are primitive and span the
  holomorphic plane.
* `gtvw_B_type`: the `B`-field is of type `(1, 1)` for `u = i`, and has a `(2,0) + (0,2)` part for each of the four
  `ω`-type structures `(±i ± j ± k)/√3`.
* `gtvw_group_orders`: `|ℤ₂⁸ : M₂₀| = 2⁸ · 960 = 245760`; GHV's cases (ii)–(iv) have orders 500, 29160 and at most
  1944; `2¹⁴ ∤ |M₂₄|`, so the group is not a subgroup of `M₂₄`; and the six `su(2)₁` factors have `c = 6`, the
  central charge of a K3 sigma model, with `D₄ ⊃ A₁⁴` (four orthogonal roots).

### Reading (Tier C)
* The parent theory of the most symmetric known K3 model is exactly the point that trapping selects on `T⁴` (G2):
  the rank-4 maximal enhancement, 24 left `so(8)₁` roots (`gtvw_so8_point`), at the T-duality self-dual radius.
  After the `ℤ₂` orbifold the K3 model is non-singular. This is a different statement from §12's `D₄ = Π ∩ Γ₄,₂₀`,
  which concerned roots orthogonal to `Π` in the K3 lattice (a singular K3 model) and was the generic
  `D_{16+d} ⊕ D_d` pattern. Here the coincidence is at the level of the torus theory, and it is not generic.
* The complex structure is not a CFT datum: the `S²` of the torus contains both `i` (D = 16) and `ω` (D = 12).
  But the model's `B`-field is the Kähler form of `i`, and it is of type `(1,1)` only there, so its natural
  geometric interpretation is the tetrahedral Kummer surface (as GTVW say), not the `ω` surface of E2 ∩ E3.
  This is a counterweight to the `ω` reading.
* `ℤ₂⁸ : M₂₀` is maximal and "one of the largest" (GTVW); that it is the largest group is not claimed.
-/
import DualScaleDyons.KummerD4

namespace DualScaleDyons.GTVWPoint

open DualScaleDyons.KummerD4

/-- GTVW (2.2) times `√2`: `l₁,₂, l₁,₋₂, l₃,₄, l₁,₃`. -/
def gtvwBasis : Fin 4 → Fin 4 → ℤ := ![![1, 1, 0, 0], ![1, -1, 0, 0], ![0, 0, 1, 1], ![1, 0, 1, 0]]

/-- GTVW (2.3): `B(a, b, c, d) = (−b, a, −d, c)`. -/
def Bmap (v : Fin 4 → ℤ) : Fin 4 → ℤ := ![-v 1, v 0, -v 3, v 2]

/-- The 24 roots `±eⱼ ± eₖ` (times `√2`). -/
def roots24 : List (Fin 4 → ℤ) :=
  let r : List ℤ := [-1, 0, 1]
  ((r.flatMap fun a => r.flatMap fun b => r.flatMap fun c => r.map fun d => (![a, b, c, d] : Fin 4 → ℤ))).filter
    fun v => (List.finRange 4).foldl (fun s k => s + (v k).natAbs) 0 == 2

/-- `m = (B + 1) l ∈ L*`: `⟨m, w⟩ = dotZ ((B+1)v) w / 2` is an integer for every basis vector `w`. -/
def dualOK (B : (Fin 4 → ℤ) → Fin 4 → ℤ) : Bool :=
  roots24.all fun v => (List.finRange 4).all fun p =>
    dotZ (fun k => B v k + v k) (gtvwBasis p) % 2 == 0

/-- **The `so(8)₁` point.** With GTVW's `B`-field every root gives a charge `(m, l) ∈ L* ⊕ L`; with `B = 0` not. -/
theorem gtvw_so8_point : roots24.length = 24 ∧ dualOK Bmap = true ∧ dualOK (fun _ _ => 0) = false := by
  decide +kernel

/-- **The `B`-field is `ω_I`.** `B` is left multiplication by `i`, and its 2-form on the lattice is `ω_I`. -/
theorem gtvw_B_is_I :
    (List.finRange 4).all (fun p => (List.finRange 4).all fun k => Bmap (gtvwBasis p) k == qmulZ zI (gtvwBasis p) k)
        = true ∧
      (List.finRange 6).all (fun k => dotZ (Bmap (gtvwBasis (pairs k).1)) (gtvwBasis (pairs k).2) ==
        kahler4 gtvwBasis zI k) = true := by
  decide +kernel

/-- Twice the Kähler forms `ω_I, ω_J, ω_K` on the GTVW lattice. -/
def fI : Fin 6 → ℤ := kahler4 gtvwBasis zI
def fJ : Fin 6 → ℤ := kahler4 gtvwBasis zJ
def fK : Fin 6 → ℤ := kahler4 gtvwBasis zK

/-- `c₁ ω_I + c₂ ω_J + c₃ ω_K` (doubled). -/
def comb (c : ℤ × ℤ × ℤ) : Fin 6 → ℤ := fun k => c.1 * fI k + c.2.1 * fJ k + c.2.2 * fK k

/-- `x` lies in the rational span of `a, b` (all `3 × 3` minors of `(a; b; x)` vanish) and `a, b` are independent. -/
def inPlane (a b x : Fin 6 → ℤ) : Bool :=
  (List.finRange 6).any (fun i => (List.finRange 6).any fun j => a i * b j - a j * b i != 0) &&
  (List.finRange 6).all fun i => (List.finRange 6).all fun j => (List.finRange 6).all fun k =>
    a i * (b j * x k - b k * x j) - a j * (b i * x k - b k * x i) + a k * (b i * x j - b j * x i) == 0

/-- Some `2 × 2` minor of `(s₁; s₂)` is `±1`: `ℤs₁ + ℤs₂` is primitive (saturated) in `ℤ⁶`. -/
def primitive2 (s1 s2 : Fin 6 → ℤ) : Bool :=
  (List.finRange 6).any fun i => (List.finRange 6).any fun j => (s1 i * s2 j - s1 j * s2 i).natAbs == 1

def ti1 : Fin 6 → ℤ := ![0, -1, 0, 1, 1, 0]
def ti2 : Fin 6 → ℤ := ![0, 1, 1, 1, 0, -1]
def tw1 : Fin 6 → ℤ := ![0, 1, 0, -1, -1, 0]
def tw2 : Fin 6 → ℤ := ![-1, 0, -1, -1, 0, 0]

/-- **Both complex structures on the GTVW torus.** For `u = i` the holomorphic plane is spanned by `ω_J, ω_K`, and
`T(A) = ℤti₁ ⊕ ℤti₂ = diag(2, 2)`; for `u = (i+j+k)/√3` it is spanned by `ω_I − ω_J`, `ω_I + ω_J − 2ω_K`, and
`T(A) = ℤtw₁ ⊕ ℤtw₂ = A₂`. Both pairs lie in their plane and are primitive. -/
theorem gtvw_complex_structures :
    (inPlane (comb (0, 1, 0)) (comb (0, 0, 1)) ti1 && inPlane (comb (0, 1, 0)) (comb (0, 0, 1)) ti2 &&
      primitive2 ti1 ti2) = true ∧
      (wedge ti1 ti1, wedge ti1 ti2, wedge ti2 ti2) = (2, 0, 2) ∧
      (inPlane (comb (1, -1, 0)) (comb (1, 1, -2)) tw1 && inPlane (comb (1, -1, 0)) (comb (1, 1, -2)) tw2 &&
        primitive2 tw1 tw2) = true ∧
      (wedge tw1 tw1, wedge tw1 tw2, wedge tw2 tw2) = (2, 1, 2) := by
  decide +kernel

/-- **The `B`-field singles out `i`.** `B ∈ H^{1,1}` iff `B` is wedge-orthogonal to the holomorphic plane. For
`u = i` both pairings vanish; for the four `ω`-type structures `(±i ± j ± k)/√3` (each plane given by two integer
vectors orthogonal to the axis in `ℝ³`) the pairings are the explicit non-zero values below (`ω_I ∧ ω_I = 4` in
these doubled units). -/
theorem gtvw_B_type :
    (wedge fI (comb (0, 1, 0)), wedge fI (comb (0, 0, 1))) = (0, 0) ∧ wedge fI fI = 4 ∧
      [((1, -1, 0), (1, 1, -2)), ((1, -1, 0), (1, 1, 2)), ((1, 1, 0), (1, -1, -2)), ((1, 1, 0), (-1, 1, -2))].map
        (fun ab : (ℤ × ℤ × ℤ) × (ℤ × ℤ × ℤ) => (wedge fI (comb ab.1), wedge fI (comb ab.2))) =
        [(4, 4), (4, 4), (4, 4), (4, -4)] := by
  decide +kernel

/-- **Group orders and central charge.** `|ℤ₂⁸ : M₂₀| = 2⁸ · |M₂₀|` with `|M₂₀| = |2⁴ : A₅| = 960`; GHV's cases
(ii)–(iv) have orders `125·4`, `81·360`, `≤ 243·2·4`; `2¹⁴` divides `245760` but not `|M₂₄|`; six `su(2)₁` have
`c = 6`, and `e₁ ± e₂`, `e₃ ± e₄` are four mutually orthogonal roots of `D₄`. -/
theorem gtvw_group_orders :
    2 ^ 8 * (2 ^ 4 * 60) = 245760 ∧ (125 * 4, 81 * 360, 243 * 2 * 4) = (500, 29160, 1944) ∧
      245760 % 2 ^ 14 = 0 ∧ (244823040 : ℕ) % 2 ^ 14 ≠ 0 ∧ (244823040 : ℕ) = 2 ^ 10 * 3 ^ 3 * 5 * 7 * 11 * 23 ∧
      6 * 1 = 6 ∧
      (let a : Fin 4 → ℤ := ![1, 1, 0, 0]; let b : Fin 4 → ℤ := ![1, -1, 0, 0]
       let c : Fin 4 → ℤ := ![0, 0, 1, 1]; let d : Fin 4 → ℤ := ![0, 0, 1, -1]
       [dotZ a b, dotZ a c, dotZ a d, dotZ b c, dotZ b d, dotZ c d] = [0, 0, 0, 0, 0, 0] ∧
         [a, b, c, d].all (fun v => roots24.contains v)) := by
  decide +kernel

end DualScaleDyons.GTVWPoint
