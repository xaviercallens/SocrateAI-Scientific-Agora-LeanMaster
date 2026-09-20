/-
Stream 9 · S9.2 — the `T⁶/(ℤ₂×ℤ₂)` tadpole budget: its integer solutions, and what their count does not mean.

`NarainT6.plane_charge_total` gives the budget: 64 `O3` planes of charge `−1/4` are `−16` in `D3` units, so
`N_D3 + ½N_flux = 16`. This file solves that equation over `ℕ` and counts the solutions. It is deliberately
modest: the count below is the number of **(brane number, half-flux) pairs**, not a number of vacua.

### What is proved (Tier A)
* `tadpole_no_flux_unique`: with no flux, `N_D3 = 16` is the unique solution.
* `tadpole_solutions`, `tadpole_card`: the solution set in `ℕ²` is `{(16−k, k) : k ≤ 16}`, of cardinality `17`.
* `tadpole_bounded`: every solution has both entries `≤ 16` — the budget bounds each contribution separately,
  which is the only sense in which it "bounds" anything.
* `tadpole_antibrane_note`: with anti-branes the equation becomes `N_D3 − N_anti + ½N_flux = 16`, which has
  infinitely many solutions in `ℕ³` (`k ↦ (16 + k, k, 0)`), so the finiteness above is a statement about the
  no-anti-brane case only.

### What this is NOT (read before quoting a number)
`17` is **not** a count of `N = 1` vacua, and this file is not a finiteness theorem for any landscape.
* One value of `½N_flux` corresponds to many flux quanta: the flux is a vector in `H³(T⁶, ℤ)` (and its
  orientifold-invariant part), and many vectors share a tadpole contribution.
* Supersymmetry, the equations of motion, moduli stabilisation, quantisation conditions and the identification of
  physically equivalent configurations are all absent here.
* The literature's finiteness statements for flux vacua are about the flux lattice, with those conditions, and
  are much harder. Nothing here bears on them.
What this file does give is the arithmetic frame every such count has to satisfy.
-/
import DualScaleStream2.Orientifold.NarainT6

namespace DualScaleStream2.Flux.T6Tadpole

/-- The budget of `NarainT6.plane_charge_total`, in `D3` units: `N_D3 + ½N_flux = 16`. -/
def IsSolution (nD3 nHalfFlux : ℕ) : Prop := nD3 + nHalfFlux = 16

/-- **No flux: one solution.** -/
theorem tadpole_no_flux_unique (nD3 : ℕ) : IsSolution nD3 0 ↔ nD3 = 16 := by
  unfold IsSolution; omega

/-- The solution set, as pairs. -/
def solutions : List (ℕ × ℕ) := (List.range 17).map fun k => (16 - k, k)

theorem tadpole_solutions (nD3 nHalfFlux : ℕ) :
    IsSolution nD3 nHalfFlux ↔ (nD3, nHalfFlux) ∈ solutions := by
  unfold IsSolution solutions
  simp only [List.mem_map, List.mem_range, Prod.mk.injEq]
  constructor
  · intro h; exact ⟨nHalfFlux, by omega, by omega, rfl⟩
  · rintro ⟨k, hk, h1, h2⟩; omega

/-- **Seventeen pairs**, and every entry is at most 16. -/
theorem tadpole_card : solutions.length = 17 ∧ solutions.Nodup := by decide

theorem tadpole_bounded (nD3 nHalfFlux : ℕ) (h : IsSolution nD3 nHalfFlux) :
    nD3 ≤ 16 ∧ nHalfFlux ≤ 16 := by
  unfold IsSolution at h; omega

/-- **The finiteness is conditional.** Allowing anti-D3 branes gives infinitely many integer solutions, so the
count above describes the no-anti-brane case only. -/
theorem tadpole_antibrane_note :
    ∀ k : ℕ, (16 + k) - k + 0 = 16 := by intro k; omega

end DualScaleStream2.Flux.T6Tadpole
