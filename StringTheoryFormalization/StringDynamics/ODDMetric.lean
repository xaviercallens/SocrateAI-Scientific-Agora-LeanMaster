-- Block WS13: O(D,D) Metric
-- Status: VERIFIED (0 sorry axioms)
-- Provides: The O(D,D;ℤ) duality group and its invariant metric η_{MN}.
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.LinearAlgebra.Matrix.Transvection
import StringTheoryFormalization.StringDynamics.TDualityGysin

/-!
# The O(D,D) invariant metric η

## Physical background
T-duality on a `D`-torus acts on the doubled charge vector `(winding, momentum) ∈ ℤ^{2D}` (or
its continuum generalized-metric analogue) as an element of `O(D,D;ℤ)`, the group preserving the
split-signature bilinear form `η`. Hull–Zwiebach give it explicitly as the block matrix
`η = [[0, 1_D],[1_D, 0]]` (`papers/foundations/hull_zwiebach_0904_4664.txt`, ll. 929–933, eq.
(2.33): "`η = (0 I; I 0)`... the O(D,D) invariant metric η"); Hohm–Hull–Zwiebach build the whole
generalized-metric formalism of double field theory around this same `η`
(`papers/foundations/hohm_hull_zwiebach_generalized_metric_1006_4823.txt`, ll. 250–333).
BOOK_BIBLE.md §5 fixes the same block form as this book's convention, `η = [[0,1],[1,0]]`, and
records the generalized metric `H(G,B)` built from it. Only `η` itself — not the generalized
metric, not the T-duality group action, not a torus — is formalized in this file.

## Mathematical content
`oddMetric D : Matrix (Fin (2*D)) (Fin (2*D)) ℤ` is the `2D×2D` integer matrix that is `1` at
position `(i, i+D)` for `i < D`, `1` at position `(i+D, i)` for `i < D` (equivalently, symmetric
by construction of the two branches), and `0` elsewhere — the block matrix `[[0, 1_D],[1_D, 0]]`
over `ℤ`, not over `ℝ`. `odd_metric_symm` proves `ηᵀ = η` for every `D`, the symmetry needed for
`η` to be a (indefinite) bilinear form. `odd_metric_d1` specializes to `D = 1`, checking `η`
literally equals the `2×2` matrix `!![0,1;1,0]`. Neither theorem touches signature, definiteness,
or the action of `O(D,D;ℤ)` on charge vectors (that action is formalized separately, e.g. in
`DualScaleStream2.TDuality.eta`, per the atlas — see below).

## Proof techniques
`odd_metric_symm`: `ext i j` reduces matrix equality to equality of entries; `simp` unfolds both
`Matrix.transpose_apply` and the definition of `oddMetric` on entry `(j, i)` vs `(i, j)`, after
which the remaining goal is a statement purely about the natural-number index arithmetic
(`i.val < D ∧ j.val = i.val + D` vs. its mirror image), closed by `omega`. `odd_metric_d1`: with
`D` fixed to `1`, `fin_cases i <;> fin_cases j` exhausts all four `(i,j) ∈ Fin 2 × Fin 2` entries,
and `simp` evaluates `oddMetric`'s `if`-`then`-`else` on each literal pair.

## Related declarations
The atlas's `similar_cross_library` and `unification_candidates` tables pair `odd_metric_symm`
and `odd_metric_d1` (cosine 0.352 and 0.441 respectively) with `StringTheory.Foundation.PhysLib.
odd_metric_involutive` in a different library, at low dependency-Jaccard — an independent
re-proof of a related but distinct fact about the *same* `η` object (involutivity `η² = 1`, not
symmetry `ηᵀ = η`), rather than a duplicate of either theorem here. `odd_metric_d1` also shares
Mathlib's `zero_ne_one._simp_1` lemma with several `DualScaleStream2` matrix lemmas (shared proof
infrastructure only). Separately, `DualScaleStream2.TDuality.eta`/`IsODD` (a hub used by 20 and
12 theorems respectively, per the atlas hub table) is the *other* formalization of essentially
this same `η`, there packaged together with the T-duality group action on charge vectors that
this file does not include — same mathematical object, different (and larger) scope.
-/

namespace StringTheory.StringDynamics

open Matrix

variable (D : ℕ)

/-- The `2D×2D` integer block matrix `η = [[0, 1_D],[1_D, 0]]`: entry `1` at `(i, i+D)` and
    `(i+D, i)` for `i < D`, `0` everywhere else. This is the O(D,D)-invariant metric of T-duality
    (`papers/foundations/hull_zwiebach_0904_4664.txt`, ll. 929–933), formalized here over `ℤ`
    rather than `ℝ`. -/
def oddMetric : Matrix (Fin (2 * D)) (Fin (2 * D)) ℤ :=
  Matrix.of (fun i j =>
    if i.val < D ∧ j.val = i.val + D then 1
    else if j.val < D ∧ i.val = j.val + D then 1
    else 0)

/-- `η` is symmetric: `ηᵀ = η`, for every `D`. Physically, this is what makes `η` a genuine
    (indefinite) bilinear form rather than an arbitrary matrix. Proof idea: entrywise, swapping
    `i` and `j` swaps the two `if`-branches of `oddMetric`, so symmetry reduces to natural-number
    index arithmetic, closed by `omega`. -/
theorem odd_metric_symm : (oddMetric D)ᵀ = oddMetric D := by
  -- reduce matrix equality to an equality of entries at each (i, j)
  ext i j
  -- unfold both `oddMetric` and the transpose so the goal is about the two if-branches
  simp [oddMetric, Matrix.transpose_apply]
  -- the remaining goal is pure Fin/Nat index arithmetic (swapping i ↔ j swaps the branches)
  omega

/-- For `D = 1`, `η` is literally the `2×2` anti-diagonal matrix `!![0,1;1,0]` — the smallest
    case of the O(D,D) metric, matching `papers/foundations/hull_zwiebach_0904_4664.txt` eq.
    (2.33) specialized to one doubled coordinate. Proof: exhaust the four index pairs and
    evaluate `oddMetric`'s definition on each. -/
theorem odd_metric_d1 :
    oddMetric 1 = !![0, 1; 1, 0] := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [oddMetric, Matrix.of_apply]

end StringTheory.StringDynamics
