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

/-- **Disclosure (2026-09-21) — both claims in the previous docstring were false, and the value was
stale.** It read "Re-export summary: all Mathlib primitives used by the pipeline. This namespace is
`open`ed in every downstream block."

* It re-exports nothing. This is a `String` constant — a label, not a proposition — and the `import`
  lines above are what make Mathlib available; the `def` plays no part in that.
* It is not opened downstream. `grep -rl mathlib_version --include=*.lean` finds **one** file: this one.
* The value said `v4.33.1` while `lakefile.lean` has required `v4.34.0-rc2` since the toolchain
  migration (commit `e9a7162`). Corrected here.

**And it will go stale again**, because nothing checks it: no kernel obligation ties this string to the
toolchain, and a `String` cannot be wrong in a way Lean can detect. **`lakefile.lean` and
`lake-manifest.json` are authoritative for the Mathlib revision; this constant is not.** Read as a
human-facing label only.

`papers/book/chapters/ch02_classical.tex` already read it correctly — "a label, not a proposition… that
is true and vacuous" — and, as with the other cases of `LL.md` §S11.8, the correct reading was in the book
and not at the declaration. -/
def mathlib_version : String := "Mathlib4 @ v4.34.0-rc2"

end StringTheory.Foundations
