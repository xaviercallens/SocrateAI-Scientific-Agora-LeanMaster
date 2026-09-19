# Thought experiment: the self-dual scale as a vortex core, not a macroscopic dimension (2026-09-19)

**Proposal received.** In a superfluid, a vortex cannot have a singular core: quantum mechanics hollows it over the
healing length `ξ`. Transposed: the self-dual length is not a large extra dimension (Streams 6–7's P1, excluded) but
the **core size of the primordial topological defects**, where the dual-scale bound acts as the healing length and
the classical singularity is replaced by a core crystallised on the `τ = ω` K3. Dark energy is then the bulk
viscosity produced when expansion stretches that network of self-dual cores.

This file assesses the proposal against what is actually proved here, so that nothing is built on a misreading.
It contains no new result.

## 1. The dual-scale bound does **not** forbid collapse — and reading it that way inverts it

The directive asks to prove that "when `G(r) → 0` or `∞`, the effective scale of `ℋ` stays bounded below by `2d`,
so geometric collapse is algebraically forbidden locally". The bound (`DualScaleStream2.DualScale.TraceBound`) is:

| Theorem | Statement |
|---|---|
| `dualScale_eq` | `𝒟(G) = tr G + tr G⁻¹` (the trace of the generalized metric at `B = 0`) |
| `dualScale_ge` | `𝒟(G) ≥ 2d` for every positive-definite `G` |
| `dualScale_one` | `𝒟(1) = 2d` |
| `dualScale_eq_iff` | equality **iff** `G = 1` — the self-dual metric is the unique minimiser |
| `dualScale_inv` | `𝒟(G⁻¹) = 𝒟(G)` — invariance under `G ↔ G⁻¹` |

`𝒟` is bounded **below**. In the collapse limit one eigenvalue `λ → 0`, so `tr G⁻¹ → ∞` and `𝒟 → ∞`: the bound is
satisfied trivially and **obstructs nothing**. A singular metric is not excluded by `𝒟 ≥ 2d`; it is the *maximiser*
side of the functional, not the forbidden side. Proving "`𝒟 ≥ 2d` in the collapse limit" would be proving a fact
that is true *because* the geometry degenerates.

**What the theorems do support.** `𝒟` is a T-duality-invariant functional on torus metrics whose unique minimum is
the self-dual metric. So:

> *If* the local dynamics at a defect core minimises `𝒟` — or any monotone function of it — *then* the core is
> driven to `G = 1`, the self-dual point.

That is a **variational** statement requiring a physical postulate (that `𝒟` is, or tracks, an energy). The
postulate is exactly what is missing; it is not supplied by the algebra, and it is where the physics of the
analogy lives. Stated that way the proposal is respectable and formalizable; stated as "collapse is algebraically
forbidden" it is false.

## 2. What the analogy gets right

* **A fixed point is the natural core size.** `R ↔ α'/R` has the single fixed point `R = √α'`, and `𝒟`'s unique
  minimiser is the self-dual metric (`dualScale_eq_iff`). A radial profile that would run from large `R` down to
  `0` must pass through `√α'`. A healing length needs exactly such a fixed point — the analogy is structurally
  sound, unlike the earlier use of the same length as a macroscopic radius.
* **Locality is the right correction.** Streams 6–7 applied the duality to the global scale factor and were refuted
  by laboratory bounds (`docs/STREAM6_PREDICTION_P1.md`, Eöt-Wash `< 30 μm`). Restricting the duality to defect
  cores removes the conflict, because nothing in the laboratory probes that regime.
* **String theory already expects small cores to be stringy.** Winding modes becoming light at small radius is
  standard; a core of order `√α'` is the conventional expectation, not an exotic claim.

## 3. What the pivot costs, and what it must supply

1. **It abandons the identification that made the programme quantitative.** Streams 3, 6 and 7 rested on
   `α' = ℓ_P c/H₀` (hence `√α' ≈ 47 μm`). If `√α'` is now a defect core at the string scale, that identification
   is dropped, and with it the programme's only number. `α'` becomes a free parameter again: the "zero free
   parameter" claim weakens, it does not strengthen. This must be written down, not glossed.
2. **The `τ = ω` core needs a mechanism.** §14 found that the maximal-symmetry K3 model (GTVW) prefers the `i`
   structure, and §10 found that symplectic symmetry does not distinguish `i` from `ω`. `ω` is currently selected
   only by the *smallest black hole's attractor* (§11). Saying defect cores are "crystallised on `τ = ω`" is that
   same attractor statement, and it applies to a black hole with `D = −3` charges — not to a generic defect.
   Which defects carry those charges is unaddressed.
3. **Dark energy as bulk viscosity has to produce `w(z)`, not a slogan.** Viscous cosmology is standard: a bulk
   viscosity `ζ` shifts the pressure by `−3ζH`, so `w_eff = −1` requires `3ζH = ρ + p` — i.e. `ζ ∝ (ρ+p)/H`, a
   tuned relation, not a consequence of having a defect network. Frozen networks have their own scalings
   (`w = −1/3` for strings, `−2/3` for walls); neither is `−1`. And viscous dark energy produces entropy, which is
   constrained. Until a `ζ` is derived from the core physics, "dark energy is topological friction" is a Tier C
   analogy with no decision rule.
4. **The quantum-fluid corpus is recorded but not verified here.** The report is in
   `docs/reviews/2026-09-19_quantumfluids_dual_scale_report.md` (verbatim). Its source path
   (`/home/xavkal/xdev/SocrateAI-Scientific-QuantumFluids`) does not exist on this VM, so no gate was run against
   it. Two things in it change how this pivot should be argued:
   * the `R + α'/R` shape is an **identity** for the Bogoliubov dispersion (`R = 1/k`, `α' = 1/k*²`), not an
     analogy — that is real support for the algebraic structure;
   * but the measurement **refutes** the hypothesis for ⁴He (the roton sits 21–51× below the envelope). What
     survives is the restricted claim that the structure belongs to the *weakly interacting* regime, and the
     report states that this is **untested**.
   So "validated by fluid physics" overstates it; "the shape is exact in a weakly interacting microscopic system,
   and fails in a strongly correlated one" is what was shown. Citing it as Tier L needs `repo@commit` plus gate
   outputs.

## 4. Formalizable targets, if the pivot is pursued (all Tier A, none yet written)

| # | Statement | Cost |
|---|---|---|
| V1 | `𝒟` restricted to a one-parameter radial profile `G(r) = diag(f(r), …)` attains its minimum exactly where `f = 1`; with `f` continuous, monotone, `f(r₀) > 1 > f(r₁)`, there is a unique self-dual radius between them | small; intermediate value + `dualScale_eq_iff` |
| V2 | The "core" statement without the false claim: for every positive-definite `G`, `𝒟(G) ≥ 2d` **with equality iff `G = 1`**, so any dynamics decreasing `𝒟` has the self-dual metric as its only fixed point | already proved (`dualScale_eq_iff`); what is new is the docstring that stops calling it an obstruction |
| V3 | Viscous-cosmology arithmetic: given `p_eff = p − 3ζH`, the exact condition on `ζ` for `w_eff = −1`, and the scaling `ρ ∝ a^{-n}` of a frozen network for `n = 1, 2, 3` | small, finite algebra; makes the dark-energy claim falsifiable |
| V4 | Which charges a defect must carry for its attractor to be `D = −3` (i.e. `τ = ω`), from `AttractorCharges.every_form_is_charged` | moderate |

**Order.** V2 (a docstring correction) and V3 (the decision rule) first: V3 is what turns the proposal into
something that can be pre-registered and tested, which is the only way it becomes more than an analogy. V1 and V4
are the geometry.

## 5. Protocol

If V3 yields a `w(z)`, it is a prediction and falls under the programme's own pre-registration discipline
(`docs/STREAM6_EXPERIMENT_PLAN.md`): freeze the statement and the decision rule by git tag, disclose what was
already known about the data, then compare. Streams 6–7 are negative results that are *credible* because they were
frozen first; a positive result obtained after looking at DESI would carry none of that weight.
