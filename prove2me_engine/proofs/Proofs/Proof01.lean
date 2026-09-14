import Specs.Card01

namespace Prove2Me.Proofs

theorem card_dft_001_proof : Prove2Me.Specs.Card01Statement := by
  intro X Y
  dsimp [Prove2Me.Specs.CourantPairing]
  omega

end Prove2Me.Proofs
