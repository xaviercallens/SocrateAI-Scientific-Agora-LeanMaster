namespace Prove2Me.Specs

def ActionLagrangian (density ricci : Int) : Int :=
  density * ricci

def Card20Statement : Prop :=
  ∀ (density R_geom : Int),
    ActionLagrangian density R_geom = ActionLagrangian R_geom density

end Prove2Me.Specs
