import Specs.Card11

namespace Prove2Me.Specs

def Card12Statement : Prop :=
  ∀ (X Y : CourantSection),
    (DorfmanBracket X Y).alpha + (DorfmanBracket Y X).alpha =
    (X.v * Y.alpha + Y.v * X.alpha)

end Prove2Me.Specs
