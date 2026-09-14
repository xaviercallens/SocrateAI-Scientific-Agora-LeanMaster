import Specs.Card16

namespace Prove2Me.Proofs

theorem card_dft_016_proof : Prove2Me.Specs.Card16Statement := by
  intro s e
  dsimp [Prove2Me.Specs.DilatonMeasure]
  rw [Int.mul_comm]

end Prove2Me.Proofs
