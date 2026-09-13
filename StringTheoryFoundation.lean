/-
StringTheoryFoundation.lean
===========================
Root module for the independent String Theory Foundation Formalization library.
Part of the SocrateAI Scientific Agora Swarm.

Re-exports verified foundation modules:
- Core: Topology, Betti numbers, Euler characteristics.
- Duality: Dual-scale crossover, T-duality involution, mass spectrum symmetry.
- K3: K3 surface Hodge diamond, second Betti number, signature -16.
- StringTheory: K3 × T² 6D compactification, N=4 supersymmetry, Tadpole cancellation, Swampland bounds.
- NSMath: Formal bridging to OpenAI Navier-Stokes & Euler.
-/

import StringTheoryFoundation.Core.Topology
import StringTheoryFoundation.Duality.DualScale
import StringTheoryFoundation.Duality.T_Duality
import StringTheoryFoundation.K3.K3Surfaces
import StringTheoryFoundation.StringTheory.K3xT2
import StringTheoryFoundation.StringTheory.TadpoleCancellation
import StringTheoryFoundation.StringTheory.Swampland
import StringTheoryFormalization.NSMath.OpenAIBridging
