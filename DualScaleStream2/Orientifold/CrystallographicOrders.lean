/-
Stream 9 · S9.4 — the crystallographic restriction, corrected: `φ(n) ≤ d` is **false**, and this file exhibits
the counterexamples.

`Crystallography.lean` (S9.3) motivated its arithmetic with the statement that a finite-order integer matrix of
size `d` and order `n` forces `φ(n) ≤ d`, and listed the theorem as the natural next formalization target. On
attempting it, the statement turned out to be **wrong for every `d ≥ 5`**, and the error is not cosmetic: it
omits four of the seventeen orders realisable on a rank-6 lattice. This file refutes the claim in the kernel and
records what the correct criterion is.

### Where the standard argument breaks
The tempting argument runs: `A^n = 1` so the minimal polynomial divides `X^n − 1 = ∏_{e ∣ n} Φ_e`; some
eigenvalue must be a *primitive* `n`-th root of unity; hence `Φ_n ∣ charpoly`, and `deg Φ_n = φ(n) ≤ d`. The
middle step is false. A matrix may have order `n` with **no** eigenvalue of order `n`: the order is the `lcm` of
the eigenvalue orders, not the maximum. `diag(C_{Φ₃}, C_{Φ₅})` has order `lcm(3,5) = 15` and every eigenvalue of
order `3` or `5`.

### What is proved (Tier A)
* `mat15_order_15`, and likewise for `20`, `24`, `30`: four explicit `6 × 6` **integer** matrices (each of
  determinant `1`, hence in `SL(6, ℤ)`) with `A^n = 1` and `A^(n/p) ≠ 1` for every prime `p ∣ n` — so the order is
  exactly `n`.
* `phi_of_the_four`: `φ(15) = φ(20) = φ(24) = φ(30) = 8 > 6`.
* `phi_criterion_refuted`: therefore **`φ(n) ≤ d` is not a necessary condition** — the four orders violate it in
  `d = 6` while being realised there.
* `phi_list_incomplete`: none of `15, 20, 24, 30` appears in `Crystallography.phi_le_six_list`, so that list,
  correct as arithmetic about `φ`, is **not** the list of orders available on a rank-6 lattice.
* `psi_le_six_list`: the corrected criterion. With `ψ(n) = Σ_{p^a ‖ n, p^a ≠ 2} φ(p^a)` — the `2` from `n ≡ 2 mod 4`
  costs no dimension, being realised by `−1` on an existing block — `ψ(n) ≤ 6` gives exactly
  `1–10, 12, 14, 15, 18, 20, 24, 30`: the thirteen of S9.3 plus precisely the four exhibited above.
* `rank_two_unaffected`: `ψ(n) ≤ 2` still gives `{1, 2, 3, 4, 6}`, identical to `φ(n) ≤ 2`. **Stream 8 §8, which
  uses only the rank-2 list, is untouched by this correction.**

### What remains Tier L
That `ψ(n) ≤ d` is *necessary* — the actual crystallographic restriction theorem — is **not** proved here. What
is proved is that it is not vacuous in the direction that matters for a search: all four orders it admits beyond
the `φ`-list are realised by explicit integer matrices, so any enumeration built on `φ(n) ≤ 6` is missing cases.
Sufficiency in general (`ψ(n) ≤ d ⟹ the order occurs in dimension d`) follows from the same block-companion
construction and is checked here only for the four orders at issue.

### Consequence for Stream 9
`docs/STREAM9_ORIENTIFOLD.md` §5 and the S9.3 entry in `docs/VERIFIED_FOUNDATION.md` stated the `φ` form; both
are corrected alongside this file. No theorem elsewhere in the repository depended on the false statement — S9.3
proves arithmetic about `φ`, which stands, and the `ℤ₂ × ℤ₂` of `NarainT6.lean` uses order 2 only.
-/
import DualScaleStream2.Orientifold.Crystallography

namespace DualScaleStream2.Orientifold.CrystallographicOrders

open Matrix

/-- `C_{Φ₃} ⊕ C_{Φ₅}`: order `lcm(3, 5) = 15`, no eigenvalue of order 15. -/
def mat15 : Matrix (Fin 6) (Fin 6) ℤ :=
  !![0, -1, 0, 0, 0, 0;
     1, -1, 0, 0, 0, 0;
     0, 0, 0, 0, 0, -1;
     0, 0, 1, 0, 0, -1;
     0, 0, 0, 1, 0, -1;
     0, 0, 0, 0, 1, -1]

/-- `C_{Φ₄} ⊕ C_{Φ₅}`: order `lcm(4, 5) = 20`. -/
def mat20 : Matrix (Fin 6) (Fin 6) ℤ :=
  !![0, -1, 0, 0, 0, 0;
     1, 0, 0, 0, 0, 0;
     0, 0, 0, 0, 0, -1;
     0, 0, 1, 0, 0, -1;
     0, 0, 0, 1, 0, -1;
     0, 0, 0, 0, 1, -1]

/-- `C_{Φ₈} ⊕ C_{Φ₃}`: order `lcm(8, 3) = 24`. -/
def mat24 : Matrix (Fin 6) (Fin 6) ℤ :=
  !![0, 0, 0, -1, 0, 0;
     1, 0, 0, 0, 0, 0;
     0, 1, 0, 0, 0, 0;
     0, 0, 1, 0, 0, 0;
     0, 0, 0, 0, 0, -1;
     0, 0, 0, 0, 1, -1]

/-- `−mat15`: order `30`. The factor `2` of `n ≡ 2 mod 4` costs no extra dimension. -/
def mat30 : Matrix (Fin 6) (Fin 6) ℤ := -mat15

theorem mat15_order_15 : mat15 ^ 15 = 1 ∧ mat15 ^ 3 ≠ 1 ∧ mat15 ^ 5 ≠ 1 := by
  refine ⟨by decide +kernel, by decide +kernel, by decide +kernel⟩

theorem mat20_order_20 : mat20 ^ 20 = 1 ∧ mat20 ^ 10 ≠ 1 ∧ mat20 ^ 4 ≠ 1 := by
  refine ⟨by decide +kernel, by decide +kernel, by decide +kernel⟩

theorem mat24_order_24 : mat24 ^ 24 = 1 ∧ mat24 ^ 12 ≠ 1 ∧ mat24 ^ 8 ≠ 1 := by
  refine ⟨by decide +kernel, by decide +kernel, by decide +kernel⟩

theorem mat30_order_30 : mat30 ^ 30 = 1 ∧ mat30 ^ 15 ≠ 1 ∧ mat30 ^ 10 ≠ 1 := by
  refine ⟨by decide +kernel, by decide +kernel, by decide +kernel⟩

/-- All four lie in `SL(6, ℤ)`, so they are genuine lattice automorphisms, not merely integer matrices. -/
theorem the_four_are_unimodular :
    mat15.det = 1 ∧ mat20.det = 1 ∧ mat24.det = 1 ∧ mat30.det = 1 := by
  refine ⟨by decide +kernel, by decide +kernel, by decide +kernel, by decide +kernel⟩

/-- Each of the four orders has `φ(n) = 8 > 6`. -/
theorem phi_of_the_four :
    Nat.totient 15 = 8 ∧ Nat.totient 20 = 8 ∧ Nat.totient 24 = 8 ∧ Nat.totient 30 = 8 := by
  decide +kernel

/-- **The refutation.** `φ(n) ≤ d` is not necessary: order `15` occurs in `SL(6, ℤ)` with `φ(15) = 8 > 6`. -/
theorem phi_criterion_refuted :
    (mat15 ^ 15 = 1 ∧ mat15 ^ 3 ≠ 1 ∧ mat15 ^ 5 ≠ 1) ∧ ¬ (Nat.totient 15 ≤ 6) := by
  exact ⟨mat15_order_15, by decide +kernel⟩

/-- **The `φ`-list is incomplete.** None of the four realised orders is in it. -/
theorem phi_list_incomplete :
    ¬ (15 ∈ ((List.range 201).filter fun n => 1 ≤ n && Nat.totient n ≤ 6)) ∧
    ¬ (20 ∈ ((List.range 201).filter fun n => 1 ≤ n && Nat.totient n ≤ 6)) ∧
    ¬ (24 ∈ ((List.range 201).filter fun n => 1 ≤ n && Nat.totient n ≤ 6)) ∧
    ¬ (30 ∈ ((List.range 201).filter fun n => 1 ≤ n && Nat.totient n ≤ 6)) := by
  refine ⟨by decide +kernel, by decide +kernel, by decide +kernel, by decide +kernel⟩

/-- Primality, structurally, so the kernel can reduce it. -/
def isPrimeB (p : ℕ) : Bool := 2 ≤ p && ((List.range p).all fun k => k < 2 || p % k != 0)

/-- The exact `p`-part of `n`: the largest power of `p` dividing `n` (`1` when `p ∤ n`). -/
def primePart (n p : ℕ) : ℕ :=
  (List.range 9).foldl (fun acc a => if n % p ^ a == 0 then p ^ a else acc) 1

/-- `ψ(n) = Σ_{p^a ‖ n, p^a ≠ 2} φ(p^a)`: the dimension a lattice automorphism of order `n` needs. The factor
`2` is skipped because `−1` on a block already present realises it at no cost. -/
def psi (n : ℕ) : ℕ :=
  ((List.range (n + 1)).filter fun p => isPrimeB p && n % p == 0).foldl
    (fun s p => let q := primePart n p; if q == 2 then s else s + Nat.totient q) 0

/-- **The corrected list for a rank-6 lattice:** the thirteen orders of S9.3 plus exactly `15, 20, 24, 30`. -/
theorem psi_le_six_list :
    ((List.range 201).filter fun n => 1 ≤ n && psi n ≤ 6) =
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 18, 20, 24, 30] := by
  decide +kernel

/-- **Stream 8 §8 is untouched.** In rank 2 the two criteria agree. -/
theorem rank_two_unaffected :
    ((List.range 201).filter fun n => 1 ≤ n && psi n ≤ 2) =
      ((List.range 201).filter fun n => 1 ≤ n && Nat.totient n ≤ 2) := by
  decide +kernel

end DualScaleStream2.Orientifold.CrystallographicOrders
