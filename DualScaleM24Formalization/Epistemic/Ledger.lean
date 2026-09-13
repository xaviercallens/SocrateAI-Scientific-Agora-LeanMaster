import DualScaleM24Formalization.Epistemic.Tier

/-!
# Stream 0 Epistemic Ledger & Transitive Soundness Theorem
Mathematical core formalized directly in DualScaleM24Formalization.

WHAT THIS MODULE PROVES:
  1. `tier_le_of_depends`: In a sound ledger, a claim never outranks anything in its transitive support set.
  2. `no_kernel_claim_rests_on_weaker`: In a sound ledger, the entire transitive support set of a Tier A claim is Tier A.
  3. `not_A_of_weak_support`: Contrapositive ensuring no weaker claim can secretly support a Tier A claim.
  4. Non-vacuity witnesses: Proves positive control and negative control with zero sorry axioms.
-/

namespace SocrateAI.Epistemic

/-- A single ledger row: the tier it is filed at, and the claims it rests on. -/
structure Claim (ι : Type) where
  tier : Tier
  supports : List ι
deriving Repr

/-- A ledger is an assignment of rows to identifiers. -/
abbrev Ledger (ι : Type) := ι → Claim ι

/-- **The Soundness Condition.** No claim is filed at a tier above any claim it directly cites. -/
def Sound {ι : Type} (L : Ledger ι) : Prop :=
  ∀ a b, b ∈ (L a).supports → (L a).tier ≤ (L b).tier

/-- Transitive dependency: `Depends L a b` means claim `a` rests on claim `b`,
directly or through a chain. -/
inductive Depends {ι : Type} (L : Ledger ι) : ι → ι → Prop where
  | direct {a b} : b ∈ (L a).supports → Depends L a b
  | step {a b c} : b ∈ (L a).supports → Depends L b c → Depends L a c

namespace Depends

theorem trans {ι : Type} {L : Ledger ι} {a b c : ι}
    (hab : Depends L a b) (hbc : Depends L b c) : Depends L a c := by
  induction hab with
  | direct h => exact Depends.step h hbc
  | step h _ ih => exact Depends.step h (ih hbc)

end Depends

/-- **Transitive Tier Monotonicity.** In a sound ledger, a claim never outranks
anything in its transitive support set. -/
theorem tier_le_of_depends {ι : Type} {L : Ledger ι} (hL : Sound L) :
    ∀ {a b : ι}, Depends L a b → (L a).tier ≤ (L b).tier := by
  intro a b h
  induction h with
  | direct hmem => exact hL _ _ hmem
  | step hmem _ ih => exact tier_trans (hL _ _ hmem) ih

/-- **Corollary: A kernel claim rests only on kernel claims.** In a sound ledger,
the entire transitive support set of a Tier A row is Tier A. -/
theorem no_kernel_claim_rests_on_weaker {ι : Type} {L : Ledger ι} (hL : Sound L)
    {a b : ι} (ha : (L a).tier = Tier.A) (hab : Depends L a b) :
    (L b).tier = Tier.A := by
  have hle : (L a).tier ≤ (L b).tier := tier_le_of_depends hL hab
  rw [ha] at hle
  exact eq_A_of_A_le hle

/-- Contrapositive: If anything in the transitive support set is below `A`,
the citing claim is below `A` too. -/
theorem not_A_of_weak_support {ι : Type} {L : Ledger ι} (hL : Sound L)
    {a b : ι} (hab : Depends L a b) (hb : (L b).tier ≠ Tier.A) :
    (L a).tier ≠ Tier.A :=
  fun ha => hb (no_kernel_claim_rests_on_weaker hL ha hab)

/-- Positive Control Witness: A valid sound ledger with verified dependency. -/
def witnessSound : Ledger (Fin 3)
  | 0 => { tier := Tier.A, supports := [1] }
  | 1 => { tier := Tier.A, supports := [] }
  | 2 => { tier := Tier.C, supports := [] }

theorem witnessSound_sound : Sound witnessSound := by
  intro a b hmem
  revert a b hmem
  decide

/-- Negative Control Witness: An unsound ledger where A cites C must be rejected. -/
def witnessUnsound : Ledger (Fin 2)
  | 0 => { tier := Tier.A, supports := [1] }
  | 1 => { tier := Tier.C, supports := [] }

theorem witnessUnsound_not_sound : ¬ Sound witnessUnsound := by
  intro h
  have h01 : (1 : Fin 2) ∈ (witnessUnsound 0).supports := by decide
  have hle := h 0 1 h01
  revert hle
  decide

end SocrateAI.Epistemic
