namespace Prove2Me.Specs

def DiracIndex (sig : Int) : Int :=
  (-sig) / 8

def Card33Statement : Prop :=
  DiracIndex (-16) = 2

end Prove2Me.Specs
