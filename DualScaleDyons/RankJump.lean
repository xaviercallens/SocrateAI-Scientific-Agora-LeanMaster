/-
G11 — the rank-jump rows of the `ρ = 20` locus, kernel-checked (2026-09-27).

### Where this comes from
Stream 2 (`SocrateAI-Scientific-Agora-K3-DarkMatter`, certificate `CM_POINTS_RHO20.json`, Tier B) lists, for
each of the two register families `cooper_s7` (`N = 7`) and `cooper_s10` (`N = 10`, ADVISORY by T0 ruling D6′),
the points of the modular curve where the Picard number jumps from `19` to `20`. At such a point a class
`v ∈ U ⊕ ⟨2N⟩` with `v² < 0` becomes algebraic, and the transcendental lattice drops to `T = v^⊥`, rank `2`,
positive definite — the CM datum of `FrickeRepair` (Huybrechts ll. 3093–3102, Tier L). Stream 2's brief of
2026-09-27 (`briefs/STREAM2_TO_LEANMASTER_RANKJUMP_ROWS_2026_09_27.md`) asks for the **lattice arithmetic** of
six rows to be kernel-checked, in the convention `v = (x, y, z)`, `v² = 2xy + 2Nz²` — which is exactly this
repository's `uPlus2N N` (`FrickeCriterion`). A first version of the request placed the vectors in a different
Gram matrix; that was withdrawn by Stream 2 after the norms disagreed (see `basis_mismatch_control` below).

### What is proved here (Tier A)
* `qform_uPlus2N`, `pair_uPlus2N`: the norm and pairing of `U ⊕ ⟨2N⟩` in coordinates, general in `N`.
* `orth_det_identity`, **general in `N`, `v`, `w₁`, `w₂`**: if `w₁, w₂ ⊥ v` then
  `det Gram(w₁, w₂) · v² = −2N · det(w₁ | w₂ | v)²`. It is `det(BᵀGB) = det(B)² det(G)` read on the block form
  that orthogonality forces — the spine of the determinant formula `det(v^⊥) = 2N·(−v²)/d²` (Stream 2's R3).
* `wall_general`, for **every** `N`: `v = e − f` has `v² = −2`, and `(e + f, w)` is a ℤ-basis of `v^⊥` with
  Gram `⟨2⟩ ⊕ ⟨2N⟩` — "basis" meaning both orthogonal *and* every lattice vector orthogonal to `v` is an
  integer combination (`IsOrthBasis`). This is the first `W_N`-fixed wall of each family.
* The six locus rows, each as `v²`, an explicit saturated ℤ-basis of `v^⊥`, its Gram matrix `[[2a, b], [b, 2c]]`
  for the certificate's reduced form `(a, b, c)`, and the membership `(a, b, c) ∈ reducedForms (4ac − b²)`:

  | family | `z` | `v` | `v²` | `T` | `D` | theorem |
  |---|---|---|---|---|---|---|
  | s7, `N = 7` | `1/27` | `(1, −1, 0)` | `−2` | `⟨2⟩ ⊕ ⟨14⟩` | `−28` | `s7_z_1_27` |
  | s7 | `−1` | `(2, −4, 1)` | `−2` | `[[2,1],[1,4]]` | `−7` | `s7_z_minus_1` |
  | s7 | `∞` | `(14, −14, −5)` | `−42` | `A₂` | `−3` | `s7_z_infinity` |
  | s10, `N = 10` | `1/16` | `(1, −1, 0)` | `−2` | `⟨2⟩ ⊕ ⟨20⟩` | `−40` | `s10_z_1_16` |
  | s10 | `−1/4` | `(2, −6, 1)` | `−4` | `[[4,2],[2,6]]` | `−20` | `s10_z_minus_1_4` |
  | s10 | `∞` | `(10, −10, −3)` | `−20` | `⟨2⟩ ⊕ ⟨2⟩` | `−4` | `s10_z_infinity` |

* `neg_three_is_square_mod_28`, `neg_three_not_square_mod_40`: the two arithmetic instances of Stream 2's
  occurrence criterion "`D` occurs in the level-`N` family iff `D` is a square mod `4N`" that decide where `A₂`
  can sit: `−3 ≡ 5² (mod 28)` and `−3` is not a square mod `40`. Stream 2 holds the same two instances in its
  own `Stream2Lean/CMPoints.lean`; this is the producer ≠ verifier copy.
* `basis_mismatch_control`: the triple `(2, −4, 1)` has norm `−2` in `uPlus2N 7` and norm `220` in the Gram
  matrix `[[0,0,−1],[0,14,0],[−1,0,0]]` first quoted as "our basis". The rows above are only meaningful in
  the first convention, and the kernel says which one that is.

### Where the kernel stops — read before citing
1. **`v^⊥ = T_X`** (the orthogonal complement of the new algebraic class *is* the transcendental lattice at the
   jump) is Dolgachev 1996 §7 / Doran 1998 Thm 5.13, **Tier L** — quoted by Stream 2, not proved here.
2. **`z`-recognition is Tier B.** That the jump for `v = (2, −4, 1)` happens at `z = −1` is a numerical
   recognition in Stream 2's certificate. Nothing here mentions `z`; the table column is a label.
3. **The index step is not proved.** `orth_det_identity` gives `det Gram(v^⊥) · v² = −2N · det(B)²`; the
   determinant formula `det(v^⊥) = 2N(−v²)/d²` needs in addition `|det B| = |v²|/d` for a saturated basis,
   with `d = gcd(x, y, 2Nz)` the divisibility of `v`. That step is **not** here; per row it is *observed*
   (`s7_z_infinity_index`: `det B = 3 = 42/14`), not derived. So the general occurrence criterion stays Tier B
   in this repository. Stream 1 (`SocrateAI-DualScaleTopologicalUniverseModel-LeanProposal`) records it as
   closed in its own tree (commit `8bb3d41`, "direction 1 closed: the determinant formula for every vector,
   `v^⊥` constructed") — read from its reflog on 2026-09-27, **not from its Lean file and not built here**.
4. **No selection.** Six rows are six lattices. Nothing here ranks them, and D7′ adopts no ranking; the s10
   rows are ADVISORY and a Tier A row does not promote the s10 lattice certificate (D6′).
-/
import DualScaleDyons.FrickeCriterion

namespace DualScaleDyons.RankJump

open Matrix DualScaleDyons.FrickeCriterion DualScaleDyons

/-! ### 1. Norm, pairing, and what "a basis of `v^⊥`" means -/

/-- The bilinear pairing of a Gram matrix, `⟨v, w⟩ = vᵀ G w`. -/
def pair (G : Matrix (Fin 3) (Fin 3) ℤ) (v w : Fin 3 → ℤ) : ℤ := v ⬝ᵥ (G *ᵥ w)

theorem pair_self (G : Matrix (Fin 3) (Fin 3) ℤ) (v : Fin 3 → ℤ) : pair G v v = qform G v := rfl

/-- **The norm of `U ⊕ ⟨2N⟩` in coordinates: `v² = 2xy + 2Nz²`.** This is the convention of Stream 2's
`CM_POINTS_RHO20.json` (`norm_is_2xy_plus_2n_z2`) and of Stream 1's `TN_norm`. -/
theorem qform_uPlus2N (N x y z : ℤ) :
    qform (uPlus2N N) ![x, y, z] = 2 * x * y + 2 * N * z ^ 2 := by
  simp [qform, uPlus2N, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]; ring

/-- The pairing in coordinates: `⟨(x,y,z), (p,q,r)⟩ = xq + yp + 2Nzr`. -/
theorem pair_uPlus2N (N x y z p q r : ℤ) :
    pair (uPlus2N N) ![x, y, z] ![p, q, r] = x * q + y * p + 2 * N * z * r := by
  simp [pair, uPlus2N, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]; ring

theorem pair_uPlus2N_comm (N : ℤ) (v w : Fin 3 → ℤ) :
    pair (uPlus2N N) v w = pair (uPlus2N N) w v := by
  simp [pair, uPlus2N, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]; ring

/-- The `2 × 2` Gram matrix of two vectors. For a reduced form `(a, b, c)` the certificate's `T` is
`[[2a, b], [b, 2c]]`, of determinant `4ac − b² = −D`. -/
def gram2 (G : Matrix (Fin 3) (Fin 3) ℤ) (w₁ w₂ : Fin 3 → ℤ) : Matrix (Fin 2) (Fin 2) ℤ :=
  !![pair G w₁ w₁, pair G w₁ w₂; pair G w₂ w₁, pair G w₂ w₂]

/-- **`w₁, w₂` is a ℤ-basis of `v^⊥`**: both are orthogonal to `v`, and *every* lattice vector orthogonal to
`v` is an integer combination of them. The second clause is the saturation that makes `v^⊥` a primitive
sublattice; without it a Gram matrix says nothing about `v^⊥`. -/
def IsOrthBasis (G : Matrix (Fin 3) (Fin 3) ℤ) (v w₁ w₂ : Fin 3 → ℤ) : Prop :=
  pair G v w₁ = 0 ∧ pair G v w₂ = 0 ∧
    ∀ w : Fin 3 → ℤ, pair G v w = 0 → ∃ a b : ℤ, w = a • w₁ + b • w₂

/-! ### 2. The determinant identity, general in everything -/

/-- The Gram matrix of three vectors is `R G Rᵀ` with `R` the matrix of rows. -/
theorem rows_gram (G : Matrix (Fin 3) (Fin 3) ℤ) (w₁ w₂ v : Fin 3 → ℤ) :
    Matrix.of ![w₁, w₂, v] * G * (Matrix.of ![w₁, w₂, v])ᵀ =
      !![pair G w₁ w₁, pair G w₁ w₂, pair G w₁ v;
         pair G w₂ w₁, pair G w₂ w₂, pair G w₂ v;
         pair G v w₁,  pair G v w₂,  pair G v v] := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [pair, Matrix.mul_apply, Matrix.vecMul, Matrix.mulVec, dotProduct, Fin.sum_univ_succ] <;> ring

/-- **`det Gram(w₁, w₂) · v² = −2N · det(w₁ | w₂ | v)²` whenever `w₁, w₂ ⊥ v` in `U ⊕ ⟨2N⟩`.** Orthogonality
makes `R G Rᵀ` block-diagonal, and `det(R G Rᵀ) = det(R)² · det(G)` with `det(U ⊕ ⟨2N⟩) = −2N`. General in
`N` and in all three vectors; no saturation is assumed. It is the spine of the determinant formula
`det(v^⊥) = 2N(−v²)/d²` — what is *not* here is `|det R| = |v²|/d` (header, item 3). -/
theorem orth_det_identity (N : ℤ) (v w₁ w₂ : Fin 3 → ℤ)
    (h₁ : pair (uPlus2N N) v w₁ = 0) (h₂ : pair (uPlus2N N) v w₂ = 0) :
    (gram2 (uPlus2N N) w₁ w₂).det * pair (uPlus2N N) v v
      = -2 * N * (Matrix.of ![w₁, w₂, v]).det ^ 2 := by
  have hd : (Matrix.of ![w₁, w₂, v] * uPlus2N N * (Matrix.of ![w₁, w₂, v])ᵀ).det
      = (Matrix.of ![w₁, w₂, v]).det * (uPlus2N N).det * (Matrix.of ![w₁, w₂, v]).det := by
    rw [Matrix.det_mul, Matrix.det_mul, Matrix.det_transpose]
  have h₁' : pair (uPlus2N N) w₁ v = 0 := by rw [pair_uPlus2N_comm]; exact h₁
  have h₂' : pair (uPlus2N N) w₂ v = 0 := by rw [pair_uPlus2N_comm]; exact h₂
  rw [rows_gram, det_uPlus2N] at hd
  simp [Matrix.det_fin_three, h₁, h₂, h₁', h₂'] at hd
  simp [gram2, Matrix.det_fin_two_of, Matrix.det_fin_three]
  linear_combination hd

/-! ### 3. The first wall, for every `N` -/

/-- **`v = e − f` for every `N`: `v² = −2`, and `(e + f, w)` is a ℤ-basis of `v^⊥` with Gram `⟨2⟩ ⊕ ⟨2N⟩`.**
Instances: s7 at `z = 1/27` (`D = −28`) and s10 at `z = 1/16` (`D = −40`). -/
theorem wall_general (N : ℤ) :
    qform (uPlus2N N) ![1, -1, 0] = -2 ∧
      IsOrthBasis (uPlus2N N) ![1, -1, 0] ![1, 1, 0] ![0, 0, 1] ∧
      gram2 (uPlus2N N) ![1, 1, 0] ![0, 0, 1] = !![2, 0; 0, 2 * N] := by
  refine ⟨by rw [qform_uPlus2N]; ring, ⟨by rw [pair_uPlus2N]; ring, by rw [pair_uPlus2N]; ring, ?_⟩, ?_⟩
  · intro w hw
    simp [pair, uPlus2N, Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at hw
    refine ⟨w 0, w 2, ?_⟩
    ext i
    fin_cases i <;> simp <;> omega
  · ext i j
    fin_cases i <;> fin_cases j <;>
      simp [gram2, pair, uPlus2N, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]

/-! ### 4. The six locus rows -/

/-- **s7, `z = 1/27`, `D = −28`**: `v = (1, −1, 0)`, `T = ⟨2⟩ ⊕ ⟨14⟩ = (1, 0, 7)`. -/
theorem s7_z_1_27 :
    qform (uPlus2N 7) ![1, -1, 0] = -2 ∧
      IsOrthBasis (uPlus2N 7) ![1, -1, 0] ![1, 1, 0] ![0, 0, 1] ∧
      gram2 (uPlus2N 7) ![1, 1, 0] ![0, 0, 1] = !![2, 0; 0, 14] ∧
      (1, 0, 7) ∈ reducedForms 28 := by
  obtain ⟨h1, h2, h3⟩ := wall_general 7
  exact ⟨h1, h2, by rw [h3]; decide, by decide +kernel⟩

/-- **s7, `z = −1`, `D = −7`**: `v = (2, −4, 1)`, `v² = −2`, `v^⊥` has ℤ-basis `(2, −3, 1), (1, 2, 0)` with
Gram `[[2, 1], [1, 4]]`, the reduced form `(1, 1, 2)`. This is the second `W₇`-fixed point. The hand
computation that opened the exchange used `(−2, 4, 1)`, the image of the certificate's `(2, −4, 1)` under the
isometry `(x, y, z) ↦ (−x, −y, z)`; the row is stated for the certificate's vector. -/
theorem s7_z_minus_1 :
    qform (uPlus2N 7) ![2, -4, 1] = -2 ∧
      IsOrthBasis (uPlus2N 7) ![2, -4, 1] ![2, -3, 1] ![1, 2, 0] ∧
      gram2 (uPlus2N 7) ![2, -3, 1] ![1, 2, 0] = !![2, 1; 1, 4] ∧
      (1, 1, 2) ∈ reducedForms 7 := by
  refine ⟨by decide +kernel, ⟨by decide +kernel, by decide +kernel, ?_⟩, by decide +kernel,
    by decide +kernel⟩
  intro w hw
  simp [pair, uPlus2N, Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at hw
  refine ⟨w 2, w 0 - 2 * w 2, ?_⟩
  ext i
  fin_cases i <;> simp <;> omega

/-- **s7, `z = ∞`, `D = −3`**: `v = (14, −14, −5)`, `v² = −42`, divisibility `14`, and `v^⊥` has ℤ-basis
`(1, 1, 0), (−2, 3, 1)` with Gram `A₂ = [[2, 1], [1, 2]]`, the reduced form `(1, 1, 1)` of
`FrickeRepair.repair_selects`. The order-3 elliptic point of `X₀(7)⁺`, where G10's minimum sits. -/
theorem s7_z_infinity :
    qform (uPlus2N 7) ![14, -14, -5] = -42 ∧
      IsOrthBasis (uPlus2N 7) ![14, -14, -5] ![1, 1, 0] ![-2, 3, 1] ∧
      gram2 (uPlus2N 7) ![1, 1, 0] ![-2, 3, 1] = !![2, 1; 1, 2] ∧
      (1, 1, 1) ∈ reducedForms 3 := by
  refine ⟨by decide +kernel, ⟨by decide +kernel, by decide +kernel, ?_⟩, by decide +kernel,
    by decide +kernel⟩
  intro w hw
  simp [pair, uPlus2N, Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at hw
  refine ⟨w 0 + 2 * w 2, w 2, ?_⟩
  ext i
  fin_cases i <;> simp <;> omega

/-- **The index, observed on the `A₂` row**: `det(w₁ | w₂ | v) = 3 = 42 / 14 = |v²| / d`. Consistent with
`orth_det_identity` (`3 · (−42) = −14 · 3²`) and with the unproved index step of the header — an
observation at one row, not a theorem about `d`. -/
theorem s7_z_infinity_index :
    (Matrix.of ![![1, 1, 0], ![-2, 3, 1], ![14, -14, -5]] : Matrix (Fin 3) (Fin 3) ℤ).det = 3 ∧
      (3 : ℤ) * (-42) = -2 * 7 * 3 ^ 2 := by
  exact ⟨by simp [Matrix.det_fin_three], by norm_num⟩

/-- **s10, `z = 1/16`, `D = −40`** (ADVISORY family): `v = (1, −1, 0)`, `T = ⟨2⟩ ⊕ ⟨20⟩ = (1, 0, 10)`. -/
theorem s10_z_1_16 :
    qform (uPlus2N 10) ![1, -1, 0] = -2 ∧
      IsOrthBasis (uPlus2N 10) ![1, -1, 0] ![1, 1, 0] ![0, 0, 1] ∧
      gram2 (uPlus2N 10) ![1, 1, 0] ![0, 0, 1] = !![2, 0; 0, 20] ∧
      (1, 0, 10) ∈ reducedForms 40 := by
  obtain ⟨h1, h2, h3⟩ := wall_general 10
  exact ⟨h1, h2, by rw [h3]; decide, by decide +kernel⟩

/-- **s10, `z = −1/4`, `D = −20`** (ADVISORY): `v = (2, −6, 1)`, `v² = −4`, `v^⊥` has ℤ-basis
`(2, −4, 1), (1, 3, 0)` with Gram `[[4, 2], [2, 6]]`, the reduced form `(2, 2, 3)`. -/
theorem s10_z_minus_1_4 :
    qform (uPlus2N 10) ![2, -6, 1] = -4 ∧
      IsOrthBasis (uPlus2N 10) ![2, -6, 1] ![2, -4, 1] ![1, 3, 0] ∧
      gram2 (uPlus2N 10) ![2, -4, 1] ![1, 3, 0] = !![4, 2; 2, 6] ∧
      (2, 2, 3) ∈ reducedForms 20 := by
  refine ⟨by decide +kernel, ⟨by decide +kernel, by decide +kernel, ?_⟩, by decide +kernel,
    by decide +kernel⟩
  intro w hw
  simp [pair, uPlus2N, Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at hw
  refine ⟨w 2, w 0 - 2 * w 2, ?_⟩
  ext i
  fin_cases i <;> simp <;> omega

/-- **s10, `z = ∞`, `D = −4`** (ADVISORY): `v = (10, −10, −3)`, `v² = −20`, divisibility `10`, `v^⊥` has
ℤ-basis `(1, 1, 0), (−3, 3, 1)` with Gram `⟨2⟩ ⊕ ⟨2⟩`, the reduced form `(1, 0, 1)` — the `τ = i` lattice of
`WhichK3`, at the order-4 elliptic point of `X₀(10)⁺`. -/
theorem s10_z_infinity :
    qform (uPlus2N 10) ![10, -10, -3] = -20 ∧
      IsOrthBasis (uPlus2N 10) ![10, -10, -3] ![1, 1, 0] ![-3, 3, 1] ∧
      gram2 (uPlus2N 10) ![1, 1, 0] ![-3, 3, 1] = !![2, 0; 0, 2] ∧
      (1, 0, 1) ∈ reducedForms 4 := by
  refine ⟨by decide +kernel, ⟨by decide +kernel, by decide +kernel, ?_⟩, by decide +kernel,
    by decide +kernel⟩
  intro w hw
  simp [pair, uPlus2N, Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at hw
  refine ⟨w 0 + 3 * w 2, w 2, ?_⟩
  ext i
  fin_cases i <;> simp <;> omega

/-! ### 5. The two arithmetic instances of the occurrence criterion -/

/-- `−3 ≡ 5² (mod 28)`: `A₂` can occur in the level-7 family — and `s7_z_infinity` exhibits it. -/
theorem neg_three_is_square_mod_28 : (5 ^ 2 + 3) % 28 = 0 := by decide

/-- `−3` is not a square mod `40`: the criterion excludes `A₂` from the level-10 family. The criterion itself
(`D` occurs iff `D` is a square mod `4N`) is Stream 2's R3, Tier B here — only its arithmetic is decided. -/
theorem neg_three_not_square_mod_40 : ∀ s < 40, (s ^ 2 + 3) % 40 ≠ 0 := by decide

/-! ### 6. The control that fixed the convention -/

/-- **The basis mismatch, in the kernel.** The triple `(2, −4, 1)` has norm `−2` in `uPlus2N 7` and norm
`220` in `[[0, 0, −1], [0, 14, 0], [−1, 0, 0]]`, the Gram matrix first quoted for it (the hand check that
raised the question used `(−2, 4, 1)`, norm `228` there; the two are exchanged by the isometry
`(x, y, z) ↦ (−x, −y, z)` of `uPlus2N`, and neither has norm `−2` in the quoted Gram). Stream 2 withdrew the
attribution on 2026-09-27 (the certificate's own self-test states `2xy + 2Nz²`). Kept so the row theorems
cannot be read back into the wrong lattice. A first draft of this theorem said `228` for `(2, −4, 1)` and
`decide` refused it — the control controlled its author. -/
theorem basis_mismatch_control :
    qform (uPlus2N 7) ![2, -4, 1] = -2 ∧
      qform !![0, 0, -1; 0, 14, 0; -1, 0, 0] ![2, -4, 1] = 220 := by
  refine ⟨by decide +kernel, by decide +kernel⟩

/-! ### 7. The rows, bundled -/

/-- **G11 in one statement**: the six saturated bases. Each conjunct is the `IsOrthBasis` clause of the row
theorem it names; the norms, Gram matrices and `reducedForms` memberships live there. Tier A for the lattice
arithmetic of these six vectors, and for nothing about `z`, `T_X`, or which K3 is selected (header). -/
theorem g11_rows :
    IsOrthBasis (uPlus2N 7) ![1, -1, 0] ![1, 1, 0] ![0, 0, 1] ∧
      IsOrthBasis (uPlus2N 7) ![2, -4, 1] ![2, -3, 1] ![1, 2, 0] ∧
      IsOrthBasis (uPlus2N 7) ![14, -14, -5] ![1, 1, 0] ![-2, 3, 1] ∧
      IsOrthBasis (uPlus2N 10) ![1, -1, 0] ![1, 1, 0] ![0, 0, 1] ∧
      IsOrthBasis (uPlus2N 10) ![2, -6, 1] ![2, -4, 1] ![1, 3, 0] ∧
      IsOrthBasis (uPlus2N 10) ![10, -10, -3] ![1, 1, 0] ![-3, 3, 1] :=
  ⟨s7_z_1_27.2.1, s7_z_minus_1.2.1, s7_z_infinity.2.1, s10_z_1_16.2.1, s10_z_minus_1_4.2.1,
    s10_z_infinity.2.1⟩

end DualScaleDyons.RankJump
