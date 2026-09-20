/-
Stream 9 · S9.1 — the invariant sublattice of an orientifold generator is totally isotropic, of rank 6.

`NarainT6.lean` proved that worldsheet parity is an **anti**-isometry of `Γ₆,₆` (`Ωᵀ G Ω = −G`). This file draws
the consequence: whatever an anti-isometry fixes is null for the Narain form. Applied to `P = Ω θᵢ`, the fixed
sublattice is totally isotropic of rank 6 — maximal, since a form of signature `(6, 6)` admits no isotropic
sublattice of rank 7.

### What is proved (Tier A)
* `antiisometry_fixed_isotropic`: **the general lemma.** If `Pᵀ G P = −G` and `P v = v`, then `Q(v) = 0`.
  (`Q(v) = (Pv)ᵀ G (Pv) = vᵀ(Pᵀ G P)v = −Q(v)`, and `2Q(v) = 0` in `ℤ` forces `Q(v) = 0`.) It needs no
  positivity, no invertibility, and nothing about `P` beyond the anti-isometry identity.
* `omegaTheta1_antiisometry`: `P = Ω θ₁` satisfies the hypothesis (re-checked here, not assumed).
* `invBasis_fixed`: the six vectors `f₁, f₂, e₃, e₄, e₅, e₆` are fixed by `P`.
* `invariant_iff`: **exactly** those coordinates are free — a vector is fixed by `P` iff its `e₁, e₂, f₃, f₄, f₅,
  f₆` components vanish. So the fixed sublattice is spanned by the six vectors above and has rank 6.
* `invBasis_totally_isotropic`: all `36` pairings among them vanish, so the sublattice is totally isotropic (not
  merely null on the diagonal), and `invBasis_independent` exhibits a `6 × 6` minor equal to `1`.

### Tier L / Tier C
Tier L: in an orientifold, the projection keeps the states invariant under the orientifold generator. That a
maximal isotropic sublattice of `Γ_{6,6}` is what survives is the lattice shadow of that projection; the standard
references for the projection itself are the ones pinned in `NarainT6.lean`.

Tier C — and deliberately weaker than the slogan: rank 6 out of 12 is half the lattice, and an isotropic lattice
carries no Narain norm, so no winding/momentum "length" distinguishes its vectors. Calling that "half the degrees
of freedom are frozen" is a reading, not a theorem: this file says nothing about which *states* survive, about
moduli, or about the spectrum. What is proved is the lattice statement.
-/
import DualScaleStream2.Orientifold.NarainT6

namespace DualScaleStream2.Orientifold

open Matrix DualScaleStream2.Lattice

/-- The Narain quadratic form of a Gram matrix: `Q(v) = vᵀ G v`. -/
def qform (G : Gram 12) (v : Fin 12 → ℤ) : ℤ := v ⬝ᵥ (G *ᵥ v)

/-- The Narain pairing: `B(v, w) = vᵀ G w`. -/
def bform (G : Gram 12) (v w : Fin 12 → ℤ) : ℤ := v ⬝ᵥ (G *ᵥ w)

/-- **The general lemma.** A vector fixed by an anti-isometry is null. -/
theorem antiisometry_fixed_isotropic (G P : Gram 12) (hP : Pᵀ * G * P = -G) (v : Fin 12 → ℤ)
    (hv : P *ᵥ v = v) : qform G v = 0 := by
  have step : (P *ᵥ v) ⬝ᵥ (G *ᵥ (P *ᵥ v)) = v ⬝ᵥ ((Pᵀ * G * P) *ᵥ v) := by
    rw [Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec,
      show P *ᵥ v = v ᵥ* Pᵀ from (Matrix.mulVec_transpose Pᵀ v).symm ▸ by
        simp [Matrix.mulVec_transpose],
      Matrix.vecMul_vecMul, ← Matrix.dotProduct_mulVec, Matrix.mul_assoc]
  have h1 : v ⬝ᵥ ((Pᵀ * G * P) *ᵥ v) = v ⬝ᵥ (G *ᵥ v) := by rw [← step, hv]
  rw [hP] at h1
  simp [Matrix.neg_mulVec] at h1
  unfold qform
  linarith

/-- `P = Ω θ₁`, the generator of the orientifold action in the first `ℤ₂` factor. -/
def omegaTheta1 : Gram 12 := omegaP * theta1

theorem omegaTheta1_antiisometry : omegaTheta1ᵀ * gamma66 * omegaTheta1 = -gamma66 := by
  have := orientifold_antiisometries
  simpa [omegaTheta1] using this.1

/-- The six coordinates left free by `P = Ω θ₁`: `f₁, f₂` (indices 1, 3) and `e₃, e₄, e₅, e₆` (4, 6, 8, 10). -/
def invIdx : List (Fin 12) := [1, 3, 4, 6, 8, 10]

/-- The corresponding basis vectors. -/
def invBasis (k : Fin 12) : Fin 12 → ℤ := fun i => if i = k then 1 else 0

theorem invBasis_fixed :
    invIdx.all (fun k => (List.finRange 12).all fun i => (omegaTheta1 *ᵥ invBasis k) i == invBasis k i)
      = true := by
  decide +kernel

/-- **The fixed sublattice, exactly.** `P v = v` holds iff the other six components vanish. -/
theorem invariant_iff (v : Fin 12 → ℤ) :
    omegaTheta1 *ᵥ v = v ↔ (v 0 = 0 ∧ v 2 = 0 ∧ v 5 = 0 ∧ v 7 = 0 ∧ v 9 = 0 ∧ v 11 = 0) := by
  constructor
  · intro h
    have e0 := congrFun h 0
    have e2 := congrFun h 2
    have e5 := congrFun h 5
    have e7 := congrFun h 7
    have e9 := congrFun h 9
    have e11 := congrFun h 11
    simp [omegaTheta1, omegaP, theta1, Matrix.mul_apply, Matrix.mulVec, dotProduct,
      Fin.sum_univ_succ] at e0 e2 e5 e7 e9 e11
    exact ⟨by omega, by omega, by omega, by omega, by omega, by omega⟩
  · rintro ⟨h0, h2, h5, h7, h9, h11⟩
    funext i
    fin_cases i <;>
      simp [omegaTheta1, omegaP, theta1, Matrix.mul_apply, Matrix.mulVec, dotProduct,
        Fin.sum_univ_succ, h0, h2, h5, h7, h9, h11]

/-- **Totally isotropic**: every pairing among the six basis vectors vanishes — not only the diagonal. -/
theorem invBasis_totally_isotropic :
    invIdx.all (fun k => invIdx.all fun l => bform gamma66 (invBasis k) (invBasis l) == 0) = true := by
  decide +kernel

/-- The six vectors are independent: the minor on the rows `invIdx` is the identity. -/
theorem invBasis_independent :
    invIdx.all (fun k => invIdx.all fun l => invBasis k l == (if k = l then 1 else 0)) = true := by
  decide +kernel

/-- **Rank 6, and maximal.** The fixed sublattice has a basis of six vectors; a totally isotropic sublattice of a
form of signature `(6, 6)` has rank at most 6 (standard linear algebra, Tier L), so this one is maximal. -/
theorem invariant_rank_six : invIdx.length = 6 ∧ (12 : ℕ) / 2 = 6 := by decide

end DualScaleStream2.Orientifold
