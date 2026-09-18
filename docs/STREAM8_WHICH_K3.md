# Stream 8 — Which K3? (convergence, thought experiments, open questions)

**Status (2026-09-18, release `v3.19.0`):** two Tier A files (`DualScaleDyons/WhichK3.lean`, 5 theorems;
`DualScaleDyons/SelfDualT2.lean`, 7 theorems — E2, §5); the rest is a research plan. Thought experiments are **Tier C** and each is tied to a formalizable target.

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
| P8.3 | Kummer lattice from `𝔽₂⁴`: rank 16, discriminant `2⁶`, the `8 + 16` split of 24 | A |
| P8.4 | E2: derive (or refute) a "maximal self-duality" selection principle; freeze any consequence before testing | C → A — **T² part done** (§5); K3 part open (P8.4c) |
| P8.5 | E4: symmetry groups of the candidate K3s vs the 26 twined genera | L + A |

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
