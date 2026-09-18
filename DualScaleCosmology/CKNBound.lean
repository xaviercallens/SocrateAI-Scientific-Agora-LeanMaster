/-
Stream 3 · The Cohen–Kaplan–Nelson micro/macro cutoff bound.

**Hypothesis under study (Tier C, `docs/STREAM3_WORKFLOW.md` §1):** a micro scale
`ℓ_micro ~ ℓ_P` and a macro scale `ℓ_macro ~ H₀⁻¹` are linked by "non-perturbative duality
transformations". This file formalizes the one piece of the literature that actually links a
UV (micro) cutoff to an IR (macro/cosmological) cutoff with a precise inequality — not a
duality, but a **bound**: Cohen–Kaplan–Nelson (CKN), "Effective Field Theory, Black Holes,
and the Cosmological Constant", `papers/foundations/hep-th_9803132.txt`.

### ⚠️ Correction, 2026-09-18 (caught during P3.3 numeric instantiation)
An earlier revision of this file (commit `2989a74`) stated eq. (2) as `L³Λ⁴ ≤ M_P²` — a
dimensionally inconsistent misreading of the paper's own garbled `pdftotext` extraction
(`L3 Λ4 <  2 \n LMP` on l. 77–78 of `hep-th_9803132.txt`, the exponent-2 line-break from the
PDF's own `M_P²` superscript colliding with the following `L` on re-flow). `[L³Λ⁴] = GeV`,
`[M_P²] = GeV²` — those cannot be compared. Re-reading the source with `-layout` gives the
actual eq. (2): **`L³Λ⁴ ≲ L·M_P²`** (l. 77–78), which is dimensionally consistent
(`[L·M_P²] = GeV⁻¹·GeV² = GeV¹`) and — dividing by `L > 0` — is exactly the well-known
"holographic dark energy" scaling `L²Λ⁴ ≤ M_P²`, i.e. `ρ_vac ~ Λ⁴ ≲ M_P²/L²`. The previous
version's two theorems (`ckn_L_le`, `ckn_Lambda_le`, solving the *wrong* inequality via
`Real.rpow` cube/fourth-roots) are replaced below by theorems for the *correct* inequality,
which — happily — need no `rpow` at all: `L²Λ⁴ ≤ M²` is literally `(LΛ²)² ≤ M²`, so `LΛ² ≤
M` follows from one `nlinarith` step, not a fractional-power rewrite. This is the exact
"read the source before citing it" failure this project has hit before (see
`SocrateAI-DualScaleTopologicalUniverseModel-LeanProposal`'s `Agora/Axioms/OBrien2016.lean`
docstring, errors E-007/E-010, for the same failure mode in a sibling project) — caught here
by re-deriving the numeric consequence (P3.3) rather than trusting the first transcription.

### Physical background (Tier L, CKN eq. (2), l. 77–78, and l. 80)
For an effective field theory in a box of size `L` with UV cutoff `Λ`, demanding no state
already collapsed to a black hole (Schwarzschild radius exceeding `L`) gives
`L³Λ⁴ ≲ L·M_P²` (l. 77–78, `M_P` the reduced Planck mass), i.e. `L²Λ⁴ ≲ M_P²`, so that "the
IR cutoff scales like `Λ⁻²`" (l. 80): the box size `L` cannot be chosen independently of the
UV cutoff `Λ`. CKN's own reading (l. 113–117) instantiates this with `L` at "the current
horizon size" — i.e. the macro/cosmological scale the Stream 3 hypothesis calls `ℓ_macro` —
and finds the implied UV cutoff `Λ ~ 10⁻²·⁵ eV`, a genuine micro/macro relation already in
the literature, 28 years before this project's hypothesis.

### What is and is not proved here (Tier A vs. Tier C)
Tier A: `ckn_bound` derives the simplified `L²Λ⁴ ≤ M²` from the paper's literal `L³Λ⁴ ≤
LM²` by cancelling `L`; `ckn_L_Lambda_sq_le` takes the (one-step) square root to get `LΛ² ≤ M`;
`ckn_L_le` and `ckn_Lambda_sq_le` solve that for each variable — no physics beyond CKN's own
eq. (2) algebra, and (per the correction above) no fractional powers needed.

**Not proved, and not claimed as anything beyond Tier C:** that the specific numbers
`ℓ_P` and `H₀⁻¹` from the Stream 3 hypothesis saturate this bound — that numeric check is
`DualScaleCosmology/CKNInstance.lean` (P3.3), which finds the bound is badly *violated* at
those values, not saturated; that this bound is a *duality* in the sense of Stream 1/2's
`O(d,d)` T-duality (it is a strict inequality with no natural involution, unlike
`ScaleFactorDuality.scaleFactorDual`); and nothing here says the two Tier A facts in this
library (`ScaleFactorDuality` and `CKNBound`) combine into a single micro/macro
correspondence — see `docs/STREAM3_WORKFLOW.md` §1.

### Proof technique
`ckn_bound` cancels the shared factor `L > 0` via `le_of_mul_le_mul_left`. `ckn_L_Lambda_sq_le`
turns `L²Λ⁴ ≤ M²` into `(LΛ²)² ≤ M²` and extracts `LΛ² ≤ M` by `nlinarith` on the sign of
`(LΛ² − M)(LΛ² + M) = (LΛ²)² − M² ≤ 0` together with `LΛ² + M > 0` — the standard
"`a² ≤ b² ∧ a + b > 0 → a ≤ b`" argument, avoiding `Real.sqrt`/`Real.rpow` machinery
entirely. `ckn_L_le`/`ckn_Lambda_sq_le` are then a single `le_div_iff₀` each.
-/
import Mathlib.Analysis.SpecialFunctions.Pow.NNReal

namespace DualScaleCosmology.CKNBound

/-- **CKN bound, paper form → simplified form** (eq. (2), l. 77–78: `L³Λ⁴ ≲ L·M_P²`,
divided by `L > 0`): the well-known holographic-dark-energy scaling `L²Λ⁴ ≤ M_P²`. -/
theorem ckn_bound (L Λ M : ℝ) (hL : 0 < L) (h : L ^ 3 * Λ ^ 4 ≤ L * M ^ 2) :
    L ^ 2 * Λ ^ 4 ≤ M ^ 2 := by
  have h' : L * (L ^ 2 * Λ ^ 4) ≤ L * M ^ 2 := by nlinarith [h]
  exact le_of_mul_le_mul_left h' hL

/-- The simplified bound `L²Λ⁴ ≤ M²`, i.e. `(LΛ²)² ≤ M²`, gives `LΛ² ≤ M` directly (no
fractional powers needed, since the combination `LΛ²` is exactly what gets squared). -/
theorem ckn_L_Lambda_sq_le (L Λ M : ℝ) (hL : 0 < L) (hΛ : 0 < Λ) (hM : 0 < M)
    (h : L ^ 2 * Λ ^ 4 ≤ M ^ 2) : L * Λ ^ 2 ≤ M := by
  have hsq : (L * Λ ^ 2) ^ 2 ≤ M ^ 2 := by nlinarith [h]
  nlinarith [sq_nonneg (L * Λ ^ 2 - M), sq_nonneg (L * Λ ^ 2 + M), hsq,
    mul_pos hL (mul_pos hΛ hΛ)]

/-- **CKN bound, solved for the macro/IR scale `L`**: fixing a UV cutoff `Λ` caps how large
the IR box `L` can be — the direction CKN themselves use (l. 113–117). -/
theorem ckn_L_le (L Λ M : ℝ) (_hL : 0 < L) (hΛ : 0 < Λ) (_hM : 0 < M)
    (h : L * Λ ^ 2 ≤ M) : L ≤ M / Λ ^ 2 := by
  rw [le_div_iff₀ (by positivity)]
  linarith [h]

/-- **CKN bound, solved for the micro/UV cutoff `Λ`** (as `Λ²`, the natural combination this
bound constrains directly — see `docs/STREAM3_WORKFLOW.md` P3.3 for the further step to
`Λ` alone): fixing a macro scale `L` (e.g. "the current horizon size", CKN l. 113) caps
`Λ²`. -/
theorem ckn_Lambda_sq_le (L Λ M : ℝ) (hL : 0 < L) (_hΛ : 0 < Λ) (_hM : 0 < M)
    (h : L * Λ ^ 2 ≤ M) : Λ ^ 2 ≤ M / L := by
  rw [le_div_iff₀ hL]
  linarith [h]

end DualScaleCosmology.CKNBound
