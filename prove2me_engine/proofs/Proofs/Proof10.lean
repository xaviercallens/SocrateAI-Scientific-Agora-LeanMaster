import Specs.Card10

namespace Prove2Me.Proofs

theorem card_dft_010_proof : Prove2Me.Specs.Card10Statement := by
  intro X Y
  dsimp [Prove2Me.Specs.CBracket]
  omega

end Prove2Me.Proofs
