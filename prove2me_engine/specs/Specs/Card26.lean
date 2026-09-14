namespace Prove2Me.Specs

def TwoDilaton (phi x : Int) : Int :=
  2 * phi - x

def Card26Statement : Prop :=
  ∀ (phi x : Int),
    TwoDilaton (phi - x) (-x) = TwoDilaton phi x

end Prove2Me.Specs
