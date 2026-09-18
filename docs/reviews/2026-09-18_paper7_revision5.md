# Paper 7 — Revision 5 (2026-09-18): what changed and why

**File:** `papers/publication/paper7_dual_scale_theory_master_demonstration.tex` (+ PDF, 29 pages; Revision 4
had 26). Built with `pdflatex` twice: 0 undefined references, 0 overfull boxes.

**Why.** After Revision 4, three later streams of the repository tested this paper's own claims, and all
three outcomes go against its physical proposal. Revision 5 reports them in the paper itself rather than
leaving them in `docs/`. No Lean statement cited in Revisions 1–4 changes.

## Changes

1. **Twining (forger's) test on the 27720 lock** (new paragraph in §6, label `sec:twining-verdict`).
   The ratio form of Theorem 6.1, recomputed from the `M₂₄`-twined series of `DualScaleMoonshine`, holds at
   the identity (`ForgerTest.lock_at_identity`) and fails at all 25 non-identity classes
   (`ForgerTest.ratio_fails_at_2A/3A/5A/7AB`, `CharactersAll.ratio_fails_at_every_class`); e.g. at `2A`,
   `𝒜₂/𝒜₁ = 14/(−6)`, not `462/90`. The theorem is kept as an arithmetic identity (Tier A); every
   structural or physical reading of the "lock" is withdrawn, and the phenomenological relations built on
   27720 and 77/360 inherit that status. Contrast recorded: `χ(K3) = 24` passes the twining test
   (`Shadow.shadow_coeff_eq_perm_trace`); module-structure relations survive
   (`CharactersAll.trace_eq_twined_coeff_all`, `Decompositions.moonshine_modules_decompose`).
2. **CKN test of the literal hypothesis** (new §8 subsection `sec:ckn-verdict`): fails by `≥ 10³⁰`
   (`CKNInstance.planckEnergy_gt_ckn_horizon_cutoff`); the Regge reading of the self-dual length is excluded
   by `≥ 10³⁰` (`CosmicString.selfDual_alphaPrime_exceeds_cms_ceiling`).
3. **Stream 6 pre-registered verdict** (new §8 subsection `sec:stream6-verdict`): P1 (`R = s ≈ 47 μm`, one
   extra dimension, `m ~ 1/R`), frozen in `docs/STREAM6_PREDICTION_P1.md`, tag `stream6-p1-frozen`,
   disclosed as a retrodiction. Excluded: Eöt-Wash 2020 radius `< 30 μm` (`2002_11761.txt` l. 289) and
   Yukawa `λ < 38.6 μm` (l. 285); MVV neutron stars `< 44 μm` (`2205_12293.txt` ll. 320–327)
   (`Stream6Verdict.p1_fails_T1/T2/T3`, `p1_verdict_excluded`). No `O(1)` rescue: `κ = 1` from the unique
   self-dual fixed point (`p62_selfdual_fixed_point`); two large `T²` dimensions fail MVV's `1.6 × 10⁻⁴ μm`
   (l. 329) by `> 10⁵` (`p62_two_dims_excluded`).
4. **Abstract, Conjecture 7.1 (new status Remark 7.2), Table 2 (two new rows), claim ledger (four new
   rows), conclusion** now state plainly that the zero-free-parameter cosmological conjecture, in its
   testable form, does not survive existing data, while the formal mathematics remains Tier A.
5. **Counts** at this revision: 611 audited theorems across ten libraries, 0 failing, release `v3.14.0`.
   Four bibliography entries added (CDH 1204.2779, CKN hep-th/9803132, Lee et al. 2002.11761, MVV
   2205.12293).

**Title kept unchanged** so the paper stays citable under its deposited name; the revision log says the
title names the conjecture examined, not a result. A Zenodo new version is the owner's decision.
