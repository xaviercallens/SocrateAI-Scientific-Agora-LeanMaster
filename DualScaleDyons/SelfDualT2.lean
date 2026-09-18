/-
Stream 8 · E2 — "maximal self-duality": the most symmetric point of T² and the most attractive K3.

### The principle and its source (Tier L)
Kofman–Linde–Liu–Maloney–McAllister–Silverstein (`hep-th_0403001.txt`): quantum production of light
particles traps rolling moduli at enhanced symmetry points; the moduli "come to rest on a locus of maximally
enhanced symmetry" — for a torus, "all circles end up at the self-dual radius" (ll. 1299–1307) — and trapping
"will select the ESPs with the largest number of light states" (ll. 1309–1311), within the range allowed by
Hubble friction and the potential. GPR (`giveon_hep-th_9401139.txt` ll. 2017–2032): on T² the two points of
maximally enhanced worldsheet symmetry are `(τ, ρ) = (i, i)` with `(SU(2)×SU(2))_L × (SU(2)×SU(2))_R` and the
`SU(3)_L × SU(3)_R` point. This file makes the count of light gauge bosons exact.

### Conventions (as in `DualScaleStream2.DFT.GeneralizedMetric`)
Charge `Z = (w₁, w₂, n₁, n₂)`, `η = [[0, I], [I, 0]]`, Hull–Zwiebach `H(G, B) = [[G − BG⁻¹B, BG⁻¹], [−G⁻¹B, G⁻¹]]`,
`α' = 1`. A massless left-moving gauge boson (a *left root*) has `p_R = 0`, `p_L² = 2`, i.e.
`ZᵀHZ = ZᵀηZ = 2`; a right root has `ZᵀHZ = 2`, `ZᵀηZ = −2`. At `(τ, ρ) = (ω, ω)`, `ω = e^{2πi/3}`:
`G = [[1, −1/2], [−1/2, 1]]`, `B = [[0, −1/2], [1/2, 0]]`, and (computed exactly by hand and checked with
rational arithmetic) `3H = h3w` below. At `(i, i)`: `G = I`, `B = 0`, `H = I`. The link of `h3w` to Stream 2's
real-valued `genMetric` is not formalized here (it is the same formula evaluated at rational `G`, `B`).

### What is proved (Tier A)
* `h3w_bound`: `15(3ZᵀHZ − |Z|²)` is a sum of squares, so `ZᵀHZ = 2` forces `|Zᵢ| ≤ 2`: the root count below
  is complete, not a box search.
* `roots_ww`: at `(ω, ω)` there are exactly **6** left and **6** right roots (`SU(3)_L × SU(3)_R`).
* `roots_ii`: at `(i, i)` there are exactly **4** left and **4** right roots (`SU(2)²` each side).
* `roots_circle`: at the self-dual radius of a circle, 2 left roots (`SU(2)`) — the Stream 6 point.
* `ww_root_lattice_is_A2`: two left roots at `(ω, ω)` have `p_L`-Gram matrix `[[2, −1], [−1, 2]]` (the `A₂`
  Cartan matrix), and `[[2, 1], [1, 2]]` — the transcendental lattice `T(X₃)` of the most attractive K3
  (`WhichK3.most_attractive`, form `(1, 1, 1)`, over `τ = ω`) — is isometric to it by `(x, y) ↦ (x, −y)`.

### Reading (Tier C) and what is not claimed
Under the trapping principle, T² comes to rest at `(ω, ω)` (6 + 6 light gauge bosons, the maximum possible in
rank 2 — the kissing number of the plane, standard), not at `(i, i)`; the attractive K3 over the same `τ = ω`
has `T(X) ≅ A₂`, the root lattice of that `SU(3)`. Not claimed: that trapping operates in our universe, that
the K3 factor is thereby fixed (its own maximal-enhancement point is an open problem, P8.4c), or any
observable consequence (K3 × T² is `N = 4`, non-chiral).
-/
import Mathlib

namespace DualScaleDyons.SelfDualT2

/-- `3·H(G, B)` at `(τ, ρ) = (ω, ω)`, basis `(w₁, w₂, n₁, n₂)`. -/
def h3w : Fin 4 → Fin 4 → ℤ := ![![4, -2, -1, -2], ![-2, 4, 2, 1], ![-1, 2, 4, 2], ![-2, 1, 2, 4]]

/-- `3ZᵀHZ` at `(ω, ω)`. -/
def q3w (Z : Fin 4 → ℤ) : ℤ := ∑ i, ∑ j, Z i * h3w i j * Z j

/-- `ZᵀηZ = 2(w·n)`. -/
def qEta (Z : Fin 4 → ℤ) : ℤ := 2 * (Z 0 * Z 2 + Z 1 * Z 3)

/-- `ZᵀHZ` at `(i, i)` (`H = I`). -/
def qI (Z : Fin 4 → ℤ) : ℤ := ∑ i, Z i * Z i

/-- **Completeness bound**: `15(3ZᵀHZ − |Z|²) = 5(3z₀ − 2z₁ − z₂ − 2z₃)² + (5z₁ + 4z₂ − z₃)² + 24(z₂ + z₃)²`,
so `ZᵀHZ = 2` (i.e. `q3w Z = 6`) forces `|Zᵢ| ≤ 2`. -/
theorem h3w_sos (Z : Fin 4 → ℤ) :
    15 * (q3w Z - ∑ i, Z i * Z i) =
      5 * (3 * Z 0 - 2 * Z 1 - Z 2 - 2 * Z 3) ^ 2 + (5 * Z 1 + 4 * Z 2 - Z 3) ^ 2 + 24 * (Z 2 + Z 3) ^ 2 := by
  simp [q3w, h3w, Fin.sum_univ_four]
  ring

theorem h3w_bound (Z : Fin 4 → ℤ) (h : q3w Z = 6) (i : Fin 4) : -2 ≤ Z i ∧ Z i ≤ 2 := by
  have hs := h3w_sos Z
  have hsum : ∑ j, Z j * Z j ≤ 6 := by
    nlinarith [sq_nonneg (3 * Z 0 - 2 * Z 1 - Z 2 - 2 * Z 3), sq_nonneg (5 * Z 1 + 4 * Z 2 - Z 3),
      sq_nonneg (Z 2 + Z 3)]
  have hi : Z i * Z i ≤ 6 := by
    have := Finset.single_le_sum (f := fun j => Z j * Z j) (fun j _ => mul_self_nonneg (Z j))
      (Finset.mem_univ i)
    simpa using le_trans this hsum
  constructor <;> nlinarith

/-- All `Z` with entries in `[-2, 2]`. -/
def box : List (Fin 4 → ℤ) :=
  let r : List ℤ := [-2, -1, 0, 1, 2]
  r.flatMap fun a => r.flatMap fun b => r.flatMap fun c => r.map fun d => ![a, b, c, d]

/-- **At `(ω, ω)`: exactly 6 left and 6 right roots** (complete by `h3w_bound`). -/
theorem roots_ww :
    (box.filter fun Z => q3w Z == 6 && qEta Z == 2).length = 6 ∧
      (box.filter fun Z => q3w Z == 6 && qEta Z == -2).length = 6 := by decide +kernel

/-- **At `(i, i)`: exactly 4 left and 4 right roots** (`ZᵀZ = 2` forces `|Zᵢ| ≤ 1`, inside the box). -/
theorem roots_ii :
    (box.filter fun Z => qI Z == 2 && qEta Z == 2).length = 4 ∧
      (box.filter fun Z => qI Z == 2 && qEta Z == -2).length = 4 := by decide +kernel

/-- `ZᵀZ = 2` bounds the entries by 1, so the `(i, i)` count is complete too. -/
theorem qI_bound (Z : Fin 4 → ℤ) (h : qI Z = 2) (i : Fin 4) : -1 ≤ Z i ∧ Z i ≤ 1 := by
  have hi : Z i * Z i ≤ 2 := by
    have := Finset.single_le_sum (f := fun j => Z j * Z j) (fun j _ => mul_self_nonneg (Z j))
      (Finset.mem_univ i)
    simp only [qI] at h
    simpa [h] using this
  constructor <;> nlinarith

/-- **Circle at the self-dual radius** (`H = I₂`, `η = [[0,1],[1,0]]`): 2 left roots `(w, n) = ±(1, 1)`. -/
theorem roots_circle :
    (([-2, -1, 0, 1, 2] : List ℤ).flatMap fun w => ([-2, -1, 0, 1, 2] : List ℤ).map fun n => (w, n)).filter
      (fun p => p.1 * p.1 + p.2 * p.2 == 2 && 2 * p.1 * p.2 == 2) = [(-1, -1), (1, 1)] := by decide

/-- `6⟨p_L(Z), p_L(Z')⟩ = Zᵀ(3H)Z' + 3 ZᵀηZ'` at `(ω, ω)`. -/
def pL6 (Z Z' : Fin 4 → ℤ) : ℤ :=
  (∑ i, ∑ j, Z i * h3w i j * Z' j) + 3 * (Z 0 * Z' 2 + Z 1 * Z' 3 + Z 2 * Z' 0 + Z 3 * Z' 1)

/-- **The `(ω, ω)` roots span `A₂`, and `T(X₃) ≅ A₂`.** The left roots `r₁ = (1,0,1,0)`, `r₂ = (0,1,−1,1)` have
`p_L`-Gram matrix `[[2, −1], [−1, 2]]`; the form `(1,1,1)` of the most attractive K3, `[[2,1],[1,2]]`, is mapped to
it by `diag(1, −1)`. -/
theorem ww_root_lattice_is_A2 :
    let r1 : Fin 4 → ℤ := ![1, 0, 1, 0]
    let r2 : Fin 4 → ℤ := ![0, 1, -1, 1]
    q3w r1 = 6 ∧ qEta r1 = 2 ∧ q3w r2 = 6 ∧ qEta r2 = 2 ∧
      pL6 r1 r1 = 12 ∧ pL6 r2 r2 = 12 ∧ pL6 r1 r2 = -6 ∧
      (!![1, 0; 0, -1] : Matrix (Fin 2) (Fin 2) ℤ) * !![2, 1; 1, 2] * !![1, 0; 0, -1] = !![2, -1; -1, 2] := by
  decide +kernel

end DualScaleDyons.SelfDualT2
