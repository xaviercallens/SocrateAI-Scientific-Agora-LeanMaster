/-
Stream 5 · P5.6 (part) — the forger's test for the `24` of the dyon sector.

Stream 4 applied the twining ("forger's") test to paper 7's "27720 lock", which failed at every class.
Here it is applied to the integers that carry the dyon story of Stream 5: `24 = χ(K3)` and the
Göttsche numbers `p₂₄(k) = χ(Hilb^k K3) = 1, 24, 324, 3200, 25650`, which are the multiplicities of the
two-centred sector (`DMVV.polar_part_removes_pole`). Twining replaces each dimension by the trace of
`g ∈ M₂₄`; the twined numbers pass the test if, for each `k`, the class function `g ↦ T_k(g)` is a
genuine character — its multiplicities on the irreducibles are non-negative integers.

### Sources (Tier L; Cheng–Duncan–Harvey, `papers/foundations/1204_2779.txt`)
* Table 14, ll. 4349–4364: the Frame shapes `Π_g = Π_k k^{e_k}` (cycle shapes of `g` on 24 points) and
  `χ_g = χ₁(g) + χ₂(g)`. The flattened text runs exponents into bases (`124` is `1²⁴`, `122` is `12²`);
  `frame_degree` (`Σ k e_k = 24`) fixes every reading.
* Table 8, ll. 4172–4178: the power maps `g ↦ g^p` for `p = 2, 3, 5, 7, 11, 23`.

### What is proved (Tier A)
* `frame_degree`, `frame_fixed_points`: every Frame shape has degree 24 and `e₁ = χ_g`
  (`Shadow.chiShadow`, itself the trace on `1 ⊕ 23` from the character table).
* `frame_power_maps`: the number of points fixed by `g^p`, read from the Frame shape of `g`
  (`Σ_{d | p} d·e_d`), equals `e₁` of the class of `g^p` given by the power maps — for all 26 classes and
  all six primes. This cross-checks Table 14 against Table 8.
* `twined_goettsche_identity`: at `g = 1A`, `T_k = p₂₄(k)` (Göttsche), `k ≤ 4`.
* `twined_goettsche_is_character`: for `k ≤ 4`, `T_k(g) = [p^k] Π_{n ≥ 1} det(1 − pⁿ g | ℂ²⁴)⁻¹` has
  non-negative integer multiplicities on all 26 irreducibles of `M₂₄` (inner products over the full
  character table, irrational columns included); `twined_goettsche_k2`: `324 = 3·1 + 3·23 + 252`.

So the `24` of the dyon sector and its Hilbert-scheme descendants pass the twining test that the
27720 lock failed. (Mathematically this is expected — `T_k` is the character of `Sym^k` of a
permutation module summed over partitions — so the content is the certified consistency of the
transcribed tables and the contrast with paper 7's lock, not a surprise.)
-/
import DualScaleDyons.DMVV
import DualScaleMoonshine.CharactersAll

namespace DualScaleDyons

open DualScaleMoonshine

/-- Frame shapes `[(k, e_k)]` in Table 8's column order (`7A`, `7B` share `1³7³`, etc.). -/
def frameShape : List (List (ℕ × ℕ)) :=
  [ [(1, 24)], [(1, 8), (2, 8)], [(2, 12)], [(1, 6), (3, 6)], [(3, 8)], [(2, 4), (4, 4)],
    [(1, 4), (2, 2), (4, 4)], [(4, 6)], [(1, 4), (5, 4)], [(1, 2), (2, 2), (3, 2), (6, 2)], [(6, 4)],
    [(1, 3), (7, 3)], [(1, 3), (7, 3)], [(1, 2), (2, 1), (4, 1), (8, 2)], [(2, 2), (10, 2)],
    [(1, 2), (11, 2)], [(2, 1), (4, 1), (6, 1), (12, 1)], [(12, 2)],
    [(1, 1), (2, 1), (7, 1), (14, 1)], [(1, 1), (2, 1), (7, 1), (14, 1)],
    [(1, 1), (3, 1), (5, 1), (15, 1)], [(1, 1), (3, 1), (5, 1), (15, 1)],
    [(3, 1), (21, 1)], [(3, 1), (21, 1)], [(1, 1), (23, 1)], [(1, 1), (23, 1)] ]

/-- Power maps (CDH Table 8), as column indices: `(p, [index of the class of g^p])`. -/
def powerMaps : List (ℕ × List ℕ) :=
  [ (2, [0, 0, 0, 3, 4, 1, 1, 2, 8, 3, 4, 11, 12, 6, 8, 15, 9, 10, 11, 12, 20, 21, 22, 23, 24, 25]),
    (3, [0, 1, 2, 0, 0, 5, 6, 7, 8, 1, 2, 12, 11, 13, 14, 15, 5, 7, 19, 18, 8, 8, 12, 11, 24, 25]),
    (5, [0, 1, 2, 3, 4, 5, 6, 7, 0, 9, 10, 12, 11, 13, 2, 15, 16, 17, 19, 18, 3, 3, 23, 22, 25, 24]),
    (7, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 0, 13, 14, 15, 16, 17, 1, 1, 21, 20, 4, 4, 25, 24]),
    (11, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 0, 16, 17, 18, 19, 21, 20, 22, 23, 25, 24]),
    (23, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 0, 0]) ]

/-- Number of points of the 24-point set fixed by `g^p`, from the Frame shape of `g`. -/
def fixedOfPower (j p : ℕ) : ℤ :=
  ((frameShape.getD j []).filter fun f => p % f.1 = 0).foldl (fun acc f => acc + (f.1 * f.2 : ℕ)) 0

theorem frame_degree : frameShape.all (fun fs => (fs.map fun f => f.1 * f.2).sum == 24) = true := by decide

theorem frame_fixed_points : (List.range 26).map (fun j => fixedOfPower j 1) = chiShadow := by decide

/-- **Frame shapes (Table 14) agree with the power maps (Table 8).** -/
theorem frame_power_maps :
    powerMaps.all (fun pm => (List.range 26).all fun j =>
      fixedOfPower j pm.1 == fixedOfPower (pm.2.getD j 0) 1) = true := by decide

/-- `T_k(g) = [p^k] Π_{n≥1} Π_{(d, e) ∈ Π_g} (1 − p^{nd})^{−e}`: the trace of `g` on `H*(Hilb^k K3)`
(the twined Göttsche number). -/
def twinedHilb (j k : ℕ) : ℤ :=
  let s := (List.range k).foldl (fun s i =>
    let n := i + 1
    (frameShape.getD j []).foldl (fun s f =>
      (List.range f.2).foldl (fun s _ =>
        let st := n * f.1
        (List.range (k + 1)).foldl (fun s m => if st ≤ m then s.set m (s.getD m 0 + s.getD (m - st) 0) else s) s) s) s)
    ((List.range (k + 1)).map fun m => if m = 0 then (1 : ℤ) else 0)
  s.getD k 0

theorem twined_goettsche_identity : (List.range 5).map (twinedHilb 0) = (List.range 5).map p24 := by decide

/-- `|M₂₄| · ⟨T_k, χ_i⟩`, as `(rational part, ω₇, ω₁₅, ω₂₃)` (`CharactersAll.inner4`). -/
def twinedInner (k i : ℕ) : ℤ × ℤ × ℤ × ℤ :=
  inner4 ((List.range 26).map fun j => (twinedHilb j k, 0)) (charTab.getD i [])

/-- **The twined Göttsche numbers are characters of `M₂₄`** (`k ≤ 4`): every multiplicity is a
non-negative integer and every irrational part vanishes. -/
theorem twined_goettsche_is_character :
    (List.range 5).all (fun k => (List.range 26).all fun i =>
      let v := twinedInner k i
      v.2.1 == 0 && v.2.2.1 == 0 && v.2.2.2 == 0 && v.1 % 244823040 == 0 && 0 ≤ v.1) = true := by
  decide +kernel

/-- `k = 2`: `H*(Hilb² K3)` is `3·1 ⊕ 3·23 ⊕ 252` as an `M₂₄`-module (character level). -/
theorem twined_goettsche_k2 :
    (List.range 26).map (fun i => (twinedInner 2 i).1 / 244823040) =
      [3, 3, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] := by decide +kernel

end DualScaleDyons
