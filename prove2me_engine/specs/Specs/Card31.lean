namespace Prove2Me.Specs

def LatticeRank (n_e8 n_u : Int) : Int :=
  n_e8 * 8 + n_u * 2

def LatticeSig (n_e8 n_u : Int) : Int :=
  n_e8 * (-8) + n_u * 0

def Card31Statement : Prop :=
  LatticeRank 2 3 = 22 ∧ LatticeSig 2 3 = -16

end Prove2Me.Specs
