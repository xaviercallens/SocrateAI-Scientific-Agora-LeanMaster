import Specs.Card07

namespace Prove2Me.Proofs

theorem card_dft_007_proof : Prove2Me.Specs.Card07Statement := by
  intro X h
  dsimp [Prove2Me.Specs.GenEnergy]
  rcases h with hv | hxi
  · have : X.v.natAbs > 0 := by omega
    omega
  · have : X.xi.natAbs > 0 := by omega
    omega

end Prove2Me.Proofs
