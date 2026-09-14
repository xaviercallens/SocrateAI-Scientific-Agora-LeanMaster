import Specs.Card26

namespace Prove2Me.Proofs

theorem card_dft_026_proof : Prove2Me.Specs.Card26Statement := by
  intro phi x
  dsimp [Prove2Me.Specs.TwoDilaton]
  omega

end Prove2Me.Proofs
