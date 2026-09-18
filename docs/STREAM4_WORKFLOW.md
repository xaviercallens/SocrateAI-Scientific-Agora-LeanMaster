# Stream 4 Workflow — Mathieu Moonshine, Computed Rather Than Typed

**Status (2026-09-18, release `v3.7.0`):** P4.1, P4.2, P4.3 (classes `2A`, `3A`, `5A`, `7AB`) and P4.5
closed; P4.3 for the remaining classes, P4.4 and P4.6 open. Library `DualScaleMoonshine` (4 files,
52 declarations, 28 theorems, 0 failing). Rules are those of Stream 2 §2 and Stream 3 §2 (kernel is
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
| **P4.3 Twining** | `H_g = (χ_g/24)H + F_g/η³` computed for `g = 2A, 3A, 5A, 7AB`; equals CDH Table 20 through `q⁹`; divisibility by 24 proved; negative controls | CDH eq. (4.18), Table 3, (A.3), Table 14, Table 20 | ✅ for 4 classes (`Twining.lean`); ⬜ other classes (irrational `F_g`, newforms `f₁₁`, `f₂₃`) |
| **P4.3b Group side** | Traces of `2A`, `3A` on EOT's representations (levels 1–7), from CDH Table 8, equal the **computed** twined coefficients; character-table transcription guarded by orthogonality and centralizer orders | CDH Table 8; EOT (1.14)–(1.15) | ✅ `Characters.lean` |
| P4.4 Shadow | the shadow `24·η³` of `H⁽²⁾`: needs a notion of mock modularity or at least of the completion; a non-vacuous arithmetic target has not been identified | CDH §4 | ⬜ open |
| **P4.5 Forger's test** | does paper 7's "27720 lock" survive twining? **No** — at every class tested | `DualScaleValidation.UseCase2` | ✅ `ForgerTest.lean` |
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

**P4.5 — the lock is numerology.** Paper 7's Theorem 6.1, `𝒜₂/(N_Q·𝒜₁) = 462/360 = 77/60` with product
`27720`, holds at the identity, now from the computed series (`lock_at_identity`). Its twined version —
the same ratio relation with each series' own coefficients — **fails at `2A`, `3A`, `5A`, `7AB`**
(`ratio_fails_at_*`). At `2A`, `𝒜₂/𝒜₁ = 14/(−6)`, not `462/90`. Relations that encode module structure
(decompositions) survive twining; this ratio does not. The reading is Tier C, but it is the reading the
twining criterion gives, and it should be applied to every integer coincidence before a physical reading
is proposed. It does not rule out other relations between BPS counts and `M₂₄`.

## 5. What is not proved
That `H⁽²⁾` is the K3 elliptic genus's mock modular form, or mock modular at all (Tier L); anything past
`q⁹`; any class other than the four above; that an `M₂₄`-module with these graded traces exists (Gannon,
Tier L); Jacobi's identity (checked for ten coefficients only). Every computation is exact integer
arithmetic on finite truncations, decided by the kernel.

## 6. Definition of done
Every row of §3 is ✅ with Tier A theorems (zero `sorry`/`admit`/`native_decide`/`axiom`, audited, locked)
or ⛔ closed with a written reason; the full build, the axiom audit of all libraries and the statement
locks pass on the release tag; `docs/VERIFIED_FOUNDATION.md` and `README.md` state the results with tiers.
**Not yet met:** P4.3 (remaining classes), P4.4 and P4.6 are open.

## 7. Gates at `v3.7.0`
Nine-library build 3787 jobs, 0 errors. `tools/axiom_audit.py DualScaleMoonshine`: 28 theorems, 0 failing
(each depends only on `propext`). Repository total 485 theorems, 0 failing. Statement lock: 52
declarations in 4 files. Local prover not used; every goal was closed by `decide` in the orchestrating
model's first draft, after the formulas had been checked numerically.
