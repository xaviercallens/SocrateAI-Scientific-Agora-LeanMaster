namespace Prove2Me.Specs

def Card08Statement : Prop :=
  ∀ (j : Int), (j = 1 ∨ j = -1) →
    (1 + j) * (1 - j) = 0 ∧ (1 + j) * (1 + j) = 2 * (1 + j)

end Prove2Me.Specs
