import Specs.Card01

namespace Prove2Me.Specs

structure Mat2 where
  a : Int
  b : Int
  c : Int
  d : Int
deriving Repr, DecidableEq

def ODD_Eta : Mat2 := { a := 0, b := 1, c := 1, d := 0 }

def BilinearForm (M : Mat2) (X Y : GenVector) : Int :=
  X.v * (M.a * Y.v + M.b * Y.xi) + X.xi * (M.c * Y.v + M.d * Y.xi)

def Card02Statement : Prop :=
  ∀ (X Y : GenVector), BilinearForm ODD_Eta X Y = CourantPairing X Y

end Prove2Me.Specs
