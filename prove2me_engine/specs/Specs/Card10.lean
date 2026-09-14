namespace Prove2Me.Specs

structure CourantSection where
  v : Int
  alpha : Int
deriving Repr, DecidableEq

def CBracket (X Y : CourantSection) : CourantSection :=
  { v := X.v * Y.v - Y.v * X.v,
    alpha := X.v * Y.alpha - Y.v * X.alpha }

def Card10Statement : Prop :=
  ∀ (X Y : CourantSection),
    (CBracket X Y).alpha = - ((CBracket Y X).alpha)

end Prove2Me.Specs
