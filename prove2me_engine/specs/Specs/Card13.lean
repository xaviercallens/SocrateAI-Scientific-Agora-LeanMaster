import Specs.Card10

namespace Prove2Me.Specs

def JacVector (X Y Z : CourantSection) : Int :=
  ((CBracket (CBracket X Y) Z).v) +
  ((CBracket (CBracket Y Z) X).v) +
  ((CBracket (CBracket Z X) Y).v)

def Card13Statement : Prop :=
  ∀ (X Y Z : CourantSection), JacVector X Y Z = 0

end Prove2Me.Specs
