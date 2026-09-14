import Specs.Card14

namespace Prove2Me.Proofs

theorem card_dft_014_proof : Prove2Me.Specs.Card14Statement := by
  intro Phi Psi hPhi hPsi
  dsimp [Prove2Me.Specs.SectionContract]
  rw [hPhi, hPsi]
  omega

end Prove2Me.Proofs
