namespace Prove2Me.Specs

structure GenVector where
  v : Int
  xi : Int
deriving Repr, DecidableEq

def CourantPairing (X Y : GenVector) : Int :=
  X.xi * Y.v + Y.xi * X.v

def Card01Statement : Prop :=
  ∀ (X Y : GenVector), CourantPairing X Y = CourantPairing Y X

end Prove2Me.Specs
