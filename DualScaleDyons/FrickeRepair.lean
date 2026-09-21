/-
G10 — the repair of the Fricke proposal carried out, and what it is *not* entitled to claim.

### Where this comes from
§9 of `docs/STREAM8_WHICH_K3.md` (G9) ended with a paragraph that was **prose only**:

> "Demanding `ρ = 20` makes the transcendental lattice rank `2` and **positive definite**, and the
> classification becomes one of positive definite binary forms — finite at each discriminant, with a smallest.
> That is `discriminant_gap`: `D ≤ −3`, attained only by `(1,1,1)`, `T_S = A₂`. **The repaired proposal
> reproduces G3's answer, reached from the modular side.**"

An unproved paragraph that no theorem depends on is the failure mode `LL.md` §S10 records — the `φ(n) ≤ d`
sentence survived five releases of green gates for exactly that reason. This file closes it, and the closing
**refutes its last clause twice over**.

### What is proved here (Tier A)

*The cut does the selecting.*
* `posdef_of_disc_neg`: a binary form with `a > 0` and `4ac − b² > 0` is positive definite, from
  `4a·Q(x,y) = (2ax + by)² + (4ac − b²)y²`.
* `reduced_bound`: a reduced form (`|b| ≤ a ≤ c`) satisfies `3a² ≤ 4ac − b²`, so only finitely many `a` occur at
  a fixed discriminant — the finiteness `reducedForms` enumerates.
* `repair_selects`: **exactly four conjuncts, and they are a bound plus three evaluations.**
  `AttractorCharges.discriminant_gap` gives `3 ≤ 4ac − b²` for every definite form; and `reducedForms 1 = []`,
  `reducedForms 2 = []`, `reducedForms 3 = [(1,1,1)]`. Read together with the standard meaning of `reducedForms`
  they say the smallest discriminant is `−3` with the single class `A₂` — G3's answer — but *that* sentence
  depends on `reducedForms` enumerating what its name says, which is a property of a definition, not one of
  these four conjuncts. Independently re-enumerated from the textbook definition of a reduced form (see the
  release note): `h(−1) = h(−2) = 0`, `h(−3) = 1` at `(1,1,1)`, matching the standard class numbers at
  `−4, −7, −8, −11, −12`. No hypothesis in the statement mentions `N`, `Γ₀(N)` or the Fricke involution.
* `reducedForms_counts_imprimitive`: and because `repair_selects` evaluates `reducedForms` only where no
  imprimitive form occurs, `reducedForms 12 = [(1,0,3), (2,2,2)]` pins *which* of the two readings of "reduced
  forms" the definition implements — in the kernel, where the name was doing the work.

*The Fricke involution, specifically, is inert.*
* `fricke_eq_sym2_S`: the Fricke matrix on form coefficients **is** the `Sym²` lift of
  `S = ![![0,−1],![1,0]] ∈ SL(2,ℤ)` — `fricke = sym2 0 (-1) 1 0`, `det S = 1` (`sym2_S_det`). Note what is
  absent: **no `N`**. In the `Γ₀(N)` convention `(a,b,c) ↦ N a x² + b x y + c y²`, substituting
  `W_N = ![![0,−1],![N,0]]` gives `(N²c, −Nb, Na)`; dividing by the overall `N` returns the same `N`-free map.
* `sym2_is_substitution`: **what `Sym²` actually does**, general in all nine variables — `sym2 p q r s *ᵥ ![a,b,c]`
  is the coefficient triple of `(x,y) ↦ Q(px + qy, rx + sy)`. This is the property the name asserts, and it is
  what turns G9's matrix identities into statements about forms.
* `fricke_coeffs`, `fricke_is_proper_equivalence`: **the chain, with every link in the kernel.**
  `fricke *ᵥ ![a,b,c] = ![c,-b,a]`; and by `fricke_eq_sym2_S` plus `sym2_is_substitution`, the Fricke
  coefficient map *is* substitution by `S`, with `det S = 1` (`sym2_S_det`). The statement of
  `fricke_is_proper_equivalence` mentions `fricke` itself, not a hand-written triple, so no step of the
  identification is left to this docstring.
* `forms_pointwise_imp_coeffs`: pointwise equality of binary forms is coefficient equality (evaluate at `(1,0)`,
  `(0,1)`, `(1,1)`), so nothing is lost by stating the above as an identity of values.

  **Tier discipline on what follows from this.** `Q ∘ S` with `det S = 1` *is* proper equivalence, so the Fricke
  map fixes every class. That last step is the **definition** of the class relation, which this repository does
  not formalize — so it is taken outside the kernel, and **nothing below closes it**: `fricke_class_trivial_box`
  checks `reduce`, not classes. "Fixes every class" is then the theorem; "therefore selects nothing" is an
  inference from it; and the two are not to be quoted as one.
* `fricke_is_first_reduction_step`: it is literally the opening branch of Gauss reduction,
  `reduceStep (a,b,c) = (c,−b,a)` when `c < a`.
* `fricke_preserves_disc`: it fixes `b² − 4Nac` for every `N`, because the form is symmetric in `a ↔ c`.
* `fricke_class_trivial_box`: `PASS(box: 1 ≤ a,c ≤ 4, |b| ≤ 6)`. On every positive definite form in that box
  this repository's own `reduce` sends `(c,−b,a)` and `(a,b,c)` to the same reduced form. **A bounded fact about
  `reduce`, not evidence about classes** — it does not bridge the definitional step below, because no
  computation bridges a definition. Always quoted with its bound.

### What this does NOT establish — the objection that survived, and changed the verdict
The first draft of this file read the above as "the modular structure is a passenger". **That reading is wrong,
and the correction is due to the source project** (`SocrateAI-DualScaleTopologicalUniverseModel-LeanProposal`,
"Stream 1", tag `v0.10-two-lattices`), which was asked to attack the claim and did.

`ρ = 20` surfaces are the *singular* (physics: *attractive*) K3s, and by Shioda–Inose their rank-2 positive
definite transcendental lattice is not merely analogous to CM data — it **is** that data. Huybrechts, Tier L,
`papers/foundations/huybrechts_K3Global.txt`: ll. 16324–16328 (`ρ = 20` surfaces "can be classified in terms of
their transcendental lattice"), and ll. 3093–3102 (for `ρ(X) = 20` the associated elliptic curves `E ∼ E'`
"have complex multiplication and their rational period can be read off directly from the lattice of rank two
`T(X)`"). The `ρ = 20` locus of an `Mₙ`-polarized family is the CM locus of the modular curve.

So the binary-form enumeration and the "modular side" are **the same computation in two languages**, and their
agreement is forced, not corroborative. G9's clause "reached from the modular side" is therefore wrong in a
second and worse way than being merely unproved: it advertises an independence that Shioda–Inose forbids.

What survives is narrower and is what the theorems above actually say. **(i)** The Fricke involution is
substitution by `S ∈ SL(2,ℤ)` and so fixes every class — Tier A for the substitution identity, with "therefore it
selects nothing" recorded as the inference it is. **(ii)** The selection is done in *two* steps, not one: the cut
`ρ = 20` lands the problem on the CM locus, and the discriminant bound then selects within that locus
(`3 ≤ 4ac − b²`, attained only by `(1,1,1)`). `ρ = 20` alone does **not** imply `T_S = A₂`; that distinction is
due to Stream 1 and is kept because the one-step phrasing invites exactly the wrong reading. Neither (i) nor (ii)
says "the modular structure" is absent from the rank-2 object. It is not absent; it is the same object.

### Tier boundary — the load-bearing link is quoted, not proved
1. `ρ = 20 ⇒ rank T(X) = 2`, positive definite (Hodge index + the signature of `H²`) — **Tier L**, Huybrechts
   ll. 16324–16332. Nothing here proves it and nothing here can. It is load-bearing for the entire repair: it is
   what turns the problem into one about positive definite binary forms.
2. definiteness ⇒ finiteness at each discriminant, with a minimum — **Tier A**, this file.
3. the minimum is `D = −3`, uniquely `(1,1,1) = A₂` — **Tier A**, `discriminant_gap` + `reducedForms 3`.
4. the rank-2 lattice *is* CM data, so the two routes are one — **Tier L**, Huybrechts ll. 3093–3102.

Blurring 1 into 2 and 3 would publish "the modular construction selects our K3" on the back of a quoted
assumption; blurring 4 away would publish forced agreement as corroboration. G10 does neither.

### Scope
Nothing here says which K3 is ours. `N = 4` compactifications give no observable (Stream 7), and G2's `i`/`ω`
choice stays open. This file is about what a selection argument is entitled to claim.
-/
import DualScaleDyons.FrickeCriterion

namespace DualScaleDyons.FrickeRepair

open Matrix DualScaleDyons.FrickeCriterion

/-! ### 1. The cut: definiteness, finiteness, and the minimum -/

/-- **A form with `a > 0` and negative discriminant is positive definite.** The identity
`4a·Q(x,y) = (2ax + by)² + (4ac − b²)y²` makes both terms non-negative and one of them strictly positive. -/
theorem posdef_of_disc_neg (a b c x y : ℤ) (ha : 0 < a) (hD : 0 < 4 * a * c - b * b)
    (hxy : ¬(x = 0 ∧ y = 0)) : 0 < a * x ^ 2 + b * (x * y) + c * y ^ 2 := by
  have key : 4 * a * (a * x ^ 2 + b * (x * y) + c * y ^ 2)
      = (2 * a * x + b * y) ^ 2 + (4 * a * c - b * b) * y ^ 2 := by ring
  have hpos : 0 < 4 * a * (a * x ^ 2 + b * (x * y) + c * y ^ 2) := by
    rw [key]
    rcases eq_or_ne y 0 with hy | hy
    · have hx : x ≠ 0 := fun h => hxy ⟨h, hy⟩
      have hne : 2 * a * x + b * y ≠ 0 := by
        subst hy
        simpa using mul_ne_zero (by omega : (2 : ℤ) * a ≠ 0) hx
      have h1 : 0 < (2 * a * x + b * y) ^ 2 :=
        lt_of_le_of_ne (sq_nonneg _) (Ne.symm (pow_ne_zero 2 hne))
      have h2 : 0 ≤ (4 * a * c - b * b) * y ^ 2 :=
        mul_nonneg hD.le (sq_nonneg y)
      linarith
    · have h1 : 0 ≤ (2 * a * x + b * y) ^ 2 := sq_nonneg _
      have hy2 : 0 < y ^ 2 := lt_of_le_of_ne (sq_nonneg y) (Ne.symm (pow_ne_zero 2 hy))
      have h2 : 0 < (4 * a * c - b * b) * y ^ 2 := mul_pos hD hy2
      linarith
  nlinarith [hpos, ha]

/-- **The finiteness bound.** A reduced form `|b| ≤ a ≤ c` has `3a² ≤ 4ac − b²`, so at a fixed discriminant `D`
only the finitely many `a` with `3a² ≤ D` can occur — the bound `reducedForms` filters on. -/
theorem reduced_bound (a b c : ℤ) (hb : |b| ≤ a) (hac : a ≤ c) :
    3 * a * a ≤ 4 * a * c - b * b := by
  have h0 : 0 ≤ a := le_trans (abs_nonneg b) hb
  have h1 : b * b ≤ a * a := by
    rw [← abs_mul_abs_self b]
    exact mul_self_le_mul_self (abs_nonneg b) hb
  nlinarith [mul_nonneg h0 (sub_nonneg.mpr hac)]

/-- **The repair, in one statement.** Under the definiteness cut the classification is finite with a smallest
discriminant, and that smallest is `3`, attained by the single class `(1,1,1) = A₂` — G3's answer. No hypothesis
here mentions `N`, `Γ₀(N)` or the Fricke involution: the cut is what decides. -/
theorem repair_selects :
    (∀ a b c : ℤ, 0 < 4 * a * c - b * b → 3 ≤ 4 * a * c - b * b) ∧
      reducedForms 3 = [(1, 1, 1)] ∧ reducedForms 2 = [] ∧ reducedForms 1 = [] := by
  refine ⟨fun a b c h => (DualScaleDyons.AttractorCharges.discriminant_gap a b c h).1, ?_, ?_, ?_⟩ <;>
    decide +kernel

/-- **The convention of `reducedForms`, pinned in the kernel instead of in a docstring.** At `D = 12` the two
readings of "reduced forms of discriminant `−D`" first diverge: there is one *primitive* class
(`h(−12) = 1`, the form `(1,0,3)`) but **two** reduced forms, the second `(2,2,2)` of content `2`.
`reducedForms` returns both, so it enumerates **all** reduced forms, not only the primitive ones — which is what
`nForms`' docstring asserts and what `moore_vs_hurwitz` requires.

Why this theorem exists: `repair_selects` evaluates `reducedForms` at `1, 2, 3`, where **no imprimitive form
occurs**, so a `decide` there cannot distinguish the two readings and the *name* was doing the work. `D = 12` is
the smallest discriminant that can. The divergence point was supplied by Stream 1's independent enumerator, and
it is the `LL.md` §S11.1 defect one level down from the one that started this file. -/
theorem reducedForms_counts_imprimitive : reducedForms 12 = [(1, 0, 3), (2, 2, 2)] := by decide +kernel

/-! ### 2. The Fricke involution: an `SL(2,ℤ)` substitution wearing another name -/

/-- **The Fricke matrix is the `Sym²` lift of `S ∈ SL(2,ℤ)`.** `S = ![![0, -1], ![1, 0]]`, i.e.
`(p, q, r, s) = (0, -1, 1, 0)`. Note what is *absent*: no `N`. The integrality of `W_N` on form coefficients is
`S`'s integrality, not a fact about the flux. -/
theorem fricke_eq_sym2_S : fricke = sym2 0 (-1) 1 0 := by decide +kernel

/-- `S` has determinant `1`. With `sym2_isometry_of_sl2` this makes `fricke` an exact isometry of the
discriminant form; with `fricke_is_proper_equivalence` it makes it a *proper* equivalence of forms. -/
theorem sym2_S_det : (0 : ℤ) * 0 - (-1) * 1 = 1 := by decide

/-- **What `Sym²` actually does: it computes the coefficients of `Q ∘ M`.** For every integer `2 × 2` matrix
`M = ![![p, q], ![r, s]]`, the vector `sym2 p q r s *ᵥ ![a, b, c]` is the coefficient triple of
`(x, y) ↦ Q (p x + q y, r x + s y)`. General in all nine variables. This is the property the name `Sym²`
asserts, and it is what turns G9's matrix identities into statements about forms. -/
theorem sym2_is_substitution (p q r s a b c x y : ℤ) :
    (sym2 p q r s *ᵥ ![a, b, c]) 0 * x ^ 2 + (sym2 p q r s *ᵥ ![a, b, c]) 1 * (x * y)
      + (sym2 p q r s *ᵥ ![a, b, c]) 2 * y ^ 2
      = a * (p * x + q * y) ^ 2 + b * ((p * x + q * y) * (r * x + s * y))
        + c * (r * x + s * y) ^ 2 := by
  simp [sym2, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]
  ring

/-- The Fricke matrix sends the coefficient triple `(a, b, c)` to `(c, −b, a)`. -/
theorem fricke_coeffs (a b c : ℤ) : fricke *ᵥ ![a, b, c] = ![c, -b, a] := by
  ext i
  fin_cases i <;> simp [fricke, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]

/-- **Fricke is substitution by `S ∈ SL(2,ℤ)`, with every link of the chain in the kernel.** The left-hand side
is the form whose coefficients the *Fricke matrix itself* produces — not a hand-written triple — and the
right-hand side is the original form evaluated at `S(x,y) = (0·x + (−1)·y, 1·x + 0·y) = (−y, x)`. It is the
instance of `sym2_is_substitution` at `(p,q,r,s) = (0,−1,1,0)`, transported along `fricke_eq_sym2_S`.

With `sym2_S_det` (`det S = 1`) this exhibits the Fricke map as a **proper equivalence** of binary forms. The
remaining step — proper equivalence implies same class — is the *definition* of the class relation, which this
repository does not formalize; it is therefore taken outside the kernel, and `fricke_class_trivial_box` is the
kernel-level check that `reduce` agrees. -/
theorem fricke_is_proper_equivalence (a b c x y : ℤ) :
    (fricke *ᵥ ![a, b, c]) 0 * x ^ 2 + (fricke *ᵥ ![a, b, c]) 1 * (x * y)
      + (fricke *ᵥ ![a, b, c]) 2 * y ^ 2
      = a * (0 * x + (-1) * y) ^ 2 + b * ((0 * x + (-1) * y) * (1 * x + 0 * y))
        + c * (1 * x + 0 * y) ^ 2 := by
  rw [fricke_eq_sym2_S]
  exact sym2_is_substitution 0 (-1) 1 0 a b c x y

/-- **Pointwise equality of binary forms implies coefficient equality** — evaluate at `(1,0)`, `(0,1)`, `(1,1)`.
So nothing is lost by stating `fricke_is_proper_equivalence` as an identity of values rather than of
coefficients. (Raised by Stream 1 as the one thing a reviewer might query about the pointwise formulation.)
Only this direction is stated, and the name says so: the converse is immediate but unused, and `LL.md` §S2.13
records what happens when a one-directional theorem acquires an `iff` name. -/
theorem forms_pointwise_imp_coeffs (a b c a' b' c' : ℤ)
    (h : ∀ x y : ℤ, a * x ^ 2 + b * (x * y) + c * y ^ 2
      = a' * x ^ 2 + b' * (x * y) + c' * y ^ 2) : a = a' ∧ b = b' ∧ c = c' := by
  have h10 := h 1 0
  have h01 := h 0 1
  have h11 := h 1 1
  refine ⟨by nlinarith, by nlinarith, by nlinarith⟩

/-- **The Fricke map is the first step of Gauss reduction.** `reduceStep` opens with exactly this branch — which
is why the enumeration below cannot disagree with the theorem above. -/
theorem fricke_is_first_reduction_step (a b c : ℤ) (h : c < a) :
    DualScaleDyons.AttractorCharges.reduceStep (a, b, c) = (c, -b, a) := by
  simp [DualScaleDyons.AttractorCharges.reduceStep, h]

/-- **It fixes the discriminant for every `N`** — because `b² − 4Nac` is symmetric in `a ↔ c`. -/
theorem fricke_preserves_disc (N a b c : ℤ) :
    qform (gramN N) ![c, -b, a] = qform (gramN N) ![a, b, c] := by
  rw [gramN_is_discriminant, gramN_is_discriminant]; ring

/-- **`PASS(box: 1 ≤ a, c ≤ 4, |b| ≤ 6)` — and be precise about what it checks.** For every positive definite
form in that box, this repository's own `reduce` sends `(c, −b, a)` and `(a, b, c)` to the same reduced form.

*What that is:* a bounded fact about **`reduce`** — that our reduction implementation agrees with the Fricke map
where we have checked. *What it is not:* it does **not** bridge the step from "proper equivalence" to "same
class". That step is a **definition**, and no computation bridges a definition; `reduce` is a reduction
procedure, not a class relation. So this check neither adds to nor substitutes for
`fricke_is_proper_equivalence` — it is a third thing, about the code. Always quote it with its bound, never as
a bare `PASS`. -/
theorem fricke_class_trivial_box :
    ((List.range 4).flatMap fun i =>
      (List.range 13).flatMap fun j =>
        (List.range 4).map fun k =>
          let a : ℤ := (i : ℤ) + 1
          let b : ℤ := (j : ℤ) - 6
          let c : ℤ := (k : ℤ) + 1
          !(decide (0 < 4 * a * c - b * b)) ||
            decide (DualScaleDyons.AttractorCharges.reduce (c, -b, a)
              = DualScaleDyons.AttractorCharges.reduce (a, b, c))).all id = true := by
  decide +kernel

/-! ### 3. The verdict -/

/-- **G10 in one statement.** Left: the Fricke involution is `Sym²` of an `SL(2,ℤ)` element of determinant `1`
and is a proper equivalence of forms, so it fixes every class and selects nothing. Right: the selection is
performed by the definiteness cut, whose statement mentions no modular datum. What this does *not* say — see
the header — is that the modular structure is absent from the rank-2 object: by Shioda–Inose (Tier L) it is the
same object, so the two descriptions agree by construction, not by corroboration. -/
theorem g10_verdict :
    (fricke = sym2 0 (-1) 1 0) ∧
      ((0 : ℤ) * 0 - (-1) * 1 = 1) ∧
      (∀ a b c x y : ℤ, (fricke *ᵥ ![a, b, c]) 0 * x ^ 2 + (fricke *ᵥ ![a, b, c]) 1 * (x * y)
        + (fricke *ᵥ ![a, b, c]) 2 * y ^ 2
        = a * (0 * x + (-1) * y) ^ 2 + b * ((0 * x + (-1) * y) * (1 * x + 0 * y))
          + c * (1 * x + 0 * y) ^ 2) ∧
      (∀ a b c : ℤ, 0 < 4 * a * c - b * b → 3 ≤ 4 * a * c - b * b) ∧
      reducedForms 3 = [(1, 1, 1)] :=
  ⟨fricke_eq_sym2_S, sym2_S_det, fricke_is_proper_equivalence, repair_selects.1,
    repair_selects.2.1⟩

end DualScaleDyons.FrickeRepair
