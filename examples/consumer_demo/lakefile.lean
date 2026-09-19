import Lake
open Lake DSL

/-!
Minimal downstream project that builds ON TOP of LeanMaster (verified 2026-09-17: `lake build`
succeeds, 3709 jobs; `Demo.lean` proves a new fact from LeanMaster theorems with standard axioms only).

Two ways to depend on LeanMaster — keep exactly one `require`:

A. Same machine as a LeanMaster checkout (fast: reuses its built Mathlib, downloads nothing).
   Set `packagesDir` to LeanMaster's package directory and require it by path.

B. Any machine: require it from git at a release tag, then `lake exe cache get` for Mathlib.
   Your `lean-toolchain` MUST be the same as LeanMaster's (leanprover/lean4:v4.34.0-rc2), and you must
   not require a different Mathlib revision (LeanMaster pins Mathlib v4.34.0-rc2 since the
   2026-09-19 toolchain migration; tags up to v3.28.0 pin v4.33.1).
-/

package «consumer-demo» where
  -- (A) only: reuse LeanMaster's packages (Mathlib etc.). Delete this line for (B).
  packagesDir := "/mnt/disks/disk-socrateai-local-1/leanmaster/lake/packages"
  leanOptions := #[⟨`maxHeartbeats, (1000000 : Nat)⟩]

-- (A) local path
require «SocrateAI-Scientific-Agora-LeanMaster» from
  "/home/callensxavier_gmail_com/SocrateAI-Scientific-Agora-LeanMaster"

-- (B) git tag — use instead of (A) on other machines:
-- require «SocrateAI-Scientific-Agora-LeanMaster» from git
--   "https://github.com/xaviercallens/SocrateAI-Scientific-Agora-LeanMaster" @ "v2.1.0"

@[default_target]
lean_lib «Demo» where
  roots := #[`Demo]
