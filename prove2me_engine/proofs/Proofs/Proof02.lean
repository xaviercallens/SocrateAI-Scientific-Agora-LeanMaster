import Specs.Card02

namespace Prove2Me.Proofs

theorem card_dft_002_proof : Prove2Me.Specs.Card02Statement := by
  intro X Y
  dsimp [Prove2Me.Specs.BilinearForm, Prove2Me.Specs.ODD_Eta, Prove2Me.Specs.CourantPairing]
  have h1 : (0 * Y.v + 1 * Y.xi) = Y.xi := by omega
  have h2 : (1 * Y.v + 0 * Y.xi) = Y.v := by omega
  rw [h1, h2]
  rw [Int.mul_comm X.v Y.xi]
  omega

end Prove2Me.Proofs
