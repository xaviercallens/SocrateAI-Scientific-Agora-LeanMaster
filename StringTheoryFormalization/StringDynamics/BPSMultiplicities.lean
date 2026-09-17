-- Block WS9: BPS Multiplicities  ℛ_BPS = 77/60
-- Status: VERIFIED (0 sorry axioms)
-- Provides: The rational BPS index ratio used in flux counting.
import Mathlib.Data.Rat.Defs
import StringTheoryFormalization.StringDynamics.MathieuM24

/-!
# A BPS index ratio, and an unverified asymptotic multiplicity formula

## Physical background
K3 sigma models carry BPS (short) representations of the N=(4,4) superconformal algebra whose
multiplicities are counted by the elliptic genus; `papers/foundations/
eguchi_ooguri_tachikawa_1004_0956.txt` ll. 82–124 defines the BPS-representation characters and
the non-BPS/BPS decomposition at the unitarity bound `h = 1/4` that these counts come from.
This file's specific ratio `77/60`, however, is **not** derived from that decomposition anywhere
in `papers/foundations/`: grepping the whole library finds no occurrence of `77/60`. The only
project source for it is `LL.md` l. 405, which records that the *undoubled* M₂₄ irreducible
dimensions `45` and `231` (`MathieuM24.M24RepDim` at indices 2 and 4) satisfy
`231 / (4 × 45) = 77/60` identically. That arithmetic identity is Tier A-checkable but is not
formalized in this file (`bpsRatio` below is simply the literal `77/60`, with no computation
connecting it to `M24RepDim`); the physical reading "BPS index ratio" is Tier C in this file —
this project's own naming, not a claim sourced to the literature.

## Mathematical content
`bpsRatio : ℚ := 77/60` is a bare rational literal. `bps_ratio_reduced` and `bps_ratio_pos` are
elementary facts about that literal (already in lowest terms; positive), proved by `norm_num`
unfolding the definition — they are arithmetic on `77/60`, not physics. `bpsMultiplicity` is a
`noncomputable def` only: no theorem in this file states or proves anything about it (no growth
bound, no relation to `bpsRatio` or to a partition-counting function). Its docstring's citation of
a "Hardy–Ramanujan formula" is likewise not pinned to any file in `papers/foundations/` — describe
it as an unverified formula this project intends to relate to BPS state counting, not as an
established asymptotic.

## Proof techniques
Both theorems reduce to `norm_num` after unfolding `bpsRatio`, i.e. plain rational-numeral
arithmetic (compute `gcd(77,60) = 1` for `bps_ratio_reduced`; compare `0 < 77/60` for
`bps_ratio_pos`). No induction, no case split.

## Related declarations
The atlas (`papers/book/generated/atlas.md`, `atlas_data.json`) records no cross-library
similarity or dependency-intersection entry for `bpsRatio`, `bps_ratio_reduced`,
`bps_ratio_pos` or `bpsMultiplicity` — they are numerically and structurally isolated in the
dependency graph; `bps_ratio_pos`/`bps_ratio_reduced` only share Mathlib's `Rat.instCharZero`
lemma with unrelated numeral facts elsewhere in `StringTheoryFormalization` (shared proof
infrastructure, no mathematical relation). `MathieuM24.M24RepDim`, imported here and mentioned
above via LL.md's `231/(4×45)` identity, is a hub used by other theorems (see that file's module
docstring) but no declaration in *this* file actually invokes it.
-/

namespace StringTheory.StringDynamics

/-- The literal `77/60`, called the "BPS index ratio" by this project. This is a Tier C naming
    choice, not a definition derived from BPS-state counting in this file: see the module
    docstring for the arithmetic coincidence (`231/(4×45) = 77/60` on two `M24RepDim` entries,
    recorded in `LL.md`, not in `papers/foundations/`) that motivated the name. -/
def bpsRatio : ℚ := 77 / 60

/-- `77/60` is already in lowest terms (`gcd(77,60) = 1`): its numerator is `77` and its
    denominator `60`. Proof: unfold `bpsRatio` and let `norm_num` compute the reduced form. -/
theorem bps_ratio_reduced :
    bpsRatio.num = 77 ∧ bpsRatio.den = 60 := by
  constructor <;> norm_num [bpsRatio]

/-- `bpsRatio` is (strictly) positive, i.e. `0 < 77/60`. Proof: `norm_num` on the unfolded
    literal. Note this is weaker than "`bpsRatio > 1`" — positivity alone says nothing about
    whether the ratio exceeds the naive count of 1; that stronger, physically-motivated claim is
    not what is proved here. -/
theorem bps_ratio_pos : (0 : ℚ) < bpsRatio := by
  norm_num [bpsRatio]

/-- An asymptotic-looking real-valued expression `exp(4π√n) / n^{3/2}` in `n`, offered as a
    candidate BPS-multiplicity growth formula. `noncomputable` (it uses `Real.exp`/`Real.sqrt`);
    **no theorem below proves anything about it** — not positivity, not a growth rate, not a
    relation to `bpsRatio`. The name and the "Hardy–Ramanujan formula" attribution in the
    original comment are not backed by a citation in `papers/foundations/`; treat this
    definition as an unverified proposal (Tier C), not as an established asymptotic (Tier L). -/
noncomputable def bpsMultiplicity (n : ℕ) : ℝ :=
  Real.exp (4 * Real.pi * Real.sqrt n) / (n : ℝ) ^ (3 / 2 : ℝ)

end StringTheory.StringDynamics
