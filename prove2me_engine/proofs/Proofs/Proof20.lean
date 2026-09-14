import Specs.Card20

namespace Prove2Me.Proofs

theorem card_dft_020_proof : Prove2Me.Specs.Card20Statement := by
  intro d R
  dsimp [Prove2Me.Specs.ActionLagrangian]
  rw [Int.mul_comm]

end Prove2Me.Proofs
