import Specs.Card09

namespace Prove2Me.Proofs

theorem card_dft_009_proof : Prove2Me.Specs.Card09Statement := by
  intro u
  dsimp [Prove2Me.Specs.LieBracket]
  omega

end Prove2Me.Proofs
