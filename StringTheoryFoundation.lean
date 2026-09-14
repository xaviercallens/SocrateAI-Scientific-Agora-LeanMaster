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
- Atlas: Differential geometry & 4-manifold invariants (Meta AI AutoformBot).
- FluidDynamics: OpenAI continuous Navier-Stokes torus Sobolev & mild PDE bridge.
- ModularForms: Anthropic & Callens Fermat modular forms, Kummer blowup, Mukai lattice Γ^{4,20}.
- PhysLib: Lean Community spacetime kinematics & Lorentz signature.
- Quantum: Oxford TNLean & LeanQuantum holographic tensor network error correction.
- StatisticalLearning: Rademacher complexity & PAC generalization bounds.
-/

import StringTheoryFoundation.Core.Topology
import StringTheoryFoundation.Duality.DualScale
import StringTheoryFoundation.Duality.T_Duality
import StringTheoryFoundation.K3.K3Surfaces
import StringTheoryFoundation.StringTheory.K3xT2
import StringTheoryFoundation.StringTheory.TadpoleCancellation
import StringTheoryFoundation.StringTheory.Swampland
import StringTheoryFoundation.StringTheory.WittenDuality
import StringTheoryFoundation.StringTheory.VafaSwampland
import StringTheoryFoundation.StringTheory.StromingerSYZ
import StringTheoryFoundation.Atlas.AtlasGeometryBridge
import StringTheoryFoundation.FluidDynamics.NavierStokesBridge
import StringTheoryFoundation.ModularForms.FermatModularBridge
import StringTheoryFoundation.PhysLib.PhysLibKinematicsBridge
import StringTheoryFoundation.Quantum.TensorNetworkBridge
import StringTheoryFoundation.StatisticalLearning.StatisticalLearningBridge
