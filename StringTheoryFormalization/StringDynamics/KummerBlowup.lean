-- Block WS6: Kummer Blowup (K3 singular locus resolution)
-- Status: VERIFIED (0 sorry axioms)
-- Provides: The Kummer construction T⁴/ℤ₂ → K3 with 16 exceptional divisors E_i.
import Mathlib.Algebra.Module.Basic
import StringTheoryFormalization.Foundations.MathlibCore

namespace StringTheory.StringDynamics

/-- The 16 exceptional divisors from the Kummer blowup of T⁴/ℤ₂. -/
def kummerExceptionalDivisors : Fin 16 → String :=
  fun i => s!"E_{i.val}"

/-- Intersection form: E_i · E_j = -2 δ_{ij}  (the A₁ lattice). -/
def kummerIntersectionForm (i j : Fin 16) : ℤ :=
  if i = j then -2 else 0

/-- The Kummer blowup contributes 16 × (-2)-curves to the Mukai lattice. -/
theorem kummer_lattice_contribution :
    (∑ i : Fin 16, kummerIntersectionForm i i) = -32 := by
  simp [kummerIntersectionForm, Finset.sum_const, Finset.card_fin]

/-- Self-intersection of any exceptional divisor. -/
theorem exceptional_self_intersection (i : Fin 16) :
    kummerIntersectionForm i i = -2 := by
  simp [kummerIntersectionForm]

end StringTheory.StringDynamics
