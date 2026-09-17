import DualScaleStream2
import StringTheoryFormalization

/-! Downstream use of LeanMaster: new results proved from its theorems. -/
open Matrix DualScaleStream2

/-- Two successive integer B-shifts are again an O(d,d;ℤ) element (uses `isODD_mul`). -/
example {d : ℕ} (Θ₁ Θ₂ : Matrix (Fin d) (Fin d) ℤ) (h₁ : Θ₁ᵀ = -Θ₁) (h₂ : Θ₂ᵀ = -Θ₂) :
    TDuality.IsODD (TDuality.thetaShift Θ₁ * TDuality.thetaShift Θ₂) :=
  TDuality.isODD_mul _ _ (TDuality.thetaShift_isODD Θ₁ h₁) (TDuality.thetaShift_isODD Θ₂ h₂)

#check @DualScale.dualScale_ge
#check @DFT.genMetric_bshift
#check @TDuality.spectrum_equivalence
#check @Lattice.cartanE8_posDef
#print axioms DualScale.dualScale_ge

/-- Downstream theorem, audited with the LeanMaster gate tools. -/
theorem two_shifts_isODD {d : ℕ} (Θ₁ Θ₂ : Matrix (Fin d) (Fin d) ℤ) (h₁ : Θ₁ᵀ = -Θ₁) (h₂ : Θ₂ᵀ = -Θ₂) :
    TDuality.IsODD (TDuality.thetaShift Θ₁ * TDuality.thetaShift Θ₂) :=
  TDuality.isODD_mul _ _ (TDuality.thetaShift_isODD Θ₁ h₁) (TDuality.thetaShift_isODD Θ₂ h₂)
