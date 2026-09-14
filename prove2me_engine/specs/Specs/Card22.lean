import Specs.Card03
import Specs.Card05

namespace Prove2Me.Specs

def CongruenceAction (M H : Mat2) : Mat2 :=
  MatMul (MatTranspose M) (MatMul H M)

def Card22Statement : Prop :=
  ∀ (H : Mat2) (_hH : H = GenMetric 1 1),
    CongruenceAction InversionGen H = GenMetric 1 1

end Prove2Me.Specs
