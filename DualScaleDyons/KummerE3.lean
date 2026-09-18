/-
Stream 8 · E3 — "the torus inside the K3": the Kummer lattice, its roots, and the octad of the Golay code.

### Sources (Tier L)
* Taormina–Wendland (`1107_3834.txt`), Prop. 2.2.3, ll. 450–470: for a Kummer surface `X` with underlying torus
  `T`, the smallest primitive sublattice of `H²(X, ℤ)` containing the 16 exceptional classes `E_a`, `a ∈ 𝔽₂⁴`
  (`E_a² = −2`), is the Kummer lattice `Π = span_ℤ{E_a ; ½ Σ_{a∈H} E_a, H ⊂ 𝔽₂⁴ an affine hyperplane}`, and
  `K = π_*H²(T, ℤ) ≅ U(2)³ = Π^⊥`. Huybrechts ll. 2060–2076: `Π` has rank 16, index `2⁵` over `⊕ ℤE_a`,
  discriminant `2⁶`.
* TW Prop. 2.3.1, 2.3.4, ll. 575–600, 660–705: the Niemeier lattice `N` of type `A₁²⁴` is
  `{v ∈ ½R : v mod 2 ∈ G₂₄}` (`G₂₄` the extended Golay code); for a special octad `O`, the vectors of `N`
  orthogonal to the 8 roots of `O` form `Π̃ ≅ Π(−1)` (on the 16 complement coordinates) and those orthogonal to
  the other 16 form `K̃` (on the octad); Nikulin: `N(A₁²⁴)` is the only Niemeier lattice containing the Kummer
  lattice (ll. 672–675). TW abstract (ll. 24–40): the "overarching" group `(ℤ₂)⁴ ⋊ A₇ ⊂ M₂₄`, order 40320.

### What is proved (Tier A)
* `kummer_code`: the 30 affine hyperplanes of `𝔽₂⁴` have rank 5 and span the 32-word code (= RM(1,4)) with weights
  `0 (×1), 8 (×30), 16 (×1)`; with the (standard) index formula, `disc Π = 2¹⁶/(2⁵)² = 2⁶` (`kummer_disc`).
* `kummer_roots`: **for every** `c : Fin 16 → ℤ` whose reduction mod 2 lies in the code, `Σ c_a² = 4` (i.e.
  `v = ½ Σ c_a E_a` has `v² = −2`) forces `c = ±2e_a`: the only roots of `Π` are the 32 vectors `±E_a` — root
  system `A₁¹⁶`, the 16 vanishing cycles, and no other.
* `golay_code`: the cyclic shifts of the quadratic-residue indicator mod 23, extended by parity, have rank 12, and
  the 4096 codewords have weights `0, 8, 12, 16, 24` with multiplicities `1, 759, 2576, 759, 1` (the extended
  Golay code, unique with these parameters — Tier L).
* `octad_is_kummer`: for the octad `O` below, exactly 32 Golay codewords are disjoint from `O`, and on the 16
  complement points, transported to `𝔽₂⁴` by the explicit bijection `φ`, they are **exactly** the Kummer glue code.
  So the Kummer split `24 = 8 + 16` is the octad/complement split of `G₂₄`.
* `kummer_betti`: `24 = (1 + 6 + 1) + 16` (even cohomology of `T⁴`, invariant under `−1`, plus 16 fixed points),
  `χ = (0 − 16)/2 + 16·2 = 24`, `rk H² = 6 + 16 = 22`, and `|disc U(2)³| = |disc Π| = 2⁶`.

### Reading (Tier C) and scope
The 8 octad coordinates carry the torus (`K ≅ U(2)³`, the programme's T-duality lattice), the 16 complement
coordinates carry the vanishing cycles (`A₁¹⁶`): E3's "macro 8 + micro 16" is the octad split of the code whose
automorphism group is `M₂₄`. Not formalized: the `M₂₄` or `(ℤ₂)⁴ ⋊ A₇` actions, the embedding into the full
`H*(X, ℤ)`, and whether `(−2)`-reflections in the 16 roots (Stream 2) generate the relevant Weyl group action.
-/
import Mathlib

namespace DualScaleDyons.KummerE3

/-! ### Codes as bitmasks -/

/-- Hamming weight of a bitmask on `n` bits. -/
def wt (n m : ℕ) : ℕ := ((List.range n).filter fun i => m.testBit i).length

/-- Rank over `𝔽₂` of a list of bitmasks (elimination on the highest remaining set bit). -/
def rank2 (n : ℕ) (vs : List ℕ) : ℕ :=
  ((List.range n).reverse.foldl (fun (st : List ℕ × ℕ) b =>
    match st.1.find? (fun v => v.testBit b) with
    | none => st
    | some p => ((st.1.erase p).map (fun v => if v.testBit b then v ^^^ p else v), st.2 + 1)) (vs, 0)).2

/-- All `2^k` sums of sub-lists of a list (distinct when the list is independent). -/
def spanOf (basis : List ℕ) : List ℕ := basis.foldl (fun S g => S ++ S.map (· ^^^ g)) [0]

/-- Weight distribution `(weight, count)` for the weights `ks`. -/
def wtDist (n : ℕ) (ks : List ℕ) (ws : List ℕ) : List (ℕ × ℕ) :=
  let w := ws.map (wt n)
  ks.map fun k => (k, w.count k)

/-! ### The Kummer glue code on `𝔽₂⁴` -/

/-- Indicator (bitmask over the 16 points of `𝔽₂⁴`) of the affine hyperplane `{p : l·p = c}`, `l ≠ 0`. -/
def hyperplane (l c : ℕ) : ℕ :=
  ((List.range 16).filter fun p => wt 4 (Nat.land l p) % 2 = c).foldl (fun m p => m + 2 ^ p) 0

/-- The 30 affine hyperplanes. -/
def hyperplanes : List ℕ :=
  (List.range 15).flatMap fun i => [hyperplane (i + 1) 0, hyperplane (i + 1) 1]

/-- A basis: the four coordinate hyperplanes `{p_i = 1}` and the whole space. -/
def kummerBasis : List ℕ := [hyperplane 1 1, hyperplane 2 1, hyperplane 4 1, hyperplane 8 1, 2 ^ 16 - 1]

/-- The Kummer glue code (32 words). -/
def kummerCode : List ℕ := spanOf kummerBasis

theorem kummer_code :
    hyperplanes.length = 30 ∧ rank2 16 hyperplanes = 5 ∧ rank2 16 kummerBasis = 5 ∧
      hyperplanes.all (· ∈ kummerCode) ∧ kummerBasis.all (fun b => b = 2 ^ 16 - 1 ∨ b ∈ hyperplanes) ∧
      kummerCode.length = 32 ∧ wtDist 16 [0, 8, 16] kummerCode = [(0, 1), (8, 30), (16, 1)] := by
  decide +kernel

/-- `disc(A₁¹⁶) = 2¹⁶`, index `2⁵` (the code dimension) ⇒ `disc Π = 2⁶`. -/
theorem kummer_disc : (2 : ℕ) ^ 16 / (2 ^ rank2 16 hyperplanes) ^ 2 = 2 ^ 6 := by decide +kernel

/-! ### The roots of the Kummer lattice -/

/-- The code as functions `Fin 16 → Bool`. -/
def codeF : List (Fin 16 → Bool) := kummerCode.map fun m a => m.testBit a

theorem codeF_weights :
    codeF.all (fun f => (Finset.univ.filter fun a => f a = true).card ∈ ({0, 8, 16} : Finset ℕ)) = true := by
  decide +kernel

/-- **The only roots of the Kummer lattice are the `±E_a`.** Writing `v = ½ Σ c_a E_a` with `c mod 2` in the glue
code, `v² = −½ Σ c_a²`, so `v² = −2` iff `Σ c_a² = 4`; this forces `c = ±2 e_a`. -/
theorem kummer_roots (c : Fin 16 → ℤ) (hc : (fun a => decide (c a % 2 ≠ 0)) ∈ codeF)
    (hn : ∑ a, c a ^ 2 = 4) : ∃ a, (c a = 2 ∨ c a = -2) ∧ ∀ b, b ≠ a → c b = 0 := by
  have hw := List.all_eq_true.mp codeF_weights _ hc
  simp only [decide_eq_true_eq] at hw
  -- odd entries contribute at least 1 each
  have h1 : ((Finset.univ.filter fun a => c a % 2 ≠ 0).card : ℤ) ≤ ∑ a, c a ^ 2 := by
    rw [Finset.card_eq_sum_ones, Nat.cast_sum]
    simp only [Nat.cast_one]
    calc ∑ a ∈ Finset.univ.filter (fun a => c a % 2 ≠ 0), (1 : ℤ)
        ≤ ∑ a ∈ Finset.univ.filter (fun a => c a % 2 ≠ 0), c a ^ 2 := by
          apply Finset.sum_le_sum
          intro a ha
          have hodd : c a % 2 ≠ 0 := (Finset.mem_filter.mp ha).2
          have hne : c a ≠ 0 := by intro h0; rw [h0] at hodd; exact hodd rfl
          have := sq_pos_of_ne_zero hne
          omega
      _ ≤ ∑ a, c a ^ 2 :=
          Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) (fun a _ _ => sq_nonneg _)
  have hle : (Finset.univ.filter fun a => c a % 2 ≠ 0).card ≤ 4 := by
    rw [hn] at h1; exact_mod_cast h1
  have h0 : (Finset.univ.filter fun a => c a % 2 ≠ 0).card = 0 := by
    simp only [Finset.mem_insert, Finset.mem_singleton] at hw
    omega
  have heven : ∀ a, c a % 2 = 0 := by
    intro a
    by_contra h
    have hmem : a ∈ Finset.univ.filter (fun a => c a % 2 ≠ 0) := Finset.mem_filter.mpr ⟨Finset.mem_univ _, h⟩
    rw [Finset.card_eq_zero.mp h0] at hmem
    exact absurd hmem (Finset.notMem_empty a)
  have hbound : ∀ a, c a ^ 2 ≤ 4 := by
    intro a
    rw [← hn]
    exact Finset.single_le_sum (f := fun a => c a ^ 2) (fun b _ => sq_nonneg _) (Finset.mem_univ a)
  have hvals : ∀ a, c a = 0 ∨ c a = 2 ∨ c a = -2 := by
    intro a
    have h1 := heven a
    have h2 := hbound a
    have h3 : -2 ≤ c a ∧ c a ≤ 2 := by constructor <;> nlinarith [sq_nonneg (c a - 2), sq_nonneg (c a + 2)]
    omega
  obtain ⟨a, ha⟩ : ∃ a, c a ≠ 0 := by
    by_contra h
    simp only [not_exists, not_not] at h
    simp [h] at hn
  have hca : c a ^ 2 = 4 := by rcases hvals a with h | h | h <;> simp_all
  have hrest : ∑ b ∈ Finset.univ.erase a, c b ^ 2 = 0 := by
    have := Finset.add_sum_erase Finset.univ (fun b => c b ^ 2) (Finset.mem_univ a)
    omega
  refine ⟨a, ?_, ?_⟩
  · rcases hvals a with h | h | h
    · exact absurd h ha
    · exact Or.inl h
    · exact Or.inr h
  · intro b hb
    have hz := (Finset.sum_eq_zero_iff_of_nonneg (fun x _ => sq_nonneg (c x))).mp hrest b
      (Finset.mem_erase.mpr ⟨hb, Finset.mem_univ b⟩)
    exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hz

/-! ### The extended Golay code and the octad split -/

/-- Indicator of the quadratic residues mod 23, shifted by `k`, extended by a parity bit (bit 23). -/
def qrShift (k : ℕ) : ℕ :=
  let s := ((List.range 23).filter fun x => ((List.range 22).map fun y => ((y + 1) * (y + 1)) % 23).contains x
    ∧ x ≠ 0).foldl (fun m x => m + 2 ^ ((x + k) % 23)) 0
  s + (wt 23 s % 2) * 2 ^ 23

/-- A basis: the first 12 independent shifts (`k = 0 … 11`). -/
def golayBasis : List ℕ := (List.range 12).map qrShift

def golay : List ℕ := spanOf golayBasis

theorem golay_code :
    rank2 24 golayBasis = 12 ∧ rank2 24 ((List.range 23).map qrShift) = 12 ∧
      wtDist 24 [0, 8, 12, 16, 24] golay = [(0, 1), (8, 759), (12, 2576), (16, 759), (24, 1)] := by
  decide +kernel

/-- An octad: positions `{0, 2, 5, 8, 9, 10, 11, 12}`. -/
def octad : ℕ := 7973

/-- The 16 complement positions, in increasing order. -/
def comp : List ℕ := (List.range 24).filter fun i => !octad.testBit i

/-- `φ`: complement position `j` ↦ point of `𝔽₂⁴` (as `0 … 15`). -/
def phi : List ℕ := [10, 14, 5, 13, 7, 9, 11, 12, 6, 15, 3, 1, 2, 4, 8, 0]

/-- Restrict a codeword to the complement and transport it by `φ`. -/
def transport (w : ℕ) : ℕ :=
  (List.range 16).foldl (fun m j => if w.testBit (comp.getD j 0) then m + 2 ^ (phi.getD j 0) else m) 0

/-- **The octad split is the Kummer split.** -/
theorem octad_is_kummer :
    octad ∈ golay ∧ wt 24 octad = 8 ∧ comp.length = 16 ∧ (List.range 16).all (· ∈ phi) ∧
      (golay.filter fun w => Nat.land w octad = 0).length = 32 ∧
      ((golay.filter fun w => Nat.land w octad = 0).map transport).all (· ∈ kummerCode) ∧
      kummerCode.all (· ∈ (golay.filter fun w => Nat.land w octad = 0).map transport) := by
  decide +kernel

/-- `24 = 8 + 16`: the Betti numbers and Euler characteristic of a Kummer surface, and the discriminants. -/
theorem kummer_betti :
    Nat.choose 4 0 + Nat.choose 4 2 + Nat.choose 4 4 = 8 ∧ 2 ^ 4 = 16 ∧ 8 + 16 = 24 ∧
      ((0 : ℤ) - 16) / 2 + 16 * 2 = 24 ∧ Nat.choose 4 2 + 16 = 22 ∧ ((-4 : ℤ) ^ 3).natAbs = 2 ^ 6 := by
  decide

end DualScaleDyons.KummerE3
