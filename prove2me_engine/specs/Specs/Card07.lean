import Specs.Card05

namespace Prove2Me.Specs

def GenEnergy (X : GenVector) : Nat :=
  X.v.natAbs + X.xi.natAbs

def Card07Statement : Prop :=
  ∀ (X : GenVector), (X.v ≠ 0 ∨ X.xi ≠ 0) → GenEnergy X > 0

end Prove2Me.Specs
