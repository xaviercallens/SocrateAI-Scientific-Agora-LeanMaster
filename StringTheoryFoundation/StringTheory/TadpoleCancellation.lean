/-
Copyright (c) 2026 SocrateAI Contributors. All rights reserved.
Released under MIT license.
Authors: SocrateAI Team & Scientific Agora Swarm

## Scientific References (pinned in `papers/foundations/`)
- Sen, A. *F-theory and Orientifolds*, Nucl. Phys. B 475 (1996) 562, hep-th/9605150
  (`hep-th_9605150.txt`, ll. 238–250): type IIB on `T²/(−1)^{F_L}·Ω·I₂`: "each of the four orientifold
  planes carry −4 units of seven-brane charge, which need to be neutralized by putting sixteen seven
  branes"; with four D7-branes on each plane the cancellation is local (`SO(8)⁴`).
- Tripathy, P. K.; Trivedi, S. P. *Compactification with flux on K3 and tori*, JHEP 03 (2003) 028,
  hep-th/0301139 (`hep-th_0301139.txt`): §2.2, ll. 160–163 — in `K3 × T²/ℤ₂` the orientifold has 4 fixed
  points on the `T²`, one O7-plane at each, cancelled by 16 D7-branes; ll. 164–171 — O7-planes and
  D7-branes wrap the K3, inducing 2 units of D3 charge per O7 and 1 per D7, 24 in total, eq. (2.3)
  `½ N_flux + N_D3 = 24`.
- Dasgupta, K.; Rajesh, G.; Sethi, S. *M theory, orientifolds and G-flux*, hep-th/9908088
  (`dasgupta_rajesh_sethi_hep-th_9908088.txt`, l. 640): for the dual M-theory/F-theory fourfold
  `K3 × K3`, the anomaly is `χ/24 = 24`.
- Polchinski, *TASI lectures on D-branes*, hep-th/9611050 (Lecture 3, eq. (93), `polchinski_tasi_dbranes_hep-th_9611050.txt` ll. 1968–1984): an O`p`-plane carries
  `−2^{p−5}` times the D`p` charge, and there are `2^{9−p}` of them, total `−16`.

## Correction (2026-09-18, `v3.21.0`)
An earlier revision placed **16 O7⁻ planes at the fixed points of `T⁴/ℤ₂`** with 32 D7-branes of
charge `+2`, and stated the D3 target as `χ(K3)/24 = 1`. Both were wrong: in the IIB orientifold on
`K3 × T²/ℤ₂` the orientifold acts on the `T²`, whose reflection has 4 fixed points, and the 16 fixed
points of `T⁴/ℤ₂` belong to the orbifold (Kummer) limit of the K3 factor, where no O7-plane sits (in
the T-dual type I description of Gimon–Polchinski, hep-th/9601038, they carry O5-planes, with
`n₅ = 32`, eq. (4.1), `hep-th_9601038.txt` ll. 842–848). Plane-to-brane charge ratio `−2` of the old
numbers matched no `p`. The D3 target is `χ(K3 × K3)/24 = 24`, not `χ(K3)/24`; `χ(K3)/24 = 1` is the D3
charge induced on one D7-brane wrapped on K3. The correction was prompted by a literature check from
the DualScaleSimulator project and verified against the sources above. Every statement below is
integer arithmetic (Tier A); its physical reading is Tier L.
-/

namespace StringTheory.Foundation.StringTheory.TadpoleCancellation

/-- Fixed points of `x ↦ −x` on `T⁴`: `2⁴ = 16`. These are the 16 nodes of the orbifold `T⁴/ℤ₂`, the
    Kummer limit of the K3 factor — **not** the positions of orientifold planes. -/
def numFixedPointsT4Z2 : Nat := 16

/-- `2⁴ = 16` fixed points of `T⁴/ℤ₂` (the same fact as
    `StringTheoryFoundation.ModularForms.FermatModularBridge.kummer_fixed_points_dim4`). -/
theorem num_fixed_points_is_16 : (2 : Nat) ^ 4 = numFixedPointsT4Z2 := by
  rfl

/-- O7-planes of `K3 × T²/ℤ₂`: one at each of the `2² = 4` fixed points of the reflection of `T²`
    (TT ll. 160–163; Sen l. 242). -/
def numO7Planes : Nat := 4

theorem num_O7_planes_is_4 : (2 : Nat) ^ 2 = numO7Planes := by
  rfl

/-- Seven-brane (`C₈`) charge of one O7⁻ plane, in units of the D7 charge: `−4` (Sen l. 242). -/
def chargeO7Minus : Int := -4

/-- Total O7 charge: `4 · (−4) = −16`. -/
def totalO7Charge : Int := (numO7Planes : Int) * chargeO7Minus

theorem total_O7_charge_is_minus_16 : totalO7Charge = -16 := by
  rfl

/-- 16 D7-branes (TT ll. 162–163; Sen l. 243), each of charge `+1`. -/
def numD7Branes : Nat := 16
def chargeD7Brane : Int := 1

def totalD7Charge : Int := (numD7Branes : Int) * chargeD7Brane

theorem total_D7_charge_is_16 : totalD7Charge = 16 := by
  rfl

/-- Seven-brane tadpole: `16 · (+1) + 4 · (−4) = 0`. Gauss's law on the compact `T²/ℤ₂` requiring this
    is Tier L. -/
theorem d7_tadpole_cancellation :
    totalD7Charge + totalO7Charge = 0 := by
  rfl

/-- The convention-independent invariant: plane charge `= −2^{7−5} = −4` times brane charge. -/
theorem plane_brane_ratio : chargeO7Minus = -(2 ^ (7 - 5) : Int) * chargeD7Brane := by
  rfl

/-- Local cancellation at the `SO(8)⁴` point: four D7-branes on each O7-plane (Sen ll. 249–250;
    TT l. 313). -/
theorem local_cancellation :
    chargeO7Minus + 4 * chargeD7Brane = 0 ∧ 4 * numO7Planes = numD7Branes := by
  decide

/-- Polchinski's table in units of `μ_p / 4` (so that all charges are integers for `3 ≤ p ≤ 9`):
    `2^{9−p}` O`p`-planes of charge `−2^{p−3}` each. -/
def planes (p : Nat) : Nat := 2 ^ (9 - p)
def planeCharge (p : Nat) : Int := -(2 ^ (p - 3) : Int)

/-- For every `p` from 3 to 9 the planes carry `−16 μ_p` (`−64` quarter units), cancelled by 16
    D`p`-branes; at `p = 7` this is `d7_tadpole_cancellation` with all charges multiplied by 4. -/
theorem oplane_total_independent :
    ∀ k < 7, (planes (k + 3) : Int) * planeCharge (k + 3) + 16 * 4 = 0 := by
  decide

theorem oplane_p7 :
    planes 7 = numO7Planes ∧ planeCharge 7 = 4 * chargeO7Minus := by
  decide

/-- `χ(K3) = 24`. -/
def k3EulerChar : Int := 24

/-- D3 charge induced on one D7-brane wrapped on K3: `χ(K3)/24 = 1` (TT ll. 165–167; GKP l. 463 gives `−1` in its sign convention). -/
def d3ChargePerD7 : Int := k3EulerChar / 24

theorem d3_charge_per_D7_is_one : d3ChargePerD7 = 1 := by
  rfl

/-- D3 charge induced on one O7-plane wrapped on K3: 2 (TT ll. 165–167; Tier L input). -/
def d3ChargePerO7 : Int := 2

/-- The D3 tadpole: `N_D3 + ½ N_flux = χ(K3 × K3)/24 = 24² / 24 = 24` (TT (2.3), l. 171; DRS l. 640). -/
def d3TadpoleTarget : Int := k3EulerChar * k3EulerChar / 24

theorem d3_tadpole_target_is_24 : d3TadpoleTarget = 24 := by
  rfl

/-- Two routes to the same 24: the seven-branes' induced D3 charge in the IIB orientifold,
    `4 · 2 + 16 · 1` (TT), equals the Euler-number budget `χ(K3 × K3)/24` of the dual fourfold (DRS). -/
theorem induced_d3_charge_matches_target :
    (numO7Planes : Int) * d3ChargePerO7 + (numD7Branes : Int) * d3ChargePerD7 = d3TadpoleTarget := by
  rfl

end StringTheory.Foundation.StringTheory.TadpoleCancellation
