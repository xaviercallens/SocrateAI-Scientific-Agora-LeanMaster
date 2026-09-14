namespace Prove2Me.Specs

def K3BettiSum (b0 b1 b2 b3 b4 : Int) : Int :=
  b0 - b1 + b2 - b3 + b4

def Card28Statement : Prop :=
  K3BettiSum 1 0 22 0 1 = 24

end Prove2Me.Specs
