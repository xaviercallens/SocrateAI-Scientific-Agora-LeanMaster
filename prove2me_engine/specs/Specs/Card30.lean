namespace Prove2Me.Specs

def SecondBetti (h20 h11 h02 : Int) : Int :=
  h20 + h11 + h02

def Card30Statement : Prop :=
  SecondBetti 1 20 1 = 22

end Prove2Me.Specs
