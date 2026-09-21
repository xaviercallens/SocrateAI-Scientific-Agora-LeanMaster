/-
S9.4b, the arithmetic half: `ψ(n) ≤ Σ_{e ∈ S} φ(e)` whenever `lcm S = n`.

### Why this is the half worth doing first
The crystallographic restriction in its correct form (`docs/STREAM9_ORIENTIFOLD.md` §5b, §5c) says that a
rank-`d` lattice carries an automorphism of order `n` only if `ψ(n) ≤ d`, where
`ψ(n) = Σ_{p^a ‖ n, p^a ≠ 2} φ(p^a)`. Its proof splits:

* **linear algebra** (not here, Tier L): `ℚ^d` is a `ℚ[X]/(Xⁿ − 1)`-module, decompose into `Φ_e`-isotypic
  parts, and `d ≥ Σ_{e ∈ S} φ(e)` where `S = {e : Φ_e ∣ minpoly A}` — with, crucially, `n = lcm S`, because a
  matrix's order is the `lcm` of its eigenvalue orders and **not** the largest of them (that confusion is what
  made the `φ(n) ≤ d` form false; §5b);
* **arithmetic** (this file, Tier A): for *any* finite set `S` of positive integers with `lcm S = n`,
  `Σ_{e ∈ S} φ(e) ≥ ψ(n)`.

The second is what makes the criterion sharp, and it needs no representation theory. Composing the two gives
`d ≥ ψ(n)`.

### The argument
Each maximal prime power `q = p^{v_p(n)}` of `n` divides *some* `e ∈ S` (the `p`-adic valuation of a `lcm` is
the `sup` of the valuations, and a `sup` over a finite set is attained). Group the prime powers by the `e`
chosen for them. Within one group the `q`'s are pairwise coprime, so their product divides `e`, and
`φ` is monotone along divisibility; multiplicativity turns `φ(∏ q)` into `∏ φ(q)`. Finally `∏ xᵢ ≥ Σ xᵢ` once
every `xᵢ ≥ 2` — which is exactly why `ψ` omits the `p^a = 2` term, the only prime power with `φ = 1`.

### Scope
Pure number theory about `Nat.totient`. Nothing here is about lattices, and composing it with the linear
algebra above is *not* done in this file — see §5c for what remains.
-/
import Mathlib.Data.Nat.Totient
import Mathlib.Data.Nat.Factorization.Basic
import Mathlib.Algebra.GCDMonoid.FinsetLemmas
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Data.Nat.GCD.BigOperators
import Mathlib.Data.Nat.Log
import DualScaleStream2.Orientifold.CrystallographicOrders
import Mathlib.RingTheory.Polynomial.Cyclotomic.Basic
import Mathlib.LinearAlgebra.Matrix.Charpoly.Minpoly
import Mathlib.Algebra.Polynomial.BigOperators

namespace DualScaleStream2.Orientifold.CrystallographicArithmetic

open Finset

/-! ### 1. `∏ ≥ Σ` once every factor is at least `2` -/

/-- A product of naturals each `≥ 2` is at least their sum. Equality at one factor; the `2 ≤ xᵢ`
hypothesis is sharp, since a factor `1` adds to the sum and does nothing to the product. -/
theorem sum_le_prod {ι : Type*} (t : Finset ι) (x : ι → ℕ) (hx : ∀ i ∈ t, 2 ≤ x i) :
    ∑ i ∈ t, x i ≤ ∏ i ∈ t, x i := by
  classical
  induction t using Finset.induction with
  | empty => simp
  | @insert a s ha ih =>
    have hxa : 2 ≤ x a := hx a (mem_insert_self a s)
    have hs : ∀ i ∈ s, 2 ≤ x i := fun i hi => hx i (mem_insert_of_mem hi)
    have hsum : ∑ i ∈ s, x i ≤ ∏ i ∈ s, x i := ih hs
    have hpos : 1 ≤ ∏ i ∈ s, x i :=
      Nat.one_le_iff_ne_zero.mpr (Finset.prod_ne_zero_iff.mpr fun i hi => by
        have := hs i hi; omega)
    rw [Finset.sum_insert ha, Finset.prod_insert ha]
    rcases Finset.eq_empty_or_nonempty s with rfl | hne
    · simp
    · -- `s` nonempty and every factor ≥ 2 gives `∏_s ≥ 2`; then
      -- `x a * ∏_s - x a - ∏_s = (x a - 1)(∏_s - 1) - 1 ≥ 0`.
      have h2 : 2 ≤ ∏ i ∈ s, x i := by
        obtain ⟨b, hb⟩ := hne
        exact le_trans (hs b hb)
          (Finset.single_le_prod' (fun i hi => le_trans (by norm_num) (hs i hi)) hb)
      nlinarith [hsum, hxa, h2]

/-! ### 2. `φ` of a maximal prime power of `n` is at least `2`, unless that prime power is `2` -/

/-- For a prime power `q = p ^ a` with `a ≥ 1` and `q ≠ 2`, `φ q ≥ 2`. This is the reason `ψ` may drop the
`p^a = 2` term and no other: `φ 2 = 1`. -/
theorem two_le_totient_prime_pow {p a : ℕ} (hp : p.Prime) (ha : 1 ≤ a) (hne : p ^ a ≠ 2) :
    2 ≤ Nat.totient (p ^ a) := by
  have hpos : 0 < Nat.totient (p ^ a) := Nat.totient_pos.mpr (pow_pos hp.pos a)
  rcases Nat.lt_or_ge (Nat.totient (p ^ a)) 2 with h | h
  · have h1 : Nat.totient (p ^ a) = 1 := by omega
    rcases Nat.totient_eq_one_iff.mp h1 with h2 | h2
    · -- `p ^ a = 1` is impossible: `p ≥ 2` and `a ≥ 1` give `p ^ a ≥ 2`.
      have : 2 ≤ p ^ a := le_trans hp.two_le (Nat.le_self_pow (by omega) p)
      omega
    · exact absurd h2 hne
  · exact h

/-! ### 3. Each maximal prime power of `n` divides some member of `S` -/

/-- The `p`-adic valuation of a `Finset.lcm` is the `sup` of the valuations, and a `sup` over a nonempty
finite set is attained — so the exact `p`-part of `n` divides one of the `e`. This is the only place the
hypothesis `lcm S = n` is used, and it is where the `φ(n) ≤ d` form of the restriction goes wrong: the order
is the `lcm` of the `e`, not the largest of them. -/
theorem exists_dvd_of_lcm {S : Finset ℕ} (hS : ∀ e ∈ S, e ≠ 0) {n : ℕ}
    (hlcm : S.lcm id = n) {p : ℕ} (hp : p ∈ n.primeFactors) :
    ∃ e ∈ S, p ^ n.factorization p ∣ e := by
  classical
  have hprime : p.Prime := Nat.prime_of_mem_primeFactors hp
  have hne : S.Nonempty := by
    rcases Finset.eq_empty_or_nonempty S with rfl | h
    · -- an empty `S` forces `n = 1`, which has no prime factors
      rw [Finset.lcm_empty] at hlcm
      rw [← hlcm] at hp
      simp at hp
    · exact h
  have hfac : n.factorization p = S.sup fun a => (id a).factorization p := by
    rw [← hlcm]; exact Finset.factorization_lcm hS p
  obtain ⟨e, he, hsup⟩ := Finset.exists_mem_eq_sup S hne (fun a => (id a).factorization p)
  refine ⟨e, he, ?_⟩
  have heq : n.factorization p = e.factorization p := by rw [hfac, hsup]; rfl
  rw [heq]
  exact (Nat.Prime.pow_dvd_iff_le_factorization hprime (hS e he)).mpr le_rfl

/-! ### 4. Two Finset bridges Mathlib does not carry -/

/-- `φ` is multiplicative over a pairwise-coprime family. Mathlib has `Nat.totient_mul` for two factors
only. -/
theorem totient_prod_of_pairwise_coprime {ι : Type*} [DecidableEq ι] (t : Finset ι) (f : ι → ℕ)
    (h : (t : Set ι).Pairwise (Nat.Coprime.onFun f)) :
    Nat.totient (∏ i ∈ t, f i) = ∏ i ∈ t, Nat.totient (f i) := by
  induction t using Finset.induction with
  | empty => simp
  | @insert a r har ih =>
    have hcop : Nat.Coprime (f a) (∏ i ∈ r, f i) :=
      Nat.Coprime.prod_right fun i hi =>
        h (Finset.mem_insert_self a r) (Finset.mem_insert_of_mem hi)
          (by rintro rfl; exact har hi)
    rw [Finset.prod_insert har, Nat.totient_mul hcop, Finset.prod_insert har,
      ih (h.mono (by simp))]

/-- A pairwise-coprime family of divisors of `z` has its product dividing `z`. -/
theorem prod_dvd_of_pairwise_coprime {ι : Type*} [DecidableEq ι] (t : Finset ι) (f : ι → ℕ) (z : ℕ)
    (h : (t : Set ι).Pairwise (Nat.Coprime.onFun f)) (hd : ∀ i ∈ t, f i ∣ z) :
    (∏ i ∈ t, f i) ∣ z := by
  induction t using Finset.induction with
  | empty => simp
  | @insert a r har ih =>
    have hcop : Nat.Coprime (f a) (∏ i ∈ r, f i) :=
      Nat.Coprime.prod_right fun i hi =>
        h (Finset.mem_insert_self a r) (Finset.mem_insert_of_mem hi)
          (by rintro rfl; exact har hi)
    rw [Finset.prod_insert har]
    exact Nat.Coprime.mul_dvd_of_dvd_of_dvd hcop (hd a (Finset.mem_insert_self a r))
      (ih (h.mono (by simp))
        fun i hi => hd i (Finset.mem_insert_of_mem hi))

/-! ### 5. `ψ`, and the theorem -/

/-- `ψ(n) = Σ_{p^a ‖ n, p^a ≠ 2} φ(p^a)`, stated with Mathlib's `Nat.factorization` so that it is correct
for every `n` — unlike the computable `psi` of `CrystallographicOrders.lean`, whose exponent cap made it
wrong above `p^8` until 2026-09-21 (`docs/STREAM9_ORIENTIFOLD.md` §5b-bis). -/
noncomputable def psiM (n : ℕ) : ℕ :=
  ∑ p ∈ n.primeFactors.filter fun p => p ^ n.factorization p ≠ 2,
    Nat.totient (p ^ n.factorization p)

/-- **S9.4b, arithmetic half.** For any finite set `S` of nonzero naturals whose `lcm` is `n`,
`ψ(n) ≤ Σ_{e ∈ S} φ(e)`.

Composed with the linear-algebra half — `ℚ^d` as a `ℚ[X]/(Xⁿ−1)`-module has `d ≥ Σ_{e ∈ S} φ(e)` for
`S = {e : Φ_e ∣ minpoly A}` with `n = lcm S`, which is **not** proved here (Tier L, §5c) — this gives the
crystallographic restriction `ψ(n) ≤ d`.

The `lcm` hypothesis is the whole content: it is what the `φ(n) ≤ d` form got wrong, since a matrix's order
is the `lcm` of its eigenvalue orders and not the largest of them. -/
theorem psiM_le_sum_totient {S : Finset ℕ} (hS : ∀ e ∈ S, e ≠ 0) {n : ℕ}
    (hlcm : S.lcm id = n) : psiM n ≤ ∑ e ∈ S, Nat.totient e := by
  classical
  set T := n.primeFactors.filter fun p => p ^ n.factorization p ≠ 2 with hT
  -- a TOTAL choice function, so no subtypes appear below
  have hchoice : ∀ p : ℕ, ∃ e : ℕ, p ∈ T → e ∈ S ∧ p ^ n.factorization p ∣ e := by
    intro p
    by_cases hp : p ∈ T
    · obtain ⟨e, he, hd⟩ := exists_dvd_of_lcm hS hlcm (Finset.mem_of_mem_filter p hp)
      exact ⟨e, fun _ => ⟨he, hd⟩⟩
    · exact ⟨0, fun h => absurd h hp⟩
  choose g hg using hchoice
  have hmaps : ∀ p ∈ T, g p ∈ S := fun p hp => (hg p hp).1
  have hstep : ∀ e ∈ S,
      ∑ p ∈ T.filter fun p => g p = e, Nat.totient (p ^ n.factorization p) ≤ Nat.totient e := by
    intro e he
    set F := T.filter fun p => g p = e with hF
    have hfacts : ∀ p ∈ F, p.Prime ∧ 1 ≤ n.factorization p ∧ p ^ n.factorization p ≠ 2 := by
      intro p hp
      have hpT : p ∈ T := Finset.mem_of_mem_filter p hp
      have hmem : p ∈ n.primeFactors := Finset.mem_of_mem_filter p hpT
      obtain ⟨hprime, hdvd, hn0⟩ := Nat.mem_primeFactors.mp hmem
      exact ⟨hprime, Nat.Prime.factorization_pos_of_dvd hprime hn0 hdvd,
        (Finset.mem_filter.mp hpT).2⟩
    have hcop : (F : Set ℕ).Pairwise
        (Nat.Coprime.onFun fun p => p ^ n.factorization p) := by
      intro a ha b hb hab
      exact Nat.Coprime.pow _ _
        ((Nat.coprime_primes (hfacts a (by simpa using ha)).1 (hfacts b (by simpa using hb)).1).mpr hab)
    have hdvd : ∀ p ∈ F, p ^ n.factorization p ∣ e := by
      intro p hp
      have hpT : p ∈ T := Finset.mem_of_mem_filter p hp
      have : g p = e := (Finset.mem_filter.mp hp).2
      exact this ▸ (hg p hpT).2
    calc ∑ p ∈ F, Nat.totient (p ^ n.factorization p)
        ≤ ∏ p ∈ F, Nat.totient (p ^ n.factorization p) :=
          sum_le_prod F _ fun p hp =>
            two_le_totient_prime_pow (hfacts p hp).1 (hfacts p hp).2.1 (hfacts p hp).2.2
      _ = Nat.totient (∏ p ∈ F, p ^ n.factorization p) :=
          (totient_prod_of_pairwise_coprime F _ hcop).symm
      _ ≤ Nat.totient e :=
          Nat.le_of_dvd (Nat.totient_pos.mpr (Nat.pos_of_ne_zero (hS e he)))
            (Nat.totient_dvd_of_dvd (prod_dvd_of_pairwise_coprime F _ e hcop hdvd))
  calc psiM n = ∑ p ∈ T, Nat.totient (p ^ n.factorization p) := by rw [psiM, hT]
    _ = ∑ e ∈ S, ∑ p ∈ T.filter fun p => g p = e, Nat.totient (p ^ n.factorization p) :=
        (Finset.sum_fiberwise_of_maps_to hmaps _).symm
    _ ≤ ∑ e ∈ S, Nat.totient e := Finset.sum_le_sum hstep

/-! ### 6. Non-vacuity: the theorem instantiated, and the bound is attained -/

/-- The lower-bound direction, so that `psiM` is not left as something only ever bounded above: every
maximal prime power of `n` other than `2` contributes at least its own `φ`. -/
theorem totient_le_psiM {n p : ℕ} (hp : p ∈ n.primeFactors) (hne : p ^ n.factorization p ≠ 2) :
    Nat.totient (p ^ n.factorization p) ≤ psiM n :=
  Finset.single_le_sum (f := fun q => Nat.totient (q ^ n.factorization q))
    (fun _ _ => Nat.zero_le _) (Finset.mem_filter.mpr ⟨hp, hne⟩)

/-- **The theorem is not vacuous, and it is sharp at `n = 15`.** Taking `S = {3, 5}` — `lcm = 15`, and
`φ(3) + φ(5) = 2 + 4 = 6` — gives `ψ(15) ≤ 6`. That is exactly the rank at which §5b exhibits `mat15`, an
explicit order-`15` element of `SL(6, ℤ)`: the arithmetic bound does not exclude what the matrix realises,
and `φ(15) = 8 > 6` would have. A bound that could not be attained would be evidence of an error in it.

**What these two corollaries do NOT establish.** They are upper bounds, so on their own they are consistent
with `psiM` being identically `0`. `totient_le_psiM` gives the other direction in general, but **no numeric
value of `psiM` is pinned in the kernel here**, and that gap is narrower than it was but still real:

* **Closed (§7):** `primePart_eq_ord_proj` proves `primePart n p = p ^ n.factorization p` for prime `p` and
  `n ≠ 0` — the identification `primePart`'s name asserts, now a theorem rather than a docstring claim, and
  *false* before the 2026-09-21 correction.
* **Also closed (§8), and this paragraph is corrected accordingly:** `psiM_eq_psi` proves `psiM n = psi n`
  for `n ≠ 0`, via `isPrimeB_iff`, `psiList_toFinset` and `foldl_add_eq`. So `psiM`'s values **are** pinned
  after all — `psiM_values` gives `ψ(15) = ψ(20) = ψ(24) = ψ(30) = 6`, *equalities*, not the upper bounds the
  corollaries below give on their own — and `psi_le_six_list`'s enumeration transfers (`psiM_le_six_list`).
* **Why the direct route still fails, recorded so it is not retried:** `Nat.primeFactors 15 = {3, 5}` does
  **not** reduce under `decide` (the `Multiset` permutation instance gets stuck) and `simp` makes no progress.
  The values are reachable only *through* the computable `psi`, which is what the bridge is for. -/
theorem psiM_fifteen_le_six : psiM 15 ≤ 6 := by
  have h : psiM 15 ≤ ∑ e ∈ ({3, 5} : Finset ℕ), Nat.totient e :=
    psiM_le_sum_totient (S := ({3, 5} : Finset ℕ)) (by decide)
      (show ({3, 5} : Finset ℕ).lcm id = 15 by decide)
  have hsum : ∑ e ∈ ({3, 5} : Finset ℕ), Nat.totient e = 6 := by decide
  omega

/-- The same at `n = 24`, the largest of the four orders §5b exhibits in rank `6`: `S = {8, 3}`,
`φ(8) + φ(3) = 4 + 2 = 6`. -/
theorem psiM_twentyfour_le_six : psiM 24 ≤ 6 := by
  have h : psiM 24 ≤ ∑ e ∈ ({8, 3} : Finset ℕ), Nat.totient e :=
    psiM_le_sum_totient (S := ({8, 3} : Finset ℕ)) (by decide)
      (show ({8, 3} : Finset ℕ).lcm id = 24 by decide)
  have hsum : ∑ e ∈ ({8, 3} : Finset ℕ), Nat.totient e = 6 := by decide
  omega

/-! ### 7. The bridge to the computable `primePart` / `psi` -/

open DualScaleStream2.Orientifold.CrystallographicOrders in
/-- The defining fold of `primePart`, as a one-step recursion. -/
private theorem foldPow_succ (n p m : ℕ) :
    (List.range (m + 1)).foldl (fun acc a => if n % p ^ a == 0 then p ^ a else acc) 1
      = if n % p ^ m == 0 then p ^ m else
          (List.range m).foldl (fun acc a => if n % p ^ a == 0 then p ^ a else acc) 1 := by
  rw [List.range_succ, List.foldl_append]
  simp

open DualScaleStream2.Orientifold.CrystallographicOrders in
/-- Past the exact valuation the fold is constant: no larger power of `p` divides `n`. -/
private theorem foldPow_stable (n p : ℕ) (hn : n ≠ 0) (hp : p.Prime) :
    ∀ m, n.factorization p + 1 ≤ m →
      (List.range m).foldl (fun acc a => if n % p ^ a == 0 then p ^ a else acc) 1
        = p ^ n.factorization p := by
  intro m hm
  induction m with
  | zero => omega
  | succ k ih =>
    rw [foldPow_succ]
    rcases Nat.lt_or_ge (n.factorization p) k with hk | hk
    · -- `k > v`, so `p ^ k ∤ n` and the fold does not update
      have hnd : ¬ p ^ k ∣ n := fun hdvd =>
        Nat.pow_succ_factorization_not_dvd hn hp
          (dvd_trans (pow_dvd_pow p (by omega)) hdvd)
      have hb : (n % p ^ k == 0) = false := by
        simpa [Nat.dvd_iff_mod_eq_zero] using hnd
      rw [hb]
      simpa using ih (by omega)
    · -- `k ≤ v` and `v + 1 ≤ k + 1` force `k = v`; here the fold updates to `p ^ v`
      have hkv : k = n.factorization p := by omega
      have hdvd : p ^ k ∣ n :=
        hkv ▸ (Nat.Prime.pow_dvd_iff_le_factorization hp hn).mpr le_rfl
      have hb : (n % p ^ k == 0) = true := by simpa [Nat.dvd_iff_mod_eq_zero] using hdvd
      rw [hb, hkv]
      simp

open DualScaleStream2.Orientifold.CrystallographicOrders in
/-- **`primePart` is the exact `p`-part of `n`** — the identification its name asserts, now in the kernel
rather than in its docstring. Before 2026-09-21 this statement was *false* (`primePart 512 2 = 256`), and
nothing in the file could see that, because every use sat inside `List.range 201`; `LL.md` §S11.1. -/
theorem primePart_eq_ord_proj {n p : ℕ} (hn : n ≠ 0) (hp : p.Prime) :
    primePart n p = p ^ n.factorization p := by
  have hle : n.factorization p ≤ Nat.log p n := by
    refine Nat.le_log_of_pow_le hp.one_lt ?_
    exact Nat.le_of_dvd (Nat.pos_of_ne_zero hn)
      ((Nat.Prime.pow_dvd_iff_le_factorization hp hn).mpr le_rfl)
  exact foldPow_stable n p hn hp (Nat.log p n + 2) (by omega)

/-! ### 8. `psiM = psi`: the numeric content of the computable side, transferred -/

open DualScaleStream2.Orientifold.CrystallographicOrders in
/-- `isPrimeB` decides primality. It is `2 ≤ p` together with "no `k` in `[2, p)` divides `p`", which is
`Nat.prime_def_lt'` verbatim. -/
theorem isPrimeB_iff (p : ℕ) : isPrimeB p = true ↔ p.Prime := by
  rw [Nat.prime_def_lt']
  simp only [isPrimeB, Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true, Bool.or_eq_true,
    List.mem_range, bne_iff_ne, ne_eq]
  constructor
  · rintro ⟨h2, hall⟩
    refine ⟨h2, fun m hm2 hmp hdvd => ?_⟩
    rcases hall m hmp with h | h
    · omega
    · exact h (Nat.mod_eq_zero_of_dvd hdvd)
  · rintro ⟨h2, hall⟩
    refine ⟨h2, fun k hk => ?_⟩
    by_cases hk2 : k < 2
    · exact Or.inl (by simpa using hk2)
    · exact Or.inr fun hmod => hall k (by omega) hk (Nat.dvd_of_mod_eq_zero hmod)

open DualScaleStream2.Orientifold.CrystallographicOrders in
/-- The list `psi` folds over is exactly `n.primeFactors`. -/
theorem psiList_toFinset {n : ℕ} (hn : n ≠ 0) :
    ((List.range (n + 1)).filter fun p => isPrimeB p && n % p == 0).toFinset = n.primeFactors := by
  ext p
  simp only [List.mem_toFinset, List.mem_filter, List.mem_range, Bool.and_eq_true,
    beq_iff_eq, Nat.mem_primeFactors]
  constructor
  · rintro ⟨_, hpb, hmod⟩
    exact ⟨(isPrimeB_iff p).mp hpb, Nat.dvd_of_mod_eq_zero hmod, hn⟩
  · rintro ⟨hp, hdvd, -⟩
    exact ⟨Nat.lt_succ_of_le (Nat.le_of_dvd (Nat.pos_of_ne_zero hn) hdvd),
      (isPrimeB_iff p).mpr hp, Nat.mod_eq_zero_of_dvd hdvd⟩

/-- An additive `foldl` is the sum of the mapped list. -/
theorem foldl_add_eq (l : List ℕ) (g : ℕ → ℕ) (init : ℕ) :
    l.foldl (fun s p => s + g p) init = init + (l.map g).sum := by
  induction l generalizing init with
  | nil => simp
  | cons a t ih => simp [ih, Nat.add_assoc]

open DualScaleStream2.Orientifold.CrystallographicOrders in
/-- **The two `ψ`s agree.** The computable `psi` of `CrystallographicOrders.lean` — the one
`psi_le_six_list` and `rank_two_unaffected` evaluate — equals the `Nat.factorization`-based `psiM` proved
about here. Each file's strength now covers the other's gap: `psi` supplies numeric values, `psiM` supplies
correctness for every `n` and the theorem `psiM_le_sum_totient`. -/
theorem psiM_eq_psi {n : ℕ} (hn : n ≠ 0) : psiM n = psi n := by
  classical
  set L := (List.range (n + 1)).filter fun p => isPrimeB p && n % p == 0 with hL
  have hnodup : L.Nodup := List.Nodup.filter _ (List.nodup_range)
  have hstep : psi n = (L.map fun p => if primePart n p == 2 then 0 else
      Nat.totient (primePart n p)).sum := by
    rw [psi, ← hL, show (fun (s p : ℕ) => if primePart n p == 2 then s else s + Nat.totient (primePart n p))
      = (fun (s p : ℕ) => s + if primePart n p == 2 then 0 else Nat.totient (primePart n p)) from by
        funext s p; by_cases h : primePart n p == 2 <;> simp [h]]
    simpa using foldl_add_eq L _ 0
  rw [hstep, ← List.sum_toFinset _ hnodup, psiList_toFinset hn, psiM, Finset.sum_filter]
  refine Finset.sum_congr rfl fun p hp => ?_
  obtain ⟨hprime, -, -⟩ := Nat.mem_primeFactors.mp hp
  rw [primePart_eq_ord_proj hn hprime]
  by_cases h : p ^ n.factorization p = 2 <;> simp [h]

open DualScaleStream2.Orientifold.CrystallographicOrders in
/-- **Numeric values of `psiM`, now reachable through the bridge.** `psiM` itself does not reduce
(`Nat.factorization` is a `Finsupp`); `psi` does. `psiM_eq_psi` transfers the one to the other, so the
corollaries above are not merely upper bounds — the values are pinned, and `ψ(15) = ψ(24) = 6` is *equality*
with the rank at which §5b exhibits `mat15` and `mat24`. -/
theorem psiM_values : psiM 15 = 6 ∧ psiM 24 = 6 ∧ psiM 30 = 6 ∧ psiM 20 = 6 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    · rw [psiM_eq_psi (by norm_num)]
      decide +kernel

open DualScaleStream2.Orientifold.CrystallographicOrders in
/-- **`psi_le_six_list` transferred.** The seventeen orders available on a rank-`6` lattice, now stated for the
`Nat.factorization`-based `ψ` that `psiM_le_sum_totient` is about. This is what the bridge buys: the
computable side supplies the enumeration, the `Finsupp` side supplies the theorem. -/
theorem psiM_le_six_list :
    ((List.range 201).filter fun n => 1 ≤ n && psi n ≤ 6) =
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 18, 20, 24, 30] ∧
    ∀ n, 1 ≤ n → n ≤ 200 → (psiM n ≤ 6 ↔ psi n ≤ 6) := by
  refine ⟨psi_le_six_list, fun n hn _ => ?_⟩
  rw [psiM_eq_psi (by omega)]

/-! ### 9. Towards `ψ(n) ≤ d`: the degree bound, and a better route than the one first scoped -/

/-- **The dimension bound, from the minimal polynomial.** If the minimal polynomial of an integer (here
rational) matrix factors as a product of distinct cyclotomics indexed by `S`, then `Σ_{e ∈ S} φ(e) ≤ d`.

`deg Φ_e = φ(e)`, degrees add over a product of nonzero polynomials, and `minpoly ∣ charpoly` with
`deg charpoly = d`. No module theory, no isotypic decomposition. -/
theorem sum_totient_le_dim {d : ℕ} (A : Matrix (Fin d) (Fin d) ℚ) (S : Finset ℕ)
    (hmin : minpoly ℚ A = ∏ e ∈ S, Polynomial.cyclotomic e ℚ) :
    ∑ e ∈ S, Nat.totient e ≤ d := by
  have hdeg : (minpoly ℚ A).natDegree = ∑ e ∈ S, Nat.totient e := by
    rw [hmin, Polynomial.natDegree_prod _ _ (fun e _ => Polynomial.cyclotomic_ne_zero e ℚ)]
    exact Finset.sum_congr rfl fun e _ => Polynomial.natDegree_cyclotomic e ℚ
  have hle : (minpoly ℚ A).natDegree ≤ A.charpoly.natDegree :=
    Polynomial.Monic.natDegree_le_of_dvd (minpoly.monic (Matrix.isIntegral A))
      A.charpoly_monic.ne_zero (Matrix.minpoly_dvd_charpoly A)
  rw [Matrix.charpoly_natDegree_eq_dim, Fintype.card_fin] at hle
  omega

/-- **The crystallographic restriction, modulo two named hypotheses.** `ψ(n) ≤ d` for a rank-`d` lattice
carrying an automorphism of order `n`, given:

* `hmin` — the minimal polynomial is a product of distinct cyclotomics indexed by `S` (true for any matrix with
  `A ^ n = 1`, since `X ^ n − 1 = ∏_{e ∣ n} Φ_e` is squarefree in characteristic `0` and the `Φ_e` are
  irreducible over `ℚ`; **not proved here**);
* `hlcm` — `lcm S = n` (the order of `A` is the `lcm` of the orders of its eigenvalues, **not** the largest;
  that confusion is what made the `φ(n) ≤ d` form false, §5b; **not proved here**).

Both are standard and neither needs module theory. **This corrects the scoping recorded earlier**, which said
the remaining half required the `Φ_e`-isotypic decomposition of `ℚ^d` as a `ℚ[X]/(Xⁿ−1)`-module and was
multi-session: the minimal polynomial suffices, and Mathlib carries every piece of it. -/
theorem psiM_le_dim {d n : ℕ} (A : Matrix (Fin d) (Fin d) ℚ) (S : Finset ℕ)
    (hS : ∀ e ∈ S, e ≠ 0) (hlcm : S.lcm id = n)
    (hmin : minpoly ℚ A = ∏ e ∈ S, Polynomial.cyclotomic e ℚ) :
    psiM n ≤ d :=
  le_trans (psiM_le_sum_totient hS hlcm) (sum_totient_le_dim A S hmin)

end DualScaleStream2.Orientifold.CrystallographicArithmetic
