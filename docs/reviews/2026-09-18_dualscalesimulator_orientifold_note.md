# External note: orientifold and tadpole files (from the DualScaleSimulator project)

**Received:** 2026-09-18, by cross-session message from the DualScaleSimulator Claude session. The full note is in
that repository at `audit/LEANMASTER_NOTE_orientifold.md`, commit `acd3b60`. The source PDFs it cites were on the
unpushed branch `loop/k3t2-rigidity`.
**Validated by:** the LeanMaster session, 2026-09-18/19. The sources were downloaded again from arXiv and pinned in
`papers/foundations/MANIFEST.md`. None of the peer's text copies were used.
**Decision:** Xavier approved the correction on 2026-09-19 ("I approve the correction and continue"). Release: `v3.21.0`.

## The note's claims, summarised (see the original for the full text)

1. `StringTheoryFoundation/StringTheory/TadpoleCancellation.lean` puts 16 O7⁻ planes at the `T⁴/ℤ₂` fixed points and
   32 D7-branes of charge +2, and states the D3 condition as `N_D3 + ½∫H∧F = χ(K3)/24 = 1`. Tripathy–Trivedi (TT)
   §2.2 has 4 O7-planes at the `T²` fixed points, 16 D7-branes, and eq. (2.3) `½N_flux + N_D3 = 24`.
2. `DualScaleM24Formalization/Moonshine/KummerTadpole.lean` uses 16 D7 at +4 and 4 O7 at −16. That is 4× TT's
   normalisation (D7 +1, O7 −4). The note asks which normalisation Gimon–Polchinski (3.12) uses.
3. `DualScaleStream2/Flux/Tadpole.lean` `tadpole_budget` agrees with TT (2.3) when flux := ½N_flux. The note
   suggests citing TT next to DRS.

## Validation, claim by claim

| # | Verdict | Evidence (pinned) |
|---|---|---|
| 1a — 16 O7 at `T⁴/ℤ₂` wrong | **Confirmed** | TT `hep-th_0301139.txt` ll. 160–163 (4 fixed points on `T²`, one O7 each, 16 D7). Sen `hep-th_9605150.txt` l. 242: "each of the four orientifold planes carry −4 units of seven-brane charge, which need to be neutralized by putting sixteen seven branes". The book's own table (ch. 25, Polchinski eq. (93)) independently shows the flaw: 16 planes belong to `p = 5`, and the file's plane/brane ratio `−4/+2 = −2` matches no `p`. |
| 1b — D3 target `χ(K3)/24 = 1` wrong | **Confirmed** | TT eq. (2.3), l. 171: 24. DRS `dasgupta_rajesh_sethi_hep-th_9908088.txt` l. 640: `χ/24 = 24` for `K3 × K3`. `χ(K3)/24 = 1` is the D3 charge of one D7-brane wrapped on K3 (TT ll. 165–167; GKP l. 463). |
| 2 — KummerTadpole normalisation | **Partly confirmed; the finding is stronger than the question asked** | The ×4 rescaling keeps the invariant ratio `−4` and is legitimate (book ch. 25 pitfall box). However, Gimon–Polchinski eq. (3.12) (`hep-th_9601038.txt` l. 503) is a Chan–Paton projection for 5-branes in type I on `T⁴/ℤ₂`, not a charge equation. The actual tadpole result is (4.1), ll. 842–848: `n₉ = n₅ = 32`. The citation was a miscitation, not a choice of normalisation. |
| 3 — `tadpole_budget` consistent | **Confirmed** | Same 24 as TT (2.3) and DRS. The `TadpoleConstraint.lean` docstring had recorded an unresolved "normalization mismatch". It is now resolved: the bare `24` is `χ(K3 × K3)/24`. |

## Changes made (`v3.21.0`)

- **`TadpoleCancellation.lean`: statements corrected (a documented review correction).**
  - Removed: `total_O7_charge_is_minus_64`, `total_D7_charge_is_64`, `d3_tadpole_target_is_one`.
  - Added: `num_O7_planes_is_4`, `total_O7_charge_is_minus_16`, `total_D7_charge_is_16`, `plane_brane_ratio`,
    `local_cancellation`, `oplane_total_independent` (Polchinski's table, `3 ≤ p ≤ 9`), `oplane_p7`,
    `d3_charge_per_D7_is_one`, `d3_tadpole_target_is_24`, `induced_d3_charge_matches_target` (`4·2 + 16·1 = 576/24`).
  - `d7_tadpole_cancellation` keeps its statement; the values underneath it changed.
- **`KummerTadpole.lean`, `UseCase3_FrontierTriad.lean`: docstrings only.** Units are now stated (`μ₇/4`), the
  O7-planes are placed on `T²/ℤ₂`, and GP (3.12) is replaced by TT and Sen. `KummerTadpole.lean` also gets the new
  theorem `o7_d7_ratio`, and its ρ = 20 claim is limited to rank-2 transcendental lattices.
- **`FTermPotential.lean`, `TadpoleConstraint.lean`, `LL.md`:** documentation updated.
- **Book:** ch. 25 (pitfall box; the Remark on the D3 charge is now pinned to TT, where it previously said "not
  checked against a source"; Lean box; claims table; exercise) and ch. 36 (atlas prose, line pins). New source keys
  TT and Sen.
- **Paper 3:** the abstract and Definition are reworded to `K3 × T²/ℤ₂` with units, and a revision note is added.
  No Lean statement of the paper changed.
