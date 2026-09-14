import Specs.Card21

namespace Prove2Me.Proofs

theorem card_dft_021_proof : Prove2Me.Specs.Card21Statement := by
  intro R
  dsimp [Prove2Me.Specs.ContractedEinstein]
  omega

end Prove2Me.Proofs
