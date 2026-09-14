import Specs.Card19

namespace Prove2Me.Proofs

theorem card_dft_019_proof : Prove2Me.Specs.Card19Statement := by
  intro R
  dsimp [Prove2Me.Specs.DFTRicciComponents]
  omega

end Prove2Me.Proofs
