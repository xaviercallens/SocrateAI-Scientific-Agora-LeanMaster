/-
Stream 2 · The Dual-Scale bound on a `d`-torus.

The project's dual-scale principle (Stream 1: `DualScaleM24Formalization.DualScale.EffectiveMetric`,
`genesis_no_singularity`) is the circle statement `R_eff(R) = R + α'/R ≥ 2√α'`: no
T-duality-invariant scale can shrink below the string scale. This file proves the
`d`-dimensional generalization on the space of flat torus metrics.

Define the **dual scale** of a torus metric `G` as the trace of its generalized metric at
`B = 0`: `𝒟(G) = tr H(G,0) = tr G + tr G⁻¹` (Hull–Zwiebach eq. (2.17), see
`DFT.GeneralizedMetric`).

Tier A here, for every `d`:
* `𝒟(G⁻¹) = 𝒟(G)` — invariance under the full T-duality;
* `𝒟(G) ≥ 2d` for every positive-definite `G` — via `tr((G−1) G⁻¹ (G−1)) ≥ 0`, which
  expands to `tr G + tr G⁻¹ − 2d`; no eigenvalue decomposition needed;
* the bound is attained at the self-dual point `G = 1`, **and only there**: for positive-definite
  `G`, `𝒟(G) = 2d ↔ G = 1` (`dualScale_eq_iff`, added 2026-09-18);
* at `d = 1`, `G = R²`: `𝒟 = (R + 1/R)² − 2`, so the torus bound specializes to exactly the
  circle statement `R + 1/R ≥ 2` behind Stream 1's dual-scale principle.

Not claimed: any cosmological interpretation (Tier C in the project's own narrative).

### Physical background
On a circle of radius `R`, the T-duality-invariant "effective size" `R + α'/R` of the
compactification never falls below `2√α'`: shrinking the true geometric radius past the
string scale is indistinguishable, by every physical observable, from growing the dual
radius, so there is a duality-invariant minimal effective scale (this is the project's own
"dual-scale principle", not a named result from a single source; the underlying mass
formula and T-duality is the same one used throughout `DFT.GeneralizedMetric`, sourced from
Hull–Zwiebach eq. (2.17)). This file asks whether that bound is special to the circle or is
really a statement about the generalized metric `H(G,0)` on an arbitrary flat `d`-torus, by
defining a duality-invariant scalar built from `H` (its trace) and bounding it.

### Mathematical content
Defines `dualScale G := tr H(G,0)`, a scalar function of the torus metric `G` alone (no
`B`-field dependence — the whole point is a bound that survives even without flux). Proves
`dualScale_eq` (`𝒟(G) = tr G + tr G⁻¹`, unwinding the block trace), `dualScale_inv`
(`𝒟(G⁻¹) = 𝒟(G)`, i.e. `𝒟` really is a T-duality invariant, not just built from one),
`dualScale_ge` (`𝒟(G) ≥ 2d` for every positive-definite `G` — the `d`-dimensional bound),
`dualScale_one` (the bound is attained, at the self-dual point `G = 1`), `dualScale_circle`
(the `d = 1` formula `𝒟(R²) = (R+1/R)² − 2`), and `circle_effective_scale_ge_two`
(`dualScale_ge` and `dualScale_circle` combined at `d = 1` reproduce exactly `R + 1/R ≥ 2`,
Stream 1's circle statement, as a genuine corollary rather than a re-proof from scratch).
**Not proved here**: that `𝒟(G)` (rather than, say, `√(𝒟(G))` or some other duality
invariant built from `H`) is the physically preferred measure of compactification size for
`d > 1`; nothing about the bound with `B ≠ 0`; and, per the module comment, no claim that
the bound plays any cosmological role — that reading is explicitly Tier C.

### Proof techniques
`dualScale_ge` is the one substantial proof: it avoids diagonalizing `G` by instead showing
`tr((G−1) G⁻¹ (G−1)) ≥ 0` — a trace of a matrix sandwiched as `Mᴴ (PSD) M`, hence positive
semidefinite, hence with a nonnegative trace — and then expanding that trace algebraically
(using `G⁻¹G = GG⁻¹ = 1`) into `tr G + tr G⁻¹ − 2d`. `dualScale_one`/`dualScale_circle` are
direct `simp`/`field_simp`/`ring` computations from `dualScale_eq`.

### Related declarations
`dualScale` is built directly from `DFT.GeneralizedMetric.genMetric`, of which `dualScale G
= (genMetric G 0).trace` is a **derived scalar invariant** (same underlying object, coarser
information). `circle_effective_scale_ge_two` is the **same statement**, re-derived here as
a `d = 1` corollary, as Stream 1's own circle dual-scale principle in
`DualScaleM24Formalization.DualScale.EffectiveMetric`/`genesis_no_singularity` (named
explicitly in the module comment above) — an independent, more general route to a fact
Stream 1 established directly on the circle. `dualScale_one` (the bound attained at the
self-dual metric) is conceptually the same phenomenon as
`DualScaleValidation.UseCase1.self_dual_is_global_minimum` /
`DoubleFieldTheory.PhysicsDSL.dsl_self_dual_minimum` (atlas similarity 0.461: "self-dual
point is a minimum/extremum"), but those are proved for a different toy potential in a
different library — a related fact about self-duality, not a shared dependency.
-/
import DualScaleStream2.DFT.GeneralizedMetric
import Mathlib.LinearAlgebra.Matrix.PosDef
import Mathlib.Analysis.Matrix.PosDef

namespace DualScaleStream2.DualScale

open Matrix DualScaleStream2.DFT

variable {d : ℕ}

/-- Dual scale `𝒟(G) = tr H(G, 0)`. -/
noncomputable def dualScale (G : Matrix (Fin d) (Fin d) ℝ) : ℝ := (genMetric G 0).trace

/-- Unwinding the block-diagonal structure of `H(G,0) = diag(G, G⁻¹)`: the trace of the
whole generalized metric is just `tr G + tr G⁻¹`, with no cross-terms from the vanishing
off-diagonal blocks. -/
theorem dualScale_eq (G : Matrix (Fin d) (Fin d) ℝ) :
    dualScale G = G.trace + G⁻¹.trace := by
  simp [dualScale, genMetric, Matrix.mul_apply, Matrix.one_apply, Matrix.conjTranspose_apply]
  <;>
    simp_all [Matrix.trace, Matrix.mul_apply, Finset.sum_apply, Finset.sum_apply]
  <;>
    rfl

/-- **T-duality invariance.** Swapping `G` for its inverse (the full T-duality on the
`d`-torus, `DFT.tduality_inverts_metric`) leaves the dual scale unchanged: `𝒟` is a genuine
duality invariant, not just a formula that happens to appear in a duality-covariant theory.
Proved by substituting `(G⁻¹)⁻¹ = G` and observing `dualScale_eq` is then symmetric in the
two summands. -/
theorem dualScale_inv (G : Matrix (Fin d) (Fin d) ℝ) (hG : IsUnit G.det) :
    dualScale G⁻¹ = dualScale G := by
  rw [dualScale_eq, dualScale_eq]
  have h_inv_inv : (G⁻¹)⁻¹ = G := Matrix.nonsing_inv_nonsing_inv G hG
  rw [h_inv_inv]
  ring

/-- **Dual-scale bound** on the space of torus metrics: for every positive-definite `G`,
`tr G + tr G⁻¹ ≥ 2d`. Physically, this is the statement that no choice of torus shape can
make the T-duality-invariant "size" `𝒟(G)` smaller than its value `2d` at the self-dual
point `G = 1`. The proof idea: `tr((G−1) G⁻¹ (G−1)) ≥ 0` because it is the trace of a matrix
sandwiched by the positive-semidefinite `G⁻¹`, and expanding that same trace algebraically
gives `tr G + tr G⁻¹ − 2d` — so no eigenvalues of `G` are ever computed. -/
theorem dualScale_ge (G : Matrix (Fin d) (Fin d) ℝ) (hG : G.PosDef) :
    (2 * d : ℝ) ≤ dualScale G := by
  rw [dualScale_eq]
  -- positive-definite matrices are in particular invertible, which every step below needs.
  have hdet : IsUnit G.det := G.isUnit_iff_isUnit_det.mp hG.isUnit
  have hl : G⁻¹ * G = 1 := Matrix.nonsing_inv_mul G hdet
  have hr : G * G⁻¹ = 1 := Matrix.mul_nonsing_inv G hdet
  -- the inverse of a positive-definite matrix is itself positive-semidefinite; this is
  -- what will make the sandwich construction below nonnegative.
  have hGinv_psd : G⁻¹.PosSemidef := hG.posSemidef.inv
  -- over ℝ, "Hermitian" (`ᴴ`) is just "symmetric" (`ᵀ`); record G and (G-1) as such,
  -- since `PosSemidef.conjTranspose_mul_mul_same` is phrased with `ᴴ`.
  have hGT : Gᵀ = G := (Matrix.conjTranspose_eq_transpose_of_trivial G).symm.trans hG.isHermitian
  have hMh : (G - 1)ᴴ = G - 1 := by
    rw [Matrix.conjTranspose_eq_transpose_of_trivial, Matrix.transpose_sub,
      Matrix.transpose_one, hGT]
  -- (G-1)ᴴ · G⁻¹ · (G-1) is a "sandwich" Mᴴ·(PSD)·M, hence positive-semidefinite,
  -- regardless of what M = (G-1) actually is.
  have hpsd : ((G - 1)ᴴ * G⁻¹ * (G - 1)).PosSemidef :=
    Matrix.PosSemidef.conjTranspose_mul_mul_same hGinv_psd (G - 1)
  rw [hMh] at hpsd
  -- a positive-semidefinite matrix has nonnegative trace — this is the one genuinely
  -- nontrivial input, and it is what replaces an eigenvalue argument.
  have htrace_nonneg : 0 ≤ ((G - 1) * G⁻¹ * (G - 1)).trace := hpsd.trace_nonneg
  -- expand the sandwich algebraically using G⁻¹G = GG⁻¹ = 1: it collapses to
  -- (G - 1) - (1 - G⁻¹), whose trace is exactly tr G + tr G⁻¹ - 2d below.
  have hexpand : (G - 1) * G⁻¹ * (G - 1) = (G - 1) - (1 - G⁻¹) := by
    rw [Matrix.sub_mul, Matrix.one_mul, Matrix.sub_mul, Matrix.mul_sub, Matrix.mul_sub]
    simp only [Matrix.mul_one]
    rw [hr, hl, Matrix.one_mul]
  rw [hexpand] at htrace_nonneg
  -- trace is additive/subtractive, and tr(1 : Matrix (Fin d) (Fin d) ℝ) = d (card of Fin d);
  -- read off 0 ≤ tr G + tr G⁻¹ - 2d, i.e. the desired bound.
  rw [Matrix.trace_sub, Matrix.trace_sub, Matrix.trace_sub, Matrix.trace_one] at htrace_nonneg
  simp only [Fintype.card_fin] at htrace_nonneg
  linarith

/-- The bound is attained at the self-dual metric. -/
theorem dualScale_one : dualScale (1 : Matrix (Fin d) (Fin d) ℝ) = 2 * d := by
  rw [dualScale_eq]
  simp [Matrix.trace_one, inv_one]
  ring

/-- **The self-dual metric is the unique minimizer.** For positive-definite `G`, the dual-scale
bound `𝒟(G) ≥ 2d` (`dualScale_ge`) is an equality **iff** `G = 1`.

Added 2026-09-18. Until then this library proved attainment only (`dualScale_one`), and paper 8
said so; an external review nevertheless read the bound as "minimized exactly at the self-dual
point" (`docs/reviews/2026-09-18_external_review_paper8.md`). Rather than only correct the
reading, this theorem makes it true.

Proof idea: equality forces `tr((G−1) G⁻¹ (G−1)) = 0`; that matrix is positive semidefinite, and a
positive-semidefinite matrix with zero trace is zero (`Matrix.PosSemidef.trace_eq_zero_iff`, which
rests on the spectral theorem — the one place this file now uses eigenvalues, inside Mathlib). Then
`xᵀ(G−1)ᵀ G⁻¹ (G−1)x = 0` for every `x`, and since `G⁻¹` is positive **definite** this forces
`(G−1)x = 0` for every `x`, i.e. `G = 1`.

Scope: a statement about real positive-definite matrices with `B = 0`. It says nothing about
`B ≠ 0`, and it does not make `𝒟` the physically preferred measure of size (Tier C, as in the
module docstring). -/
theorem dualScale_eq_iff (G : Matrix (Fin d) (Fin d) ℝ) (hG : G.PosDef) :
    dualScale G = 2 * d ↔ G = 1 := by
  constructor
  · intro h
    rw [dualScale_eq] at h
    have hdet : IsUnit G.det := G.isUnit_iff_isUnit_det.mp hG.isUnit
    have hl : G⁻¹ * G = 1 := Matrix.nonsing_inv_mul G hdet
    have hr : G * G⁻¹ = 1 := Matrix.mul_nonsing_inv G hdet
    have hGinv : G⁻¹.PosDef := hG.inv
    have hGT : Gᵀ = G := (Matrix.conjTranspose_eq_transpose_of_trivial G).symm.trans hG.isHermitian
    have hMh : (G - 1)ᴴ = G - 1 := by
      rw [Matrix.conjTranspose_eq_transpose_of_trivial, Matrix.transpose_sub,
        Matrix.transpose_one, hGT]
    have hpsd : ((G - 1)ᴴ * G⁻¹ * (G - 1)).PosSemidef :=
      Matrix.PosSemidef.conjTranspose_mul_mul_same hGinv.posSemidef (G - 1)
    have hexpand : (G - 1) * G⁻¹ * (G - 1) = (G - 1) - (1 - G⁻¹) := by
      rw [Matrix.sub_mul, Matrix.one_mul, Matrix.sub_mul, Matrix.mul_sub, Matrix.mul_sub]
      simp only [Matrix.mul_one]
      rw [hr, hl, Matrix.one_mul]
    -- equality in the bound says exactly that the sandwich has zero trace
    have htr0 : ((G - 1)ᴴ * G⁻¹ * (G - 1)).trace = 0 := by
      rw [hMh, hexpand, Matrix.trace_sub, Matrix.trace_sub, Matrix.trace_sub, Matrix.trace_one]
      simp only [Fintype.card_fin]
      linarith
    -- a positive-semidefinite matrix with zero trace is zero
    have hzero : (G - 1)ᴴ * G⁻¹ * (G - 1) = 0 := hpsd.trace_eq_zero_iff.mp htr0
    -- G⁻¹ is positive definite, so Mᴴ G⁻¹ M = 0 forces M = 0
    have hM : G - 1 = 0 := by
      by_contra hne
      obtain ⟨x, hx⟩ : ∃ x, (G - 1) *ᵥ x ≠ 0 := by
        by_contra hall
        push Not at hall
        exact hne (Matrix.ext fun i j => by
          have := congrFun (hall (Pi.single j 1)) i
          simpa using this)
      have hpos := hGinv.dotProduct_mulVec_pos hx
      have hq : star ((G - 1) *ᵥ x) ⬝ᵥ (G⁻¹ *ᵥ ((G - 1) *ᵥ x))
          = star x ⬝ᵥ (((G - 1)ᴴ * G⁻¹ * (G - 1)) *ᵥ x) := by
        simp only [star_mulVec, dotProduct_mulVec, vecMul_vecMul, Matrix.mul_assoc]
      rw [hq, hzero] at hpos
      simp at hpos
    exact sub_eq_zero.mp hM
  · rintro rfl; exact dualScale_one

/-- Circle case: `𝒟(R²) = (R + 1/R)² − 2`. -/
theorem dualScale_circle (R : ℝ) (hR : R ≠ 0) :
    dualScale (!![R ^ 2] : Matrix (Fin 1) (Fin 1) ℝ) = (R + R⁻¹) ^ 2 - 2 := by
  rw [dualScale_eq]
  have hinv : (!![R ^ 2] : Matrix (Fin 1) (Fin 1) ℝ)⁻¹ = !![(R ^ 2)⁻¹] := by
    rw [Matrix.inv_def, Matrix.det_fin_one_of, Matrix.adjugate_fin_one, Ring.inverse_eq_inv]
    ext i j
    fin_cases i <;> fin_cases j <;> simp
  rw [hinv]
  simp only [Matrix.trace_fin_one_of]
  field_simp
  ring

/-- **Specialization to Stream 1's dual-scale principle**: `R + 1/R ≥ 2` for `R > 0` —
    the `d = 1` content of `dualScale_ge` together with `dualScale_circle`. -/
theorem circle_effective_scale_ge_two (R : ℝ) (hR : 0 < R) : 2 ≤ R + R⁻¹ := by
  have h : R + R⁻¹ - 2 = (R - 1) ^ 2 / R := by field_simp; ring
  have h_nonneg : 0 ≤ (R - 1) ^ 2 / R := by
    apply div_nonneg
    · exact sq_nonneg (R - 1)
    · linarith
  linarith

end DualScaleStream2.DualScale
