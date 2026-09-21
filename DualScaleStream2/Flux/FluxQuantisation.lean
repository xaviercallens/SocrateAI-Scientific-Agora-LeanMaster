/-
Stream 9 · S9.5c — quantisation does not bound the fluxes either, for any normalisation.

S9.5 and S9.5b showed that the `O3` tadpole bounds an integer and never the flux quanta, in `H³(T⁶, ℤ)` and in
its rank-8 `ℤ₂ × ℤ₂`-invariant sublattice alike. Both files assumed only that the quanta are integers. The
remaining objection is about **normalisation**: on an orientifold the surviving periods are often required to be
multiples of some factor (the familiar "fluxes must be even on `T⁶/ℤ₂`"), and one might hope that this is what
bounds them. It is not, and this file proves that parametrically in the factor, without pretending to know it.

### The Tier L input, pinned, and its limit
Giddings–Kachru–Polchinski, `papers/foundations/giddings_kachru_polchinski_hep-th_0105097.txt` ll. 534–547,
eq. (2.25): `(1/2πα′)∫_C F₃ ∈ 2πℤ` and `(1/2πα′)∫_C H₃ ∈ 2πℤ` over every 3-cycle `C`. So the periods are
**integers** in those units — which is exactly the modelling of S9.5/S9.5b, and no more.

What GKP (2.25) does *not* fix is the orientifold normalisation: whether the surviving periods form all of `ℤ⁸`
or a proper sublattice. Nor does it fix the `D3`-charge normalisation that would turn the lattice pairing into
the physical `N_flux`. **Neither is pinned here**, and the file is arranged so that its conclusion does not
depend on them.

### What is proved (Tier A)
* `pairing_dvd`: if all quanta of `H` and of `F` lie in `M·ℤ`, then `⟨H, F⟩ ∈ M²·ℤ`.
* `pairing_attains`: every multiple of `M²` is attained by quantised fluxes — the divisibility is exact.
* `quantised_family`, `quantised_family_injective`: **the conclusion.** For every `M` and every attainable value,
  **infinitely many** quantised flux pairs realise it. Rescaling a lattice gives a lattice, so the mechanism of
  S9.5 is untouched by quantisation, whatever the factor.
* `tadpole_range`: from `N_D3 + ½N_flux = 16` with `N_D3 ≥ 0` and `N_flux ≥ 0`, one gets `0 ≤ N_flux ≤ 32`. This
  is arithmetic about integers; it is not connected to the lattice pairing anywhere in this file.

### A conditional remark, deliberately not a result
`convention_factor_bounded` and `convention_hypothesis_tight` are **not** part of the claim above. They say: *if*
one worked in a normalisation in which the lattice pairing is `N_flux` itself — which is **not** established
here, and would need the `D3`-charge normalisation on the quotient from a source — then a coarse isotropic
quantisation would be self-defeating, since `M ≥ 6` gives `M² ≥ 36 > 32` and forces `N_flux = 0`; and the
hypothesis `M ≥ 6` is tight for that argument, since `M = 5` gives `25 ≤ 32`. Two reasons this is a remark and
not a finding: the bridge to `N_flux` is assumed, and the isotropic model `M·ℤ⁸` is not the shape an orientifold
projection actually takes (the physically cited case is `M = 2`, where `N_flux ∈ 4ℤ ∩ [0, 32]` — eight values,
no obstruction). It is recorded to show where the remaining freedom lives.

### Reading (Tier C)
The lattice never produces finiteness: for any normalisation, infinitely many quantised fluxes share a value. So
the sequence S9.5 → S9.5b → S9.5c ends by naming precisely what a real count would need and cannot get from
arithmetic — a sourced normalisation, then the supersymmetry conditions, then the quotient by the duality group.
Nothing here is a statement about vacua.
-/
import DualScaleStream2.Flux.InvariantH3

namespace DualScaleStream2.Flux.Quantisation

open Matrix DualScaleStream2.Flux.InvariantH3

/-- A flux vector is `M`-quantised when every one of its eight quanta is a multiple of `M`. -/
def Quantised (M : ℤ) (v : Fin 8 → ℤ) : Prop := ∀ i, M ∣ v i

/-- **The pairing of two `M`-quantised fluxes is divisible by `M²`.** -/
theorem pairing_dvd (M : ℤ) (H F : Fin 8 → ℤ) (hH : Quantised M H) (hF : Quantised M F) :
    M ^ 2 ∣ invPairing H F := by
  simp only [invPairing, dotProduct, Matrix.mulVec, sq]
  refine Finset.dvd_sum fun i _ => ?_
  exact mul_dvd_mul (hH i) (Finset.dvd_sum fun j _ => Dvd.dvd.mul_left (hF j) _)

/-- The `M`-quantised counterpart of the family of `InvariantH3`: `H = M·e₇`, `F = M·(k·e₀ + m·e₁)`. -/
def hQ (M : ℤ) : Fin 8 → ℤ := fun i => if i = 7 then M else 0
def fQ (M k m : ℤ) : Fin 8 → ℤ := fun i => if i = 0 then M * k else if i = 1 then M * m else 0

theorem hQ_quantised (M : ℤ) : Quantised M (hQ M) := by
  intro i; unfold hQ; split <;> simp

theorem fQ_quantised (M k m : ℤ) : Quantised M (fQ M k m) := by
  intro i; unfold fQ; split
  · exact Dvd.intro k rfl
  · split
    · exact Dvd.intro m rfl
    · simp

/-- **Exactness.** Every multiple of `M²` is the pairing of two `M`-quantised fluxes. -/
theorem pairing_attains (M k : ℤ) : invPairing (hQ M) (fQ M k 0) = M ^ 2 * k := by
  simp [invPairing, hQ, fQ, symJ8, Matrix.mulVec, dotProduct]
  ring

/-- **The family survives quantisation.** For every `M` and every `k`, an infinite family of `M`-quantised
fluxes has the same pairing `M²k`. -/
theorem quantised_family (M k m : ℤ) : invPairing (hQ M) (fQ M k m) = M ^ 2 * k := by
  simp [invPairing, hQ, fQ, symJ8, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]
  ring

theorem quantised_family_injective (M k : ℤ) (hM : M ≠ 0) : Function.Injective (fQ M k) := by
  intro m₁ m₂ h
  have h1 := congrFun h 1
  simp [fQ] at h1
  exact h1.resolve_right hM

/-- The tadpole `N_D3 + ½N_flux = 16` with no anti-branes confines `N_flux` to `[0, 32]`. -/
theorem tadpole_range (nD3 nflux : ℤ) (h : 2 * nD3 + nflux = 32) (h0 : 0 ≤ nD3) (h1 : 0 ≤ nflux) :
    0 ≤ nflux ∧ nflux ≤ 32 := ⟨h1, by omega⟩

/-- **Conditional remark, not a result** (see the header). Assuming a normalisation in which the lattice pairing
is `N_flux`, an isotropic quantisation with `M ≥ 6` gives `M² ≥ 36 > 32` and the budget leaves only
`N_flux = 0`. The hypothesis on the pairing's range is supplied by hand, not derived.

**Update (2026-09-21) — the hypothesis is now sourced, and that is why this stays a remark.**
`docs/STREAM9_ORIENTIFOLD.md` §6e settles where it holds:

* **On the covering `T⁶` it is a theorem of the constants, not a convention.** Giddings–Kachru–Polchinski
  (`papers/foundations/giddings_kachru_polchinski_hep-th_0105097.txt`) fix `2κ₁₀² = (2π)⁷α'⁴` and
  `T₃ = μ₃ = (2π)⁻³α'⁻²` (l. 511), quantise each period into `(2π)²α'ℤ` (eq. 2.25, ll. 538–544), and give
  `N_flux = (1/2κ₁₀²T₃)∫H₃∧F₃` (eq. 4.4, ll. 1306–1320). Composing, the factors cancel exactly:
  **`N_flux = ⟨h,f⟩`**, no leftover constant.
* **On the orientifold quotient it fails.** Tripathy–Trivedi (`papers/foundations/hep-th_0301139.txt`,
  ll. 1834–1841): a *half* cycle of `T²` — closed in `T²/ℤ₂`, not in `T²` — gives a **half-integer** period, and
  Dirac quantisation then demands fluxes from **exotic orientifold planes** (Frey–Polchinski). They avoid it by
  restricting to lattice vectors with **even** coefficients — which is exactly the `M = 2` case this file's
  header already identified as the physically cited one, now sourced rather than asserted.

So the periods on the quotient are not in `ℤ`, which is why no amount of lattice arithmetic here could ever
have determined the factor — `quantised_family_injective` and `pairing_dvd` are about `ℤ`-quanta and remain
exactly as strong as before. The remark stays a remark. -/
theorem convention_factor_bounded (M : ℤ) (hM : 6 ≤ M) (H F : Fin 8 → ℤ)
    (hH : Quantised M H) (hF : Quantised M F) (h0 : 0 ≤ invPairing H F)
    (h32 : invPairing H F ≤ 32) : invPairing H F = 0 := by
  rcases (h0.lt_or_eq).symm with h | hpos
  · exact h.symm
  · have hdvd := pairing_dvd M H F hH hF
    have hle : M ^ 2 ≤ invPairing H F := Int.le_of_dvd hpos hdvd
    nlinarith

/-- The hypothesis `M ≥ 6` above is tight **for that argument**: at `M = 5` the pairing `25` is inside `[0, 32]`,
so the proof cannot be relaxed to `M ≥ 5`. This says nothing about whether `M = 5` is physically realisable. -/
theorem convention_hypothesis_tight :
    invPairing (hQ 5) (fQ 5 1 0) = 25 ∧ (0 : ℤ) ≤ 25 ∧ (25 : ℤ) ≤ 32 := by
  refine ⟨?_, by norm_num, by norm_num⟩
  rw [pairing_attains]; norm_num

end DualScaleStream2.Flux.Quantisation
