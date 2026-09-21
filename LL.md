# Lessons Learned (LL)

**Most recent session first** — read §S11 (G10, the two-repository exchange and the audit-the-auditor pass, 2026-09-21), then
§S10 (Stream 9, the orientifold control, 2026-09-20), then §S9
(toolchain migration to v4.34.0-rc2, 2026-09-19) and §S8 (Stream 8,
2026-09-19), then §S2 and §S2-I (Stream 2 run + improvements,
2026-09-16/17) and §0 (2026-09-16) before anything below them.
Everything from §1 onward is the original "Phase 0" document and is kept for record, but
**its headline metrics are a known overclaim, not a mistake to repeat**: "125,790 files",
"961,898 theorems", "96.9% coverage" are aggregate counts across every vendored
`lean4basesource/` submodule (Mathlib, FLT, Navier-Stokes, …) — other people's proved
theorems, not this project's own content — presented as if they were this project's
foundation-theory coverage. Treat every number below the divider as unverified until
independently re-checked (the pattern is the same one `FOUNDATIONS.md`'s own correction
note and the root `README.md`'s "note on this revision" already flag elsewhere in this
repo) rather than as ground truth to build the next session's narrative on.

---

# §S11. G10, and what a sibling repository caught that our gates could not (2026-09-21)

Session context: `DualScaleDyons/FrickeRepair.lean` (G10), run alongside a live session of
`SocrateAI-DualScaleTopologicalUniverseModel-LeanProposal` ("Stream 1") on the same VM, with messages going both
ways throughout. Every lesson below came out of that exchange and none of them would have come out of a solo run.

## S11.1 A theorem can constrain an object completely and still never say what it is

The defect, and it appeared **independently in both repositories in the same hour**:

* Here: `fricke_is_proper_equivalence` was first stated as
  `c*x^2 + -b*(x*y) + a*y^2 = a*(-y)^2 + b*((-y)*x) + c*x^2`. True; `ring` closes it. But the statement never
  mentions `fricke`, `sym2` or `SL(2,ℤ)` — both sides are the same polynomial in five free variables. The claim
  "the left-hand side is the Fricke transform of `(a,b,c)`" lived in the **docstring**.
* There: `EmbeddingAssembly.lean` CONTROL 2, docstring "replacing `C` by `B` destroys orthogonality", statement
  `Phi_Tᵀ * Lambda * (fromRows B 0) ≠ 0` — but `fromRows B 0` *is* `Phi_T`, definitionally, two lines up. The
  theorem said only that `Φ_T` is not orthogonal to itself. The substitution the name advertised lived in the
  **docstring**.

Both files had every gate green. The common shape: the surrounding theorems *characterise* the object by its
behaviour (`sym2_isometry`, `sym2_contravariant` constrain what `Sym²` does to the Gram form; the orthogonality
controls constrain what the embedding does) and **none of them identifies it**. When nothing states what the
object *is*, the name in the docstring silently does the identifying, and a reader — human or peer — supplies the
missing step without noticing.

**The fix, both times, was the same:** state what the object *is*, not only how it behaves. Here that meant
`sym2_is_substitution` — general in nine variables, `sym2 p q r s *ᵥ ![a,b,c]` is the coefficient triple of
`(x,y) ↦ Q(px+qy, rx+sy)` — plus `fricke_coeffs`, after which `fricke_is_proper_equivalence` is
`rw [fricke_eq_sym2_S]; exact sym2_is_substitution 0 (-1) 1 0 a b c x y`, with `fricke` itself in the statement.
There it meant restating the control with `Φ_M`'s own shape so the theorem is about the sign.

**Test to apply to any new file:** for each named object, point at the theorem that would be *false* if the name
were wrong. If the only thing that would change is a docstring, the identification is not in the kernel.

## S11.2 Name where the kernel stops, and do not let a bounded check be demoted past its job

`Q ∘ S` with `det S = 1` is a proper equivalence, hence fixes every class. That last step is the **definition**
of the class relation — and this repository formalizes no class relation. So it is outside the kernel.

The first draft got this wrong in both directions within one session. It first let a `PASS(box)` enumeration do
the general theorem's work; corrected that (rightly) by proving the general theorem; and then **demoted the box
check to "a control carrying no weight"** — which was wrong, because with the last step outside the kernel the box
run is the only kernel-level evidence that our `reduce` implements the relation the theorems exhibit. It is back
to evidence status, quoted as `PASS(box: 1 ≤ a,c ≤ 4, |b| ≤ 6)` in its own docstring.

**Rule:** before demoting an enumeration as redundant, check that the theorem replacing it is complete *in Lean*,
not complete in the write-up. And always tier the theorem separately from the inference drawn from it — here
"fixes every class" is Tier A, "therefore selects nothing" is an inference, and the two must not be quoted as one.

## S11.3 Agreement between two routes is worth nothing until someone shows they are two routes

G9 published: "the repaired proposal reproduces G3's answer, **reached from the modular side**". G10 was written
to prove it and instead refuted the clause — on an objection raised by the sibling project and then confirmed in
**this repository's own pinned source**. For `ρ = 20` the rank-2 transcendental lattice *is* the CM datum
(Huybrechts `huybrechts_K3Global.txt` ll. 3093–3102, "their rational period can be read off directly from the
lattice of rank two `T(X)`"; ll. 16324–16328), so the binary-form enumeration and the "modular side" are one
computation in two languages. The agreement was forced, not corroborative.

Two further corrections fell out of the same objection: **absence of one morphism is weak evidence of no
influence** when a classical correspondence connects the two sides by other means (so "the modular structure is
inert" was too wide — what is inert is the Fricke involution); and the selection is **two steps, not one** — the
cut `ρ = 20` lands you on the CM locus, the discriminant bound selects within it, and `ρ = 20` alone does *not*
imply `T_S = A₂`.

**Rule:** when two derivations agree, the first question is not "which is more rigorous" but "are these the same
computation?" Name the dictionary that would make them the same, and say whether it applies.

## S11.4 A peer's fenced transcript is a claim about a run, not the run — and the danger signature is near-certainty

The sibling session sent four `#print axioms` output lines, then retracted them unprompted: it had not executed
the run. It had the structural argument (no axiom module in the import graph) and a whole-namespace audit, and
**the values it wrote out turned out to be exactly right** when the real run followed. Nothing was published in
between, and the episode is recorded in `docs/VERIFIED_FOUNDATION.md` as a lesson rather than a black mark,
because the handling was correct.

The useful form of the rule is theirs, and it is sharper than "don't fabricate": *a fenced transcript must be
pasted from a run in this session, and "pending" is always available.* A gate phrased "don't fabricate" catches
nothing here, because the failure mode is not carelessness — it is near-certainty. This is gate G5
(producer ≠ verifier) seen from the other side: **being right is not the same as having checked.** When citing a
peer, cite the artefact they actually ran, at the width they actually ran it.

## S11.7 Mechanise §S11.1: strip the docstring, then ask whether the statement mentions the name

Stream 1 turned §S11.1 into a thirty-line triage and contributed it
(`scripts/name_vs_statement.py` in their repo). The whole trick is two `re.sub` lines: **strip block comments,
docstrings and line comments BEFORE asking whether the statement contains the name's tokens.** Without that
everything looks clean, because the docstring supplies the very words being tested for — which is exactly how
these declarations survive review.

**Positive-control it first; this repository's history demands it.** Run it where the answer is known. Ours
flagged all three surviving disclosed-vacuous declarations, each with every name token missing and conclusion
`True`: `ward_identity_translation`, `ward_identity_dilatation`, `fm_squared_is_shift`. Only then was the rest
of the output worth reading.

**It is a reading list, not a verdict, and the raw output is useless.** 666 of 834 `theorem`/`lemma`
declarations flagged across the ten libraries — 80%, because Lean states properties symbolically and the English
word is legitimately absent (`isometry` is `Mᵀ G M = G`, `nonneg` is `0 ≤ x`, `involution` is `M * M = 1`).
False negatives are the dangerous direction and the tool cannot establish that anything is clean. Two filters
make it usable: **(a)** a weak-statement signature — conclusion `True`, `∨ True`, `∃ _, True`, or a trivial
`0 ≤ n` — which cut 666 to 26; **(b)** the highest-signal flag is a missing **object** name (`fricke`, `glue`,
`primitive`), not a missing property word, since an absent object usually means the identification is happening
in prose.

**What it found here, and the lesson is not the one expected.** Of the 26, four were already disclosed in place
by the earlier campaign — the mechanism working. The genuine find was **`bdf2_order_bound`**
(`StringTheoryFormalization/StringDynamics/StiffIntegrators.lean`): `dim : ℕ`, so `0 ≤ sys.dim` is
`Nat.zero_le`, true of every natural number, while the name promises an order bound for the second-order
backward differentiation formula. It is the `mapper_nerve_theorem` shape and **it survived §S10.5's scan because
that scan looked for statements literally equal to `True`.** A vacuous statement need not be `True`; it only
needs to be implied by nothing. `picard_convergence` is the adjacent case — `picard_spectral_contraction` under
a second name, `1/18 < 1`, with no operator, iteration, fixed point or norm in the file.

**The twist worth keeping.** Both were *already disclosed*, correctly and in detail, in
`papers/book/chapters/ch32_cosmology.tex` — "the name promises an order bound … the statement contains none".
The disclosure existed and was right; it was simply **not at the source**, so it did not travel with the
declaration into `papers/book/generated/lean_catalogue.md` or to anyone reading the Lean file. Both are now
disclosed in place, statements unchanged, nothing deleted.

**Rule:** a disclosure belongs on the declaration, not only in the prose that discusses it. Prose is read by
whoever reads that prose; a docstring is read by everyone who meets the theorem. And when a scan is written for
one signature (`= True`), record what it *cannot* see, because the next instance will take the other shape.

**Denominator discipline, learned twice in one day.** Report `666 of 834 theorem/lemma declarations`, not
`of 1203` — 1203 is the statement lock's count of *all* declarations including `def`s, a different population.
Stream 1 made the mirror-image slip (`208 of 481` where 481 counted three libraries' declarations and 208
counted one library's theorems, the true ratio being 208/312) and corrected it at source. Numerator and
denominator must name the same population; this is the same failure as carrying a repository total forward and
incrementing it instead of re-measuring (§S11.4's cousin).

## S11.8 Ask where the disclosure IS, not only whether the claim is carried

§S11.7's triage asks "does the statement match the name". Stream 1's companion check asks the question that one
structurally cannot: **"does the disclosure reach whoever meets the declaration?"** Method (a dozen lines,
`disclosure_reaches_source.py` in this session's scratchpad): extract declaration identifiers occurring near
vacuity language (`vacuou|vacuit|disclos|placeholder|content-free|carries no|says nothing|⚠`) in the **prose**
— `README.md`, `LL.md`, `docs/**`, `papers/book/chapters/*.tex` — then check whether that declaration's **own
docstring** carries the same language. A hit means the disclosure exists and does not travel.

Tune the window: ±4 lines gave 39 candidates, ±1 line gave 13, and most of those are still prose *near*
vacuity language rather than *about* that declaration — `dmvv_unreachable_example` is cited in the book as
showing a guard **is not** vacuous, the opposite of a disclosure. Read the sentence, do not trust the match.

**What it found: `Lean5Corpus/Problems/Problem3_DualScaleTCC.lean`, and it is the sharpest instance yet.** The
module docstring asserted *"the Trans-Planckian Censorship Conjecture is satisfied unconditionally without
fine-tuning cosmological parameters"*. Meanwhile `papers/book/chapters/ch27_swampland.tex` says, in terms:
*"None of these mentions a scale factor, a horizon or a mode crossing it; [the TCC inequality] is not
formalized. The docstring's claim that TCC is 'satisfied unconditionally' is the Tier C identification of the
box, not a theorem."* **The book was criticising that exact docstring, by name, and the docstring still said
it.** Everything in the file is over `ℕ`, with `planck_length := 1` and
`effective_wavelength_num R λ₀ := (R²+1)λ₀` both *definitions*, so the theorems are: a product of two naturals
one of which is `≥ 2` is `≥ 2`, and such a product is not `≤ 1`. True, arithmetic, and not the TCC.
`desitter_swampland_master_contract` (Problem 6) is the same shape — the book notes the `volume` field is
declared and never read, so the "gradient" is a second copy of the "potential" and the steepness bound is
reflexivity. Both disclosed in place; statements unchanged, nothing deleted.

**The general lesson, and it is uncomfortable.** This repository's book is *excellent* at this — ch27's tier
table lists the module's real content as `(R²+1)λ₀ ≥ 2; M/H ≥ 1 (ℕ)`, and ch32 does the same for
`bdf2_order_bound`. The honest reading existed, was detailed, and was ours. **Writing the critique is not the
same as landing it.** A critique that lives only in the document that discusses the code leaves the code
asserting the thing the critique denies, and every downstream consumer — `lean_catalogue.md`, a RAG index (these
files carry `@rag_query` metadata), a reader opening the file — meets the assertion, never the critique.

**Rule:** when a review concludes that a declaration claims more than it proves, the *first* edit is to that
declaration's docstring. Writing it up elsewhere is the second edit, not the first. And when auditing, grep the
prose for what it says about the code, then check the code says the same about itself — disagreement between
the two is a defect even when the prose is the correct half.

**Third instance, and the sharpest on retrieval:** `DualScaleM24Formalization/DualScale/EffectiveMetric.lean`.
`genesis_no_singularity` carries `@rag_query: "Does string theory eliminate the Big Bang singularity?",
"Why can spacetime not reach zero size?"` while its statement is
`0 < (effectiveRadius …).num ∧ 0 < (effectiveRadius …).den` — and `PosScale` carries `h_num`/`h_den` as
*fields*, so the proof projects the structure's own positivity out in both branches. ch31 had already written
"Literally: a positive rational is positive". `self_dual_symmetric` is `α'/α' = 1`. Disclosed in place. **The
consumer of a docstring is increasingly not a person who could go and read the chapter** — these files carry
retrieval metadata, so the misleading half is the half that gets served.

## S11.9 The same two theorems have now been invisible to three tools for the same reason

Stream 1 audited their scanners with their scanners and found **modifier blindness**: anchoring on
`^(theorem|lemma)` misses every `noncomputable` / `private` / `protected` declaration — **41 of 465 on their
side, 9%, including `cooperC3`**, the source-of-record for their headline result. Checked here immediately.

**This repository has no modifier-prefixed theorems at all, so the cost was 2, not 41 — and the 2 are the
punchline.** They are `add_pos` and `add_neg`, both `@[simp]`, in `DualScaleStream2/Lattice/K3T2Signature.lean`:
**the exact pair that `tools/axiom_audit.py` and `tools/statement_lock.py` could not see until the `v3.17.0`
gate fix** (`VERIFIED_FOUNDATION.md`: "matched declaration heads only at column 0, so attribute-prefixed
theorems were never audited or locked"). Three tools, one anchoring bug, the same two theorems. The v3.17.0 fix
repaired two files and never became a convention, so the next tool reintroduced it.

**A scan that cannot see a declaration reports it as clean.** That is §S10.5's lesson one level lower: not
"the scan looked for the wrong signature" but "the scan never saw the object". Stream 1 found A1 by *reading*
the brief; had they trusted the tool over the reading they would have called that file clean and said so.

**The durable fix is a self-test, not a fixed regex.** Both tools now take `--self-test`, which asserts the
attribute-prefixed controls are visible and exits non-zero otherwise, with the history in the comment beside
it. A regex fix repairs one tool; a self-test makes the *next* tool fail loudly instead of quietly. Any future
audit script over this repository should assert `add_pos`/`add_neg` are in its parse before reporting anything.

**And negative-control the self-test — a self-test that cannot fail is this same trap one level up.** Stream 1
insisted on it and was right; we had shipped a green self-test never seen go red. Done: the `v3.17.0` anchoring
bug (`^(theorem|lemma)` at column 0) was reintroduced into scratch copies of both tools, and both then print
`SELF-TEST FAIL -- parser cannot see: add_pos, add_neg` and **exit 1**; the real tools exit 0. The guard
demonstrably fires.

*One more slip, in the control itself, worth recording because it is the same shape a third time.* The first
run reported `exit=0` for the buggy copies — the harness was `python3 ... | tail -1` and `$?` was **`tail`'s**
exit code, not Python's. The measurement measured the wrong object while printing the right words. Verifying a
verification is not exempt: check what the number you are reading is actually a number *of*. Stream 1 then
turned this on their own day's work and found every build they had reported was piped through `grep`, so every
exit code they read was grep's; the claims held, but *by habit of reading the text rather than the number*.
Their demonstration of the live trap is the one to remember:
`lake build NoSuchTarget 2>&1 | grep "Build completed"; echo $?` → **0**, reading as success.

**Audited here in the same pass, and the gate tools are fine but the reading was not.** Every `lake build` in
this session was unpiped (`> log 2>&1; echo $?`) or used `${PIPESTATUS[0]}`, so those numbers were real. But
**`axiom_audit.py` and `statement_lock.py` were both read through `| tail`** — and both *do* return `1` on
failure (`return 1 if bad else 0`, `sys.exit(main())`), so a meaningful signal was discarded and the text read
instead. Re-run unpiped: `axiom_audit DualScaleDyons` **exit 0**, 166 audited / 0 failing; `statement_lock
--check` over all ten libraries **exit 0**, OK.

**And the lock is now mutation-verified, not merely green.** Changing `sym2_S_det`'s statement from `= 1` to
`= 2` makes `--check` print `CHANGED DualScaleDyons/FrickeRepair.lean :: sym2_S_det` and **exit 1**; reverted,
it returns to exit 0. A gate that has never been seen go red is a gate you are trusting, not running — the same
rule as the self-test, one layer down. **Read the exit code, and make sure the exit code is the tool's.**

**G2 and G3 too, with one mutation that also demonstrates why G1 cannot substitute for either.** Appending
`theorem g3_negative_control : (0 : Nat) = 1 := by sorry` to `DualScaleValidation/Observables.lean`:

| gate | result |
|---|---|
| G1 `lake build DualScaleValidation` | **exit 0** — `Build completed successfully`, with only `warning: … declaration uses ‘sorry’` |
| G2 comment-stripped grep | **exit 1**, names the line |
| G3 `axiom_audit.py` (unpiped) | **exit 1**, `FAIL g3_negative_control ['sorryAx']`, 24 audited / 1 failing |

Reverted: build exit 0, audit exit 0, 23 audited / 0 failing. **A `sorry` does not fail the build** — that is
the whole reason G2 and G3 exist, and it is now demonstrated here rather than asserted. (Note also that the
warning text uses a typographic backtick: a grep for `'sorry'` with straight quotes finds nothing in the log.
The first run of this very control reported `0` matches for that reason.)

**A gate's exit code can be structurally uninformative, and that is worth checking separately.** Stream 1 found
`axiom_audit.py Agora` **exits 1 permanently** on their side — it returns non-zero whenever any theorem depends
on a *registered, disclosed* axiom, and their steady state is three. They had read it through `| tail` all day
and called it green from the counts. Same tool, same code: **its exit code is a usable CI signal here (we
register no axioms, so 0 means clean) and permanently red there.** Before wiring any gate to CI, ask not only
"have I seen it go red" but "can it go green in this repository's steady state" — a signal engineered to be
ignored is worse than no signal.

**Corrected count: 666 of 836**, not `666 of 834` as first reported — our denominator was the narrow anchor's.
Small here only because of the structural accident that we have no `noncomputable` theorems, which is exactly
why the bug would have gone unnoticed on this side. Stream 1's moved twice: `208/481` (wrong population) →
`208/312` → `226/333` (population the tool could not see). Two different errors behind one number, and both
are this audit's own failure mode in miniature.

**The `Disclosure` convention, now load-bearing.** §S11.8 recorded that the tool cannot confirm a disclosure
exists, only that its vocabulary appears. Adopted on both sides: every in-place disclosure opens with the
literal word **`Disclosure`**. Retrofitted to the four written earlier that lacked it, which moved the
candidate list from 13 to 10 and stopped the tool re-flagging our own corrections. The point is not the word;
it is that **the audit and the reader now look for the same token.** Stream 1's deeper catch on the same
sweep: their fix was still flagged because they had landed A1's resolution on `cooperC3`, the declaration where
the *substance* lives, and not on `partner_res0`, the declaration the review actually **named**. The rule gains
a clause: *the disclosure goes on the declaration the criticism names, which is not always the one where the
substance lives.*

**Two limitations of the tooling, both found by running it on my own fixes.**
1. *Homonyms.* Binding a base name to the first file read produced a **false positive** against
   `k3_euler_characteristic` — this repo has three, the book distinguishes them by fully-qualified name, and
   the tool could not. Fixed: keep all homonyms, flag only when none carries the language. Match on the
   fully-qualified name where the prose supplies one.
2. *Keyword blindness.* After disclosing `tcc_cosmic_protection_contract`, the tool still flagged it — the
   disclosure says "not formalized", which is not in the keyword list. **The tool cannot confirm a disclosure
   exists, only that its vocabulary appears.** Hence the convention adopted here: every in-place disclosure
   opens with the literal word **`Disclosure`**, so the audit and the reader look for the same token.

**Open items decay into assumed-closed** (Stream 1's generalisation, and the quieter failure): an *unanswered*
review item leaves no trace in **any** gate — not a `sorry`, not an axiom, not a failing build, and the
statement lock is silent. It reads as done because nothing says it is not. Their case ran two months on their
headline result. Checked here and this repo is in better shape: the analogous scan over `docs/reviews/` and the
revision brief found **0 unrecorded of 3**, and Stream 9's own conditional status *is* carried at the
declaration (`convention_factor_bounded`: "**Conditional remark, not a result**… not established here"). That
is the pattern working, and it is why the finds concentrated in the legacy Phase-0 libraries instead.


## S11.5 Two Lean sessions on this VM contend for page cache, not CPU

A single-file `lake env lean` here sat at ~1% CPU for six minutes while the sibling repository elaborated: both
were I/O-bound on olean loading, with ~16 GB RAM free the whole time. `§S8.2`'s warning generalises — it applies
**across repositories and across Claude sessions**, not just within one build. Also worth knowing before starting
a long run next to one: a `lake env lean` on a full-library import can hold the Lake lock for ~10 minutes.
**Ask the other session before starting, and say when you are clear.** That exchange cost two messages and saved
an unknown number of 20–40 minute stalls.

## S11.6 Ported code must match Lean's integer division, or the port invents failures

Porting `AttractorCharges.reduceStep` to Python to pre-check a theorem produced **56 spurious class mismatches**.
Cause: the port used truncation toward zero; Lean 4's `Int./` is `ediv` (floor for a positive divisor).
`#eval ((-1 : Int) / 4)` gives `-1`, not `0`. With floor division there were zero mismatches. Had the port been
trusted, the conclusion would have been the opposite of the truth.

**Rule:** when pre-checking a Lean definition outside Lean, verify the division and modulus semantics with
`#eval` on a negative operand *first*. `%` is `emod` and is always non-negative; the repo's own
`discriminant_gap` relies on that.

---

# §S10. Stream 9, the orientifold control (2026-09-20)

**Scope**: `DualScaleStream2/Orientifold/` and `DualScaleStream2/Flux/`, releases `v3.31.0` … `v3.36.0`.

## S10.1 A statement listed as "the next formalization target" is an unverified claim, and it cost the repo a false sentence

S9.3 wrote, as *motivation* for a file of arithmetic about `φ`, that a finite-order integer matrix of size `d`
and order `n` requires `φ(n) ≤ d`, and listed "prove it" as the next target. It sat in the header, in
`docs/STREAM9_ORIENTIFOLD.md` §5 and in `docs/VERIFIED_FOUNDATION.md` for five releases. **It is false for every
`d ≥ 5`**: `diag(C_{Φ₃}, C_{Φ₅}) ∈ SL(6, ℤ)` has order 15 and `φ(15) = 8 > 6`. The argument everyone reaches for
— minimal polynomial divides `X^n − 1`, so some eigenvalue is a primitive `n`-th root — fails because a matrix's
order is the **lcm** of its eigenvalue orders, not the largest.

The gates could not catch it: no theorem depended on it, so the build, the `sorry` grep, the axiom audit and the
statement lock were all green the whole time. What caught it was *starting the proof* — three minutes of
`sympy` before writing any Lean.

**Rule.** Before writing "not proved here; the next target is X", spend the five minutes to check X on a small
case. A target is a claim. If it is wrong, listing it propagates it into every doc that summarises the file, and
the repository's own verification machinery is structurally blind to it.

## S10.2 A hand-computed matrix literal is not Tier A until a lemma derives every entry

S9.5b's `8 × 8` pairing matrix came from a Python script. `J₈ᵀ = −J₈` and `J₈·J₈ = −1` are kernel-checked — but
they are true of *any* such matrix, so the kernel was certifying internal consistency, not provenance. The fix
(`symJ8_is_wedge`) checks all 64 entries, **zeros included**, against `wedgeSign`, i.e. against the definition of
the pairing. Twelve lines. Any transcribed table deserves the same.

## S10.3 Do not let a conditional bound be written up as the result

S9.5c proved "if the lattice pairing *is* `N_flux`, a coarse quantisation `M ≥ 6` forces zero flux". The bridge
to `N_flux` needs a `D3`-charge normalisation this repo has no source for, and the isotropic model `M·ℤ⁸` is not
the shape an orientifold projection takes — the case anyone cites is `M = 2`, where nothing is obstructed. The
theorems stayed; the framing changed to **"a conditional remark, not a result"**, with both reasons written down.
The tell: a headline whose hypotheses are supplied by hand rather than derived.

## S10.4 Kill background shells before a release build

Roughly ten `until`-loop watchers and one foreign `lake build` were still spinning from earlier in the session.
A concurrent Lean build is the documented OOM / page-cache-flush failure of §S8. Stop them (`TaskStop`) before
the release commit, not after.

## S10.5 The gates cannot see a vacuous statement, and mutation testing cannot either

Two instances, one week apart, same blind spot from the other side. §S10.1 was prose no theorem depended on.
This one is a *theorem* that depends on nothing because it says nothing.

`StringTheoryFormalization/StringDynamics/TDAMapper.lean` carried `mapper_nerve_theorem`, docstring "The Mapper
construction preserves connected components in the limit of fine covers (nerve theorem analog)", statement
`∀ (G : MapperGraph), G.nodes.card ≥ 0`, proof `Nat.zero_le`. True of every `Finset`. The file header said
"Status: VERIFIED (0 sorry axioms)" and a scorecard said 100%. Both true, both beside the point. Its companion
`mapperComponents` returned the node count, which is not a component count. A repo-wide scan then turned up three
more declarations whose statement is literally `True` — `ward_identity_translation`, `ward_identity_dilatation`,
`fm_squared_is_shift` — all in the same library, all *already* labelled vacuous in their own docstrings by an
earlier session, and all still counted in the headline number.

**Why no gate catches it.** The build compiles a vacuous theorem happily. The `sorry` grep finds nothing —
`True := trivial` is strictly better at evading it than `sorry` would be. The axiom audit reports
`propext, Classical.choice, Quot.sound`, because that is what a trivial proof uses. The statement lock locks the
vacuous statement and reports no change. And **mutation testing does not help**: a mutant of `card ≥ 0` is
usually still true, so nothing fails to compile. Every gate is a dependency check; none is a content check.

**Rules adopted.**
1. A count of "theorems audited" is a count of *declarations whose dependencies were checked*. Say so wherever
   the number appears, and state how many carry content (`README.md` now says 785 audited, 782 with content).
2. A placeholder must never be written as `True := trivial`. It evades every gate. If a result is not proved,
   leave it out and say so in prose, or use `sorry` — which at least trips a gate.
3. When a docstring claims more than the statement, the docstring is the defect. Read them against each other.

# §S9. Toolchain migration to Lean/Mathlib `v4.34.0-rc2` (2026-09-19)

**Scope**: branch `toolchain/v4.34.0-rc2` in a worktree on the data disk; `lean-toolchain`, `lakefile.lean`,
`lake-manifest.json` and version strings only — **no `.lean` file changed**. Gate numbers in
`docs/VERIFIED_FOUNDATION.md` §0b.

## S9.1 A minor Lean release cost nothing in proofs here, and the reason is the proof style
All 150 first-party modules, 693 audited theorems and 1053 locked declarations went from `v4.33.1` to
`v4.34.0-rc2` with zero source edits. What broke elsewhere in such migrations — `simp` set drift, renamed
lemmas — barely touches this corpus because most of it is `decide`/`decide +kernel` over own `def`s and only a
thin layer uses Mathlib lemmas by name. Four Mathlib deprecations appeared as warnings (`if_pos`/`if_neg` →
`ite_eq_left`/`ite_eq_right`, `dif_pos` → `dite_eq_left`, `push_neg` → `push Not`) and were left alone: a
deprecation is not a breakage, and changing a proof that compiles adds risk with no gate benefit.

## S9.1b The one real breakage was a tactic that became redundant, not a renamed lemma
`push_cast; rw [hk]; ring` failed under rc2 with "No goals to be solved": `rw` now closes the goal by `rfl`
before `ring` runs. Dropping the `ring` is the whole fix. When a migration reports "No goals to be solved",
read it as *the preceding tactic got stronger*, and delete the trailing tactic rather than hunting for a
renamed lemma. Not verified against v4.33.1: the file arrived on `main` after the migration run had started,
so "rc2 changed this" is the plausible reading, not a measurement. (The file, `DualScaleDyons/TrappingObstruction.lean`, arrived on `main` mid-migration and is
not imported by the `DualScaleDyons` root, so `axiom_audit.py <Lib>` cannot see it — a module outside the
root's import closure is outside the gate; audit it by file until the root imports it.)

## S9.2 Migrate in a worktree, with its own `.lake` and its own LeanMemory
`git worktree add` on the data disk gives a second, independent `.lake` (7.9 GB after `lake update` +
`lake exe cache get`, 7 min) while another session keeps committing on `main`. `leanstack` resolves its repo
root from its own file location, so running it inside the worktree builds the worktree; `--home` pointed at a
separate LeanMemory keeps the main store's measured peaks clean. `main` moved twice during the run; because the
branch had no commits yet, `git stash && git reset --hard main && git stash pop` re-based the three real
changes in seconds.

## S9.3 The `MemAvailable` floor is a machine-wide condition, not a measurement of your build
`DualScaleMoonshine.HMNBridge` was killed three times: twice by leanstack's `MemAvailable < 2 GB` floor
(peaks 17.1 and 17.5 GB anon, the second at a moment when Lean itself was back down to ~3 GB and a peer
session's jobs had grown to 10–12 GB), once by the kernel OOM killer at only 7.5 GB anon (same cause,
`dmesg` 18:34:49). Raising `--budget-gb`/`--module-gb` cannot help: the floor is `min_available_kb`, hardcoded
in `scheduler.execute` with no CLI flag. On a shared VM, a 19 GB module is not schedulable while a neighbour
holds 10 GB — the fix is to run it when the machine is quiet (it then built in 1689 s, peak 21.0 GB RSS /
17.4 GB anon), not to tune the guard. Under `v4.33.1` the same module was killed at 18.1 GB, so rc2 did not
regress its cost.

## S9.4 Warm the page cache *before* the heavy module, not during it
After an OOM the cache is empty and Lean loads its imports at 2 MB/s at ~2% CPU for ten minutes; a sequential
read of the same files (`leanstack warm`) runs at 10–50 MB/s. 1.9 GB of `.olean` plus 3.7 GB of
`.olean.private` is the working set of the Mathlib-dependent libraries here; warming it costs under a minute
when the machine is idle and is wasted effort once Lean has already started reading.

---

# §S8. Stream 8 "which K3?" (2026-09-19): E4 on the D = 12 Kummer, P8.2, P8.4c

**Scope**: `DualScaleDyons/KummerOmegaE4.lean` (v3.24.0), `AttractorCharges.lean` (v3.25.0),
`K3Enhancement*.lean` (P8.4c). Full reading in `docs/STREAM8_WHICH_K3.md` §10–§12. These are the lessons that cost
time or nearly let a wrong claim through.

## S8.1 `decide +kernel` memory is the binding constraint, not time — and it accumulates per file
`so40_point` (760 root vectors, each reconstructed from a 24-vector basis by `decode`) reached **28 GB RSS** and was
OOM-killed on the 29 GB VM; `so44_point` alone needs ~14 GB even after a lighter rewrite. The kernel keeps every
intermediate term of a declaration's evaluation, and the memory of all `decide +kernel` calls in one file adds up.
**Do**: (i) measure peak RSS per theorem (`/usr/bin/time -f %M`, or poll `/proc/<pid>/status`) before assembling a
file; (ii) prefer sparse *certificates* (an explicit short integer combination per item) over full reconstruction;
(iii) put each heavy check in its own module (`K3EnhancementSO40.lean`, `...SO44.lean`) and build heavy modules
sequentially with `lake build <Module>`; (iv) drop checks whose cost is out of proportion — `Nodup` on 760 integer
lists exceeded 14 GB, so distinctness is stated as "by construction" and the docstring says it is not kernel-checked.
The first version of the file compiled once (5.5 min) and then OOM'd after a docstring-only edit: a borderline
file is not a passing file.

## S8.2 An OOM kill flushes the page cache, and on this disk that costs 20–40 minutes per compile
After each OOM the OS page cache was empty, and every `lake env lean` then re-read Mathlib's `.olean` files from the
persistent disk at **2–6 MB/s with ~1% CPU** (vmstat `wa` ≈ 12%). A single-theorem test file "timed out" at 900 s
without ever finishing its imports. **Diagnose before blaming the code**: low CPU + slowly growing RSS + high I/O
wait means cold-cache loading, not a hard proof. Keep a guard that kills a runaway `lean` at a budget below the
machine total (so the kernel OOM killer never fires and the cache survives), and warm the cache by reading the
`.olean` files sequentially before a batch of compiles.

## S8.3 Parallel compiles multiply memory; timeouts on a shared VM are not verdicts
Three mutants compiled in parallel all produced "no errors" — they had been killed by timeouts/OOM, which prints
nothing matching `error`. **A mutation that is "not caught" must show a real compile result**: log the exit code
(124 = timeout, 137 = SIGKILL) and the error count, and rerun sequentially. Peer sessions on the same VM
(DualScaleSimulator TDA jobs) also consume RAM and disk bandwidth.

## S8.4 `pkill -f <pattern>` kills your own shell when the pattern is in your command line
Twice a background command died with exit 144 because `pkill -f "scratchpad/k3b.lean"` matched the bash process that
was running it. Match on the real binary (`pgrep -f "^lean .*file.lean"`) or kill by PID.

## S8.5 Verify an advisor's cross-check before adopting it — and keep a refuted one refuted
The advisor twice proposed "|U₂(ℤ[i])| = 96 and |U₂(ℤ[ω])| = 72" as a classical confirmation of the exhaustive
holomorphic-isometry count. It is false: a unit vector (x, y) of the standard hermitian form has |x|² + |y|² = 1
with integer norms, so one entry is a unit and the other is 0; unitary matrices are monomial, the standard U₂(ℤ[i])
has order 2·4² = 32, and U₂(ℤ[ω]) (order 2·6² = 72) has SU₂ of order 12, not 24. The counts 96 and 72 themselves
stand (exhaustive search, 24 symplectic = Fujiki's maximum). The Hurwitz D₄ lattice is not the standard hermitian ℤ[w]².
The advisor's other points (chirality convention, parity argument, Sen anchor) were right and were adopted.
**Rule**: a suggested cross-check is a claim like any other — derive it before writing it into a docstring.

## S8.6 Anchor computed physics numbers to a printed table before calling them counts
The ψ₁^F coefficients 25353 and −50064 came from our own Stream 5 series. Sen's lecture notes (`0708_1270.txt`
l. 6788) print d = 50064 for Q² = P² = 2, Q·P = 0, which matches the second and fixes the sign convention
d = (−1)^{ℓ+1}c; 25353 is not in that table and is stated as computed, not as a checked count.

## S8.7 Check chirality and frame conventions when comparing counts across sections
E2 counted 6 + 6 roots (SU(3)_L × SU(3)_R, GPR's convention); Aspinwall's heterotic/IIA rule counts one side only
(the GSO projection kills the other). Comparing E2's 12 with P8.4c's numbers would have been inconsistent. In the
IIA frame the T² area modulus is the heterotic axion-dilaton (Aspinwall ll. 2838–2845), so E2's ρ = ω is not a
trapping statement there. Write the frame next to every count.

## S8.8 Negative results belong in the synthesis
P8.4c found that trapping on the whole K3 × T² moduli space selects SO(44) (D₂₂, 924 roots), which does not split
into a K3 point and a T² point, and that the maximal-enhancement point is a singular CFT where moonshine symmetry
(E4) does not apply. Both weaken the "maximal self-duality selects X₃ × E_ω" reading of E2; they are recorded in
§12 and the synthesis, not softened. The ω convergence survives for black holes (P8.2), not for the vacuum.

## S8.9 Check what a literature example actually is before calling your case "not in the literature"
Taormina–Wendland's "ℤ₃-symmetric torus" sounded like the ω torus. Computing its transcendental lattice
(`tools/e4_omega_kummer.py` part 4) gave diag(2, 2), not A₂, so the D = 12 surface really is outside their examples.
One short computation turned an assumption into a pinned statement.

---

# §S2. Stream 2 autonomous run (2026-09-16 21:27 → 2026-09-17 UTC): tiered proof pipeline

**Scope**: new `DualScaleStream2` lean_lib (K3 × T² lattices, `O(d,d;ℤ)`, DFT generalized
metric, dual-scale bound, tadpole, moonshine). Full per-tier numbers:
`docs/STREAM2_WORKFLOW.md` §6. These lessons are the ones that should change how the *next*
run is organized.

## S2.1 Route every goal T3 → T2 → T1; the split is sharp and predictable
Local `DeepSeek-Prover-V2-7B` (Q8_0 on the T4, ~4 s/attempt) closed essentially every
*concrete* goal (fixed matrices, numerals, `fin_cases` tables, the 64-entry E8 inverse
check) and essentially none of the *symbolic* general-`n`/general-`d` goals. Haiku closed
most short symbolic algebra; Sonnet was needed for goals needing a real idea (block-matrix
identities with inverses, positive-definiteness, the diagonal + strict-upper decomposition).
**Do**: write statements so the concrete content is split into separate lemmas — they are
nearly free at T3.

## S2.2 A thinking prover model is useless if the budget can't reach the answer
`Goedel-Prover-V2-8B` closed 0 goals: with thinking on it spent 8192 tokens / 615 s without
emitting an answer; with thinking off it went off-target and emitted `sorry` scaffolds.
**Check `done_reason` and the separate `thinking` field before concluding a model can't
prove something.** It was a configuration failure at T4 speed, not a capability verdict.

## S2.3 Never count an agent's "SOLVED" or "0 errors" without recompiling it yourself
Two Haiku reports misstated compile status: "5 clean `sorry`s" was really 8 compile errors,
and "no compilation errors" was really 3. A third report said a definition "could not be
found" when it existed in a file this session had written. Recompile every report,
re-check that every statement and definition is byte-identical to what was designed, and
restore unsolved goals to exactly `sorry` before escalating. Put "unsolved = exactly
`sorry`, final compile 0 errors" in every prover prompt.

## S2.4 `lake env lean` does not apply `lakefile.lean` options
Package `leanOptions` (here `maxHeartbeats := 1000000`) apply to `lake build`, not to bare
`lake env lean file.lean`, which uses Lean's default 200000. Agents and
`tools/prover_loop.py` were running a stricter gate than the real build, and one Haiku agent
abandoned `e8_LDL` on a timeout the real budget doesn't hit. **Always pass
`-DmaxHeartbeats=1000000 -DmaxRecDepth=8000` to single-file compiles.** (A stricter gate
can reject valid proofs; it can never accept invalid ones, so no wrong result entered the
repo — it only cost time.)

## S2.5 A green build and zero `sorry` are not the whole gate — audit axioms
The new `tools/axiom_audit.py` (`#print axioms` over every theorem) found a `native_decide`
in the "clean" Stream 1 core (`bps_ratio_reduced`), which the build and every `sorry` grep
had passed. It also correctly propagates `sorryAx` to theorems that only *depend* on a
`sorry`. Run it at every gate; validate it with a positive control (a known-clean library)
and a negative control (a library with known `sorry`s) before trusting it.

## S2.6 Guard every data table with a theorem that would break if the table were wrong
Stream 1's `M24RepDim` table had been "verified" for months and was wrong (two entries
duplicated, two missing), because its only theorem checked a single entry. Burnside's
`∑ dim² = |G|` caught it in one line. For every hand-entered table, add the cheapest global
consistency theorem available (sum of squares, total count, known product, symmetry).

## S2.7 Pick the proof route before picking the tier
`cartanE8_posDef` failed at T2 through the literal 64-entry `L·D·Lᵀ` matrix product. It fell
to T1 once the orchestrator derived (and sympy-verified) the equivalent sum-of-squares
identity `xᵀ E8 x = Σ Dₖ yₖ²`, which `ring` checks directly. When a goal times out, look for a
formulation that avoids large definitional unfolding *before* escalating to a costlier model.

## S2.8 Bound agents by wall-clock, not just attempts
Several Haiku agents ran for hours on 1–3 goals (one took 6.7 h for 3 goals, all trivial
once found), dominated by CPU contention from up to six concurrent `lean` processes on one
VM. "At most N compile attempts" did not bound elapsed time. Give every agent a wall-clock
limit, and run at most 2–3 compile-heavy agents at once on this VM.

## S2.9 Pin citations to file + line, and grep them — even your own
A docstring drafted this run cited Huybrechts "Ch. 16 (§1.4?)"; grepping the downloaded
text showed the Mukai pairing is Ch. 9 §1 Def. 1.4 (heading at line 7352). Every Tier L
citation in `DualScaleStream2` now names a `papers/foundations/*.txt` file and line range, and
the papers' metadata came from the arXiv abstract pages, not memory.

## S2.10 Lock statements, not just proofs
The kernel checks that a proof proves its statement. It does not check that the statement is
still the one that was reviewed. `tools/statement_lock.py` hashes theorem statements (up to
the top-level `:=`) and full definition bodies into `docs/statement_lock.json`. Replacing
`sorry` with a proof leaves the hash unchanged; weakening a hypothesis changes it. Run
`--check` before accepting any agent's proof.

## S2.11 An audit that can't elaborate must fail loudly, not report "MISSING"
When the root `.olean` of `StringTheoryFormalization` was stale, the axiom audit printed
"89 theorems audited, 89 failing (MISSING)". That looks like a proof result, but it was an
infrastructure failure. The audit now exits 2 with `AUDIT ERROR` whenever the probe file has
any elaboration error. General rule: tools must tell "could not check" apart from "checked
and failed".

## S2.12 Pre-verify conventions symbolically before stating a theorem
Every block-matrix convention (sign of `B` in the generalized metric, the `η`-pairing, the
Θ-shift orientation) was checked in sympy before its Lean statement was written. A sign slip
caught this way costs minutes. The same slip caught only after an agent has spent an hour on
an unprovable statement costs far more. A sympy check is still **not**
Tier A: papers must label it as a symbolic check and must not quote it as a theorem (for
example, the converse "commutator ≠ 0 when det A ≠ 1" in `SL2Product`).

## S2.13 Docs drift into "iff" when the theorem is one direction
The revision brief said the Θ-shift preserves η "iff Θ antisymmetric". The Lean theorem proves
only the "if" direction. Before a claim goes into a paper, read the Lean statement itself, not
the prose that summarized it.

---

# §S2-I. Improvements for the next run (actionable)

1. **Statement design first, in one pass.** Write every statement with sympy-checked
   conventions and `sorry`, then run `lake build`, `statement_lock --update`, and T0 review.
   Only after that does any proving start. This run interleaved design and proving, which
   caused re-locks.
2. **Tier routing by goal shape, automatically.** Concrete goals (numerals, fixed matrices,
   `fin_cases`) go to T3 `prover_loop.py`. Short symbolic algebra goes to Haiku. Anything
   with inverses, positivity, or general `n` goes straight to Sonnet: Haiku's success rate
   there was low and its reports unreliable (S2.3).
3. **Concurrency budget.** Run at most 3 compile-heavy agents, each with a wall-clock limit
   (≈45 min Haiku, ≈90 min Sonnet), plus the prompt line "final compile 0 errors, paste the
   literal compiler output".
4. **Single gate script.** Wrap `lake build <lib>`, the sorry grep, `axiom_audit.py`,
   `statement_lock.py --check`, and the S8 refresh (`index_declarations.py`, `leangraph`,
   `socrateai_oracle.py export-json`) in one `tools/gate.sh`, so no gate is skipped under
   time pressure.
5. **Rebuild root oleans after module changes.** Build the library target itself, not only
   module targets, before auditing (S2.11).
6. **Paper claims come from the Lean source.** Generate the claim tables in papers from the
   declarations DB (`.leancache/declarations.db`) plus the statement lock, not from
   hand-written prose (S2.13).
7. **Next mathematics targets (Stream 3 candidates).** Narain lattice Γ^{d,d} even
   self-duality for general d; the full O(Γ^{4,20}) action on the Mukai lattice; the
   Siegel–Narain theta function's modular transformation (needs Mathlib modular-forms
   coverage); and a certified reduction of EOT A_n coefficients to M24 characters.

---

# §0. Session 2026-09-16: Recovery, Build-Fix, Use-Case, and RAG/Graph Wiring

**Project**: SocrateAI-Scientific-Agora-LeanMaster
**What happened this session, in order**: (1) the entire local checkout was missing from
disk and had to be re-cloned from GitHub; (2) `StringTheoryFormalization` had 8 real
build failures despite being self-documented as "26-28/30 modules, complete" — fixed to
3291/3291, 0 errors; (3) added 5 new, real, fully-proved "known complex" use cases (26
theorems, 0 sorry); (4) wired up the project's own RAG/graph/SQLite tooling for real,
since most of it was either unpopulated or scoped to a stale subset of the project.
**Final state**: `main` green, `lake build` 3353/3353 jobs, 0 errors, across all 6
first-party libraries.

## Lesson 0.1: A missing project is not always a missing project — check the disk before re-cloning
Home-directory symlinks to the data disk can silently disappear (a VM remount/relabel
event, cause unconfirmed) while the actual data survives one level down. **Before
concluding something needs re-cloning**, diff every top-level entry of the data-disk
directory against home's symlinks — a one-line loop, seconds to run — rather than trusting
`ls ~` alone. This session, doing that turned up 4 more silently-broken symlinks besides
the one initially reported, including the project's main Python venv (6.5GB, completely
unreachable at its expected path until checked). Only re-clone from GitHub once you've
confirmed via `find -L` (which follows symlinks; plain `find` gives false negatives) that
the data is genuinely gone from every disk, not just unlinked.

## Lesson 0.2: Self-reported "complete"/"N/M modules passing" status is a claim, not a fact — rerun the build
This repo's own session summaries have repeatedly stated build status that didn't match
running `lake build` fresh: "26-28/30 modules" was actually 22/30 failing-or-untested at
the start of this session (8 real failures once the full dependency chain was exercised,
not the "2 remaining" the docs named — those 2 had in fact been fixed; a different 8
had not). **The fix that generalizes**: after any claim of "X builds clean" from a
document, memory note, or your own earlier turn in a long session, re-run the actual
build before trusting it or building further work on top of it. This is cheap (`lake
build <target>`, background it, keep working) and it is the only way this session
caught real, previously-unreported failures.

## Lesson 0.3: A fix that "compiles" can still be hiding downstream breakage — fixing cascades
Fixing one broken file can *unblock* Lean from even attempting to elaborate files that
depend on it, which can surface entirely new failures that were always latently present
but never reached because the build stopped earlier. This session: fixing 4 modules
revealed a 5th (`ModuliGeodesics`) and 6th (`SwamplandSafe`, `FTermPotential`) that had
never actually been attempted in a full build before. **Rule**: after any fix, re-run
the *whole* target's build, not just the one file you touched — `lake build` on the
single file will look green and hide this.

## Lesson 0.4: A real, reproducible Lean 4 parser gotcha — parenthesize multi-name structure fields
`structure Foo where a b c d : T` (space-separated field names, **no parens**) is parsed
as ONE field `a` that is a *curried function* taking `b c d` as auto-bound implicit
arguments and returning `T` — not four scalar fields of type `T`. This reproduces in
vanilla Lean 4 with zero Mathlib imports (`structure Foo where a b c d : Nat`, then any
use of `a`,`b`,`c`,`d` as scalars fails with bizarre dependent-function-type errors whose
error messages give no hint of the real cause). **Fix**: parenthesize the group,
`(a b c d : T)`. This bug, once found in one file (`SL2CSymmetry.MobiusTransform`), was
found again independently in a second, unrelated file (`ModuliGeodesics.ModuliGeodesic`)
in the same corpus — **grep the whole codebase for `structure \w+ where\s*\n\s*\w+ \w+`
(two-or-more bare space-separated names before a bare `:`) as a class of latent bug**,
don't assume it's isolated once you've found and fixed one instance.

## Lesson 0.5: This project's automation tools are a mix of real and fabricated — audit each one before trusting or extending it
`leanautoresearch/evaluator.py`'s `LeanEvaluator` is real: it runs an actual `lake build`
subprocess and a real regex sorry/admit audit after stripping comments. `leangraph/`
(dependency graph extractor) and `tools/socrateai_oracle.py`/`tools/lean_cache_manager.py`
+ `leangraph/cache.py` (SQLite declaration index) are also real, working code. But:
- `leanautoresearch/prover.py` is a **hardcoded static list** of already-"PROVEN"
  experiments with **no actual proving logic** — pure mock data.
- `leanautoresearch/engine.py`'s `sync_epistemic_claims()` injects the **same 3
  hardcoded claims** into `ledger.jsonl` any time the *whole* corpus builds with
  aggregate zero-sorry, regardless of whether those 3 specific claims are what was
  actually just proved.
- `leangraph.build_graph`'s default module list and `socrateai_oracle.py`'s indexing
  scope both silently omitted `StringTheoryFormalization` — the single largest library
  in the project — until fixed this session (see §0.7). A "complete" RAG/graph export
  can still be silently missing most of the actual corpus; check the target/scope list,
  not just whether the tool ran successfully.
**Rule for next session**: before running or trusting output from any `tools/*.py` or
`*/engine.py`/`prover.py` script in this repo, read what it actually does (open the
file), don't assume the module or file name describes real behavior.

## Lesson 0.6: A local LLM is a second opinion, not an oracle — verify its claims like anyone else's
Asked the locally-hosted `qwen2.5-coder:7b-instruct` (Ollama, on the project's T4 GPU) to
sanity-check 5 new formalizations' physics claims. It correctly confirmed 2 of 3
spot-checked facts and **incorrectly disputed the third** (claimed the bosonic-string
ghost central charge was `c=-24` at weight `λ=2`; the correct, well-established value —
independently re-derived from the cited Polchinski formula and matching the famous
`D=26` bosonic-string result — is `c=-26`; the model likely conflated it with the
unrelated `D-2=24` light-cone transverse count). Useful as a fast first-pass check, not
as a substitute for deriving the answer yourself from a cited source.

## Lesson 0.7: "Ensure RAG/graph/DB is in place" means checking real data flows in, not that the script exists
Three separate indexing tools existed with real, working code, but each was either
never run (SQLite `declarations.db` didn't exist anywhere on disk) or scoped to a
subset of the project that excluded `StringTheoryFormalization`:
- `leangraph`'s declaration-graph builder defaults to `["DoubleFieldTheory",
  "DualScaleM24Formalization", "StringTheoryFoundation"]` only — re-run with an explicit
  `--target` listing all 6 first-party libraries to get real coverage (729 nodes / 1216
  edges vs. the stale 538/807 in the committed `graph/` from before this session).
- `tools/socrateai_oracle.py`'s `_load_corpus` had the same 5-library gap (missing
  `StringTheoryFormalization`) — one-line fix, then re-run `export-json`.
- No script existed that walked the *whole* corpus into `leangraph.cache.LeanCacheManager`
  (the real SQLite backend) — `leangraph/base_graph.py`'s `_index_key_declarations` only
  indexes ~27 hand-picked "landmark" files. Wrote `tools/index_declarations.py` to do a
  full walk; **first regex attempt (copied from `base_graph.py`) undercounted by >2x**
  (746 real declarations vs. 297 found) because it tried to capture the entire
  multi-line signature in one regex and silently dropped anything that didn't fit —
  switched to a line-anchored "match just the declaration head, treat the rest of the
  line as a preview" pattern and cross-checked the total against a plain
  `grep -c '^theorem '`-style count (matched exactly: 746 = 746) before trusting it.
  **General lesson**: when writing any extraction/counting tool over this corpus,
  cross-check its output against an independent, dumber method before trusting the count.

## Lesson 0.8: Keep large data off the root disk, always
Mathlib clones, git submodule clones, Lake build caches, and (new this session) Ollama
model weights all belong on `/mnt/disks/disk-socrateai-local-1/`, never the root disk —
even for a disposable, throwaway experiment (a stray 812MB test clone landed on root
disk under `/tmp` mid-session and had to be relocated). Set `OLLAMA_MODELS` /
`LAKE_ARTIFACT_CACHE` / clone target paths onto the second disk *before* running the
command that downloads, not after.

---

## 1. Executive Summary & Core Results

The **LeanMaster Extended Architecture** aims to mechanize String Theory, T-Duality, and Dual-Scale Generalized Geometry on $K3 \times T^2$ in Lean 4. Rather than writing foundational functional analysis and algebraic geometry from scratch, Phase 0 implemented an automated retrieval and grounding pipeline that harvests existing verified mathematical monoliths:
1. **OpenAI Navier-Stokes & Euler**: Continuous functional analysis on the 2-torus $T^2$.
2. **Anthropic & Callens Fermat's Last Theorem (FLT)**: Discrete algebraic geometry, Kummer surfaces, and modular forms on $K3$.
3. **Physlib, TNLean, LeanQuantum, and LeanStatLearning**: Spacetime gauge metrics, $O(D,D;\mathbb{Z})$ doubled geometry, and tensor networks.

### Ground Truth Census of Retrieved Foundations
Across 7 cloned repositories in [`lean4basesource/`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/lean4basesource):
- **Total Mechanized `.lean` Files**: **125,790**
- **Total Lines of Code**: **28,277,226**
- **Theorems and Lemmas**: **961,898**
- **Definitions and Structures**: **108,062**
- **Directly Verified Macroscopic Blocks**: **23 / 29 (79.3%)**
- **Weighted Foundation Theory Coverage**: **96.9%** (far exceeding the 60.0% milestone requirement)

---

## 2. Key Mathematical Insights: Continuous vs Discrete Duality

String compactification on $M_{10} = M_4 \times (K3 \times T^2)$ requires unifying two historically disconnected domains of mechanized mathematics:

### Lesson 1.1: The Continuous Sector ($T^2$) via OpenAI Navier-Stokes
- **Formal Bridging Module**: Implemented [`StringTheoryFormalization/NSMath/OpenAIBridging.lean`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/StringTheoryFormalization/NSMath/OpenAIBridging.lean), which formally links OpenAI's `NavierStokes.TorusInverse` and `Euler.ParentEulerSobolev` into Lean 4 string theory:
  - Frequencies in $\mathbb{Z} \times \mathbb{Z}$ (`TorusFrequency`) on the universal cover $\mathbb{R}^2$.
  - Polynomial weight function $w(k) = 1 + |k_1| + |k_2|$ (`torusWeight`) and rapid decay configurations (`IsRapid`).
  - Basis mode expansions $\exp(2\pi i (k_1 x_1 + k_2 x_2))$ and coordinate swap involution $\sigma: (x, y) \mapsto (y, x)$ (`swapTorusCoordinates`).
  - Continuous Sobolev path evolution classes (`ContinuousTorusEvolution`) with strong Euler regularity.
- **Sobolev Spaces $H^s(T^2)$**: Continuous target-space metric deformations and wave/heat flows require fractional Sobolev spaces for arbitrary $s \in \mathbb{R}$. OpenAI's Euler/NS formalization directly supplied:
  - $H^s$ norms and continuous embeddings $H^s(T^2) \hookrightarrow C^0(T^2)$ for $s > 1$.
  - Torus Fourier multipliers $\mathfrak{F}$ and Calderón-Zygmund singular integral bounds (`Rapid.mul_linear`).
  - Mild PDE solutions via Duhamel integrals $u(t) = e^{t\Delta} u_0 + \int_0^t e^{(t-s)\Delta} B(u(s), u(s)) ds$ with Banach-space Picard-Lindelöf contraction.
  - A priori energy dissipation inequalities $\frac{d}{dt} \|u\|_{L^2}^2 + 2\nu \|\nabla u\|_{L^2}^2 \le 0$ preventing metric blow-ups.
- **Moduli Dynamics & Cosmology**:
  - The Picard spectral radius iteration ($\rho = 18$) and stiff differential integrators (BDF2 / Implicit Euler A-stability) map cleanly to moduli space relaxation.
  - Primordial cosmological perturbations (Mukhanov-Sasaki) and Bunch-Davies vacuum normalization were established via Gaussian elliptic operators.

### Lesson 1.2: The Discrete Sector ($K3$) via Anthropic & Callens FLT
- **Kummer Orbifold Resolution**: The $T^4/\mathbb{Z}_2$ singular locus consists of 16 $A_1$ singularities. The Fermat formalization's modular curve blowup mechanisms provided:
  - Exceptional $(-2)$-curves $E_i$ with exact intersection matrix $E_i \cdot E_j = -2\delta_{ij}$.
  - The Kummer lattice contribution $\sum E_i^2 = -32$.
- **Lattices and Derived Auto-Equivalences**:
  - Mukai lattice $\widetilde{H}(K3, \mathbb{Z}) \cong \Gamma^{4,20} \cong 4U \oplus 2E_8(-1)$ with even unimodular signature $(4, 20)$ and inner product $\langle (r_1, c_1, s_1), (r_2, c_2, s_2) \rangle = c_1 c_2 - r_1 s_2 - r_2 s_1$.
  - Fourier-Mukai transforms $\Phi_{\mathcal{E}}: D^b(K3) \to D^b(K3)$ inducing isometries on the Mukai lattice.
- **Modular Forms & BPS Counting**:
  - Mathieu group $M_{24}$ (order 244,823,040), character tables, and elliptic genus $Z_{K3}(\tau)$.
  - Exact Rademacher expansion yielding the BPS invariant ratio $77/60$.
  - $SL(2, \mathbb{Z})$ modular transformations on the upper half-plane $\mathbb{H}$ ($\mathrm{Im}(\tau) > 0$).

### Lesson 1.3: The Doubled Metric & Dual Scale Synthesis
- Hitchin's Generalized Complex Geometry and T-duality on $K3 \times T^2$ require the doubled $O(D,D;\mathbb{Z})$ split-signature metric $\eta = \begin{pmatrix} 0 & I \\ I & 0 \end{pmatrix}$.
- In [`ODDMetric.lean`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/StringTheoryFormalization/StringDynamics/ODDMetric.lean), we verified $\eta^T = \eta$ and $\eta_{D=1} = \begin{pmatrix} 0 & 1 \\ 1 & 0 \end{pmatrix}$.
- In [`TDualityGysin.lean`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/StringTheoryFormalization/StringDynamics/TDualityGysin.lean), T-duality is proved as an involution $s \mapsto s$ swapping momentum $n$ and winding $w$, coupled with the Gysin pushforward $\pi_*: H^*(K3 \times S^1) \to H^*(K3)$.
- Gukov-Vafa-Witten superpotential $W = \int_{K3 \times T^2} (F_3 - \tau H_3) \wedge \Omega$ and Tadpole cancellation $\sum Q + \text{flux} = \chi(K3\times K3)/24 = 24$ (corrected 2026-09-18: an earlier version wrote $\chi(K3)/24$, which is the D3 charge of one wrapped D7-brane; see `TadpoleCancellation.lean`, Tripathy–Trivedi (2.3), DRS l. 640) bridge the discrete Euler characteristic ($\chi = 24$) with continuous flux integrals.

---

## 3. Engineering & Toolchain Lessons Learned

### Lesson 2.1: The "Mathlib Clone Trap" in Lean 4 Projects
- **Issue**: Standard `lake build` or `lake test` invocations automatically check dependencies declared in `lakefile.toml`. If `mathlib` is listed as a remote git dependency, Lake will initiate a multi-gigabyte download and trigger a massive CPU build of Mathlib oleans.
- **Resolution**:
  - Pinned the toolchain to `leanprover/lean4:v4.33.1`.
  - Implemented decoupled symbolic checks in [`workflow.py`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/workflow.py) (`tool_run_cpu_aesop`), verifying `.lake/packages/mathlib` non-blockingly and avoiding unconstrained Lake runs until pre-compiled olean caches are hydrated.

### Lesson 2.2: Filesystem I/O with 120,000+ Files & Single-Theorem Architectures
- **Issue**: Anthropic's Fermat repository uses a modular, atomic design where **each theorem is an individual `.lean` file** (29,511 in `Theorems/`, 29,513 in `P2M/`). Naive recursive filesystem traversals (`Path.rglob("*.lean")`) entered deep `.git/` trees (thousands of packfiles/objects), causing `workflow.py` scans to take 20–40 seconds.
- **Resolution**:
  - Refactored `FoundationRetriever.get_available_repositories` to use `os.walk` with explicit in-place pruning (`dirs.remove(".git")`).
  - Added a cache file (`lean4basesource/.repo_counts.json`) that caches repo file counts, reducing subsequent status checks from ~15 seconds to **< 1 millisecond**.
  - Added `lean4basesource/` to [`.gitignore`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/.gitignore) to prevent Git from treating the subrepositories as dirty untracked submodules.

### Lesson 2.3: Comments vs Code in AST / Line Parsing
- **Issue**: In `pipeline_orchestrator.py`, a simple substring search for `"sorry"` matched documentation comments mentioning `sorry axioms` (e.g. `-- Status: VERIFIED (0 sorry axioms)`), falsely inflating the project's incomplete goal tally.
- **Resolution**:
  - Implemented single-line and multiline comment stripping (`--` and `/- ... -/`) prior to counting `sorry` tokens.
  - Pinned verified block tallies to strictly code-level axioms.

---

## 4. Antigravity Agent & Execution Architecture

### Lesson 3.1: Dual Local/Cloud Targeting
- The common agent in [`workflow.py`](file:///home/xavkal/SocrateAI-Scientific-Agora-LeanMaster/workflow.py) (`LeanMasterAntigravityAgent`) operates across three deployment targets:
  1. `DeploymentTarget.LOCAL`: Queries the local Ollama daemon (`deepseek-prover:7b-q4`) at `http://localhost:11434/v1`. If the model weights are not yet pulled, it alerts the user and falls back gracefully to deterministic symbolic tooling.
  2. `DeploymentTarget.GCP`: Integrates with Vertex AI / Cloud Composer to dispatch GKE Autopilot spot workers and trigger Cloud TPU v5e RL training cycles.
  3. `DeploymentTarget.API_ZERO_GPU`: Executes pure symbolic rules (`aesop`, `ring`, `positivity`, `omega`) and Blueprint DAG ingestion.

### Lesson 3.2: Replay Buffer & Reinforcement Learning Feedback
- Implemented persistent experience replay logging in `.replay_buffer.json` via `ProofTrajectory`.
- Each successful or attempted tactic sequence records the block ID, phase index, tactic array, outcome (`closed`, `failed`), and scalar reward. This provides direct ground truth for future PPO/DPO training cycles on Cloud TPUs.

---

## 5. Phased Roadmap Execution State

```
[Phase 0: Blueprint & Foundations]  =====> 100% COMPLETE (Released)
  ├── 125,790 foundational Lean 4 files indexed
  ├── 96.9% weighted foundation theory coverage
  ├── 23/29 blocks verified (0 sorry)
  └── Blueprint & RAG context exported to foundation_retrieval_map.json

[Phase 1: Local CPU Optimization]  =====> NEXT STEP
  ├── Mathlib cache hydration (lake exe cache get)
  ├── Micro-tactic Aesop rule generation for FR1-FR6
  └── Memory bounds (16-32GB CPU RAM)

[Phase 2: Edge LLM Prover]        =====> READY
  ├── Ollama deepseek-prover:7b-q4 local serving
  └── Streamed tactic generation with temperature 0.2

[Phase 3: GCP Swarm & TPU RL]     =====> SPECIFIED
  ├── GKE Autopilot spot vLLM workers
  ├── TPU v5e continuous PPO/DPO loop
  └── Weekly Hugging Face weight synchronization
```

---

## 6. Release Verification Checklist

- [x] All 7 foundational repositories cloned and indexed in `lean4basesource/`.
- [x] `foundation_retrieval_map.json` generated and verified (96.9% theory coverage).
- [x] `pipeline_orchestrator.py` accurately tracking 29 blocks (19 fully mechanized locally, 23 grounded in foundations).
- [x] `workflow.py` equipped with `--basesource`, `--retrieve`, `--coverage`, and `--phase` commands.
- [x] `.gitignore` updated to ignore `lean4basesource/` and `.replay_buffer.json`.
- [x] Git commits structured and pushed to `origin/main`.
- [x] Release tag `v0.1.0-phase0` created and pushed.

---

## 7. Lessons Learned: Phase 2 Dual-Scale Theory & Mathieu $M_{24}$ Moonshine

### Lesson 2.1: Pure Lean 4 Core vs. Heavy Monolithic Dependencies
- Monolithic Mathlib dependencies introduce gigabytes of remote network fetching and cache fragility that can block automated agents.
- Core algebraic, group-theoretic, and topological invariants (e.g. Diophantine tadpole equations, Gysin exact sequences, K-theory difference classes, and Mathieu $M_{24}$ cross-multiplications) can be formalized directly in pure Lean 4 core (`Init`, `Std`, `decide`, `omega`, `ac_rfl`).
- A self-contained package (`DualScaleM24Formalization`) cold-builds via Lake in **~7 seconds** across 14 targets with **zero sorry axioms**, ensuring deterministic and lightning-fast CI/CD certification.

### Lesson 2.2: Stream 0 Epistemic Governance (`SocrateAI-Mathesis`)
- The 5-tier calculus ($X < C < L < B < A$) prevents epistemic claim contamination across distributed agent sessions.
- The **Soundness Transitivity Theorem** (`no_kernel_claim_rests_on_weaker` and `tier_le_of_depends`) proved that if any dependency in the transitive closure of a claim has tier below A, the citing claim cannot be certified as Tier A.
- Enforcing Gate 1 (exact $\mathbb{Q}/\mathbb{Z}$ arithmetic with failing negative controls) immediately identified that un-doubled components $(45, 231)$ satisfy $231 / (4 \times 45) = 77/60$ identically, proving the deep structural consistency of the $M_{24}$ character decomposition.

### Lesson 2.3: Mechanized Triad Closed Loop & Graph Invariants
- In TDA Mapper 1-skeleton graph extraction from Langevin point clouds, the first Betti number requires accounting for the number of connected components $b_0$:
  $$\beta_1 = E - V + b_0$$
  For $V = 187$ nodes and $E = 557$ edges, the 6 isolated defect clusters ($b_0 = 6$) in the multi-well landscape rigorously account for the exact observed Betti number $\beta_1 = 557 - 187 + 6 = 376$.
- Singularity resolution in the dual-scale metric $R_{\text{eff}} = \max(R, \alpha'/R) \ge \sqrt{\alpha'} > 0$ is proved constructively as a geometric theorem (`genesis_no_singularity`), ensuring that **regularization is never an axiom**.

