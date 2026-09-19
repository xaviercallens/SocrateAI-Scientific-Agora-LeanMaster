export const meta = {
  name: 'stream8-closure',
  description: 'Compile and gate GTVWPoint.lean (Stream 8 §14), then update the status documents',
  phases: [{ title: 'Compile' }, { title: 'Gates' }, { title: 'Docs' }],
}

// D3 of docs/NEXT_DIRECTIONS.md. One Lean process at a time: this VM has 29 GB and no swap, and a second
// build halves the page cache (LL.md §S8.2). Run nothing else Lean-heavy while this runs.
const GUARD = 'python3 -m leanstack plan --budget-gb 22'

const compile = await agent(
  `In /mnt/disks/disk-socrateai-local-1/callensxavier_home_data/SocrateAI-Scientific-Agora-LeanMaster:
   1. Check no other lake/lean process is running (pgrep -af "lake build|^lean "); if one is, stop and report.
   2. Compile DualScaleDyons/GTVWPoint.lean with
      lake env lean -DmaxHeartbeats=1000000 -DmaxRecDepth=8000, under an RSS watchdog that kills the lean PID
      (never pkill -f with a pattern that matches your own command line) above 12 GB or when MemAvailable < 3 GB.
      Record peak RSS and wall time.
   3. If a decide +kernel theorem is too heavy, split it into its own module, as K3EnhancementSO40/SO44 were.
   Report: compile result, peak RSS, any error text verbatim.`,
  { label: 'compile:gtvw', phase: 'Compile' })

const gates = await agent(
  `Add DualScaleDyons.GTVWPoint to DualScaleDyons.lean, then run the five gates, one at a time:
   lake build DualScaleDyons; grep -nE "\\bsorry\\b|\\badmit\\b|native_decide" on the new file (must be empty);
   python3 tools/axiom_audit.py DualScaleDyons (0 failing, only propext/Classical.choice/Quot.sound);
   python3 tools/statement_lock.py --update on the new file then --check on DualScaleDyons/*.lean (ADDED only,
   never CHANGED); and two mutation controls that must each fail the kernel check (e.g. a wrong B-field entry,
   a wrong Gram value). Report every number; do not round a partial result up.`,
  { label: 'gates', phase: 'Gates' })

await agent(
  `Update docs/VERIFIED_FOUNDATION.md (new release paragraph with the theorem count), README.md (audited totals
   and per-library table), and the status line of docs/STREAM8_WHICH_K3.md for §14. Then commit with a message
   ending in the repository's Co-Authored-By line, tag, and report the exact numbers. Do not push or release:
   the owner decides that.
   Context from the previous steps: ${JSON.stringify({ compile, gates }).slice(0, 4000)}`,
  { label: 'docs', phase: 'Docs' })

return { compile, gates }
