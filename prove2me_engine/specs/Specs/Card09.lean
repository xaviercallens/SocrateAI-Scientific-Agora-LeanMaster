namespace Prove2Me.Specs

def LieBracket (u v : Int) : Int :=
  u * v - v * u

def Card09Statement : Prop :=
  ∀ (u : Int), LieBracket u u = 0

end Prove2Me.Specs
