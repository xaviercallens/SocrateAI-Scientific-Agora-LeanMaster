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
-/
import DualScaleStream2.Lattice.Basic
import StringTheoryFormalization.UseCases.K3SignatureTheorem

namespace DualScaleStream2.Lattice

/-- Signature `(b₊, b₋)` of a non-degenerate real quadratic form. -/
structure Signature where
  pos : ℕ
  neg : ℕ
  deriving DecidableEq, Repr

namespace Signature

instance : Add Signature := ⟨fun a b => ⟨a.pos + b.pos, a.neg + b.neg⟩⟩

@[simp] theorem add_pos (a b : Signature) : (a + b).pos = a.pos + b.pos := rfl
@[simp] theorem add_neg (a b : Signature) : (a + b).neg = a.neg + b.neg := rfl

def rank (s : Signature) : ℕ := s.pos + s.neg

/-- `b₊ − b₋`. -/
def index (s : Signature) : ℤ := (s.pos : ℤ) - s.neg

end Signature

/-- `U` (Tier L input). -/
def sigU : Signature := ⟨1, 1⟩
/-- `E8(−1)` (Tier L input). -/
def sigE8Neg : Signature := ⟨0, 8⟩

/-- K3 lattice `E8(−1)⊕2 ⊕ U⊕3`. -/
def sigK3 : Signature := sigE8Neg + sigE8Neg + sigU + sigU + sigU
/-- Mukai lattice `Γ⁴'²⁰ = Γ³'¹⁹ ⊕ U`. -/
def sigMukai : Signature := sigK3 + sigU
/-- `T²` Narain lattice `Γ²'² = U ⊕ U`. -/
def sigT2 : Signature := sigU + sigU
/-- K3 × T² charge lattice `Γ⁶'²² = Γ⁴'²⁰ ⊕ Γ²'²`. -/
def sigK3T2 : Signature := sigMukai + sigT2

theorem sigK3_eq : sigK3 = ⟨3, 19⟩ := by
  rfl

theorem sigMukai_eq : sigMukai = ⟨4, 20⟩ := by
  rfl

theorem sigK3T2_eq : sigK3T2 = ⟨6, 22⟩ := by
  rfl

theorem rank_K3 : sigK3.rank = 22 := by
  simp [Signature.rank, sigK3, sigE8Neg, sigU]
  <;> rfl

theorem rank_K3T2 : sigK3T2.rank = 28 := by
  simp [Signature.rank, sigK3T2, sigMukai, sigT2, sigU, sigK3, sigE8Neg, sigU]
  <;> rfl

/-- The mod-8 constraint that any even unimodular indefinite lattice must satisfy
holds for all three (arithmetic only; the constraint itself is Tier L). -/
theorem index_mod_eight :
    sigK3.index % 8 = 0 ∧ sigMukai.index % 8 = 0 ∧ sigK3T2.index % 8 = 0 := by
  constructor
  · rfl
  constructor
  · rfl
  · rfl

/-- **Cross-check against Stream 1.** The lattice-decomposition signature of K3 equals
the Hodge-theoretic `(b₊, b₋) = (2h²'⁰+1, h¹'¹−1)` from `UseCases.K3Signature`. -/
theorem sigK3_matches_hodge :
    sigK3.pos = StringTheory.UseCases.K3Signature.bPlus ∧
    sigK3.neg = StringTheory.UseCases.K3Signature.bMinus := by
  constructor
  <;> rfl
  <;> simp [sigK3, sigE8Neg, sigU, Signature.pos, Signature.neg]
  <;> rfl

end DualScaleStream2.Lattice
