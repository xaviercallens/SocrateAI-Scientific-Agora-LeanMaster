# Vendored openai/math files (unmodified)

`openai-math-fd4aeeb2/` holds an **unmodified** copy of selected files from https://github.com/openai/math at commit
`fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb` (2026-10-07, the release that withdrew three Hodge/abelian-eightfold/K3
manuscripts; `history.md` is included). They are distributed under the Apache License 2.0 (`openai-math-fd4aeeb2/LICENSE`);
copyright remains with the original authors. No file was changed.

Included:
- `lean/ComparatorChallenges/TriangularEnergy.{lean,json}`: the universal-optimality challenge statement (sha256 af51979c…0616, identical at adc7f124);
- `lean/ComparatorChallenges/LiebThirring.{lean,json}`: the sharp 1D Lieb–Thirring challenge statement;
- `lean/OAI/Analysis/Triangular/**`, `lean/OAI/Analysis/LiebThirring/**`: the corresponding proof trees;
- `lean/OAI/NumberTheory/DirichletL/LatticeSummability.lean`: the lemma used by D1b;
- `lean/lean-toolchain`, `lean/lake-manifest.json`: the pins (Lean 4.34.1, Mathlib d13f23b7).

This is a **reference snapshot for audit**, not a buildable project: the proof trees import further upstream modules
that are not copied. Build from the upstream repository at the commit above. Our Comparator runs on these two
challenges (both COMPARATOR_ACCEPTS, clean axioms) are in `../verification/openai_math/hypotheses/night_2026-10-08/{TRI_CMP,LT_CMP}/`.
