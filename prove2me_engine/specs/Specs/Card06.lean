import Specs.Card03
import Specs.Card05

namespace Prove2Me.Specs

def Card06Statement : Prop :=
  ∀ (g : Int) (_h : g = 1),
    MatMul (GenMetric g g) (MatMul ODD_Eta (GenMetric g g)) = ODD_Eta

end Prove2Me.Specs
