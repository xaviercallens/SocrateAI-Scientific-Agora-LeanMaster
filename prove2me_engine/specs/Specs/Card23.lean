import Specs.Card03

namespace Prove2Me.Specs

def Det2 (M : Mat2) : Int :=
  M.a * M.d - M.b * M.c

def Identity2 : Mat2 := { a := 1, b := 0, c := 0, d := 1 }

def Card23Statement : Prop :=
  MatMul InversionGen InversionGen = Identity2 ∧ Det2 InversionGen = -1

end Prove2Me.Specs
