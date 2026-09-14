import Specs.Card04

namespace Prove2Me.Proofs

theorem card_dft_004_proof : Prove2Me.Specs.Card04Statement := by
  intro b
  dsimp [Prove2Me.Specs.MatMul, Prove2Me.Specs.MatTranspose, Prove2Me.Specs.BTwist, Prove2Me.Specs.ODD_Eta]
  omega

end Prove2Me.Proofs
