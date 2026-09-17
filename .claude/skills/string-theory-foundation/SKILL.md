---
name: string-theory-foundation
description: Use when a project or paper wants to rely on, import, cite or extend the kernel-verified string-theory mathematics in LeanMaster — T-duality O(d,d;Z), Narain/hyperbolic lattices, E8, K3 and Mukai lattices, the double-field-theory generalized metric, the dual-scale bound tr G + tr G^-1 >= 2d, flux tadpole arithmetic, Mathieu-moonshine dimension facts. Gives the verified status, the exact entry points, the scope limits, and how to cite.
---

# Building on the verified string-theory foundation

**Confirmation (2026-09-17, release `v2.1.0`)**: 425 theorems across 7 libraries, 0 `sorry`, every theorem
depends only on `propext`, `Classical.choice`, `Quot.sound`; statements locked; a separate downstream
Lake project imports the libraries and proves new results (`examples/consumer_demo/`). Full certificate
with 55 key statements printed verbatim by Lean: `docs/VERIFIED_FOUNDATION.md`. Re-confirm any time with
the five commands in its §4 — trust the commands over any document, including this one.

## Entry points (import → namespace → what you get)
| Import | Namespace | Key declarations |
|---|---|---|
| `DualScaleStream2.TDuality.ODD` | `DualScaleStream2.TDuality` | `Charge d`, `eta d`, `IsODD g`, `thetaShift`, `basisChange`, `thetaShift_isODD`, `basisChange_isODD`, `isODD_mul` |
| `…TDuality.Factorized`, `.Spectrum` | same | `factorized`, `factorized_isODD`, `factorized_mul_self`, `chargeNorm`, `chargeNorm_invariant`, `isODD_inv_isODD`, `spectrum_equivalence` |
| `…TDuality.Mirror`, `.SL2Product` | same | `tauShift`, `mirror_conjugates_tauShift`, `basisChange_comm_thetaShift` |
| `DualScaleStream2.DFT.GeneralizedMetric` | `DualScaleStream2.DFT` | `genMetric G B`, `etaR_genMetric_sq` ((ηH)²=1), `genMetric_symm`, `tduality_inverts_metric`, `massForm`, `massForm_covariant`, `massForm_circle` |
| `…DFT.BShift`, `.SectionCondition` | same | `genMetric_bshift`, `IsSection`, `momentumFrame_isSection`, `isSection_image`, `levelMatching_iff` |
| `DualScaleStream2.DualScale.TraceBound` | `DualScaleStream2.DualScale` | `dualScale G = tr G + tr G⁻¹`, `dualScale_ge` (≥ 2d for PosDef G), `dualScale_inv`, `dualScale_one`, `circle_effective_scale_ge_two` |
| `DualScaleStream2.Lattice.*` | `DualScaleStream2.Lattice` | `Gram`, `cartanE8`, `cartanE8_unimodular`, `cartanE8_posDef`, `hyperbolicU_*`, `Signature`, `sigK3_eq` (3,19), `sigMukai_eq` (4,20), `sigK3T2_eq`, `mukaiPair_*`, `reflection_isometry` |
| `DualScaleStream2.Flux.*`, `.Moonshine.EOT` | `…Flux`, `…Moonshine` | `k3k3_anomaly` (χ/24 = 24), `tadpole_budget`, `flux_half_selfIntersection_integral`, `eotA`, `first_five_are_irreps`, `A6_decomposition` |
| `StringTheoryFormalization.UseCases.*` | `StringTheory.UseCases.*` | `tduality_invariant_mass_squared`, `self_dual_radius_unique`, `narain_form_even`, `narain_gram_unimodular`, critical dimension 26/10, K3 signature −16, Mathieu tower |
| `StringTheoryFormalization.StringDynamics.MathieuM24` | `StringTheory.StringDynamics` | `M24_order`, `M24RepDim` (EOT A.3 order), `M24RepDim_sum_sq` (Burnside guard) |

Find anything else with the skill `leanmaster-theorem-search` (catalogue: `papers/book/generated/lean_catalogue.md`).

## Depend on it
Copy `examples/consumer_demo/` (lakefile shows both options): same-machine path dependency reusing the
built Mathlib (`packagesDir`), or `require … from git … @ "v2.1.0"`. Your `lean-toolchain` must be
`leanprover/lean4:v4.33.1` and you must not pull a different Mathlib revision.

## Scope limits you must carry into your own text
* Tier A = the Lean statement as written. Physical interpretation = Tier L (pin the source) or Tier C.
* One direction only: `thetaShift_isODD`, `basisChange_comm_thetaShift`; `dualScale_one` is attainment, not
  uniqueness; generation of O(d,d;ℤ) and the classification of even unimodular lattices are Tier L.
* The five Mathlib-free libraries are integer/rational "arithmetic shadows": fine to cite as such, not as
  formalized field theory. Prefer `DualScaleStream2` when a fact exists in several libraries.
* Moonshine convention: `eotA` = EOT's A_n (45, 231, 770, 2277, …); massive multiplicities are 2·A_n; 2277 is
  a real irrep (4554 = 2·2277, not a conjugate pair).
* Never "zero axioms", "100% verified", "proves string theory".

## Cite
"Kernel-checked in Lean 4 (v4.33.1, Mathlib v4.33.1) in `DualScaleStream2.<Module>.<name>`, repository
xaviercallens/SocrateAI-Scientific-Agora-LeanMaster, release v2.1.0; depends only on Lean's three standard
axioms." Narrative and derivations: `papers/publication/paper8_dual_scale_k3t2_tduality_lean4.pdf` and the
master book under `papers/book/`.
