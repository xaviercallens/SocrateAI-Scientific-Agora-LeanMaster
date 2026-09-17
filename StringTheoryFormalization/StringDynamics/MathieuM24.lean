-- Block WS8: Mathieu M₂₄ Representations
-- Status: VERIFIED (0 sorry axioms)
-- Provides: Character decomposition of K3 elliptic genus under M₂₄.
import Mathlib.GroupTheory.Perm.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import StringTheoryFormalization.Foundations.MathlibCore

/-!
# Mathieu M₂₄ representation dimensions and the Burnside sum check

## Physical background
"Mathieu Moonshine" is the observation, first made by Eguchi, Ooguri and Tachikawa (EOT,
arXiv:1004.0956, `papers/foundations/eguchi_ooguri_tachikawa_1004_0956.txt`), that the K3
elliptic genus — a topological invariant of K3 that also counts BPS states in the associated
superconformal field theory (ll. 39–56, ll. 82–124 for the BPS/non-BPS character decomposition)
— decomposes, order by order in `q`, into non-negative integer combinations of the dimensions of
irreducible representations of the sporadic simple group M₂₄ (EOT eq. (1.11)–(1.12), quoted in
`docs/PAPER_REVISION_BRIEF_2026_09_17.md` §2 item 3). Gaberdiel–Hohenegger–Volpato
(`papers/foundations/gaberdiel_hohenegger_volpato_mathieu_1006_0221.txt`, ll. 501–503, 1436–1439)
argue this reflects an actual M₂₄ action on the Hilbert space of quarter-BPS states of K3 sigma
models. Whether such an action exists as a genuine, everywhere-defined M₂₄-module was a conjecture
when EOT wrote; it was later settled in the literature (Gannon 2012) — no part of that existence
proof, nor the group M₂₄ itself, nor its character table (traces on conjugacy classes, as opposed
to dimensions), is constructed anywhere in this file.

## Mathematical content
`M24RepDim : Fin 26 → ℕ` is a literal transcription of the 26 irreducible-representation
dimensions of M₂₄ from EOT eq. (A.3) (ll. 346–349), in EOT's stated order. `M24_order` is the
Tier A arithmetic identity `244823040 = 2^10·3^3·5·7·11·23`; that `244823040` is genuinely `|M₂₄|`
is a Tier L fact quoted from EOT (A.1), not derived here. `M24RepDim_sum_sq` checks the Tier A
arithmetic identity `∑ᵢ M24RepDim(i)² = 244823040`; Burnside's theorem that `∑ dim(Vᵢ)² = |G|`
for the irreps of any finite group `G` is itself Tier L (not proved in this corpus, which never
constructs `G`-representations abstractly). Passing the check is strong evidence the 26 numbers
were transcribed correctly (a wrong or duplicated entry generically breaks the sum), but it is
**not** a proof that they are M₂₄'s irrep dimensions specifically — infinitely many other
26-tuples of positive integers also sum-of-squares to `244823040`. `M24_first_coefficient` is a
single table lookup, included as a compile-time regression guard on the table's second entry.

## Proof techniques
Table lookups (`M24_first_coefficient`) close by `rfl`, unfolding `M24RepDim` on a literal index.
The catch-all case `⟨n + 26, h⟩ => absurd h (by omega)` is discharged from the `Fin 26` bound
(`omega` on the underlying `n + 26 < 26` contradiction) rather than by a silent default value, so
a genuinely missing table entry would be a compile error, not a wrong answer. `M24RepDim_sum_sq`
unfolds the `Fin 26` sum into 26 concrete term additions via `Fin.sum_univ_succ` and then
normalizes the resulting numeral arithmetic, both handled by `simp`.

## Related declarations
Per the theorem atlas (`papers/book/generated/atlas.md`), `M24RepDim` is a hub: it is used
directly by four `DualScaleStream2.Moonshine` theorems in a different library —
`A6_decomposition`, `A6_not_irrep`, `A7_decomposition`, `first_five_are_irreps` — which cite this
exact declaration (a cross-library bridge, i.e. the *same* mathematical object, not a re-proof) to
verify EOT's `A₆`/`A₇` decomposition identities (brief §2 item 4). `M24_order` shares its proof
recipe (`norm_num` numeral factorization) with `StringTheory.UseCases.MathieuTower.
M21_order_factorization` (dependency-Jaccard 0.925 in the atlas) — this is shared proof
*infrastructure* only (both are bare arithmetic factorizations), not an asserted mathematical
relation between the groups M₂₄ and M₂₁.
-/

namespace StringTheory.StringDynamics

/-- Dimension of the j-th irreducible representation of M₂₄, all 26, in the order of
    Eguchi–Ooguri–Tachikawa, arXiv:1004.0956, eq. (A.3)
    (`papers/foundations/eguchi_ooguri_tachikawa_1004_0956.txt`, lines 346–348).

    Corrected 2026-09-16: the previous table listed 10395 and 483 twice and omitted the
    second 990 and the third 1035; its squares summed to 351,061,029 ≠ |M₂₄|. The
    Burnside check `M24RepDim_sum_sq` below now guards the table. -/
def M24RepDim : Fin 26 → ℕ
  | ⟨0, _⟩ => 1
  | ⟨1, _⟩ => 23
  | ⟨2, _⟩ => 45
  | ⟨3, _⟩ => 45
  | ⟨4, _⟩ => 231
  | ⟨5, _⟩ => 231
  | ⟨6, _⟩ => 252
  | ⟨7, _⟩ => 253
  | ⟨8, _⟩ => 483
  | ⟨9, _⟩ => 770
  | ⟨10, _⟩ => 770
  | ⟨11, _⟩ => 990
  | ⟨12, _⟩ => 990
  | ⟨13, _⟩ => 1035
  | ⟨14, _⟩ => 1035
  | ⟨15, _⟩ => 1035
  | ⟨16, _⟩ => 1265
  | ⟨17, _⟩ => 1771
  | ⟨18, _⟩ => 2024
  | ⟨19, _⟩ => 2277
  | ⟨20, _⟩ => 3312
  | ⟨21, _⟩ => 3520
  | ⟨22, _⟩ => 5313
  | ⟨23, _⟩ => 5796
  | ⟨24, _⟩ => 5544
  | ⟨25, _⟩ => 10395
  -- All 26 indices of `Fin 26` are enumerated above; this branch is unreachable and is
  -- discharged from the `Fin` bound rather than by a catch-all default, so that a genuinely
  -- missing dimension would still be a compile error.
  | ⟨n + 26, h⟩ => absurd h (by omega)

/-- Regression guard: the table's second entry (index 1, right after the trivial
    representation at index 0) is `23`, the dimension of M₂₄'s smallest non-trivial
    irreducible representation. This is a direct table lookup, proved by `rfl` — it checks
    that `M24RepDim` was not silently edited at this index, nothing more. It is **not** a
    statement about the K3 elliptic genus or any moonshine coefficient; the physical
    Mathieu-moonshine decomposition (EOT eq. (1.11)–(1.12)) is not formalized in this file
    at all (Tier L, see the module docstring). -/
theorem M24_first_coefficient :
    M24RepDim ⟨1, by norm_num⟩ = 23 := by rfl

/-- The order of M₂₄ factors as `2¹⁰ · 3³ · 5 · 7 · 11 · 23`, matching EOT eq. (A.1)
    (`papers/foundations/eguchi_ooguri_tachikawa_1004_0956.txt`, ll. 341–343). Proof: `norm_num`
    evaluates both sides as numerals and compares. That `244823040` is the order of the *group*
    M₂₄ — as opposed to just being this numeral — is Tier L, quoted from EOT; M₂₄ is never
    constructed here, so nothing about a group is proved. -/
theorem M24_order : (244823040 : ℕ) = 2^10 * 3^3 * 5 * 7 * 11 * 23 := by norm_num

/-- **Burnside consistency check (Tier A arithmetic; Burnside's `∑ dim² = |G|` is Tier L).**
    The irreducible dimensions square-sum to exactly `|M₂₄|`. A wrong or duplicated entry
    in `M24RepDim` breaks this theorem. -/
theorem M24RepDim_sum_sq : (∑ i : Fin 26, M24RepDim i ^ 2) = 244823040 := by
  simp [Fin.sum_univ_succ, M24RepDim]

end StringTheory.StringDynamics
