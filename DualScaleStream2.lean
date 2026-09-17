-- Stream 2 root: Dual-Scale string theory on K3 × T² — lattice and T-duality layer.
-- Separate `lean_lib` from Stream 1 (`StringTheoryFormalization`) by design; imports it,
-- never the reverse.

import DualScaleStream2.Lattice.Basic
import DualScaleStream2.Lattice.E8
import DualScaleStream2.Lattice.Hyperbolic
import DualScaleStream2.Lattice.K3T2Signature
import DualScaleStream2.Lattice.E8PosDef
import DualScaleStream2.Lattice.Mukai
import DualScaleStream2.TDuality.ODD
import DualScaleStream2.TDuality.Factorized
import DualScaleStream2.DFT.GeneralizedMetric
import DualScaleStream2.DualScale.TraceBound
import DualScaleStream2.Flux.Tadpole
import DualScaleStream2.Moonshine.EOT
