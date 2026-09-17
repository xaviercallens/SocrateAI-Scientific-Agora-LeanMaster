/-
Stream 2 · P2.4 — The DFT generalized metric on a `d`-torus.

Source (Tier L): Hull & Zwiebach, *Double Field Theory*, arXiv:0904.4664, eq. (2.17)
(`papers/foundations/hull_zwiebach_0904_4664.txt`, lines 662–672):
`H(E) = [[G − B G⁻¹ B, B G⁻¹], [−G⁻¹ B, G⁻¹]]` with `E = G + B`, acting on the column
vector `(X', P)`, and "The matrix H(E) satisfies the constraint H⁻¹ = ηHη."

Tier A here (over `ℝ`, every `d`):
* `(ηH)² = 1` — Hull–Zwiebach's constraint — needing only `G` invertible (no symmetry or
  antisymmetry of `B` is used; this is sharper than the source states);
* `H` is symmetric when `G` is symmetric and `B` antisymmetric;
* at `B = 0` the full duality conjugates `G ↦ G⁻¹` (T-duality is metric inversion);
* the mass form `Zᵀ H Z` is covariant under any `g` with `gᵀ η g = η`;
* at `d = 1`, `G = R²`, `B = 0`, the mass form reproduces Stream 1's
  `TDuality.momentumMassSq` (up to its factor 2) — so Stream 2's DFT layer and
  Stream 1's circle computation are proved to be the same physics, not merely analogous.

Ordering note: Hull–Zwiebach order the doubled vector as `(X', P)` = (winding, momentum);
the generalized metric's `G` block pairs with winding.

### Physical background
In closed-string compactification on a `d`-torus, the low-energy fields are a metric `G`
and a Kalb–Ramond `B`-field on the torus; the string spectrum only depends on them through
the combination `E = G + B`. Double Field Theory doubles the torus coordinates
(`x`, winding-conjugate; `x̃`, momentum-conjugate) and packages `G` and `B` into a single
`2d × 2d` "generalized metric" `H(G,B)` acting on the doubled momentum/winding vector, so
that the closed-string mass and the T-duality group `O(d,d;ℤ)` act on `H` in one uniform,
manifestly covariant way (Hull–Zwiebach §2.2–2.3, around eq. (2.17),
`papers/foundations/hull_zwiebach_0904_4664.txt` lines 640–672). `H` is not itself a metric
on physical spacetime; it is a bookkeeping device on the doubled torus fiber, one instance
per point of the (undoubled) low-energy moduli space.

### Mathematical content
Defines `etaR d : Matrix (Charge d) (Charge d) ℝ`, the real `O(d,d)` form `[[0,I],[I,0]]`
(the field-theoretic counterpart of `TDuality.eta`, which is the same block matrix over `ℤ`),
and `genMetric G B`, the block matrix of eq. (2.17) for arbitrary real `G B : Matrix (Fin d)
(Fin d) ℝ` (no symmetry hypothesis is baked into the definition itself — symmetry is a
hypothesis of the theorems that need it). Proves: `etaR_mul_self` (`η` is an involution);
`etaR_genMetric_sq`, the Hull–Zwiebach constraint `H⁻¹ = ηHη` rewritten as `(ηH)² = 1`, valid
whenever `G` is invertible, with no hypothesis on `B` at all; `genMetric_symm`, that `H` is
symmetric under the physically expected hypotheses `Gᵀ = G`, `Bᵀ = −B`; `tduality_inverts_metric`,
that conjugating `H(G,0)` by the full duality `η` gives exactly `H(G⁻¹,0)`; `massForm` (the
scalar `Zᵀ H Z`) and its covariance `massForm_covariant` under any `g` preserving `η`; and
`massForm_circle`, the `d = 1`, `B = 0` specialization, identified on the nose (up to the
factor of 2 already present in Stream 1's convention) with Stream 1's circle mass formula
`StringTheory.UseCases.TDuality.momentumMassSq`. **Not proved here**: any dynamics for `H`
(no equations of motion, no dependence on the doubled coordinates, no Courant bracket — that
structure lives in `DoubleFieldTheory.CourantAlgebroid`, a different formalization); that
`O(d,d;ℝ)` covariance extends to the *continuous* group beyond the single matrix identity
checked in `massForm_covariant`; and nothing about the section condition, which is the
subject of `DFT.SectionCondition`.

### Proof techniques
Every identity is a `2×2` block-matrix computation: `unfold` the definitions to expose
`fromBlocks`, multiply blocks with `Matrix.fromBlocks_multiply` (or transpose with
`fromBlocks_transpose`), and close a block-matrix equality with `fromBlocks_inj` — which
reduces it to four independent scalar (in the matrix-ring sense) equations, one per block,
each then closed by `ring`/`abel`-style rewriting using only `G⁻¹ * G = 1` and
`G * G⁻¹ = 1`. `massForm_circle` additionally handles the `1 × 1` case explicitly (matrices
`!![_]`) and threads a cast from `ℚ` (Stream 1's convention) to `ℝ`.

### Related declarations
`genMetric` is a hub used directly by 7 theorems in this project (`etaR_genMetric_sq`,
`genMetric_bshift`, `genMetric_bshift_cancel`, `genMetric_symm`, `massForm_circle`,
`tduality_inverts_metric`, and `DualScale.dualScale`, which takes `genMetric`'s trace —
see `DualScale.TraceBound`, a **special case** of this file's object). `massForm_circle` is
the atlas's only recorded cross-library bridge out of this file: it is proved equal (as a
number, up to the stated factor) to `StringTheory.UseCases.TDuality.leftMomentum`,
`rightMomentum` and `momentumMassSq` — the **same physical quantity**, computed two ways in
two independently developed libraries, not a re-proof of the same Lean statement. Within
this file, `etaR_mul_self` and the eta-preservation lemmas of `DFT.BShift` share the same
underlying `fromBlocks` computation on `etaR`; `DFT.SectionCondition` reuses `Charge d` and
the integer analogue `eta d` on the charge lattice rather than on the moduli-space metric.
-/
import DualScaleStream2.TDuality.ODD
import StringTheoryFormalization.UseCases.TDualityMassSpectrum
import Mathlib.LinearAlgebra.Matrix.NonsingularInverse
import Mathlib.Data.Real.Basic

namespace DualScaleStream2.DFT

open Matrix DualScaleStream2.TDuality

variable {d : ℕ}

/-- Real `O(d,d)` form `η = [[0, I],[I, 0]]`. -/
noncomputable def etaR (d : ℕ) : Matrix (Charge d) (Charge d) ℝ := fromBlocks 0 1 1 0

/-- Hull–Zwiebach generalized metric `H(G, B)`, eq. (2.17). -/
noncomputable def genMetric (G B : Matrix (Fin d) (Fin d) ℝ) : Matrix (Charge d) (Charge d) ℝ :=
  fromBlocks (G - B * G⁻¹ * B) (B * G⁻¹) (-(G⁻¹ * B)) G⁻¹

/-- `η² = 1` over `ℝ`: the O(d,d) form, read as a linear map swapping the momentum and
winding blocks, is its own inverse. Physically, `η` is the full T-duality `n ↔ w`, and
applying it twice returns the original frame. -/
theorem etaR_mul_self : etaR d * etaR d = 1 := by
  unfold etaR
  rw [fromBlocks_multiply]
  simp

/-- **Hull–Zwiebach constraint** `H⁻¹ = ηHη`, in the form `(ηH)(ηH) = 1`. -/
theorem etaR_genMetric_sq (G B : Matrix (Fin d) (Fin d) ℝ) (hG : IsUnit G.det) :
    (etaR d * genMetric G B) * (etaR d * genMetric G B) = 1 := by
  have hl : G⁻¹ * G = 1 := Matrix.nonsing_inv_mul G hG
  have hr : G * G⁻¹ = 1 := Matrix.mul_nonsing_inv G hG
  have hM : etaR d * genMetric G B
      = fromBlocks (-(G⁻¹ * B)) G⁻¹ (G - B * G⁻¹ * B) (B * G⁻¹) := by
    unfold etaR genMetric
    rw [fromBlocks_multiply]
    simp
  rw [hM, fromBlocks_multiply]
  rw [show (1 : Matrix (Charge d) (Charge d) ℝ) = fromBlocks 1 0 0 1 from fromBlocks_one.symm]
  apply fromBlocks_inj.mpr
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- block₁₁ : -(G⁻¹*B) * -(G⁻¹*B) + G⁻¹ * (G - B*G⁻¹*B) = 1
    simp only [neg_mul_neg, Matrix.mul_sub, mul_assoc, hl]
    abel
  · -- block₁₂ : -(G⁻¹*B) * G⁻¹ + G⁻¹ * (B*G⁻¹) = 0
    simp only [neg_mul, mul_assoc]
    abel
  · -- block₂₁ : (G-B*G⁻¹*B) * -(G⁻¹*B) + (B*G⁻¹) * (G-B*G⁻¹*B) = 0
    have hGB : G * (G⁻¹ * B) = B := by rw [← mul_assoc, hr, one_mul]
    simp only [mul_neg, Matrix.sub_mul, Matrix.mul_sub, mul_assoc, hl, hGB, mul_one]
    abel
  · -- block₂₂ : (G-B*G⁻¹*B) * G⁻¹ + (B*G⁻¹) * (B*G⁻¹) = 1
    simp only [Matrix.sub_mul, mul_assoc, hr]
    abel

/-- If the background metric `G` is symmetric and the `B`-field is antisymmetric (the
physically required reality conditions), the generalized metric `H(G,B)` is a symmetric
matrix, as it must be to define a (indefinite) inner product on the doubled tangent space. -/
theorem genMetric_symm (G B : Matrix (Fin d) (Fin d) ℝ) (hG : IsUnit G.det)
    (hGs : Gᵀ = G) (hB : Bᵀ = -B) : (genMetric G B)ᵀ = genMetric G B := by
  have hGinv : (G⁻¹)ᵀ = G⁻¹ := by rw [Matrix.transpose_nonsing_inv, hGs]
  unfold genMetric
  rw [fromBlocks_transpose]
  apply fromBlocks_inj.mpr
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- (G - B*G⁻¹*B)ᵀ = G - B*G⁻¹*B
    rw [Matrix.transpose_sub, hGs, Matrix.transpose_mul, Matrix.transpose_mul, hB, hGinv]
    simp only [mul_neg, neg_mul, neg_neg, mul_assoc]
  · -- (-(G⁻¹*B))ᵀ = B*G⁻¹
    rw [Matrix.transpose_neg, Matrix.transpose_mul, hGinv, hB]
    simp only [neg_mul, neg_neg]
  · -- (B*G⁻¹)ᵀ = -(G⁻¹*B)
    rw [Matrix.transpose_mul, hGinv, hB, mul_neg]
  · -- (G⁻¹)ᵀ = G⁻¹
    exact hGinv

/-- **T-duality is metric inversion**: conjugating by the full duality maps `H(G,0)` to
    `H(G⁻¹,0)`. -/
theorem tduality_inverts_metric (G : Matrix (Fin d) (Fin d) ℝ) (hG : IsUnit G.det) :
    etaR d * genMetric G 0 * etaR d = genMetric G⁻¹ 0 := by
  -- (G⁻¹)⁻¹ = G, needed to recognise the right-hand side as a block matrix in `G`.
  have hGG : G⁻¹⁻¹ = G := Matrix.nonsing_inv_nonsing_inv G hG
  -- at B = 0 the generalized metric is simply block-diagonal `diag(G, G⁻¹)` …
  have hL : genMetric G 0 = fromBlocks G 0 0 G⁻¹ := by
    unfold genMetric
    simp
  -- … and likewise for `G⁻¹` in place of `G`, using `hGG` to simplify `(G⁻¹)⁻¹`.
  have hR : genMetric G⁻¹ 0 = fromBlocks G⁻¹ 0 0 G := by
    unfold genMetric
    simp [hGG]
  rw [hL, hR]
  -- η, applied on both sides of a block-diagonal matrix, swaps its two diagonal blocks.
  unfold etaR
  rw [mul_assoc, fromBlocks_multiply, fromBlocks_multiply]
  simp

/-- Mass form `Zᵀ H Z`. -/
noncomputable def massForm (H : Matrix (Charge d) (Charge d) ℝ) (Z : Charge d → ℝ) : ℝ :=
  Z ⬝ᵥ (H *ᵥ Z)

/-- **Covariance**: transforming the background by `g` is the same as transforming the
    charge vector by `g`. -/
theorem massForm_covariant (g H : Matrix (Charge d) (Charge d) ℝ) (Z : Charge d → ℝ) :
    massForm (gᵀ * H * g) Z = massForm H (g *ᵥ Z) := by
  unfold massForm
  rw [show (gᵀ * H * g) *ᵥ Z = gᵀ *ᵥ (H *ᵥ (g *ᵥ Z)) by
    rw [← Matrix.mulVec_mulVec, ← Matrix.mulVec_mulVec]]
  rw [Matrix.dotProduct_transpose_mulVec, dotProduct_comm]

/-- **Cross-link to Stream 1.** On a circle of radius `R` (`G = R²`, `B = 0`), with winding
    `w` and momentum `n`, the DFT mass form equals half of Stream 1's
    `momentumMassSq n w R = P_L² + P_R²`. -/
theorem massForm_circle (n w R : ℚ) (hR : R ≠ 0) :
    massForm (genMetric (d := 1) (!![((R : ℝ) ^ 2)]) 0) (Sum.elim ![(w : ℝ)] ![(n : ℝ)]) =
      ((StringTheory.UseCases.TDuality.momentumMassSq n w R : ℚ) : ℝ) / 2 := by
  -- cast the hypothesis R ≠ 0 (over ℚ, Stream 1's convention) to ℝ, and square it,
  -- since G = R² is what actually needs to be invertible here.
  have hR' : (R : ℝ) ≠ 0 := by exact_mod_cast hR
  have hR2 : ((R : ℝ) ^ 2) ≠ 0 := pow_ne_zero 2 hR'
  -- the 1×1 matrix inverse of R² is literally 1/R², computed via the Cramer/adjugate formula.
  have hinv : (!![((R : ℝ) ^ 2)] : Matrix (Fin 1) (Fin 1) ℝ)⁻¹ = !![((R : ℝ) ^ 2)⁻¹] := by
    rw [Matrix.inv_def, Matrix.det_fin_one_of, Matrix.adjugate_fin_one, Ring.inverse_eq_inv]
    ext i j
    fin_cases i <;> fin_cases j <;> simp
  -- at B = 0, `genMetric` is exactly the block-diagonal `diag(G, G⁻¹)` of the definition,
  -- which for d = 1 reduces to the two 1×1 blocks R² and 1/R².
  have hgm : genMetric (d := 1) (!![((R : ℝ) ^ 2)]) 0
      = fromBlocks !![((R : ℝ) ^ 2)] 0 0 !![((R : ℝ) ^ 2)⁻¹] := by
    unfold genMetric
    simp [hinv]
  rw [hgm]
  -- expand the mass form Zᵀ H Z along the block structure of H and of Z = (w, n);
  -- the off-diagonal (zero) blocks drop out, leaving one term for winding and one for momentum.
  unfold massForm
  rw [fromBlocks_mulVec]
  simp only [Sum.elim_comp_inl, Sum.elim_comp_inr, Matrix.zero_mulVec, add_zero, zero_add]
  rw [sumElim_dotProduct_sumElim]
  -- evaluate each 1-dimensional dot product/mulVec explicitly: R² w² and n²/R².
  have e1 : (![(w : ℝ)] ⬝ᵥ (!![((R : ℝ) ^ 2)] *ᵥ ![(w : ℝ)])) = (R : ℝ) ^ 2 * w ^ 2 := by
    simp [Matrix.mulVec, dotProduct]
    ring
  have e2 : (![(n : ℝ)] ⬝ᵥ (!![((R : ℝ) ^ 2)⁻¹] *ᵥ ![(n : ℝ)])) = ((R : ℝ) ^ 2)⁻¹ * n ^ 2 := by
    simp [Matrix.mulVec, dotProduct]
    ring
  rw [e1, e2]
  -- unfold Stream 1's momentumMassSq = leftMomentum² + rightMomentum² and match term by term;
  -- push_cast/field_simp/ring close the resulting rational-function identity over ℝ.
  unfold StringTheory.UseCases.TDuality.momentumMassSq
    StringTheory.UseCases.TDuality.leftMomentum StringTheory.UseCases.TDuality.rightMomentum
  push_cast
  field_simp
  ring

end DualScaleStream2.DFT
