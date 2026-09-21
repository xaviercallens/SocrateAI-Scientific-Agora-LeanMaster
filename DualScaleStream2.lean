-- Stream 2 root: Dual-Scale string theory on K3 × T² — lattice and T-duality layer.
-- Separate `lean_lib` from Stream 1 (`StringTheoryFormalization`) by design; imports it,
-- never the reverse.

import DualScaleStream2.Lattice.Basic
import DualScaleStream2.Lattice.E8
import DualScaleStream2.Lattice.E8PosDef
import DualScaleStream2.Lattice.Hyperbolic
import DualScaleStream2.Lattice.K3T2Signature
import DualScaleStream2.Lattice.Mukai
import DualScaleStream2.Lattice.Reflection
import DualScaleStream2.TDuality.ODD
import DualScaleStream2.TDuality.Factorized
import DualScaleStream2.TDuality.Spectrum
import DualScaleStream2.TDuality.Mirror
import DualScaleStream2.TDuality.SL2Product
import DualScaleStream2.DFT.GeneralizedMetric
import DualScaleStream2.DFT.BShift
import DualScaleStream2.DFT.SectionCondition
import DualScaleStream2.DualScale.TraceBound
import DualScaleStream2.Flux.Tadpole
import DualScaleStream2.Flux.Integrality
import DualScaleStream2.Moonshine.EOT
import DualScaleStream2.Orientifold.NarainT6
import DualScaleStream2.Orientifold.InvariantSublattice
import DualScaleStream2.Orientifold.Crystallography
import DualScaleStream2.Flux.T6TadpoleFiniteness
import DualScaleStream2.Flux.FluxLattice
import DualScaleStream2.Flux.InvariantH3
import DualScaleStream2.Flux.FluxQuantisation
import DualScaleStream2.Orientifold.CrystallographicOrders
import DualScaleStream2.Orientifold.CrystallographicArithmetic
import DualScaleStream2.Flux.ISDFiniteness
