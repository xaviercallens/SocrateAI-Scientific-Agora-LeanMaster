import Specs.Card33

namespace Prove2Me.Specs

def ChiralIndex (ker_plus ker_minus : Int) : Int :=
  ker_plus - ker_minus

def Card34Statement : Prop :=
  ChiralIndex 2 0 = DiracIndex (-16)

end Prove2Me.Specs
