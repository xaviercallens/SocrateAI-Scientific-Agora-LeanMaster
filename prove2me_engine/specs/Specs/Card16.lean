namespace Prove2Me.Specs

def DilatonMeasure (sqrt_g e_minus_2phi : Int) : Int :=
  sqrt_g * e_minus_2phi

def Card16Statement : Prop :=
  ∀ (sqrt_g e_minus_2phi : Int),
    DilatonMeasure sqrt_g e_minus_2phi = DilatonMeasure e_minus_2phi sqrt_g

end Prove2Me.Specs
