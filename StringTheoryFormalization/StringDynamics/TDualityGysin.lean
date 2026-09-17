-- Block WS12: T-Duality Gysin Map
-- Status: VERIFIED (0 sorry axioms)
-- Provides: T-duality as a Gysin pushforward on K3 cohomology.
import Mathlib.Algebra.Module.Basic
import StringTheoryFormalization.StringDynamics.MukaiLattice

/-!
# T-duality on a circle: radius inversion, the winding/momentum swap, and a stub pushforward

## Physical background
A closed string on a circle of radius `R` carries quantized momentum `n` and winding number `w`;
T-duality is the statement that the theory at radius `R` is physically identical to the theory at
radius `α'/R` with `n` and `w` exchanged. Tong derives the mode expansion carrying both quantum
numbers and the resulting left/right momenta `p_{L,R} = n/R ± wR/α'`
(`papers/foundations/tong_string_theory_0908_0333.txt`, ll. 11371–11400); Giveon–Porrati–Rabinovici
write the doubled charge vector `Z` of winding and momentum integers that this symmetry acts on
(`papers/foundations/giveon_hep-th_9401139.txt`, l. 1289). BOOK_BIBLE.md §5 fixes the same
convention: `R ↦ α'/R`, `n ↔ w`, mass formula `M² = n²/R² + w²R²/α'² + …`. The "Gysin pushforward"
half of this file — integration over a fibre `S¹` in `H*(K3×S¹) → H*(K3)` — is standard algebraic
topology but does **not** appear, under that or any name, anywhere in `papers/foundations/*.txt`
(checked by exhaustive grep); it is marked here as "standard; not checked against a source in
this book's library" per BOOK_BIBLE.md §1, not invented a citation for.

## Mathematical content
`tDualityRadius R α' hR hα := α'/R` computes the dual radius; the positivity hypotheses `hR`,
`hα` are accepted as arguments but **never used** in the body (Lean's own linter flags both as
unreferenced — see the file's baseline warnings), so this definition proves nothing about
positivity of the result, it merely computes a quotient. `TDualState` is a pair of integers
`(momentumNum, windingNum)`; `tDualityAction` swaps them. `tduality_involution` proves that
applying the swap twice returns the original state — an authentic (if minimal) formalization of
"T-duality squares to the identity" at the level of the bare integer pair, with no mass formula,
no radius, and no moduli space attached. `gysinPushforward coeff := coeff 0` reads off the
zeroth coefficient of an arbitrary integer sequence; nothing here constructs `H*(K3×S¹)`,
`H*(K3)`, a fibration, or an integration map, so the docstring's "integrates over the S¹ fibre"
is a naming aspiration, not a formalized construction — the function is definitionally just
evaluation at `0`.

## Proof techniques
`tduality_involution` unfolds `tDualityAction` twice via `simp`, at which point swapping a pair's
two components twice is definitionally the identity on each component (`simp` closes both
resulting field-equalities directly).

## Related declarations
No declaration in this file appears in the atlas's hub, bridge, similarity or intersection
tables. `tduality_involution` is the natural analogue of `DoubleFieldTheory.TDualityBuscher.
buscher_log_involution` (an atlas similarity pair with `DualScaleValidation.UseCase1.
buscher_log_involution`, cosine 0.434, elsewhere in the project) and of `DualScaleStream2.
TDuality.eta`'s involutive structure (an atlas hub used by 20 theorems) — same underlying physical
idea, T-duality-squares-to-identity, formalized independently and at a much thinner level (a bare
integer swap, no `η`-matrix, no charge norm, no basis change) than either of those.
-/

namespace StringTheory.StringDynamics

/-- Computes `α'/R`, the T-dual radius under `R ↦ α'/R`
    (`papers/foundations/tong_string_theory_0908_0333.txt`, ll. 11371–11460, and BOOK_BIBLE.md
    §5). The hypotheses `hR : 0 < R` and `hα : 0 < α'` are accepted but **not used** in the
    body — this definition is the bare quotient `α'/R`, proving no positivity of the result. -/
noncomputable def tDualityRadius (R α' : ℝ) (hR : 0 < R) (hα : 0 < α') : ℝ := α' / R

/-- A pair of integers `(momentumNum, windingNum) = (n, w)`, the Kaluza–Klein momentum and
    winding numbers of a string on a circle. Carries no radius, mass, or level-matching data —
    just the two integers T-duality is stated to exchange. -/
structure TDualState where
  momentumNum : ℤ   -- n (KK momentum)
  windingNum : ℤ    -- w (winding number)

/-- The T-duality action on `TDualState`: swap momentum and winding, `(n, w) ↦ (w, n)`. -/
def tDualityAction (s : TDualState) : TDualState :=
  { momentumNum := s.windingNum
    windingNum  := s.momentumNum }

/-- T-duality is an involution: swapping momentum and winding twice returns the original state,
    `tDualityAction (tDualityAction s) = s`. Physically, this is the minimal content of
    "T-duality squares to the identity" — at the level of the bare `(n, w)` pair only, with no
    radius or mass formula attached. Proof idea: unfold the swap twice; each field ends up back
    where it started, by `simp`. -/
theorem tduality_involution (s : TDualState) :
    tDualityAction (tDualityAction s) = s := by
  simp [tDualityAction]

/-- Evaluates an integer sequence `coeff : ℤ → ℤ` at `0`. Named for the intended physical
    reading — a Gysin/fibre-integration map `π₊ : H*(K3×S¹) → H*(K3)` picking out the degree-0
    piece — but no cohomology ring, fibration, or integration is constructed here; this is
    literally `coeff 0`. "Gysin pushforward" does not occur in `papers/foundations/*.txt`;
    treat this as standard algebraic topology not checked against a source in this project's
    library, per BOOK_BIBLE.md §1. -/
noncomputable def gysinPushforward (coeff : ℤ → ℤ) : ℤ :=
  coeff 0  -- degree-0 component = fibre integral

end StringTheory.StringDynamics
