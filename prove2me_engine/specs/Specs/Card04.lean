import Specs.Card03

namespace Prove2Me.Specs

def BTwist (b : Int) : Mat2 :=
  { a := 1, b := 0, c := b, d := 1 }

def Card04Statement : Prop :=
  ∀ (b : Int), (MatMul (MatTranspose (BTwist b)) (MatMul ODD_Eta (BTwist b))).b = ODD_Eta.b ∧
               (MatMul (MatTranspose (BTwist b)) (MatMul ODD_Eta (BTwist b))).c = ODD_Eta.c

end Prove2Me.Specs
