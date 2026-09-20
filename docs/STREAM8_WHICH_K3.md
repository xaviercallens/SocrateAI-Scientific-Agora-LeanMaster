# Stream 8 — Which K3? (convergence, thought experiments, open questions)

**Status (2026-09-19, release `v3.29.0`, Lean v4.34.0-rc2):** eleven Tier A files (`DualScaleDyons/WhichK3.lean`, 5 theorems;
`DualScaleDyons/SelfDualT2.lean`, 7 theorems — E2, §5; `DualScaleDyons/KummerE3.lean`, 7 theorems — E3, §6;
`DualScaleDyons/ForgerE4.lean`, 6 theorems — E4, §7; `DualScaleDyons/KummerD4.lean`, 8 theorems — G2, §9;
`DualScaleDyons/KummerOmegaE4.lean`, 6 theorems — E4 on the `D = 12` surface, §10;
`DualScaleDyons/AttractorCharges.lean`, 7 theorems — P8.2 and G3, §11; `DualScaleDyons/K3Enhancement.lean` with
`K3EnhancementSO40.lean` and `K3EnhancementSO44.lean`, 9 theorems — P8.4c, §12; `DualScaleDyons/FormAutomorphs.lean`,
7 theorems — open question 2, §13; `DualScaleDyons/GTVWPoint.lean`, 5 theorems — G5, §14;
`DualScaleDyons/TrappingObstruction.lean`, 4 theorems — the IR/UV obstruction corrected, §14); the rest is a
research plan.
Thought experiments are **Tier C** and each is tied to a formalizable target.

## 0. The question, made precise

All K3 surfaces are diffeomorphic; "which K3" means **which point of the moduli space** (complex structure,
Kähler class, B-field; for the sigma model the Grassmannian of positive 4-planes in `Γ_{4,20}`), and — the
lesson of Streams 6–7 — **which mechanism of the theory chooses it**, since a hand-picked point is a free
parameter like `α'` was. A choice must be forced, not fitted.

## 1. The convergence (Tier L + Tier A)

Three independent routes lead to the same object, the `SL(2, ℤ)`-classes of binary quadratic forms
`(a, b, c)` of discriminant `D = b² − 4ac < 0`:

| Route | Statement | Source |
|---|---|---|
| Geometry | K3 surfaces with maximal Picard number `ρ = 20` ("attractive"/"singular") ↔ oriented even positive lattices `T(X) = [[2a,b],[b,2c]]` up to `SL(2,ℤ)` | Huybrechts Cor. 14.3.21, ll. 13658–13696 (Shioda–Inose) |
| Black holes | in K3 × T², the near-horizon K3 of a dyon is attractive; U-duality classes of charges with discriminant `D` (horizon area `∝ √−D`) number `N(D) = Σ_m h(D/m²)` = all form classes | Moore hep-th/9807087 (3.17)–(3.18), ll. 1150–1160, 1250–1262, 1410–1425 |
| Our Stream 5 | the single-centred index at `m = 1` is `3E₄A − 648H`, with `H` the Hurwitz class numbers (weighted form counts) | `DualScaleDyons.immortal_m1` (Tier A) |

**The precise relation between the counts (Tier A, `moore_vs_hurwitz`, `D ≤ 400`):**
`12·N(D) = 12·H(D) + 6·[D = 4f²] + 8·[D = 3f²]`.
Moore's count of attractor backgrounds and the class-number coefficient of the immortal index agree
**except exactly at the discriminants of the two self-dual points of the torus**, `τ = i` and `τ = e^{2πi/3}`,
whose extra automorphisms give the weights `1/2` and `1/3`. Those are the points GPR identify as fixed points
of dualities with maximally enhanced symmetry, `(τ, ρ) = (i, i)` with `(SU(2)×SU(2))²` and the `SU(3)²` point
(GPR ll. 2017–2032).

## 2. Thought experiments (Tier C, each with a formal target)

**E1 — "The black hole chooses its K3."** Drop a dyon of charges `(Q, P)` into K3 × T². Near the horizon the
moduli flow to attractor values fixed by the charges alone: the K3 becomes the attractive surface whose
`T(X)` is the form `(Q², Q·P, P²)` of discriminant `D = (Q·P)² − Q²P²`. The *micro* data (integers) fix the
*macro* geometry — a dual-scale mechanism with **no free `α'`**. *But*: `D` labels a black-hole state, not the
vacuum; the asymptotic K3 remains free. So E1 answers "which K3 near each black hole", not "which K3 is our
universe". *Target:* formalize the attractor form of given charges and check `N(D)` against explicit charge
enumerations for small `D`.

**E2 — "The self-dual points are the most attractive K3s."** The circle's self-dual radius gave `κ = 1`
(Stream 6). On T² the self-dual points are `τ = i`, `τ = e^{2πi/3}`. Their forms `(1,0,1)`, `(1,1,1)` are the
two most attractive K3s, `D = 4, 3` (`most_attractive`); Shioda–Inose builds them over `Km(E_τ × E_τ)` with
exactly these `τ` (Huybrechts Remark 3.22). And the only place where "counting K3s" and "counting immortal
dyons" disagree is on the rays of these two points (`moore_vs_hurwitz`). *Candidate answer:* the dual-scale
K3 is the attractive K3 over the self-dual torus. *Target:* is the `6`/`8` discrepancy explained by the
enhanced symmetry (orbifold weights of the fundamental domain)? — a statement one can formalize.

**E3 — "The torus inside the K3."** A Kummer K3 is `T⁴/ℤ₂` resolved: its 24 splits as `8` (cohomology inherited
from `T⁴`: `1 + 6 + 1`) + `16` (the Kummer lattice, rank 16, discriminant `2⁶`, Huybrechts ll. 2060–2076). The
macro part carries the torus's T-duality — the programme's own `O(d,d; ℤ)` (Stream 2) — and the micro part is
the 16 vanishing cycles. Taormina–Wendland see the `45` of `M₂₄` on states of `ℤ₂`-orbifold models
(1303.3221). Among attractive K3s, the Kummer ones are those with `a, b, c` even (`kummer_iff_even`); the first
are `D = 12, 16`, the doubles of the self-dual points (`first_kummer_attractive`); the Fermat quartic
(`T = ℤ(8)⊕ℤ(8)`, `D = 64`) is one of them (`fermat_quartic_form`). *Target:* construct the Kummer lattice from
`𝔽₂⁴` (Nikulin) and check its invariants.

**E4 — the forger's test for any choice.** A K3 chosen for the theory must survive twining: its symmetry group
(a subgroup of `Co₀` fixing a 4-plane, GHV 1106.4315 ll. 204, 429) should act compatibly with the moonshine
module. *Target:* for the candidates of E2–E3, identify the symmetry group from the literature and check that
the twined genera of its elements are among the 26 computed ones.

## 3. Open questions (in order)

1. **Is `D` forced?** Within K3 × T² black holes, no: `D` is set by charges. For the *vacuum*, nothing in the
   programme fixes a point of moduli space. E2 is the best candidate principle ("maximal self-duality"), but it
   must be derived, not chosen — the same test `α'` failed.
2. **What does the `6`/`8` correction mean?** *Answered at the level of arithmetic (§13):* `12H(D)` is the
   automorphism-weighted count `Σ 24/|Aut(Q)|`, `N(D)` the unweighted one, and `|Aut(Q)| > 2` only on the two
   self-dual rays. Why the index is orbifold-weighted (mock modularity, DMZ) stays Tier L.
3. **Chirality.** None of this cures `N = 4` non-chirality (Stream 7). A realistic model needs a different
   geometry (K3-fibred CY3; `docs/COMMUNITY_ROADMAP.md` P-1).

## 4. Plan (Stream 8)

| Phase | Content | Tier |
|---|---|---|
| P8.1 | convergence and `N` vs `H` relation, Kummer criterion, Fermat quartic | A — **done** (`WhichK3.lean`) |
| P8.2 | attractor form of explicit charges `(Q, P)` in `Γ_{6,22}`; `N(D)` by enumeration for small `D` | A — **done** (§11, `AttractorCharges.lean`) |
| P8.3 | Kummer lattice from `𝔽₂⁴`: rank 16, discriminant `2⁶`, the `8 + 16` split of 24 | A — **done** (§6, `KummerE3.lean`) |
| P8.4 | E2: derive (or refute) a "maximal self-duality" selection principle; freeze any consequence before testing | C → A — **T² part done** (§5); **K3 part done** (P8.4c, §12): `SO(40)`; globally `SO(44)`, not a product point |
| P8.5 | E4: symmetry groups of the candidate K3s vs the 26 twined genera | L + A — **done** for the Kummer structure (§7) and for the `τ = ω` Kummer, `T₁₉₂` (§10); its `M₂₄` embedding via TW's `Θ` open |

## 5. E2 — results (`v3.19.0`, `DualScaleDyons/SelfDualT2.lean`)

**Mechanism, not choice (Tier L).** Moduli trapping (Kofman–Linde–Liu–Maloney–McAllister–Silverstein,
hep-th/0403001): particle production traps rolling moduli at enhanced symmetry points; they "come to rest on a
locus of maximally enhanced symmetry" — for a torus, every circle at its self-dual radius (ll. 1299–1307) — and
the ESPs "with the largest number of light states" are selected (ll. 1309–1311), within the range allowed by
Hubble friction and the potential. This is the circle's `κ = 1` (Stream 6) promoted to a dynamical principle.

**The count (Tier A).** Massless gauge bosons (`p_R = 0`, `p_L² = 2`) with the Stream 2 conventions:
circle at the self-dual radius: 2 (`SU(2)`, `roots_circle`); T² at `(i, i)`: 4 + 4 (`roots_ii`); T² at
`(ω, ω)`: **6 + 6** (`SU(3)_L × SU(3)_R`, `roots_ww`). The counts are complete, not box searches: a sum-of-squares
identity bounds every root's entries (`h3w_sos`, `h3w_bound`, `qI_bound`). Six is the most a rank-2 root system can
have (the kissing number of the plane, standard). So **under trapping, T² comes to rest at `(ω, ω)`**, not `(i, i)`. (The `6 + 6` counts both chiralities; in the
heterotic frame of §12 only one side is gauge, `6` vs `4`, with the same conclusion.)

**The K3 over it (Tier A + Tier C).** The left roots at `(ω, ω)` span the `A₂` lattice (Gram `[[2, −1], [−1, 2]]`),
and the transcendental lattice of the most attractive K3, `T(X₃) = [[2, 1], [1, 2]]` (form `(1,1,1)`, `τ = ω`), is
isometric to it (`ww_root_lattice_is_A2`). The K3 that Shioda–Inose attach to the self-dual `SU(3)` torus has as
transcendental lattice the root lattice of that very `SU(3)`. *Reading (Tier C):* the dual-scale K3 × T² selected
by maximal self-duality is `X₃ × E_ω` with T² at `(ω, ω)`.

**What E2 does not settle.** (i) The K3 factor's own moduli: trapping selects the point of K3 moduli with the most
light states — the maximal ADE enhancement from `(−2)`-vectors orthogonal to the positive 4-plane — and whether
that point is `X₃` (or related to it) is open (P8.4c; it connects to Stream 2's `(−2)`-reflections). (ii) The
assumptions of trapping (accessible range, Hubble friction, early-universe dynamics). (iii) Observables: none —
`N = 4`, non-chiral. Any consequence would be frozen before comparison (paper 11 protocol). (iv) E3 (Kummer) is the
next experiment: the Kummer K3s on the `τ = ω` ray are `T = A₂(2)` (`D = 12`, `first_kummer_attractive`).

## 6. E3 — results (`v3.20.0`, `DualScaleDyons/KummerE3.lean`)

**The lattice (Tier L + Tier A).** Taormina–Wendland (1107.3834, Prop. 2.2.3, ll. 450–470): the Kummer lattice `Π` is
spanned by the 16 exceptional classes `E_a`, `a ∈ 𝔽₂⁴`, and the half-sums `½ Σ_{a∈H} E_a` over the affine hyperplanes
`H`; its orthogonal complement is `K ≅ U(2)³`, the pushed-forward lattice of the torus. Computed (`kummer_code`,
`kummer_disc`): the 30 hyperplanes span a 32-word code of dimension 5 (Reed–Muller `RM(1,4)`), weights `0, 8, 16` with
multiplicities `1, 30, 1`, so `disc Π = 2¹⁶/2¹⁰ = 2⁶ = |disc U(2)³|` (`kummer_betti`).

**The micro part has no hidden roots (Tier A, `kummer_roots`).** For every integer vector `c` with `c mod 2` in the code,
`Σ c_a² = 4` forces `c = ±2e_a`: the `(−2)`-classes of `Π` are exactly the 32 vectors `±E_a`, root system `A₁¹⁶` — the
16 vanishing cycles and nothing else. (A proof over all of `ℤ¹⁶`, using that code words have weight 0, 8 or 16.)

**The split is the octad split (Tier A, `golay_code`, `octad_is_kummer`).** The extended Golay code built from the
quadratic residues mod 23 has 4096 words with weights `1, 759, 2576, 759, 1`. For the octad `{0, 2, 5, 8, 9, 10, 11,
12}`, exactly 32 Golay words avoid it, and an explicit bijection of the 16 complement positions with `𝔽₂⁴` carries them
**exactly** onto the Kummer glue code. So E3's "`8` inherited from the torus + `16` vanishing cycles" is the
octad/complement split of the code whose automorphism group is `M₂₄`. TW (Prop. 2.3.4, ll. 660–705) is the
lattice-level statement: in the Niemeier lattice `N(A₁²⁴)`, orthogonal to an octad's roots sits `Π(−1)`, and `N(A₁²⁴)`
is the only Niemeier lattice containing the Kummer lattice (Nikulin, ll. 672–675). The stabilizer of the octad in `M₂₄`,
`(ℤ₂)⁴ ⋊ A₈`, acts on the complement as the affine group `Aff(𝔽₂⁴)` of the hypercube (TW ll. 1603–1606) — the
symmetry of our `𝔽₂⁴` picture; TW's overarching group `(ℤ₂)⁴ ⋊ A₇` (order 40320, a maximal subgroup of `M₂₃`),
generated by the symplectic automorphisms of Kummer surfaces along a path in moduli space, contains all symplectic
automorphism groups of Kummer surfaces preserving the induced Kähler class (abstract ll. 24–40; ll. 94–97). Tier L,
not formalized.

**E2 ∩ E3 (Tier L).** The K3 selected in E2, `X₃` with `T(X₃) = A₂` (form `(1,1,1)`), is by Shioda–Inose a double
cover of the Kummer surface of `E₁ × E₂` with `τ₁ = (−1 + √−3)/2 = ω`, `τ₂ = (1 + √−3)/2 = ω + 1` (Huybrechts Remark
3.22, ll. 13684–13687), and `ω + 1 ≅ ω` under `SL(2, ℤ)`, so `E₂ ≅ E₁ = E_ω`: the two experiments land on the same
value of `τ`. The tori are distinct objects — the compactification factor `T²` (E2) and the abelian surface underlying
the Shioda–Inose cover (E3); only their complex structure coincides. On the same ray the Kummer K3 itself is the
attractive surface with `T = A₂(2)` (Kummer iff `T = T'(2)`, Huybrechts Remark 3.24 and ll. 13643–13644), form `(2,2,2)`,
`D = 12` — `first_kummer_attractive`.

**Reading (Tier C).** The "macro 8" carries the torus and its T-duality lattice (`U(2)³`, the programme's `O(d,d;ℤ)`
with doubled form), the "micro 16" the vanishing cycles, and the division line between them is a Golay octad: the
macro/micro split of the dual-scale picture is the one `M₂₄` itself singles out. **What E3 does not settle.** (i) The
`M₂₄` and `(ℤ₂)⁴ ⋊ A₇` actions and the embedding into `H*(X, ℤ)` are not formalized. (ii) Nothing here selects a point
of moduli space beyond E2 — E3 is structural, not dynamical. (iii) Observables: none (`N = 4`, non-chiral). Next:
P8.5 (E4) — check that the elements of `(ℤ₂)⁴ ⋊ A₇` have twined genera among the 26 computed in Stream 4 (their `M₂₄`
classes are in TW), and P8.4c (maximal enhancement of the K3 factor).

## 7. E4 — results (`v3.22.0`, `DualScaleDyons/ForgerE4.lean`)

**The geometric classes, from the moonshine side (Tier A + Tier L).** A symplectic automorphism of order `n` of a
K3 has `24/(n∏_{p|n}(1+1/p))` fixed points and `n ≤ 8` (Huybrechts Cor. 15.1.5, 15.1.8, ll. 14030–14135). A finite
group acts symplectically on some K3 iff it embeds in `M₂₃` with at least five orbits on 24 points (Mukai, Thm.
15.3.1, ll. 14545–14556). Read on the 26 Frame shapes (`mukai_classes`), the criterion picks out exactly `1A, 2A,
3A, 4B, 5A, 6A, 7A, 7B, 8A`. On these, `χ_g = Z_g(τ, 0)` from Stream 4's twined genera (`twined_genus_z0`)
reproduces Nikulin's numbers 8, 6, 4, 4, 2, 3, 2 (`nikulin_from_moonshine`). The moonshine data know the fixed-point
geometry of K3 symmetries.

**The symmetries of the E3 structure (Tier A + computation).** The stabilizer, inside `M₂₃`, of an octad through the
fixed point is Taormina–Wendland's overarching group `(ℤ₂)⁴ ⋊ A₇` (TW ll. 2084–2090, 2491–2507). Ours is conjugate to theirs in `M₂₄`, because `M₂₄ = Aut(Golay)` is 5-transitive (Huybrechts ll. 14623–14633) and hence transitive on (octad, point) pairs. Conjugate groups have the same classes. A Frame shape fixes the class except within the five pairs `7A/B, 14A/B, 15A/B, 21A/B, 23A/B` (`frame_classes_up_to_pairs`).
- The half-period translations are explicit Golay automorphisms of class `2A` (`kummer_translations`). They fix the
  octad pointwise, act as `x ↦ x + eᵢ` on `𝔽₂⁴`, and have 8 fixed points, as a Nikulin involution must.
- `tw_generators` gives two more generators. `tools/e4_octad_census.py` computes the group's order, 40320, and its
  classes:
  - 34560 elements in Mukai's classes.
  - 5760 elements of order 14 (`1·2·7·14`, four orbits).
- `order14_not_geometric` exhibits one of these order-14 elements explicitly. By Mukai, no single K3 has it as a
  symplectic automorphism, although its twined genus is one of the 26 (`14A` or `14B`; the Frame shape does not
  decide which).

**Reading (Tier C).**
- The Kummer symmetries pass the forger's test that the 27720 lock failed. Every element is a genuine `M₂₄` element
  with a computed twined genus, and on the geometric classes the genus gives the right fixed points.
- The group is larger than any single K3 allows. Its order-14 elements act on the family of Kummer surfaces, not on
  one surface, in line with TW's reading that `M₂₄` symmetry is a symmetry of the moduli space rather than of a point
  in it.
- For "which K3?" this weakens E2's selection. The moonshine symmetry does not single out one K3; it lives on paths
  through moduli space.

**E4 on the E2 candidate: done in §10.** TW's worked examples, the square and tetrahedral Kummer surfaces, have
`T = diag(4, 4)`, `D = 16`, on the `τ = i` ray (TW (3.3), ll. 1044–1055). Their `ℤ₃`-symmetric torus `T(3)` (§5,
ll. 2716–2742) has `T(A) = diag(2, 2)` as well (`tools/e4_omega_kummer.py`), so the `τ = ω` Kummer surface
(`T = A₂(2)`, `D = 12`) is not among TW's examples. §10 determines its group.

## 8. A constraint from Henningson–Moore (hep-th/9608145, Tier L)

For the heterotic string on K3 × T², the four orbifold K3s `T⁴/ℤ_n` (`n = 2, 3, 4, 6`, ll. 189–195) "only differ by
being at different points in the moduli space of the K3-surface". Those moduli sit in hypermultiplets, which "do not
mix with the vector multiplet moduli", so the one-loop threshold corrections do not depend on `n` (ll. 1371–1375).
**Consequence for Stream 8:** no coupling of the vector-multiplet sector can choose the K3. E2's `T²` selection and
the K3 choice (P8.4c) are separate problems, and the `A₂ = T(X₃)` match of §5 gets no support from this side; it
stays Tier C. The one K3-selecting handle is the Wilson line of the gauge factor that exists only in the orbifold
limit (`SU(2)` for `n = 2`, `U(1)` for `n = 3, 4, 6`, ll. 1359–1367). Turning it on "freez[es] the hypermultiplet
moduli at that particular point" (ll. 1376–1379). In type II language, orbifold CFT points carry `B = ½` and no gauge
enhancement (Aspinwall ll. 2530–2545: enhancement needs `B = 0` along the vanishing cycle, CFT orbifolds give `B = ½`, ll. 2540–2544). P8.4c must therefore state its duality frame. Possible Tier A targets: the 240
`E₈` roots with the split `1 + 56 + 126 + 56 + 1` along a root (ll. 1510–1519), and the crystallographic list
`n ∈ {1, 2, 3, 4, 6}` (`φ(n) ≤ 2`).


## 9. Thought experiments in Einstein's manner (2026-09-19; Tier C unless marked)

The method: take a principle that already worked once, apply it somewhere new, look for the paradox, then resolve
it. Each experiment is tied to a check.

**G1 — The duality elevator (principle of scale equivalence).** An observer inside a circle cannot tell `R` from
`α'/R`. The spectrum is identical, and only at `R = √α'` do extra massless states appear. Einstein turned an
indistinguishability (acceleration vs gravity) into a principle. The analogue here: *only duality invariants are
physical*. So "which K3?" must be answered by an invariant (a discriminant `D`, a class, an enhanced symmetry
point), never by coordinates. This rules out selection principles that are not duality-invariant. Trapping at ESPs
passes the test. *Target (Tier A arithmetic, ADE list Tier L):* the maximum number of roots of a simply-laced root
system of rank `d` is `2, 6, 12, 24, 40, 72, 126, 240` for `d = 1 … 8`, attained by `A₁, A₂, A₃, D₄, D₅, E₆, E₇, E₈`.

**G2 — Trapping in four dimensions (computed).** Apply E2's principle to the `T⁴` inside a Kummer K3. The ESP with the
most light states in rank 4 is `D₄`, with 24 roots.
- *Paradox:* TW's "tetrahedral" Kummer surface over the `D₄` torus has the complex structure of the square one,
  `T = diag(4,4)`, `D = 16`, the `τ = i` ray (TW ll. 1961–1970). The `T²` of E2, by contrast, sits at `ω`.
- *Resolution (computation, `tools/gedanken_d4_torus.py`, exact arithmetic, not kernel-checked):* the `D₄` lattice is
  the Hurwitz order, which contains both `i` and `ω = (−1+i+j+k)/2`, so it carries both complex structures.

| Torus lattice | Complex structure | `T(A)` | Kummer `T = T(A)(2)` | `D` |
|---|---|---|---|---|
| `ℤ⁴` | `i` | `diag(2,2)` | `diag(4,4)` (TW (3.3), sanity check) | 16 |
| `ℤ⁴` | `ω` | `A₂(2)` | `A₂(4)` | 48 |
| `D₄` | `i` | `diag(2,2)` | `diag(4,4)` (TW, sanity check) | 16 |
| `D₄` | `ω` | `A₂` | `A₂(2)` | **12** |

- With the `ω` structure, the torus selected by trapping in 4 dimensions has `T(A) = A₂ = T(X₃)`. Its Kummer surface
  is exactly the E2 ∩ E3 candidate (`D = 12`, `first_kummer_attractive`). The paradox dissolves into agreement, but
  one choice remains open: trapping does not choose between `i` and `ω` on `D₄` (a hyperkähler rotation).
  Consistency with the `T²` factor picks `ω`, and that consistency is an assumption.
- *Caveats:* the ESP carries a `B`-field; orbifold CFT points have `B = ½` and no type II enhancement (Aspinwall
  ll. 2540–2544); vector-multiplet couplings are blind to the K3 point (Henningson–Moore, §8).
- **Done, Tier A (`v3.23.0`, `DualScaleDyons/KummerD4.lean`):**
  - `trapping_rank_table`: `D₄` is the unique rank-4 maximum.
  - `hurwitz_units`: the Hurwitz lattice has 24 units.
  - `omega_symmetry`: `ω` is an order-3 lattice symmetry commuting with `u`.
  - `sigma_plane`: the holomorphic plane is orthogonal to the Kähler direction in `Σ`.
  - `transcendental_omega` and `transcendental_omega_saturated`: `T(A) = ℤt₁ ⊕ ℤt₂ ≅ A₂`, proved for every
    integral 2-form in the plane.
  - `kummer_d4_omega`: `A₂(2)`, `D = −12`.
  - `sanity_standard_structure`: reproduces TW's `diag(4,4)` for `ℤ⁴` and `D₄` with `u = i`.
  - Remaining Tier L inputs: the hyperkähler `S²` and the `Σ = Ω ⊕ J` split (Aspinwall ll. 474–482, 864–874),
    and GPR's maximal enhancement (ll. 1843–1847).

**G3 — The smallest black hole.** Drop dyons of ever smaller charge into K3 × T². The horizon area grows like `√|D|`
(Moore ll. 1150–1160), and `|D| ≥ 3` for every definite binary form, with equality only for the class `(1,1,1)`
(`WhichK3.most_attractive`). So the smallest black hole with a horizon forces its near-horizon K3 to be `X₃`, the
`ω` point again. *Lesson:* like the metric in general relativity, the K3 is local (attractor values vary from black
hole to black hole). "Which K3?" is relational: the minimal black hole gives a canonical answer for black holes, not
for the vacuum (E1's limit stands). **Done (P8.2, §11):** the charges are explicit, the attractor also puts the `T²`
at `τ = ω`, and this black hole carries 25353 single-centred states.

**G4 — The twined light clock.** Einstein's light clock measures time in a moving frame. The twined genus `Z_g(τ, z)`
is a clock carried by an observer who applies a symmetry `g` before counting states. At `z = 0` it reads `χ_g`. E4
showed that for geometric `g` the reading is Nikulin's fixed-point number. The order-14 clock ticks too, though no
single K3 carries that symmetry. *Lesson (Mach's principle for K3):* part of the moonshine symmetry belongs to the
space of K3s (paths in moduli, TW), not to one surface. So a selection principle based on moonshine symmetry alone
cannot pick a point. *Target:* identify the Kummer surfaces whose symplectic groups generate an order-14 element
along a path (TW §4).

**G6 — Why one question answers and the other does not (2026-09-20; `v3.40.0`,
`DualScaleDyons/DefiniteAndIndefinite.lean`).** Two questions in this programme are posed in the same language
and behave in opposite ways. *Which surface does the smallest black hole pick?* has one answer (G3). *How many
flux configurations does the budget permit?* has infinitely many, and keeps having infinitely many after the
orbifold projection and under every quantisation factor (`docs/STREAM9_ORIENTIFOLD.md` §6–§6c). Both are
questions about integer vectors in a lattice. Why does one decide?

- *The tempting answer is wrong.* "The black hole problem has more structure" — no. **The very lattice in which
  the black hole charges live already contains infinitely many vectors of the same norm.** In `U ⊕ U` the family
  `v(n) = (n, 1, 1 − n, 1)` has norm exactly `2` for every integer `n`, injectively
  (`roots_norm_two`, `roots_injective`, Tier A). The charge lattice is indefinite (`ambient_is_indefinite`), and
  it has as little determinacy as the flux lattice does.
- *Resolution.* **Definiteness is not a property of the ambient lattice; it is a condition the physics imposes on
  the object being counted.** A black hole with a horizon requires its charge *form* `Q_{p,q}` to be positive
  definite (Moore (3.4)–(3.5), Tier L), and a definite form has a floor — `D ≤ −3`
  (`definite_pair_has_a_floor`, Tier A). The flux problem imposes no such condition, until supersymmetry does
  through imaginary self-duality, which is exactly where §6d of Stream 9 finds its finiteness.
- *Lesson (Tier C).* "How many vacua?" is not a hard question waiting to be cracked. It is a question whose
  arithmetic **cannot** have a finite answer until something makes the relevant form definite. Stated once:
  arithmetic decides when, and only when, the physics hands it a definite form. That also predicts where to look
  next for determinacy anywhere in this programme: find the definiteness condition, or expect none.
- *What it does not say.* That every selection question here is of one of these two types; and nothing about
  vacua.

**G7 — The grid that measures itself (2026-09-20; Tier C, target stated, not yet formalized).** Einstein's method
insists that a measurement distinguish its object from its instrument — clocks and rods enter the theory, they are
not outside it. Apply that to the one empirical datum bearing on the vortex-core pivot.

- *The datum.* An external group measured a floor on the separation between distinct vortex lines in a simulated
  superfluid tangle: `F = 0.943 ξ`, at `6.1×` the null's 95th percentile, by a threshold-free method
  (`docs/reviews/2026-09-19_quantumfluids_dual_scale_report.md`).
- *The paradox, found by re-analysing their own results file for paper 12.* With their `ξ = 1.5 Δx`, the value
  `F = 0.943 ξ` is `1.4142135623730903 Δx`, which agrees with `√2` to **fourteen significant figures**; and the
  ten smallest inter-line distances in that file are **bit-identical**. Either the healing length happens to equal
  the face diagonal of the simulation grid — absurd, since `ξ` was *set* to `1.5 Δx` by convention — or the
  measurement is reading the instrument.
- *Resolution.* The traced lines live on face centres of the grid, so inter-line distances are quantised on a
  sub-lattice. The minimum of a quantised set is a lattice distance whatever the physics does. A floor can only be
  *measured* when the physical scale stands well above the instrument's quantum — which is why the authors
  themselves require `ξ/Δx ≳ 5`, and why their split verdict is the honest one.
- *Lesson (Tier C, and general).* Any "minimum separation" statistic computed on a discretised field measures
  `max(physical floor, instrument quantum)`. The instrument quantum must be reported beside the result, always.
  A degenerate minimum — the same value attained many times to the last bit — is the tell.
- *The arithmetic, checked.* Face centres of a cubic grid of spacing `Δ` come in three families,
  `(i+½, j, k)`, `(i, j+½, k)`, `(i, j, k+½)`. Their squared separations are **exactly the positive half-integer
  multiples of `Δ²`**: `½, 1, 3/2, 2, 5/2, …`. The smallest is `Δ²/2`, i.e. `Δ/√2 ≈ 0.707 Δ` — the value the
  authors quote as what discretisation alone permits — and `2Δ²`, i.e. the measured `√2 Δ`, is a member. So the
  reported floor is a lattice distance, the fourth one up. (First written here as "multiples of `Δ²/4`"; the
  enumeration says `Δ²/2`, and the sentence was corrected rather than left. G7 applied to G7.)
- *Target (Tier A, small).* Formalize that enumeration in doubled integer coordinates, where the squared
  separations become the positive even integers, the minimum is `2` and the measured value `8` occurs. That turns
  "this is a lattice constant" from a numerical coincidence into a statement.

**Synthesis.** Three independent routes point to `ω`: `T²` trapping (E2), `T⁴` trapping with the `ω` complex
structure (G2), and the smallest black hole (G3). Three counterweights: the choice of complex structure on `D₄`
(G2), which symplectic symmetry does not break and non-symplectic symmetry breaks towards `i` (§10); the blindness
of couplings to the K3 point (§8); and moonshine symmetry living on moduli space (G4, §10). No observable follows
(`N = 4`). Anything that becomes a prediction would be frozen first (paper 11 protocol).

## 10. E4 on the `D = 12` Kummer surface (`v3.24.0`, `DualScaleDyons/KummerOmegaE4.lean`)

**The question.** G2 realised the E2 ∩ E3 candidate (`T = A₂(2)`, `D = 12`) as the Kummer surface of the `D₄` torus
with the complex structure `u = (i+j+k)/√3`. What is its symmetry group, and does it pass the forger's test?

**The group (Tier A + Tier L).**
- `right_units_fix_sigma`: right multiplication by each of the 24 Hurwitz units (`units_complete`) maps `D₄` into
  itself (onto, since right multiplication by `b̄` inverts it) and fixes the three Kähler forms `ω_I, ω_J, ω_K`,
  hence the whole positive 3-plane `Σ`, including
  `T(A) = ℤt₁ ⊕ ℤt₂`. So it is holomorphic, symplectic and Kähler for **every** complex structure on the twistor
  sphere, `u = i` and `u = ω` alike. That these 24 exist at `ω` is forced by construction.
- `holomorphic_isometries` makes the result exact. An exhaustive search over all `ℂ_u`-linear lattice isometries
  (576 candidates, via a `ℤ[w]`-basis of `D₄`) finds:

| Complex structure | Holomorphic isometries fixing 0 | Symplectic | Order on `H^{2,0}` |
|---|---|---|---|
| `u = i` (TW tetrahedral, `D = 16`) | 96 | 24 | 1 (24), 2 (24), 4 (48) |
| `u = ω` (E2 ∩ E3, `D = 12`) | 72 | 24 | 1 (24), 3 (48) |

  The symplectic part is exactly the binary tetrahedral group (order 24, Fujiki's maximum; TW Prop. 4.2.2,
  ll. 1899–1904). By TW Prop. 3.3.4 (ll. 1396–1407), the Kummer surface with the induced Kähler class has
  `G = (ℤ₂)⁴ ⋊ A₄ = T₁₉₂`, the same abstract group as TW's tetrahedral Kummer surface.

**The forger's test (Tier A, `kummer_group_frames`).** The 192 elements `x ↦ x b + t/2` act on
`H²(Km A, ℚ) = π_*H²(A) ⊕ ℚ¹⁶` as 192 distinct automorphisms. Their Frame shapes are read off from the Lefschetz
numbers of their powers (Möbius inversion):

| Frame shape | `1²⁴` | `1⁸2⁸` | `1⁶3⁶` | `1⁴2²4⁴` |
|---|---|---|---|---|
| Class | 1A | 2A | 3A | 4B |
| Elements | 1 | 27 | 128 | 36 |

All four are among Mukai's geometric classes (`ForgerE4.mukai_classes`), and their fixed points `24, 8, 6, 4` are
Nikulin's numbers. The surface passes the forger's test. The Frame shapes are distinct from one another and
outside the five `A/B` pairs, so they fix the classes (`frame_classes_up_to_pairs`). Negative control: three
mutations were each caught (left instead of right multiplication, a wrong holomorphic count, and dropping the
translation part).

**Reading (Tier C).**
- *The group does not select the point.* `T₁₉₂` acts in the same way on `H*` for every complex structure on the
  `D₄` twistor sphere. Symplectic symmetry therefore does not choose between the `i` Kummer (`D = 16`) and the `ω`
  Kummer (`D = 12`), so G2's open choice stays open. This is G4's lesson again: the symmetry belongs to a family
  (here the twistor line), not to a point.
- *Non-symplectic symmetry points the other way.* At `u = i` the torus has an automorphism acting on `H^{2,0}` with
  order 4. At `u = ω` the largest order is 3. A "maximal symmetry" principle would pick `i`, not `ω`. This is a
  counterweight to the synthesis of §9, recorded as found.
- *What trapping selects: the polarization.* `D₄` enters through the Narain metric (24 light vectors), i.e. through
  the Kähler class, not the complex structure. For attractive abelian surfaces `T(A)` fixes `A` up to isomorphism
  (Shioda–Mitani, via Moore ll. 1503–1507), so the `ω` torus is `E_ω × E_ω` whichever lattice one starts from.
  The polarization is what carries the symmetry: TW's `X₀` (square torus) and `X_{D₄}` have the **same** complex
  structure (TW ll. 1966–1970) but symmetry groups `T₆₄` and `T₁₉₂` (TW l. 114). Trapping acts on exactly this
  datum, so G2 is not weakened; its lever is the Kähler class, not the complex torus.

**Not settled.** (i) The realisation of this `T₁₉₂` inside `M₂₄` through TW's map `Θ` (TW realise `T₁₉₂` only at
`D = 16`; at `ℤ₃`-symmetric points they expect `M₂₄` rather than `M₂₃`, ll. 2735–2742). (ii) Symmetries that do not
preserve the induced Kähler class (the full automorphism group is infinite, TW footnote 13). (iii) Observables:
none (`N = 4`).

## 11. P8.2 — explicit charges and the smallest black hole (`v3.25.0`, `DualScaleDyons/AttractorCharges.lean`)

**Charges to forms (Tier A + Tier L).** Moore (3.4)–(3.5) (ll. 1104–1116) attaches to a charge pair `(p, q)` the form
`Q_{p,q}` with `D = (p·q)² − p²q²`. For primitive `L_{p,q}`, U-duality classes are `SL(2, ℤ)` classes of forms
((3.11), l. 1189, via Nikulin), and `N(D) = Σ_m h(D/m²)` counts all form classes ((3.18), ll. 1254–1257).
- `every_form_is_charged`: for **every** `(a, b, c)`, the charges `p = e₁ + a f₁`, `q = e₂ + b f₁ + c f₂` in
  `U ⊕ U ⊂ H²(K3, ℤ)` have Gram `[[2a, b], [b, 2c]]` and span a primitive sublattice. This proves Moore's claim that
  every form, imprimitive ones included, is realised.
- `charge_classes_small`: an independent enumeration (all pairs in `{−1, 0, 1}⁴`, primitive, positive definite,
  Gauss-reduced) returns only reduced forms of the right discriminant, all of them for `D = 3, 4, 7`, and the
  minimum `|D|` is 3. `tools/p82_charge_enumeration.py` (box `[−2, 2]⁴`, not kernel) finds all classes for
  `D = 3, 4, 7, 8, 11, 12, 15, 16, 20, 23, 24` and no wrong one. Classes that need larger entries (the first is
  `(1, 1, 5)`, `D = 19`) lie outside that box; `every_form_is_charged` covers them all.

**The smallest black hole (Tier A).**
- `discriminant_gap`: a positive definite form has `4ac − b² ≥ 3`, and `3` needs odd `b`.
- `smallest_black_hole`: `p² = q² = 2`, `p·q = 1`, `T_S = A₂ = T(X₃)`, `D = −3`, class `(1, 1, 1)`.
- `attractor_tau`: for every charge with `D < 0`, `τ(p, q) = (p·q + i√−D)/p²` solves Moore (4.5) (l. 1370) with
  `Im τ > 0`. `tau_minimal`: for the smallest black hole `τ = (1 + i√3)/2 = ω + 1`, so `E_τ ≅ E_ω`; for `D = −4`,
  `τ = i`.
- `smallest_black_hole_index`: from Stream 5's `∆ψ₁^F = 3E₄A − 648H` and `1/η²⁴`, the coefficient of `ψ₁^F` at
  `(n, ℓ, m) = (1, 1, 1)` is **25353**, and at `(1, 0, 1)` (`D = −4`) it is **−50064**. DMZ read these coefficients
  as single-centred counts ((1.6), ll. 426–443). External anchor: Sen (`0708_1270.txt`, l. 6788) prints
  `d = 50064` for `Q² = P² = 2`, `Q·P = 0`, which matches the second value and fixes the sign convention
  `d = (−1)^{ℓ+1} c`. In that convention the smallest black hole has `d = 25353` (Sen's table does not list it).

**The chain (Tier L links, Tier A pieces).** The smallest black hole has attractor variety `X₃ × E_ω`
(Moore (4.27), l. 1585). `X₃` is the Shioda–Inose double cover of `Km(E_ω × E_{ω+1}) = Km(E_ω × E_ω)`
((4.15), (4.29)). By Shioda–Mitani (Moore ll. 1503–1507), `E_ω × E_ω` is the `D₄` torus with the `ω` structure
(`T(A) = A₂`, `KummerD4`). So its Kummer surface is the `D = 12` surface of §10. G3's minimal black hole, G2's
trapped torus, E2's `T²` and §10's `T₁₉₂` surface are one geometry.

**Reading (Tier C).**
- *For black holes, the tie is broken.* The smallest horizon selects `ω` for both the K3 (`X₃`) and the `T²`
  complex structure; `i` comes next (`D = −4`). This is the tie-breaker that G2 and §10 lacked. It holds only
  near a horizon.
- *Not for the vacuum.* The attractor fixes the near-horizon moduli of one black hole. It leaves the asymptotic
  moduli free, and even at the horizon it leaves 88 directions free (Moore (4.3), ll. 1351–1353), including the
  `T²` Kähler modulus that E2's trapping fixes at `ρ = ω`. E1's limit stands.
- *The self-dual point is where the counts differ.* `D = 3` is exactly where `N(D)` and `12H(D)` disagree
  (`moore_vs_hurwitz`). The `−648 H(3) = −216` part of `C(3) = 528` is the `1/3` weight of the `ω` point.
- Observables: none (`N = 4`). Negative control: three mutations caught (a wrong index value, no `SL(2, ℤ)`
  reduction, a wrong sign in the pairing).

## 12. P8.4c — trapping on the K3 factor (`v3.26.0`, `DualScaleDyons/K3Enhancement*.lean`)

**The rule (Tier L).**
- Aspinwall (95), ll. 2464–2485: for IIA on K3 (dual to heterotic on `T⁴`), the non-abelian gauge roots are the
  vectors `α ∈ Γ₄,₂₀ ∩ Π^⊥` with `α² = −2`; the group is ADE.
- Aspinwall ll. 2856–2858: the same rule holds in four dimensions for a positive 6-plane in `Γ₆,₂₂`.
- Trapping selects the point with the most roots (§5). The duality frame is the one §8 asked for: IIA on K3,
  i.e. heterotic on `T⁴`, where the enhancement needs `B = 0` along the vanishing cycles.

**The maximum (Tier A).**
- `trapping_rank_table_22`: in rank 20 the largest root system is `D₂₀` alone (760 roots). `A₂₀` has 420, and any
  split has at most 686. In rank 22 it is `D₂₂` alone (924).
- `gamma4_unimodular`: an explicit even unimodular lattice of signature `(4, 20)` (so `Γ₄,₂₀`, by Milnor,
  Huybrechts ll. 12906–12910), with Gram determinant 1 computed by fraction-free elimination.
- `so40_point` (own file: the kernel needs 11 GB): with `Π` the first four coordinates, the 760 roots `±eᵢ ± eⱼ` of `D₂₀` are in the lattice
  (each written as an integer combination of basis vectors), orthogonal to `Π`, of norm `−2`. That the 760 are
  pairwise distinct is by construction, one per `(i < j, signs)`; a kernel `Nodup` was tried and needs more than 14 GB. With the rank table and the ADE rule (Aspinwall l. 2484), the gauge group is
  exactly `SO(40)`, the largest possible for the K3 factor. By `uniform_parity`, `Π^⊥ ∩ Γ = D₂₀(−1)`, and
  `Π ∩ Γ ⊇ D₄` (equal: standard, both have a discriminant group of order 4 in a unimodular lattice).
- `gamma6_unimodular`, `so44_point` (own file, 14 GB): for K3 × T² as a whole (`Γ₆,₂₂`), the maximum is `SO(44)` (924 roots), with
  `Π ∩ Γ = D₆`.
- `product_points_not_maximal`: if the 6-plane splits as `Π₄ ⊕ Π₂` along `Γ₄,₂₀ ⊕ Γ₂,₂`, there are at most
  `760 + 6 = 766 < 924` roots. The arithmetic is kernel-checked. That roots cannot mix is a short argument: the two
  components have even norms `≤ 0` adding to `−2`, so one of them vanishes.
- `agrees_with_rank8_table`: on ranks `≤ 8` the table agrees with G2's `KummerD4.bestTable`.

**Reading (Tier C).**
- *The K3 factor lands on `D₄` again, but for a generic reason.* At the `SO(40)` point the positive 4-plane is
  spanned by the Hurwitz lattice `D₄`, the lattice of G2's trapped torus. Its 24 norm-2 vectors are states of the
  other chirality, which the heterotic GSO projection removes (Aspinwall ll. 2455–2462), like E2's second
  `SU(3)`. And the discriminant forms of `D_{16+d}` and `D_d` agree, so `D_{16+d} ⊕ D_d` glues to `Γ_{d,16+d}` for
  every `d`; `d = 4` is one case. The recurrence of `D₄` carries little independent weight.
- *Chirality convention.* E2 counted `6 + 6` (`SU(3)_L × SU(3)_R`, both chiralities, GPR's convention). In the
  heterotic/IIA frame of this section only one side gives gauge bosons, so a `T²` at `(ω, ω)` contributes 6 roots,
  the number used in `product_points_not_maximal`. E2's conclusion survives (6 > 4, `(ω, ω)` over `(i, i)`), with the
  count halved.
- *Trapping and moonshine select disjoint loci.* At the `SO(40)` point the sigma model is singular (GHV ll. 370–386:
  D-branes become massless), and the K3 is very small and singular (rank 20 > 19; Aspinwall ll. 2551–2559). E4's
  forger test and the symmetry groups `G_Π ⊂ Co₀` apply only at points without roots. The two principles of
  Stream 8, "most light states" and "most (moonshine) symmetry", therefore point to different places.
- *Factor-wise trapping is not global trapping.* E2 (`T²` at `(ω, ω)`), G2 and the K3 factor were each maximised
  separately. On the full K3 × T² moduli space the maximum is `SO(44)`, which does not split into a K3 point and a
  `T²` point, and its 6-plane lattice is `D₆`, not a lattice built from `A₂`. Also, in IIA the `T²` area modulus is
  the heterotic axion-dilaton (Aspinwall ll. 2838–2845) and carries no gauge roots, so E2's `ρ = ω` is not a
  trapping statement in this frame.
- *What survives.* The `ω` convergence of §9–§11 stands **for black holes** (G3/P8.2, the attractor mechanism). As a
  selection principle for the vacuum, trapping chooses `SO(44)`, not `ω`. This is recorded as a negative result for
  the "maximal self-duality selects `X₃ × E_ω`" reading of E2.
- Negative control: five mutations caught (a basis without the half-integer glue vector, roots shifted into `Π`, a
  wrong `E₈` root count in the table, and, after the certificate rewrite, a wrong sign in a certificate and a shifted
  root block).

## 13. Open question 2 — the `6`/`8` correction is an orbifold weight (`v3.27.0`, `DualScaleDyons/FormAutomorphs.lean`)

**The question.** `moore_vs_hurwitz` (§1) gave `12·N(D) = 12·H(D) + 6·[D = 4f²] + 8·[D = 3f²]`. Moore's count of
attractor backgrounds and the class-number coefficient of the immortal index differ only on the rays of `τ = i` and
`τ = ω`. What is the difference?

**The answer (Tier A).**
- `reduced_value_bound`, `automorph_bound`: an automorph `(p, q; r, s)` of a reduced form has `|p|, |r| ≤ 1` and
  `a(q² + s²) ≤ 2c`.
- `automorphs_complete`: every determinant-1 automorph lies in the finite list `autList`, so counting the list
  counts the whole group.
- `automorph_table`: for every reduced form with `3 ≤ D ≤ 100`, `|Aut(Q)| = 6` for `a(1, 1, 1)`, `4` for
  `a(1, 0, 1)`, and `2` otherwise.
- `mass_formula`: for `3 ≤ D ≤ 100`, `12·H(D) = Σ_Q 24/|Aut(Q)|`.

So `N` counts each class once, and `H` counts it with weight `2/|Aut(Q)|`, i.e. `1/|PSL(2, ℤ)` stabiliser of `τ_Q|`.
The two self-dual rays are exactly the orbifold points of `SL(2, ℤ)\ℍ`: weight `1/2` at `i`, `1/3` at `ω`.

**Reading (Tier C).** The immortal index counts attractor backgrounds as points of the orbifold `SL(2, ℤ)\ℍ`, with
their orbifold weights; Moore's `N` counts points of the coarse moduli space. The smallest black hole (§11) sits
at the order-6 point, and the `−648 H(3) = −216` part of its coefficient `C(3) = 528` is that orbifold weight. This
is a consequence of G1 (only duality invariants are physical): the index sees the self-dual points as orbifold
points, not as ordinary ones. Why the index is orbifold-weighted (the mock modularity of `ψ₁^F`, DMZ) is Tier L
and is not formalized.

**Scope.** Checked for `D ≤ 100` (the completeness bound is general; the table is finite). Negative control: two
mutations caught (dropping the cross-term condition, a wrong order at `a(1, 1, 1)`).

## 14. G5 — the maximal-symmetry principle: the GTVW model (`v3.29.0`, `DualScaleDyons/GTVWPoint.lean`)

**The thought experiment.** Trapping (§12) chose singular points, where the sigma model is not defined. Ask
instead for the most symmetric *non-singular* K3 model, the vacuum a "symmetry-maximising" universe would pick.

**The literature (Tier L).**
- GHV list the possible symmetry groups of non-singular K3 models (1106.4315 ll. 144–159). GTVW (1309.4127,
  abstract, ll. 138–149, 1509–1514) realise the group `ℤ₂⁸ : M₂₀`: it is maximal (no larger symmetry group contains
  it) and "one of the largest".
- The model is the `ℤ₂` orbifold of the `D₄`-torus theory at its `so(8)₁` point, geometrically a sigma model on the
  tetrahedral Kummer surface.
- Harvey–Moore (2003.13700 ll. 735–742): the target torus is the Spin(8) maximal torus, and the model is
  equivalently six circles at the **T-duality self-dual radius** `R = 1`.

**The checks (Tier A).**
- `gtvw_so8_point`: GTVW's `B`-field is exactly what the `so(8)₁` enhancement needs. With it, every root `l` gives
  a charge `(m, l) = ((B+1)l, l) ∈ L* ⊕ L`; with `B = 0` the condition fails.
- `gtvw_B_is_I`: the `B`-field is left multiplication by `i`, i.e. the Kähler form `ω_I`.
- `gtvw_complex_structures`: on the same torus, `u = i` gives `T(A) = diag(2, 2)` (the tetrahedral Kummer surface,
  `D = 16`) and `u = (i+j+k)/√3` gives `T(A) = A₂` (the `D = 12` surface of §10 and E2 ∩ E3). Both lattices are
  primitive.
- `gtvw_B_type`: `B` is of type `(1, 1)` for `u = i`. For each of the four `ω`-type structures, its pairings with
  the holomorphic plane are explicitly non-zero (±4, where `ω_I ∧ ω_I = 4`).
- `gtvw_group_orders`: the group orders, `2¹⁴ ∤ |M₂₄|`, `c = 6 = 6 × c(su(2)₁)`, and `A₁⁴ ⊂ D₄`.

**Reading (Tier C).**
- *A vacuum-level convergence for the K3 factor.* The parent theory of the most symmetric known non-singular K3
  model is exactly the enhanced symmetry point that trapping selects on `T⁴` (G2). It is the rank-4 maximum, with
  24 left `so(8)₁` roots (`gtvw_so8_point`), at the self-dual radius (the programme's `κ = 1`, Stream 6).
  - This is not §12's `D₄ = Π ∩ Γ₄,₂₀`. That one concerned roots orthogonal to `Π` in the K3 lattice, a singular
    K3 model, and was an instance of the generic `D_{16+d} ⊕ D_d` pattern.
  - Here the coincidence is at the level of the torus theory, and the `ℤ₂`-orbifold is a well-defined K3 CFT.
  - This is the strongest vacuum-level selection in Stream 8.
- *But the complex structure it favours is `i`, not `ω`.* The complex structure is not a CFT datum: the twistor
  sphere of the `D₄` torus contains both the tetrahedral (`i`) and the `ω` Kummer surfaces, and `T₁₉₂` acts on both
  (§10). The model's `B`-field, however, is the Kähler form of `i` and is of type `(1, 1)` only there. So its natural
  geometric interpretation is the tetrahedral surface (`D = 16`), as GTVW state. This is a second counterweight to
  `ω`, after the non-symplectic symmetry of §10.
- *Updated synthesis.* `ω` is selected for black holes (the smallest horizon, §11). For the vacuum, the K3 factor
  is best described as the GTVW model: the `D₄` torus at the self-dual point, orbifolded. Its geometric reading
  prefers `i`, and none of the principles tried fixes the `T²` factor together with it (§12). "Which K3?" therefore
  has a sharp answer at the level of the CFT (GTVW) and none yet at the level of a single complex structure.
- `ℤ₂⁸ : M₂₀` is maximal and "one of the largest" (GTVW's words); that it is the largest group is not claimed.

### 14.1 The IR/UV obstruction, corrected (`DualScaleDyons/TrappingObstruction.lean`)

A directive proposed formalising "the `SO(44)` root lattice admits no orthogonal decomposition preserving the
signature split `(3,19) ⊕ (2,2)` while keeping `T(A) = A₂`", read as "a factorised static `K3 × T²` vacuum is
mathematically forbidden". **That is false as phrased**, and the file says why:

- `Γ₆,₂₂ ⊃ Γ₄,₂₀ ⊕ Γ₂,₂`, and `D₂₂` embeds in `Γ₆,₂₂` (`so44_point`): nothing forbids the decomposition.
- `uv_charges_in_so44_plane`, `a2_saturated_in_D6`, `a1a1_saturated_in_D6`: the charge lattices of **both**
  smallest black holes — `A₂` (`D = −3`, the `ω` point) and `A₁ ⊕ A₁` (`D = −4`, the `i` point) — embed
  **primitively** in `D₆`, the positive-plane lattice at the `SO(44)` point. The UV attractor charges are
  compatible with the globally trapped 6-plane.
- `obstruction_is_quantitative`: what is true is quantitative — a factorised point carries at most `766` roots
  against `924` at the maximum, so trapping does not *select* a factorised point (§12).

The frustration between the IR trapping point and the UV attractor is therefore real but softer than
"forbidden": what fails is maximality, not existence. A stronger no-go would have to quantify over the signature
split of the 6-plane, and is not proved here.

