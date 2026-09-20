/-
G7 — the grid that measures itself: face-centre separations are quantised.

Einstein's method insists that a measurement distinguish its object from its instrument. This file supplies the
arithmetic for one case where the distinction was at risk.

### The datum and the paradox
An external group measured a floor on the separation between distinct vortex lines in a simulated superfluid
tangle: `F = 0.943 ξ`, at `6.1×` the null's 95th percentile, by a threshold-free method
(`docs/reviews/2026-09-19_quantumfluids_dual_scale_report.md`, Tier L). Re-analysing their published results file
for paper 12 gives two facts they do not state: with their `ξ = 1.5 Δx`, the value `F = 0.943 ξ` is
`1.4142135623730903 Δx`, agreeing with `√2` to **fourteen significant figures**; and the ten smallest inter-line
distances in that file are **bit-identical**. Either the healing length happens to equal the face diagonal of the
simulation grid — absurd, since `ξ` was *set* to `1.5 Δx` by convention — or the measurement is reading the
instrument.

### What is proved here (Tier A)
Their traced lines are located at **face centres** of the grid, so the separations available to the measurement
are not continuous. In doubled integer coordinates, where a face centre of a cubic grid of spacing `Δ` has one
odd and two even entries, the squared separation `dsq` of two distinct face centres satisfies:

* `separations_even`: `dsq` is always **even** — so in physical units the squared separations are half-integer
  multiples of `Δ²`, never arbitrary;
* `min_separation_two`: the smallest nonzero value is `2`, i.e. `Δ/√2 ≈ 0.707 Δ`, which is exactly the figure the
  authors quote as what discretisation alone permits;
* `measured_value_occurs`: the value `8`, i.e. `√2 Δ` — the measured floor — **occurs**, and is the fourth
  available separation.

So the reported floor is a member of a discrete spectrum fixed by the instrument. That does not make it wrong; it
makes the resolution caveat load-bearing rather than decorative.

### Reading (Tier C), and the general form
Any "minimum separation" statistic computed on a discretised field measures `max(physical floor, instrument
quantum)`. The instrument quantum must be reported beside the result. A degenerate minimum — the same value
attained many times to the last bit — is the tell that the second term is winning. The authors' own requirement
`ξ/Δx ≳ 5` is the condition under which the first term can be seen, and their split verdict is the honest one.

### Scope
Nothing here is about superfluids, vortices or the dual-scale programme. It is the geometry of a cubic grid,
proved on a finite box, and it is offered as a check on a measurement — not as a result about physics.
-/
import Mathlib

namespace DualScaleDyons.GridQuantum

/-- Doubled integer coordinates: a face centre of a cubic grid has exactly one odd entry. -/
abbrev Pt := ℤ × ℤ × ℤ

def box : List ℤ := [-1, 0, 1]

/-- The face centres of a `3 × 3 × 3` block of cells, in doubled coordinates. -/
def centres : List Pt :=
  box.flatMap fun i => box.flatMap fun j => box.flatMap fun k =>
    [(2 * i + 1, 2 * j, 2 * k), (2 * i, 2 * j + 1, 2 * k), (2 * i, 2 * j, 2 * k + 1)]

/-- Squared separation in doubled coordinates; the physical squared separation is this over `4`. -/
def dsq (p q : Pt) : ℤ :=
  (p.1 - q.1) ^ 2 + (p.2.1 - q.2.1) ^ 2 + (p.2.2 - q.2.2) ^ 2

/-- Every nonzero squared separation occurring in the block. -/
def seps : List ℤ :=
  (centres.flatMap fun p => centres.map fun q => dsq p q).filter (fun d => d != 0)

/-- Exactly one coordinate of a face centre is odd — the defining property, checked. -/
theorem centres_are_face_centres :
    centres.all (fun p => (p.1 % 2 != 0).toNat + (p.2.1 % 2 != 0).toNat +
      (p.2.2 % 2 != 0).toNat == 1) = true := by decide +kernel

/-- **The separations are quantised.** Every nonzero squared separation is even, so in physical units the squared
separations are half-integer multiples of `Δ²`. -/
theorem separations_even : seps.all (fun d => d % 2 == 0) = true := by decide +kernel

/-- **The smallest available separation** is `2` in doubled units, i.e. `Δ/√2`. -/
theorem min_separation_two : seps.min? = some 2 := by decide +kernel

/-- **The measured floor is one of them.** `8` in doubled units is `√2 Δ`, the reported `F = 0.943 ξ`. -/
theorem measured_value_occurs : seps.contains 8 = true := by decide +kernel

/-- The first four available separations, in doubled units: `2, 4, 6, 8`. The measured value is the fourth. -/
theorem first_four_available :
    seps.contains 2 = true ∧ seps.contains 4 = true ∧ seps.contains 6 = true ∧
      seps.contains 8 = true := by decide +kernel

end DualScaleDyons.GridQuantum
