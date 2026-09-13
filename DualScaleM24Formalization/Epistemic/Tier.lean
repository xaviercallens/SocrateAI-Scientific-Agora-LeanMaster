/-!
# Stream 0 Epistemic Tier System
Derived from SocrateAI-Mathesis notation framework.

Five tiers in strict linear order:
  X < C < L < B < A
  A: Kernel-verified (Lean 4, zero sorry, declared axiom footprint)
  B: Exact-arithmetic (deterministic ℚ/ℤ check + negative control that fails)
  L: Literature (peer-reviewed, quoted theorem statement)
  C: Conjecture (proposal, analogy, unverified reduction)
  X: Exploratory (floats, sampling, LLM output)
-/

namespace SocrateAI.Epistemic

inductive Tier : Type where
  | X : Tier  -- Exploratory / Float
  | C : Tier  -- Conjecture
  | L : Tier  -- Literature
  | B : Tier  -- Exact-Arithmetic Checkable
  | A : Tier  -- Kernel-Verified (Lean 4, zero sorry)
deriving DecidableEq, Repr

def Tier.toNat : Tier → Nat
  | Tier.X => 0
  | Tier.C => 1
  | Tier.L => 2
  | Tier.B => 3
  | Tier.A => 4

def Tier.le (t1 t2 : Tier) : Prop :=
  t1.toNat ≤ t2.toNat

instance : LE Tier where
  le := Tier.le

instance (t1 t2 : Tier) : Decidable (t1 ≤ t2) :=
  inferInstanceAs (Decidable (t1.toNat ≤ t2.toNat))

theorem tier_refl (t : Tier) : t ≤ t := by
  change t.toNat ≤ t.toNat
  omega

theorem tier_trans {t1 t2 t3 : Tier} (h12 : t1 ≤ t2) (h23 : t2 ≤ t3) : t1 ≤ t3 := by
  change t1.toNat ≤ t3.toNat
  have h1 : t1.toNat ≤ t2.toNat := h12
  have h2 : t2.toNat ≤ t3.toNat := h23
  omega

theorem tier_antisymm {t1 t2 : Tier} (h12 : t1 ≤ t2) (h21 : t2 ≤ t1) : t1 = t2 := by
  have h1 : t1.toNat ≤ t2.toNat := h12
  have h2 : t2.toNat ≤ t1.toNat := h21
  have heq : t1.toNat = t2.toNat := Nat.le_antisymm h1 h2
  cases t1 <;> cases t2 <;> first | rfl | contradiction

theorem tier_A_is_maximal (t : Tier) : t ≤ Tier.A := by
  change t.toNat ≤ Tier.A.toNat
  cases t <;> decide

theorem tier_X_is_minimal (t : Tier) : Tier.X ≤ t := by
  change Tier.X.toNat ≤ t.toNat
  cases t <;> decide

theorem eq_A_of_A_le {s : Tier} (h : Tier.A ≤ s) : s = Tier.A := by
  cases s <;> first | rfl | exact absurd h (by decide)

end SocrateAI.Epistemic
