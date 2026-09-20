# Verified foundation — what other projects and sessions may build on

**Status as of 2026-09-17.** Release tag `v2.1.0` (commit `46af79b`) passed the full gate; the key-theorem
probe below was re-run on the working tree at `0b8215b` + documentation-only edits (statement lock OK).
Toolchain `leanprover/lean4:v4.33.1`, Mathlib tag `v4.33.1` (`0df444a3…`) for that release and every tag up to v3.28.0.
**Toolchain migration (2026-09-19, branch `toolchain/v4.34.0-rc2`):** `leanprover/lean4:v4.34.0-rc2`, Mathlib tag
`v4.34.0-rc2` (`85e3a25e…`); gate results of the migration run are recorded below under "Toolchain migration".

**Re-gated 2026-09-17 after the documentation pass** (40 `.lean` files, docstrings and comments only):
comment-stripped code byte-identical to the gated version for all 40 files; `lake build DualScaleStream2
StringTheoryFormalization` 3708 jobs, 0 errors; axiom audit 99 + 89 theorems, 0 failing; statement lock OK.

**Re-gated 2026-09-18 with Stream 3** (`DualScaleCosmology`, eighth library; release `v3.4.0`): all eight
libraries built together, 3781 jobs, 0 errors; axiom audit re-run on every library (counts below unchanged
for the first seven); `DualScaleCosmology` 31 theorems, 0 failing; its statement lock covers 44 declarations
in 7 files. Total audited: **425 + 31 = 456 theorems**.

**`v3.5.0` (2026-09-18) changes no `.lean` file**: it revises paper 7 (Revision 4, external peer review), a
figure caption in papers 1/7/8, book chapter 38, and `tools/check_book_lean_names.py`. Every gate result above
applies unchanged.

**`v3.6.0` (2026-09-18): one theorem added to `DualScaleStream2`**, `dualScale_eq_iff` (uniqueness of the
dual-scale minimizer), in response to an external review recorded in `docs/reviews/`. Gates re-run on that
tree: eight-library build 3781 jobs, 0 errors; `DualScaleStream2` audit 100 theorems, 0 failing; statement
lock reported exactly one change (`ADDED dualScale_eq_iff`) before it was locked. Total audited: **457**.
Earlier paragraphs above record the counts at their own dates (99 / 425 / 456) and are left as written.

**`v3.7.0` (2026-09-18): ninth library `DualScaleMoonshine` (Stream 4, `docs/STREAM4_WORKFLOW.md`)**,
importing Stream 2. It computes the Mathieu-moonshine coefficients from a closed formula instead of
reading them from a table, twines them, checks them against the `M₂₄` character table, and applies the
twining test to paper 7's "27720 lock", which fails it. Gates: nine-library build 3787 jobs, 0 errors;
`DualScaleMoonshine` 28 theorems, 0 failing (axioms: `propext` only); statement lock 52 declarations in 4
files; no file of the other eight libraries changed. Total audited: **485**.

**`v3.8.0`, `v3.8.1` (2026-09-18): Stream 4 phase P4.3 completed at every conjugacy class.** Two files added to
`DualScaleMoonshine`: `TwiningAll.lean` computes the sixteen remaining twined series of Cheng–Duncan–Harvey's
Table 20 (eta quotients, the newforms `f₁₁, f₁₄, f₁₅, f₂₃,ₐ, f₂₃,ᵦ`, prefactors `2/5, 1/3, 1/4, 1/3, 1/11`)
and proves each equal to the printed column through `q⁹`; `CharactersAll.lean` transcribes the full `M₂₄`
character table over `ℤ[b₇]`, `ℤ[b₁₅]`, `ℤ[b₂₃]`, guards it (centralizer orders from column norms, class
equation, full row orthogonality), and proves that at **all 26 classes** and levels 1–7 the traces on EOT's
representations equal the computed twined coefficients. The forger's test now fails at all 25 non-identity
classes. Gates: nine-library build 3789 jobs, 0 errors; `DualScaleMoonshine` 68 theorems, 0 failing
(axioms: `propext` only); statement lock 153 declarations in 6 files (the pre-update check showed the four
existing files unchanged and only the two new files unlocked); no file of the other eight libraries
changed. Counts are those of `v3.8.1`, which adds `eta_lambda_agree_2B/4A` (CDH's two forms printed both as
`Λ`-combinations and as eta quotients agree through `q⁹`); `v3.8.0` had 66 / 523. Total audited: **525**.

**`v3.9.0` (2026-09-18): Stream 4 phase P4.4 — the arithmetic skeleton of the shadow.** `Shadow.lean`
computes the K3 elliptic genus from theta products (`Z(τ,0) = 24`), and proves that its polar/finite
decomposition `Ψ₁,₁Z = 24·Av⁽²⁾[(y+1)/(y−1)] + H·θ̂₁` (CDH §2.3, cleared of denominators) holds through `q⁹`
with the independently computed `H`, and fails for polar multiplicity `23` or `25`; the shadow theta
series `S₁⁽²⁾` equals `η³`; the twined shadow multiplicities are traces on `1 ⊕ 23`. The shadow property
itself (completion, modularity) remains Tier L. Gates: nine-library build 3790 jobs, 0 errors;
`DualScaleMoonshine` 76 theorems, 0 failing (axioms: `propext` only); statement lock 190 declarations in
7 files (pre-update check: only `Shadow.lean` new). Total audited: **533**.

**`v3.10.0` (2026-09-18): Stream 4 phase P4.6 — Harvey–Murthy–Nazaroglu's DSLST index reproduced; Stream 4
complete.** `HMNBridge.lean`: HMN's closed formula for the BPS index `χ₂^Y` reproduces their printed series;
at `k = 2` it equals `−½η³H`; their umbral relation (4.9) holds for `ℓ = 2, 3, 4, 5, 7, 13` through `q⁶`
with umbral forms built from theta functions; their divisibility observation is proved in both directions
(`rk(Y) ∣` all coefficients iff `rk(Y) ∣ 24`) for all `A`, all `D` and `E₆₇₈`. The link to Stream 2's
`(−2)`-reflections is closed as not available (it needs Niemeier lattices). Gates: nine-library build
3791 jobs, 0 errors; `DualScaleMoonshine` 98 theorems, 0 failing; statement lock 234 declarations in
8 files (pre-update check: only `HMNBridge.lean` new). Total audited: **555**.

**`v3.11.0` (2026-09-18): tenth library `DualScaleDyons` (Stream 5, `docs/STREAM5_WORKFLOW.md`)**, importing
Stream 4. From the K3 elliptic genus computed in Stream 4 it builds the DMVV/Borcherds product for the
quarter-BPS dyon partition function `1/Φ₁₀` on K3 × T² (Dabholkar–Murthy–Zagier) and proves, through the
orders stated: the index-1 Jacobi property of `Z_K3`; an enumerated reachability guard for the truncated
product; Göttsche's `p₂₄(k)` for `k ≤ 5`; DMZ's six printed identities (5.16); the strip expansion (9.55);
that the polar part `p₂₄(m+1)A₂,ₘ` removes the double pole of `ψ_m` (and `p₂₄ ± 1` do not), `m = 1, 2, 3`;
and that the single-centred counting function `∆ψ₁^F` equals `3E₄A − 648H` with `H` the Hurwitz class
numbers, counted independently. Gates: ten-library build 3795 jobs, 0 errors; `DualScaleDyons` 17
theorems, 0 failing (axioms: `propext` only); statement lock 48 declarations in 2 files; no file of the
other nine libraries changed. Total audited: **572**. `v3.11.1` adds `negBinom_exact` (the integer
divisions inside the product are exact; 18 theorems, 50 declarations) and clarifies that the polar-part
theorems discriminate the first-order pole condition. Total audited: **573**.

**`v3.12.0` (2026-09-18): Stream 5 phase P5.6 — immortal dyons at `m = 2, 3`, and the twining test.**
`ImmortalHigher.lean`: DMZ's (9.11) and (9.13) at `m = 2, 3` checked (the finite parts of `ψ₀,₃^opt/A`,
`ψ₀,₄^opt/A` are `−12^{m+1}·H|V_m`); the single-centred counting functions `∆ψ₂^F`, `∆ψ₃^F` from the product
equal `p₂₄(m+1)·(−H|V_m)` plus explicit weak Jacobi forms; without the Hecke correction the `m = 2`
identity fails. `TwinedHilbert.lean`: CDH's Frame shapes cross-checked against the power maps; for
`k ≤ 4` the twined Göttsche numbers `Tr(g | H*(Hilbᵏ K3))` are characters of `M₂₄` (non-negative integer
multiplicities over all 26 irreducibles). Gates: ten-library build 3797 jobs, 0 errors; `DualScaleDyons`
32 theorems, 0 failing (`propext` or none); statement lock 74 declarations in 4 files (pre-update check:
only the two new files). Total audited: **587**.

**`v3.13.0` (2026-09-18): Stream 5 phase P5.7 — `M₂₄`-twisted dyons; Stream 4 levels 8–9 closed.**
`DualScaleDyons/TwistedDyons.lean`: the 26 twisted K3 elliptic genera `Z_g = (χ_g/24)Z − F_g·A` from Stream 4's
data (integral, index 1, `Z_g(τ,0) = χ_g`); Cheng's twisted denominators `1/Φ_g` by the plethystic product
with Newton's identities and CDH's power maps (untwisted case recovered; `z = 0` gives the twined Göttsche
numbers); all coefficients of `G₁^{(g)}, G₂^{(g)}` and of the twisted single-centred counting function at
`m = 1` are virtual characters of `M₂₄` (through `q²`). `DualScaleMoonshine/Decompositions.lean`: for
`n = 0 … 9` the computed twined series decompose with integer multiplicities equal to CDH Table 48 (levels
8, 9 were open in Stream 4); EOT's original level-7 proposal is inconsistent (Cheng). Gates: ten-library
build 3799 jobs, 0 errors; `DualScaleMoonshine` 101 theorems, `DualScaleDyons` 42 theorems, 0 failing;
statement locks: only the two new files added. Total audited: **600**. `v3.13.1` adds `TwistedNotes.lean`
(`c_g(−1) = +2` for all 26 classes, checked; Cheng's printed `−2` at l. 960 is a sign convention or misprint).
Total audited: **602**.

**`v3.14.0` (2026-09-18): Stream 6 — experimental verdict.** `DualScaleCosmology/Stream6Verdict.lean` (9 theorems):
the frozen prediction P1 (`docs/STREAM6_PREDICTION_P1.md`, tag `stream6-p1-frozen`), `R = s = √(ℓ_P c/H₀) ≈ 47 μm`
for one large extra dimension, fails Eöt-Wash 2020's radius (`30 μm`) and Yukawa-range (`38.6 μm`) bounds and
MVV's neutron-star bound (`44 μm`): **excluded** by the pre-registered rule; the programme's T-duality fixes the
`O(1)` factor at `κ = 1`. `DualScaleCosmology` 40 theorems, 0 failing. Total audited: **611**.

**`v3.15.0` (2026-09-18): Stream 7, candidate C-A.** `DualScaleCosmology/Stream7CA.lean` (5 theorems): frozen C-A
(tag `stream7-ca-frozen`) — CKN saturation with infrared length `c/H` and conserved matter give `H² = C/a³` and
`q = 1/2` for every `ε`; Planck 2018 (flat ΛCDM) gives `q₀ < 0`: **excluded** (retrodiction, disclosed).
`DualScaleCosmology` 45 theorems, 0 failing. Total audited: **616**.

**`v3.16.0` (2026-09-18): Stream 7, candidate C-B.** `DualScaleCosmology/Stream7CB.lean` (5 theorems): frozen C-B (tag
`stream7-cb-frozen`, before any sensitivity was pinned) — pre-big-bang relic gravitons with `α' = s²`: `g₁² ≈ 1.2 × 10⁻⁶¹`,
spectrum ending at `≈ 6 × 10⁻⁵ Hz` with peak `Ω ≈ 10⁻⁶⁵`; LISA (`1702_00786.txt` ll. 692–699) cannot reach it: **not
falsifiable in practice**. `DualScaleCosmology` 50 theorems, 0 failing. Total audited: **621**.

**Book name checker — a latent bug found and fixed (2026-09-18).** `tools/check_book_lean_names.py` sends every
name it cannot resolve locally to Lean in one probe file. Lean stops reporting after `maxErrors` (default 100)
errors, so **every name after the 100th error in the probe passed silently**; earlier "0 unknown to Lean"
reports were therefore incomplete for books whose probe exceeded 100 errors. Fix: the probe now runs with
`-DmaxErrors=1000000` and the tool aborts if Lean reports hitting the limit; chapters 39–41 and the Streams 4–5
libraries were added to its scope. After the fix it flagged 51 names; triage found **no name presented as a real
library result that does not exist** (all were exercise/hypothetical names, tactics, options, versions, files,
locals, or real declarations cited by short names); 45 allowlist entries with reasons were added, 7 of them with a
target that the tool verifies with `#check`. Negative controls (a bogus name appended to a chapter) are flagged.

**`v3.18.0` (2026-09-18): book Part IX (ch39–41, 753 pages) and Stream 8 (`docs/STREAM8_WHICH_K3.md`).**
`DualScaleDyons/WhichK3.lean` (5 theorems): attractive (ρ = 20) K3s, dyon charges (Moore) and the immortal index
share the reduced binary forms; `12·N(D) = 12·H(D) + 6·[D = 4f²] + 8·[D = 3f²]` for `D ≤ 400` — the counts differ only
at the self-dual points of the torus; Kummer criterion; the first Kummer attractive K3s (`D = 12, 16`); the Fermat
quartic's form. `DualScaleDyons` 49 theorems, 0 failing. Total audited: **626**.

**`v3.19.0` (2026-09-18): Stream 8 E2.** `DualScaleDyons/SelfDualT2.lean` (7 theorems): exact, complete counts of
massless gauge bosons — circle at the self-dual radius 2, T² at `(i, i)` 4 + 4, T² at `(ω, ω)` 6 + 6 (completeness by a
sum-of-squares bound); the `(ω, ω)` roots span `A₂`, isometric to `T(X₃)` of the most attractive K3. With moduli
trapping (hep-th/0403001, Tier L) this selects `(ω, ω)` for T². `DualScaleDyons` 56 theorems, 0 failing. Total
audited: **633**.

**`v3.20.0` (2026-09-18): Stream 8 E3.** `DualScaleDyons/KummerE3.lean` (7 theorems): the Kummer glue code on `𝔽₂⁴`
(30 affine hyperplanes, rank 5, weights `0/8/16` with multiplicities `1/30/1`, `disc Π = 2⁶`); **every** root of the
Kummer lattice is one of the 32 vectors `±E_a` (`A₁¹⁶`, proof for all integer vectors, not a search); the extended
Golay code built from quadratic residues mod 23 (rank 12, weights `1/759/2576/759/1`); for an explicit octad, the 32
Golay words disjoint from it are, through an explicit bijection of the complement with `𝔽₂⁴`, exactly the Kummer
glue code — the Kummer split `24 = 8 + 16` is the octad split (Taormina–Wendland 1107.3834, Tier L for the lattice
embedding). `DualScaleDyons` 63 theorems, 0 failing. Total audited: **640**.

**`v3.21.0` (2026-09-19): tadpole correction (review correction, documented).** A literature check from the
DualScaleSimulator project (recorded with a per-claim validation in
`docs/reviews/2026-09-18_dualscalesimulator_orientifold_note.md`) was verified against newly pinned sources
(Tripathy–Trivedi hep-th/0301139, Sen hep-th/9605150, Gimon–Polchinski hep-th/9601038). The file
`StringTheoryFoundation/StringTheory/TadpoleCancellation.lean` had put 16 O7-planes at the fixed points of
`T⁴/ℤ₂`, a combination that matches no orientifold, and gave the D3 target as `χ(K3)/24 = 1`. It now states the
`K3 × T²/ℤ₂` configuration (4 O7 at `−4`, 16 D7 at `+1`), Polchinski's table for `3 ≤ p ≤ 9`, and the D3 target
`χ(K3 × K3)/24 = 24 = 4·2 + 16·1`. Removed: `total_O7_charge_is_minus_64`, `total_D7_charge_is_64`,
`d3_tadpole_target_is_one`; the statements of `d7_tadpole_cancellation` and of its re-export
`flux_tadpole_quantization_exact` are unchanged in form, with new values underneath. `KummerTadpole.lean` and
`UseCase3_FrontierTriad.lean` keep their statements (a legitimate ×4 rescaling, ratio `−4`, new `o7_d7_ratio`);
their docstrings no longer cite Gimon–Polchinski (3.12), which is a Chan–Paton projection, not a charge. The three
files are now in the statement lock (they were not before). `StringTheoryFoundation` 63 theorems,
`DualScaleM24Formalization` 62, total audited **648**, 0 failing. Book chapters 25 and 36 and paper 3 (wording
only) updated. `tools/check_book_lean_names.py` had a second latent gap: it accepted names from the stale
dependency dump even after they were removed from the sources; a negative control now shows removed names are
caught.

**`v3.22.0` (2026-09-19): Stream 8 E4, the forger's test for the Kummer symmetries.** `DualScaleDyons/ForgerE4.lean`
(5 theorems). Among the 26 Frame shapes (CDH Table 14), the classes with a fixed point and at least five cycles are
exactly Mukai's `1A, 2A, 3A, 4B, 5A, 6A, 7A, 7B, 8A`, all of order `≤ 8`. On them the twined genus at `z = 0` equals
Nikulin's fixed-point number `24/(n∏(1+1/p))` (Huybrechts Cor. 15.1.5): 8, 6, 4, 4, 2, 3, 2. The four half-period
translations are explicit Golay automorphisms of class `2A`. They fix the octad pointwise and act as `x ↦ x + eᵢ` on
`𝔽₂⁴`. An explicit element of order 14 in the stabilizer of an octad and one of its points (Taormina–Wendland's
`(ℤ₂)⁴⋊A₇`) has only four orbits: by Mukai's theorem it is not a symmetry of any single K3. Group orders (322560,
40320) and the class census come from `tools/e4_octad_census.py`, a computation that is not kernel-checked.
`DualScaleDyons` 68 theorems, 0 failing. Total audited: **653**. `v3.22.1`: `frame_classes_up_to_pairs` (the 26 Frame shapes take 21 values; the coincidences are exactly the five A/B pairs); `M₂₄ = Aut(Golay)` and the conjugacy with TW's group pinned (Huybrechts ll. 14623–14633, TW l. 2500). All ten libraries re-audited: `DualScaleDyons` 69, total **654**, 0 failing.

**`v3.23.0` (2026-09-19): Stream 8 G2, trapping in four dimensions.** `DualScaleDyons/KummerD4.lean` (8 theorems).
- In rank `d ≤ 8`, the largest ADE root system has 2, 6, 12, 24, 40, 72, 126, 240 roots. In rank 4 this is `D₄`
  alone.
- The Hurwitz lattice has 24 units, and `ω = (−1+i+j+k)/2` is an order-3 lattice symmetry commuting with the complex
  structure `u = (i+j+k)/√3`.
- On that torus the holomorphic plane is orthogonal to the Kähler direction inside the round 3-plane `Σ`.
- The integral forms in it are exactly `ℤt₁ ⊕ ℤt₂` (a saturation proof over all integer 2-forms), with Gram
  `[[2,1],[1,2]] = A₂ = T(X₃)`.
- The Kummer surface over it has `A₂(2)`, `D = −12`.
- Sanity check: the same construction with `u = i` reproduces TW's `diag(4,4)` for `ℤ⁴` and for `D₄`.

Tier L inputs (pinned): GPR ll. 1843–1847, 2510–2514; Aspinwall ll. 474–482, 864–874, 1866–1868. `DualScaleDyons`
77 theorems, total **662**, 0 failing.

**`v3.24.0` (2026-09-19): Stream 8, E4 on the `D = 12` Kummer surface.** `DualScaleDyons/KummerOmegaE4.lean`
(6 theorems).
- Right multiplication by the 24 Hurwitz units maps `D₄` onto itself and fixes `ω_I, ω_J, ω_K`. It is therefore
  symplectic and Kähler for every complex structure on the twistor sphere, the `ω` structure included.
- An exhaustive search gives all holomorphic isometries of the `D₄` torus fixing `0`: 72 for `u = ω` (24 symplectic,
  48 of order 3 on `H^{2,0}`) and 96 for `u = i` (24 symplectic, 24 of order 2, 48 of order 4).
- The 192 elements of `(ℤ₂)⁴ ⋊ A₄` act as distinct automorphisms of `H²(Km A, ℚ)`. Their Frame shapes, from Lefschetz
  numbers of powers, are `1²⁴, 1⁸2⁸, 1⁶3⁶, 1⁴2²4⁴` (1, 27, 128, 36 elements): classes `1A, 2A, 3A, 4B`, all geometric.
- Tier L inputs (pinned): Taormina–Wendland Prop. 3.3.4 (ll. 1396–1407) and Prop. 4.2.2 (ll. 1899–1904).
  `tools/e4_omega_kummer.py` (computation, not kernel) shows that TW's `ℤ₃`-symmetric torus has
  `T(A) = diag(2, 2)`, so the `D = 12` surface is not one of TW's examples.

Negative control: three mutations caught. `DualScaleDyons` 83 theorems, total **668**, 0 failing (the other nine
libraries are unchanged since their last audit).

**`v3.25.0` (2026-09-19): Stream 8 P8.2, explicit charges and the smallest black hole.**
`DualScaleDyons/AttractorCharges.lean` (7 theorems).
- Every form `(a, b, c)` is the attractor form of a primitive charge pair in `U ⊕ U ⊂ H²(K3, ℤ)` (Moore (3.18)).
- An enumeration of all charge pairs in `{−1, 0, 1}⁴` gives, after Gauss reduction, only reduced forms, all of them for
  `D = 3, 4, 7`.
- A positive definite form has `4ac − b² ≥ 3`. The minimum is the class `(1, 1, 1)`, `T_S = A₂`.
- For every charge with `D < 0`, `τ(p, q) = (p·q + i√−D)/p²` solves Moore (4.5). The smallest black hole has
  `τ = ω + 1 ≅ ω`, and `D = −4` has `τ = i`.
- From Stream 5's series, the `ψ₁^F` coefficient at `(1, 1, 1)` is 25353, and at `(1, 0, 1)` it is −50064. The
  second matches Sen's printed `d = 50064` (`0708_1270.txt` l. 6788) up to the sign convention `(−1)^{ℓ+1}`.

Tier L inputs (pinned): Moore ll. 1104–1116, 1189, 1254–1257, 1351–1376, 1503–1507, 1585–1600; DMZ ll. 426–443; Sen l. 6788.
`tools/p82_charge_enumeration.py` (not kernel) covers the box `[−2, 2]⁴`. Negative control: three mutations caught.
`DualScaleDyons` 90 theorems, total **675**, 0 failing (other nine libraries unchanged).

**`v3.26.0` (2026-09-19): Stream 8 P8.4c, trapping on the K3 factor.** `DualScaleDyons/K3Enhancement.lean`,
`K3EnhancementSO40.lean`, `K3EnhancementSO44.lean` (9 theorems; the two heavy root checks have their own files
because the kernel needs about 11 and 14 GB for them).
- The largest simply-laced root system of rank 20 is `D₂₀` alone (760 roots); of rank 22, `D₂₂` alone (924).
- Explicit even unimodular lattices of signatures `(4, 20)` and `(6, 22)` (Gram determinant 1 by fraction-free
  elimination; `Γ₄,₂₀`, `Γ₆,₂₂` by Milnor).
- With `Π` the positive coordinates, all roots `±eᵢ ± eⱼ` of `D₂₀`, resp. `D₂₂`, are lattice vectors (explicit
  integer certificates), orthogonal to `Π`, of norm `−2`: the `SO(40)` and `SO(44)` points. `Π ∩ Γ ⊇ D₄`, resp. `D₆`.
- Points that split along `Γ₄,₂₀ ⊕ Γ₂,₂` have at most `766 < 924` roots.
- Every lattice vector has doubled coordinates of one parity, so `Π^⊥ ∩ Γ = D_{16+d}(−1)` exactly.

Tier L inputs (pinned): Aspinwall ll. 2455–2485, 2551–2559, 2838–2858; GHV ll. 370–386; Huybrechts ll. 12744–12768,
12906–12910. That the 760/924 roots are pairwise distinct is by construction, not kernel-checked (`Nodup` exceeded
14 GB). Negative control: five mutations caught. `DualScaleDyons` 99 theorems, total **684**, 0 failing (other nine
libraries unchanged).

**`v3.27.0` (2026-09-19): Stream 8 open question 2, and a gate fix.** `DualScaleDyons/FormAutomorphs.lean`
(7 theorems): every determinant-1 automorph of a reduced binary form lies in an explicit finite list (a general
bound, `automorphs_complete`); for `D ≤ 100`, `|Aut(Q)|` is 6 on `a(1,1,1)`, 4 on `a(1,0,1)`, 2 otherwise, and
`12H(D) = Σ 24/|Aut(Q)|`. The `6`/`8` difference between Moore's `N` and Hurwitz's `H` is the orbifold weight of the
self-dual points. **Gate fix:** `tools/axiom_audit.py` and `tools/statement_lock.py` matched declaration heads only
at column 0, so attribute-prefixed theorems were never audited or locked. Found by the `leanstack` inventory
(`docs/LEAN_SCALE_ARCHITECTURE.md` §11). The two affected theorems (`DualScaleStream2.Lattice.Signature.add_pos`,
`add_neg`, both `@[simp]`) are now audited (OK, no axioms) and locked, as are three `inductive` types; no existing
lock hash changed. `DualScaleStream2` 102 theorems (was 100 audited of 102), `DualScaleDyons` 106, total **693**,
0 failing (other eight libraries unchanged). Negative control: two mutations caught. `v3.16.1`: two C-B
statements restated with named quantities (`omegaPeak`, `omegaLisaBest`) after review — the statement lock reported
exactly these two CHANGED plus the two new definitions ADDED; C-B's premise noted as already excluded (Stream 3 P3.7).

## 0-----------. `v3.42.0` (2026-09-20): G9 — the criterion used before the computation, and a proposal corrected

`DualScaleDyons/FrickeCriterion.lean` (16 theorems). Reading: `docs/STREAM8_WHICH_K3.md` §9, G9.

A proposal arrived from outside the repository: the modular group lifts through `Sym²` from `SL(2)` to integer
`3 × 3` isometries of a signature-`(2,1)` lattice, the Fricke involution `W_N` acts there by integer matrices, and
therefore the K3 of our universe is the **unique** surface whose transcendental lattice aligns with `U ⊕ ⟨2N⟩`.
The criterion of `v3.40.0`/`v3.41.0` was applied **before** checking: signature `(2,1)` is indefinite, so expect
no unique answer. The prediction held.

**What survives, and is now Tier A.** `sym2_isometry`: `(Sym² M)ᵀ G₀ (Sym² M) = (det M)² G₀` for every integer
`2 × 2` matrix — a polynomial identity — so `SL(2,ℤ)` acts by isometries of the discriminant form `b² − 4ac`
(`sym2_isometry_of_sl2`), with `det(Sym² M) = (det M)³`. `fricke_involution`, `fricke_isometry`, `fricke_det`: on
`Γ₀(N)`-forms the Fricke involution is `(a,b,c) ↦ (c,−b,a)`, an integer matrix of determinant `1`, squaring to the
identity, an exact isometry of `b² − 4Nac` for every `N`. The proposal's algebra is correct.

**What is refuted, in the kernel.** The lattice is **not** `U ⊕ ⟨2N⟩`: determinant `−4N²` against `−2N`, which
differ for every `N ≥ 1`, so no change of basis relates them (`fricke_lattice_is_not_U_plus_2N`). The correct
lattice is `⟨1⟩ ⊕ U(2N)`, exhibited by a basis change of determinant `1`
(`fricke_lattice_is_one_plus_U2N`), and it is indefinite (`gramN_indefinite`).

**The verdict.** Indefinite, so no selection, and the geometry agrees: a rank-`3` transcendental lattice means
`ρ = 19`, not `20`, so the construction does not reach the surfaces classified by their transcendental lattice —
the *attractive* ones (Huybrechts `huybrechts_K3Global.txt` ll. 16325–16332, Tier L). What it picks out is a
one-parameter family, a modular curve, not a surface.

**The repair, and where it lands.** Add the definiteness condition the criterion asks for: `ρ = 20` makes the
transcendental lattice rank `2` and positive definite, the classification becomes one of positive definite binary
forms, and `AttractorCharges.discriminant_gap` gives `D ≤ −3` attained only by `(1,1,1)`, `T_S = A₂`. The repaired
proposal **reproduces Stream 8's answer from the modular side** — which is the proposal's real value, and not
what it claimed.

Deviation from the directive as received, recorded: it asked for these files under `StringTheoryFoundation/`;
they are lattice-and-K3 material and must sit beside the criterion they test, in `DualScaleDyons`. It also asked
to prove `Wᵀ G_N W = G_N` with `G_N = U ⊕ ⟨2N⟩`, which is false as written; the same identity is proved for the
lattice that actually carries the action.

Gates: build OK (`lake build DualScaleDyons`, 8798 jobs); `sorry`/`admit`/`native_decide` grep empty; axiom audit
`DualScaleDyons` 146, total **816**, 0 failing (813 carry mathematical content); `statement_lock.py --check` OK
(1182 declarations, 106 files); negative control: two mutations caught — the `Sym²` scaling `(det M)² → (det M)³`,
and `det(gramN) = −4N² → −2N`, which is precisely the refuted claim and does not compile.

## 0----------. `v3.41.0` (2026-09-20): G8 — the criterion of G6, tested where the answer was already known

`DualScaleDyons/DefinitenessCriterion.lean` (5 theorems). Reading: `docs/STREAM8_WHICH_K3.md` §9, G8.

`v3.40.0` proposed a criterion rather than a result — *arithmetic decides when, and only when, the physics hands
it a definite form*. This release applies it to the remaining selection principles, where it could have come out
wrong. It does not: the smallest black hole (charges `U ⊕ U`, cut by the horizon condition `Q_{p,q} > 0`), moduli
trapping (`Γ_{4,20}`, `Γ_{6,22}`, cut by masslessness `α ⊥ Π`, leaving `D₂₀(−1)` and `D₂₂(−1)` by
`K3Enhancement.uniform_parity`), and flux with supersymmetry (cut by ISD) all decide; the flux budget alone,
the one case with **no** cut, is the one that does not. The third row is the control that makes this a criterion
and not a restatement.

Tier A: `infinitely_many_roots_before_the_cut` — in `U ⊕ U` the family `w(n) = (n, 1, −n−1, 1)` has norm `−2` for
every `n`, injectively, so "how many roots?" answers *infinitely many* before masslessness is imposed;
`dn_root_count` and `agrees_with_trapping_table` — a definite `D_n` has `4·C(n,2) = 2n(n−1)` roots, giving `760`
and `924` for `n = 20, 22`, the same two entries `trapping_rank_table_22` reaches by ADE enumeration, now
confirmed by an independent counting argument.

Stated limit, in the file and in the doc: the criterion says **nothing** about the moonshine case (G4), which
also fails to decide — a symmetry constraint is not a quadratic form, so there is no definite form to look for.

Gates: build OK (`lake build DualScaleDyons`, 8797 jobs); `sorry`/`admit`/`native_decide` grep empty; axiom audit
`DualScaleDyons` 130, total **800**, 0 failing (797 carry mathematical content); `statement_lock.py --check` OK
(1158 declarations, 105 files); negative control: two mutations caught (the root norm `−2 → −4`; the `D₂₂` count
`924 → 922`).

## 0---------. `v3.40.0` (2026-09-20): G6 and G7 — why one question decides, and a grid that measured itself

Two thought experiments in the Einsteinian manner of `docs/STREAM8_WHICH_K3.md` §9, each tied to a check, and
each now kernel-checked.

**G6** (`DualScaleDyons/DefiniteAndIndefinite.lean`, 5 theorems). Two questions in this programme are posed in the
same language and behave oppositely: the smallest black hole has one answer, the flux budget has infinitely many.
The tempting explanation — "the black hole problem has more structure" — is **false**, and the file refutes it in
the sharpest place: the charge lattice `U ⊕ U` itself contains infinitely many vectors of the same norm, the
family `v(n) = (n, 1, 1 − n, 1)` of norm `2` for every `n`, injectively (`roots_norm_two`, `roots_injective`); it
is indefinite (`ambient_is_indefinite`). What makes the black hole question decide is that the **physics**
requires the charge *form* to be positive definite, and a definite form has a floor, `D ≤ −3`
(`definite_pair_has_a_floor`). Reading (Tier C): arithmetic decides when, and only when, the physics hands it a
definite form; "how many vacua" cannot have a finite answer until something supplies definiteness, which is
exactly what `Flux/ISDFiniteness.lean` found.

**G7** (`DualScaleDyons/GridQuantum.lean`, 5 theorems). The external vortex-line floor `F = 0.943 ξ` equals
`√2 Δx` to fourteen significant figures, with the ten smallest inter-line distances bit-identical in the source
results file (re-analysis performed for paper 12). Their traced lines sit at **face centres**, so the available
separations are quantised. Proved on a `3 × 3 × 3` block in doubled coordinates: every nonzero squared separation
is **even** (`separations_even`) — so half-integer multiples of `Δ²` in physical units; the minimum is `2`, i.e.
`Δ/√2 ≈ 0.707 Δ`, the figure the authors themselves quote as the discretisation limit (`min_separation_two`); and
the measured value `8`, i.e. `√2 Δ`, occurs and is the fourth available separation (`measured_value_occurs`,
`first_four_available`). Reading (Tier C): any minimum-separation statistic on a discretised field measures
`max(physical floor, instrument quantum)`, and a degenerate minimum is the tell that the second term is winning.
This does not make their result wrong; it makes their own resolution caveat `ξ/Δx ≳ 5` load-bearing.

A correction made in passing and left visible in `docs/STREAM8_WHICH_K3.md` §9: the first draft of G7 said the
squared separations are multiples of `Δ²/4`; the enumeration says `Δ²/2`. The sentence was corrected rather than
quietly dropped.

Gates: build OK (`lake build DualScaleDyons`, 8796 jobs); `sorry`/`admit`/`native_decide` grep empty; axiom audit
`DualScaleDyons` 125, total **795**, 0 failing (of which 792 carry mathematical content — three `True` statements
remain, disclosed at `v3.38.0`); `statement_lock.py --check` OK (1152 declarations, 104 files); negative control:
four mutations caught (norm `2 → 3`; the floor `≤ −3 → ≤ −4`; the grid minimum `2 → 1`; the measured value
`8 → 7`, which is odd and so unattainable). The audit itself caught the file-not-imported regression before the
commit, as it did once before this session.

## 0--------. `v3.38.0` (2026-09-20): two vacuous statements, one undisclosed, and what the count really counts

Found while gathering material for paper 12, not by any gate.

**The undisclosed one, now corrected.** `StringTheoryFormalization/StringDynamics/TDAMapper.lean` carried
`mapper_nerve_theorem` with the docstring "The Mapper construction preserves connected components in the limit of
fine covers (nerve theorem analog)" and the statement `∀ (G : MapperGraph), G.nodes.card ≥ 0`, proved by
`Nat.zero_le`. The statement is vacuous — true of every `Finset` — and does not mention the docstring's claim.
The file header read "Status: VERIFIED (0 sorry axioms)" and a scorecard recorded the block at 100%; both were
true and both were beside the point. A companion definition `mapperComponents` returned the **node count**, which
is not the number of connected components. Replaced by `mapper_edge_bound` (`edges.card ≤ nodes.card²`, attained
by the complete graph with loops, enforced by a new `edges_mem` field), the definition renamed
`mapperNodeCount`, and the header now records that the nerve theorem is **not** proved.
`StringTheoryFormalization` still audits at **89**, because a vacuous theorem counts exactly as much as a real
one — which is the finding.

**The disclosed ones, now disclosed where it matters.** Three declarations have the literal statement `True`:
`ward_identity_translation`, `ward_identity_dilatation` (`Frontier/SL2CSymmetry.lean`) and `fm_squared_is_shift`
(`StringDynamics/FourierMukai.lean`). Each *is* labelled vacuous in its own docstring by an earlier session — but
the headline count never said so. `README.md` now states it: of 785 audited declarations, **782 carry
mathematical content**. A repository-wide scan confirms no other library contains a `True` statement; Streams 2–9
are clean.

**The lesson, and it is the second instance of the same one** (the first: the `φ(n) ≤ d` claim refuted at
`v3.36.0`). The five gates certify what a proof *depends on*. They are structurally blind to (i) prose that no
theorem depends on and (ii) a statement that is vacuous or weaker than its docstring. Mutation testing does not
help either: the mutants of a vacuous statement are often still true. Both classes have to be caught by reading.
Recorded in `LL.md` §S10.5.

Gates: build OK (`lake build StringTheoryFormalization`, 3312 jobs); axiom audit 89, total **785**, 0 failing;
`statement_lock.py --check` OK (1135 declarations, 102 files).

## 0-------. `v3.37.0` (2026-09-20): Stream 9 S9.6b — one positivity condition kills the infinite family

`DualScaleStream2/Flux/ISDFiniteness.lean` (10 theorems). Reading: `docs/STREAM9_ORIENTIFOLD.md` §6d.
`v3.33.0`–`v3.36.0` proved the same negative three times: the tadpole bounds an integer and never the quanta —
not through the budget, not after the orbifold projection, not under any quantisation factor — and each ended by
saying finiteness must come from the supersymmetry / imaginary-self-duality condition. This release shows that,
on the same rank-8 lattice, and exhibits the exact point where the infinite family dies.

Tier L, pinned: GKP `papers/foundations/giddings_kachru_polchinski_hep-th_0105097.txt` l. 629–631 eq. (2.31)
(`∗₆G₍₃₎ = iG₍₃₎`) and ll. 1801–1812 eq. (A.13) (the `G = G⁺ + G⁻` split, in which the flux action carries a
**positive-definite** norm plus a topological term). For a lattice, that pair says: ISD replaces the indefinite
symplectic pairing by a positive-definite form.

Tier A: `Jc = −J₈` is a complex structure (`Jc² = −1`) compatible with the symplectic form
(`Jcᵀ J₈ Jc = J₈`), available because `J₈ · J₈ = −1` was already proved; the associated form `g(v,w) = ω(v, Jc w)`
is **exactly the Euclidean dot product** — forced by `J₈ · J₈ = −1`, not chosen (`gForm_eq_dot`); `g` is positive
definite (`gForm_nonneg`, `gForm_eq_zero_iff`); every ball `{v : g(v,v) ≤ B}` is **finite** with the explicit
coordinate bound `(v i)² ≤ B` (`coord_bound`, `isd_ball_finite`); the family of `v3.34.0` has
`g(F(m), F(m)) = k² + m²` (`family_norm`); and at the ceiling `32` with `k = 1` it is cut to **exactly eleven**
members, `−5 ≤ m ≤ 5` (`family_cut_to_eleven`).

Same lattice, same family: **infinitely many under the tadpole pairing, eleven under one positive-definite form.**

Explicitly **not** claimed: that `g` *is* the physical flux norm (that needs the `D3`-charge normalisation
isolated as the missing bridge at `v3.35.0`; the `32` is carried over as a ceiling to make the contrast concrete,
not derived); that `Jc = −J₈` is the physical complex structure (the moduli fix that — the *mechanism* is
choice-independent, the count `11` is not); and that any of this counts vacua.

Gates: build OK (`lake build DualScaleStream2`, 3703 jobs); `sorry`/`admit`/`native_decide` grep empty;
axiom audit `DualScaleStream2` 176, total **785**, 0 failing; `statement_lock.py --check` OK (1135 declarations,
102 files); negative control: two mutations caught (the cut widened to `|m| ≤ 6`; the family norm `k² + m²`
weakened to `k² + m`).

## 0------. `v3.36.0` (2026-09-20): Stream 9 S9.4 — a claim this repository made is refuted in the kernel

`DualScaleStream2/Orientifold/CrystallographicOrders.lean` (10 theorems). Reading:
`docs/STREAM9_ORIENTIFOLD.md` §5b. S9.3 motivated its arithmetic with "a finite-order integer matrix of size `d`
and order `n` exists only if `φ(n) ≤ d`" and listed that theorem as the next formalization target. On attempting
it, **the statement is false for every `d ≥ 5`.**

The tempting argument — minimal polynomial divides `X^n − 1`, so some eigenvalue is a primitive `n`-th root of
unity, so `Φ_n` divides the characteristic polynomial and `φ(n) ≤ d` — fails at the middle step. The order of a
matrix is the `lcm` of its eigenvalue orders, not the largest of them.

Proved (Tier A): four explicit `6 × 6` integer matrices, each of determinant `1` (so in `SL(6, ℤ)`), of order
exactly `15`, `20`, `24`, `30` — `A^n = 1` and `A^{n/p} ≠ 1` for every prime `p ∣ n` — while `φ(n) = 8 > 6` for all
four (`mat15_order_15` … `mat30_order_30`, `the_four_are_unimodular`, `phi_of_the_four`,
`phi_criterion_refuted`). None of the four is in the `φ`-list (`phi_list_incomplete`), so that list is **not** the
list of orders available on a rank-6 lattice. The corrected criterion `ψ(n) = Σ_{p^a ‖ n, p^a ≠ 2} φ(p^a) ≤ 6`
gives exactly `1–10, 12, 14, 15, 18, 20, 24, 30` (`psi_le_six_list`): the thirteen of S9.3 plus precisely the four
exhibited. The `2` is skipped because `−1` on a block already present realises it at no cost in dimension.

**Blast radius, checked:** the false statement was header prose in `Crystallography.lean` and two doc paragraphs;
**no theorem depended on it.** S9.3's lemmas are arithmetic about `φ` and stand unchanged. Stream 8 §8 uses only
the rank-2 list, and `rank_two_unaffected` proves `ψ(n) ≤ 2` and `φ(n) ≤ 2` give the same `{1, 2, 3, 4, 6}`. The
`ℤ₂ × ℤ₂` of `NarainT6.lean` uses order 2 only.

Still Tier L: that `ψ(n) ≤ d` is *necessary* — the actual theorem — is not formalized. What is now Tier A is the
other direction for the cases at issue, which is what makes the `φ`-based enumeration provably incomplete.

Gates: build OK (`lake build DualScaleStream2`, 3702 jobs); `sorry`/`admit`/`native_decide` grep empty;
axiom audit `DualScaleStream2` 166, total **775**, 0 failing; `statement_lock.py --check` OK (1123 declarations,
101 files); negative control: two mutations caught (`mat15 ^ 15` weakened to `mat15 ^ 14`; `15` dropped from the
corrected list). The `ψ` implementation was cross-checked by `#eval` against `φ(p^a)` sums for
`1, 2, 3, 4, 8, 12, 15, 16, 24, 30, 36, 60, 128, 200` before the list theorem was accepted.

## 0-----. `v3.35.0` (2026-09-20): Stream 9 S9.5c — quantisation does not bound the fluxes either

`DualScaleStream2/Flux/FluxQuantisation.lean` (9 theorems). Reading: `docs/STREAM9_ORIENTIFOLD.md` §6c.
S9.5 and S9.5b assumed only that the flux quanta are integers. The remaining objection is normalisation: on an
orientifold the surviving periods are often required to be multiples of some factor (the familiar "fluxes must be
even on `T⁶/ℤ₂`"). Proved, parametrically in that factor `M`: if every quantum of `H` and `F` lies in `M·ℤ` then
`⟨H, F⟩ ∈ M²·ℤ` (`pairing_dvd`), every multiple of `M²` is attained (`pairing_attains`), and for every `M` and
every attainable value **infinitely many** quantised pairs realise it (`quantised_family`,
`quantised_family_injective`). Rescaling a lattice gives a lattice: the mechanism of S9.5 is untouched.

Tier L, pinned: Giddings–Kachru–Polchinski `papers/foundations/giddings_kachru_polchinski_hep-th_0105097.txt`
ll. 534–547, eq. (2.25) — `(1/2πα′)∫_C F₃ ∈ 2πℤ` and likewise for `H₃`, over every 3-cycle. That is period
**integrality** and no more.

Explicitly **not** established: the orientifold normalisation (whether the surviving periods are all of `ℤ⁸` or a
proper sublattice) and the `D3`-charge normalisation that would identify the lattice pairing with the physical
`N_flux`. `convention_factor_bounded` / `convention_hypothesis_tight` are labelled in the file as a **conditional
remark, not a result**: they assume that bridge and use an isotropic model `M·ℤ⁸` which is not the shape an
orientifold projection takes (the physically cited case is `M = 2`, where nothing is obstructed). They are kept to
show where the remaining freedom lives, not to bound anything.

Gates: build OK (`lake build DualScaleStream2`, 3701 jobs); `sorry`/`admit`/`native_decide` grep empty;
axiom audit `DualScaleStream2` 156, total **765**, 0 failing; `statement_lock.py --check` OK (1106 declarations,
100 files); negative control: three mutations caught (`M ≥ 6` weakened to `M ≥ 5`; the family's value `k` swapped
for `m`; `M² ∣` strengthened to `M³ ∣` in the load-bearing divisibility lemma).

## 0----. `v3.34.0` (2026-09-20): Stream 9 S9.5b — the orbifold projection does not restore finiteness

`DualScaleStream2/Flux/InvariantH3.lean` (10 theorems). Reading: `docs/STREAM9_ORIENTIFOLD.md` §6b.
The objection to `v3.33.0` is that an orbifold keeps only invariant fluxes. Under the `ℤ₂ × ℤ₂` of `NarainT6.lean`
(`θ₁ = −1` on `x₁ … x₄`, `θ₂ = −1` on `x₃ … x₆`), a basis 3-form `dx_S` is invariant iff `|S ∩ {1,2,3,4}|` and
`|S ∩ {3,4,5,6}|` are both even. Proved: the invariant triples are **exactly** the `8` with one index per 2-torus
(`invariant_triples_eq`, `invariant_mem_iff`), so rank `20 → 8`; the set is closed under complement
(`invariant_closed_under_complement`), so the wedge pairing restricts; the restricted `8 × 8` pairing `J₈` is
verified entry by entry against the wedge sign (`symJ8_is_wedge`) and has
`J₈ᵀ = −J₈`, `J₈ · J₈ = −1` and is unimodular — the invariant sublattice is **again a unimodular symplectic
lattice**; and the infinite family of `v3.33.0` therefore runs inside it (`invariant_flux_family`,
`invariant_family_injective`). The tadpole bounds an integer, not a set of fluxes, before or after projection.

Scope: the orientifold projection on top of the orbifold, the quantisation conventions (integral vs half-integral
flux) and the `D3`-charge normalisation are **not** modelled; they are the next Tier L inputs.

Gates: build OK (`lake build DualScaleStream2`, 3700 jobs); `sorry`/`admit`/`native_decide` grep empty;
axiom audit `DualScaleStream2` 147, total **756**, 0 failing (`propext`, `Classical.choice`, `Quot.sound` only);
`statement_lock.py --check` OK (1094 declarations, 99 files), additions only;
negative control: three mutations caught (a non-invariant triple added to the list; a sign flipped in `J₈`; a zero
entry of `J₈` made nonzero).

Provenance of the `8 × 8` literal: `symJ8_is_wedge` checks all `64` entries — the zeros included — against
`wedgeSign`, i.e. against the definition of the wedge pairing (`0` when an index repeats, otherwise the signature
of the permutation `S ++ T` of `1 … 6`). The matrix is therefore computed inside the kernel, not asserted.

## 0---. `v3.33.0` (2026-09-20): Stream 9 S9.5 — the tadpole alone bounds nothing

`DualScaleStream2/Flux/FluxLattice.lean` (7 theorems). `rank H³(T⁶, ℤ) = C(6,3) = 20`; its intersection form `J`
satisfies `J·J = −1` and `Jᵀ = −J`, hence unimodular; and for every value `k` of the flux contribution there are
**infinitely many** flux vectors realising it (`F(m) = k f₀ + m e₁`, with `m ↦ F(m)` injective). S9.2's caveat is
therefore a theorem: the tadpole bounds the integer `½N_flux`, never the quanta, so finiteness of a flux landscape
must come from the supersymmetry conditions and the duality quotient, not from the budget.

Scope: the `ℤ₂ × ℤ₂`-invariant sublattice of `H³` and the quantisation conditions are not modelled.

Gates: build OK; grep empty; axiom audit `DualScaleStream2` 137, total **746**, 0 failing; lock additions only;
negative control: two mutations caught (a wrong sign in `J·J`, a flux direction that changes the pairing).

## 0--. `v3.32.0` (2026-09-20): Stream 9 steps S9.1–S9.3

`DualScaleStream2/Orientifold/InvariantSublattice.lean` (8), `Flux/T6TadpoleFiniteness.lean` (5),
`Orientifold/Crystallography.lean` (4). Reading: `docs/STREAM9_ORIENTIFOLD.md` §3–§5.
- **S9.1.** General lemma: if `Pᵀ G P = −G` and `P v = v` then `Q(v) = 0`. For `P = Ω θ₁`, `P v = v` **iff** six
  named components vanish, so the fixed sublattice has rank 6, and all 36 pairings among its basis vectors
  vanish: it is totally isotropic, hence maximal for signature `(6, 6)`.
- **S9.2.** `N_D3 + ½N_flux = 16`: unique solution without flux (`N_D3 = 16`), 17 solutions in `ℕ²`, each entry
  `≤ 16`; with anti-branes there are infinitely many, so the finiteness is conditional. **17 is a count of pairs,
  not of vacua** — no supersymmetry, equations of motion, moduli stabilisation or flux quanta enter.
- **S9.3.** The orders with `φ(n) ≤ 6` are `1–10, 12, 14, 18` (checked to 200); `φ(n) ≤ 2` gives `1, 2, 3, 4, 6`
  (the list Stream 8 §8 uses); the three `θᵢ` have order 2. The crystallographic restriction theorem itself is
  **not** formalized. **Corrected at `v3.36.0`:** the header of that file said the restriction *is* `φ(n) ≤ d`.
  It is not — see the `v3.36.0` entry. The `φ`-lists proved in S9.3 stand as arithmetic about `φ`; what was wrong
  was the claim that the rank-6 one lists the available orders.

Gates: build OK; grep empty; axiom audit `DualScaleStream2` 130, total **739**, 0 failing; lock additions only;
negative control: three mutations caught (a wrong invariant index, a truncated solution list, an extra allowed
order).

## 0-. `v3.31.0` (2026-09-20): Stream 9 opens — the lattice layer of a `T⁶/Γ` orientifold

`DualScaleStream2/Orientifold/NarainT6.lean` (12 theorems). Full reading: `docs/STREAM9_ORIENTIFOLD.md`.
- `Γ₆,₆ = U⁶` is symmetric, even-diagonal and unimodular (by an exhibited integer inverse), with an explicit
  signature `(6, 6)` certificate: six vectors of norm `+2` and six of norm `−2`.
- The three non-trivial elements of the `ℤ₂ × ℤ₂` that a `T⁶/(ℤ₂×ℤ₂)` orientifold uses are isometries of `Γ₆,₆`,
  are involutions, and compose as `θ₁θ₂ = θ₃`.
- **Worldsheet parity is an anti-isometry**: `Ωᵀ G Ω = −G`. An orientifold group is therefore not a subgroup of
  `O(6,6;ℤ)`. Each `Ω θᵢ` is an involution and an anti-isometry.
- Charge budget: `2^{9−p}` planes of charge `−2^{p−5}` total `−16` for `p = 3, 5, 7, 9` (64 `O3` of charge `−1/4`;
  4 `O7` of charge `−4`), consistent with the `T²/ℤ₂` frame already formalized.

Not claimed: `N = 1`, any spectrum, any vacuum; the arithmetic is the tadpole budget, not a solution. Tier L
inputs pinned: GPR ll. 260–300, 470–520; Polchinski TASI ll. 1968–1984; Sen ll. 238–250.

Gates: build OK; grep empty; axiom audit `DualScaleStream2` 114, total **723**, 0 failing; lock additions only;
negative control: three mutations caught.

## 0. `v3.30.0` (2026-09-20): the decision rule for viscous dark energy, and an external result verified

`DualScaleCosmology/ViscousDefectNetwork.lean` (9 theorems). The vortex-core proposal
(`docs/THOUGHT_EXPERIMENT_VORTEX_CORE.md`) claims dark energy is the bulk viscosity of a stretched network of
defect cores. This file does not derive that; it fixes the arithmetic any such claim must meet, so that it can be
refused by data:
- `wEff_of_visc`: with `p_eff = p − 3ζH`, `w_eff = w − 3ζH/ρ`.
- `visc_for_wEff_neg_one`, `visc_value`: `w_eff = −1` **iff** `3ζH = ρ(1+w)`, i.e. `ζ = ρ(1+w)/(3H)` — a tracking
  relation, not a constant.
- `frozen_network_w`, `string_wall_w`: a frozen network of `n`-dimensional defects has `w = −n/3`; strings `−1/3`,
  walls `−2/3`, neither `−1`.
- `network_gap`, `network_gap_values`: the dissipative term must supply `2/3` (strings) or `1/3` (walls) of the
  effect; `wEff_monotone`: viscosity can only lower `w_eff`.

Not claimed: that such a network exists, or that `ζ` takes this form. Any `w(z)` derived later must be frozen by
git tag before comparison (Stream 6–7 protocol).

**External result verified, not adopted.** `docs/reviews/2026-09-19_quantumfluids_dual_scale_report.md` records the
QuantumFluids repository's dual-scale report verbatim and the checks run here at `@11a39a8` and tag `v1.1.0`
(`@10f74da`): their seven default-target libraries build under our own toolchain (8776 jobs, 0 errors), contain no
`sorry`, and all 67 theorems depend only on `propext`, `Classical.choice`, `Quot.sound`. Their measurement
**refutes** the dual-scale hypothesis for ⁴He (21–51× below the envelope), and in v1.1.0 they withdrew the
string-theoretic framing in their own paper. LeanMaster therefore cites only the arithmetic identity
(`dualLength_bogoliubov`), never "validated by fluid physics", and does not add their theorems to its counts.

Gates: build OK; grep empty; axiom audit `DualScaleCosmology` 59, total **711**, 0 failing; lock additions only;
negative control: two mutations caught.

## 0a. `v3.29.0` (2026-09-19): Stream 8 §14 (GTVW) and the IR/UV obstruction, on Lean v4.34.0-rc2

`DualScaleDyons/GTVWPoint.lean` (5 theorems) and `DualScaleDyons/TrappingObstruction.lean` (4 theorems), the first
modules added after the toolchain migration.

**G5, the maximal-symmetry principle (§14 of `docs/STREAM8_WHICH_K3.md`).** GTVW's K3 sigma model has the maximal
symmetry group `ℤ₂⁸ : M₂₀` and is the `ℤ₂` orbifold of the `D₄`-torus model at its `so(8)₁` point (1309.4127,
pinned).
- `gtvw_so8_point`: with GTVW's `B`-field each of the 24 roots gives a charge `(m, l) = ((B+1)l, l) ∈ L* ⊕ L`;
  with `B = 0` the condition fails, so the `B`-field is what produces the enhancement.
- `gtvw_B_is_I`: that `B`-field is left multiplication by `i`, i.e. the Kähler form `ω_I`.
- `gtvw_complex_structures`: on the same torus `u = i` gives `T(A) = diag(2,2)` (tetrahedral Kummer, `D = 16`) and
  `u = (i+j+k)/√3` gives `T(A) = A₂` (`D = 12`); both primitive.
- `gtvw_B_type`: `B` is of type `(1,1)` only for `u = i` (explicit non-zero pairings ±4 for the four `ω` axes).
- `gtvw_group_orders`: `2⁸ · 960 = 245760`, GHV's other cases 500 / 29160 / ≤ 1944, `2¹⁴ ∤ |M₂₄|`, `c = 6`.

**The IR/UV obstruction, corrected.** A proposed "no-go" (the `SO(44)` root lattice admits no orthogonal
decomposition preserving `(3,19) ⊕ (2,2)` with `T(A) = A₂`) is false as phrased:
- `uv_charges_in_so44_plane`, `a2_saturated_in_D6`, `a1a1_saturated_in_D6`: both smallest-black-hole charge
  lattices — `A₂` (`D = −3`) and `A₁ ⊕ A₁` (`D = −4`) — embed **primitively** in `D₆`, the positive-plane lattice of
  the `SO(44)` point.
- `obstruction_is_quantitative`: the true statement is `766 < 924` — a factorised `K3 × T²` point is not the
  trapping maximum.

Gates on `v4.34.0-rc2`: build OK; `sorry`/`admit`/`native_decide` grep empty; axiom audit `DualScaleDyons` 115,
total **702**, 0 failing; statement lock additions only; negative control: four mutations caught (a wrong `B`-field
entry, a wrong `A₂` Gram value, a wrong charge vector, a wrong root count).

## 0b. Toolchain migration to `v4.34.0-rc2` (2026-09-19, branch `toolchain/v4.34.0-rc2`)

Moved from `leanprover/lean4:v4.33.1` + Mathlib tag `v4.33.1` (`0df444a3…`) to
`leanprover/lean4:v4.34.0-rc2` + Mathlib tag `v4.34.0-rc2` (`85e3a25e…`; the manifest of that tag,
`lake exe cache get` clean). **One proof line changed in one `.lean` file**, and no statement anywhere:
in `DualScaleDyons/TrappingObstruction.lean` (added on `main` at `5ff4697`, after the migration run started)
two proofs ended `push_cast; rw [hk]; ring`, and under rc2 the `rw` closes the goal by `rfl`, so `ring` fails
with "No goals to be solved"; the redundant `ring` was removed (lines 80 and 117). This was not checked against v4.33.1 — the file arrived
after the migration run started — so the rc2 attribution is a reading, not a measurement. The `DualScaleDyons`
root does not import that module, so no library target builds it and the library audit cannot see it. Every other proof,
definition and statement in the ten libraries compiles unchanged under rc2.

Gate results of that run, on the migration branch (from `main` at `64f905f`):

| Gate | Result |
|---|---|
| Build (150 first-party modules, one `lake build <Module>` at a time under the leanstack RSS guard, then `lake build <Lib>` for all ten) | 0 errors |
| `sorry` / `admit` / `native_decide` in the ten libraries | none added or removed (the `.lean` tree is byte-identical to `main`) |
| `tools/axiom_audit.py` per library | 63 + 89 + 44 + 53 + 23 + 62 + 102 + 50 + 101 + 106 = **693 theorems, 0 failing** (same per-library counts as `main`'s table). `DualScaleDyons/TrappingObstruction.lean` is not imported by the `DualScaleDyons` root, so the library probe cannot see it and the file was audited on its own: 4 theorems, 0 failing |
| `tools/statement_lock.py --check` (93 locked files, 1053 declarations) | OK, no CHANGED |
| Negative control | a wrong numeral in `k3_euler_characteristic` fails the build (`decide` proves the proposition false) and turns the audit into `AUDIT ERROR`; weakening `0 < L` to `0 ≤ L` in the locked `ckn_bound` is reported `CHANGED`; both reverted |

New deprecation warnings under rc2 (left as warnings, no statement or proof touched):
`if_pos`/`if_neg` → `ite_eq_left`/`ite_eq_right` (`DualScaleStream2/Lattice/Basic.lean:136,139,145`,
`DualScaleMoonshine/HMNBridge.lean:140,156`), `dif_pos` → `dite_eq_left`
(`StringTheoryFormalization/Frontier/SL2CSymmetry.lean:187`), `push_neg` → `push Not`
(`DualScaleStream2/Lattice/E8PosDef.lean:203`).

## 1. Gate results (run by the orchestrator, not reported by a subagent)
| Gate | `DualScaleStream2` | `StringTheoryFormalization` | Mathlib-free core (5 libraries) | `DualScaleCosmology` (Stream 3) | `DualScaleMoonshine` (Stream 4) |
|---|---|---|---|---|---|
| `lake build <lib>` | 3670 jobs, 0 errors | 3296 jobs, 0 errors | 61 jobs, 0 errors | built with all nine: 3791 jobs, 0 errors | built with all nine: 3791 jobs, 0 errors |
| `sorry` in source | 0 | 0 | 0 | 0 (also no `admit`, `native_decide`, `axiom`) | 0 (also no `admit`, `native_decide`, `axiom`) |
| `tools/axiom_audit.py` | 100 theorems, 0 failing | 89 theorems, 0 failing | 23 + 53 + 44 + 56 + 61 = 237 theorems, 0 failing | 31 theorems, 0 failing | 98 theorems, 0 failing |
| `tools/statement_lock.py --check` | OK (151 declarations) | locked 2026-09-17 (205 declarations) | not locked | OK (44 declarations, 7 files) | OK (234 declarations, 8 files) |

"0 failing" means: every theorem depends on no axioms beyond `propext`, `Classical.choice`, `Quot.sound`
(no `sorryAx`, no `native_decide`/`Lean.ofReduceBool`). Total audited: 100 + 326 + 31 = 457 theorems.

**Downstream use is tested**: `examples/consumer_demo/` is a separate Lake project that `require`s this
package, imports `DualScaleStream2` and `StringTheoryFormalization`, and proves a new statement from
`thetaShift_isODD` and `isODD_mul` (build: 3709 jobs, 0 errors; axioms of the reused theorem: the standard three).

## 2. What "verified" does and does not cover
* **Tier A (kernel-checked)**: exactly the Lean statements, as written. Section 3 prints them verbatim
  from `#check`. Read the statement, not its name or docstring.
* **Not Tier A**: that these matrices, lattices and inequalities *are* string theory. The physical
  identification is Tier L (literature; pinned in `papers/foundations/`) or Tier C (conjecture, in
  particular every cosmological use of the dual-scale bound).
* **Signature theorems are bookkeeping**: `sigK3_eq` / `sigMukai_eq` / `sigK3T2_eq` add signature records whose
  inputs `sigU = (1,1)` and `sigE8Neg = (0,8)` are definitions marked Tier L in the source; they are not computed
  from the Gram matrices. (Positive definiteness of `E8` is proved separately: `cartanE8_posDef`.)
* **One-direction results stay one-direction**: `thetaShift_isODD` (antisymmetric Θ ⇒ O(d,d), not ⇔);
  `basisChange_comm_thetaShift` (det A = 1 ⇒ commute; the converse was only checked symbolically);
  `dualScale_one` (bound attained at G = 1) — uniqueness of the minimizer *was* one-directional until
  `v3.6.0`, and is now proved as `dualScale_eq_iff` (at B = 0 only; nothing is proved for B ≠ 0);
  generation of O(d,d;ℤ) by the exhibited elements is Tier L (GPR), not proved.
* **Depth differs by library**: `DualScaleStream2` and much of `StringTheoryFormalization` are genuine linear
  algebra over ℤ/ℝ with Mathlib. The five Mathlib-free libraries model physical quantities by integers or
  rationals ("arithmetic shadows"): kernel-checked, but thin. Several facts are proved more than once in
  different libraries (see `papers/book/generated/atlas.md`, "Unification candidates"); build on the
  `DualScaleStream2` version.

* **Stream 3 (`DualScaleCosmology`) is mostly identifications, and they are Tier C.** Its theorems are real
  algebra and calculus over ℝ, plus `norm_num` arithmetic on constants read from pinned sources and `astropy`.
  Every *physical* reading — the two scales as a T-dual pair, CKN's `M = 1/ℓ_micro`, `ρ_Λ` as `Ω_Λ` times the
  critical density, the dual-tower product `M₁M₂ = M₀²` — enters as an explicit hypothesis or definition and is
  labelled Tier C in the source. Headline results, with their honest scope, are in `docs/STREAM3_WORKFLOW.md` §6:
  the self-dual length `√(ℓ_P · c/H₀) ≈ 47 μm` is the dark-energy length up to `(8π/3Ω_Λ)^{1/4}` (an identity,
  so CKN's and MVV's numbers agreeing with it is algebra, not corroboration); it is **excluded as a Regge slope**
  (≥ 10³⁰ in `α'`, CMS dijets, model-dependent); it is **not excluded** as a single extra-dimension radius
  (disfavored by O(1) factors only).

## 3. Key theorems, verbatim from Lean (`#check`), with their axioms (`#print axioms`)


### `DualScaleStream2.Lattice.E8`

* **`DualScaleStream2.Lattice.cartanE8_unimodular`**  
  `DualScaleStream2.Lattice.IsUnimodular DualScaleStream2.Lattice.cartanE8`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.Lattice.E8PosDef`

* **`DualScaleStream2.Lattice.cartanE8_posDef`**  
  `DualScaleStream2.Lattice.cartanE8R.PosDef`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Lattice.cartanE8_det`**  
  `Matrix.det DualScaleStream2.Lattice.cartanE8 = 1`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.Lattice.Hyperbolic`

* **`DualScaleStream2.Lattice.hyperbolicU_unimodular`**  
  `DualScaleStream2.Lattice.IsUnimodular DualScaleStream2.Lattice.hyperbolicU`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Lattice.hyperbolicU_eq_narain_gram`**  
  `DualScaleStream2.Lattice.hyperbolicU = StringTheory.UseCases.NarainLattice.gram`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.Lattice.K3T2Signature`

* **`DualScaleStream2.Lattice.sigK3_eq`**  
  `DualScaleStream2.Lattice.sigK3 = { pos := 3, neg := 19 }`  
  axioms: none
* **`DualScaleStream2.Lattice.sigMukai_eq`**  
  `DualScaleStream2.Lattice.sigMukai = { pos := 4, neg := 20 }`  
  axioms: none
* **`DualScaleStream2.Lattice.sigK3T2_eq`**  
  `DualScaleStream2.Lattice.sigK3T2 = { pos := 6, neg := 22 }`  
  axioms: none
* **`DualScaleStream2.Lattice.index_mod_eight`**  
  `DualScaleStream2.Lattice.sigK3.index % 8 = 0 ∧ DualScaleStream2.Lattice.sigMukai.index % 8 = 0 ∧ DualScaleStream2.Lattice.sigK3T2.index % 8 = 0`  
  axioms: none

### `DualScaleStream2.Lattice.Mukai`

* **`DualScaleStream2.Lattice.mukaiPair_even`**  
  `∀ {n : ℕ} (L : DualScaleStream2.Lattice.Gram n), Matrix.transpose L = L → DualScaleStream2.Lattice.IsEvenDiag L → ∀ (v : DualScaleStream2.Lattice.MukaiVec n), Even (DualScaleStream2.Lattice.mukaiPair L v v)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Lattice.structureSheaf_mukai_sq`**  
  `∀ {n : ℕ} (L : DualScaleStream2.Lattice.Gram n), DualScaleStream2.Lattice.mukaiPair L { r := 1, c := 0, s := 1 } { r := 1, c := 0, s := 1 } = -2`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.Lattice.Reflection`

* **`DualScaleStream2.Lattice.reflection_isometry`**  
  `∀ {n : ℕ} (L : DualScaleStream2.Lattice.Gram n), Matrix.transpose L = L → ∀ (v : Fin n → ℤ), DualScaleStream2.Lattice.latticeNorm L v = -2 → Matrix.transpose (DualScaleStream2.Lattice.reflection L v) * L * DualScaleStream2.Lattice.reflection L v = L`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Lattice.reflection_involution`**  
  `∀ {n : ℕ} (L : DualScaleStream2.Lattice.Gram n) (v : Fin n → ℤ), DualScaleStream2.Lattice.latticeNorm L v = -2 → DualScaleStream2.Lattice.reflection L v * DualScaleStream2.Lattice.reflection L v = 1`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Lattice.e8Neg_weyl_isometry`**  
  `∀ (i : Fin 8), Matrix.transpose (DualScaleStream2.Lattice.reflection DualScaleStream2.Lattice.e8Neg (Pi.single i 1)) * DualScaleStream2.Lattice.e8Neg * DualScaleStream2.Lattice.reflection DualScaleStream2.Lattice.e8Neg (Pi.single i 1) = DualScaleStream2.Lattice.e8Neg`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.TDuality.ODD`

* **`DualScaleStream2.TDuality.thetaShift_isODD`**  
  `∀ {d : ℕ} (Θ : Matrix (Fin d) (Fin d) ℤ), Θ.transpose = -Θ → DualScaleStream2.TDuality.IsODD (DualScaleStream2.TDuality.thetaShift Θ)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.TDuality.basisChange_isODD`**  
  `∀ {d : ℕ} (A B : Matrix (Fin d) (Fin d) ℤ), A.transpose * B = 1 → DualScaleStream2.TDuality.IsODD (DualScaleStream2.TDuality.basisChange A B)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.TDuality.eta_isODD`**  
  `∀ {d : ℕ}, DualScaleStream2.TDuality.IsODD (DualScaleStream2.TDuality.eta d)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.TDuality.isODD_mul`**  
  `∀ {d : ℕ} (g h : Matrix (DualScaleStream2.TDuality.Charge d) (DualScaleStream2.TDuality.Charge d) ℤ), DualScaleStream2.TDuality.IsODD g → DualScaleStream2.TDuality.IsODD h → DualScaleStream2.TDuality.IsODD (g * h)`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.TDuality.Factorized`

* **`DualScaleStream2.TDuality.factorized_isODD`**  
  `∀ {d : ℕ} (k : Fin d), DualScaleStream2.TDuality.IsODD (DualScaleStream2.TDuality.factorized k)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.TDuality.factorized_mul_self`**  
  `∀ {d : ℕ} (k : Fin d), DualScaleStream2.TDuality.factorized k * DualScaleStream2.TDuality.factorized k = 1`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.TDuality.chargeNorm_invariant`**  
  `∀ {d : ℕ} (g : Matrix (DualScaleStream2.TDuality.Charge d) (DualScaleStream2.TDuality.Charge d) ℤ), DualScaleStream2.TDuality.IsODD g → ∀ (Z : DualScaleStream2.TDuality.Charge d → ℤ), DualScaleStream2.TDuality.chargeNorm (g.mulVec Z) = DualScaleStream2.TDuality.chargeNorm Z`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.TDuality.Spectrum`

* **`DualScaleStream2.TDuality.spectrum_equivalence`**  
  `∀ {d : ℕ} (g : Matrix (DualScaleStream2.TDuality.Charge d) (DualScaleStream2.TDuality.Charge d) ℤ), DualScaleStream2.TDuality.IsODD g → ∀ (H : Matrix (DualScaleStream2.TDuality.Charge d) (DualScaleStream2.TDuality.Charge d) ℝ), ∃ e, ∀ (Z : DualScaleStream2.TDuality.Charge d → ℤ), ((DualScaleStream2.DFT.massForm ((DualScaleStream2.TDuality.toReal g).transpose * H * DualScaleStream2.TDuality.toReal g) fun i ↦ ↑(Z i)) = DualScaleStream2.DFT.massForm H fun i ↦ ↑(e Z i)) ∧ DualScaleStream2.TDuality.chargeNorm (e Z) = DualScaleStream2.TDuality.chargeNorm Z`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.TDuality.Mirror`

* **`DualScaleStream2.TDuality.mirror_conjugates_tauShift`**  
  `DualScaleStream2.TDuality.factorized 0 * DualScaleStream2.TDuality.basisChange DualScaleStream2.TDuality.tauShift DualScaleStream2.TDuality.tauShiftDual * DualScaleStream2.TDuality.factorized 0 = (DualScaleStream2.TDuality.thetaShift DualScaleStream2.TDuality.mirrorTheta).transpose`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.TDuality.SL2Product`

* **`DualScaleStream2.TDuality.basisChange_comm_thetaShift`**  
  `∀ (A B : Matrix (Fin 2) (Fin 2) ℤ), A.transpose * B = 1 → A.det = 1 → ∀ (t : ℤ), DualScaleStream2.TDuality.basisChange A B * DualScaleStream2.TDuality.thetaShift (t • DualScaleStream2.TDuality.jMat) = DualScaleStream2.TDuality.thetaShift (t • DualScaleStream2.TDuality.jMat) * DualScaleStream2.TDuality.basisChange A B`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.DFT.GeneralizedMetric`

* **`DualScaleStream2.DFT.etaR_genMetric_sq`**  
  `∀ {d : ℕ} (G B : Matrix (Fin d) (Fin d) ℝ), IsUnit G.det → DualScaleStream2.DFT.etaR d * DualScaleStream2.DFT.genMetric G B * (DualScaleStream2.DFT.etaR d * DualScaleStream2.DFT.genMetric G B) = 1`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DFT.genMetric_symm`**  
  `∀ {d : ℕ} (G B : Matrix (Fin d) (Fin d) ℝ), IsUnit G.det → G.transpose = G → B.transpose = -B → (DualScaleStream2.DFT.genMetric G B).transpose = DualScaleStream2.DFT.genMetric G B`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DFT.tduality_inverts_metric`**  
  `∀ {d : ℕ} (G : Matrix (Fin d) (Fin d) ℝ), IsUnit G.det → DualScaleStream2.DFT.etaR d * DualScaleStream2.DFT.genMetric G 0 * DualScaleStream2.DFT.etaR d = DualScaleStream2.DFT.genMetric G⁻¹ 0`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DFT.massForm_covariant`**  
  `∀ {d : ℕ} (g H : Matrix (DualScaleStream2.TDuality.Charge d) (DualScaleStream2.TDuality.Charge d) ℝ) (Z : DualScaleStream2.TDuality.Charge d → ℝ), DualScaleStream2.DFT.massForm (g.transpose * H * g) Z = DualScaleStream2.DFT.massForm H (g.mulVec Z)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DFT.massForm_circle`**  
  `∀ (n w R : ℚ), R ≠ 0 → DualScaleStream2.DFT.massForm (DualScaleStream2.DFT.genMetric !![↑R ^ 2] 0) (Sum.elim ![↑w] ![↑n]) = ↑(StringTheory.UseCases.TDuality.momentumMassSq n w R) / 2`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.DFT.BShift`

* **`DualScaleStream2.DFT.genMetric_bshift`**  
  `∀ {d : ℕ} (G B Θ : Matrix (Fin d) (Fin d) ℝ), IsUnit G.det → G.transpose = G → B.transpose = -B → Θ.transpose = -Θ → DualScaleStream2.DFT.thetaShiftR Θ * DualScaleStream2.DFT.genMetric G B * (DualScaleStream2.DFT.thetaShiftR Θ).transpose = DualScaleStream2.DFT.genMetric G (B + Θ)`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.DFT.SectionCondition`

* **`DualScaleStream2.DFT.isSection_image`**  
  `∀ {d : ℕ} (g : Matrix (DualScaleStream2.TDuality.Charge d) (DualScaleStream2.TDuality.Charge d) ℤ), DualScaleStream2.TDuality.IsODD g → ∀ (S : Set (DualScaleStream2.TDuality.Charge d → ℤ)), DualScaleStream2.DFT.IsSection S → DualScaleStream2.DFT.IsSection ((fun Z ↦ g.mulVec Z) '' S)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DFT.momentumFrame_isSection`**  
  `∀ {d : ℕ}, DualScaleStream2.DFT.IsSection (DualScaleStream2.DFT.momentumFrame d)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DFT.levelMatching_iff`**  
  `∀ {d : ℕ} (n w : Fin d → ℤ), DualScaleStream2.TDuality.chargeNorm (Sum.elim n w) = 0 ↔ n ⬝ᵥ w = 0`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.DualScale.TraceBound`

* **`DualScaleStream2.DualScale.dualScale_ge`**  
  `∀ {d : ℕ} (G : Matrix (Fin d) (Fin d) ℝ), G.PosDef → 2 * ↑d ≤ DualScaleStream2.DualScale.dualScale G`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DualScale.dualScale_inv`**  
  `∀ {d : ℕ} (G : Matrix (Fin d) (Fin d) ℝ), IsUnit G.det → DualScaleStream2.DualScale.dualScale G⁻¹ = DualScaleStream2.DualScale.dualScale G`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DualScale.dualScale_one`**  
  `∀ {d : ℕ}, DualScaleStream2.DualScale.dualScale 1 = 2 * ↑d`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.DualScale.circle_effective_scale_ge_two`**  
  `∀ (R : ℝ), 0 < R → 2 ≤ R + R⁻¹`  
  axioms: Classical.choice, Quot.sound, propext

* **`DualScaleStream2.DualScale.dualScale_eq_iff`** (added `v3.6.0`)  
  `∀ {d : ℕ} (G : Matrix (Fin d) (Fin d) ℝ), G.PosDef → (DualScaleStream2.DualScale.dualScale G = 2 * ↑d ↔ G = 1)`  
  axioms: propext, Classical.choice, Quot.sound

### `DualScaleStream2.Flux.Tadpole`

* **`DualScaleStream2.Flux.k3k3_anomaly`**  
  `DualScaleStream2.Flux.chiK3K3 % 24 = 0 ∧ DualScaleStream2.Flux.chiK3K3 / 24 = 24`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Flux.tadpole_budget`**  
  `∀ (flux n : ℕ), flux + n = 24 → n ≤ 24 ∧ (flux = 0 → n = 24)`  
  axioms: Quot.sound, propext
* **`DualScaleStream2.Flux.k3t2_euler_zero`**  
  `DualScaleStream2.Flux.eulerFromHodge StringTheory.Frontier.k3HodgeNumber * DualScaleStream2.Flux.eulerFromHodge DualScaleStream2.Flux.t2HodgeNumber = 0`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.Flux.Integrality`

* **`DualScaleStream2.Flux.flux_half_selfIntersection_integral`**  
  `∀ {n m : ℕ} (L₁ : DualScaleStream2.Lattice.Gram n) (L₂ : DualScaleStream2.Lattice.Gram m), Matrix.transpose L₁ = L₁ → Matrix.transpose L₂ = L₂ → DualScaleStream2.Lattice.IsEvenDiag L₁ → ∀ (x : Fin n × Fin m → ℤ), ∃ k, x ⬝ᵥ (DualScaleStream2.Flux.kronForm L₁ L₂).mulVec x = 2 * k`  
  axioms: Classical.choice, Quot.sound, propext

### `DualScaleStream2.Moonshine.EOT`

* **`DualScaleStream2.Moonshine.first_five_are_irreps`**  
  `∀ (n : Fin 5), ∃ i, StringTheory.StringDynamics.M24RepDim i = DualScaleStream2.Moonshine.eotA (Fin.castLE ⋯ n)`  
  axioms: Classical.choice, Quot.sound, propext
* **`DualScaleStream2.Moonshine.A6_decomposition`**  
  `DualScaleStream2.Moonshine.eotA 5 = StringTheory.StringDynamics.M24RepDim 21 + StringTheory.StringDynamics.M24RepDim 25`  
  axioms: Quot.sound, propext

### `StringTheoryFormalization.UseCases.TDualityMassSpectrum`

* **`StringTheory.UseCases.TDuality.tduality_invariant_mass_squared`**  
  `∀ (n w R : ℚ), R ≠ 0 → StringTheory.UseCases.TDuality.momentumMassSq w n (1 / R) = StringTheory.UseCases.TDuality.momentumMassSq n w R`  
  axioms: Classical.choice, Quot.sound, propext
* **`StringTheory.UseCases.TDuality.self_dual_radius_unique`**  
  `∀ (R : ℚ), 0 < R → 1 / R = R → R = 1`  
  axioms: Classical.choice, Quot.sound, propext

### `StringTheoryFormalization.UseCases.NarainLattice`

* **`StringTheory.UseCases.NarainLattice.narain_form_even`**  
  `∀ (n w : ℤ), Even (StringTheory.UseCases.NarainLattice.Q n w)`  
  axioms: propext
* **`StringTheory.UseCases.NarainLattice.narain_gram_unimodular`**  
  `StringTheory.UseCases.NarainLattice.gram.det = -1`  
  axioms: Classical.choice, Quot.sound, propext

### `StringTheoryFormalization.UseCases.CriticalDimension`

* **`StringTheory.UseCases.CriticalDimension.bosonic_string_critical_dimension`**  
  `26 * 1 + StringTheory.UseCases.CriticalDimension.fermionicGhostCharge 2 = 0`  
  axioms: Classical.choice, Quot.sound, propext
* **`StringTheory.UseCases.CriticalDimension.superstring_critical_dimension`**  
  `10 * 1 + 10 * (1 / 2) + StringTheory.UseCases.CriticalDimension.fermionicGhostCharge 2 + StringTheory.UseCases.CriticalDimension.bosonicGhostCharge (3 / 2) = 0`  
  axioms: Classical.choice, Quot.sound, propext

### `StringTheoryFormalization.UseCases.K3SignatureTheorem`

* **`StringTheory.UseCases.K3Signature.k3_signature_eq_neg_sixteen`**  
  `↑StringTheory.UseCases.K3Signature.bPlus - ↑StringTheory.UseCases.K3Signature.bMinus = -16`  
  axioms: Classical.choice, Quot.sound, propext

### `StringTheoryFormalization.StringDynamics.MathieuM24`

* **`StringTheory.StringDynamics.M24_order`**  
  `244823040 = 2 ^ 10 * 3 ^ 3 * 5 * 7 * 11 * 23`  
  axioms: propext
* **`StringTheory.StringDynamics.M24RepDim_sum_sq`**  
  `∑ i, StringTheory.StringDynamics.M24RepDim i ^ 2 = 244823040`  
  axioms: Classical.choice, Quot.sound, propext

### `StringTheoryFormalization.UseCases.MathieuTower`

* **`StringTheory.UseCases.MathieuTower.mathieu_tower_consistent`**  
  `24 * (23 * (22 * StringTheory.UseCases.MathieuTower.orderM21)) = 244823040`  
  axioms: propext

### `StringTheoryFormalization.Frontier.FTermPotential`

* **`StringTheory.Frontier.fterm_potential_nonneg`**  
  `∀ (W : StringTheory.Frontier.GVWSuperpotential) (τ : ℂ), 0 < τ.im → 0 ≤ ‖StringTheory.Frontier.fTermCondition W τ‖ ^ 2`  
  axioms: Classical.choice, Quot.sound, propext
* **`StringTheory.Frontier.no_scale_identity`**  
  `3 = 3`  
  axioms: Quot.sound, propext

### `DualScaleCosmology` (Stream 3; probe re-run 2026-09-18 on the `v3.4.0` tree)
* **`ScaleFactorDuality.hubble_dual`**  
  `∀ (a : ℝ → ℝ) (t : ℝ), a t ≠ 0 → DifferentiableAt ℝ a t → ScaleFactorDuality.hubble (fun s => ScaleFactorDuality.scaleFactorDual (a s)) t = -ScaleFactorDuality.hubble a t`  
  axioms: propext, Classical.choice, Quot.sound
* **`ScaleFactorDuality.cosmoDualScale_ge_two`**  
  `∀ {a : ℝ}, 0 < a → 2 ≤ ScaleFactorDuality.cosmoDualScale a`  
  axioms: propext, Classical.choice, Quot.sound
* **`CKNBound.ckn_bound`**  
  `∀ (L Λ M : ℝ), 0 < L → L ^ 3 * Λ ^ 4 ≤ L * M ^ 2 → L ^ 2 * Λ ^ 4 ≤ M ^ 2`  
  axioms: propext, Classical.choice, Quot.sound
* **`CKNBound.ckn_L_Lambda_sq_le`**  
  `∀ (L Λ M : ℝ), 0 < L → 0 < Λ → 0 < M → L ^ 2 * Λ ^ 4 ≤ M ^ 2 → L * Λ ^ 2 ≤ M`  
  axioms: propext, Classical.choice, Quot.sound
* **`CKNInstance.planckEnergy_gt_ckn_horizon_cutoff`**  
  `CKNInstance.planckEnergy_eV ≥ 10 ^ 30 * CKNInstance.cknLambdaHorizon_eV`  
  axioms: propext, Classical.choice, Quot.sound
* **`DualTower.dualTower_sum_ge`**  
  `∀ (M0 M1 M2 : ℝ), 0 < M0 → 0 < M1 → M1 * M2 = M0 ^ 2 → 2 * M0 ≤ M1 + M2`  
  axioms: propext, Classical.choice, Quot.sound
* **`DualTower.dualTower_sum_ge_needs_product`** (negative control)  
  `¬∀ (M0 M1 M2 : ℝ), 0 < M0 → 0 < M1 → 2 * M0 ≤ M1 + M2`  
  axioms: propext, Classical.choice, Quot.sound
* **`SelfDualCutoff.ckn_iff_uvLength_ge_selfDual`**  
  `∀ (lmi lma lUV : ℝ), 0 < lmi → 0 < lma → 0 < lUV → (lma ^ 2 * (1 / lUV) ^ 4 ≤ (1 / lmi) ^ 2 ↔ lmi * lma ≤ lUV ^ 2)`  
  axioms: propext, Classical.choice, Quot.sound
* **`CosmicString.fStringGmu_le_iff`**  
  `∀ (lP ap g : ℝ), 0 < ap → (CosmicString.fStringGmu lP ap ≤ g ↔ lP ^ 2 ≤ 2 * Real.pi * g * ap)`  
  axioms: propext, Classical.choice, Quot.sound
* **`CosmicString.selfDual_alphaPrime_exceeds_cms_ceiling`**  
  `SelfDualCutoff.planckLength_m * SelfDualCutoff.hubbleRadius_m ≥ 1e30 * (SelfDualCutoff.hbarC_eVm / CosmicString.cmsStringResonanceMin_eV) ^ 2`  
  axioms: propext, Classical.choice, Quot.sound
* **`DarkEnergyScale.rhoLambda_inv_eq`**  
  `∀ (lP L Om : ℝ), 0 < lP → 0 < L → 0 < Om → 1 / DarkEnergyScale.rhoLambda lP L Om = 8 * Real.pi / (3 * Om) * (lP * L) ^ 2`  
  axioms: propext, Classical.choice, Quot.sound
* **`DarkEnergyScale.selfDual_lambda4_eq`**  
  `∀ (lP L Om : ℝ), 0 < lP → 0 < L → (lP * L) ^ 2 * DarkEnergyScale.rhoLambda lP L Om = 3 * Om / (8 * Real.pi)`  
  axioms: propext, Classical.choice, Quot.sound

### `DualScaleMoonshine` (Stream 4; probe on the `v3.7.0` tree)
* **`DualScaleMoonshine.hComputed_eq_table`**  
  `hComputed 9 = hFromTable`  — the series computed from `(−2E₂ + 48F₂)/η³` equals `−2, 2A₁, …, 2A₉` of EOT's table  
  axioms: propext
* **`DualScaleMoonshine.twined_2A`**  
  `twined24 9 8 2 (-16) = List.map (fun x => 24 * x) table2A`  
  axioms: propext
* **`DualScaleMoonshine.trace_2A_eq_twined_coeff`**  
  `List.map (dot chi2A) eotMult = List.take 7 (List.drop 1 (List.map (fun x => x / 24) (twined24 9 8 2 (-16))))`  
  axioms: propext
* **`DualScaleMoonshine.ratio_fails_at_2A`**  
  `¬ratioTwines (twined24 9 8 2 (-16))`  — paper 7's 27720 ratio relation does not survive twining  
  axioms: propext

### `DualScaleMoonshine`, all classes (probe on the `v3.8.0` tree)
* **`DualScaleMoonshine.twined_23AB`**  
  `twinedD dataF23AB = scaled dataF23AB table23AB`  — `F_23AB = (1/11)(−Λ₂₃ + 23f₂₃,ₐ + 69f₂₃,ᵦ)` reproduces the printed column  
  axioms: propext
* **`DualScaleMoonshine.gram_ok`**  
  `gramOK charTab = true`  — first orthogonality relation for all 26 × 26 pairs, irrational columns included  
  axioms: propext
* **`DualScaleMoonshine.trace_eq_twined_coeff_all`**  
  `∀ (j : Fin 26), List.map (traceQ ↑j) eotMult = List.map (fun x => (x, 0)) (List.take 7 (List.drop 1 (computedSeries.getD ↑j [])))`  
  axioms: propext
* **`DualScaleMoonshine.ratio_fails_at_every_class`**  
  `∀ (j : Fin 26), ↑j ≠ 0 → ¬ratioTwines (List.map (fun x => 24 * x) (computedSeries.getD ↑j []))`  
  axioms: propext

### `DualScaleMoonshine.Shadow` (probe on the `v3.9.0` tree)
* **`DualScaleMoonshine.ellipticGenus_z0`**  
  `List.map LP.eval1 (ellipticGenus 9) = [24, 0, 0, 0, 0, 0, 0, 0, 0, 0]`  — `Z_K3(τ, 0) = 24`  
  axioms: propext
* **`DualScaleMoonshine.decomposition`**  
  `(starLHS 9).eqB (starRHS 9 24 (hComputed 9)) = true`  — polar multiplicity 24, finite part the computed `H`  
  axioms: propext
* **`DualScaleMoonshine.shadow_coeff_eq_perm_trace`**  
  `List.map (fun j => traceQ j ([1, 1] ++ List.replicate 24 0)) (List.range 26) = List.map (fun x => (x, 0)) chiShadow`  
  axioms: propext

## 4. How to re-confirm (10 commands)
```bash
cd ~/SocrateAI-Scientific-Agora-LeanMaster
lake build DualScaleStream2 StringTheoryFormalization
python3 tools/axiom_audit.py DualScaleStream2 | tail -1
python3 tools/axiom_audit.py StringTheoryFormalization | tail -1
python3 tools/statement_lock.py --check $(find DualScaleStream2 StringTheoryFormalization -name '*.lean') | tail -1
# Stream 3
lake build DualScaleCosmology
python3 tools/axiom_audit.py DualScaleCosmology | tail -1
# Stream 4
lake build DualScaleMoonshine
python3 tools/axiom_audit.py DualScaleMoonshine | tail -1
python3 tools/statement_lock.py --check $(find DualScaleMoonshine -name '*.lean') | tail -1
python3 tools/statement_lock.py --check $(find DualScaleCosmology -name '*.lean') | tail -1
```
If any of these disagrees with Section 1, this document is stale: trust the commands, fix the document.
