namespace Prove2Me.Specs

def BuscherLogMap (x : Int) : Int :=
  -x

def Card24Statement : Prop :=
  ∀ (x : Int), BuscherLogMap (BuscherLogMap x) = x

end Prove2Me.Specs
