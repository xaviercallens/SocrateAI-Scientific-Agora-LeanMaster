import Specs.Card15

namespace Prove2Me.Proofs

theorem card_dft_015_proof : Prove2Me.Specs.Card15Statement := by
  intro a b f
  dsimp [Prove2Me.Specs.LieCommutator]
  rw [← Int.mul_assoc, ← Int.mul_assoc]
  rw [Int.mul_comm a b]
  omega

end Prove2Me.Proofs
