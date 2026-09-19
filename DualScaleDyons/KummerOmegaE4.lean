/-
Stream 8 · E4 on the `τ = ω` Kummer surface: its symmetry group and the forger's test.

E4 (`docs/STREAM8_WHICH_K3.md` §7) left one case open: the symplectic group of the Kummer surface on the `τ = ω` ray
(`T = A₂(2)`, `D = 12`). G2 (`KummerD4.lean`) realised that surface as the Kummer surface of the `D₄` torus with the
complex structure `u = (i+j+k)/√3`. Here we determine its symmetry group and run the forger's test on it.

### Sources (Tier L)
* Taormina–Wendland (`1107_3834.txt`) Prop. 3.3.4, ll. 1396–1407: for a Kummer surface with the induced Kähler class,
  `G = (ℤ₂)⁴ ⋊ G'_T/ℤ₂`, where `G'_T` is the group of holomorphic symplectic automorphisms of the torus that fix
  `0` (and preserve its Kähler class). Prop. 4.2.2–4.2.3, ll. 1899–1948: for the `D₄` torus with the standard
  complex structure, `G'_T` is the binary tetrahedral group and `G = T₁₉₂ = (ℤ₂)⁴ ⋊ A₄`.
* TW §5, ll. 2716–2726: their "`ℤ₃`-symmetric torus" `T(3)` has `T(A) = diag(2, 2)`
  (`tools/e4_omega_kummer.py`, part 4). It is **not** the `ω` torus of G2, so the `D = 12` surface is not treated in TW.
* Mukai / Huybrechts Ch. 15 (via `ForgerE4`): the character of a symplectic automorphism on `H*(X, ℚ)` is that of an
  `M₂₃` element on 24 points, so the Frame shape is read off from `χ(gᵏ) = 2 + tr(gᵏ | H²)`.
* Standard: `H²(Km A, ℚ) = π_* H²(A, ℚ) ⊕ ⨁_{a ∈ 𝔽₂⁴} ℚ E_a`, translations act trivially on `H²(A)`, and a torus
  map `x ↦ x b + c` (`2c ∈ Λ`) sends the node `a/2` to `(a b + 2c)/2`.

### Conventions
Vectors of `ℍ` are written with doubled integer coordinates (`2x`), as in `KummerD4`; `x ∈ D₄` iff the doubled
coordinates have one parity. `matR b` is right multiplication by the unit `b` in the Hurwitz basis, and `pull M` its
pull-back on 2-forms. The 16 nodes are `D₄/2D₄ = 𝔽₂⁴` (bit masks `0 … 15`).

### What is proved (Tier A)
* `units_complete`: the 24 doubled Hurwitz units are all vectors of `D₄` of norm 1.
* `right_units_fix_sigma`: right multiplication by each unit maps `D₄` onto itself and fixes `ω_I, ω_J, ω_K`,
  hence the whole positive 3-plane `Σ`, and `t₁, t₂` (`T(A) = A₂`). It is holomorphic, symplectic and Kähler for
  **every** complex structure of the hyperkähler `S²`, in particular `u = i` (TW's tetrahedral Kummer, `D = 16`)
  and the `ω` structure (`D = 12`).
* `holomorphic_isometries`: all holomorphic isometries of the `D₄` torus fixing `0`, found exhaustively. For
  `u = ω` there are 72, of which exactly 24 are symplectic; the other 48 act on `H^{2,0}` with order 3. For
  `u = i` there are 96: 24 symplectic, 24 of order 2, 48 of order 4. So `G'_T` has order 24 in both cases.
* `kummer_group_frames`: the 192 elements `x ↦ x b + t/2` (`b` modulo `±1`, `t ∈ 𝔽₂⁴`) act on
  `H²(Km A, ℚ)` as 192 distinct automorphisms. Their Frame shapes are `1²⁴` (1×), `1⁸2⁸` (27×), `1⁶3⁶` (128×)
  and `1⁴2²4⁴` (36×), i.e. classes `1A, 2A, 3A, 4B`, all among Mukai's geometric classes (`ForgerE4.mukai_classes`).

### Reading (Tier C) and scope
The E2 ∩ E3 candidate (`D = 12`) has the symmetry group `T₁₉₂ = (ℤ₂)⁴ ⋊ A₄`, the group of TW's tetrahedral
Kummer surface (`D = 16`). It passes the forger's test: every element lies in a geometric `M₂₄` class with a
computed twined genus. The group is the same, acting on `H*` in the same way, for every complex structure on the
twistor sphere of the `D₄` torus, so symplectic symmetry does not choose between `i` and `ω`. The holomorphic but
non-symplectic symmetry is larger at `u = i` (order 4 on `H^{2,0}`) than at `u = ω` (order 3). Not established
here: the embedding of this `T₁₉₂` into `M₂₄` through TW's map `Θ` (TW realise `T₁₉₂` only for `D = 16`).
-/
import DualScaleDyons.KummerD4
import DualScaleDyons.ForgerE4

namespace DualScaleDyons.KummerOmegaE4

open DualScaleDyons DualScaleDyons.KummerD4 DualScaleDyons.ForgerE4

/-! ### The 24 units and right multiplication -/

def vec (l : List ℤ) : Fin 4 → ℤ := ![l.getD 0 0, l.getD 1 0, l.getD 2 0, l.getD 3 0]

/-- The Hurwitz units, doubled coordinates: `±2eₘ` and `(±1, ±1, ±1, ±1)`. -/
def units2 : List (List ℤ) :=
  [[2, 0, 0, 0], [-2, 0, 0, 0], [0, 2, 0, 0], [0, -2, 0, 0], [0, 0, 2, 0], [0, 0, -2, 0], [0, 0, 0, 2],
    [0, 0, 0, -2]] ++
  ([1, -1].flatMap fun a => [1, -1].flatMap fun b => [1, -1].flatMap fun c => [1, -1].map fun d => [a, b, c, d])

/-- Doubled coordinates of a vector of `D₄`: all of one parity. -/
def inH2 (v : Fin 4 → ℤ) : Bool := (v 1 - v 0) % 2 == 0 && (v 2 - v 0) % 2 == 0 && (v 3 - v 0) % 2 == 0

/-- **The 24 units.** Every doubled vector of norm `4` has entries in `[−2, 2]`; among those, exactly 24 lie in
`D₄`, and they are `units2`. -/
theorem units_complete :
    (let r : List ℤ := [-2, -1, 0, 1, 2]
     ((r.flatMap fun a => r.flatMap fun b => r.flatMap fun c => r.map fun d => [a, b, c, d]).filter
       (fun l => inH2 (vec l) && dotZ (vec l) (vec l) == 4)).length = 24) ∧
      units2.all (fun l => inH2 (vec l) && dotZ (vec l) (vec l) == 4) = true ∧ units2.Nodup := by
  decide +kernel

/-- Hurwitz-basis coordinates of a doubled vector. -/
def hcoords2 (v : Fin 4 → ℤ) : Fin 4 → ℤ := ![v 0, (v 1 - v 0) / 2, (v 2 - v 0) / 2, (v 3 - v 0) / 2]

/-- `v ↦ v · b` in doubled coordinates. -/
def rmul (b v : Fin 4 → ℤ) : Fin 4 → ℤ := fun m => qmulZ v b m / 2

/-- The division in `rmul` is exact. -/
def rmulExact (b v : Fin 4 → ℤ) : Bool := (List.finRange 4).all fun m => qmulZ v b m % 2 == 0

/-- Right multiplication by `b` in the Hurwitz basis: row `p` = coordinates of `hₚ · b`. -/
def matR (b : Fin 4 → ℤ) : Fin 4 → Fin 4 → ℤ := fun p => hcoords2 (rmul b (hurwitz2 p))

/-- Pull-back on 2-forms: `(f^*α)(eₚ, e_q) = α(f eₚ, f e_q)`, in the basis `pairs`. -/
def lam2 (M : Fin 4 → Fin 4 → ℤ) : Fin 6 → Fin 6 → ℤ := fun i j =>
  M (pairs i).1 (pairs j).1 * M (pairs i).2 (pairs j).2 - M (pairs i).1 (pairs j).2 * M (pairs i).2 (pairs j).1

def pull (M : Fin 4 → Fin 4 → ℤ) (a : Fin 6 → ℤ) : Fin 6 → ℤ := fun i =>
  (List.finRange 6).foldl (fun s j => s + lam2 M i j * a j) 0

def eq6 (a b : Fin 6 → ℤ) : Bool := (List.finRange 6).all fun i => a i == b i

/-- **Right multiplication by a unit fixes `Σ`.** For each of the 24 units `b`, `x ↦ x b` maps the Hurwitz basis
into `D₄` (exactly), and its pull-back fixes the three Kähler forms `ω_I, ω_J, ω_K` and the generators `t₁, t₂` of
`T(A) = A₂` of the `ω` structure. -/
theorem right_units_fix_sigma :
    units2.all (fun l =>
      (List.finRange 4).all (fun p => rmulExact (vec l) (hurwitz2 p) && inH2 (rmul (vec l) (hurwitz2 p))) &&
        [zI, zJ, zK].all (fun X => eq6 (pull (matR (vec l)) (kahler4 hurwitz2 X)) (kahler4 hurwitz2 X)) &&
        eq6 (pull (matR (vec l)) t1) t1 && eq6 (pull (matR (vec l)) t2) t2) = true := by
  decide +kernel

/-! ### All holomorphic isometries of the `D₄` torus fixing `0`

For `w = i` or `w = ω`, `(e, w e, v, w v)` is a `ℤ`-basis of `D₄`, and a `ℂ_w`-linear map is fixed by
`a = f(e)`, `c = f(v)`. It is an automorphism of `D₄` iff `a, c` are units and the Gram matrix is preserved. -/

/-- `x ↦ w x` in doubled coordinates. -/
def lmul (w x : Fin 4 → ℤ) : Fin 4 → ℤ := fun m => qmulZ w x m / 2

/-- Doubled `i`, `ω = (−1 + i + j + k)/2`, `1`, `j`. -/
def wI : Fin 4 → ℤ := ![0, 2, 0, 0]
def wO : Fin 4 → ℤ := ![-1, 1, 1, 1]
def one2 : Fin 4 → ℤ := ![2, 0, 0, 0]
def j2 : Fin 4 → ℤ := ![0, 0, 2, 0]

/-- The adapted basis `(e, w e, v, w v)`. -/
def basisW (w e v : Fin 4 → ℤ) : Fin 4 → Fin 4 → ℤ := ![e, lmul w e, v, lmul w v]

/-- `hₚ = Σ coef p m · Bₘ`: for `w = i`, `B = (h₀, i h₀, j, k)`; for `w = ω`, `B = (1, ω, i, ω i)`. -/
def coefI : Fin 4 → Fin 4 → ℤ := ![![1, 0, 0, 0], ![1, 1, 0, -1], ![0, 0, 1, 0], ![0, 0, 0, 1]]
def coefO : Fin 4 → Fin 4 → ℤ := ![![1, 1, 0, 0], ![0, 0, 1, 0], ![1, 1, 0, 1], ![0, 1, -1, -1]]

def combo (coef : Fin 4 → Fin 4 → ℤ) (B : Fin 4 → Fin 4 → ℤ) (p : Fin 4) : Fin 4 → ℤ := fun n =>
  (List.finRange 4).foldl (fun s m => s + coef p m * B m n) 0

def eq4 (a b : Fin 4 → ℤ) : Bool := (List.finRange 4).all fun i => a i == b i

/-- The adapted bases are `ℤ`-bases of `D₄`: their vectors lie in `D₄` and the Hurwitz basis is an integer
combination of them. -/
theorem adapted_bases :
    (List.finRange 4).all (fun m => inH2 (basisW wI (hurwitz2 0) j2 m) && inH2 (basisW wO one2 wI m)) = true ∧
      (List.finRange 4).all (fun p => eq4 (combo coefI (basisW wI (hurwitz2 0) j2) p) (hurwitz2 p) &&
        eq4 (combo coefO (basisW wO one2 wI) p) (hurwitz2 p)) = true ∧
      (List.finRange 4).all (fun m => eq4 (lmul wI (lmul wI (basisW wI (hurwitz2 0) j2 m)))
        (fun n => -basisW wI (hurwitz2 0) j2 m n)) = true := by
  decide +kernel

/-- The `ℂ_w`-linear map with `f(e) = a`, `f(v) = c`, in Hurwitz coordinates. -/
def holMat (w : Fin 4 → ℤ) (coef : Fin 4 → Fin 4 → ℤ) (a c : Fin 4 → ℤ) : Fin 4 → Fin 4 → ℤ :=
  fun p => hcoords2 (combo coef (basisW w a c) p)

/-- `f` preserves the Gram matrix of the adapted basis (so it is an isometry of `D₄` onto itself). -/
def isIso (w e v a c : Fin 4 → ℤ) : Bool :=
  (List.finRange 4).all fun m => (List.finRange 4).all fun n =>
    dotZ (basisW w a c m) (basisW w a c n) == dotZ (basisW w e v m) (basisW w e v n)

/-- The action on the holomorphic plane, as a `2 × 2` integer matrix in the basis `(s₁, s₂)` of `T(A)`, given the
coordinate read-off `rd`; `none` if the pull-back leaves `T(A)`. -/
def onT (M : Fin 4 → Fin 4 → ℤ) (s1 s2 : Fin 6 → ℤ) (rd : (Fin 6 → ℤ) → ℤ × ℤ) :
    Option ((ℤ × ℤ) × (ℤ × ℤ)) :=
  let img := fun s => pull M s
  let r1 := rd (img s1)
  let r2 := rd (img s2)
  if eq6 (img s1) (fun k => r1.1 * s1 k + r1.2 * s2 k) && eq6 (img s2) (fun k => r2.1 * s1 k + r2.2 * s2 k)
  then some (r1, r2) else none

def mul2 (A B : (ℤ × ℤ) × (ℤ × ℤ)) : (ℤ × ℤ) × (ℤ × ℤ) :=
  ((A.1.1 * B.1.1 + A.1.2 * B.2.1, A.1.1 * B.1.2 + A.1.2 * B.2.2),
    (A.2.1 * B.1.1 + A.2.2 * B.2.1, A.2.1 * B.1.2 + A.2.2 * B.2.2))

def pow2 (A : (ℤ × ℤ) × (ℤ × ℤ)) : ℕ → (ℤ × ℤ) × (ℤ × ℤ)
  | 0 => ((1, 0), (0, 1))
  | n + 1 => mul2 (pow2 A n) A

/-- Order (`≤ 6`) of the action on `H^{2,0}`; `0` if not found. -/
def ordT : Option ((ℤ × ℤ) × (ℤ × ℤ)) → ℕ
  | some A => ((List.range 6).map (· + 1)).find? (fun n => pow2 A n == ((1, 0), (0, 1))) |>.getD 0
  | none => 0

/-- `T(A)` for `u = i` on `D₄` (`sanity_standard_structure`): `d₁, d₂`, read off from coordinates 0, 1. -/
def d1 : Fin 6 → ℤ := ![-1, 0, 1, 1, 1, 0]
def d2 : Fin 6 → ℤ := ![0, -1, 0, -1, 1, 0]

/-- Orders of the action on `H^{2,0}` of all holomorphic isometries fixing `0`, for `w = i` and `w = ω`. -/
def holOrders (w e v : Fin 4 → ℤ) (coef : Fin 4 → Fin 4 → ℤ) (s1 s2 : Fin 6 → ℤ)
    (rd : (Fin 6 → ℤ) → ℤ × ℤ) : List ℕ :=
  ((units2.flatMap fun a => units2.map fun c => (vec a, vec c)).filter (fun ac => isIso w e v ac.1 ac.2)).map
    fun ac => ordT (onT (holMat w coef ac.1 ac.2) s1 s2 rd)

/-- **Holomorphic isometries of the `D₄` torus fixing `0`.** For `u = i`: 96, acting on `H^{2,0}` with orders
`1, 2, 4` (24, 24, 48 elements). For `u = ω`: 72, with orders `1, 3` (24, 48). In both cases exactly 24 are
symplectic, so `|G'_T| = 24`, and the Kummer surface of either has `G = (ℤ₂)⁴ ⋊ G'_T/ℤ₂` of order 192
(TW Prop. 3.3.4). -/
theorem holomorphic_isometries :
    (let L := holOrders wI (hurwitz2 0) j2 coefI d1 d2 (fun x => (-x 0, -x 1))
     L.length = 96 ∧ L.count 1 = 24 ∧ L.count 2 = 24 ∧ L.count 4 = 48) ∧
      (let L := holOrders wO one2 wI coefO t1 t2 (fun x => (-x 0 - x 1, x 1))
       L.length = 72 ∧ L.count 1 = 24 ∧ L.count 3 = 48) := by
  decide +kernel

/-! ### The Kummer group and its Frame shapes -/

def firstNZpos (l : List ℤ) : Bool :=
  match l.find? (· ≠ 0) with
  | some x => decide (0 < x)
  | none => false

/-- One unit from each pair `±b`. -/
def reps12 : List (List ℤ) := units2.filter firstNZpos

theorem reps_12 :
    reps12.length = 12 ∧ units2.all (fun l => reps12.contains l || reps12.contains (l.map (- ·))) = true := by
  decide +kernel

/-- Row `p` of `matR b` modulo 2, as a bit mask. -/
def mask (b : Fin 4 → ℤ) (p : Fin 4) : ℕ :=
  (List.finRange 4).foldl (fun s q => s + ((matR b p q) % 2).toNat * 2 ^ (q : ℕ)) 0

/-- The node map `a ↦ a b + t` on `𝔽₂⁴`. -/
def nodeMap (b : Fin 4 → ℤ) (t a : ℕ) : ℕ :=
  (List.finRange 4).foldl (fun s (p : Fin 4) => if a.testBit p.val then s ^^^ mask b p else s) t

def iterN (f : ℕ → ℕ) : ℕ → ℕ → ℕ
  | 0, a => a
  | n + 1, a => f (iterN f n a)

/-- `bⁿ` in doubled coordinates. -/
def qpow (b : Fin 4 → ℤ) : ℕ → Fin 4 → ℤ
  | 0 => one2
  | n + 1 => rmul b (qpow b n)

def isPM1 (v : Fin 4 → ℤ) : Bool := (v 0 == 2 || v 0 == -2) && v 1 == 0 && v 2 == 0 && v 3 == 0

/-- Trace on `H²(A)` of right multiplication. -/
def trL (b : Fin 4 → ℤ) : ℤ := (List.finRange 6).foldl (fun s i => s + lam2 (matR b) i i) 0

/-- Lefschetz number `χ(gᵏ) = 2 + tr(gᵏ | H²(A)) + #(nodes fixed by gᵏ)` for `g : x ↦ x b + t/2`. -/
def chiK (b : Fin 4 → ℤ) (t k : ℕ) : ℕ :=
  (2 + trL (qpow b k)).toNat + ((List.range 16).filter fun a => iterN (nodeMap b t) k a == a).length

/-- Order of `g` on the Kummer surface (`≤ 6`; `0` if not found). -/
def ordK (b : Fin 4 → ℤ) (t : ℕ) : ℕ :=
  ((List.range 6).map (· + 1)).find? (fun k =>
    isPM1 (qpow b k) && (List.range 16).all fun a => iterN (nodeMap b t) k a == a) |>.getD 0

/-- Frame shape from `χ(gᵈ)`, `d | ord g` (Möbius inversion of `χ(gᵏ) = Σ_{d | k} d·a_d`). -/
def frameK (b : Fin 4 → ℤ) (t : ℕ) : List (ℕ × ℕ) :=
  let c1 := chiK b t 1
  let c2 := chiK b t 2
  let c3 := chiK b t 3
  (match ordK b t with
    | 1 => [(1, 24)]
    | 2 => [(1, c1), (2, (24 - c1) / 2)]
    | 3 => [(1, c1), (3, (24 - c1) / 3)]
    | 4 => [(1, c1), (2, (c2 - c1) / 2), (4, (24 - c2) / 4)]
    | 6 => [(1, c1), (2, (c2 - c1) / 2), (3, (c3 - c1) / 3), (6, (24 + c1 - c2 - c3) / 6)]
    | _ => []).filter (·.2 ≠ 0)

/-- The action of `g` on `H²(Km A, ℚ) = π_*H²(A) ⊕ ℚ¹⁶`: pull-back matrix and node permutation. -/
def actK (b : Fin 4 → ℤ) (t : ℕ) : List ℤ × List ℕ :=
  ((List.finRange 6).flatMap fun i => (List.finRange 6).map fun j => lam2 (matR b) i j,
    (List.range 16).map (nodeMap b t))

/-- **The forger's test on the `D = 12` Kummer surface.** The 192 elements `x ↦ x b + t/2` act as distinct
automorphisms of `H²(Km A, ℚ)`. Their Frame shapes are `1²⁴`, `1⁸2⁸`, `1⁶3⁶`, `1⁴2²4⁴` with multiplicities
1, 27, 128, 36, all among Mukai's geometric classes `1A, 2A, 3A, 4B`. -/
theorem kummer_group_frames :
    (reps12.flatMap fun l => (List.range 16).map fun t => actK (vec l) t).Nodup ∧
      (let F := reps12.flatMap fun l => (List.range 16).map fun t => frameK (vec l) t
       F.length = 192 ∧ F.count [(1, 24)] = 1 ∧ F.count [(1, 8), (2, 8)] = 27 ∧
         F.count [(1, 6), (3, 6)] = 128 ∧ F.count [(1, 4), (2, 2), (4, 4)] = 36 ∧
         F.all (fun f => ((List.range 26).filter geometric).contains (frameShape.idxOf f)) = true) ∧
      [[(1, 24)], [(1, 8), (2, 8)], [(1, 6), (3, 6)], [(1, 4), (2, 2), (4, 4)]].map frameShape.idxOf = [0, 1, 3, 6] := by
  decide +kernel

end DualScaleDyons.KummerOmegaE4
