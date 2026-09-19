# What LeanMaster can and cannot hand the CMB "cosmic crystallography" search (2026-09-19)

The data repository (LeanFlow) is reorienting its TDA pipeline away from generic cosmic strings towards a search
for **discrete residual anisotropy** imitating the symmetries of the `D₄` lattice, the `τ = ω` Kummer surface and
its group `T₁₉₂`. This file is the LeanMaster side of that hand-off: the verified facts that can be used, in the
exact form in which they are verified, and — more importantly — what they do **not** license.

## 0. Read this first: there is no derivation from these symmetries to a CMB observable

Nothing in Stream 8 predicts a CMB signal. The chain "UV crystallisation at `τ = ω` → fossil imprint in the CMB"
has **no step formalized and no step pinned to the literature**. Stream 7 already inventoried what the programme
can and cannot derive without a constructed compactification, and Stream 6–7's verdicts were negative. A search
built on this file is a **template for a null test**, not a prediction: it can only report "no discrete anisotropy
of this type at this sensitivity", or find something that then needs an independent explanation.

Two further cautions about claims circulating in the directives:

* *"The `SO(44)` attractor destroyed the cosmic strings."* No such result exists. What is proved
  (`K3Enhancement.product_points_not_maximal`) is that a factorised `K3 × T²` point carries at most 766 roots
  against 924 at the global maximum: trapping does not select a factorised point. That says nothing about defect
  formation, smoothing, or string networks.
* *Label collision between repositories.* In **this** repository, **P1 is the ≈ 47 μm extra dimension and it is
  excluded** (Eöt-Wash < 30 μm; `docs/STREAM6_PREDICTION_P1.md`, tag `stream6-p1-frozen`). The LeanFlow directive
  calls that same prediction **P2**, and uses **P1** for a dark-energy fit. Before any addendum is written, fix one
  numbering or write both ("LeanMaster P1 = LeanFlow P2 = the 47 μm dimension, excluded").

## 1. The verified objects a search could target (Tier A)

All of these are kernel-checked in `DualScaleDyons`; the file and theorem are given so a claim can be traced.

| Object | Content | Where |
|---|---|---|
| `D₄` lattice (Hurwitz order) | 24 units; the unique rank-4 maximum of the simply-laced root systems (24 roots) | `KummerD4.hurwitz_units`, `trapping_rank_table` |
| The `ω` axis | `ω = (−1+i+j+k)/2` is an order-3 lattice symmetry commuting with `u = (i+j+k)/√3` | `KummerD4.omega_symmetry` |
| Transcendental lattices | `T(A) = A₂` for the `ω` structure (Kummer `D = 12`); `diag(2,2)` for `i` (`D = 16`) | `KummerD4.transcendental_omega`, `GTVWPoint.gtvw_complex_structures` (pending) |
| `T₁₉₂ = (ℤ₂)⁴ ⋊ A₄` | 192 elements acting on `H²(Km, ℚ)`; classes `1A, 2A, 3A, 4B` with multiplicities 1, 27, 128, 36; fixed points 24, 8, 6, 4 | `KummerOmegaE4.kummer_group_frames` |
| The 16 nodes | `𝔽₂⁴`, with the `8 + 16` split of the 24 being a Golay octad split | `KummerE3.octad_is_kummer` |
| The overarching group | `(ℤ₂)⁴ ⋊ A₇`, order 40320, 5760 elements of order 14 that no single K3 realises | `ForgerE4.order14_not_geometric` |
| Self-dual radius | the `T²` rest point `(ω, ω)` has 6 + 6 massless gauge bosons (6 in the heterotic frame) | `SelfDualT2.roots_ww` |

**What a "signature" would have to be.** Each of these lives on a lattice or on `H²` of a K3 — not on the sky. To
become an observable, a search needs a stated map from one of them to an angular pattern. Candidates, all Tier C
and all unproved:

1. a **point group** acting on a spatial slice: the relevant finite rotation groups are `W(F₄)` (order 1152, the
   automorphism group of `D₄`) and the tetrahedral group `A₄` inside it — i.e. a tetrahedral/cubic pattern, not a
   generic multipole;
2. an **order-3 axis** (the `ω` direction), which in a slice would give a 3-fold discrete anisotropy;
3. a **16-point structure** (`𝔽₂⁴`, the Kummer nodes) — the natural home of a 16-fold discrete correlation.

A search should fix **one** of these, in advance, with its angular scale, before touching the data.

## 2. Protocol the search must follow to be worth anything

This mirrors the pre-registration discipline of Streams 6–7 (`docs/STREAM6_EXPERIMENT_PLAN.md`), which is what
made their negative verdicts credible:

1. **Freeze first.** Write the statistic, the sky cuts, the multipole range, the null hypothesis, and the decision
   rule in the pre-registration file, and tag the repository, **before** running on real data.
2. **Null control before signal.** The lognormal/CAMB mocks are the null distribution; the p-value has to come
   from them, not from an analytic formula. The TDA bugs the directive lists (dead bins counted in the degrees of
   freedom, the `1e-8` ridge, the hollow-tetrahedron `b₂` of the sphere being 49147 instead of 1) must be fixed and
   the fixed pipeline must reproduce the known topology of test cases *before* any cosmological run.
3. **Look-elsewhere.** Any scan over axes, scales or group elements costs trials; state the number of effective
   trials in the freeze.
4. **Report the null result as the result.** Given §0, the expected outcome is a bound. That is publishable and
   honest; a "detection" found after scanning would need independent replication before it is called anything.

## 3. What LeanMaster will supply on request

Concretely, and as kernel-checked artifacts rather than prose:

* the explicit `D₄` root list and the `W(F₄)` action (from `KummerD4`);
* the 192 elements of `T₁₉₂` as permutations of the 16 nodes plus their action on `H²` (from `KummerOmegaE4`);
* the fixed-point counts per class (24, 8, 6, 4), which fix how many invariant directions a given element leaves;
* the `𝔽₂⁴` ↔ Golay-octad dictionary (from `KummerE3`), if a 16-point pattern is the chosen target.

Ask through the MCP server (`search_theorems`, `get_declaration`) so that every number used downstream carries its
theorem name and its gate status.
