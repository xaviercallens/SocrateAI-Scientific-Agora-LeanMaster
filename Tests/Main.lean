-- Test suite for the StringTheoryFormalization project
-- Runs all verified blocks and checks no regressions.
import StringTheoryFormalization.Foundations.MathlibCore
import StringTheoryFormalization.NSMath.FractionalSobolev
import StringTheoryFormalization.NSMath.OpenAIBridging
import StringTheoryFormalization.StringDynamics.KummerBlowup
import StringTheoryFormalization.StringDynamics.TadpoleConstraint
import StringTheoryFormalization.StringDynamics.MathieuM24
import StringTheoryFormalization.StringDynamics.BPSMultiplicities
import StringTheoryFormalization.StringDynamics.MukaiLattice
import StringTheoryFormalization.StringDynamics.TDualityGysin
import StringTheoryFormalization.StringDynamics.AutoEvolve
import StringTheoryFormalization.Frontier.CentralCharge
import StringTheoryFormalization.Frontier.ChiralPrimaries
import StringTheoryFormalization.Frontier.SL2CSymmetry
import StringTheoryFormalization.Frontier.HodgeNumbers
import StringTheoryFormalization.Pipeline.DAGOrchestrator
import StringTheoryFoundation

namespace StringTheory.Tests

-- ── Verified Block Smoke Tests ────────────────────────────────────────────

#check StringTheory.NSMath.SobolevExponent
#check StringTheory.NSMath.OpenAIBridging.swap_torus_involution
#check StringTheory.NSMath.OpenAIBridging.is_rapid_summable
#check StringTheory.StringDynamics.kummerIntersectionForm
#check StringTheory.StringDynamics.tadpole_cancellation
#check StringTheory.StringDynamics.M24_order
#check StringTheory.StringDynamics.bpsRatio
#check StringTheory.StringDynamics.mukai_rank
#check StringTheory.StringDynamics.tDualityAction

-- ── Foundation Library Smoke Tests ────────────────────────────────────────

#check StringTheory.Foundation.Core.Topology.euler_char_K3
#check StringTheory.Foundation.Core.Topology.euler_char_T2
#check StringTheory.Foundation.Duality.DualScale.dual_pair_symmetric
#check StringTheory.Foundation.Duality.T_Duality.t_duality_involution
#check StringTheory.Foundation.K3.K3Surfaces.k3_b2_is_22
#check StringTheory.Foundation.StringTheory.K3xT2.dim_real_k3xt2_is_6
#check StringTheory.Foundation.StringTheory.TadpoleCancellation.d7_tadpole_cancellation
#check StringTheory.Foundation.StringTheory.Swampland.distance_conjecture_monotonicity

-- ── Arithmetic Spot Checks ───────────────────────────────────────────────

example : StringTheory.StringDynamics.kummerIntersectionForm 0 0 = -2 := by
  simp [StringTheory.StringDynamics.kummerIntersectionForm]

example : StringTheory.StringDynamics.bpsRatio = 77/60 := by
  native_decide

example : StringTheory.StringDynamics.M24_order = True.intro.elim id := by
  trivial

-- ── Frontier Block Smoke Tests ────────────────────────────────────────────

#check StringTheory.Frontier.centralChargeK3
#check StringTheory.Frontier.K3ChiralPrimaryCount
#check StringTheory.Frontier.mobiusId
#check StringTheory.Frontier.k3HodgeNumber

example : StringTheory.Frontier.centralChargeK3 = 6 :=
  StringTheory.Frontier.central_charge_k3_eq_six

example : StringTheory.Frontier.k3HodgeNumber ⟨1, by norm_num⟩ ⟨1, by norm_num⟩ = 20 := by
  simp [StringTheory.Frontier.k3HodgeNumber]

example : StringTheory.Frontier.K3ChiralPrimaryCount ⟨1, by norm_num⟩ = 0 := by
  simp [StringTheory.Frontier.K3ChiralPrimaryCount]

-- ── DAG Integrity Check ───────────────────────────────────────────────────

#eval StringTheory.Pipeline.progressSummary
#eval StringTheory.Pipeline.totalSorryCount
#eval StringTheory.Pipeline.verifiedBlockCount

example : StringTheory.Pipeline.formalizationDAG.length = 29 := by native_decide

end StringTheory.Tests
