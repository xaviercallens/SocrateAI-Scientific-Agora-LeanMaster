import Specs.Card08

namespace Prove2Me.Proofs

theorem card_dft_008_proof : Prove2Me.Specs.Card08Statement := by
  intro j hj
  rcases hj with rfl | rfl
  · decide
  · decide

end Prove2Me.Proofs
