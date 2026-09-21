/-
Stream 9 · S9.6b — where the finiteness actually comes from: one positivity condition kills the infinite family.

§6, §6b and §6c proved a negative three times over: the `O3` tadpole bounds an integer and never the flux quanta
— not through the budget, not after the orbifold projection, not under any quantisation factor. Each of them
ended by saying that finiteness must come from the supersymmetry / imaginary-self-duality condition. This file
makes that concrete on the same rank-8 lattice, and exhibits the exact point where the infinite family dies.

### The Tier L input, pinned
Giddings–Kachru–Polchinski, `papers/foundations/giddings_kachru_polchinski_hep-th_0105097.txt`:
* l. 629–631, eq. (2.31): the 3-form field strength of a compactification satisfying their inequality is
  **imaginary self-dual**, `∗₆G₍₃₎ = i G₍₃₎`;
* ll. 1801–1812, eq. (A.13): the decomposition `G = G⁺ + G⁻` with `∗₆G^± = ∓i G^±`, in which the flux action
  splits into a **positive-definite norm** `G⁺_{mnp}G⁺^{mnp}` plus a topological term `∫G ∧ Ḡ`.

The content of that pair, for a lattice: the ISD condition replaces the indefinite symplectic pairing — which is
what §6–§6c worked with — by a **positive-definite** form. Everything below is what that substitution does,
proved for an explicit compatible complex structure on the rank-8 invariant lattice.

### What is proved (Tier A)
* `compStruct_sq`, `compStruct_compatible`: `Jc = −J₈` is a complex structure (`Jc² = −1`) compatible with the
  symplectic form (`Jcᵀ J₈ Jc = J₈`). It exists because `J₈ · J₈ = −1` was already proved in `InvariantH3`.
* `gForm_eq_dot`: the associated form `g(v, w) = ω(v, Jc w)` is **exactly the Euclidean dot product** on `ℤ⁸`.
  This is not a modelling choice dressed up — it is forced by `J₈ · J₈ = −1`.
* `gForm_nonneg`, `gForm_eq_zero_iff`: `g` is positive definite on the lattice.
* `coord_bound`, `isd_ball_finite`: **`{v : g(v,v) ≤ B}` is finite**, with the explicit coordinate bound
  `(v i)² ≤ B` for every `i`.
* `family_norm`: the family of §6b, `F(m) = k·e₀ + m·e₁`, has `g(F(m), F(m)) = k² + m²`.
* `family_cut_to_eleven`: at the tadpole ceiling `32` and `k = 1`, the family that was **infinite** under the
  pairing alone is cut to **exactly the eleven** values `−5 ≤ m ≤ 5`.

### The arc, closed
Same lattice, same family. Under the tadpole pairing: `⟨H, F(m)⟩ = k` for every one of infinitely many `m`
(`InvariantH3.invariant_flux_family`). Under one positive-definite form: eleven. The finiteness was never going
to come from the budget, the projection or the quantisation; it comes from positivity, and this is the smallest
honest demonstration of that.

### What is NOT claimed
* That `g` **is** the physical flux norm. That identification needs the `D3`-charge normalisation on the quotient
  which §6c isolated as the missing Tier L bridge and which is still missing. The number `32` is carried over
  from `tadpole_range` as a ceiling to make the contrast concrete, not as a derived bound on `g`.
* That the compatible complex structure used here is the physical one. The physical one is fixed by the
  complex-structure moduli; `Jc = −J₈` is the canonical choice available on this lattice with no extra data. The
  **mechanism** — an indefinite pairing replaced by a positive-definite form makes balls finite — does not depend
  on which compatible structure is chosen; the specific count `11` does.
* That any of this counts vacua. No moduli stabilisation, no equations of motion, no quotient by the duality
  group. A flux vector is not a vacuum, and eleven flux vectors are not eleven vacua.
-/
import DualScaleStream2.Flux.InvariantH3

namespace DualScaleStream2.Flux.ISDFiniteness

open Matrix DualScaleStream2.Lattice DualScaleStream2.Flux.InvariantH3

/-- The compatible complex structure the invariant lattice already carries: `Jc = −J₈`. -/
def compStruct : Gram 8 := -symJ8

/-- `Jc² = −1`: it is a complex structure. -/
theorem compStruct_sq : compStruct * compStruct = -1 := by
  simp only [compStruct, Matrix.neg_mul, Matrix.mul_neg, neg_neg]
  exact restricted_sq

/-- `Jcᵀ J₈ Jc = J₈`: it is compatible with the symplectic form. -/
theorem compStruct_compatible : compStructᵀ * symJ8 * compStruct = symJ8 := by
  decide +kernel

/-- The form associated to the pair `(ω, Jc)`: `g(v, w) = ω(v, Jc w)`. -/
def gForm (v w : Fin 8 → ℤ) : ℤ := invPairing v (compStruct *ᵥ w)

/-- **The associated form is the Euclidean one.** Forced by `J₈ · J₈ = −1`, not chosen. -/
theorem gForm_eq_dot (v w : Fin 8 → ℤ) : gForm v w = v ⬝ᵥ w := by
  unfold gForm invPairing compStruct
  rw [Matrix.mulVec_mulVec, Matrix.mul_neg, restricted_sq, neg_neg, Matrix.one_mulVec]

theorem gForm_self (v : Fin 8 → ℤ) : gForm v v = ∑ i, v i * v i := by
  rw [gForm_eq_dot]; rfl

/-- Positive semidefinite. -/
theorem gForm_nonneg (v : Fin 8 → ℤ) : 0 ≤ gForm v v := by
  rw [gForm_self]
  exact Finset.sum_nonneg fun i _ => mul_self_nonneg (v i)

/-- Definite: only the zero flux has zero norm. -/
theorem gForm_eq_zero_iff (v : Fin 8 → ℤ) : gForm v v = 0 ↔ v = 0 := by
  rw [gForm_self]
  constructor
  · intro h
    funext i
    have hi : v i * v i = 0 :=
      le_antisymm
        (h ▸ Finset.single_le_sum (f := fun j => v j * v j)
          (fun j _ => mul_self_nonneg (v j)) (Finset.mem_univ i))
        (mul_self_nonneg (v i))
    simpa using mul_self_eq_zero.mp hi
  · rintro rfl; simp

/-- Each coordinate is bounded by the norm. -/
theorem coord_bound (v : Fin 8 → ℤ) (B : ℤ) (h : gForm v v ≤ B) (i : Fin 8) : v i * v i ≤ B :=
  le_trans (Finset.single_le_sum (f := fun j => v j * v j)
    (fun j _ => mul_self_nonneg (v j)) (Finset.mem_univ i)) (by rwa [gForm_self] at h)

/-- **The ball is finite.** One positivity condition, and the flux vectors below a ceiling are finitely many. -/
theorem isd_ball_finite (B : ℤ) : {v : Fin 8 → ℤ | gForm v v ≤ B}.Finite := by
  apply Set.Finite.subset (Set.Finite.pi fun _ : Fin 8 => Set.finite_Icc (-B) B)
  intro v hv
  simp only [Set.mem_univ_pi, Set.mem_Icc]
  intro i
  have hb := coord_bound v B hv i
  constructor <;> nlinarith [hb, mul_self_nonneg (v i), mul_self_nonneg (v i + 1),
    mul_self_nonneg (v i - 1)]

/-- The norm of the family of §6b. -/
theorem family_norm (k m : ℤ) : gForm (fInv k m) (fInv k m) = k * k + m * m := by
  rw [gForm_self]
  simp [fInv, Fin.sum_univ_succ]

/-- **The arc closes.** The family that has the same tadpole pairing for every `m`
(`InvariantH3.invariant_flux_family`) is cut, at the ceiling `32` with `k = 1`, to exactly eleven members. -/
theorem family_cut_to_eleven (m : ℤ) :
    gForm (fInv 1 m) (fInv 1 m) ≤ 32 ↔ (-5 ≤ m ∧ m ≤ 5) := by
  rw [family_norm]
  constructor
  · intro h
    constructor <;> nlinarith [h, mul_self_nonneg (m + 6), mul_self_nonneg (m - 6)]
  · rintro ⟨h1, h2⟩
    nlinarith [h1, h2]

/-! ### S9.6c — the ceiling, derived: at an ISD point `H` is not free

Above, the ceiling `32` was *carried over* from the tadpole budget and applied to `g(F,F)` by fiat. The two are
connected by the ISD condition itself. With `G = F − τH` and `∗G = iG` at `τ = i`, separating real and
imaginary parts gives `∗F = H`: **`H` is determined by `F`**. On this lattice `∗` is the complex structure, so
the ISD partner of `F` is `J₈ F`, and the tadpole pairing of an ISD pair *is* the positive-definite norm.
(Tier L for the ISD condition, GKP eq. (2.31); Tier C for `τ = i`, the square torus and `Jc` being the physical
`∗` — see `docs/STREAM9_ORIENTIFOLD.md` §6f.) -/

/-- **For an ISD pair the tadpole pairing is the norm.** `⟨J₈F, F⟩ = g(F, F) = F · F`. The indefinite pairing
of §6–§6c, restricted to ISD pairs, is positive definite — which is why the budget suddenly bounds the quanta
when it never could before. -/
theorem isd_pairing_eq_norm (F : Fin 8 → ℤ) : invPairing (symJ8 *ᵥ F) F = gForm F F := by
  rw [gForm_self]
  simp [invPairing, symJ8, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]
  ring

/-- **The ceiling is now derived, not carried over.** For an ISD pair the budget `0 ≤ N_flux ≤ 32`
(`FluxQuantisation.tadpole_range`) bounds every flux quantum: `(F i)² ≤ 32`, i.e. `|F i| ≤ 5`. -/
theorem isd_budget_bounds_quanta (F : Fin 8 → ℤ) (h : invPairing (symJ8 *ᵥ F) F ≤ 32) (i : Fin 8) :
    -5 ≤ F i ∧ F i ≤ 5 := by
  have hb : F i * F i ≤ 32 := coord_bound F 32 (by rw [← isd_pairing_eq_norm]; exact h) i
  constructor <;> nlinarith [hb, mul_self_nonneg (F i + 6), mul_self_nonneg (F i - 6)]

/-- Hence finitely many ISD fluxes fit the budget — the finiteness §6, §6b and §6c each failed to obtain. -/
theorem isd_budget_finite : {F : Fin 8 → ℤ | invPairing (symJ8 *ᵥ F) F ≤ 32}.Finite := by
  have : {F : Fin 8 → ℤ | invPairing (symJ8 *ᵥ F) F ≤ 32} = {F | gForm F F ≤ 32} := by
    ext F; simp [isd_pairing_eq_norm]
  rw [this]; exact isd_ball_finite 32

/-- **Of §6b's infinite family, exactly one member is an ISD pair.** The family kept `H = hInv` fixed and let
`F(m)` run; ISD forces `H = J₈ F`, which holds only at `k = 1, m = 0`. So the honest count for that family is
**one**, not eleven: `family_cut_to_eleven` bounded `F` alone and remains an illustration of the mechanism,
which is what its docstring always said it was. -/
theorem family_isd_iff (k m : ℤ) : symJ8 *ᵥ fInv k m = hInv ↔ k = 1 ∧ m = 0 := by
  constructor
  · intro h
    have h7 := congrFun h 7
    have h6 := congrFun h 6
    simp [symJ8, fInv, hInv, Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at h7 h6
    omega
  · rintro ⟨rfl, rfl⟩
    funext i
    fin_cases i <;> simp [symJ8, fInv, hInv, Matrix.mulVec, dotProduct]

end DualScaleStream2.Flux.ISDFiniteness
