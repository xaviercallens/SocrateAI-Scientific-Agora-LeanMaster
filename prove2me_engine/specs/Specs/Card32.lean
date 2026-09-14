namespace Prove2Me.Specs

def HolonomyDimSO4 : Nat := 6
def HolonomyDimSU2 : Nat := 3

def Card32Statement : Prop :=
  HolonomyDimSU2 < HolonomyDimSO4 ∧ HolonomyDimSO4 - HolonomyDimSU2 = 3

end Prove2Me.Specs
