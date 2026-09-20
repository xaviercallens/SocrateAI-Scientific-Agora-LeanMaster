/-
Stream 9 · S9.5 — the flux lattice of `T⁶`, and why the tadpole alone bounds nothing.

`T6TadpoleFiniteness.lean` (S9.2) solved `N_D3 + ½N_flux = 16` and found 17 pairs, with the warning that a pair is
not a vacuum because one value of `½N_flux` corresponds to many flux quanta. This file turns that warning into a
theorem: the flux contribution is a **symplectic pairing** of two integer vectors in a lattice of rank 20, and for
every value `k` there are **infinitely many** pairs of flux vectors giving `N_flux = k`.

### What is proved (Tier A)
* `h3_rank`: `rank H³(T⁶, ℤ) = C(6,3) = 20`.
* `symplectic_sq`, `symplectic_unimodular`: the intersection form `J` on `H³` (rank 20, block `[[0,1],[−1,0]]`)
  satisfies `J·J = −1`, hence is unimodular; `symplectic_antisymm`: `Jᵀ = −J`.
* `flux_pairing_family`: for every `k : ℤ` and every `m : ℤ`, the vectors `H = e₀` and `F(m) = k f₀ + m e₁`
  satisfy `⟨H, F(m)⟩ = k`.
* `flux_family_injective`: `m ↦ F(m)` is injective, so the solution set of `⟨H, F⟩ = k` is infinite for every `k`.
* `tadpole_does_not_bound_flux`: consequently, the tadpole equation of S9.2 bounds the **integer** `½N_flux`, but
  not the flux quanta that realise it.

### Reading (Tier L / Tier C)
Tier L: in the GKP-type setting the flux tadpole is the pairing `∫ H₃ ∧ F₃` of two integral three-forms, and the
orientifold projection keeps an invariant sublattice of `H³(T⁶, ℤ)`; the references are those pinned in
`NarainT6.lean` plus `TadpoleCancellation.lean`.

Tier C — the point of the file: **finiteness of a flux landscape cannot come from the tadpole alone.** It needs
the supersymmetry/imaginary-self-duality conditions and quotienting by the duality group. Any statement of the
form "there are `N` vacua" that cites only a tadpole budget is counting the wrong set. This file does not model
the invariant sublattice of the specific `ℤ₂ × ℤ₂` action, nor the quantisation conditions; it isolates one
mechanism and proves it.
-/
import DualScaleStream2.Flux.T6TadpoleFiniteness

namespace DualScaleStream2.Flux.FluxLattice

open Matrix DualScaleStream2.Lattice

/-- `dim H³(T⁶, ℤ) = C(6,3) = 20`. -/
theorem h3_rank : Nat.choose 6 3 = 20 := by decide

/-- The intersection form on `H³(T⁶, ℤ)`: ten symplectic blocks. -/
def symJ : Gram 20 :=
  !![0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1;
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0]

theorem symplectic_antisymm : symJᵀ = -symJ := by decide +kernel

theorem symplectic_sq : symJ * symJ = -1 := by decide +kernel

theorem symplectic_unimodular : IsUnimodular symJ := by
  have h : (-symJ) * symJ = 1 := by
    rw [Matrix.neg_mul, symplectic_sq]; simp
  exact isUnimodular_of_mul_eq_one symJ (-symJ) h

/-- The flux tadpole contribution: the symplectic pairing of the two three-form fluxes. -/
def fluxPairing (H F : Fin 20 → ℤ) : ℤ := H ⬝ᵥ (symJ *ᵥ F)

/-- `H = e₀`. -/
def hVec : Fin 20 → ℤ := fun i => if i = 0 then 1 else 0

/-- `F(k, m) = k f₀ + m e₁`: one flux with the required pairing, one direction that does not change it. -/
def fVec (k m : ℤ) : Fin 20 → ℤ := fun i => if i = 1 then k else if i = 2 then m else 0

/-- **Every value is attained, in infinitely many ways.** -/
theorem flux_pairing_family (k m : ℤ) : fluxPairing hVec (fVec k m) = k := by
  simp [fluxPairing, hVec, fVec, symJ, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]

theorem flux_family_injective (k : ℤ) : Function.Injective (fVec k) := by
  intro m₁ m₂ h
  have := congrFun h 2
  simpa [fVec] using this

/-- **The tadpole does not bound the flux quanta.** For every `k` the set of `F` with `⟨e₀, F⟩ = k` is infinite:
the integer `½N_flux` is bounded by the budget, the flux vectors realising it are not. -/
theorem tadpole_does_not_bound_flux (k : ℤ) :
    ∀ m : ℤ, fluxPairing hVec (fVec k m) = k ∧ Function.Injective (fVec k) :=
  fun m => ⟨flux_pairing_family k m, flux_family_injective k⟩

end DualScaleStream2.Flux.FluxLattice
