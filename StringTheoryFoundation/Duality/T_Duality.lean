/-
Copyright (c) 2026 SocrateAI Contributors. All rights reserved.
Released under MIT license.
Authors: SocrateAI Team & Scientific Agora Swarm

## Scientific References
- [GPR1994] Giveon, A.; Porrati, M.; Rabinovici, E.
  Target Space Duality in String Theory. arXiv: hep-th/9401139.
  T-duality on circle states exchanging KK momentum n and winding w.
-/

namespace StringTheory.Foundation.Duality.T_Duality

/-- String compactification state on a circle with radius R:
    - `n`: Kaluza-Klein momentum excitation integer
    - `w`: topological string winding number -/
structure CircleState where
  n : Int
  w : Int
  deriving Repr, DecidableEq

/-- T-duality transformation on string states:
    Exchanges momentum and winding numbers: (n, w) ↦ (w, n). -/
def tDualState (s : CircleState) : CircleState :=
  { n := s.w, w := s.n }

/-- Theorem: T-duality on state quantum numbers is an involution:
    (T ∘ T)(s) = s. -/
theorem t_duality_involution (s : CircleState) :
    tDualState (tDualState s) = s := by
  dsimp [tDualState]

/-- String mass spectrum factor (n² + w²) at the self-dual radius R = √α'. -/
def selfDualMassFactor (n w : Int) : Int :=
  n * n + w * w

/-- Theorem: The self-dual mass factor is strictly invariant under n ↔ w exchange:
    (n² + w²) = (w² + n²). -/
theorem self_dual_mass_symmetry (n w : Int) :
    selfDualMassFactor n w = selfDualMassFactor w n := by
  dsimp [selfDualMassFactor]
  omega

/-- General T-duality invariant relation:
    Swapping (n, w) preserves the quadratic sum. -/
theorem t_duality_spectrum_invariance (n w : Int) :
    n * n + w * w = w * w + n * n := by
  omega

end StringTheory.Foundation.Duality.T_Duality
