namespace Prove2Me.Specs

def Signature (b2_pos b2_neg : Int) : Int :=
  b2_pos - b2_neg

def Card29Statement : Prop :=
  Signature 3 19 = -16

end Prove2Me.Specs
