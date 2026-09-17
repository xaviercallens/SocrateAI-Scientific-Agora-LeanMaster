-- Use Case 5: K3 Intersection-Form Signature σ(K3) = -16 (Hirzebruch/Rokhlin)
-- Status: VERIFIED (0 sorry, 0 admit) — builds directly on the already-certified
--         `Frontier.HodgeNumbers.k3HodgeNumber` / `k3_b2`.
-- Source: Hirzebruch signature theorem; Barth-Hulek-Peters-Van de Ven,
--         "Compact Complex Surfaces" Ch.VIII; Huybrechts "Lectures on K3
--         Surfaces" §1.2.
import Mathlib.Tactic.NormNum
import StringTheoryFormalization.Frontier.HodgeNumbers

namespace StringTheory.UseCases.K3Signature

open StringTheory.Frontier

/-!
# The K3 Intersection-Form Signature `σ = -16`

## Physical background

`H²(K3,ℤ)` carries a symmetric intersection form; its signature `(b₊, b₋)` is what
fixes the K3 lattice to be `3U ⊕ 2E8(-1)` up to isomorphism, the lattice underlying
every use of K3 as a compactification space in this project (moduli counting, flux
quantization, tadpole cancellation). Huybrechts (Prop. 3.5, `papers/foundations/
huybrechts_K3Global.txt`, ll.599-619) derives the *same* number `σ = -16` from the
Thom-Hirzebruch index theorem, `σ = (c₁² - 2c₂)/3 = -16` (K3 has `c₁ = 0`, `c₂ = 24`),
combined with `b₂ = 22` to read off `(3,19)`. This file takes a *different*, purely
Hodge-theoretic route to the same conclusion: on a compact Kähler surface the
self-dual/anti-self-dual splitting of `H²(X,ℝ)` decomposes as `b₊ = 2h^{2,0} + 1` (the
`+1` is the Kähler class itself, which is self-dual) and `b₋ = h^{1,1} - 1`. This is
standard Hodge theory (see e.g. Huybrechts §1.2 for the Hodge diamond that supplies
`h^{2,0}` and `h^{1,1}`, ll.406-441); it is not re-derived from the index theorem here.

## Mathematical content

`bPlus`/`bMinus` are *defined* directly from the already-certified lookup table
`Frontier.k3HodgeNumber` (`h^{2,0}=1`, `h^{1,1}=20`) via the Hodge-theoretic formulas
above, not computed from an actual intersection form on cohomology. The file proves:
`bPlus = 3`, `bMinus = 19` (both by `decide` on the lookup table); that `bPlus + bMinus`
equals the same alternating sum of Hodge numbers that `Frontier.HodgeNumbers.k3_b2`
already certifies to be `22`, so `betti_sum_eq_b2` is a direct corollary, not an
independent computation; and the **main result** `k3_signature_eq_neg_sixteen : (bPlus :
ℤ) - (bMinus : ℤ) = -16`. Because `bPlus`/`bMinus` are hard-coded formulas in the fixed
`h^{2,0}=1, h^{1,1}=20` numbers, this is arithmetic on those two numbers — it is *not*
a formalization of the Hirzebruch signature theorem or of the self-dual/anti-self-dual
Hodge decomposition itself (no differential form, wedge product or intersection pairing
appears anywhere in this file).

## Proof techniques

`decide` (finite case check on the `Fin 3 → Fin 3 → ℕ` table) for the two definitional
evaluations, `unfold` + `decide`/`norm_num` for the arithmetic identities, and a single
`rw` chaining `betti_decomposition_matches_b2` into the already-proved `k3_b2` for
`betti_sum_eq_b2`. No structural induction or geometric lemma is used.

## Related declarations

* `DualScaleStream2.Lattice.sigK3_matches_hodge` (bridge, per the atlas) consumes
  `bPlus`/`bMinus` directly — an independent module's signature computation for its own
  `Signature` lattice type is checked *against* these two definitions, giving external
  confirmation that the two conventions agree, not a re-derivation of them.
* `StringTheory.Frontier.k3_b2` (`Frontier/HodgeNumbers.lean`) is the declaration this
  file's `betti_sum_eq_b2` directly reduces to (dep-Jaccard 0.653, cosine 0.0 — a direct
  consumer relationship, not an independent proof).
* `DualScaleStream2.Lattice.hyperbolicU_symm`/`cartanE8_symm`/`e8Neg_symm` share very
  high dependency overlap (≥0.81) with `Frontier.k3_hodge_symmetry`, but this is an
  artifact of all of them being tiny `decide`/`rfl`-style lemmas built from the same
  Mathlib `Matrix`/`Fin` machinery, not a mathematical relationship to this file's
  signature computation.
-/

/-- The positive-definite part of the intersection form: `2h^{2,0} + 1`. -/
def bPlus : ℕ := 2 * k3HodgeNumber ⟨2, by norm_num⟩ ⟨0, by norm_num⟩ + 1

/-- The negative-definite part of the intersection form: `h^{1,1} - 1`. -/
def bMinus : ℕ := k3HodgeNumber ⟨1, by norm_num⟩ ⟨1, by norm_num⟩ - 1

/-- Evaluating `bPlus = 2h^{2,0}+1` at the certified K3 Hodge number `h^{2,0}=1`
    gives `3` — read off the lookup table, not derived geometrically. -/
theorem bPlus_eq_three : bPlus = 3 := by
  unfold bPlus k3HodgeNumber; decide

/-- Evaluating `bMinus = h^{1,1}-1` at the certified K3 Hodge number `h^{1,1}=20`
    gives `19` — likewise a table lookup. -/
theorem bMinus_eq_nineteen : bMinus = 19 := by
  unfold bMinus k3HodgeNumber; decide

/-- `bPlus + bMinus` is exactly the sum of Hodge numbers already certified to
    equal `22 = b₂(K3)` by `HodgeNumbers.k3_b2` — this file's new numbers are
    not independent restatements, they are the *same* certified quantity
    split into its Hirzebruch self-dual/anti-self-dual parts. -/
theorem betti_decomposition_matches_b2 :
    bPlus + bMinus =
      k3HodgeNumber ⟨0, by norm_num⟩ ⟨2, by norm_num⟩ +
      k3HodgeNumber ⟨1, by norm_num⟩ ⟨1, by norm_num⟩ +
      k3HodgeNumber ⟨2, by norm_num⟩ ⟨0, by norm_num⟩ := by
  unfold bPlus bMinus k3HodgeNumber; decide

/-- `bPlus + bMinus = 22 = b₂(K3)`: a direct corollary of `betti_decomposition_matches_b2`
    plus the already-certified `Frontier.HodgeNumbers.k3_b2`, not a new computation. -/
theorem betti_sum_eq_b2 : bPlus + bMinus = 22 := by
  rw [betti_decomposition_matches_b2]; exact k3_b2

/-- **Main result**: the K3 intersection-form signature is `-16`, matching the value
    Huybrechts obtains independently via the Thom-Hirzebruch index theorem. -/
theorem k3_signature_eq_neg_sixteen : (bPlus : ℤ) - (bMinus : ℤ) = -16 := by
  rw [bPlus_eq_three, bMinus_eq_nineteen]; norm_num

end StringTheory.UseCases.K3Signature
