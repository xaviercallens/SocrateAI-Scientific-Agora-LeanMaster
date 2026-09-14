namespace Prove2Me.Specs

structure FieldDeriv where
  dx : Int
  dtx : Int
deriving Repr, DecidableEq

def SectionContract (Phi Psi : FieldDeriv) : Int :=
  Phi.dx * Psi.dtx + Phi.dtx * Psi.dx

def Card14Statement : Prop :=
  ∀ (Phi Psi : FieldDeriv),
    Phi.dtx = 0 → Psi.dtx = 0 → SectionContract Phi Psi = 0

end Prove2Me.Specs
