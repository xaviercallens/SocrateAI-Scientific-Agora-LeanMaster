import Specs.Card25

namespace Prove2Me.Proofs

theorem card_dft_025_proof : Prove2Me.Specs.Card25Statement := by
  intro phi x
  dsimp [Prove2Me.Specs.BuscherDilatonMap, Prove2Me.Specs.BuscherLogMap]
  omega

end Prove2Me.Proofs
