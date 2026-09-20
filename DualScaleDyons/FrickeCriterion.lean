/-
G9 — the definiteness criterion used **before** the computation, on a proposal from outside.

G8 (`DefinitenessCriterion.lean`) tested G6's criterion — *arithmetic decides when, and only when, the physics
hands it a definite form* — against four cases whose answers were already known. That is confirmation, not a
test. A criterion is only worth something if it can be used **in advance**, on a question not yet settled, and if
it can come out wrong. This file is the first such use.

### The proposal, as received
An "arithmetic resonance" selection principle: the modular group's action lifts through `Sym²` from `SL(2)` on
the worldsheet to integer `3 × 3` isometries of a signature-`(2,1)` lattice; the Fricke involution `W_N` of a
flux `N` acts there by integer matrices; and therefore — the proposal concludes — **the K3 of our universe is the
unique surface whose transcendental lattice aligns with that lattice**, "crystallised by number theory, not by
dynamics".

### The prediction, made before checking
The lattice in question has signature `(2,1)`. It is **indefinite**. By the criterion, expect **no** unique
answer. Recorded here as a prediction because the point of a criterion is to be usable before the work.

### What is proved (Tier A)
The algebra of the proposal is correct, and is formalised:
* `sym2_isometry`: for every `2 × 2` integer matrix, `(Sym² M)ᵀ G₀ (Sym² M) = (det M)² · G₀`, where `G₀` is the
  discriminant form `b² − 4ac` on binary quadratic forms. So `det M = 1` gives an exact isometry
  (`sym2_isometry_of_sl2`), and `sym2_det` gives `det(Sym² M) = (det M)³`. This is the classical
  `SL(2) → SO(2,1)` lift, and it is a polynomial identity.
* `sym2_contravariant`, `sym2_not_covariant`: the lift is an **anti**-homomorphism,
  `Sym²(MM') = Sym²(M')Sym²(M)`, because `Sym²` acts by substitution into the form and substitution reverses
  composition. The covariant form is false, and the negative control exhibits a pair where it fails. This trap
  was flagged by the Stream 1 project and verified here before being adopted.
* `sym2_lifts_rank_two`: **the bridge `L₃ = Sym²(L₂)` stated as one theorem**, and built on
  `DualScaleStream2.TDuality.mul_jMat_mul_transpose` (`A J Aᵀ = det A · J`), which this repository already had.
  The rank-2 form is rescaled by `det A`, the rank-3 form by `(det A)²`, and the lift itself has determinant
  `(det A)³`: the exponents `1, 2, 3` are the whole content of the claim, and each is now checked.
* `fricke_involution`, `fricke_isometry`, `fricke_det`: on `Γ₀(N)`-forms `N a x² + b x y + c y²`, the Fricke
  involution acts on the coefficients by `(a, b, c) ↦ (c, −b, a)`, an **integer** matrix of determinant `1` which
  squares to the identity and is an exact isometry of the discriminant form `b² − 4Nac`, for every `N`.

**Amendment (recorded after reconciling with the source project, and it weakens what this file first said).**
An earlier version of this header stated flatly that "the lattice carrying that action is not `U ⊕ ⟨2N⟩`". That
is **too strong, and wrong as a general claim**. There are *two* rank-3 lattices in this story, both of signature
`(2,1)`, both carrying integer symmetric-square actions of `Γ₀(N)⁺`, and they are **not isomorphic**:

| lattice | determinant | where it comes from |
|---|---|---|
| `⟨1⟩ ⊕ U(2N)` | `−4N²` | the discriminant form `b² − 4Nac` on the coefficients of `Γ₀(N)`-forms — the coordinates used in this file |
| `U ⊕ ⟨2N⟩` | `−2N` | the transcendental lattice of an `Mₙ`-polarized K3 (Dolgachev) — the coordinates the source project uses |

The source project (`SocrateAI-DualScaleTopologicalUniverseModel-LeanProposal`, "Stream 1") builds its integer
representation `ρ` **on `U ⊕ ⟨2N⟩` directly**, and proves `ρᵀ T_N ρ = T_N` for `(ad − Nbc)² = 1`. That is
correct, and this file does not contradict it. What is refuted is the **conflation** in the directive as it
reached this repository, which named the discriminant form `b² − 4ac` *and* `U ⊕ ⟨2N⟩` as one lattice.

What is proved here, then, is a **distinctness** statement and not a refutation of anyone's construction:
* `det_gramN`, `det_uPlus2N`, `fricke_lattice_is_not_U_plus_2N`: determinants `−4N²` and `−2N` differ for every
  `N ≥ 1`, so the two lattices are not isomorphic. Two constructions, two objects, one name in the directive.
* `fricke_lattice_is_one_plus_U2N`: the lattice of *this* file's coordinates is `⟨1⟩ ⊕ U(2N)`, exhibited by an
  explicit basis change of determinant `1`.
* `gramN_indefinite`: it represents `+1` and `−4N`, so it is indefinite — the criterion's hypothesis.

**A caveat closed, in the other direction.** The source project records that its signature `(2,1)` is *asserted*,
not proved, and says it inherits that Tier L caveat from this repository. `uPlus2N_signature` and
`uPlus2N_diagonalises` close it: an explicit basis of index `2` diagonalises `U ⊕ ⟨2N⟩` as
`diag(2, 2N, −2)`, so for `N > 0` the signature is `(2,1)` — now Tier A, on both sides.

### The verdict (Tier C, and the prediction was right)
Indefinite, so no selection, and the geometry says exactly that. A rank-`3` transcendental lattice means Picard
number `ρ = 19`, not `20`; the surfaces with `ρ = 20` — the ones classified by their transcendental lattice, and
the ones physics calls *attractive* — are precisely the case this proposal does **not** reach
(Huybrechts, `huybrechts_K3Global.txt` ll. 16325–16332, Tier L). What the construction picks out is a
one-parameter family, a modular curve, not a surface.

### What would repair it, and where it lands
By the criterion: add a definiteness condition. Demanding `ρ = 20` makes the transcendental lattice rank `2` and
**positive definite**, and then the classification is by positive definite binary forms — finite at each
discriminant, with a smallest one. That is `AttractorCharges.discriminant_gap`: `D ≤ −3`, attained only by
`(1, 1, 1)`, `T_S = A₂`. **The repaired proposal reproduces the answer Stream 8 already has**, and it reaches it
from the modular side. That is the useful content of the proposal, and it is not the content it claimed.

### Deviations from the directive as received, and why
The directive asked for these files under `StringTheoryFoundation/`. They are lattice-and-K3 material and must sit
beside the criterion they test, which lives in `DualScaleDyons`; `StringTheoryFoundation` imports none of it. The
directive also asked to prove `Wᵀ G_N W = G_N` with `G_N = U ⊕ ⟨2N⟩`; that statement is false as written, and what
is proved instead is the same identity for the lattice that actually carries the action.
-/
import DualScaleDyons.AttractorCharges
import DualScaleStream2.TDuality.SL2Product

namespace DualScaleDyons.FrickeCriterion

open Matrix

/-- The quadratic form of a `3 × 3` Gram matrix. -/
def qform (G : Matrix (Fin 3) (Fin 3) ℤ) (v : Fin 3 → ℤ) : ℤ := v ⬝ᵥ (G *ᵥ v)

/-! ### The `Sym²` lift: `SL(2)` on the worldsheet to `SO(2,1)` on forms -/

/-- `Sym² M` acting on the coefficients `(a, b, c)` of `a x² + b x y + c y²`, for `M = ![![p, q], ![r, s]]`. -/
def sym2 (p q r s : ℤ) : Matrix (Fin 3) (Fin 3) ℤ :=
  !![p ^ 2,     p * r,         r ^ 2;
     2 * p * q, p * s + q * r, 2 * r * s;
     q ^ 2,     q * s,         s ^ 2]

/-- The discriminant form `b² − 4ac`. -/
def G0 : Matrix (Fin 3) (Fin 3) ℤ := !![0, 0, -2; 0, 1, 0; -2, 0, 0]

theorem G0_is_discriminant (a b c : ℤ) : qform G0 ![a, b, c] = b ^ 2 - 4 * (a * c) := by
  simp [qform, G0, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]
  ring

/-- **The lift is an isometry up to `(det M)²`.** A polynomial identity. -/
theorem sym2_isometry (p q r s : ℤ) :
    (sym2 p q r s)ᵀ * G0 * (sym2 p q r s) = ((p * s - q * r) ^ 2) • G0 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [sym2, G0, Matrix.mul_apply, Matrix.transpose_apply, Fin.sum_univ_succ] <;> ring

/-- For `M ∈ SL(2, ℤ)` it is an exact isometry: the classical `SL(2) → SO(2,1)`. -/
theorem sym2_isometry_of_sl2 (p q r s : ℤ) (h : p * s - q * r = 1) :
    (sym2 p q r s)ᵀ * G0 * (sym2 p q r s) = G0 := by
  rw [sym2_isometry, h]; simp

/-- **The lift is contravariant, and the covariant form is false.** `Sym²` acts by *substitution* into the form,
`Q ↦ Q ∘ M`, and substitution reverses composition: `(Q ∘ M') ∘ M = Q ∘ (M' M)`. So `M ↦ Sym² M` is an
**anti**-homomorphism — a right action — and any statement of the form `Sym²(MM') = Sym²(M)Sym²(M')` is wrong.
Flagged by the Stream 1 project; verified here before adopting. -/
theorem sym2_contravariant (p q r s p' q' r' s' : ℤ) :
    sym2 (p * p' + q * r') (p * q' + q * s') (r * p' + s * r') (r * q' + s * s')
      = sym2 p' q' r' s' * sym2 p q r s := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [sym2, Matrix.mul_apply, Fin.sum_univ_succ] <;> ring

/-- The negative control for the previous theorem, on an explicit non-commuting pair: with
`M = ![![1,1],![0,1]]` and `M' = ![![1,0],![1,1]]`, so that `M M' = ![![2,1],![1,1]]`, the contravariant identity
holds and the covariant one fails. Without this, the docstring above would be an assertion. -/
theorem sym2_not_covariant :
    sym2 2 1 1 1 = sym2 1 0 1 1 * sym2 1 1 0 1 ∧
      sym2 2 1 1 1 ≠ sym2 1 1 0 1 * sym2 1 0 1 1 := by
  refine ⟨by decide +kernel, by decide +kernel⟩

theorem sym2_det (p q r s : ℤ) : (sym2 p q r s).det = (p * s - q * r) ^ 3 := by
  simp [sym2, Matrix.det_fin_three]
  ring

/-- **The bridge `L₃ = Sym²(L₂)`, made literal, by reusing what this repository already proved.**
At rank 2 an integer matrix rescales the symplectic form by `det A` — that is
`DualScaleStream2.TDuality.mul_jMat_mul_transpose`, **reused here, not reproved**. Its symmetric square
rescales the signature-`(2,1)` discriminant form by `(det A)²`, and has determinant `(det A)³`. The three
exponents `1, 2, 3` are the entire content of the lift, and each is now a theorem. -/
theorem sym2_lifts_rank_two (p q r s : ℤ) :
    (!![p, q; r, s] : Matrix (Fin 2) (Fin 2) ℤ) * DualScaleStream2.TDuality.jMat *
        (!![p, q; r, s] : Matrix (Fin 2) (Fin 2) ℤ)ᵀ
        = (p * s - q * r) • DualScaleStream2.TDuality.jMat ∧
      (sym2 p q r s)ᵀ * G0 * (sym2 p q r s) = ((p * s - q * r) ^ 2) • G0 ∧
      (sym2 p q r s).det = (p * s - q * r) ^ 3 := by
  refine ⟨?_, sym2_isometry p q r s, sym2_det p q r s⟩
  have h := DualScaleStream2.TDuality.mul_jMat_mul_transpose (!![p, q; r, s])
  simpa [Matrix.det_fin_two_of] using h

/-! ### The Fricke involution on `Γ₀(N)`-forms -/

/-- The discriminant form `b² − 4Nac` of the forms `N a x² + b x y + c y²`. -/
def gramN (N : ℤ) : Matrix (Fin 3) (Fin 3) ℤ := !![0, 0, -2 * N; 0, 1, 0; -2 * N, 0, 0]

theorem gramN_is_discriminant (N a b c : ℤ) :
    qform (gramN N) ![a, b, c] = b ^ 2 - 4 * N * (a * c) := by
  simp [qform, gramN, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]
  ring

/-- The Fricke involution `τ ↦ −1/(Nτ)`, on coefficients: `(a, b, c) ↦ (c, −b, a)`. Integer, for every `N`. -/
def fricke : Matrix (Fin 3) (Fin 3) ℤ := !![0, 0, 1; 0, -1, 0; 1, 0, 0]

theorem fricke_involution : fricke * fricke = 1 := by decide +kernel

theorem fricke_det : fricke.det = 1 := by decide +kernel

/-- **`W_N` is an exact integer isometry** of the lattice that carries the action, for every `N`. -/
theorem fricke_isometry (N : ℤ) : frickeᵀ * gramN N * fricke = gramN N := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [fricke, gramN, Matrix.mul_apply, Matrix.transpose_apply, Fin.sum_univ_succ]

/-! ### Which lattice it is — and which it is not -/

/-- `U ⊕ ⟨2N⟩`, the lattice the proposal named. -/
def uPlus2N (N : ℤ) : Matrix (Fin 3) (Fin 3) ℤ := !![0, 1, 0; 1, 0, 0; 0, 0, 2 * N]

/-- `⟨1⟩ ⊕ U(2N)`, the lattice that actually carries the action. -/
def onePlusU2N (N : ℤ) : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 0, 2 * N; 0, 2 * N, 0]

theorem det_gramN (N : ℤ) : (gramN N).det = -4 * N ^ 2 := by
  simp [gramN, Matrix.det_fin_three]; ring

theorem det_uPlus2N (N : ℤ) : (uPlus2N N).det = -2 * N := by
  simp [uPlus2N, Matrix.det_fin_three]

theorem det_onePlusU2N (N : ℤ) : (onePlusU2N N).det = -4 * N ^ 2 := by
  simp [onePlusU2N, Matrix.det_fin_three]; ring

/-- **The two lattices are distinct.** Determinants `−4N²` and `−2N` differ for every `N ≥ 1`, so no change of
basis takes one to the other. This refutes the *conflation* of the two under one name, not either construction:
each carries its own integer `Γ₀(N)⁺` action. -/
theorem fricke_lattice_is_not_U_plus_2N (N : ℤ) (hN : 1 ≤ N) :
    (gramN N).det ≠ (uPlus2N N).det := by
  rw [det_gramN, det_uPlus2N]
  intro h
  nlinarith

/-- The change of basis `(a, b, c) ↦ (b, a, −c)`, of determinant `1`. -/
def toOnePlusU2N : Matrix (Fin 3) (Fin 3) ℤ := !![0, 1, 0; 1, 0, 0; 0, 0, -1]

theorem toOnePlusU2N_det : toOnePlusU2N.det = 1 := by decide +kernel

/-- **The correct identification**, exhibited rather than asserted. -/
theorem fricke_lattice_is_one_plus_U2N (N : ℤ) :
    toOnePlusU2Nᵀ * gramN N * toOnePlusU2N = onePlusU2N N := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [toOnePlusU2N, gramN, onePlusU2N, Matrix.mul_apply, Matrix.transpose_apply,
      Fin.sum_univ_succ]

/-- A basis of index `2` diagonalising `U ⊕ ⟨2N⟩`: the columns are `e + f`, `w`, `e − f`. -/
def diagBasis : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 1; 1, 0, -1; 0, 1, 0]

theorem diagBasis_det : diagBasis.det = 2 := by decide +kernel

/-- **`U ⊕ ⟨2N⟩` diagonalises as `diag(2, 2N, −2)`** on a sublattice of index `2`. -/
theorem uPlus2N_diagonalises (N : ℤ) :
    diagBasisᵀ * uPlus2N N * diagBasis = !![2, 0, 0; 0, 2 * N, 0; 0, 0, -2] := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [diagBasis, uPlus2N, Matrix.mul_apply, Matrix.transpose_apply, Fin.sum_univ_succ]

/-- **Signature `(2,1)` for `U ⊕ ⟨2N⟩`, `N > 0` — now proved, not asserted.** Two independent directions of
positive norm and one of negative norm, pairwise orthogonal. The source project records this signature as an
assertion inherited from this repository's Tier L caveat; this closes it. -/
theorem uPlus2N_signature (N : ℤ) (hN : 0 < N) :
    qform (uPlus2N N) ![1, 1, 0] = 2 ∧ qform (uPlus2N N) ![0, 0, 1] = 2 * N ∧
      qform (uPlus2N N) ![1, -1, 0] = -2 ∧ 0 < 2 * N := by
  refine ⟨?_, ?_, ?_, by linarith⟩ <;>
    · simp [qform, uPlus2N, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]

/-- **The criterion's hypothesis, checked**: the lattice is indefinite, representing `+1` and `−4N`. -/
theorem gramN_indefinite (N : ℤ) (hN : 0 < N) :
    qform (gramN N) ![0, 1, 0] = 1 ∧ qform (gramN N) ![1, 0, 1] = -4 * N ∧ -4 * N < 0 := by
  refine ⟨?_, ?_, by linarith⟩ <;>
    · simp [qform, gramN, Matrix.mulVec, dotProduct, Fin.sum_univ_succ] <;> ring

/-- **G9 in one statement.** The algebra of the proposal holds; the lattice it names is the wrong one; and the
lattice that carries the action is indefinite — so the criterion of G6/G8 predicts no selection, correctly. -/
theorem g9_verdict (N : ℤ) (hN : 1 ≤ N) :
    frickeᵀ * gramN N * fricke = gramN N ∧
      fricke * fricke = 1 ∧
      (gramN N).det ≠ (uPlus2N N).det ∧
      qform (gramN N) ![0, 1, 0] = 1 ∧ qform (gramN N) ![1, 0, 1] = -4 * N :=
  ⟨fricke_isometry N, fricke_involution, fricke_lattice_is_not_U_plus_2N N hN,
    (gramN_indefinite N (by linarith)).1, (gramN_indefinite N (by linarith)).2.1⟩

end DualScaleDyons.FrickeCriterion
