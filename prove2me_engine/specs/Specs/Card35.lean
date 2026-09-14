import Specs.Card03

namespace Prove2Me.Specs

def ModS : Mat2 := { a := 0, b := -1, c := 1, d := 0 }
def ModT : Mat2 := { a := 1, b := 1, c := 0, d := 1 }
def NegI : Mat2 := { a := -1, b := 0, c := 0, d := -1 }

def Card35Statement : Prop :=
  MatMul ModS ModS = NegI ∧
  MatMul (MatMul ModS ModT) (MatMul (MatMul ModS ModT) (MatMul ModS ModT)) = NegI

end Prove2Me.Specs
