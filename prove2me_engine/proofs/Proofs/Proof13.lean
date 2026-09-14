import Specs.Card10
import Specs.Card13

namespace Prove2Me.Proofs

theorem cbracket_v_zero (X Y : Prove2Me.Specs.CourantSection) : (Prove2Me.Specs.CBracket X Y).v = 0 := by
  dsimp [Prove2Me.Specs.CBracket]
  rw [Int.mul_comm X.v Y.v]
  omega

theorem card_dft_013_proof : Prove2Me.Specs.Card13Statement := by
  intro X Y Z
  dsimp [Prove2Me.Specs.JacVector]
  rw [cbracket_v_zero (Prove2Me.Specs.CBracket X Y) Z]
  rw [cbracket_v_zero (Prove2Me.Specs.CBracket Y Z) X]
  rw [cbracket_v_zero (Prove2Me.Specs.CBracket Z X) Y]
  omega

end Prove2Me.Proofs
