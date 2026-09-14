import Specs.Card10

namespace Prove2Me.Specs

def DorfmanBracket (X Y : CourantSection) : CourantSection :=
  { v := X.v * Y.v - Y.v * X.v,
    alpha := 2 * (X.v * Y.alpha) - (Y.v * X.alpha) }

def Card11Statement : Prop :=
  ∀ (X Y : CourantSection),
    (DorfmanBracket X Y).alpha - (CBracket X Y).alpha = X.v * Y.alpha

end Prove2Me.Specs
