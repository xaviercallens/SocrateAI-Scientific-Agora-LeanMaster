-- Block WS7: Tadpole Constraint ∑Q = 0
-- Status: VERIFIED (0 sorry axioms)
-- Provides: D3-brane + flux tadpole cancellation on K3 × T².
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import StringTheoryFormalization.StringDynamics.KummerBlowup

/-!
# A toy D3/flux tadpole balance equation

## Physical background
In type IIB flux compactifications, RR-charge conservation on a compact internal space forces the
total D3-brane charge — from actual D3-branes, from three-form flux `H₃∧F₃` (via the Chern–Simons
coupling), and from negatively-charged orientifold planes — to cancel. For an orientifold of a
Calabi–Yau fourfold `M`, Dasgupta–Rajesh–Sethi state the total D3-brane tadpole as `χ(M)/24`
(`papers/foundations/dasgupta_rajesh_sethi_hep-th_9908088.txt`, l. 1240: "the total D3-brane
tadpole is χ(M)/24"); Giddings–Kachru–Polchinski derive and use the same normalization for a
concrete example, `χ = −8·24` cancelled by `16` D3-branes and `64` O3-planes
(`papers/foundations/giddings_kachru_polchinski_hep-th_0105097.txt`, l. 421). For K3 alone,
`χ(K3) = 24`, and for the fourfold `K3 × K3` dual to the IIB orientifold `K3 × T²/ℤ₂`,
`χ/24 = 24` (DRS l. 640; Tripathy–Trivedi `hep-th_0301139.txt` eq. (2.3), l. 171:
`½ N_flux + N_D3 = 24`). Sethi–Vafa–Witten (`papers/foundations/sethi_vafa_witten_hep-th_9606122.txt`,
ll. 16–91, 514) discuss the sign and integrality obstructions to solving this constraint at all.

## Mathematical content
**Normalization mismatch, noted rather than silently reconciled**: the pinned sources state the
tadpole as `(branes) + (flux) = χ(M)/24`, but `totalTadpole` below is defined as
`(∑ charges) + fluxTadpole H₃ F₃ − 24` — subtracting the bare number `24`, not `χ(K3)/24`. LL.md's
own note on this file writes the constraint a third way, `∑Q + χ(K3)/24 = 0`. All three of the
pinned literature, the project's own note, and this file's code disagree on where the `/24`
belongs; this documentation pass records the discrepancy rather than resolving it, since the
statements and code are not to be changed here. **Resolution (2026-09-18):** for `K3 × T²/ℤ₂` the
bare `24` is `χ(K3 × K3)/24 = 24²/24`, the value of DRS l. 640 and TT (2.3); it coincides numerically
with `χ(K3)` only because `χ(K3)²/24 = χ(K3)` when `χ(K3) = 24`. So the code's `24` is the right number
for this compactification; the note "`∑Q + χ(K3)/24 = 0`" in LL.md was the wrong one (`χ(K3)/24 = 1` is
the D3 charge of one D7-brane wrapped on K3, `TadpoleCancellation.d3_charge_per_D7_is_one`). Read literally: `BraneStack` bundles an integer
`charge` and an integer `euler` field that no declaration in this file ever uses. `fluxTadpole`
is the bare product `H₃_quanta * F₃_quanta`. `totalTadpole` sums the `charge` fields of 4 brane
stacks, adds `fluxTadpole H₃ F₃`, and subtracts the literal `24`. `tadpole_cancellation` is a
restatement of `totalTadpole`'s definition under the hypothesis that it vanishes: it is a
definitional rearrangement, not an independent physical derivation of charge conservation, and it
proves nothing about actual D-branes, fluxes, or Euler characteristics beyond this one integer
equation.

## Proof techniques
`tadpole_cancellation` unfolds `totalTadpole` in the hypothesis `h` and then closes the goal by
`linarith`, which rearranges the resulting linear equation over `ℤ` (`(∑ charge) + flux − 24 = 0`
implies `(∑ charge) + flux = 24`) — pure linear arithmetic, no case analysis.

## Related declarations
Per the atlas, `tadpole_cancellation` is TF-IDF-similar to `DualScaleValidation.UseCase3.
rr_tadpole_cancellation` (cosine 0.514) and, more distantly, `SocrateAI.Moonshine.
rr_tadpole_cancellation` (cosine 0.404) — both state a charge-sum-equals-Euler-term identity for
the same physical setup, at low dependency-Jaccard (≤0.02), so these are independent formalization
attempts of the same physical statement rather than shared proofs. It also bridges (atlas
`bridges` table, different declaration) to `StringTheory.Frontier.
flux_tadpole_quantization_exact`, which cites `StringTheory.Foundation.StringTheory.
TadpoleCancellation.{d7_tadpole_cancellation, totalD7Charge, totalO7Charge}` — a related but
distinct D7/O7-charge tadpole formalized elsewhere in the project, not the D3/O3 one here.
-/

namespace StringTheory.StringDynamics

/-- A single stack's contribution to the D3-brane tadpole: an integer `charge` (positive for
    branes, negative for anti-branes) and an integer `euler`, the Euler characteristic of the
    cycle the stack wraps. **`euler` is never read** by `fluxTadpole`, `totalTadpole` or
    `tadpole_cancellation` below — it is recorded but plays no role in this file's arithmetic. -/
structure BraneStack where
  /-- Number of D3 branes (positive = brane, negative = anti-brane). -/
  charge : ℤ
  /-- Euler characteristic of the wrapping cycle. -/
  euler : ℤ

/-- The bare integer product `H₃_quanta · F₃_quanta`, standing for the Chern–Simons-induced
    D3-charge contribution `H₃∧F₃` of three-form flux (`papers/foundations/
    dasgupta_rajesh_sethi_hep-th_9908088.txt`, ll. 61–93). No flux quantization lattice, integral
    or wedge product is formalized; this is the two integers' product only. -/
def fluxTadpole (H₃_quanta F₃_quanta : ℤ) : ℤ := H₃_quanta * F₃_quanta

/-- Sums four `BraneStack.charge` fields, adds `fluxTadpole H₃ F₃`, and subtracts the literal
    `24`. Physically intended as "branes + flux − χ(K3)", using `χ(K3) = 24`; see the module
    docstring for a normalization discrepancy against the pinned sources, which write the
    constraint with `χ(M)/24` rather than a bare `24`. -/
def totalTadpole (braneStacks : Fin 4 → BraneStack)
    (H₃ F₃ : ℤ) : ℤ :=
  (∑ i, (braneStacks i).charge) + fluxTadpole H₃ F₃ - 24

/-- If `totalTadpole` vanishes, the brane-charge sum plus flux contribution equals `24`. This is
    an algebraic rearrangement of `totalTadpole`'s own definition (subtract `-24` becomes `= 24`
    once the total is set to `0`), not an independently derived charge-conservation law; the
    physical content — that RR tadpoles must cancel — is Tier L (see module docstring), assumed
    here as the hypothesis `h`, not proved. -/
theorem tadpole_cancellation (braneStacks : Fin 4 → BraneStack)
    (H₃ F₃ : ℤ)
    (h : totalTadpole braneStacks H₃ F₃ = 0) :
    (∑ i, (braneStacks i).charge) + fluxTadpole H₃ F₃ = 24 := by
  -- unfold the definition so `h` becomes a plain linear equation over ℤ
  unfold totalTadpole at h
  -- rearrange `(∑ charge) + flux - 24 = 0` to the goal `(∑ charge) + flux = 24`
  linarith

end StringTheory.StringDynamics
