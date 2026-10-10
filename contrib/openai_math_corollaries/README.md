# openai/math corollaries and certified numerics (external contribution, separate toolchain)

Lean 4 work produced in the AutoevolveAI repository (branch `worktree-openai-math-discovery`) on top of the
[openai/math](https://github.com/openai/math) release. It is **not** part of LeanMaster's library build:

* toolchain **Lean 4.34.1** with Mathlib `d13f23b7` and upstream openai/math commit `adc7f124` (the files used are
  unchanged at `fd4aeeb2`), not LeanMaster's `v4.34.0-rc2`;
* not covered by LeanMaster's five gates (`lake build`, `sorry` grep, `tools/axiom_audit.py`,
  `tools/statement_lock.py --check`, producer ≠ verifier). Its own gates are listed below and in `audit/`.

Nothing here should be cited as LeanMaster Tier A. The labels below are descriptive: "kernel-checked" means compiled by
the Lean kernel with `#print axioms` ⊆ {`propext`, `Classical.choice`, `Quot.sound`}.

## 1. Triangular lattice: corollaries of upstream's universal-optimality theorem

`lean/Triangular/`. **Everything is conditional on upstream `OAI.AtomicTriangular.universal_energy_minimum`**, an
AI-generated proof that we found Comparator-accepted under the pinned toolchain. It has not been peer reviewed, and by
its authors' account it does not claim the per-potential (sharp auxiliary function) form of the Cohn–Kumar
conjecture. Paper: doi:[10.5281/zenodo.23285631](https://doi.org/10.5281/zenodo.23285631).

| Name | Statement (informal) |
|---|---|
| `TriangularRiesz.riesz_admissible`, `triangular_riesz_optimal` (D1) | for s > 0, t ↦ t^{-s/2} is completely monotone, so the triangular lattice minimises the Riesz s-energy among locally finite density-1 configurations (informative for s > 2) |
| `TriangularRiesz.latticeEnergy_riesz_lt_top` (D1b) | for s > 2 the lattice Riesz energy (Epstein zeta) is finite |
| `TriangularDensity.universal_any_density`, `triangular_optimal_any_density`, `attained` (D2) | for every ρ > 0 and admissible g, ρ^{-1/2}A has density ρ and minimises the g-energy among locally finite density-ρ configurations |
| `TriangularDensity.unscaled_false` | negative control: without the rescaling the D2 statement is false (ρ = 1/4, s = 4) |
| `TriangularControls.*` | Riesz kernel identity, t ↦ t not admissible, ρ = 1 reduction, kernel-checked homogeneity ρ^{s/2} Σ\|a\|^{-s} ≤ E(C) |

Audit: `audit/triangular/` (statement-fidelity audit against CKMRV 2022 Defs 1.1–1.3, two independent verification
reports, preregistrations, numerics scripts, axiom-audit output). `lean/Triangular/Axioms.lean` contains two planted
controls (`ctl_sorry`, `ctl_axiom`) on purpose; the audit flags both.

## 2. Certified numerics: DESI DR2 BAO and the Hubble tension

`lean/BAOCert/`. Self-contained (Mathlib only). Rational interval arithmetic with a soundness theorem, integer
certificates closed by `decide +kernel`, no `native_decide`.

* **P1** kernel-checked enclosures of flat-ΛCDM BAO distances against DESI DR2; doi:[10.5281/zenodo.23247730](https://doi.org/10.5281/zenodo.23247730).
* **P2** the BAO χ² exceeds 35.2897 for every Ω_m ∈ [0, 0.255] ∪ [0.35, 1] and every h·r_d, while it is ≤ 10.2897 at
  a point (Δχ² > 25). Status P2_PARTIAL: the preregistered slab layout excluded 8 of 19 slabs; the stated bands use a
  disclosed post-hoc bisection. Einstein–de Sitter: χ² ≥ 1415.82.
* **P3** `H0_ge_73_excluded`: with the BBN prior ω_b = 0.02218 ± 0.00055 and the Aubourg r_d fit, the combined χ²
  exceeds 10.2897 + 25 for every Ω_m ∈ [0, 1], every ω_b and every h ≥ 0.73. P2 + P3 paper:
  doi:[10.5281/zenodo.23284020](https://doi.org/10.5281/zenodo.23284020).

These are certified versions of numerically known results; no new physics. Audit: `audit/certified_numerics/`.

## Provenance

Lean proofs, audits and drafting were produced by AI agents (Claude) under the author's direction; verification runs
were separate instances of the same model (producer ≠ verifier), not human review. `MANIFEST.json` lists the sha256
of every file. Reproduction: `REPRODUCE.md`.
