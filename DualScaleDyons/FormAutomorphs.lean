/-
Stream 8 · open question 2 — what the `6`/`8` correction between Moore's `N(D)` and Hurwitz's `H(D)` means.

`WhichK3.moore_vs_hurwitz` found `12·N(D) = 12·H(D) + 6·[D = 4f²] + 8·[D = 3f²]`: counting attractor backgrounds
(Moore) and the class-number coefficient of the immortal index (Stream 5) differ only on the rays of the two
self-dual points of the torus. Here the difference is identified: `H` is the **automorphism-weighted** count of form
classes, with weight `2/|Aut(Q)|`, and `|Aut(Q)|` is `4` on the `τ = i` ray, `6` on the `τ = ω` ray and `2`
otherwise. `N` counts the same classes without weights.

### Sources (Tier L)
* Moore (`hep-th_9807087.txt`) (3.13)–(3.15), ll. 1210–1245: forms `(a, b, c)` up to `SL(2, ℤ)`, and the point
  `τ_Q = (−b + √D)/2a` of the fundamental domain; the `SL(2, ℤ)` action on `Q` is the fractional linear action on `τ`.
* DMZ via `Immortal.lean`: the class numbers `H(Δ)` weight `a(x² + y²)` by `1/2` and `a(x² + xy + y²)` by `1/3`.

### What is proved (Tier A)
* `reduced_value_bound`: for a reduced form (`|b| ≤ a ≤ c`), `2Q(x, y) ≥ a(x² + y²)`.
* `automorph_bound`: an automorph `(p, q; r, s)` of a reduced form has `|p|, |r| ≤ 1` and `a(q² + s²) ≤ 2c`.
* `automorphs_complete`: every integral automorph of determinant 1 lies in the finite list `autList` (so the list is
  the whole automorphism group, not a sample).
* `automorph_table`: for every reduced form with `3 ≤ D ≤ 100`, `|Aut(Q)| = 6` if `Q = a(1, 1, 1)`, `4` if
  `Q = a(1, 0, 1)`, and `2` otherwise.
* `mass_formula`: for `3 ≤ D ≤ 100`, `12·H(D) = Σ_Q 24/|Aut(Q)|` over the reduced forms of discriminant `−D`.
  With `moore_vs_hurwitz` this is the whole content of the `6`/`8` correction: `N` gives each class weight 1,
  `H` gives it `2/|Aut(Q)|`, and the two self-dual rays are the only places where `|Aut(Q)| > 2`.

### Reading (Tier C)
The automorphs of `Q` are the stabiliser of `τ_Q` in `SL(2, ℤ)`: `±1` in general, the order-4 group at `τ = i` and the
order-6 group at `τ = ω`. The immortal index counts attractor backgrounds as points of the orbifold
`SL(2, ℤ)\ℍ` (with their orbifold weights); Moore's `N` counts them as points of the coarse moduli space. The
smallest black hole (`D = −3`, `AttractorCharges`) sits exactly at the order-6 orbifold point, which is where its
index picks up `−648·H(3) = −216`. This answers open question 2 at the level of arithmetic; why the index is
orbifold-weighted (mock modularity of `ψ₁^F`, DMZ) is Tier L and not formalized.
-/
import DualScaleDyons.WhichK3

namespace DualScaleDyons.FormAutomorphs

open DualScaleDyons

/-- `Q(x, y) = a x² + b x y + c y²`. -/
def Qv (f : ℤ × ℤ × ℤ) (x y : ℤ) : ℤ := f.1 * x * x + f.2.1 * x * y + f.2.2 * y * y

/-- `M = (p, q; r, s)` preserves `Q`, i.e. `Q(p x + q y, r x + s y) = Q(x, y)`: compare the three coefficients. -/
def preserves (f : ℤ × ℤ × ℤ) (p q r s : ℤ) : Bool :=
  Qv f p r == f.1 && Qv f q s == f.2.2 && 2 * f.1 * p * q + f.2.1 * (p * s + q * r) + 2 * f.2.2 * r * s == f.2.1

/-- **The value bound for reduced forms**: `2Q(x, y) ≥ a(x² + y²)`. -/
theorem reduced_value_bound (a b c x y : ℤ) (ha : 0 < a) (hb1 : -a ≤ b) (hb2 : b ≤ a) (hc : a ≤ c) :
    a * (x ^ 2 + y ^ 2) ≤ 2 * (a * x * x + b * x * y + c * y * y) := by
  rcases le_total 0 (x * y) with hxy | hxy
  · nlinarith [sq_nonneg (x - y), mul_nonneg ha.le (sq_nonneg (x - y)), mul_nonneg (sub_nonneg.2 hc) (sq_nonneg y),
      mul_nonneg (by linarith : (0:ℤ) ≤ b + a) hxy]
  · nlinarith [sq_nonneg (x + y), mul_nonneg ha.le (sq_nonneg (x + y)), mul_nonneg (sub_nonneg.2 hc) (sq_nonneg y),
      mul_nonpos_of_nonneg_of_nonpos (by linarith : (0:ℤ) ≤ a - b) hxy]

/-- **Automorphs are bounded.** If `(p, q; r, s)` preserves a reduced form, its first column has entries in
`{−1, 0, 1}` and its second column satisfies `a(q² + s²) ≤ 2c`. -/
theorem automorph_bound (a b c p q r s : ℤ) (ha : 0 < a) (hb1 : -a ≤ b) (hb2 : b ≤ a) (hc : a ≤ c)
    (h1 : a * p * p + b * p * r + c * r * r = a) (h2 : a * q * q + b * q * s + c * s * s = c) :
    -1 ≤ p ∧ p ≤ 1 ∧ -1 ≤ r ∧ r ≤ 1 ∧ a * (q ^ 2 + s ^ 2) ≤ 2 * c := by
  have hp := reduced_value_bound a b c p r ha hb1 hb2 hc
  have hq := reduced_value_bound a b c q s ha hb1 hb2 hc
  rw [h1] at hp
  rw [h2] at hq
  have hpr : p ^ 2 + r ^ 2 ≤ 2 := by
    by_contra h
    rw [not_le] at h
    nlinarith
  refine ⟨?_, ?_, ?_, ?_, hq⟩ <;> nlinarith [sq_nonneg p, sq_nonneg r]

/-- The box radius for the second column: `|q|, |s| ≤ √(2c/a)`. -/
def radius (f : ℤ × ℤ × ℤ) : ℕ := Nat.sqrt (2 * f.2.2 / f.1).toNat

def window (k : ℕ) : List ℤ := (List.range (2 * k + 1)).map fun i : ℕ => (i : ℤ) - (k : ℤ)

/-- All automorphs of determinant 1 in the box given by `automorph_bound`. -/
def autList (f : ℤ × ℤ × ℤ) : List (ℤ × ℤ × ℤ × ℤ) :=
  (window 1).flatMap fun p => (window 1).flatMap fun r => (window (radius f)).flatMap fun q =>
    ((window (radius f)).filter fun s => p * s - q * r == 1 && preserves f p q r s).map fun s => (p, q, r, s)

theorem mem_window (k : ℕ) (x : ℤ) (h1 : -(k : ℤ) ≤ x) (h2 : x ≤ k) : x ∈ window k := by
  obtain ⟨n, hn⟩ : ∃ n : ℕ, (n : ℤ) = x + k := ⟨(x + k).toNat, Int.toNat_of_nonneg (by omega)⟩
  unfold window
  rw [List.mem_map]
  refine ⟨n, List.mem_range.mpr ?_, ?_⟩
  · have : (n : ℤ) < 2 * k + 1 := by omega
    exact_mod_cast this
  · omega

/-- **The list is complete**: every determinant-1 automorph of a reduced form is in `autList`. -/
theorem automorphs_complete (a b c p q r s : ℤ) (ha : 0 < a) (hb1 : -a ≤ b) (hb2 : b ≤ a) (hc : a ≤ c)
    (hdet : p * s - q * r = 1) (hpres : preserves (a, b, c) p q r s = true) :
    (p, q, r, s) ∈ autList (a, b, c) := by
  simp only [preserves, Qv, Bool.and_eq_true, beq_iff_eq] at hpres
  obtain ⟨⟨h1, h2⟩, h3⟩ := hpres
  obtain ⟨hp1, hp2, hr1, hr2, hqs⟩ := automorph_bound a b c p q r s ha hb1 hb2 hc h1 h2
  -- `|q|, |s| ≤ radius`
  have hq2 : q * q ≤ 2 * c / a := by
    rw [Int.le_ediv_iff_mul_le ha]; nlinarith [sq_nonneg s]
  have hs2 : s * s ≤ 2 * c / a := by
    rw [Int.le_ediv_iff_mul_le ha]; nlinarith [sq_nonneg q]
  have hbound : ∀ x : ℤ, x * x ≤ 2 * c / a → -(radius (a, b, c) : ℤ) ≤ x ∧ x ≤ radius (a, b, c) := by
    intro x hx
    have h0 : (0 : ℤ) ≤ 2 * c / a := le_trans (mul_self_nonneg x) hx
    have hsq : ((x.natAbs * x.natAbs : ℕ) : ℤ) = x * x := by
      push_cast; exact abs_mul_abs_self x
    have hn : x.natAbs * x.natAbs ≤ (2 * c / a).toNat := by
      have : ((x.natAbs * x.natAbs : ℕ) : ℤ) ≤ ((2 * c / a).toNat : ℤ) := by
        rw [hsq, Int.toNat_of_nonneg h0]; exact hx
      exact_mod_cast this
    have hs : x.natAbs ≤ radius (a, b, c) := Nat.le_sqrt.mpr hn
    have habs : |x| ≤ (radius (a, b, c) : ℤ) := by
      rw [Int.abs_eq_natAbs]; exact_mod_cast hs
    exact abs_le.mp habs
  obtain ⟨hq3, hq4⟩ := hbound q hq2
  obtain ⟨hs3, hs4⟩ := hbound s hs2
  simp only [autList, List.mem_flatMap, List.mem_map, List.mem_filter]
  refine ⟨p, mem_window 1 p (by omega) (by omega), r, mem_window 1 r (by omega) (by omega), q,
    mem_window _ q hq3 hq4, s, ⟨mem_window _ s hs3 hs4, ?_⟩, rfl⟩
  simp [preserves, Qv, hdet, h1, h2, h3]

/-- The predicted order: `6` on `a(1, 1, 1)`, `4` on `a(1, 0, 1)`, `2` otherwise. -/
def autOrder (f : ℤ × ℤ × ℤ) : ℕ :=
  if f.2.1 = f.1 ∧ f.1 = f.2.2 then 6 else if f.2.1 = 0 ∧ f.1 = f.2.2 then 4 else 2

/-- **The automorphism groups**, for every reduced form with `3 ≤ D ≤ 100`. -/
theorem automorph_table :
    (List.range 101).all (fun D => (reducedForms D).all fun f => (autList f).length == autOrder f) = true := by
  decide +kernel

/-- **The mass formula**: `12·H(D) = Σ_Q 24/|Aut(Q)|` for `3 ≤ D ≤ 100`. -/
theorem mass_formula :
    (List.range 101).all (fun D => D < 3 || D % 4 == 1 || D % 4 == 2 ||
      h12 D == (((reducedForms D).map fun f => 24 / autOrder f).sum : ℕ)) = true := by
  decide +kernel

/-- Sanity: the reduced forms of `WhichK3` are reduced in the sense used above. -/
theorem reduced_forms_are_reduced :
    (List.range 101).all (fun D => (reducedForms D).all fun f =>
      decide (0 < f.1) && decide (-f.1 ≤ f.2.1) && decide (f.2.1 ≤ f.1) && decide (f.1 ≤ f.2.2)) = true := by
  decide +kernel

end DualScaleDyons.FormAutomorphs
