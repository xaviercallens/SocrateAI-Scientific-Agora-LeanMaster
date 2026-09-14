namespace Prove2Me.Specs

def LieCommutator (Lx Ly : Int → Int) (f : Int) : Int :=
  Lx (Ly f) - Ly (Lx f)

def Card15Statement : Prop :=
  ∀ (a b : Int) (f : Int),
    LieCommutator (fun x => a * x) (fun x => b * x) f = 0

end Prove2Me.Specs
