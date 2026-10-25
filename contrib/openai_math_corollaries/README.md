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

## 3. Papers (`papers/`)

Sources and PDFs as published on Zenodo (each directory has `zenodo_doi.txt`):

| Directory | Paper | DOI |
|---|---|---|
| `triangular_riesz/` | Riesz-energy, finiteness and every-density corollaries of the openai/math planar universal-optimality theorem | [10.5281/zenodo.23285631](https://doi.org/10.5281/zenodo.23285631) |
| `certified_desi_h0/` | Kernel-checked constraints from DESI DR2 BAO in Lean 4 (P2 + P3) | [10.5281/zenodo.23284020](https://doi.org/10.5281/zenodo.23284020) |
| `certified_bao/` | Kernel-checked enclosures of DESI DR2 BAO distances (P1) | [10.5281/zenodo.23247730](https://doi.org/10.5281/zenodo.23247730) |
| `lt_matrix_audit/` | Matrix Lieb–Thirring audit: a null result (Tier X), scalar theorem Comparator-accepted | [10.5281/zenodo.23245266](https://doi.org/10.5281/zenodo.23245266) |
| `dyadic_triangular_hilbert/` | Dyadic triangular Hilbert form: lower bound C* ≥ 3 for the absolute sum | [10.5281/zenodo.23232389](https://doi.org/10.5281/zenodo.23232389) |

## 4. Verification of openai/math claims (`verification/openai_math/`)

The full record of the openai/math discovery sub-project (corpus index, preregistrations, controls, results), including
our Comparator runs under the pinned toolchain: `hypotheses/night_2026-10-08/TRI_CMP/` (triangular universal
optimality) and `LT_CMP/` (sharp 1D Lieb–Thirring), both COMPARATOR_ACCEPTS with whitelisted axioms and with planted
positive/negative controls (`LT_CMP/controls/`). Comparator certifies that a solution matches the challenge statement
and uses only allowed axioms; it does not audit whether the statement is the intended mathematics (see
`audit/triangular/statement_fidelity.md` for that audit, done for the triangular theorem only).
Strategy documents: `docs/`.

## 5. Upstream snapshot (`upstream/`)

Unmodified Apache-2.0 copy of the openai/math files these results depend on, at the latest upstream commit
`fd4aeeb2` (2026-10-07). See `upstream/NOTICE.md`. Reference only; build from upstream.

## 6. D3: universal optimality in CKMRV's sense, and non-uniqueness (`lean/Triangular/UniversalOptimality.lean`)

| Name | Statement (informal) |
|---|---|
| `UniversallyOptimal ρ C` | CKMRV Def 1.3 in upstream's notions: density ρ, and minimal lower g-energy among locally finite density-ρ configurations for every admissible g. **Strictly weaker** than CKMRV: their definition also requires the energy of C to exist as a limit. |
| `triangular_universally_optimal` | ρ^{-1/2}A is universally optimal (in this sense) for every ρ > 0 |
| `vacancy_energy`, `vacancy_universally_optimal` | A \ {0} (one vacancy) has the same lower energy for every admissible g, so it is also universally optimal |
| `vacancy_not_isometric_image`, `universal_optimum_not_unique` | A \ {0} is not an isometric image of A: universal optima are not unique up to isometry among all configurations |

This formalises CKMRV's remark after their Theorem 1.4 ("removing a single particle changes neither the density nor
the energy"). It shows that "particles always arrange into a triangular lattice" is false as a statement about all
configurations. Uniqueness among *periodic* configurations, the form CKMRV prove in dimensions 8 and 24, is open in
dimension 2 and not addressed. Upstream's `universal_energy_minimum` has a kernel-checked, axiom-clean proof; what
remains conditional is the fidelity of its definitions. Preregistration, verification report (CONFIRMED_WITH_CORRECTIONS,
corrections applied, including non-degeneracy checks at Riesz s = 4) in `audit/triangular/D3/`.

History, checked against CKMRV's text: universal optimality was proved in dimension 1 before dimensions 8 and 24
(Ventevogel–Nijboer; Cohn–Kumar gave another proof); before CKMRV no universal optimum in dimension > 1 was proved.

## 7. D4: open versus closed disks (`lean/Triangular/OpenDisk.lean`, `OpenDiskAny.lean`)

`energy_eq_openEnergy` and `densityOne_iff_open` show that upstream's liminf energy and density-one condition are
unchanged with open disks, so `universal_energy_minimum_open` holds. The `_any` versions need no local finiteness, and
`ctl_open`/`ctl_closed` show the identity is not definitional. This is Tier A for density one and the lower energy. The
scope is upstream's observables only. The independent verification is in `audit/triangular/D4/`.

## 8. Autoresearch round 2026-10-25 (`lean/Autoresearch/`, `audit/autoresearch_2026-10-25/`, `papers/ar_*/`)

Thirteen hypotheses were preregistered before any attempt, then run as a Karpathy-style keep/discard loop with the
Lean kernel as judge (`audit/autoresearch_2026-10-25/{program.md,preregistration.json,results.tsv,SUMMARY.md}`). Five
of them were developed into Elenchus-tiered preprints, each with a step-by-step human proof, rusty-SUNDIALS numerics
and an independent audit:

| Contribution | Preprint | Lean |
|---|---|---|
| Bilayer dipolar excitons: 2(1/r − 1/√(r²+d²)) completely monotone, triangular optimal at every density | doi:10.5281/zenodo.23646103 | `DipolarExciton*.lean` |
| Planar Yukawa e^{−κr}/r: admissible, optimal at every density, mixtures of screening lengths | doi:10.5281/zenodo.23646105 | `Yukawa*.lean` |
| Rytova–Keldysh (TMD) interaction: a positive Gaussian mixture; Laplace-mixture admissibility in Lean, Struve link Tier C | doi:10.5281/zenodo.23646107 | `KeldyshCM*.lean` |
| σ = 3 dyadic shell model: cutoff-independent enstrophy bound | doi:10.5281/zenodo.23646111 | QuantumFluids env, `audit/.../H7/` |
| Bogoliubov structure factor under the √(k/2k*) envelope | doi:10.5281/zenodo.23646117 | QuantumFluids env, `audit/.../H8/` |

Also included:
- the dyadic triangular Hilbert bound C* ≥ 3 (`DyadicHilbert*.lean`);
- population genetics (`PopGen*.lean`: formalizations of known results);
- tadpole uniqueness (`audit/.../H13/`).

Planted controls live only in `*Controls.lean`. The triangular-lattice corollaries are conditional on upstream's
`universal_energy_minimum`. The H7 and H8 files build in the QuantumFluids v4.34.0-rc2 environment, not the pinned
openai/math one. No human has audited the statements, and the Elenchus ledgers keep their LEDGER_UNAUDITED_TIER_A flags open.

## Provenance

Lean proofs, audits and drafting were produced by AI agents (Claude) under the author's direction; verification runs
were separate instances of the same model (producer ≠ verifier), not human review. `MANIFEST.json` lists the sha256
of every file. Reproduction: `REPRODUCE.md`.
