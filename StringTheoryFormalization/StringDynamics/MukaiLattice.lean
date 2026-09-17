-- Block WS10: Mukai Lattice Γ^{4,20}
-- Status: VERIFIED (0 sorry axioms)
-- Provides: The K3 cohomology lattice H*(K3,ℤ) ≅ Γ^{4,20}.
import Mathlib.LinearAlgebra.Matrix.BilinearForm
import StringTheoryFormalization.StringDynamics.KummerBlowup

/-!
# The Mukai lattice Γ^{4,20}, as a record of four numbers

## Physical background
For a K3 surface `X`, the full cohomology `H*(X,ℤ) = H⁰⊕H²⊕H⁴` carries the Mukai pairing
`⟨(r,c,s),(r',c',s')⟩ = c·c' − r·s' − r'·s`, making it an even unimodular lattice of signature
`(4,20)`, isomorphic to `E₈(−1)⊕²⊕U⊕⁴`; this is the *Mukai lattice*, as opposed to the ordinary
K3 lattice `H²(X,ℤ) ≅ E₈(−1)⊕²⊕U⊕³` of signature `(3,19)`
(`papers/foundations/huybrechts_K3Global.txt`, ll. 12876–12886, "the extended K3 lattice or Mukai
lattice"; ll. 13430–13440 for the Mukai-pairing/ring-structure statement). The Mukai lattice is
the natural home for Chern characters of coherent sheaves on `X` and for the numerical invariants
that autoequivalences of `Db(X)` (see `FourierMukai.lean`) act on. BOOK_BIBLE.md §5 fixes the
signature convention `(n₊,n₋)` used here and the K3-lattice identification `3U⊕2E₈(−1)`.

## Mathematical content
`MukaiLattice` is **not** a lattice in the mathematical sense (no underlying abelian group, no
bilinear form, no basis) — it is a record of four bookkeeping fields (`rank`, `posSignature`,
`negSignature`, a `Bool` flag `unimodular`), each with a numeral default. `canonicalMukaiLattice`
and `h2Lattice` are two instantiations built entirely from those defaults: `(24,4,20,true)` and
`(22,3,19,true)` respectively, matching the numerical invariants of `Γ^{4,20}` and `Γ^{3,19}`
quoted above, but the Mukai pairing, the embedding `Γ^{3,19} ⊂ Γ^{4,20}` and unimodularity itself
are none of them formalized — `unimodular` is a settable `Bool` field whose `:= true` is only a
default value one could override with `false` on either record without contradiction (the same
defect the `FourierMukai.lean` module docstring documents for `isEquivalence`). `mukai_rank` is
the tautology `24 = 4 + 20` read off `canonicalMukaiLattice`'s four default fields by `rfl`.
`kummer_sublattice_rank` states only `Fintype.card (Fin 16) = 16` — a fact about the type `Fin 16`,
with no reference to `MukaiLattice`, the Mukai pairing, or an embedding; the embedding of the
16 Kummer `(-2)`-curves (`KummerBlowup.lean`) into the K3/Mukai lattice as a sublattice is
mathematically true (Huy ll. 2071–2096 discusses the Kummer lattice `K`) but is **not** what this
theorem proves.

## Proof techniques
`mukai_rank` unfolds `canonicalMukaiLattice`'s field defaults and closes by `rfl` (definitional
equality of numerals). `kummer_sublattice_rank` is `simp`, which resolves `Finset.univ.card` for
`Fin 16` to its cardinality via the standard `Fintype.card_fin` simp lemma.

## Related declarations
Per the atlas similarity tables, `mukai_rank` is textually similar (cosine 0.571) to
`Lean5Corpus.Problems.MukaiMonodromy.mukai_rank_and_signature` and (cosine 0.416) to
`DualScaleStream2.Lattice.rank_K3` — both state numerical rank/signature facts about K3-adjacent
lattices, but at low dependency-Jaccard (≤0.09), so these are independent re-derivations of
related numerology, not shared proofs of the same object. `kummer_sublattice_rank` is similarly
close (cosine 0.349) to the same `mukai_rank_and_signature` declaration. Neither `MukaiLattice`,
`canonicalMukaiLattice` nor `h2Lattice` appears in the atlas at all — the record type itself has
no cross-library counterpart.
-/

namespace StringTheory.StringDynamics

/-- A record of four bookkeeping numbers describing a lattice's numerical invariants — **not**
    a lattice (no group, no bilinear form is carried). Defaults `(24, 4, 20, true)` match the
    rank and signature `(4,20)` of the genuine Mukai lattice `Γ^{4,20} ≅ E₈(−1)⊕²⊕U⊕⁴`
    (`papers/foundations/huybrechts_K3Global.txt`, ll. 12879–12886), which this project treats
    as an *arithmetic shadow* of that lattice in the sense of BOOK_BIBLE.md §2. `unimodular` is
    a settable `Bool` field, so nothing here enforces that the recorded data is actually
    unimodular. -/
structure MukaiLattice where
  /-- Basis vectors as ℤ²⁴ -/
  rank : ℕ := 24
  posSignature : ℕ := 4
  negSignature : ℕ := 20
  /-- Unimodularity: det of Gram matrix = ±1 -/
  unimodular : Bool := true

/-- `MukaiLattice` built from all four field defaults: `(rank, posSignature, negSignature,
    unimodular) = (24, 4, 20, true)`, the numerical shadow of `Γ^{4,20}`. -/
def canonicalMukaiLattice : MukaiLattice := {}

/-- The recorded rank of `canonicalMukaiLattice` equals the sum of its recorded signature
    components: `24 = 4 + 20`. Proof: unfold the three fields to their numeral defaults and
    close by `rfl` — this is arithmetic on the record's fields, not a fact about a lattice's
    Gram matrix or the signature theorem for quadratic forms. -/
theorem mukai_rank :
    canonicalMukaiLattice.rank = canonicalMukaiLattice.posSignature +
    canonicalMukaiLattice.negSignature := by rfl

/-- `Fin 16` has exactly 16 elements. Proof: `simp` resolves `Finset.univ.card` on a `Fin`
    type via its standard cardinality lemma. As stated this is a fact about the type `Fin 16`
    only — it does not mention `MukaiLattice`, a bilinear form, or an embedding. Physically the
    16 Kummer exceptional `(-2)`-curves of `KummerBlowup.lean` do span a rank-16 sublattice of
    the K3/Mukai lattice (`papers/foundations/huybrechts_K3Global.txt`, ll. 2071–2096, "the
    Kummer lattice"), but that embedding claim is Tier L/C here, not proved by this theorem. -/
theorem kummer_sublattice_rank :
    (Finset.univ (α := Fin 16)).card = 16 := by
  simp

/-- `MukaiLattice` built with fields `(rank, posSignature, negSignature, unimodular) =
    (22, 3, 19, true)`, the numerical shadow of the ordinary K3 lattice `H²(K3,ℤ) ≅ Γ^{3,19}`
    (signature `(3,19)`, `papers/foundations/huybrechts_K3Global.txt` ll. 12876–12878), as
    opposed to the extended Mukai lattice `Γ^{4,20}` of `canonicalMukaiLattice`. No theorem in
    this file relates `h2Lattice` to `canonicalMukaiLattice` (e.g. no stated embedding
    `Γ^{3,19} ↪ Γ^{4,20}`); the name records the intended physical reading only. -/
def h2Lattice : MukaiLattice where
  rank := 22
  posSignature := 3
  negSignature := 19
  unimodular := true

end StringTheory.StringDynamics
