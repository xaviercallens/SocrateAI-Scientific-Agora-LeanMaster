/-
Stream 2 · Signature bookkeeping: K3 lattice → Mukai lattice → K3 × T² charge lattice.

What is Tier L (quoted, not proved here):
* `H²(K3,ℤ) ≅ E8(−1)⊕2 ⊕ U⊕3` — Huybrechts, *Lectures on K3 Surfaces*, Ch. 1, eq. (3.4).
* `Γ³'¹⁹` is even self-dual and the K3 moduli space is
  `O⁺(Γ³'¹⁹)\O⁺(3,19)/(O(2)×O(1,19))⁺` — Aspinwall, *K3 Surfaces and String Duality*,
  hep-th/9611137 (`papers/foundations/aspinwall_hep-th_9611137.txt`, lines 705–766).
* The even self-dual `Γ⁴'²⁰ ⊃ Γ³'¹⁹` (Mukai lattice) — same reference, lines 1737–1748.
* Component signatures `U = (1,1)`, `E8(−1) = (0,8)`, and Sylvester's law of inertia.
* Even unimodular indefinite lattices have `b₊ − b₋ ≡ 0 (mod 8)` (Milnor / Serre,
  *A Course in Arithmetic* — journal/book only, not downloaded).

What is Tier A (checked here): the signature *arithmetic* of the direct sums, the
mod-8 condition holding for each, and that the lattice-theoretic `(3,19)` agrees with
the Hodge-theoretic `(b₊, b₋)` computed in Stream 1's `K3Signature`. That agreement is a
consistency check between two *independently tabulated* Tier L inputs (the lattice
decomposition vs. the Hodge diamond) — it is not an independent derivation of either.

## Physical background

Signature bookkeeping is what turns the abstract lattice decompositions of `E8.lean` and
`Hyperbolic.lean` into a statement about an actual K3 surface: `H²(X,ℤ)` of a complex K3
surface carries a *Lorentzian* intersection form, signature `(3,19)` — a 3-dimensional
positive-definite part (spanned by the real and imaginary parts of the periods of the
holomorphic 2-form, plus the Kähler class) and a 19-dimensional negative-definite
complement. The Torelli theorem then identifies the moduli space of complex structures
with the Grassmannian of oriented positive 3-planes in `ℝ^{3,19}` modulo the lattice's
isometry group, `O⁺(Γ³'¹⁹)\O⁺(3,19)/(O(2)×O(1,19))⁺` (Aspinwall,
`papers/foundations/aspinwall_hep-th_9611137.txt`, lines 705–766, read for this file: eq.
(31)–(32) and the surrounding derivation). Adding the Mukai lattice's extra copy of `U`
(rank 4, signature `(4,20)`) extends this to the Grassmannian of space-like 4-planes in
`ℝ^{4,20}` that appears in the moduli space of Einstein metrics / hyperkähler structures
(same source, lines 1737–1748: "Let us introduce the even self-dual lattice `Γ⁴'²⁰ ⊂
ℝ⁴'²⁰`... we would like to show `Gσ ≅ O(Γ⁴'²⁰)`"). Adjoining the `T²` factor's `Γ²'²` gives
the `(6,22)` charge lattice of the full K3×T² compactification. None of that moduli-space
geometry is formalized here — only the rank/signature arithmetic that any such lattice
decomposition must satisfy is checked.

## Mathematical content

`Signature` is a bare pair `(pos, neg) : ℕ × ℕ` with componentwise addition, `rank`
(their sum) and `index` (`pos - neg` as an integer). `sigU`, `sigE8Neg` are the Tier L
input signatures of the two lattice pieces certified elsewhere (`Hyperbolic.lean`,
`E8PosDef.lean`, respectively, for the qualitative "one of each sign" / "all negative"
facts — the *specific numbers* `(1,1)` and `(0,8)` are asserted here, not re-derived from
those files' theorems). `sigK3`, `sigMukai`, `sigT2`, `sigK3T2` build up the signatures of
`H²(K3,ℤ)`, the Mukai lattice, the `T²` Narain lattice, and the full K3×T² charge lattice
purely by adding these two inputs the right number of times. `sigK3_eq`/`sigMukai_eq`/
`sigK3T2_eq`/`rank_K3`/`rank_K3T2` are `rfl`-level arithmetic consequences: evaluating
`⟨0,8⟩+⟨0,8⟩+⟨1,1⟩+⟨1,1⟩+⟨1,1⟩` really does reduce to `⟨3,19⟩`, and so on.
`index_mod_eight` checks that `index % 8 = 0` holds for these three specific tuples — a
necessary condition for an even unimodular indefinite lattice (Milnor/Serre; Tier L,
not re-proved here), verified only *at* these tuples, not as the general theorem.
`sigK3_matches_hodge` cross-checks `sigK3.pos`/`sigK3.neg` (from the lattice
decomposition) against `bPlus`/`bMinus` (from Stream 1's independently tabulated Hodge
numbers).

**Not proved here** (this is the file's central epistemic caveat, worth restating): that
`H²(K3,ℤ)` really has signature `(3,19)` — that is a Tier L fact about actual K3 surfaces,
quoted from Huybrechts/Aspinwall. What *is* proved is that the four numbers `sigU`,
`sigE8Neg` (also Tier L inputs) combine, by pure integer arithmetic, to the pair `(3,19)`
matching that quotation, and *separately* that the Hodge-theoretic route to the same pair
(in Stream 1) lands on the identical numbers. Agreement of two independently-sourced
Tier L inputs is evidence of consistency, not a derivation of either from first
principles — this is the project's "arithmetic shadow" pattern (BOOK_BIBLE §2): the real
mathematical content (why `H²(K3,ℤ)` has this signature) lives in the literature, and
what Lean checks is that the bookkeeping built on top of it is self-consistent. Likewise,
`index_mod_eight` does not prove the mod-8 theorem for general even unimodular indefinite
lattices — only that these three specific `(pos,neg)` pairs satisfy it.

## Proof techniques

Every theorem in this file is `rfl`, `decide`, or a short `simp` unfolding the
definitions — genuine unification of natural-number/integer arithmetic, not lattice
theory. `sigK3_matches_hodge` additionally needs `Signature.pos`/`Signature.neg`
unfolded before the two sides (a Stream-2 `Signature` value versus Stream 1's `bPlus`/
`bMinus` naturals) are recognizably the same numbers.

## Related declarations

`Signature` is an atlas hub (5 dependent theorems, all in this file). `sigK3_matches_hodge`
is one of the atlas's three cross-library *bridges* originating in `DualScaleStream2.
Lattice`, reaching into `StringTheory.UseCases.K3Signature.bPlus`/`bMinus` — a genuine
cross-check between two independently built Tier L inputs, exactly as described above (not
a "same object" identification like `Hyperbolic.hyperbolicU_eq_narain_gram`, since the two
sides are computed by unrelated routes — lattice decomposition vs. Hodge diamond — that
happen to agree). `rank_K3` and `rank_K3T2` are atlas *similarity* matches (cosine 0.42,
0.42; dependency overlap only 0.02, i.e. essentially independent proofs) with
`Lean5Corpus.Problems.MukaiMonodromy.mukai_rank_and_signature` and `SocrateAI.
FrontierTriad.total_k3t2_moduli_dim_eq_80` respectively — these are related numerology
(rank 22 of the K3 lattice vs. the Mukai-lattice rank-and-signature statement; rank 28 of
the K3×T² charge lattice vs. the 80-real-dimensional K3×T² moduli space) but **not** the
same statement: a lattice rank is not a moduli-space dimension, and no theorem here
relates the two numbers to each other.
-/
import DualScaleStream2.Lattice.Basic
import StringTheoryFormalization.UseCases.K3SignatureTheorem

namespace DualScaleStream2.Lattice

/-- Signature `(b₊, b₋)` of a non-degenerate real quadratic form: `pos` real dimensions
where the form is positive, `neg` where it is negative (`b₊ − b₋` is the physicists'
"index" or Hirzebruch signature). This is a bare pair of naturals with no link, inside
this `structure`, to any actual quadratic form — the link to concrete lattices (`U`,
`E8(−1)`, ...) is asserted by the `def`s below, not derived from a definiteness proof. -/
structure Signature where
  pos : ℕ
  neg : ℕ
  deriving DecidableEq, Repr

namespace Signature

/-- Direct-sum addition of signatures: stacking two orthogonal quadratic forms adds
their positive and negative dimensions independently, `(p,n) ⊕ (p',n') = (p+p', n+n')`. -/
instance : Add Signature := ⟨fun a b => ⟨a.pos + b.pos, a.neg + b.neg⟩⟩

/-- The positive part of a direct sum is the sum of the positive parts (unfolds the
`Add` instance above; `simp`-tagged so later arithmetic proofs can use it automatically). -/
@[simp] theorem add_pos (a b : Signature) : (a + b).pos = a.pos + b.pos := rfl
/-- The negative part of a direct sum is the sum of the negative parts. -/
@[simp] theorem add_neg (a b : Signature) : (a + b).neg = a.neg + b.neg := rfl

/-- Total rank `b₊ + b₋` of the form. -/
def rank (s : Signature) : ℕ := s.pos + s.neg

/-- `b₊ − b₋`. -/
def index (s : Signature) : ℤ := (s.pos : ℤ) - s.neg

end Signature

/-- Signature of `U` (Tier L input): one positive, one negative direction, matching the
diagonalization witness `hyperbolicU_congruence` in `Hyperbolic.lean` — this value is
asserted here, not mechanically extracted from that theorem. -/
def sigU : Signature := ⟨1, 1⟩
/-- Signature of `E8(−1)` (Tier L input): purely negative, rank 8 — matching
`E8PosDef.cartanE8_posDef` (positive-definiteness of `E8` before the sign flip) up to the
same asserted-not-extracted caveat as `sigU`. -/
def sigE8Neg : Signature := ⟨0, 8⟩

/-- Signature of the K3 lattice `H²(K3,ℤ) ≅ E8(−1)⊕2 ⊕ U⊕3`, computed by adding the two
Tier L input signatures the right number of times. -/
def sigK3 : Signature := sigE8Neg + sigE8Neg + sigU + sigU + sigU
/-- Signature of the Mukai lattice `Γ⁴'²⁰ = Γ³'¹⁹ ⊕ U`. -/
def sigMukai : Signature := sigK3 + sigU
/-- Signature of the `T²` Narain lattice `Γ²'² = U ⊕ U`. -/
def sigT2 : Signature := sigU + sigU
/-- Signature of the K3 × T² charge lattice `Γ⁶'²² = Γ⁴'²⁰ ⊕ Γ²'²`. -/
def sigK3T2 : Signature := sigMukai + sigT2

/-- The K3 lattice signature works out to `(3,19)`, matching Huybrechts's Proposition 3.5
(eq. (3.4)). Proof: `sigK3` unfolds to a literal sum of `Signature` pairs, so both sides
reduce to the same normal form definitionally (`rfl`). -/
theorem sigK3_eq : sigK3 = ⟨3, 19⟩ := by
  rfl

/-- The Mukai lattice signature is `(4,20)`, matching Aspinwall's `Γ⁴'²⁰`. -/
theorem sigMukai_eq : sigMukai = ⟨4, 20⟩ := by
  rfl

/-- The full K3 × T² charge lattice has signature `(6,22)`. -/
theorem sigK3T2_eq : sigK3T2 = ⟨6, 22⟩ := by
  rfl

/-- The K3 lattice has rank `22 = 3 + 19`, matching `b₂(K3) = 22`. -/
theorem rank_K3 : sigK3.rank = 22 := by
  simp [Signature.rank, sigK3, sigE8Neg, sigU]
  <;> rfl

/-- The K3 × T² charge lattice has rank `28 = 6 + 22`. -/
theorem rank_K3T2 : sigK3T2.rank = 28 := by
  simp [Signature.rank, sigK3T2, sigMukai, sigT2, sigU, sigK3, sigE8Neg, sigU]
  <;> rfl

/-- The mod-8 constraint that any even unimodular indefinite lattice must satisfy
holds for all three (arithmetic only; the constraint itself is Tier L). Each conjunct is
checked at the specific numeric tuple (`(3,19)`, `(4,20)`, `(6,22)`) computed above — this
is not a proof of the general mod-8 theorem, only that these three instances satisfy it. -/
theorem index_mod_eight :
    sigK3.index % 8 = 0 ∧ sigMukai.index % 8 = 0 ∧ sigK3T2.index % 8 = 0 := by
  constructor
  · rfl
  constructor
  · rfl
  · rfl

/-- **Cross-check against Stream 1.** The lattice-decomposition signature of K3 equals
the Hodge-theoretic `(b₊, b₋) = (2h²'⁰+1, h¹'¹−1)` from `UseCases.K3Signature`. This is a
consistency check between two independently tabulated Tier L inputs — the `E8(−1)⊕2⊕U⊕3`
lattice decomposition on this side, the Hodge diamond of a K3 surface on Stream 1's side —
not an independent derivation of either number from the other. Proof: both sides reduce
to the literal naturals `3` and `19` by unfolding definitions (`rfl`/`simp` on the
`Signature` field projections). -/
theorem sigK3_matches_hodge :
    sigK3.pos = StringTheory.UseCases.K3Signature.bPlus ∧
    sigK3.neg = StringTheory.UseCases.K3Signature.bMinus := by
  constructor
  <;> rfl
  <;> simp [sigK3, sigE8Neg, sigU, Signature.pos, Signature.neg]
  <;> rfl

end DualScaleStream2.Lattice
