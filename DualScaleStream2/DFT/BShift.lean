/-
Stream 2 · P2.4 — Integer B-field shifts are T-dualities of the generalized metric.

Sources (Tier L): Giveon–Porrati–Rabinovici hep-th/9401139 §2.4 eq. (2.4.25)
(`papers/foundations/giveon_hep-th_9401139.txt`, lines 1355–1373): the Θ-shift
`g_Θ = [[I, Θ],[0, I]]` with integer antisymmetric Θ is "a symmetry of the spectrum … the
B-term … gives only topological contributions"; Hull–Zwiebach eq. (2.17) for `H(G, B)`.

Tier A here, every `d`, over `ℝ`: for invertible symmetric `G`, antisymmetric `B` and `Θ`,
    `g_Θ · H(G, B) · g_Θᵀ = H(G, B + Θ)`.
The convention was checked *before* formalization (sympy, `d = 2`, generic symbols): of
the four candidates `g Hgᵀ`/`gᵀHg` with `±Θ` in the upper or lower block, exactly this one
holds, so the sign/ordering here is not a guess.

Combined with `TDuality.thetaShift_isODD` (the Θ-shift lies in `O(d,d;ℤ)`) this says the
periodic identification `B ∼ B + Θ` of the B-field is an `O(d,d;ℤ)` duality of the DFT
background.

### Physical background
An integer antisymmetric shift of the `B`-field, `B ↦ B + Θ` with `Θᵀ = −Θ` and `Θ`
integer-valued, changes the string worldsheet action only by a total derivative and hence
by a multiple of `2π` in the path integral phase (Giveon–Porrati–Rabinovici §2.4, around
eq. (2.4.25), `papers/foundations/giveon_hep-th_9401139.txt` lines 1355–1373): it is
physically invisible, a "large gauge transformation" of the doubled background, realized as
the block matrix `g_Θ = [[I,Θ],[0,I]]` acting on the doubled charge/coordinate vector. This
file checks the DFT-side counterpart of that statement: that `g_Θ` acts on the generalized
metric `H(G,B)` exactly by shifting its `B`-argument.

### Mathematical content
Defines `thetaShiftR Θ`, the real block matrix `[[I,Θ],[0,I]]` (the field-theoretic, `ℝ`-
valued counterpart of `TDuality.thetaShift`, which is the same block pattern over `ℤ`).
Proves `genMetric_bshift`: for symmetric invertible `G`, antisymmetric `B` and antisymmetric
`Θ`, conjugating `H(G,B)` by `g_Θ` (as `g_Θ · H · g_Θᵀ`) gives exactly `H(G, B+Θ)`; the sign
and left/right placement of `g_Θ` in this identity is not a free choice — a preliminary
`sympy` check at `d = 2` with generic symbols (recorded in the module comment above) ruled
out the three other combinations of `g Hgᵀ`/`gᵀHg` with `±Θ`. Proves `thetaShiftR_preserves_eta`,
the real analogue of `TDuality.thetaShift_isODD`: `g_Θ` preserves the `O(d,d)` form `η`.
Proves `genMetric_bshift_cancel`, the purely algebraic fact that shifting by `Θ` then by
`−Θ` returns the original metric — this one needs no antisymmetry hypothesis on `Θ` at all,
since `B + Θ + (−Θ)` simplifies to `B` in any ring. **Not proved here**: that the shift is a
symmetry of the full string spectrum or path integral (that identification is Tier L, the
GPR argument quoted above) — only that it acts as claimed on the algebraic object `H`.

### Proof techniques
Same block-matrix method as `GeneralizedMetric.lean`: `fromBlocks_multiply`/`fromBlocks_transpose`
expose the product as a `2×2` block matrix, `fromBlocks_inj` reduces the goal to four scalar
block equations, each closed by ring/module normalization (`abel`) after substituting
`hΘ : Θᵀ = −Θ`.

### Related declarations
`thetaShiftR_preserves_eta` and `TDuality.thetaShift_isODD` are the atlas's most similar
pair originating from this file (dependency-Jaccard 0.694 with `TDuality.thetaShift_mul`,
and directly analogous statements to each other): the same shift, proved to preserve the
same bilinear form, once over `ℝ` (for the DFT metric) and once over `ℤ` (for the T-duality
group) — independent proofs of the same fact in two different rings, not one reused from
the other. `genMetric_bshift` depends on `DFT.GeneralizedMetric.genMetric`, a **special
case** of which (`B = 0`) is `tduality_inverts_metric` in that file.
-/
import DualScaleStream2.DFT.GeneralizedMetric

namespace DualScaleStream2.DFT

open Matrix DualScaleStream2.TDuality

variable {d : ℕ}

/-- Real Θ-shift `g_Θ = [[I, Θ],[0, I]]`. -/
noncomputable def thetaShiftR (Θ : Matrix (Fin d) (Fin d) ℝ) : Matrix (Charge d) (Charge d) ℝ :=
  fromBlocks 1 Θ 0 1

/-- **B-shift covariance.** Conjugating the generalized metric `H(G,B)` by the Θ-shift
`g_Θ` produces `H(G, B+Θ)`: acting with the large gauge transformation on the doubled
background is the same as shifting the `B`-field by `Θ` before building `H`. Proved by
reducing the `2×2` block-matrix identity to its four scalar blocks and simplifying each
with the antisymmetry of `B` and `Θ`. -/
theorem genMetric_bshift (G B Θ : Matrix (Fin d) (Fin d) ℝ) (hG : IsUnit G.det)
    (hGs : Gᵀ = G) (hB : Bᵀ = -B) (hΘ : Θᵀ = -Θ) :
    thetaShiftR Θ * genMetric G B * (thetaShiftR Θ)ᵀ = genMetric G (B + Θ) := by
  unfold thetaShiftR genMetric
  rw [fromBlocks_transpose, fromBlocks_multiply, fromBlocks_multiply, Matrix.transpose_one,
    Matrix.transpose_zero, hΘ]
  apply fromBlocks_inj.mpr
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- block₁₁
    simp only [Matrix.one_mul, Matrix.zero_mul, zero_add, Matrix.mul_one, Matrix.add_mul,
      Matrix.mul_add, Matrix.mul_assoc, Matrix.neg_mul, Matrix.mul_neg, neg_neg]
    abel
  · -- block₁₂
    simp only [Matrix.one_mul, Matrix.zero_mul, zero_add, Matrix.mul_one, Matrix.mul_zero,
      add_zero, Matrix.add_mul]
  · -- block₂₁
    simp only [Matrix.one_mul, Matrix.zero_mul, Matrix.mul_one, Matrix.mul_zero, add_zero,
      zero_add, Matrix.mul_add, Matrix.mul_neg, neg_add]
  · -- block₂₂
    simp only [Matrix.one_mul, Matrix.zero_mul, Matrix.mul_one, Matrix.mul_zero, add_zero,
      zero_add]

/-- The real Θ-shift preserves `η` (the real counterpart of `TDuality.thetaShift_isODD`). -/
theorem thetaShiftR_preserves_eta (Θ : Matrix (Fin d) (Fin d) ℝ) (hΘ : Θᵀ = -Θ) :
    (thetaShiftR Θ)ᵀ * etaR d * thetaShiftR Θ = etaR d := by
  unfold thetaShiftR etaR
  rw [fromBlocks_transpose, fromBlocks_multiply, fromBlocks_multiply, Matrix.transpose_one,
    Matrix.transpose_zero, hΘ]
  simp

/-- Shifting by `Θ` and then by `-Θ` returns the original background. This is pure ring
algebra (`B + Θ + (−Θ) = B` inside the `G − BG⁻¹B` block once distributed), needing no
antisymmetry hypothesis on `Θ` at all — unlike `genMetric_bshift`, which needs `Θᵀ = −Θ`
to identify the *conjugation* by `g_Θ` with this shift in the first place. -/
theorem genMetric_bshift_cancel (G B Θ : Matrix (Fin d) (Fin d) ℝ) :
    genMetric G (B + Θ + -Θ) = genMetric G B := by
  -- distribute (B+Θ-Θ)·G⁻¹·(B+Θ-Θ) and cancel the Θ/−Θ cross terms; the repeated
  -- simp/abel passes below are a robustness idiom (later passes clean up terms the
  -- earlier `simp` left in a form `abel` alone could not close), not separate proof steps.
  simp [genMetric, Matrix.mul_add, Matrix.add_mul, Matrix.mul_assoc]
  <;>
    abel
  <;>
    simp_all [Matrix.mul_assoc]
  <;>
    abel
  <;>
    simp_all [Matrix.mul_assoc]
  <;>
    abel

end DualScaleStream2.DFT
