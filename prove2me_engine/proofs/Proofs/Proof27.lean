import Specs.Card27

namespace Prove2Me.Proofs

theorem card_dft_027_proof : Prove2Me.Specs.Card27Statement := by
  intro x hx
  dsimp [Prove2Me.Specs.BuscherLogMap] at hx
  omega

end Prove2Me.Proofs
