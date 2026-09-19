export const meta = {
  name: 'toolchain-migrate-project',
  description: 'Migrate one Lake project to a target Lean toolchain, memory-guarded, gates before merge',
  phases: [{ title: 'Prepare' }, { title: 'Build' }, { title: 'Gates' }],
}

// D5 of docs/NEXT_DIRECTIONS.md. args: { repo: "/abs/path", toolchain: "leanprover/lean4:v4.34.0-rc2",
// mathlib: "v4.34.0-rc2", branch: "toolchain/v4.34.0-rc2" }. One project at a time: this VM cannot build two.
const A = typeof args === 'object' && args ? args : {}
const repo = A.repo, toolchain = A.toolchain || 'leanprover/lean4:v4.34.0-rc2', mathlib = A.mathlib || 'v4.34.0-rc2'
const branch = A.branch || 'toolchain/v4.34.0-rc2'

const prepare = await agent(
  `Project ${repo}. Confirm no lake/lean process is running anywhere on this machine; if one is, stop and report.
   Create a git worktree on the data disk (/mnt/disks/disk-socrateai-local-1/leanmaster/worktrees/) on branch
   ${branch} from the project's default branch, and work only there.
   Set lean-toolchain to ${toolchain}; set the Mathlib require to ${mathlib} (and any other pinned dependency to a
   revision compatible with it); run lake update and lake exe cache get. Report the resulting lake-manifest.json
   revisions and anything that failed to resolve.`,
  { label: 'prepare', phase: 'Prepare' })

const build = await agent(
  `In that worktree, build every first-party library module by module in topological order, one Lean process at a
   time, under an RSS guard (kill the process group at the per-module budget or when MemAvailable < 2 GB; never
   pkill -f a pattern matching your own command line). Fix compile errors caused by the version change: proofs,
   imports and definition internals only — NEVER a theorem statement. If a statement cannot be kept, stop and
   report it instead of changing it. Report per module: result, wall time, peak RSS, and every source change with
   its reason. Setup: ${JSON.stringify(prepare).slice(0, 4000)}`,
  { label: 'build', phase: 'Build' })

await agent(
  `Run the project's gates on the migrated tree: full build, sorry/admit/native_decide grep, the axiom audit per
   library (theorem counts must match the pre-migration numbers), the statement lock check (no CHANGED), and one
   negative control. Update the version strings in CLAUDE.md, README and docs, commit on ${branch}, and report the
   exact numbers. Do not merge, push or tag: the owner decides.
   Build: ${JSON.stringify(build).slice(0, 4000)}`,
  { label: 'gates', phase: 'Gates' })

return { prepare, build }
