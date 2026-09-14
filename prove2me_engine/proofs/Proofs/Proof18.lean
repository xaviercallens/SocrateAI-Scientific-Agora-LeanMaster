import Specs.Card18

namespace Prove2Me.Proofs

theorem card_dft_018_proof : Prove2Me.Specs.Card18Statement := by
  intro R k H
  dsimp [Prove2Me.Specs.DFTRicciComponents]
  omega

end Prove2Me.Proofs
