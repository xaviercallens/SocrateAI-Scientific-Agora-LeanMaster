# Stream 4 Workflow — Mathieu Moonshine, Computed Rather Than Typed

**Status (2026-09-18, release `v3.9.0`):** P4.1, P4.2, P4.3 (all 21 columns of CDH Table 20, i.e. all
26 conjugacy classes), P4.3b (all classes), P4.4 (arithmetic skeleton of the shadow; mock modularity
itself still Tier L) and P4.5 (all classes) closed; P4.6 open. Library `DualScaleMoonshine` (7 files,
190 declarations, 76 theorems, 0 failing). Rules are those of Stream 2 §2 and Stream 3 §2 (kernel is
the only accept gate; no citation from memory; ASCII identifiers; separate `lean_lib`).

## 1. Why this stream exists

Streams 1–2 checked Mathieu moonshine as **one typed table against another**: `eotA` (the coefficients
`A₁ … A₉` of Eguchi–Ooguri–Tachikawa) against `M24RepDim` (the irreducible dimensions of `M₂₄`). Both
are transcriptions. A transcription matching a transcription is weak evidence — and this project has
already caught one mistyped `M₂₄` table.

Stream 4 replaces the transcriptions by **computations**: the coefficients are computed from a closed
formula for the mock modular form `H⁽²⁾`, the twined coefficients from the formula for `H_g`, and the
group-theoretic traces from the character table. Where two independent computations meet, the
coincidence is checked, not copied.

It also supplies the one test that separates moonshine from numerology — **twining** — and applies it to
this project's own integer coincidences.

## 2. Motivation (Tier C — recorded, not asserted)

The stream was prompted by a discussion of Harvey–Murthy–Nazaroglu (HMN, 1410.6174), who obtain umbral
mock modular forms from BPS counting in double-scaled little string theories. Four thought experiments
shaped the plan; none is a result.

1. **Micro and macro in a mock modular form.** In HMN's setting the non-holomorphic completion of the
   mock modular form comes from a continuum of states escaping to infinity, while the holomorphic part
   counts bound states. For `H⁽²⁾` the *shadow* is `24·η³`, and `24 = χ(K3)`. One can read that 24 as
   what the bound-state (micro) sector owes the continuum (macro) sector for modularity to hold. This is
   a reading, not a theorem, and it is **not** the same thing as this programme's "dual-scale" `R ↔ α'/R`:
   "double scaling" in HMN is a different limit (`g_s → 0` with brane separation, at fixed ratio).
2. **Vanishing cycles.** The double-scaling limit contracts `(−2)`-cycles. Stream 2's
   `Lattice.Reflection` already proves that reflections in `(−2)`-vectors are lattice isometries — the one
   existing formal bridge to HMN's setting.
3. **Symmetry without a location.** No K3 sigma model has `M₂₄` as its symmetry group
   (Gaberdiel–Hohenegger–Volpato, 1106.4315); the symmetry appears only across moduli space. Compare
   T-duality, visible only when `R` and `α'/R` are held together.
4. **The forger's test.** What made monstrous moonshine more than numerology was that the coincidence
   survives twining by every group element. Apply the same test to this project's integers.

## 3. Phases

| Phase | Content | Sources | Status |
|---|---|---|---|
| **P4.1 Pin sources** | HMN 1410.6174; Cheng–Duncan–Harvey (CDH) 1204.2779; Cheng–Harrison (CH) 1406.0619; GHV 1106.4315 | `papers/foundations/MANIFEST.md` | ✅ |
| **P4.2 Compute `H⁽²⁾`** | `(−2E₂ + 48F₂⁽²⁾)/η³` as exact truncated series over ℤ; equals EOT's `A₁ … A₉` (`hComputed_eq_table`); `F₂` transcription check; Jacobi's series checked (not proved) through `q⁹` | CH eq. (3.5)–(3.6) ll. 800–813; HMN eq. (2.37) l. 736; CDH App. A.1 | ✅ `QSeries.lean` |
| **P4.3 Twining** | `H_g = (χ_g/24)H + F_g/η³` computed for `g = 2A, 3A, 5A, 7AB`; equals CDH Table 20 through `q⁹`; divisibility by 24 proved; negative controls | CDH eq. (4.18), Table 3, (A.3), Table 14, Table 20 | ✅ all 21 columns: `2A, 3A, 5A, 7AB` in `Twining.lean`; the other 16 (eta quotients, newforms `f₁₁, f₁₄, f₁₅, f₂₃,ₐ, f₂₃,ᵦ`, prefactors `1/D`) in `TwiningAll.lean` |
| **P4.3b Group side** | Traces of **every** class on EOT's representations (levels 1–7), from CDH Table 8 over `ℤ[b₇], ℤ[b₁₅], ℤ[b₂₃]`, equal the **computed** twined coefficients; transcription guarded by centralizer orders from column norms, the class equation and full row orthogonality | CDH Table 8; EOT (1.14)–(1.15) | ✅ `Characters.lean` (`2A, 3A`), `CharactersAll.lean` (all 26) |
| **P4.4 Shadow** | where the `24` of the shadow `24·η³` comes from: the K3 elliptic genus computed from theta functions has `Z(τ,0) = 24`; its polar/finite decomposition `Ψ₁,₁Z = 24·Av⁽²⁾[(y+1)/(y−1)] + H·θ̂₁` holds with the **computed** `H` and fails for `23`, `25`; the shadow's theta series is `η³`; twined multiplicities `χ_g` are traces on `1 ⊕ 23`. The shadow property itself (completion, modular transformation) stays Tier L | CDH (2.15)–(2.30), (2.49), (2.62), (A.2), Table 14; HMN ll. 246–270 | ✅ `Shadow.lean` (arithmetic skeleton) |
| **P4.5 Forger's test** | does paper 7's "27720 lock" survive twining? **No** — at all 25 non-identity classes | `DualScaleValidation.UseCase2` | ✅ `ForgerTest.lean`, `CharactersAll.lean` |
| P4.6 HMN bridge | relate HMN's double-scaled LST counting to Stream 2's `(−2)`-reflections, or show no such formal relation is available | HMN §2–3 | ⬜ open |

## 4. Results

**P4.2 — computed equals typed.** From the formula, `q^{1/8}H⁽²⁾ = −2 + 90q + 462q² + 1540q³ + 4554q⁴ +
11592q⁵ + 27830q⁶ + 61686q⁷ + 131100q⁸ + 265650q⁹ + …`, i.e. `2A₁ … 2A₉` exactly as tabulated
(`hComputed_eq_table`, Tier A).

**P4.3 — twining, from two sides.** The twined series for `2A`, `3A`, `5A`, `7AB` computed from the
modular formula equal CDH's printed table (Tier A; the printed table is Tier L, so these theorems also
certify our reading of a flattened `pdftotext` table). Independently, the traces of `2A` and `3A` on
EOT's `M₂₄`-representations at levels 1–7, computed from the character table, equal the computed twined
coefficients (`trace_2A_eq_twined_coeff`, `trace_3A_eq_twined_coeff`). That is the moonshine
phenomenon itself, checked at two classes and seven levels by two independent computations. Negative
controls: dropping `F_g` breaks the match (`twined_2A_needs_F`); the wrong class breaks it
(`trace_3A_ne_twined_2A`).

**P4.3 completed — every class (`v3.8.0`).** The sixteen remaining columns need more than a single
`Λ_N`: eta quotients (`2B, 3B, 4A, 4C, 6B, 10A, 12A, 12B, 21AB`), sums of `Λ_d` (`4A, 4B, 6A, 8A`) and
the newforms of CDH Appendix A with rational prefactors — `F_11A = (2/5)(−Λ₁₁ + 11f₁₁)`,
`F_14AB = (1/3)(Λ₂ + Λ₇ − Λ₁₄ + 14f₁₄)`, `F_15AB = (1/4)(Λ₃ + Λ₅ − Λ₁₅ + 15f₁₅)`,
`F_23AB = (1/11)(−Λ₂₃ + 23f₂₃,ₐ + 69f₂₃,ᵦ)`. Each is computed as `24·D·H_g` over `ℤ` and equals `24·D`
times the printed column (`twined_2B … twined_23AB`); the division by `24·D` is exact at every
coefficient (`twinedAll_div`). The `12A` formula is displaced in the flattened PDF text; the exponent
`3` on `η(τ)` was inferred from the weight and is confirmed by the match (with `2` it fails:
`twined_12A_exponent_matters`). Dropping the newforms breaks `11A` and `23AB`.

On the group side, `CharactersAll.lean` carries all 26 columns of the character table, the irrational
values as pairs `(a, b) = a + b·b_n` in `ℤ[b_n]`. The guards: column norms equal the centralizer orders
(computed from the table, not typed from memory), each divisible by the element order and dividing
`|M₂₄|`; the class equation; the first orthogonality relation for all `26 × 26` pairs, with the
irrational parts tracked separately (`1, √−7, √−15, √−23` are linearly independent over `ℚ`). The
flattened text loses the overlines (`b7` for both `b₇` and `b̄₇`): a Python search over the ten
independent choices found 128 readings passing orthogonality — exactly the orbit under renaming
`7A ↔ 7B`, …, `45 ↔ 4̅5̅`, … — and all 128 give the same traces; `misread_fails_gram` shows the
guard rejects a reading outside that orbit. Then `trace_eq_twined_coeff_all`: at **every** class and
levels 1–7, the trace is a rational integer and equals the computed coefficient.

**P4.4 — the `24` of the shadow, located (`v3.9.0`).** HMN state (Tier L) that `H⁽²⁾` has shadow `24·η³`
and that `η³Ĥ` is, up to `−½`, the second helicity supertrace of the double-scaled little string theory
at `k = 2`. `Shadow.lean` does not prove a shadow — it has no completion and no modular transformation —
but it checks the arithmetic on which that statement rests (CDH §2.3, Zwegers' decomposition):

* The K3 elliptic genus `Z = 8(f₂² + f₃² + f₄²)`, computed from the theta products, starts
  `2y + 20 + 2y⁻¹ + q(20y² − 128y + 216 − 128y⁻¹ + 20y⁻²)` and satisfies `Z(τ,0) = 24`, with every higher
  coefficient zero (`ellipticGenus_z0`).
* Multiplying by `Ψ₁,₁` and clearing denominators, the decomposition into a polar part with
  multiplicity `χ` and a finite part `H·θ̂₁` holds with `χ = 24` and `H` the series computed from
  Cheng–Harrison's closed formula (`decomposition`). It fails with `χ = 23`, `25`
  (`decomposition_pins_chi`), and with `H` replaced by `H_2A` (`decomposition_needs_H`). This removes
  one former Tier L item: through `q⁹`, the `H⁽²⁾` of the closed formula *is* the mock modular form
  extracted from the K3 elliptic genus.
* The theta series `S₁⁽²⁾` whose multiple is the shadow equals `η³` (`shadowTheta_eq_eta3`), and the
  twined multiplicities `χ_g` of CDH Table 14 are the traces of `g` on the permutation representation
  `1 ⊕ 23` (`shadow_coeff_eq_perm_trace`).

So two independent computations meet at `24`: the Witten index `Z(τ,0) = χ(K3)` and the multiplicity of
the polar (massless) part. That this multiplicity is the shadow's coefficient is Zwegers' theorem
(Tier L). The reading of the polar part as a "macro" or continuum sector and of `H` as the "micro"
bound-state sector, with `24` as the coupling between them, is Tier C (§2, thought experiment 1).
Atlas-lean (Meta, `lean4basesource/atlas-lean`) was searched for reusable material: it has no Jacobi
forms, Appell–Lerch sums or mock modular forms (its only modular content is the `jacobiTheta`
S-transform, a Mathlib re-export) and its toolchain is Lean v4.29.0, so it was not used.

**P4.5 — the lock is numerology.** Paper 7's Theorem 6.1, `𝒜₂/(N_Q·𝒜₁) = 462/360 = 77/60` with product
`27720`, holds at the identity, now from the computed series (`lock_at_identity`). Its twined version —
the same ratio relation with each series' own coefficients — **fails at `2A`, `3A`, `5A`, `7AB`**
(`ratio_fails_at_*`), and at all 25 non-identity classes (`ratio_fails_at_every_class`, `v3.8.0`). At `2A`, `𝒜₂/𝒜₁ = 14/(−6)`, not `462/90`. Relations that encode module structure
(decompositions) survive twining; this ratio does not. The reading is Tier C, but it is the reading the
twining criterion gives, and it should be applied to every integer coincidence before a physical reading
is proposed. It does not rule out other relations between BPS counts and `M₂₄`.

## 5. What is not proved
That `H⁽²⁾` is mock modular at all, or that its shadow is `24·η³` (Tier L; `Shadow.lean` proves only
the decomposition through `q⁹`); anything past
`q⁹`; the group side at levels 8–9 (EOT give no decomposition there); that the forms `F_g` are modular
for `Γ₀(N_g)`; that an `M₂₄`-module with these graded traces exists (Gannon,
Tier L); Jacobi's identity (checked for ten coefficients only). Every computation is exact integer
arithmetic on finite truncations, decided by the kernel.

## 6. Definition of done
Every row of §3 is ✅ with Tier A theorems (zero `sorry`/`admit`/`native_decide`/`axiom`, audited, locked)
or ⛔ closed with a written reason; the full build, the axiom audit of all libraries and the statement
locks pass on the release tag; `docs/VERIFIED_FOUNDATION.md` and `README.md` state the results with tiers.
**Not yet met:** P4.6 is open.

## 7. Gates at `v3.7.0`
Nine-library build 3787 jobs, 0 errors. `tools/axiom_audit.py DualScaleMoonshine`: 28 theorems, 0 failing
(each depends only on `propext`). Repository total 485 theorems, 0 failing. Statement lock: 52
declarations in 4 files. Local prover not used; every goal was closed by `decide` in the orchestrating
model's first draft, after the formulas had been checked numerically.

## 8. Gates at `v3.8.1`
Nine-library build 3789 jobs, 0 errors. `tools/axiom_audit.py DualScaleMoonshine`: 68 theorems, 0 failing
(each depends only on `propext`). Repository total 525 theorems, 0 failing. Statement lock: before the
update the check reported the four `v3.7.0` files unchanged and the two new files unlocked; after review,
153 declarations in 6 files (`v3.8.1` adds `eta_lambda_agree_2B/4A`: CDH's two printed
`Λ`-forms equal their eta quotients through `q⁹`). Every goal closed by `decide`; the formulas and the overline search were
prototyped in Python first. Kernel time: `TwiningAll.lean` about 45 s, `CharactersAll.lean` about 55 s.

## 9. Gates at `v3.9.0`
Nine-library build 3790 jobs, 0 errors. `tools/axiom_audit.py DualScaleMoonshine`: 76 theorems, 0 failing
(each depends only on `propext`). Repository total 533 theorems, 0 failing. Statement lock: the
pre-update check showed the six `v3.8.1` files unchanged and only `Shadow.lean` unlocked; after review,
190 declarations in 7 files. `Shadow.lean` takes about 105 s of kernel time; the Laurent polynomials in
`y` are exact (offset + coefficient list), so no truncation in `y` occurs, and the Appell–Lerch
geometric series were checked (Python) to be unchanged when the summation ranges are doubled.
