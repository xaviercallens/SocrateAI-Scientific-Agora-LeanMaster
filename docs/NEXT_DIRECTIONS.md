# Next directions after Stream 8 (2026-09-19)

Two directives arrived for this repository and for the data/phenomenology repository. This file records what is
**already done here**, what is **mis-specified and must be restated before it can be formalized**, and what the
**workflows in `.claude/workflows/`** actually run. Nothing below is a result; results live in
`docs/VERIFIED_FOUNDATION.md` and `docs/STREAM8_WHICH_K3.md`.

## 1. Already done in LeanMaster (do not duplicate)

| Directive item | Status here |
|---|---|
| "Create `MinimalBlackHole.lean`: charges `p² = q² = 2`, `p·q = 1`, Moore discriminant `D = −3`, attractor root `τ = ω` in the upper half plane, docstring pointing at `X₃ × E_ω`, `T(A) = A₂`" | **Done** in `DualScaleDyons/AttractorCharges.lean` (v3.25.0): `smallest_black_hole` (`D = −3`, `T_S = A₂`), `attractor_tau` (the root of Moore (4.5) with `Im τ > 0`, for every `D < 0`), `tau_minimal` (`τ = (1+i√3)/2 = ω + 1 ≅ ω`; `D = −4` gives `i`), plus `every_form_is_charged`, `discriminant_gap`, `smallest_black_hole_index`. §11 of `docs/STREAM8_WHICH_K3.md` is the write-up. A second file would duplicate locked statements. |
| "Push tags `v3.24.0`, `v3.25.0`" | **Done** (and `v3.26.0`, `v3.27.0`, `v3.28.0`; releases published). |
| "`audit/k3t2_rigidity_v2/REPORT.md`", branch `loop/k3t2-rigidity`, `.claude/workflows/k3t2-rigidity-loop-v3.js` (`6e09699`) | **Not in this repository** — no `audit/`, no such branch, no such workflow. They belong to the sibling (data/phenomenology) repository or to another working copy. |
| TDA / DESI / Eöt-Wash verdicts, `PRE_REGISTRATION.md` addendum, `reverse-to-zero` report, TDA Mapper lens, `loop/tda-simple` bug fixes | **Other repository (LeanFlow).** LeanMaster holds no data pipeline. What LeanMaster can hand that search, and what it must not be used to claim, is `docs/CMB_CRYSTALLOGRAPHY_SPEC.md`. **Label collision:** here P1 is the ≈ 47 μm extra dimension and it is *excluded*; the LeanFlow directive calls that P2 and uses P1 for a dark-energy fit. Fix one numbering before writing any addendum. |

## 2. Mis-specified as given — restate before formalizing

**"No-go: the `SO(44)` root lattice admits no orthogonal decomposition preserving the signature split
`(3,19) ⊕ (2,2)` while keeping `T(A) = A₂`", with the proof left as `sorry`.**

Two problems.

1. **The repository forbids `sorry`.** The invariant is zero `sorry` / `admit` / `native_decide` across every built
   library (`CLAUDE.md`, gate G2). A `sorry` would break the build gate and the axiom audit. A statement that is
   not yet proved goes in a document or in a file outside the `lean_lib` roots, never into the library.
2. **The contract as phrased is not what §12 establishes, and is probably false as stated.** `Γ₆,₂₂` *does* contain
   `Γ₄,₂₀ ⊕ Γ₂,₂`, and `D₂₂` does embed in `Γ₆,₂₂`; what was proved (`K3Enhancement.product_points_not_maximal`) is
   that a positive 6-plane that splits along `Γ₄,₂₀ ⊕ Γ₂,₂` carries **at most `760 + 6 = 766` roots, fewer than the
   924 of the global maximum**. That is a statement about which point trapping selects, not about a lattice
   decomposition being impossible.

**Well-posed successors** (either is formalizable; the first is already half-done):

* *(A, arithmetic)* For every positive 6-plane `Π = Π₄ ⊕ Π₂` split along `Γ₄,₂₀ ⊕ Γ₂,₂`, the root count is
  `≤ 766 < 924`; and if in addition the `T²` factor sits at `(ω, ω)` its contribution is exactly 6. Half of this is
  `product_points_not_maximal`; the rest is the same DP table plus the `SelfDualT2` root count.
* *(B, harder)* No positive 6-plane whose orthogonal complement has 924 roots contains a rank-2 sublattice
  isometric to `A₂` **primitively with the right signature split**. Note `D₆ ⊃ A₂` primitively, so the honest
  version must quantify over the *split*, not merely over `A₂ ⊂ Π`. **Drafted**:
  `DualScaleDyons/TrappingObstruction.lean` proves the positive half — both smallest-black-hole charge lattices
  (`A₂`, `D = −3`, and `A₁ ⊕ A₁`, `D = −4`) embed primitively in the `SO(44)` plane lattice `D₆` — so the proposed
  no-go is false as phrased, and restates the true content (`766 < 924`). Not yet compiled (the machine is busy
  with the toolchain migration).

Until one of them is proved, the "frustration" between the IR trapping point and the UV attractor stays Tier C and
lives in §12 and §14 of `docs/STREAM8_WHICH_K3.md`.

## 3. Genuinely new directions

| # | Direction | Why | First step |
|---|---|---|---|
| D1 | **Orientifold `T⁶/Γ` (Stream 9)** | `K3 × T²` is `N = 4` and non-chiral (Stream 7). Orientifolds of `T⁶` keep the arithmetic certifiable while allowing `N = 1`. | `Γ₆,₆` Narain lattice + the involutions; tadpole budget as integer arithmetic. |
| D2 | **Tadpole uniqueness** | v3.21.0 corrected the `T²/ℤ₂` orientifold budget after a peer note. Uniqueness of `16 × (+1) + 4 × (−4) = 0` under the geometric constraints is finite arithmetic. | Extend `StringTheoryFoundation/StringTheory/TadpoleCancellation.lean`. |
| D3 | **Stream 8 closure** | §14 (GTVW) is the last open piece; then Stream 8 is complete and can be written up. | Compile `GTVWPoint.lean`, gates, release. |
| D4 | **`M₂₄` realization of `T₁₉₂` at `D = 12`** | §10 left it open: the group is abstractly `T₁₉₂`, but its embedding through TW's map `Θ` is unverified. | Follow TW §3–4 with the octad census tooling. |
| D4b | **Hand-off to the CMB search** | LeanFlow is reorienting its TDA to discrete `D₄`/`T₁₉₂` anisotropy. | `docs/CMB_CRYSTALLOGRAPHY_SPEC.md`: the verified objects, the missing derivation, and the freeze-first protocol. |
| D5 | **Migrate the other projects to `v4.34.0-rc2`** | Cross-project integration (user's request). LeanMaster's own migration is on `toolchain/v4.34.0-rc2`. | After the LeanMaster merge: same four steps per project, one module at a time. |

## 4. Workflows

`.claude/workflows/` holds one script per direction. They are **plans with gates**, not proofs: every one of them
ends in the five gates (build, `sorry` grep, `tools/axiom_audit.py`, `tools/statement_lock.py --check`,
producer ≠ verifier) and reports honestly if a step fails.

| Workflow | What it does |
|---|---|
| `stream9-orientifold-t6.js` | D1: `Γ₆,₆` + involutions, one module at a time under the memory guard. |
| `tadpole-uniqueness.js` | D2: enumerate integer solutions of the tadpole budget, prove uniqueness, lock. |
| `stream8-closure.js` | D3: compile and gate `GTVWPoint.lean`, update `VERIFIED_FOUNDATION.md`, release. |
| `toolchain-migrate-project.js` | D5: migrate one Lake project to a target toolchain, with the memory-guarded build. |

Running them costs many agent-hours of compute; start them explicitly, one at a time, and never two Lean builds at
once on this VM (LL.md §S8.2: a second build halves the page cache and both crawl at 2–6 MB/s).
