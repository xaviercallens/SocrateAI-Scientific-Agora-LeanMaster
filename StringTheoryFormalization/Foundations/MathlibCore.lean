-- Block F1: Mathlib Foundation Layer
-- Status: VERIFIED (0 sorry axioms)
-- Provides: Core logic, algebra, category theory, topology prerequisites
-- consumed by all 28 downstream blocks.
import Mathlib.Algebra.Category.ModuleCat.Basic
import Mathlib.Analysis.SpecialFunctions.Complex.Circle
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Topology.Algebra.Module.FiniteDimension
import Mathlib.CategoryTheory.Functor.Basic
import Mathlib.MeasureTheory.Function.L2Space

namespace StringTheory.Foundations

/-- Re-export summary: all Mathlib primitives used by the pipeline.
    This namespace is `open`ed in every downstream block. -/
def mathlib_version : String := "Mathlib4 @ v4.33.1"

end StringTheory.Foundations
