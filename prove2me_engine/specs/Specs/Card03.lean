import Specs.Card02

namespace Prove2Me.Specs

def MatMul (M N : Mat2) : Mat2 :=
  { a := M.a * N.a + M.b * N.c, b := M.a * N.b + M.b * N.d,
    c := M.c * N.a + M.d * N.c, d := M.c * N.b + M.d * N.d }

def MatTranspose (M : Mat2) : Mat2 :=
  { a := M.a, b := M.c, c := M.b, d := M.d }

def IsODD (M : Mat2) : Prop :=
  MatMul (MatTranspose M) (MatMul ODD_Eta M) = ODD_Eta

def InversionGen : Mat2 := { a := 0, b := 1, c := 1, d := 0 }

def Card03Statement : Prop :=
  IsODD InversionGen

end Prove2Me.Specs
