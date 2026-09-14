import Specs.Card12

namespace Prove2Me.Proofs

theorem card_dft_012_proof : Prove2Me.Specs.Card12Statement := by
  intro X Y
  dsimp [Prove2Me.Specs.DorfmanBracket]
  omega

end Prove2Me.Proofs
