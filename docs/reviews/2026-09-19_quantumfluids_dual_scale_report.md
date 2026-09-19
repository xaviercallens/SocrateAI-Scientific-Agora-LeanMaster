# Received report — dual scale in quantum fluids (2026-09-19)

**Source as given:** `/home/xavkal/xdev/SocrateAI-Scientific-QuantumFluids`, consolidated in that repository's
`docs/DUAL_SCALE_PROPOSAL.md`. **Not reachable from this VM** (no such path here, nor any `*QuantumFluid*`
directory on either disk), so **nothing below has been re-checked by this repository**. It is recorded verbatim, as
`docs/reviews/` requires for anything arriving from outside, and then assessed. Recording is not endorsement: in
LeanMaster's tier system this is Tier X (another repository's claim) until it is pinned as `repo@commit` with its
own gate outputs, at which point the parts LeanMaster relies on become Tier L.

---

## 1. Verbatim

> The dual-scale proposal for quantum fluids now exists as a stated, proved, and tested object. Consolidated in docs/DUAL_SCALE_PROPOSAL.md; build clean, all 51 theorems Comparator-accepted.
>
> The proposal
>
> Define the dual length ℓ(k) := ε(k)²/(ħ²c²k³), which needs only a measured dispersion and the sound speed. Its phonon limit is 1/k and its free-particle limit is k/k*². The Bogoliubov dispersion is Pythagorean in those two branches, so
>
> ℓ_B(k) = 1/k + k/k*² exactly — the R + α′/R shape as an identity, not an analogy, with R = 1/k and α′ = 1/k*².
>
> Proved (DualLength.lean, 12 theorems, standard axioms, Comparator-checked)
>
> - ℓ_B is invariant under the involution k ↦ k*²/k, which exchanges the two branches.
> - ℓ_B ≥ 2/k* = √2 ξ, with equality iff k = k*.
> - Equivalently: ε(k)² ≥ (2ħ²c²/k*)k³ — the dispersion never dips below a k^{3/2} envelope tangent at the self-dual point.
> - Equivalently, via Feynman's relation: the bound is S(k) ≤ √(k/2k*), a statement about the static structure factor, testable by diffraction alone.
> - Falsification lemmas making "measured ℓ < 2/k* ⟹ not Bogoliubov" a theorem.
>
> Negative controls (floor 3/k*, bound k/k*) both fail to compile.
>
> Measured — and it refutes the hypothesis for ⁴He
>
> At SVP: no interior minimum; ℓ/(√2ξ) = 0.047 at the roton, i.e. the roton sits 4.6× below the envelope in energy; duality error 132%. Across pressure the shortfall deepens monotonically from 21× at 0 bar to 51× at 24 bar. All four pre-registered predictions confirmed.
>
> Two controls earned their keep. A positive control voided an entire run by revealing that k* lay outside the 7-pressure table's range — a data-scope error, not a code error. And the c-recovery check returned 238.8 m/s against the literature 238.3.
>
> The physics is textbook — the roton is low because ⁴He is strongly correlated. I claim no novelty for it. What is new is only the compression into one dimensionless number with a Lean-checked meaning.
>
> What survives
>
> DS-QF′: the dual-scale structure belongs to the weakly interacting regime, and ℓ/(√2ξ) measures departure from it. This is sharper than the original, since it says where the structure should hold. It is untested — it needs cold-atom or S(k) data, neither of which this repo holds. I deliberately did not state the LHY/Beliaev correction coefficient, because I could not verify it.
>
> Companion dynamical result
>
> The complexified shell model is a Hamiltonian SHG chain, giving a second invariant H; Liouville and energy conservation fall out as corollaries, and H ≡ 0 on real data — the phase carries the second law. The σ-rule: a regulator of order k^σ controls the k^{σ−1} norm uniformly in the cutoff, so quantum pressure (σ=2) does not reach enstrophy. The completed search (N ≤ 6, controls passing) confirms no "enstrophy + positive quartic" invariant exists.
>
> Two process notes I recorded rather than smoothed over: the first search died on its own timeout from a 1.25 GB cache — a bookkeeping stop, never a finding — and my registered prediction was wrong in its count (I forgot the trivial invariant mass²) though right in its content.

---

## 2. What this is, read carefully

The report is **a refutation with a surviving weaker successor**, and it says so itself. The headline that matters
for LeanMaster is not "51 theorems": it is

* **the `R + α'/R` shape is an identity for the Bogoliubov dispersion**, with `R = 1/k`, `α' = 1/k*²` — the algebraic
  structure this project formalises appears, exactly, in a laboratory system; and
* **⁴He fails the bound by a factor 21–51**, so the dual-scale structure does **not** describe ⁴He. The claimed
  domain of validity shrinks to the weakly interacting regime (DS-QF′), which the report states is **untested**.

The methodological quality is the part worth importing: pre-registered predictions, negative controls that must
fail to compile, a positive control that voided a run, a units/recovery check (238.8 vs 238.3 m/s), and two process
failures recorded rather than smoothed. That is the same discipline as Streams 6–7 here.

## 3. What LeanMaster may and may not do with it

| Use | Allowed? |
|---|---|
| Cite "the `R + α'/R` shape is an identity for Bogoliubov, kernel-checked elsewhere" as **Tier L**, with `repo@commit` and the theorem name | Only once the repository is reachable and pinned; not today |
| Say "the dual-scale principle is validated by fluid physics" | **No.** The measurement refutes it for ⁴He; what survives is a restricted, untested claim (DS-QF′) |
| Use it to support the vortex-core pivot (`docs/THOUGHT_EXPERIMENT_VORTEX_CORE.md`) | Partly: it supports that the `R + α'/R` structure is a real feature of a *microscopic, weakly interacting* system, which is consistent with a defect-core reading. It says nothing about gravity, about `τ = ω`, or about dark energy |
| Count its 51 theorems in this repository's totals | **No.** LeanMaster's counts are its own libraries only (702 audited theorems, `docs/VERIFIED_FOUNDATION.md`) |

## 4. To make it citable here (one step)

Give this repository a reachable path or a clone URL plus a commit hash; then a session can run the same five gates
against it (build, `sorry` grep, axiom audit, statement lock, producer ≠ verifier), record the outputs in this file,
and only then may `docs/` cite it as Tier L. Until then, every LeanMaster document that mentions it must say
"reported, not verified here" — as `docs/THOUGHT_EXPERIMENT_VORTEX_CORE.md` §3.4 already does.

## 5. Two questions the report raises for this repository

1. **`ℓ_B ≥ 2/k*` with equality iff `k = k*`** is the same shape as `dualScale_ge` + `dualScale_eq_iff`
   (`tr G + tr G⁻¹ ≥ 2d`, equality iff `G = 1`). If both are instances of one statement about a positive quantity
   and its inverse, that common lemma is worth stating once, in the `DualScaleStream2` core, with the two
   applications as corollaries. This would be a genuine unification and is cheap (Tier A, AM–GM).
2. **The report's `ℓ/(√2 ξ)` ratio is a dimensionless "distance from self-duality".** The analogue here is
   `𝒟(G)/2d ≥ 1`. Whether that ratio has any use in the gravity setting is exactly the open question of the
   vortex-core pivot (target V3 there): it needs a dynamics, not just a functional.
