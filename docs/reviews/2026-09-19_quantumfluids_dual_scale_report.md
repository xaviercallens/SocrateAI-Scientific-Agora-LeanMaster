# Received report — dual scale in quantum fluids (2026-09-19)

**Source:** https://github.com/xaviercallens/SocrateAI-Scientific-QuantumFluids at commit
`11a39a80caabf4b5774758744e5125a29a4cb0c4`, consolidated in that repository's `docs/DUAL_SCALE_PROPOSAL.md`.
The local path first given (`/home/xavkal/xdev/...`) does not exist on this VM; the clone does.
**Verified here on 2026-09-20 — see §1b**, which is what promotes the parts LeanMaster relies on from Tier X
(another repository's claim) to Tier L (pinned literature/artefact). The report itself is recorded verbatim in
§1, as `docs/reviews/` requires. Recording is not endorsement; §2–§3 say what may and may not be claimed.

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

## 1b. Independent verification in this repository (2026-09-20)

Clone at `/mnt/disks/disk-socrateai-local-1/leanmaster/SocrateAI-Scientific-QuantumFluids`, commit `11a39a8`.

| Gate | Result |
|---|---|
| Toolchain | `leanprover/lean4:v4.34.0-rc2` — **identical to LeanMaster's** after our migration |
| Mathlib pin | `85e3a25e006c35636f0e53b0e9296caca2685bc0` (tag v4.34.0-rc2) — **the same revision LeanMaster uses** |
| Build | `lake build` (their seven default targets): **8776 jobs, 0 errors**, `exit=0` |
| `sorry` / `admit` / `native_decide` | **0 in every default-target module** (`DualLength`, `Duality`, `ShellHamiltonian`, `QuantumFluidsShell`, `MadelungSplit`, `GPGalerkin`, `RipsFloor`). The 65 hits in the tree are all in `ComparatorChallenges/`, which their `lakefile.lean` marks as *not* a default target, with the comment that those statements "contain `sorry` by design and must never count as built theorems" |
| Axioms | Probe with `#print axioms` over every theorem of the seven modules: **67 of 68 reported, all with only `propext`, `Classical.choice`, `Quot.sound`; no `sorryAx`**. The 68th (`hasDerivAt_line`) is `private`, so my generated probe could not name it — a limitation of the probe, not of their file |
| Theorem count | `DualLength.lean` has **13** theorems, not the 12 the report states; the other six modules give 11, 9, 12, 6, 13, 4, so 68 in total across default targets |

**Conclusion of the check.** The Lean side of the report holds up: it builds under our own toolchain, contains no
`sorry` in anything it counts, and depends on nothing beyond the three standard axioms. The one numerical
discrepancy (12 vs 13 theorems in `DualLength`) is in the report's favour to correct, not to keep.

**Two findings to send back.**

1. **A committed `.lake` symlink breaks the clone.** `lean_src/.lake` is a symlink to
   `/media/xavkal/3ada43de-.../qf-lake`, i.e. to the author's other machine; on any other machine `lake` stops
   with "already exists (error code: 17)". `.lake` belongs in `.gitignore`.
2. **Their own file already refuses the reading the directives put on it.** `DualLength.lean`'s header says, in
   its "NOT claimed" section: *"anything about string theory or T-duality (the shape is AM-GM on two positive
   terms)"*. So the repository that proves the result explicitly declines to call it evidence for T-duality. Any
   LeanMaster document that cites it must respect that.

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
| Cite "the `R + α'/R` shape is an identity for Bogoliubov, kernel-checked elsewhere" as **Tier L**, with `repo@commit` and the theorem name | **Yes**, as `SocrateAI-Scientific-QuantumFluids@11a39a8`, `QuantumFluids.DualLength.dualLength_bogoliubov` (verified §1b) |
| Say "the dual-scale principle is validated by fluid physics" | **No.** The measurement refutes it for ⁴He; what survives is a restricted, untested claim (DS-QF′) |
| Use it to support the vortex-core pivot (`docs/THOUGHT_EXPERIMENT_VORTEX_CORE.md`) | Partly, and with their own caveat: the structure is a real feature of a *microscopic, weakly interacting* system, but `DualLength.lean` states that it claims nothing about string theory or T-duality, "the shape is AM-GM on two positive terms". It says nothing about gravity, about `τ = ω`, or about dark energy |
| Count its 51 theorems in this repository's totals | **No.** LeanMaster's counts are its own libraries only (702 audited theorems, `docs/VERIFIED_FOUNDATION.md`) |

## 4. Citable as of 2026-09-20

Done: §1b. Cite as `SocrateAI-Scientific-QuantumFluids@11a39a8` with the theorem name. Two gates of LeanMaster's
five do not transfer: that repository has no statement lock, and the producer ≠ verifier rule was met here only in
the weak sense that this session re-ran the build and the axiom probe without touching the proofs.

## 5. Two questions the report raises for this repository

1. **`ℓ_B ≥ 2/k*` with equality iff `k = k*`** is the same shape as `dualScale_ge` + `dualScale_eq_iff`
   (`tr G + tr G⁻¹ ≥ 2d`, equality iff `G = 1`). If both are instances of one statement about a positive quantity
   and its inverse, that common lemma is worth stating once, in the `DualScaleStream2` core, with the two
   applications as corollaries. This would be a genuine unification and is cheap (Tier A, AM–GM).
2. **The report's `ℓ/(√2 ξ)` ratio is a dimensionless "distance from self-duality".** The analogue here is
   `𝒟(G)/2d ≥ 1`. Whether that ratio has any use in the gravity setting is exactly the open question of the
   vortex-core pivot (target V3 there): it needs a dynamics, not just a functional.

---

## 6. Addendum: release `v1.1.0` (received 2026-09-20)

### 6.1 Verbatim

> Done — README and paper updated, work continued, committed, pushed, released.
>
> https://github.com/xaviercallens/SocrateAI-Scientific-QuantumFluids/releases/tag/v1.1.0
>
> The continuation produced a real result
>
> I implemented the threshold-free fix I'd identified: line identity from cube adjacency — a vortex line enters a grid cube through one face and leaves by another — so there is no parameter for the floor to track. It validated cleanly: 0 ambiguous cubes out of 46,762 pierced. It also found 175 lines where the proximity method found 67, so that method had been merging distinct lines.
>
> The verdict splits, and I reported it split rather than picking the convenient half:
> - The floor supports the hypothesis. F = 0.943 ξ — the minimum separation between distinct vortex lines sits essentially at the healing length — 6.1× the null's 95th percentile. With no threshold in the method, this can't be the artifact that killed the first attempt.
> - The f_< criterion refutes it as written. 0.402 vs 0.381 in the null: indistinguishable. T[…] conditions I fixed in the pre-registration, so prediction T2 is wrong.
>
> Net: partially supported, not established. ξ = 1.5 Δx leaves only a 2× margin over the grid; ξ/Δx ≳ 5 is still needed.
>
> Paper: 10 → 14 pages, compiles clean, all refs resolved
> - Retitled off T-duality, with a provenance paragraph stating plainly that no string-theoretic [content is claimed] and that the earlier framing was withdrawn. What survives is arithmetic on two positive terms — plus the fact that [the shape occurs exactly in] a standard dispersion relation, where it becomes measurable and can therefore be wrong.
> - New section: the Ham[iltonian structure] and the σ-rule.
> - New section: the dual length and its failure in ⁴He (21× → 51×).
> - Status table gains [the in]conclusive TDA run and the demotion of the dual-scale claim from universal to weak-coupling.

*(The message arrived with several lines truncated in transit; the bracketed text is my reconstruction from the
repository, and the repository is authoritative.)*

### 6.2 Verified here (2026-09-20), tag `v1.1.0` = commit `10f74daf1b39d2ac51a785452329fff0003cfc83`

| Gate | Result |
|---|---|
| Build | `lake build`, all seven default targets: **8776 jobs, 0 errors** |
| `sorry` / `admit` / `native_decide` | **0** in every default-target module (again confined to `ComparatorChallenges/`, not a default target) |
| Axioms | `#print axioms` over **all 67** theorems of the seven modules: only `propext`, `Classical.choice`, `Quot.sound`; **no `sorryAx`** |
| Module counts | `DualLength` 13, `Duality` 11, `ShellHamiltonian` 9, `QuantumFluidsShell` 12, `MadelungSplit` 5, `GPGalerkin` 13, `RipsFloor` 4 |
| Provenance paragraph | present in `paper/quantumfluids_tdual.tex` ll. 126–132: "**No string-theoretic content is claimed or used anywhere below**, and an earlier framing of this programme, which leaned on that language, has been withdrawn." |
| Status table | `README.md` l. 36 records the TDA workstream as "**partial, split verdict** — floor `F = 0.943 ξ` at 6.1× the null, but the `f_<` criterion refutes the hypothesis as written" |

The split verdict is reported in their own README, not only in the message — the claim and its refutation travel
together.

### 6.3 What this changes for LeanMaster

1. **The withdrawal is theirs, and it is now in their paper.** Any LeanMaster text that cited "validated by fluid
   physics" would now contradict the source repository. The correct citation remains the narrow one of §3: the
   `R + α'/R` shape is an identity for the Bogoliubov dispersion (`dualLength_bogoliubov`), and the ⁴He
   measurement refutes the hypothesis there.
2. **A measured floor at the healing length is the first empirical datum that bears on the vortex-core pivot.**
   `F = 0.943 ξ` is a *minimum separation between distinct vortex lines*, measured with a threshold-free method,
   at 6.1× the null's 95th percentile. It is evidence that a healing-length floor exists in a real tangle — the
   structural ingredient the pivot borrows. It is **not** evidence that the core is self-dual, and the companion
   criterion (`f_<`) failed against the null, so the authors call the workstream partially supported, not
   established. `docs/THOUGHT_EXPERIMENT_VORTEX_CORE.md` §2 is updated accordingly.
3. **Resolution caveat travels with it.** `ξ = 1.5 Δx` leaves a factor ~2 over the grid; they state `ξ/Δx ≳ 5` is
   needed. Any LeanMaster sentence that leans on the floor must carry that caveat.

