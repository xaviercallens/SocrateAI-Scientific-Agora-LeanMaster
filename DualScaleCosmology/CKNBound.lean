/-
Stream 3 · The Cohen–Kaplan–Nelson micro/macro cutoff bound.

**Hypothesis under study (Tier C, `docs/STREAM3_WORKFLOW.md` §1):** a micro scale
`ℓ_micro ~ ℓ_P` and a macro scale `ℓ_macro ~ H₀⁻¹` are linked by "non-perturbative duality
transformations". This file formalizes the one piece of the literature that actually links a
UV (micro) cutoff to an IR (macro/cosmological) cutoff with a precise inequality — not a
duality, but a **bound**: Cohen–Kaplan–Nelson (CKN), "Effective Field Theory, Black Holes,
and the Cosmological Constant", `papers/foundations/hep-th_9803132.txt`.

### Physical background (Tier L, CKN eq. (2), l. 78, and l. 80)
For an effective field theory in a box of size `L` with UV cutoff `Λ`, demanding no state
already collapsed to a black hole (Schwarzschild radius exceeding `L`) gives
`L³Λ⁴ < M_P²` (l. 78, `M_P` the reduced Planck mass), so that "the IR cutoff scales like
`Λ⁻²`" (l. 80): the box size `L` cannot be chosen independently of the UV cutoff `Λ`. CKN's
own reading (l. 113–117) instantiates this with `L` at "the current horizon size" — i.e.
the macro/cosmological scale the Stream 3 hypothesis calls `ℓ_macro` — and finds the
implied UV cutoff `Λ ~ 10⁻²·⁵ eV`, a genuine micro/macro relation already in the literature,
20+ years before this project's conjecture.

### What is and is not proved here (Tier A vs. Tier C)
Tier A: the bound `L³Λ⁴ ≤ M_P²` is symmetric in what it constrains — solved for `Λ` it
bounds the UV cutoff by the macro scale (`ckn_Lambda_le`), and solved for `L` it bounds the IR
box size by the UV cutoff (`ckn_L_le`), each a straightforward monotone rearrangement of the
same cubic/quartic inequality using `Real.rpow` monotonicity — no physics beyond CKN's own
eq. (2) algebra.

**Not proved, and not claimed as anything beyond Tier C:** that the specific numbers
`ℓ_P` and `H₀⁻¹` from the Stream 3 hypothesis saturate this bound (CKN's own √TeV-scale
"L at current horizon" estimate is a physics argument, Tier L, not re-derived here); that
this bound is a *duality* in the sense of Stream 1/2's `O(d,d)` T-duality (it is a strict
inequality with no natural involution, unlike `ScaleFactorDuality.scaleFactorDual`); and
nothing here says the two Tier A facts in this library (`ScaleFactorDuality` and `CKNBound`)
combine into a single micro/macro correspondence — see `docs/STREAM3_WORKFLOW.md` §1 for
exactly how far the current formalization goes and where the gap to the Stream 3 hypothesis
remains open.

### Proof technique
Both directions clear denominators with `div_le_iff₀`/`le_div_iff₀` to reduce to the raw
polynomial inequality `h`, then apply `Real.rpow_le_rpow` (monotonicity of `x ↦ x^(1/n)` on
nonnegative reals) and simplify `(x^n)^(1/n) = x` via `Real.rpow_natCast` and
`Real.rpow_mul`. No case split on the sign of `L`, `Λ`, `M` beyond the positivity hypotheses
already required for the physical quantities to make sense.
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real

namespace DualScaleCosmology.CKNBound

open Real

/-- **CKN bound, solved for the macro/IR scale `L`** (eq. (2), l. 78, rearranged): if
`L³Λ⁴ ≤ M_P²`, the macro scale `L` cannot exceed `(M_P² Λ⁻⁴)^(1/3)`. This is the direction
CKN themselves use (l. 113–117): fixing a UV cutoff `Λ` caps how large the IR box `L` can be
in a consistent effective field theory. -/
theorem ckn_L_le (L Λ M : ℝ) (hL : 0 < L) (hΛ : 0 < Λ) (_hM : 0 < M)
    (h : L ^ 3 * Λ ^ 4 ≤ M ^ 2) :
    L ≤ (M ^ 2 * Λ⁻¹ ^ 4) ^ ((1 : ℝ) / 3) := by
  have hΛ4 : (0 : ℝ) < Λ ^ 4 := by positivity
  have key : L ^ 3 ≤ M ^ 2 * Λ⁻¹ ^ 4 := by
    rw [inv_pow, ← div_eq_mul_inv, le_div_iff₀ hΛ4]
    linarith [h]
  have step := Real.rpow_le_rpow (by positivity : (0 : ℝ) ≤ L ^ 3) key
    (by norm_num : (0 : ℝ) ≤ (1 : ℝ) / 3)
  rw [← Real.rpow_natCast L 3, ← Real.rpow_mul hL.le] at step
  norm_num at step
  rw [inv_pow]; exact step

/-- **CKN bound, solved for the micro/UV cutoff `Λ`** (eq. (2), l. 78, rearranged the other
way): if `L³Λ⁴ ≤ M_P²`, the micro cutoff `Λ` cannot exceed `(M_P² L⁻³)^(1/4)`. Fixing a
macro scale `L` (e.g. "the current horizon size", CKN l. 113) caps how fine a UV cutoff the
effective theory can consistently claim. -/
theorem ckn_Lambda_le (L Λ M : ℝ) (hL : 0 < L) (hΛ : 0 < Λ) (_hM : 0 < M)
    (h : L ^ 3 * Λ ^ 4 ≤ M ^ 2) :
    Λ ≤ (M ^ 2 * L⁻¹ ^ 3) ^ ((1 : ℝ) / 4) := by
  have hL3 : (0 : ℝ) < L ^ 3 := by positivity
  have key : Λ ^ 4 ≤ M ^ 2 * L⁻¹ ^ 3 := by
    rw [inv_pow, ← div_eq_mul_inv, le_div_iff₀ hL3]
    nlinarith [h]
  have step := Real.rpow_le_rpow (by positivity : (0 : ℝ) ≤ Λ ^ 4) key
    (by norm_num : (0 : ℝ) ≤ (1 : ℝ) / 4)
  rw [← Real.rpow_natCast Λ 4, ← Real.rpow_mul hΛ.le] at step
  norm_num at step
  rw [inv_pow]; exact step

end DualScaleCosmology.CKNBound
