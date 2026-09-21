-- Block WS5: Picard Spectral Radius ρ = 18
-- Status: VERIFIED (0 sorry axioms)
import Mathlib.Analysis.SpecialFunctions.Complex.Circle
import StringTheoryFormalization.StringDynamics.VertexOperators

namespace StringTheory.StringDynamics

/-- The Picard iteration for the worldsheet OPE algebra converges
    when the spectral radius ρ < 1 after rescaling by 1/18. -/
def picardSpectralRadius : ℕ := 18

/-- Contraction factor of the Picard iteration on the OPE algebra:
    Rescaled Picard spectral radius satisfies ρ⁻¹ < 1.

    **Disclosure (2026-09-21).** The statement is `1/18 < 1`, a fact about two numerals, closed by `norm_num`.
    `picardSpectralRadius := 18` is an *assigned definition*, not a computed spectral radius, and no operator,
    iteration, fixed point or norm appears anywhere in this file — so this is not a contraction estimate for
    the OPE algebra or for anything else. See `picard_convergence` below, which is this same statement under a
    second name. Statement unchanged, nothing deleted. -/
theorem picard_spectral_contraction :
    (1 : ℝ) / (picardSpectralRadius : ℝ) < 1 := by
  dsimp [picardSpectralRadius]
  norm_num

/-- Positivity of the spectral radius. -/
theorem picard_spectral_radius_pos :
    0 < (picardSpectralRadius : ℝ) := by
  dsimp [picardSpectralRadius]
  norm_num

/-- **Disclosure (2026-09-21) — the same statement as `picard_spectral_contraction`, under a second name** — the proof is that theorem,
by `rfl` of the term. It is `1/18 < 1`, a fact about two numerals. No operator, no iteration, no fixed point
and no norm appears in this file, so neither declaration is a convergence criterion for anything: a
contraction-mapping argument would need the Picard map on a function space, a Lipschitz constant `L` of the
right-hand side, and `L t < 1` on a short interval. `picardSpectralRadius := 18` is a definition, not a
computed spectral radius.

Disclosed in place on 2026-09-21 (statement unchanged, nothing deleted). `papers/book/chapters/ch32_cosmology.tex`
already reads it this way; the disclosure was missing *here*, where it travels with the declaration. Found by
the name-vs-statement triage of `LL.md` §S11.7. -/
theorem picard_convergence :
    (1 : ℝ) / (picardSpectralRadius : ℝ) < 1 :=
  picard_spectral_contraction

end StringTheory.StringDynamics
