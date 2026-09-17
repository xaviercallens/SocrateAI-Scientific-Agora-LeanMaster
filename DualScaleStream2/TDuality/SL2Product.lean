/-
Stream 2 · P2.2 — On `T²`, the τ-modular group commutes with the ρ-translations.

## Physical background
As in `Mirror.lean`, the `T²` moduli `(G_11, G_12, G_22, B_12)` organize into a
complex-structure modulus `τ` and a Kähler modulus `ρ = B + i√det G`. Source (Tier L):
Giveon–Porrati–Rabinovici hep-th/9401139, "The d = 2 Example"
(`papers/foundations/giveon_hep-th_9401139.txt`, lines 1874–1884): "the duality
symmetry group turns out to be isomorphic to `SL(2,Z) × SL(2,Z) ⊗S [Z2 × Z2]`" —
explicitly *not* a naive factorization of `O(2,2,Z)`, but for the two `SL(2,ℤ)`
factors: basis changes (`ODD.basisChange`) act on `τ`, and integer `B`-shifts
(`ODD.thetaShift`) are the translations `ρ ↦ ρ + t` (`t ∈ ℤ`, along the antisymmetric
direction `J`). This file checks, at the level of the `4×4` integer matrices acting on
charges, that these two actions commute when the `τ`-side transformation has
determinant `1` — the matrix-level fact underlying "the `τ`- and `ρ`-moduli spaces
factorize as independent `SL(2,ℤ)`s".

## Mathematical content
Deliberately narrower in scope than the full `SL(2,ℤ)_ρ` (which also contains the
inversion `ρ ↦ −1/ρ`, not treated here):
* `mul_jMat_mul_transpose`: for every `2×2` integer `A`, `A J Aᵀ = det(A) · J`, where
  `J = [[0,1],[-1,0]]` (this identity was checked with sympy before formalization);
* `basisChange_mul`: the basis changes `diag(A, B)` compose as `diag(AA', BB')` — they
  form a monoid under matrix multiplication (no inverses are asserted here);
* `thetaShift_mul`: the `Θ`-shifts compose additively, `thetaShift Θ · thetaShift Θ' =
  thetaShift (Θ + Θ')` — they form a group isomorphic to `(antisymmetric matrices, +)`;
* `basisChange_comm_thetaShift` (**main result**): a basis change `diag(A,B)` with
  `det A = 1` commutes with every `ρ`-translation `thetaShift (t • J)` — i.e.
  `SL(2,ℤ)_τ` and the `ρ`-translations generate a *commuting* product inside
  `O(2,2;ℤ)` (the sympy check that motivated this: the commutator of the two block
  matrices vanishes exactly when `det A = 1`).
Not claimed: the `ρ ↦ −1/ρ` generator, the full `SL(2,ℤ)_ρ`, or that the product here
is *all* of `O(2,2;ℤ)` (it plainly is not — `Factorized.factorized` is not covered).

## Proof techniques
`mul_jMat_mul_transpose` is a fixed `2×2` computation, closed by expanding the matrix
product entrywise (`fin_cases`) and then `ring_nf`/`aesop` to match the two sides
(`A.det` unfolds via `Matrix.det_fin_two`). `basisChange_mul` and `thetaShift_mul` are
general-`d` block-matrix identities, proved exactly as in `ODD.lean`
(`fromBlocks_multiply` plus `simp`/`ring`/`aesop` on the resulting blocks). The main
theorem, `basisChange_comm_thetaShift`, is a genuine multi-step derivation (not a
single rewrite): it first uses `hdet : A.det = 1` together with
`mul_jMat_mul_transpose` to get `A J Aᵀ = J`, then uses the compatibility hypothesis
`Aᵀ B = 1` to turn that into `A J = J B`, and only then expands both
`basisChange A B · thetaShift (t•J)` and the reverse product blockwise, where `hcomm`
closes every surviving block.

## Related declarations
* `basisChange_comm_thetaShift` is the `SL(2,ℤ)_τ`/`ρ`-translation half of the `d = 2`
  duality-group structure that `Mirror.lean`'s `mirror_conjugates_tauShift` probes from
  the mirror-symmetry side; both files formalize consequences of the same GPR `d = 2`
  discussion (lines 1874–1884 here, line 344 there) but along independent, dual axes
  (this file: what commutes; `Mirror.lean`: what one duality conjugates another into).
* `mul_jMat_mul_transpose` and `basisChange_mul`/`thetaShift_mul` reuse `basisChange`
  and `thetaShift` from `ODD.lean` at the general-`d` block-matrix level; the closure
  results here (`basisChange_mul`, `thetaShift_mul`) are the multiplicative structure
  that `ODD.basisChange_isODD`/`thetaShift_isODD` only checked membership in
  `O(d,d;ℤ)` for, not composition.
-/
import DualScaleStream2.TDuality.ODD

namespace DualScaleStream2.TDuality

open Matrix

/-- `J = [[0,1],[-1,0]]`: the antisymmetric generator along which the `ρ`-translations
    `thetaShift (t • jMat)` (`t ∈ ℤ`) run, `ρ ↦ ρ + t`. -/
def jMat : Matrix (Fin 2) (Fin 2) ℤ := !![0, 1; -1, 0]

/-- **`A J Aᵀ = det(A) · J`** for every `2×2` integer `A`: conjugating `J` by `A`
    rescales it by `A`'s determinant (checked with sympy before formalization). This
    is the key algebraic fact that makes `det A = 1` the exact condition for a
    `τ`-side basis change to leave the `ρ`-translation direction `J` fixed, which is
    what `basisChange_comm_thetaShift` below turns into a commutation statement.
    Proof idea: both sides are fixed `2×2` matrices with entries polynomial in `A`'s
    four entries, so entrywise expansion (`fin_cases`) followed by `ring_nf`/`aesop`
    verifies the polynomial identity directly. -/
theorem mul_jMat_mul_transpose (A : Matrix (Fin 2) (Fin 2) ℤ) :
    A * jMat * Aᵀ = A.det • jMat := by
  -- both sides are 2×2 matrices with entries polynomial in A's four entries, so
  -- reduce to one polynomial identity per entry (fin_cases) and verify each by ring_nf
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, jMat, Matrix.det_fin_two, Fin.sum_univ_succ, Fin.sum_univ_zero]
  <;>
    ring_nf <;>
    aesop

/-- **Basis changes compose blockwise**: `diag(A,B) · diag(A',B') = diag(AA',BB')`.
    Together with `ODD.basisChange_isODD` this shows the basis changes satisfying
    `Aᵀ B = 1` form a monoid closed under `O(d,d;ℤ)`-preserving composition
    (no inverses are asserted). Proof idea: both sides act block-diagonally, so
    entrywise expansion of the matrix product reduces directly to the two block
    products `A·A'` and `B·B'`. -/
theorem basisChange_mul {d : ℕ} (A B A' B' : Matrix (Fin d) (Fin d) ℤ) :
    basisChange A B * basisChange A' B' = basisChange (A * A') (B * B') := by
  ext i j
  simp [basisChange, Matrix.mul_apply, Finset.sum_mul, Finset.mul_sum]
  <;> ring
  <;> aesop

/-- **`Θ`-shifts compose additively**: `thetaShift Θ · thetaShift Θ' =
    thetaShift (Θ + Θ')`. Physically, two integer `B`-field shifts combine into the
    shift by the sum — so the `Θ`-shifts form a group isomorphic to the additive group
    of antisymmetric integer matrices. Proof idea: expand the block product via
    `fromBlocks_multiply`; the only nonzero off-diagonal block collapses to `Θ + Θ'`. -/
theorem thetaShift_mul {d : ℕ} (Θ Θ' : Matrix (Fin d) (Fin d) ℤ) :
    thetaShift Θ * thetaShift Θ' = thetaShift (Θ + Θ') := by
  unfold thetaShift
  rw [fromBlocks_multiply]
  simp [add_comm]

/-- **`SL(2,ℤ)_τ` commutes with the ρ-translations**: a basis change `diag(A,B)` with
    `det A = 1` commutes with every integer `ρ`-shift `thetaShift (t • J)`. Physically,
    this is the matrix-level content of GPR's "`d=2` duality group factorizes as
    `SL(2,ℤ)_τ × SL(2,ℤ)_ρ`": transformations of the two moduli do not interfere.
    Proof idea (a three-step derivation, not a single rewrite): (1) `hjMat` uses
    `mul_jMat_mul_transpose` together with `det A = 1` to show conjugating `J` by `A`
    fixes it, `A J Aᵀ = J`; (2) `hcomm` combines that with the compatibility hypothesis
    `Aᵀ B = 1` to convert this into the "off-diagonal" identity `A J = J B` (multiply
    `A J` by the identity `Aᵀ B = 1` on the right, then regroup and substitute `hjMat`);
    (3) expand both `diag(A,B) · thetaShift(tJ)` and the reverse product blockwise, and
    `hcomm` (scaled by `t`) closes the two surviving off-diagonal blocks. -/
theorem basisChange_comm_thetaShift (A B : Matrix (Fin 2) (Fin 2) ℤ) (hAB : Aᵀ * B = 1)
    (hdet : A.det = 1) (t : ℤ) :
    basisChange A B * thetaShift (t • jMat) = thetaShift (t • jMat) * basisChange A B := by
  have hjMat : A * jMat * Aᵀ = jMat := by
    -- det A = 1 turns the general rescaling A J Aᵀ = det(A)·J into A J Aᵀ = J
    rw [mul_jMat_mul_transpose A, hdet]; simp
  have hcomm : A * jMat = jMat * B := by
    -- insert the identity Aᵀ B = 1, then regroup so A·J·Aᵀ (= J, by hjMat) appears
    have h1 : A * jMat = A * jMat * (Aᵀ * B) := by simp [hAB]
    rw [h1]
    rw [show A * jMat * (Aᵀ * B) = (A * jMat * Aᵀ) * B by simp [Matrix.mul_assoc]]
    simp [hjMat]
  unfold basisChange thetaShift
  ext i j
  -- expand both products blockwise; hcomm (scaled by t) matches the two remaining blocks
  simp only [fromBlocks_multiply, Matrix.mul_smul, Matrix.smul_mul]
  fin_cases i <;> fin_cases j <;> simp [hcomm]

end DualScaleStream2.TDuality
