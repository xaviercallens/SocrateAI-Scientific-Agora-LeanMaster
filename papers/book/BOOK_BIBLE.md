# BOOK BIBLE — rules every chapter author and reviewer follows

**Book**: *The Dual-Scale String: T-Duality, K3 × T², and Their Formalization in Lean 4 — A Student's
Companion*. Audience: a beginning graduate student in physics or mathematics who knows quantum mechanics,
special relativity, linear algebra and a little differential geometry, and has never seen string theory or a
proof assistant. Goal: one homogeneous account — the physics, the mathematics, and what exactly has been
machine-checked — that a student can study from cover to cover.

Repo root: `/home/callensxavier_gmail_com/SocrateAI-Scientific-Agora-LeanMaster` (all paths below are relative to it).

## 1. Sources: read them, do not write from memory
* Foundation texts are in `papers/foundations/*.txt` (metadata: `papers/foundations/MANIFEST.md`).
  Section → line-number maps: `papers/book/generated/source_toc.md`. Read the relevant line ranges with
  `sed -n 'A,Bp'` or `grep -n`; never load a whole `.txt`.
* Every equation, definition or claim taken from the literature carries a pinned source:
  `\source{GPR §2.4, ll.~1355--1373}` = short key + section + line range in the `.txt` you actually read.
  Short keys are fixed in §6. If you cannot find a claim in the sources, either derive it on the page or
  mark it "standard; not checked against a source in this book's library" — do not invent a citation,
  an equation number, a page number or a historical date.
* pdftotext garbles formulas. Reconstruct each formula from the surrounding text and check it by an
  independent route (dimensional analysis, a limiting case, a two-line derivation, or sympy via
  `~/venv/bin/python`). State conventions (α′, signature, normalization of B) when first used; this book
  uses the conventions of §5 below.

## 2. Lean: say exactly what is proved
* Catalogue of every compiled declaration: `papers/book/generated/lean_catalogue.md` (grep it by module).
  Before quoting a declaration, open the `.lean` file and read the statement. Quote statements verbatim
  in `leancode` environments (lines ≤ 80 characters; you may re-wrap lines and drop the proof, writing
  `:= by ...` — never alter the statement).
* State in words what the Lean statement literally says, no stronger: one direction stays one direction;
  a statement about integer or rational toy quantities is described as that; a theorem about a fixed
  matrix is not a theorem about all lattices. Several older libraries (`DoubleFieldTheory`,
  `StringTheoryFoundation`, `DualScaleM24Formalization`, `Lean5Corpus`, `DualScaleValidation`) model physical
  quantities by integers or rationals and prove arithmetic consequences. Describe these honestly as
  *arithmetic shadows* of the physical statement and explain what a faithful formalization would need.
* Tiers, used on every claim that matters: `\TA` kernel-checked in Lean 4 (name the declaration);
  `\TL` established in the literature (pinned source), not formalized here; `\TC` conjecture or a proposal of
  this programme. The identification of a Lean object with a physical system is never Tier A.
* Axioms: all audited theorems depend only on `propext`, `Classical.choice`, `Quot.sound`. Never write
  "zero axioms", "100%", "fully verified string theory", "proves string theory", "certified physics".
* Checks done only by computer algebra (sympy) are "symbolic checks", not Tier A.

## 3. Style: a textbook, not a report
* Each chapter: (1) opening paragraph — the question the chapter answers and why a student should care;
  (2) development with full derivations — show intermediate steps a student would otherwise have to
  reconstruct, explain the physics behind every formal step (what is being measured, what would go wrong
  otherwise, which limit is classical); (3) at least one worked example with numbers; (4) `physicsbox`
  for intuition, `pitfallbox` for classic mistakes, `historybox` only for facts present in the sources;
  (5) a section "What the machine has checked" with `leanbox`es: statement, plain-language reading, proof
  idea in two or three sentences, tier table; (6) `summarybox`; (7) 6–10 exercises graded (★, ★★, ★★★),
  some asking the student to state or prove a small lemma in Lean; (8) "Further reading" with pinned sources.
* Plain, precise sentences. Define every symbol at first use in the chapter. Prefer a derivation to an
  assertion. No marketing language, no superlatives about this project, no "revolutionary", no "bible".
* Figures: TikZ only, simple and correct (winding string on a cylinder, torus lattice, Dynkin diagram,
  Hodge diamond, moduli-space fundamental domain...). 1–3 per chapter where they help.
* Cross-reference other chapters as `\cref{ch:<slug>}` (labels in §7). A chapter compiled alone will show
  these as undefined — that is expected and is the ONLY permitted kind of undefined reference.

## 4. LaTeX contract
* File: `papers/book/chapters/<id>_<slug>.tex`, starting with `\chapter{Title}\label{ch:<slug>}`. No
  preamble, no `\usepackage`, no `\newcommand` (use `papers/book/preamble.tex` macros: `\ap`, `\Z`, `\R`,
  `\C`, `\HH`, `\Tr`, `\Odd{d}`, `\OddR{d}`, `\SLZ`, `\Mtf`, `\KT`, `\dd`, `\ii`, `\ee`, `\lean{}`, `\source{}`,
  `\TA \TL \TC`; environments theorem, proposition, lemma, corollary, conjecture, definition, example,
  exercise, remark, physicsbox, leanbox, pitfallbox, historybox, summarybox, leancode).
* Labels are prefixed with the chapter slug: `\label{eq:<slug>:mass}`, `fig:<slug>:...`, `thm:<slug>:...`.
* Index important terms with `\index{T-duality}`, `\index{Narain lattice}` (about 10–25 per chapter).
* No bibliography environment in chapters: cite with `\source{...}`; the editor builds the bibliography.
* Compile: `papers/book/compile_chapter.sh chapters/<file>.tex` (pdfLaTeX twice, isolated build dir).
  Required: no `! ` errors, no unknown-unicode errors, no overfull boxes > 15pt, page count within target.
  Unicode is allowed only inside `leancode` and only for symbols already mapped in the preamble.
* Touch only your own chapter file. Never run `git`, never edit `.lean` files, never compile in
  `papers/publication/`.

## 5. Conventions (fixed for the whole book)
* α′ has dimension length²; string length ℓ_s = √α′; tension T = 1/(2πα′). Mostly-plus signature.
* Circle of radius R: X ~ X + 2πR; momentum n/R, winding w R/α′; closed-string mass formula
  M² = n²/R² + w²R²/α′² + (2/α′)(N + Ñ − 2), level matching N − Ñ = n w. T-duality R ↦ α′/R, n ↔ w.
  Verify against Tong §8 before use; if a source uses another normalization, convert and say so.
* Doubled charge vector Z = (w, n) or (n, w): follow the Lean convention of the module being described
  and state it. η = [[0,1],[1,0]] (block form). Generalized metric in Lean (`DualScaleStream2/DFT/
  GeneralizedMetric.lean`): H(G,B) = [[G − B G⁻¹ B, B G⁻¹], [−G⁻¹ B, G⁻¹]].
* Lattice signature written (n₊, n₋). K3 lattice: 3U ⊕ 2E8(−1), signature (3,19). Mukai: (4,20).
* Moonshine: A_n denotes the EOT coefficients 45, 231, 770, 2277, ...; multiplicities are 2A_n.
* "Dual-scale" = this programme's name for treating R and α′/R on an equal footing, with effective scale
  R + α′/R ≥ 2√α′ (and tr G + tr G⁻¹ ≥ 2d). The inequality is Tier A mathematics; its role as a physical
  minimal length or cosmological regulator is Tier L where a source says so (string gas cosmology) and
  Tier C otherwise.

## 6. Source keys
Tong = tong_string_theory_0908_0333 · GPR = giveon_hep-th_9401139 · AAL = alvarez_alvarezgaume_lozano_tduality_hep-th_9410237 ·
Pol = polchinski_tasi_dbranes_hep-th_9611050 · HZ = hull_zwiebach_0904_4664 · HHZ = hohm_hull_zwiebach_generalized_metric_1006_4823 ·
AMN = aldazabal_marques_nunez_dft_review_1305_1907 · Asp = aspinwall_hep-th_9611137 · Huy = huybrechts_K3Global ·
DRS = dasgupta_rajesh_sethi_hep-th_9908088 · GVW = gukov_vafa_witten_hep-th_9906070 · SVW = sethi_vafa_witten_hep-th_9606122 ·
BB = becker_becker_eightfolds_hep-th_9605053 · GKP = giddings_kachru_polchinski_hep-th_0105097 · Gra = grana_flux_compactifications_hep-th_0509003 ·
Pal = palti_swampland_1903_06239 · EOT = eguchi_ooguri_tachikawa_1004_0956 · GHV = gaberdiel_hohenegger_volpato_mathieu_1006_0221 ·
BW = battefeld_watson_string_gas_hep-th_0510022 · CDH = 1204_2779 · CH = 1406_0619 · HMN = 1410_6174 · DMZ = 1208_4074 · Cheng = 1005_5415 ·
GV = gasperini_veneziano_pbb_hep-th_0207130 · LISA = 1702_00786 · EW = 2002_11761 · MVV = 2205_12293 · CKN = hep-th_9803132 · TT = hep-th_0301139 · Sen = hep-th_9605150. Project documents: `docs/STREAM2_WORKFLOW.md`, `LL.md`,
`docs/PAPER_REVISION_BRIEF_2026_09_17.md`, `papers/book/generated/atlas.md`.

## 7. Chapter labels
See `papers/book/chapters.json` (field `slug`; label is `ch:<slug>`).
