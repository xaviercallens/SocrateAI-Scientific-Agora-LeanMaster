# Stream 9 — completion report (2026-09-21, `v3.46.0`)

**Orientifolds of `T⁶`: what lattice arithmetic alone can and cannot decide about a flux landscape.**
Full text: `docs/STREAM9_ORIENTIFOLD.md`. Lessons: `LL.md` §S10, §S11. This page is the summary for a reader
who will not open either.

## The question

Stream 9 was opened as a **control**, not as a continuation of the dual-scale hypothesis: take a different
compactification — the `T⁶/ℤ₂×ℤ₂` orientifold, the standard route to `N = 1` — and ask how far the
certifiable ingredients (lattices, involutions, integer charges) actually reach. Where does a *finite* answer
come from?

## The answer, in one paragraph

**The tadpole bounds an integer, never the flux quanta** — not through the budget (§6), not through the
orbifold projection (§6b), not through any quantisation factor (§6c); in each case the kernel exhibits
infinitely many integer fluxes per tadpole value. **Finiteness comes from supersymmetry.** The ISD condition
forces `H = ∗F`, so an ISD pair is one lattice vector, not two; on it the indefinite tadpole pairing *is* the
positive-definite norm, `⟨J₈F, F⟩ = F·F` (§6f); and only then does the budget bound every quantum
(`|Fᵢ| ≤ 5`). Of the infinite family that defeated the budget, **exactly one member is ISD**. Separately, the
orders of lattice automorphisms are governed by `ψ(n) ≤ d` and **not** by the often-quoted `φ(n) ≤ d`, which is
false for every `d ≥ 5`.

## What is proved (Tier A — 10 files, 106 theorems, `DualScaleStream2/Orientifold/` and `/Flux/`)

| Step | File | Result |
|---|---|---|
| — | `NarainT6` | `Γ₆,₆ = U⁶` even unimodular, signature `(6,6)`; worldsheet parity `Ω` is an **anti**-isometry (`ΩᵀGΩ = −G`), so an orientifold group is not a subgroup of `O(6,6;ℤ)` |
| S9.1 | `InvariantSublattice` | what `Ωθᵢ` fixes is a maximal totally isotropic sublattice of rank 6 |
| S9.2 | `T6TadpoleFiniteness` | `N_D3 + ½N_flux = 16` has 17 integer solutions — **which are not vacua** |
| S9.3–4 | `Crystallography`, `CrystallographicOrders` | **`φ(n) ≤ d` refuted**: four explicit elements of `SL(6,ℤ)` of order 15, 20, 24, 30, each with `φ(n) = 8 > 6` |
| S9.4b | `CrystallographicArithmetic` | **`crystallographic_restriction`: `ψ(n) ≤ d`, unconditional.** Sharp on both sides: `no_order_fifteen_in_rank_five`, while rank 6 realises it |
| S9.5 | `FluxLattice` | `H³(T⁶,ℤ)` rank 20, unimodular symplectic; infinitely many fluxes per budget value |
| S9.5b | `InvariantH3` | the projection cuts rank `20 → 8` and leaves the infinite family intact |
| S9.5c | `FluxQuantisation` | for **any** quantisation factor `M`, still infinitely many pairs per value |
| S9.6b | `ISDFiniteness` | ISD replaces the symplectic pairing by a positive-definite form — forced by `J₈² = −1`, not chosen; balls are finite |
| S9.6c | `ISDFiniteness` | **the ceiling derived**: `isd_pairing_eq_norm`, `isd_budget_bounds_quanta`, `family_isd_iff` |

## What is sourced (Tier L, every pin checked against the file)

* `⟨H,F⟩ = N_flux` **exactly on the covering torus** — GKP `hep-th/0105097` l. 511 (`2κ₁₀² = (2π)⁷α'⁴`,
  `T₃ = μ₃`), ll. 538–544 (eq. 2.25), ll. 1306–1320 (eq. 4.4). The constants cancel with nothing left over.
* **On the quotient it is obstructed** — Tripathy–Trivedi `hep-th/0301139` ll. 1834–1841: half cycles give
  half-integer periods, Dirac quantisation then needs exotic O-planes (Frey–Polchinski), avoided by restricting
  to even coefficients. That is why no lattice argument could ever have fixed the factor.
* ISD, `∗₆G = iG` — GKP ll. 629–631 eq. (2.31), with `G = F − τH` at l. 169; the `G±` split, ll. 1801–1812 eq. (A.13).
  At `τ = i` the real and imaginary parts of ISD read `∗F = H`, `∗H = −F`.

## What is assumed (Tier C — named, not hidden)

`τ = i`; the square torus; and that `Jc = −J₈` is the physical Hodge star on the invariant lattice. The
**mechanism** (ISD ⇒ pairing = norm ⇒ finiteness) does not depend on the point in moduli space. The **numbers**
`32` and `5` do.

## What is NOT claimed

No vacuum, no spectrum, no `N = 1`, no chirality, and **no vacuum count**: there is no moduli stabilisation, no
equation of motion, and no quotient by the duality group anywhere in this stream. Seventeen budget solutions
are not seventeen vacua; one ISD family member is not one vacuum. Nothing here connects to the dual-scale
proposal — Stream 9 is a change of compactification, and Stream 8's conclusions do not transfer to it.

## Three corrections this stream made to itself

1. **A target that was false.** "`φ(n) ≤ d`" sat in the doc as *the next thing to prove* through five releases
   of green gates. It is false for `d ≥ 5`. No theorem depended on it, so no gate could see it. (`LL.md` §S10.1)
2. **A definition that was not what its name said.** `psi` was wrong above `p⁸` — `psi 512 = 128` where
   `φ(512) = 256` — and every theorem still passed, because all of them quantified below the cap. Fixed, pinned
   at the first discriminating input, and then *identified* in the kernel (`primePart_eq_ord_proj`,
   `psiM_eq_psi`). (`LL.md` §S11.1)
3. **An estimate that was never examined.** The last half of S9.4b was deferred three times as "needs the
   isotypic decomposition of `ℚ^d`, multi-session". It needed the *degree* of the minimal polynomial and three
   Mathlib lemmas, and compiled first try. S9.6c was likewise "needs a pinned normalisation" when the link was
   the ISD condition already pinned two sections earlier. **An over-estimate is the dangerous direction: it
   silently prevents the attempt, so it never gets corrected.**

## What is left, and why it is not this stream's

**S9.6 — the massless spectrum, and whether a chiral one is reachable.** That is not lattice arithmetic: it
needs brane configurations, open-string sectors and their own pinned sources. It would be a new stream with its
own scope statement, not a last step of this one.

Anything that becomes a physical prediction is frozen by git tag before comparison, as in Streams 6–7.
