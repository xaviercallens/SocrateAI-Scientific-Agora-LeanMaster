import Specs.Card24

namespace Prove2Me.Specs

def BuscherDilatonMap (phi x : Int) : Int :=
  phi - x

def Card25Statement : Prop :=
  ∀ (phi x : Int),
    BuscherDilatonMap (BuscherDilatonMap phi x) (BuscherLogMap x) = phi

end Prove2Me.Specs
