/-
Stream 8 · the IR/UV obstruction, stated correctly.

A directive of 2026-09-19 proposed the theorem: "the root lattice of `SO(44)` admits no orthogonal decomposition
preserving the signature split `(3,19) ⊕ (2,2)` while keeping the transcendental lattice `T(A) = A₂`", with the
reading "a factorised static `K3 × T²` vacuum is mathematically forbidden". **That statement is false as phrased,
and this file shows why**, then states what is true.

* `Γ₆,₂₂ ⊃ Γ₄,₂₀ ⊕ Γ₂,₂` exists, and `D₂₂` embeds in `Γ₆,₂₂` (`K3Enhancement.so44_point`). Nothing about the
  `SO(44)` point forbids a decomposition of the lattice.
* At the `SO(44)` point the positive 6-plane lattice is `Π ∩ Γ = D₆` (`K3Enhancement.uniform_parity`), and the UV
  attractor charges of the two smallest black holes **do** fit inside it, primitively: `A₂` (`D = −3`, the `ω`
  point, `AttractorCharges.smallest_black_hole`) and `A₁ ⊕ A₁` (`D = −4`, the `i` point). So the charges that fix
  the near-horizon `K3 × T²` are compatible with the globally trapped 6-plane.

What is actually true is quantitative, and it is `K3Enhancement.product_points_not_maximal`: a positive 6-plane that
splits along `Γ₄,₂₀ ⊕ Γ₂,₂` — a factorised `K3 × T²` point — carries at most `760 + 6 = 766` roots, while the
global maximum is `924`. Trapping, which selects the point with the most light states, therefore does not select a
factorised point. That is a statement about which vacuum the dynamics picks, not about an algebraic impossibility.

### Sources (Tier L)
* Aspinwall (`aspinwall_hep-th_9611137.txt`) ll. 2856–2858: enhanced gauge groups in four dimensions come from
  roots orthogonal to a positive 6-plane in `Γ₆,₂₂`.
* Moore (`hep-th_9807087.txt`) (4.2)–(4.3), ll. 1344–1353: the attractor equations require `p, q ∈ Π`.
* Kofman–Linde–Liu–Maloney–McAllister–Silverstein (`hep-th_0403001.txt`) ll. 1299–1311: trapping selects the
  enhanced symmetry point with the most light states.

### What is proved (Tier A)
* `uv_charges_in_so44_plane`: `a = e₁ − e₂`, `b = e₂ − e₃` lie in `D₆`, have Gram `[[2, −1], [−1, 2]] ≅ A₂` and
  discriminant `(p·q)² − p²q² = −3`; `c = e₁ − e₂`, `d = e₁ + e₂` lie in `D₆`, have Gram `diag(2, 2)` and
  discriminant `−4`.
* `a2_saturated_in_D6`, `a1a1_saturated_in_D6`: both pairs are primitive — every vector of `D₆` in their rational
  span is an integer combination. (For `A₁ ⊕ A₁` this uses the parity condition: `(c + d)/2 = e₁` is in `ℤ⁶` but
  not in `D₆`.)
* `obstruction_is_quantitative`: the arithmetic of the true statement, `766 < 924`, with the gap `158`.

### Reading (Tier C)
The frustration between the IR trapping point and the UV attractor is real but softer than "forbidden": the
attractor charges fit inside the trapped 6-plane, and what fails is maximality — the most light states are not
obtained at a factorised `K3 × T²` point. Any stronger no-go has to quantify over the **signature split** of the
6-plane, not merely over the existence of `A₂ ⊂ Π`, and is not proved here. Nothing in this file is evidence about
the physical vacuum; it is lattice arithmetic plus the trapping principle (Tier C, §12 of
`docs/STREAM8_WHICH_K3.md`).
-/
import DualScaleDyons.K3Enhancement

namespace DualScaleDyons.TrappingObstruction

open DualScaleDyons.K3Enhancement

/-- `D₆ = {x ∈ ℤ⁶ : Σ xᵢ even}`, the positive-plane lattice `Π ∩ Γ₆,₂₂` of the `SO(44)` point. -/
def inD6 (x : Fin 6 → ℤ) : Bool := ((List.finRange 6).foldl (fun s k => s + x k) 0) % 2 == 0

def dot6 (x y : Fin 6 → ℤ) : ℤ := (List.finRange 6).foldl (fun s k => s + x k * y k) 0

def aVec : Fin 6 → ℤ := ![1, -1, 0, 0, 0, 0]
def bVec : Fin 6 → ℤ := ![0, 1, -1, 0, 0, 0]
def cVec : Fin 6 → ℤ := ![1, -1, 0, 0, 0, 0]
def dVec : Fin 6 → ℤ := ![1, 1, 0, 0, 0, 0]

/-- **The UV attractor charges fit in the `SO(44)` 6-plane.** Both charge pairs lie in `D₆`, with the Gram matrices
of `A₂` and `A₁ ⊕ A₁` and Moore discriminants `−3` and `−4`. -/
theorem uv_charges_in_so44_plane :
    (inD6 aVec && inD6 bVec && inD6 cVec && inD6 dVec) = true ∧
      (dot6 aVec aVec, dot6 aVec bVec, dot6 bVec bVec) = (2, -1, 2) ∧
      (dot6 cVec cVec, dot6 cVec dVec, dot6 dVec dVec) = (2, 0, 2) ∧
      (dot6 aVec bVec) ^ 2 - dot6 aVec aVec * dot6 bVec bVec = -3 ∧
      (dot6 cVec dVec) ^ 2 - dot6 cVec cVec * dot6 dVec dVec = -4 := by
  decide +kernel

/-- **`A₂` is primitive.** Every integer vector in the rational span of `a, b` is an integer combination:
`α = x₀` and `β = −x₂`. -/
theorem a2_saturated_in_D6 (x : Fin 6 → ℤ) (α β : ℚ) (hx : ∀ k, (x k : ℚ) = α * aVec k + β * bVec k) :
    ∀ k, x k = x 0 * aVec k + (-x 2) * bVec k := by
  have hα : α = (x 0 : ℚ) := by have := hx 0; simp [aVec, bVec] at this; linarith
  have hβ : β = -(x 2 : ℚ) := by have := hx 2; simp [aVec, bVec] at this; linarith
  intro k
  have hk := hx k
  rw [hα, hβ] at hk
  have : ((x k : ℤ) : ℚ) = ((x 0 * aVec k + (-x 2) * bVec k : ℤ) : ℚ) := by push_cast; rw [hk]
  exact_mod_cast this

/-- **`A₁ ⊕ A₁` is primitive in `D₆`** (though not in `ℤ⁶`): a vector of `D₆` in the span has `x₀ + x₁` even, so
`γ = (x₀ − x₁)/2` and `δ = (x₀ + x₁)/2` are integers. `(c + d)/2 = e₁` is in `ℤ⁶` but has odd coordinate sum. -/
theorem a1a1_saturated_in_D6 (x : Fin 6 → ℤ) (γ δ : ℚ) (hx : ∀ k, (x k : ℚ) = γ * cVec k + δ * dVec k)
    (hD6 : inD6 x = true) :
    ∃ m n : ℤ, ∀ k, x k = m * cVec k + n * dVec k := by
  have h0 : (x 0 : ℚ) = γ + δ := by have := hx 0; simp [cVec, dVec] at this; linarith
  have h1 : (x 1 : ℚ) = -γ + δ := by have := hx 1; simp [cVec, dVec] at this; linarith
  have hpar : (x 0 + x 1) % 2 = 0 := by
    have : ((List.finRange 6).foldl (fun s k => s + x k) 0) % 2 = 0 := by
      simpa [inD6] using hD6
    have hrest : ∀ k : Fin 6, 3 ≤ (k : ℕ) → x k = 0 := by
      intro k hk3
      have := hx k
      have hz : (x k : ℚ) = 0 := by
        rw [this]; fin_cases k <;> simp_all [cVec, dVec]
      exact_mod_cast hz
    have h2 : x 2 = 0 := by
      have := hx 2
      have hz : (x 2 : ℚ) = 0 := by rw [this]; simp [cVec, dVec]
      exact_mod_cast hz
    have h3 := hrest 3 (by norm_num)
    have h4 := hrest 4 (by norm_num)
    have h5 := hrest 5 (by norm_num)
    simp [List.finRange, List.foldl] at this
    omega
  obtain ⟨m, hm⟩ : ∃ m : ℤ, x 0 - x 1 = 2 * m := ⟨(x 0 - x 1) / 2, by omega⟩
  obtain ⟨n, hn⟩ : ∃ n : ℤ, x 0 + x 1 = 2 * n := ⟨(x 0 + x 1) / 2, by omega⟩
  have hm' : (x 0 : ℚ) - (x 1 : ℚ) = 2 * (m : ℚ) := by exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hm
  have hn' : (x 0 : ℚ) + (x 1 : ℚ) = 2 * (n : ℚ) := by exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hn
  have hγ : γ = (m : ℚ) := by linarith
  have hδ : δ = (n : ℚ) := by linarith
  refine ⟨m, n, fun k => ?_⟩
  have hk := hx k
  rw [hγ, hδ] at hk
  have : ((x k : ℤ) : ℚ) = ((m * cVec k + n * dVec k : ℤ) : ℚ) := by push_cast; rw [hk]
  exact_mod_cast this

/-- **The obstruction is quantitative.** A factorised `K3 × T²` point carries at most `766` roots; the global
maximum is `924` (`K3Enhancement.product_points_not_maximal`). -/
theorem obstruction_is_quantitative :
    (best 22).getD 20 0 + (best 22).getD 2 0 = 766 ∧ (best 22).getD 22 0 = 924 ∧ 924 - 766 = 158 := by
  decide +kernel

end DualScaleDyons.TrappingObstruction
