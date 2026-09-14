import Specs.Card11

namespace Prove2Me.Proofs

theorem card_dft_011_proof : Prove2Me.Specs.Card11Statement := by
  intro X Y
  dsimp [Prove2Me.Specs.DorfmanBracket, Prove2Me.Specs.CBracket]
  omega

end Prove2Me.Proofs
