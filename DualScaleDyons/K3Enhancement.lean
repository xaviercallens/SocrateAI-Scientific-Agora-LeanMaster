/-
Stream 8 · P8.4c — trapping on the K3 factor: the point of maximal gauge enhancement.

E2 applied moduli trapping (the enhanced symmetry point with the most light states) to `T²`, G2 to `T⁴`. Here the
same principle is applied to the K3 factor, and then to the whole K3 × T² moduli space.

### Sources (Tier L)
* Aspinwall (`aspinwall_hep-th_9611137.txt`) (95), ll. 2464–2485: for IIA on K3 (heterotic on `T⁴`) the roots of the
  non-abelian gauge group are the `α ∈ Γ₄,₂₀ ∩ Π^⊥` with `α² = −2`, `Π` the positive 4-plane; the group is
  simply laced (ADE). ll. 2551–2559: a non-abelian part of rank 20, the maximum, needs a very small, singular K3
  ("volume of order one in units of `α'²`"). ll. 2856–2858: in four dimensions the same rule holds for a positive
  6-plane in `Γ₆,₂₂`. ll. 2838–2845: the extra `SL(2)` factor is the heterotic axion-dilaton, which is the area and
  `B`-field of `T²` in IIA.
* GHV (`1106_4315.txt`) ll. 370–386: when `Π` is orthogonal to a root the sigma model is not well defined
  (D-branes become massless). The symmetry groups `G_Π ⊂ Co₀` (Mathieu moonshine, E4) are for the other points.
* Huybrechts (`huybrechts_K3Global.txt`) Thm. 1.1, ll. 12906–12910 (Milnor): an even unimodular lattice of
  signature `(n₊, n₋)`, `n₊, n₋ > 0`, exists iff `n₊ − n₋ ≡ 0 (8)` and is unique. ll. 12744–12768: even overlattices
  of `Λ₀` correspond to isotropic subgroups of `A_{Λ₀}`, and gluing along an anti-isometry of discriminant forms.

### Conventions
Vectors in `ℝ^{d, 16+d}` are written with doubled integer coordinates; `ip4 x y = 4 ⟨x, y⟩` with the metric
`diag(1^d, (−1)^{16+d})`. The lattice `Γ_d` is spanned by `2e₀`, `e₀ + eᵢ` (`1 ≤ i ≤ n − 2`) and `½(1, …, 1)`,
`n = 16 + 2d`; `Π` is the span of the first `d` coordinates.

### What is proved (Tier A)
* `trapping_rank_table_22`: the largest simply-laced root system of rank `≤ r` has, for `r = 0 … 22`,
  `0, 2, 6, 12, 24, 40, 72, 126, 240, 242, 246, 252, 264, 312, 364, 420, 480, 544, 612, 684, 760, 840, 924` roots.
  In rank 20 the maximum is `D₂₀` alone (760; `A₂₀` has 420, any split at most 686); in rank 22 it is `D₂₂` alone
  (924; `A₂₂` 506, splits at most 842).
* `bareiss_sanity`: the determinant routine gives `det A₂ = 3`, `det D₄ = 4`.
* `gamma4_unimodular`, `gamma6_unimodular`: `Γ₄` and `Γ₆` are even, integral, with Gram determinant 1. By Milnor
  they are `Γ₄,₂₀` and `Γ₆,₂₂`.
* `so40_point`, `so44_point` (in `K3EnhancementSO40.lean`, `K3EnhancementSO44.lean`: the kernel needs 11 and 14 GB for
  each, so each has its own file): all `±eᵢ ± eⱼ` in the negative block lie in `Γ_d`, orthogonal to `Π`, with norm
  `−2`: 760 roots of `D₂₀` for `d = 4`, 924 of `D₂₂` for `d = 6`. All `±eᵢ ± eⱼ` of the positive block also lie in
  `Γ_d`: `Π ∩ Γ_d ⊇ D₄`, resp. `D₆`. With the rank table and Aspinwall's rule, the gauge group at these points is
  exactly `SO(40)`, resp. `SO(44)`, the largest possible.
* `product_points_not_maximal`: at a point where the 6-plane splits as `Π₄ ⊕ Π₂` along `Γ₄,₂₀ ⊕ Γ₂,₂`, the roots
  number at most `760 + 6 = 766 < 924` (the arithmetic; the splitting of roots is the Tier L step below).
* `uniform_parity`: every lattice vector has doubled coordinates of one parity and even coordinate sum, so
  `Π^⊥ ∩ Γ_d` is exactly `D_{16+d}(−1)`, and `Π ∩ Γ_d ⊇ D_d` (by `so40_point`, `so44_point`).
* `agrees_with_rank8_table`: on ranks `≤ 8` the table agrees with G2's `KummerD4.bestTable`.

Tier L steps used with these: the roots of an even negative-definite lattice form an ADE system (Aspinwall
l. 2484), so the rank table bounds the number of roots; and in an orthogonal sum of two even negative-definite
lattices a root lies in one summand (the two parts have even norms `≤ 0` adding to `−2`, so one of them is `0`).

### Reading (Tier C) and scope
Trapping on the K3 factor selects the `SO(40)` point, where `Π ∩ Γ₄,₂₀ = D₄`, the Hurwitz lattice of G2. The
24 norm-2 vectors of `Π` are the states of the other chirality, which the heterotic GSO projection removes (Aspinwall
ll. 2455–2462), just as E2's second `SU(3)`; and `D_{16+d} ⊕ D_d` is the generic pattern (the discriminant forms of
`D_{16+d}` and `D_d` agree). So the recurrence of `D₄` carries little independent weight. Three consequences:
* the point is a very small, singular K3 (rank 20 > 19; Aspinwall ll. 2551–2559) where the sigma model is not
  defined (GHV). Trapping and moonshine symmetry (E4) select disjoint loci;
* on the whole K3 × T² moduli space the maximum is `SO(44)`, at a point that does not split into a K3 point and a
  `T²` point. Factor-wise trapping (E2, G2, this file's `d = 4`) does not give the global maximum;
* in IIA, E2's `T²` area modulus is the heterotic axion-dilaton, which carries no gauge roots.
-/
import DualScaleDyons.KummerD4

namespace DualScaleDyons.K3Enhancement

/-! ### The largest root systems up to rank 22 -/

/-- Simple ADE components `(rank, number of roots)` of rank `≤ N`. -/
def ade (N : ℕ) : List (ℕ × ℕ) :=
  ((List.range N).map fun n => (n + 1, (n + 1) * (n + 2))) ++
  ((List.range (N - 3)).map fun n => (n + 4, 2 * (n + 4) * (n + 3))) ++
  ([(6, 72), (7, 126), (8, 240)].filter (·.1 ≤ N))

/-- `best N = [b₀, …, b_N]`, `b_k` = most roots of a simply-laced system of rank `≤ k`. -/
def best (N : ℕ) : List ℕ :=
  (List.range N).foldl (fun b k =>
    b ++ [max (b.getD k 0) (((ade N).filter (·.1 ≤ k + 1)).foldl
      (fun m c => max m (c.2 + b.getD (k + 1 - c.1) 0)) 0)]) [0]

/-- Largest two-part split `b_k + b_{r−k}`, `1 ≤ k ≤ r − 1`. -/
def bestSplit (r : ℕ) : ℕ :=
  ((List.range (r - 1)).map fun k => (best 22).getD (k + 1) 0 + (best 22).getD (r - 1 - k) 0).foldl max 0

/-- **Trapping in ranks 20 and 22.** The maxima are unique: `D₂₀` (760) and `D₂₂` (924). -/
theorem trapping_rank_table_22 :
    best 22 = [0, 2, 6, 12, 24, 40, 72, 126, 240, 242, 246, 252, 264, 312, 364, 420, 480, 544, 612, 684, 760,
      840, 924] ∧
      ((ade 22).filter (·.1 = 20)).map (·.2) = [420, 760] ∧ bestSplit 20 = 686 ∧
      ((ade 22).filter (·.1 = 22)).map (·.2) = [506, 924] ∧ bestSplit 22 = 842 := by
  decide +kernel

/-! ### A fraction-free determinant -/

/-- Bareiss elimination with row pivoting; `fuel ≥` size. Returns the determinant. -/
def bareiss : ℕ → List (List ℤ) → ℤ → ℤ
  | 0, _, _ => 0
  | f + 1, M, prev =>
    match M.findIdx? (fun r => r.headD 0 ≠ 0) with
    | none => 0
    | some i =>
      let piv := M.getD i []
      let others := M.eraseIdx i
      let sgn : ℤ := if i % 2 = 0 then 1 else -1
      let p := piv.headD 0
      if others = [] then sgn * p else
        sgn * bareiss f (others.map fun r =>
          List.zipWith (fun a b => (p * a - r.headD 0 * b) / prev) r.tail piv.tail) p

def det (M : List (List ℤ)) : ℤ := bareiss (M.length + 1) M 1

theorem bareiss_sanity :
    det [[2, -1], [-1, 2]] = 3 ∧ det [[2, -1, 0, 0], [-1, 2, -1, -1], [0, -1, 2, 0], [0, -1, 0, 2]] = 4 ∧
      det [[0, 1], [1, 0]] = -1 := by
  decide +kernel

/-! ### The lattices `Γ_{d, 16+d}` -/

/-- Unit vector, doubled: `2eᵢ`. -/
def e2 (n i : ℕ) : List ℤ := (List.range n).map fun k => if k = i then 2 else 0

def addL (x y : List ℤ) : List ℤ := List.zipWith (· + ·) x y
def scaleL (c : ℤ) (x : List ℤ) : List ℤ := x.map (c * ·)

/-- Basis of `Γ_d`, doubled coordinates: `2e₀ → 4e₀`, `e₀ + eᵢ → 2e₀ + 2eᵢ`, `½(1,…,1) → (1,…,1)`. -/
def basis (n : ℕ) : List (List ℤ) :=
  [scaleL 2 (e2 n 0)] ++ ((List.range (n - 2)).map fun i => addL (e2 n 0) (e2 n (i + 1))) ++
    [(List.range n).map fun _ => 1]

/-- `4⟨x, y⟩` for the metric `diag(1^d, (−1)^{n−d})`. -/
def ip4 (d : ℕ) (x y : List ℤ) : ℤ :=
  ((List.range x.length).map fun k => (if k < d then 1 else -1) * x.getD k 0 * y.getD k 0).sum

def gram (d n : ℕ) : List (List ℤ) := (basis n).map fun x => (basis n).map fun y => ip4 d x y / 4

/-- Even and integral: `ip4 ≡ 0 mod 4` everywhere, `≡ 0 mod 8` on the diagonal. -/
def evenIntegral (d n : ℕ) : Bool :=
  (basis n).all (fun x => (basis n).all (fun y => ip4 d x y % 4 == 0) && ip4 d x x % 8 == 0)

/-- **`Γ₄` is even unimodular of signature `(4, 20)`**, hence `Γ₄,₂₀` (Milnor). -/
theorem gamma4_unimodular : (basis 24).length = 24 ∧ evenIntegral 4 24 = true ∧ det (gram 4 24) = 1 := by
  decide +kernel

/-- **`Γ₆` is even unimodular of signature `(6, 22)`**, hence `Γ₆,₂₂`. -/
theorem gamma6_unimodular : (basis 28).length = 28 ∧ evenIntegral 6 28 = true ∧ det (gram 6 28) = 1 := by
  decide +kernel

/-- Integer coordinates of a doubled vector in `basis n`, if it lies in `Γ_d` (`none` otherwise): the last
coordinate fixes the coefficient of `½(1,…,1)`, then those of `e₀ + eᵢ`, then of `2e₀`. -/
def decode (n : ℕ) (z : List ℤ) : Option (List ℤ) :=
  let cs := z.getD (n - 1) 0
  let r := z.map (· - cs)
  let cis := (List.range (n - 2)).map fun i => r.getD (i + 1) 0 / 2
  let c0 := (r.getD 0 0 - 2 * cis.sum) / 4
  let c := [c0] ++ cis ++ [cs]
  let back := (List.zipWith scaleL c (basis n)).foldl addL ((List.range n).map fun _ => 0)
  if back = z then some c else none

/-- All `±eᵢ ± eⱼ` (`i < j`) with `i, j` in `[lo, lo + m)`, doubled coordinates. -/
def rootsD (n lo m : ℕ) : List (List ℤ) :=
  (List.range m).flatMap fun i => ((List.range m).filter (i < ·)).flatMap fun j =>
    [(1, 1), (1, -1), (-1, 1), (-1, -1)].map fun s : ℤ × ℤ =>
      addL (scaleL s.1 (e2 n (lo + i))) (scaleL s.2 (e2 n (lo + j)))

/-- `e₀ + e_k`, doubled. For `1 ≤ k ≤ n − 2` it is a basis vector; `e₀ + e_{n−1}` is decoded once. -/
def gvec (n k : ℕ) : List ℤ := addL (e2 n 0) (e2 n k)

/-- Sparse certificate: `s₁eᵢ + s₂eⱼ` (`i < j`) as `s₁(e₀+eᵢ) + s₂(e₀+eⱼ) − ((s₁+s₂)/2)·2e₀`, or, when `i = 0`,
`s₂(e₀+eⱼ) + ((s₁−s₂)/2)·2e₀`. -/
def rootCombo (n i j : ℕ) (s1 s2 : ℤ) : List ℤ :=
  if i = 0 then addL (scaleL s2 (gvec n j)) (scaleL ((s1 - s2) / 2) (scaleL 2 (e2 n 0)))
  else addL (addL (scaleL s1 (gvec n i)) (scaleL s2 (gvec n j))) (scaleL (-((s1 + s2) / 2)) (scaleL 2 (e2 n 0)))

/-- The generators used by the certificates are in `Γ_d`: `2e₀` and `e₀ + e_k` (`1 ≤ k ≤ n − 2`) are basis vectors,
and `e₀ + e_{n−1}` decodes. -/
def generatorsIn (n : ℕ) : Bool :=
  (basis n).contains (scaleL 2 (e2 n 0)) &&
    (List.range (n - 2)).all (fun k => (basis n).contains (gvec n (k + 1))) && (decode n (gvec n (n - 1))).isSome

/-- Roots `s₁eᵢ + s₂eⱼ` with `i < j` in `[lo, lo + m)`, with their certificates checked; norms and orthogonality to
`Π` (the first `d` coordinates) checked on the negative block. -/
def blockCheck (d n lo m : ℕ) (neg : Bool) : Bool :=
  (List.range m).all fun i => ((List.range m).filter (i < ·)).all fun j =>
    [(1, 1), (1, -1), (-1, 1), (-1, -1)].all fun s : ℤ × ℤ =>
      let r := addL (scaleL s.1 (e2 n (lo + i))) (scaleL s.2 (e2 n (lo + j)))
      rootCombo n (lo + i) (lo + j) s.1 s.2 == r &&
        (if neg then ip4 d r r == -8 && (List.range d).all (fun k => r.getD k 0 == 0) else ip4 d r r == 8)

/-- The roots `±eᵢ ± eⱼ` of the negative block lie in `Γ_d`, are orthogonal to `Π` and have norm `−2`; those of
the positive block lie in `Γ_d` and have norm `2`. -/
def enhancementCheck (d : ℕ) : Bool :=
  let n := 16 + 2 * d
  generatorsIn n && blockCheck d n d (16 + d) true && blockCheck d n 0 d false

/-- **Product points are not maximal.** Roots orthogonal to `Π₄ ⊕ Π₂` in `Γ₄,₂₀ ⊕ Γ₂,₂` lie in one factor (the
complements are even and negative definite), so they number at most `b₂₀ + b₂ = 766 < 924`. -/
theorem product_points_not_maximal :
    (best 22).getD 20 0 + (best 22).getD 2 0 = 766 ∧ 766 < (best 22).getD 22 0 := by
  decide +kernel

/-- **`Π^⊥ ∩ Γ_d` is exactly `D_{16+d}(−1)`.** Every basis vector has doubled coordinates of one parity and doubled
coordinate sum `≡ 0 mod 4`; both properties pass to integer combinations. A lattice vector with first coordinate `0`
therefore has even doubled coordinates, i.e. it lies in `ℤⁿ` with even coordinate sum; if it is orthogonal to `Π` it
lies in `D_{16+d}` on the negative block. With `so40_point`/`so44_point` (`⊇`) this is equality. -/
theorem uniform_parity :
    [24, 28].all (fun n => (basis n).all fun b =>
      b.all (fun x => x % 2 == (b.headD 0) % 2) && b.sum % 4 == 0) = true := by
  decide +kernel

/-- **Cross-check with G2.** On ranks `0 … 8` this table agrees with `KummerD4.bestTable`. -/
theorem agrees_with_rank8_table : (best 22).take 9 = KummerD4.bestTable 8 := by
  decide +kernel

end DualScaleDyons.K3Enhancement
