-- Block FR2: Chiral Primaries  [FRONTIER — Track A]
-- Status: IN PROGRESS — sorry axioms to be eliminated by ML pipeline
-- Assignee: Phase 1 (Meta PDF-to-Lean) + Phase 2 (Fermat) + Phase 3 (ML tactics)
-- Dependencies: FR1 (CentralCharge), M2 (FourierMultipliers)
-- Source: Lerche-Vafa-Warner (1989); de Boer et al. (1999)
import Mathlib.Algebra.Ring.Basic
import StringTheoryFormalization.Frontier.CentralCharge

namespace StringTheory.Frontier

/-!
# Chiral Primaries from the N=2 Superconformal Algebra

## Physical background

A `(4,4)`-supersymmetric sigma model, such as the K3 sigma model appearing in this
project's compactifications, has an `N=2` superconformal algebra on each chiral half,
with generators `T`, `G^±`, and a `U(1)_R` current `J`. Unitary representations of this
algebra obey a BPS bound relating conformal weight `h` and `U(1)` charge `q`: `h ≥ |q|/2`
(Lerche-Vafa-Warner 1989; de Boer et al. 1999 — neither is in this book's source
library, so the bound is stated here as standard CFT background, not pinned to an
opened source). States saturating the bound, `h = q/2` for `q ≥ 0`, are the *chiral
primaries*; they are annihilated by the lowering supercharge `G^-_0` and are in
one-to-one correspondence with Dolbeault cohomology classes `H^{p,0}` of the target
space. For K3, `h^{0,0} = h^{2,0} = 1` and `h^{1,0} = 0` (the already-certified Hodge
diamond, `Frontier.HodgeNumbers.k3HodgeNumber`; see that file's docstring for the
Huybrechts pin), so K3's sigma model has exactly two chiral primaries: the vacuum and
the state dual to the holomorphic 2-form `Ω`.

## Mathematical content

`N2State` bundles a conformal weight and `U(1)` charge (both `ℚ`, with no positivity
constraint on `confWeight` enforced in the type, despite the physical requirement `h≥0`
mentioned above); `bpsBound` and `isChiralPrimary` are the two `Prop`s above.
`chiral_primary_saturates_bps` proves the *forward* direction only — that saturating
the BPS bound implies satisfying it (an immediate consequence of `q ≥ 0` making
`|q|=q`) — not the converse or any statement about which states of an actual N=2 SCA
representation are chiral primaries. `K3ChiralPrimaryCount` is a hard-coded
`Fin 3 → ℕ` table (`1,0,1`) matching the `H^{p,0}` counts by hand, not derived from
`k3HodgeNumber` or any cohomological computation; `k3_chiral_primary_total` sums this
table to `2`. `chiral_primary_ring_associativity` is, despite its name, **vacuous**: for
any three chiral primaries, regardless of the hypotheses, it proves the trivial
proposition `True`; **no chiral ring, OPE coefficients `C_{ij}^k`, or associativity are
formalized anywhere in this file**. This is the file's single most overclaiming
declaration and should never be cited as evidence about the chiral ring.

## Proof techniques

`chiral_primary_saturates_bps` unfolds both definitions, destructures the conjunction
`isChiralPrimary`, rewrites the weight equation, then closes with `simp` using
`abs_of_nonneg` on the charge positivity hypothesis. `k3_chiral_primary_total` is a
finite sum unfolded by `Fin.sum_univ_three` and `simp`. `chiral_primary_ring_associativity`
is discharged by `intros; trivial`, since its conclusion is `True` independent of any
hypothesis.

## Related declarations

* `StringTheory.Frontier.CentralCharge` (imported) supplies the K3 CFT this file's
  states inhabit; no declaration from that file is actually used in any proof here
  beyond the import.
* `StringTheory.Frontier.HodgeNumbers.k3HodgeNumber` computes the *same* Hodge numbers
  `{1,0,1}` that `K3ChiralPrimaryCount` re-encodes by hand; the atlas records
  `SocrateAI.Moonshine.total_chiral_weight_value ~ k3_chiral_primary_total` at cosine
  0.358 (an independent, differently-sourced count of the same physical multiplicity,
  in the Moonshine-focused `SocrateAI` library) as a unification candidate — a good
  target for eventually deriving `K3ChiralPrimaryCount` from `k3HodgeNumber` directly
  instead of duplicating it.
-/

/-- A pair of `N=2` superconformal quantum numbers `(h, q)` for a state: a
    conformal weight and a `U(1)_R` charge. Physically `h ≥ 0` in any unitary
    representation, but that positivity is **not** a field constraint of this
    structure — an `N2State` with negative `confWeight` typechecks fine, so
    downstream lemmas that need `h ≥ 0` must assume it separately. -/
structure N2State where
  /-- Conformal weight h (see the structure docstring on positivity). -/
  confWeight : ℚ
  /-- U(1)_R charge q ∈ ℤ (after spectral flow normalization). -/
  u1Charge : ℚ

/-- The unitarity/BPS bound of the `N=2` SCA: `h ≥ |q|/2`. -/
def bpsBound (s : N2State) : Prop :=
  s.confWeight ≥ |s.u1Charge| / 2

/-- A chiral primary is a state saturating the BPS bound from the positive-charge
    side: `q ≥ 0` and `h = q/2`. (The `q ≤ 0` case, anti-chiral primaries, is not
    modeled here.) -/
def isChiralPrimary (s : N2State) : Prop :=
  0 ≤ s.u1Charge ∧ s.confWeight = s.u1Charge / 2

/-- **One direction only**: a chiral primary satisfies the BPS bound (the
    converse — that saturating the bound with `q≥0` makes a state chiral
    primary — is definitional here, not a separate theorem). Proof idea:
    unfold both `Prop`s, then `|q| = q` since `q ≥ 0`, reducing `h ≥ |q|/2`
    to the assumed equality `h = q/2`. -/
theorem chiral_primary_saturates_bps (s : N2State) (h : isChiralPrimary s) :
    bpsBound s := by
  unfold bpsBound isChiralPrimary at *
  -- split the chiral-primary hypothesis into charge sign and saturation equality
  obtain ⟨hq, hw⟩ := h
  -- rewrite the bound's h by the saturation equality h = q/2
  rw [hw]
  -- q ≥ 0 makes |q| = q, so the bound q/2 ≥ |q|/2 becomes q/2 ≥ q/2, i.e. reflexivity
  simp [abs_of_nonneg hq]

/-- Hand-encoded lookup table (not derived from `Frontier.HodgeNumbers.k3HodgeNumber`
    or from any cohomology computation): the physical claim is that chiral
    primaries at charge `q ∈ {0,1,2}` correspond to `H^{q,0}(K3)`, of dimensions
    `{1, 0, 1}`. -/
def K3ChiralPrimaryCount : Fin 3 → ℕ
  | ⟨0, _⟩ => 1  -- H^{0,0} = ℂ (vacuum)
  | ⟨1, _⟩ => 0  -- H^{1,0} = 0 (K3 has no holomorphic 1-forms)
  | ⟨2, _⟩ => 1  -- H^{2,0} = ℂ (holomorphic 2-form Ω)

/-- K3 has exactly 2 chiral primaries (vacuum + Ω). -/
theorem k3_chiral_primary_total :
    (∑ i : Fin 3, K3ChiralPrimaryCount i) = 2 := by
  simp [K3ChiralPrimaryCount, Fin.sum_univ_three]

/-- **Vacuous — proves `True`, not associativity of anything.** The intended
    target (unformalized) is the chiral ring structure `φ_i ⋆ φ_j = C_{ij}^k φ_k`
    and its associativity; this statement takes three chiral primaries as
    hypotheses but its conclusion is the trivial proposition `True`, so the
    hypotheses are unused and no ring, product `⋆` or structure constants
    `C_{ij}^k` are defined anywhere in this file. This declaration should be
    read as a placeholder marking where that development would go, not as
    evidence of any fact about the chiral ring. -/
theorem chiral_primary_ring_associativity :
    ∀ (φ₁ φ₂ φ₃ : N2State),
    isChiralPrimary φ₁ → isChiralPrimary φ₂ → isChiralPrimary φ₃ →
    True := by
  intros; trivial -- placeholder: full ring axioms assigned to Fermat Phase 2

end StringTheory.Frontier
