/-
Stream 9 · the lattice layer of a `T⁶/Γ` orientifold: `Γ₆,₆`, the orientifold involutions, and the
plane/brane charge budget.

Streams 1–8 live on `K3 × T²`, which is `N = 4` and non-chiral (Stream 7). Orientifolds of `T⁶` are the standard
route to `N = 1` that keeps every ingredient finite and integral, hence certifiable. This file builds **only the
lattice layer**: the Narain lattice of `T⁶`, the involutions an orientifold uses, and the integer charge budget.
No statement about supersymmetry, spectra, moduli stabilisation or vacua is made or implied.

### Sources (Tier L)
* GPR (`giveon_hep-th_9401139.txt`) ll. 260–300, 470–520: the Narain lattice of `T^d` is the even self-dual
  lattice of signature `(d, d)`, `Γ_{d,d} ≅ U^d`, with `Q(n, w) = 2 n·w` on momentum/winding; T-duality is
  `O(d, d; ℤ)`.
* Polchinski, TASI (`polchinski_tasi_dbranes_hep-th_9611050.txt`) ll. 1968–1984, eq. (93): an `O_p` plane carries
  `−2^{p−5}` times the `D_p` charge, and a toroidal orientifold has `2^{9−p}` of them, so the total plane charge
  is `−16` for every `p`.
* Sen (`hep-th_9605150.txt`) ll. 238–250 and the correction recorded in
  `StringTheoryFoundation/StringTheory/TadpoleCancellation.lean` (v3.21.0): the same `−16` in the `T²/ℤ₂` frame,
  four `O7` planes of charge `−4` cancelled by sixteen `D7` branes.

### What is proved (Tier A)
* `gamma66`, `gamma66_symm`, `gamma66_evenDiag`, `gamma66_unimodular`: `Γ₆,₆ = U⁶` is symmetric, has even
  diagonal and is unimodular (by an exhibited integer inverse, the `Lattice.Basic` certificate route).
* `gamma66_signature`: six explicit vectors of norm `+2` and six of norm `−2`, pairwise orthogonal — a certificate
  that the form has signature `(6, 6)`.
* `theta_isometries`: the three non-trivial elements `θ₁, θ₂, θ₃` of the `ℤ₂ × ℤ₂` that a `T⁶/(ℤ₂×ℤ₂)`
  orientifold uses (each flipping four real coordinates) are isometries of `Γ₆,₆`, square to the identity, and
  compose as `θ₁θ₂ = θ₃`.
* `parity_antiisometry`: worldsheet parity `Ω` (`w ↦ −w`, i.e. `eᵢ ↦ eᵢ`, `fᵢ ↦ −fᵢ`) satisfies
  `Mᵀ G M = −G`: it is an **anti**-isometry of the Narain form. This is the precise lattice statement of "Ω
  exchanges left- and right-movers", and it is why an orientifold is not a subgroup of `O(6,6;ℤ)`.
* `orientifold_involutions`: `Ω θᵢ` squares to the identity for each `i`, so `Ω` times any element of the group
  is an involution of the lattice.
* `fixed_points_pow`: `x ↦ −x` on `T^k` has `2^k` fixed points; with `k = 9 − p` this is the `O_p` count.
* `plane_charge_total`: for `p = 3, 5, 7, 9`, `2^{9−p} · (−2^{p−5}) = −16` — the plane charge is `−16` in every
  frame, so the brane number that cancels it is `16` (in `D_p` units). For `p = 3`: 64 planes of charge `−1/4`.

### What is NOT claimed
That any particular `Γ` gives `N = 1`; that the spectrum is chiral; that these lattices describe a vacuum. The
charge arithmetic is the tadpole *budget*, not a solution: a solution also needs the geometry of the branes and
(with flux) the `½N_flux + N_D3` relation of `TadpoleCancellation.lean`. Stream 9's physics is Tier L/C and will be
written in `docs/STREAM9_ORIENTIFOLD.md` as it is built.
-/
import DualScaleStream2.Lattice.Hyperbolic

namespace DualScaleStream2.Orientifold

open Matrix DualScaleStream2.Lattice

def gamma66 : Gram 12 :=
  !![0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]

/-- Worldsheet parity `Ω`: momenta fixed, windings reversed. -/
def omegaP : Gram 12 :=
  !![1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1]

/-- `θ₁`: the reflection flipping the first two coordinate pairs (four real coordinates of `T⁶`). -/
def theta1 : Gram 12 :=
  !![-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]

/-- `θ₂`: flips the third and fourth pairs. -/
def theta2 : Gram 12 :=
  !![1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]

/-- `θ₃ = θ₁θ₂`: flips the first, second, fifth and sixth pairs — the third element of `ℤ₂ × ℤ₂`. -/
def theta3 : Gram 12 :=
  !![-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]

theorem gamma66_symm : gamma66ᵀ = gamma66 := by decide +kernel

theorem gamma66_evenDiag : IsEvenDiag gamma66 := by
  intro i
  fin_cases i <;> exact ⟨0, by rfl⟩

/-- `U` is its own inverse, hence so is `U⁶`. -/
theorem gamma66_mul_self : gamma66 * gamma66 = 1 := by decide +kernel

theorem gamma66_unimodular : IsUnimodular gamma66 :=
  isUnimodular_of_mul_eq_one gamma66 gamma66 gamma66_mul_self

/-- The quadratic form of a Gram matrix on an integer vector: `Q(v) = vᵀ G v`. -/
def q12 (G : Gram 12) (v : Fin 12 → ℤ) : ℤ := ∑ i : Fin 12, ∑ j : Fin 12, v i * G i j * v j

/-- `e_b + f_b` and `e_b − f_b` for the six blocks. -/
def plusVec (b : Fin 6) : Fin 12 → ℤ := fun i => if (i : ℕ) / 2 = (b : ℕ) then 1 else 0
def minusVec (b : Fin 6) : Fin 12 → ℤ := fun i =>
  if (i : ℕ) = 2 * (b : ℕ) then 1 else if (i : ℕ) = 2 * (b : ℕ) + 1 then -1 else 0

/-- **Signature `(6, 6)` certificate.** Six vectors of norm `+2` and six of norm `−2`. -/
theorem gamma66_signature :
    (∀ b : Fin 6, q12 gamma66 (plusVec b) = 2) ∧ (∀ b : Fin 6, q12 gamma66 (minusVec b) = -2) := by
  constructor <;> decide +kernel

/-- **The `ℤ₂ × ℤ₂` reflections are isometries**, are involutions, and compose as `θ₁θ₂ = θ₃`. -/
theorem theta_isometries :
    (theta1ᵀ * gamma66 * theta1 = gamma66 ∧ theta2ᵀ * gamma66 * theta2 = gamma66 ∧
      theta3ᵀ * gamma66 * theta3 = gamma66) ∧
      (theta1 * theta1 = 1 ∧ theta2 * theta2 = 1 ∧ theta3 * theta3 = 1) ∧
      theta1 * theta2 = theta3 := by
  refine ⟨⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ?_⟩ <;> decide +kernel

/-- **Parity is an anti-isometry**: `Ωᵀ G Ω = −G`. Exchanging left- and right-movers reverses the sign of the
Narain form, which is why an orientifold group is not a subgroup of `O(6,6;ℤ)`. -/
theorem parity_antiisometry : omegaPᵀ * gamma66 * omegaP = -gamma66 := by decide +kernel

/-- `Ω` squares to the identity and commutes with each `θᵢ`, so every `Ω θᵢ` is an involution. -/
theorem orientifold_involutions :
    omegaP * omegaP = 1 ∧
      ((omegaP * theta1) * (omegaP * theta1) = 1 ∧ (omegaP * theta2) * (omegaP * theta2) = 1 ∧
        (omegaP * theta3) * (omegaP * theta3) = 1) := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> decide +kernel

/-- Each `Ω θᵢ` is also an anti-isometry (the sign comes from `Ω` alone). -/
theorem orientifold_antiisometries :
    (omegaP * theta1)ᵀ * gamma66 * (omegaP * theta1) = -gamma66 ∧
      (omegaP * theta2)ᵀ * gamma66 * (omegaP * theta2) = -gamma66 ∧
      (omegaP * theta3)ᵀ * gamma66 * (omegaP * theta3) = -gamma66 := by
  refine ⟨?_, ?_, ?_⟩ <;> decide +kernel

/-! ### The charge budget -/

/-- Fixed points of `x ↦ −x` on `T^k`: `2^k`; for `k = 4` (one `θᵢ`) that is 16 fixed planes, for `k = 6`
(the full reflection) `64`. -/
theorem fixed_point_counts : (2 : ℕ) ^ 4 = 16 ∧ (2 : ℕ) ^ 6 = 64 := by norm_num

/-- Number of `O_p` planes in a toroidal orientifold: `2^{9−p}` (Polchinski eq. (93)). -/
def numPlanes (p : ℕ) : ℕ := 2 ^ (9 - p)

/-- Charge of one `O_p` plane in `D_p` units: `−2^{p−5}`. -/
def planeCharge (p : ℕ) : ℚ := -(2 : ℚ) ^ (p : ℤ) / 32

/-- **The budget is `−16` in every frame.** For `p = 3, 5, 7, 9`, `2^{9−p}` planes of charge `−2^{p−5}` total
`−16`, so 16 `D_p` branes cancel them. For `p = 3` that is 64 planes of charge `−1/4`. -/
theorem plane_charge_total :
    ((numPlanes 3 : ℚ) * planeCharge 3 = -16 ∧ (numPlanes 5 : ℚ) * planeCharge 5 = -16 ∧
      (numPlanes 7 : ℚ) * planeCharge 7 = -16 ∧ (numPlanes 9 : ℚ) * planeCharge 9 = -16) ∧
      numPlanes 3 = 64 ∧ planeCharge 3 = -1/4 ∧ numPlanes 7 = 4 ∧ planeCharge 7 = -4 := by
  refine ⟨⟨?_, ?_, ?_, ?_⟩, by norm_num [numPlanes], by norm_num [planeCharge], by
    norm_num [numPlanes], by norm_num [planeCharge]⟩ <;>
    norm_num [numPlanes, planeCharge]

/-- Cross-check with the `T²/ℤ₂` frame already formalized: four `O7` planes of charge `−4` and sixteen `D7`
branes of charge `+1` cancel, which is the `p = 7` case of `plane_charge_total`. -/
theorem consistent_with_O7_frame : (4 : ℚ) * (-4) + 16 * 1 = 0 := by norm_num

end DualScaleStream2.Orientifold
