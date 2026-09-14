namespace Prove2Me.Specs

def ContractedEinstein (D R : Int) : Int :=
  (D - 2) * R

def Card21Statement : Prop :=
  ∀ (R : Int), ContractedEinstein 2 R = 0

end Prove2Me.Specs
