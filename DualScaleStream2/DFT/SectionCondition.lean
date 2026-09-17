/-
Stream 2 · P2.4 — Level matching and the DFT section condition on the charge lattice.

Source (Tier L): Hull & Zwiebach, *Double Field Theory*, arXiv:0904.4664
(`papers/foundations/hull_zwiebach_0904_4664.txt`):
* eq. (1.3), line 231: "L₀ − L̄₀ = N − N̄ − pₐwᵃ = 0" (level matching);
* lines 339–342: "The solutions independent of x̃ give the gravity field …, the antisymmetric
  tensor field … and the dilaton …. The solutions independent of xᵃ give dual versions of
  these fields";
* lines 3930–3940: restriction to null subspaces; "A 2d dimensional space with metric of
  signature (d, d) can have totally null d-dimensional subspaces".

Tier A here, every `d`, on the integer charge lattice `ℤ^d ⊕ ℤ^d` (momentum ⊕ winding) with
the `η`-pairing:
* at `N = N̄`, level matching is exactly `n · w = 0`, i.e. the charge is `η`-null;
* the pure-momentum frame (no winding: the "independent of x̃" supergravity frame) and the
  pure-winding frame (its dual) are each totally null — they solve the section condition;
* the full T-duality `η` maps the momentum frame onto the winding frame;
* any `O(d,d;ℤ)` element maps a section to a section.
-/
import DualScaleStream2.TDuality.Factorized

namespace DualScaleStream2.DFT

open Matrix DualScaleStream2.TDuality

variable {d : ℕ}

/-- The `η`-pairing `Z ∘ Z' = Zᵀ η Z'`. -/
def etaPair (Z Z' : Charge d → ℤ) : ℤ := Z ⬝ᵥ (eta d *ᵥ Z')

/-- A set of charges is a *section* if it is totally `η`-null. -/
def IsSection (S : Set (Charge d → ℤ)) : Prop := ∀ Z ∈ S, ∀ Z' ∈ S, etaPair Z Z' = 0

/-- Pure-momentum frame (no winding). -/
def momentumFrame (d : ℕ) : Set (Charge d → ℤ) :=
  {Z | ∃ n : Fin d → ℤ, Z = Sum.elim n (0 : Fin d → ℤ)}

/-- Pure-winding frame (no momentum). -/
def windingFrame (d : ℕ) : Set (Charge d → ℤ) :=
  {Z | ∃ w : Fin d → ℤ, Z = Sum.elim (0 : Fin d → ℤ) w}

/-- **Level matching at `N = N̄`** (HZ eq. (1.3)): the charge is `η`-null iff `n · w = 0`. -/
theorem levelMatching_iff (n w : Fin d → ℤ) :
    chargeNorm (Sum.elim n w) = 0 ↔ n ⬝ᵥ w = 0 := by
  rw [chargeNorm_sumElim]
  constructor <;> intro h <;> omega

theorem etaPair_self (Z : Charge d → ℤ) : etaPair Z Z = chargeNorm Z := by
  unfold etaPair chargeNorm; rfl

/-- The full T-duality maps pure momentum to pure winding. -/
theorem eta_momentum_to_winding (n : Fin d → ℤ) :
    eta d *ᵥ Sum.elim n (0 : Fin d → ℤ) = Sum.elim (0 : Fin d → ℤ) n := by
  unfold eta
  rw [fromBlocks_mulVec]
  ext x
  cases x with
  | inl i => simp [Sum.elim_inl, Sum.elim_inr, Matrix.zero_mulVec, Matrix.one_mulVec]
  | inr i => simp [Sum.elim_inl, Sum.elim_inr, Matrix.zero_mulVec, Matrix.one_mulVec]

theorem momentumFrame_isSection : IsSection (momentumFrame d) := by
  rintro Z ⟨n, rfl⟩ Z' ⟨n', rfl⟩
  unfold etaPair
  rw [eta_momentum_to_winding]
  simp [sumElim_dotProduct_sumElim, dotProduct_zero, zero_dotProduct]

theorem windingFrame_isSection : IsSection (windingFrame d) := by
  rintro Z ⟨w, rfl⟩ Z' ⟨w', rfl⟩
  unfold etaPair eta
  rw [fromBlocks_mulVec]
  simp [Sum.elim_comp_inl, Sum.elim_comp_inr, sumElim_dotProduct_sumElim, dotProduct_zero, zero_dotProduct]

/-- `O(d,d;ℤ)` maps sections to sections. -/
theorem isSection_image (g : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g)
    (S : Set (Charge d → ℤ)) (hS : IsSection S) :
    IsSection ((fun Z => g *ᵥ Z) '' S) := by
  rintro _ ⟨Z, hZ, rfl⟩ _ ⟨Z', hZ', rfl⟩
  unfold etaPair
  have key : (g *ᵥ Z) ⬝ᵥ (eta d *ᵥ (g *ᵥ Z')) = Z ⬝ᵥ ((gᵀ * eta d * g) *ᵥ Z') := by
    rw [← Matrix.mulVec_mulVec, ← Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec Z gᵀ,
      Matrix.vecMul_transpose]
  rw [key, hg]
  exact hS Z hZ Z' hZ'

end DualScaleStream2.DFT
