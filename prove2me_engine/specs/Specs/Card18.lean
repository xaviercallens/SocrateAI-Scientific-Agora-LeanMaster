namespace Prove2Me.Specs

def DFTRicciComponents (R_geom kin_phi H_sq : Int) : Int :=
  R_geom + 4 * kin_phi - H_sq

def Card18Statement : Prop :=
  ∀ (R_geom kin_phi H_sq : Int),
    DFTRicciComponents R_geom kin_phi H_sq + H_sq = R_geom + 4 * kin_phi

end Prove2Me.Specs
