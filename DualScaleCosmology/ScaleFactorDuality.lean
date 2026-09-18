/-
Stream 3 · Scale-factor duality and the log-scale-factor dual-scale bound.

**Hypothesis under study (Tier C, stated in full in `docs/STREAM3_WORKFLOW.md` §1):**
the project's dual-scale principle — no T-duality-invariant scale falls below a minimum
(Stream 1 `EffectiveMetric.genesis_no_singularity`, Stream 2
`DualScale.TraceBound.dualScale_ge`) — has a *cosmological* counterpart pairing a
microscopic scale `ℓ_micro ~ ℓ_P` with a macroscopic scale `ℓ_macro ~ H₀⁻¹` via some
non-perturbative duality. This file formalizes the one piece of that hypothesis that is
already a theorem in the literature: **scale-factor duality** in string cosmology
(Gasperini–Veneziano, `papers/foundations/hep-th_9211021.txt`, "Pre-Big-Bang in String
Cosmology"), which is the `O(d,d)` target-space duality of `DFT.GeneralizedMetric` applied
to a time-dependent FRW background instead of a static torus.

### Physical background (Tier L, Gasperini–Veneziano ll. 372–373, 639–640)
"the Hubble parameter is odd under scale factor duality, `H → −H`, so that a duality
transformation `a → a⁻¹` maps an expanding solution" to a contracting one (l. 372–373); the
self-dual case is "a metric that satisfies `a⁻¹(t) = a(−t)`" (l. 639–640). This is the
*same* algebraic involution `x ↦ −x` on the log-radius that Stream 2's Buscher inversion
uses on `K3 × T²` (paper 1, "Buscher Inversion is an Exact Involution", `x = ln(R/√α')`),
now applied to the scale factor `a(t)` instead of a compactification radius.

### What is and is not proved here (Tier A vs. Tier C)
Tier A: `a ↦ a⁻¹` is an involution on `ℝ \ {0}` (`scaleFactorDual_invol`); its unique
positive fixed point is `a = 1`, matching the self-dual condition above at `t = 0`
(`scaleFactorDual_fixed_iff`); the log-scale-factor `x = ln a` is odd under the duality
(`log_scaleFactorDual`, the algebraic shadow of "`H` is odd", since `H = d(ln a)/dt` and
differentiating an odd function gives an odd-in-the-transformed-variable statement — the
differential-geometric statement about `H` itself is Tier L, not re-derived here, exactly as
the module comment on `DualScaleStream2.DualScale.TraceBound` treats `R_eff`); and the same
"dual scale ≥ minimum" bound already proved for the torus radius
(`TraceBound.circle_effective_scale_ge_two`) transfers verbatim to `a + a⁻¹`
(`cosmoDualScale_ge_two`), since the underlying algebra is identical.

**Not proved, and not claimed as anything beyond Tier C:** that `a + a⁻¹` (or any duality
invariant built from it) is a physically preferred measure relating `ℓ_micro` and
`ℓ_macro`; that the Hubble parameter itself (as opposed to its algebraic shadow `ln a`) is
odd under any transformation proved here; and, above all, that this file says anything about
`H₀` or the present cosmological horizon — that identification is exactly the Stream 3
hypothesis under study, stated as Tier C in `docs/STREAM3_WORKFLOW.md`, not asserted here.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic

namespace DualScaleCosmology.ScaleFactorDuality

/-- Scale-factor duality: `a ↦ a⁻¹` (Gasperini–Veneziano l. 373, `a → a⁻¹`). -/
noncomputable def scaleFactorDual (a : ℝ) : ℝ := a⁻¹

/-- **Scale-factor duality is an involution** on nonzero reals: applying it twice returns
the original scale factor, matching the fact that `a → a⁻¹` is its own inverse
transformation (Gasperini–Veneziano l. 373). -/
theorem scaleFactorDual_invol {a : ℝ} (_ha : a ≠ 0) :
    scaleFactorDual (scaleFactorDual a) = a := by
  simp [scaleFactorDual, inv_inv]

/-- **The self-dual point is `a = 1`**: among positive scale factors, `a` is a fixed point
of scale-factor duality iff `a = 1`. This is the `t = 0` instance of the self-dual condition
"`a⁻¹(t) = a(−t)`" (Gasperini–Veneziano l. 639–640): at `t = 0`, self-duality reads
`a⁻¹(0) = a(0)`, i.e. exactly `scaleFactorDual a = a`. -/
theorem scaleFactorDual_fixed_iff {a : ℝ} (ha : 0 < a) :
    scaleFactorDual a = a ↔ a = 1 := by
  constructor
  · intro h
    have : a * a = 1 := by
      have h' : a⁻¹ = a := h
      field_simp [scaleFactorDual, ha.ne'] at h'
      linarith [h']
    nlinarith [sq_nonneg (a - 1)]
  · rintro rfl; simp [scaleFactorDual]

/-- **The log-scale-factor is odd under scale-factor duality**: `ln(a⁻¹) = −ln a`. This is
the algebraic shadow of "`H` is odd under duality" (Gasperini–Veneziano l. 372): the Hubble
parameter is `H = d(ln a)/dt`, and differentiating an odd function's argument transformation
carries the sign; the differential statement about `H` itself is Tier L (not re-derived
here, exactly as `TraceBound`'s module comment treats the un-formalized derivative content
behind `R_eff`), but its purely algebraic content — that the log-radius itself flips sign —
is Tier A. -/
theorem log_scaleFactorDual {a : ℝ} (_ha : 0 < a) :
    Real.log (scaleFactorDual a) = -Real.log a := by
  simp [scaleFactorDual, Real.log_inv]

/-- The dual-scale invariant built from the log-scale-factor's duality partner
`x = ln a` and its own image under negation, in the same algebraic shape as Stream 2's
`R + α'/R` (`DualScaleStream2.DualScale.TraceBound.dualScale_circle`, `d = 1` case): the sum
of a positive quantity `a` and its dual `a⁻¹`. -/
noncomputable def cosmoDualScale (a : ℝ) : ℝ := a + scaleFactorDual a

/-- **The cosmological dual scale is bounded below by 2**, attained uniquely at the
self-dual point `a = 1`: the exact transfer of Stream 2's
`TraceBound.circle_effective_scale_ge_two` (`R + 1/R ≥ 2`) to the scale factor, since
`cosmoDualScale` is definitionally the same expression `a + a⁻¹`. Proved independently here
(not `import`ed from Stream 2) because the physical objects — a compactification radius `R`
versus a cosmological scale factor `a` — are different, and Stream 3 does not assert they
are the same invariant; only the algebra is shared. -/
theorem cosmoDualScale_ge_two {a : ℝ} (ha : 0 < a) : 2 ≤ cosmoDualScale a := by
  have h : cosmoDualScale a - 2 = (a - 1) ^ 2 / a := by
    simp only [cosmoDualScale, scaleFactorDual]; field_simp; ring
  nlinarith [sq_nonneg (a - 1), div_nonneg (sq_nonneg (a - 1)) ha.le, h]

end DualScaleCosmology.ScaleFactorDuality
