import Specs.Card24

namespace Prove2Me.Proofs

theorem card_dft_024_proof : Prove2Me.Specs.Card24Statement := by
  intro x
  dsimp [Prove2Me.Specs.BuscherLogMap]
  omega

end Prove2Me.Proofs
