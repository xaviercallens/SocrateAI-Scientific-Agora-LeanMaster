/-
Stream 2 · P2.4 — Level matching and the DFT section condition on the charge lattice.

Source (Tier L): Hull & Zwiebach, *Double Field Theory*, arXiv:0904.4664
(`papers/foundations/hull_zwiebach_0904_4664.txt`):
* eq. (1.3), line 231: "L₀ − L̄₀ = N − N̄ − pₐwᵃ = 0" (level matching);
* lines 339–342: "The solutions independent of x̃ give the gravity field …, the antisymmetric
  tensor field … and the dilaton …. The solutions independent of xᵃ give dual versions of
  these fields";
* lines 3930–3940: restriction to null subspaces; "A 2d dimensional space with metric of
  signature (d, d) can have totally null d-dimensional subspaces".

Tier A here, every `d`, on the integer charge lattice `ℤ^d ⊕ ℤ^d` (momentum ⊕ winding) with
the `η`-pairing:
* at `N = N̄`, level matching is exactly `n · w = 0`, i.e. the charge is `η`-null;
* the pure-momentum frame (no winding: the "independent of x̃" supergravity frame) and the
  pure-winding frame (its dual) are each totally null — they solve the section condition;
* the full T-duality `η` maps the momentum frame onto the winding frame;
* any `O(d,d;ℤ)` element maps a section to a section.

### Physical background
Double Field Theory doubles every torus coordinate, but the doubled fields are constrained:
physical states obey level matching `L₀ − L̄₀ = 0`, and physical *fields* must be annihilated
by the strong constraint, which restricts them to depend on only half of the doubled
coordinates (Hull–Zwiebach, `papers/foundations/hull_zwiebach_0904_4664.txt`, eq. (1.3) at
line 231, and lines 339–342). Geometrically, the allowed coordinate choices are the totally
null ("isotropic") `d`-dimensional subspaces of the `2d`-dimensional doubled space carrying
the `O(d,d)` form `η` — HZ §5.4, lines 3930–3940: "A `2d` dimensional space with metric of
signature `(d,d)` can have totally null `d`-dimensional subspaces … we shall be interested
in totally null subspaces `T^d ⊂ T^{2d}`." The ordinary supergravity fields correspond to
one such choice (independent of the dual/winding coordinates); T-duality moves to another.

### Mathematical content
Works on the *integer* charge lattice `Charge d → ℤ` (momentum ⊕ winding numbers), not on
the continuous field theory: defines `etaPair`, the `η`-bilinear pairing of two charges, and
`IsSection`, "totally `η`-null" applied to a *set* of charges (the lattice-level shadow of a
totally isotropic subspace). Defines the two standard sections `momentumFrame`/`windingFrame`
(no winding / no momentum). Proves `levelMatching_iff`: at `N = N̄`, the level-matching
condition `chargeNorm Z = 0` (HZ eq. (1.3)) is equivalent to `n·w = 0`, i.e. to `Z` being
`η`-null; `etaPair_self`, that `etaPair Z Z` is exactly `TDuality.chargeNorm Z`, the two
notions coincide on the diagonal; `eta_momentum_to_winding`, that the full duality `η` sends
the momentum frame onto the winding frame; `momentumFrame_isSection` and
`windingFrame_isSection`, that both standard frames are indeed sections; and
`isSection_image`, that any `g ∈ O(d,d;ℤ)` maps a section to a section — so acting with a
T-duality on a valid choice of undoubled coordinates gives another valid choice. **Not
proved here**: any statement about the *classification* of all totally null `d`-dimensional
subspaces (only the two standard ones and their `O(d,d;ℤ)`-images are exhibited); nothing
about the strong constraint as a differential condition on fields, only its lattice/charge
shadow via `η`-nullity of charge sets.

### Proof techniques
`levelMatching_iff` and `etaPair_self` reduce to `TDuality.Factorized.chargeNorm_sumElim`
by unfolding definitions (both `etaPair` and `chargeNorm` are literally `Z ⬝ᵥ (eta d *ᵥ Z')`)
and, for the iff, close the remaining linear Diophantine equivalence with `omega`.
`eta_momentum_to_winding` and the two `*Frame_isSection` proofs unfold `eta`/`etaPair` to
`fromBlocks_mulVec` and then case on the `Sum.inl`/`Sum.inr` components of the doubled index
type. `isSection_image` transports the bilinear pairing along `g` by rewriting
`(g *ᵥ Z) ⬝ᵥ (η *ᵥ (g *ᵥ Z'))` as `Z ⬝ᵥ ((gᵀ η g) *ᵥ Z')` (associativity of `mulVec` plus
`dotProduct_mulVec`/`vecMul_transpose`), then substitutes `gᵀ η g = η` (`hg : IsODD g`) to
land back on the hypothesis `hS` about the untransformed set.

### Related declarations
This file's `etaPair`/`IsSection` reuse `TDuality.eta`/`TDuality.IsODD` from `TDuality.ODD`
and `TDuality.Factorized.chargeNorm` directly (same objects, not re-derived); `etaPair_self`
is precisely the statement that this file's pairing and Stream 2's charge norm agree on the
diagonal. `isSection_image` is the section-condition instance of the general fact
`TDuality.chargeNorm_invariant` (both say an `O(d,d;ℤ)` element preserves an `η`-built
invariant — chargeNorm_invariant for the diagonal pairing, `isSection_image` for the pairing
between distinct elements of a set). `DFT.GeneralizedMetric.massForm_covariant` is the
`ℝ`-valued, continuous-group analogue of the same idea (a bilinear form built from `η`/`H`
transported along a duality), proved independently there for the real generalized metric
rather than the integer charge lattice.
-/
import DualScaleStream2.TDuality.Factorized

namespace DualScaleStream2.DFT

open Matrix DualScaleStream2.TDuality

variable {d : ℕ}

/-- The `η`-pairing `Z ∘ Z' = Zᵀ η Z'`. -/
def etaPair (Z Z' : Charge d → ℤ) : ℤ := Z ⬝ᵥ (eta d *ᵥ Z')

/-- A set of charges is a *section* if it is totally `η`-null. -/
def IsSection (S : Set (Charge d → ℤ)) : Prop := ∀ Z ∈ S, ∀ Z' ∈ S, etaPair Z Z' = 0

/-- Pure-momentum frame (no winding). -/
def momentumFrame (d : ℕ) : Set (Charge d → ℤ) :=
  {Z | ∃ n : Fin d → ℤ, Z = Sum.elim n (0 : Fin d → ℤ)}

/-- Pure-winding frame (no momentum). -/
def windingFrame (d : ℕ) : Set (Charge d → ℤ) :=
  {Z | ∃ w : Fin d → ℤ, Z = Sum.elim (0 : Fin d → ℤ) w}

/-- **Level matching at `N = N̄`** (HZ eq. (1.3)): the charge is `η`-null iff `n · w = 0`. -/
theorem levelMatching_iff (n w : Fin d → ℤ) :
    chargeNorm (Sum.elim n w) = 0 ↔ n ⬝ᵥ w = 0 := by
  rw [chargeNorm_sumElim]
  constructor <;> intro h <;> omega

/-- The `η`-pairing of a charge with itself is exactly its `TDuality.chargeNorm`: the two
definitions are the same expression `Z ⬝ᵥ (eta d *ᵥ Z)`, so this is a `rfl`-level identity
recording that this file's section-theoretic pairing and Stream 2's charge norm are one
and the same object, not merely numerically equal. -/
theorem etaPair_self (Z : Charge d → ℤ) : etaPair Z Z = chargeNorm Z := by
  unfold etaPair chargeNorm; rfl

/-- The full T-duality maps pure momentum to pure winding. -/
theorem eta_momentum_to_winding (n : Fin d → ℤ) :
    eta d *ᵥ Sum.elim n (0 : Fin d → ℤ) = Sum.elim (0 : Fin d → ℤ) n := by
  unfold eta
  rw [fromBlocks_mulVec]
  ext x
  cases x with
  | inl i => simp [Sum.elim_inl, Sum.elim_inr, Matrix.zero_mulVec, Matrix.one_mulVec]
  | inr i => simp [Sum.elim_inl, Sum.elim_inr, Matrix.zero_mulVec, Matrix.one_mulVec]

/-- The pure-momentum frame is a section: any two purely-momentum charges are `η`-orthogonal,
because `η` couples momentum only to winding, and there is no winding here. This is HZ's
"solutions independent of `x̃`" choice — the ordinary supergravity fields. -/
theorem momentumFrame_isSection : IsSection (momentumFrame d) := by
  rintro Z ⟨n, rfl⟩ Z' ⟨n', rfl⟩
  unfold etaPair
  rw [eta_momentum_to_winding]
  simp [sumElim_dotProduct_sumElim, dotProduct_zero, zero_dotProduct]

/-- The pure-winding frame is a section, by the same reasoning as `momentumFrame_isSection`
with the roles of momentum and winding exchanged; this is HZ's dual choice, "independent
of `xᵃ`". -/
theorem windingFrame_isSection : IsSection (windingFrame d) := by
  rintro Z ⟨w, rfl⟩ Z' ⟨w', rfl⟩
  unfold etaPair eta
  rw [fromBlocks_mulVec]
  simp [Sum.elim_comp_inl, Sum.elim_comp_inr, sumElim_dotProduct_sumElim, dotProduct_zero, zero_dotProduct]

/-- `O(d,d;ℤ)` maps sections to sections. -/
theorem isSection_image (g : Matrix (Charge d) (Charge d) ℤ) (hg : IsODD g)
    (S : Set (Charge d → ℤ)) (hS : IsSection S) :
    IsSection ((fun Z => g *ᵥ Z) '' S) := by
  rintro _ ⟨Z, hZ, rfl⟩ _ ⟨Z', hZ', rfl⟩
  unfold etaPair
  -- move g off the two vectors and onto η itself, turning the pairing of the *images*
  -- g·Z, g·Z' into the pairing of the *original* Z, Z' under the conjugated form gᵀηg.
  have key : (g *ᵥ Z) ⬝ᵥ (eta d *ᵥ (g *ᵥ Z')) = Z ⬝ᵥ ((gᵀ * eta d * g) *ᵥ Z') := by
    rw [← Matrix.mulVec_mulVec, ← Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec Z gᵀ,
      Matrix.vecMul_transpose]
  -- since g ∈ O(d,d;ℤ), gᵀηg = η, so the conjugated form collapses back to η itself,
  -- and the goal becomes exactly the section hypothesis hS on the untransformed set.
  rw [key, hg]
  exact hS Z hZ Z' hZ'

end DualScaleStream2.DFT
