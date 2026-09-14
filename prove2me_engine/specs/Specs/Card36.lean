import Specs.Card28
import Specs.Card31

namespace Prove2Me.Specs

def MukaiRank (b0 b2 b4 : Int) : Int :=
  b0 + b2 + b4

def MathieuDegree : Int := 24

def Card36Statement : Prop :=
  MukaiRank 1 22 1 = MathieuDegree ∧
  LatticeRank 2 4 = MathieuDegree

end Prove2Me.Specs
