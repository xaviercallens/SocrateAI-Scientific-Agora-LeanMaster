# Stream 8 — Which K3? (convergence, thought experiments, open questions)

**Status (2026-09-19, release `v3.24.0`):** six Tier A files (`DualScaleDyons/WhichK3.lean`, 5 theorems;
`DualScaleDyons/SelfDualT2.lean`, 7 theorems — E2, §5; `DualScaleDyons/KummerE3.lean`, 7 theorems — E3, §6;
`DualScaleDyons/ForgerE4.lean`, 6 theorems — E4, §7; `DualScaleDyons/KummerD4.lean`, 8 theorems — G2, §9;
`DualScaleDyons/KummerOmegaE4.lean`, 6 theorems — E4 on the `D = 12` surface, §10); the rest is a research plan.
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
2. **What does the `6`/`8` correction mean?** The immortal index uses `H` (weighted), Moore's count uses `N`
   (unweighted). Why the black-hole index weights self-dual attractor points by their automorphisms is a precise,
   probably known, question — to be checked against DMZ §9–10 and Moore §3 before any claim.
3. **Chirality.** None of this cures `N = 4` non-chirality (Stream 7). A realistic model needs a different
   geometry (K3-fibred CY3; `docs/COMMUNITY_ROADMAP.md` P-1).

## 4. Plan (Stream 8)

| Phase | Content | Tier |
|---|---|---|
| P8.1 | convergence and `N` vs `H` relation, Kummer criterion, Fermat quartic | A — **done** (`WhichK3.lean`) |
| P8.2 | attractor form of explicit charges `(Q, P)` in `Γ_{6,22}`; `N(D)` by enumeration for small `D` | A |
| P8.3 | Kummer lattice from `𝔽₂⁴`: rank 16, discriminant `2⁶`, the `8 + 16` split of 24 | A — **done** (§6, `KummerE3.lean`) |
| P8.4 | E2: derive (or refute) a "maximal self-duality" selection principle; freeze any consequence before testing | C → A — **T² part done** (§5); K3 part open (P8.4c) |
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
have (the kissing number of the plane, standard). So **under trapping, T² comes to rest at `(ω, ω)`**, not `(i, i)`.

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
for the vacuum (E1's limit stands). *Target:* P8.2, explicit charges `(Q, P)` with `Q² = P² = 2`, `Q·P = 1` in
`Γ^{6,22}`.

**G4 — The twined light clock.** Einstein's light clock measures time in a moving frame. The twined genus `Z_g(τ, z)`
is a clock carried by an observer who applies a symmetry `g` before counting states. At `z = 0` it reads `χ_g`. E4
showed that for geometric `g` the reading is Nikulin's fixed-point number. The order-14 clock ticks too, though no
single K3 carries that symmetry. *Lesson (Mach's principle for K3):* part of the moonshine symmetry belongs to the
space of K3s (paths in moduli, TW), not to one surface. So a selection principle based on moonshine symmetry alone
cannot pick a point. *Target:* identify the Kummer surfaces whose symplectic groups generate an order-14 element
along a path (TW §4).

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
  (Shioda–Mitani, standard; not pinned here), so the `ω` torus is `E_ω × E_ω` whichever lattice one starts from.
  The polarization is what carries the symmetry: TW's `X₀` (square torus) and `X_{D₄}` have the **same** complex
  structure (TW ll. 1966–1970) but symmetry groups `T₆₄` and `T₁₉₂` (TW l. 114). Trapping acts on exactly this
  datum, so G2 is not weakened; its lever is the Kähler class, not the complex torus.

**Not settled.** (i) The realisation of this `T₁₉₂` inside `M₂₄` through TW's map `Θ` (TW realise `T₁₉₂` only at
`D = 16`; at `ℤ₃`-symmetric points they expect `M₂₄` rather than `M₂₃`, ll. 2735–2742). (ii) Symmetries that do not
preserve the induced Kähler class (the full automorphism group is infinite, TW footnote 13). (iii) Observables:
none (`N = 4`).
