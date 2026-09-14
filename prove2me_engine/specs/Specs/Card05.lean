import Specs.Card02

namespace Prove2Me.Specs

def GenMetric (g : Int) (ginv : Int) : Mat2 :=
  { a := g, b := 0, c := 0, d := ginv }

def Card05Statement : Prop :=
  ∀ (g ginv : Int), (GenMetric g ginv).b = (GenMetric g ginv).c

end Prove2Me.Specs
