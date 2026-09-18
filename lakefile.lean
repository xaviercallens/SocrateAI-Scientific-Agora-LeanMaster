import Lake
open Lake DSL

package «SocrateAI-Scientific-Agora-LeanMaster» where
  srcDir := "."
  -- Heavy algebraic-geometry / PDE unification needs raised limits.
  leanOptions := #[
    ⟨`maxHeartbeats, (1000000 : Nat)⟩,
    ⟨`maxRecDepth, (8000 : Nat)⟩
  ]

-- Mathlib pinned at tag v4.33.1 (commit 0df444a360eaa60ab8c11dca51a86af692955474).
-- Verified 2026-09-15: that tag's `lean-toolchain` is `leanprover/lean4:v4.33.1`, an exact
-- match for this project's `lean-toolchain`, so the upstream olean cache is usable.
-- NOTE: earlier docs pinned `db584cd6d46...`; that is the `v4.33.0` tag (toolchain v4.33.0)
-- and would have produced a toolchain-mismatched, unusable cache. See docs/INFRA_SETUP.md.
require "leanprover-community" / "mathlib" @ git "v4.33.1"

-- === Mathlib-free libraries (the verified Tier A core; build with zero packages) ===

@[default_target]
lean_lib «StringTheoryFoundation» where
  roots := #[`StringTheoryFoundation]

@[default_target]
lean_lib «DualScaleM24Formalization» where
  roots := #[`DualScaleM24Formalization]

@[default_target]
lean_lib «DoubleFieldTheory» where
  roots := #[`DoubleFieldTheory]

@[default_target]
lean_lib «DualScaleValidation» where
  roots := #[`DualScaleValidation]

@[default_target]
lean_lib «Lean5Corpus» where
  roots := #[`Lean5Corpus]

-- === Stream 1: Mathlib-dependent library (previously unregistered / unbuildable) ===
-- Deliberately NOT a default_target until it builds clean, so `lake build` keeps
-- reporting honest status for the five libraries above.

lean_lib «StringTheoryFormalization» where
  roots := #[`StringTheoryFormalization]

-- === Stream 2: Dual-Scale K3 × T² lattice / T-duality layer ===
-- Separate library so a Stream 2 failure never turns the green Stream 1 core red.
-- Not a default_target until it builds clean; build with `lake build DualScaleStream2`.

lean_lib «DualScaleStream2» where
  roots := #[`DualScaleStream2]

-- === Stream 3: micro/macro dual-scale cosmology pilot ===
-- Separate `lean_lib` so a Stream 3 failure never turns Streams 1/2 red; imports neither.
-- Not a default_target until it builds clean; build with `lake build DualScaleCosmology`.

lean_lib «DualScaleCosmology» where
  roots := #[`DualScaleCosmology]

-- === Stream 4: Mathieu moonshine computed from formulas (imports Stream 2) ===
-- Not a default_target; build with `lake build DualScaleMoonshine`.

lean_lib «DualScaleMoonshine» where
  roots := #[`DualScaleMoonshine]
