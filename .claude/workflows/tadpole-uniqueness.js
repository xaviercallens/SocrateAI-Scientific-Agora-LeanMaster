export const meta = {
  name: 'tadpole-uniqueness',
  description: 'Prove that the corrected T^2/Z2 orientifold tadpole solution is the only integer one',
  phases: [{ title: 'Survey' }, { title: 'Formalize' }, { title: 'Gates' }],
}

// D2 of docs/NEXT_DIRECTIONS.md. The v3.21.0 correction is recorded in
// docs/reviews/2026-09-18_dualscalesimulator_orientifold_note.md; read it before touching the statement.
const survey = await agent(
  `Read StringTheoryFoundation/StringTheory/TadpoleCancellation.lean, docs/reviews/*orientifold*, and the Stream 8
   sections that cite the tadpole budget. Report: the exact budget equation as currently formalized, which
   quantities are Tier A and which are Tier L (with their paper pins), and what "the only integer solution" would
   have to quantify over (charges per O-plane and per D-brane, their numbers, the flux term) for the statement to
   be both true and non-trivial. Propose the precise Lean statement; do not write it yet.`,
  { label: 'survey', phase: 'Survey' })

const formalize = await agent(
  `Using this proposal, add the uniqueness theorem to the tadpole file (or a new module if the file is locked
   tight): a finite enumeration over the integer solutions of the budget with the geometric constraints, proved by
   decide +kernel, plus a docstring separating Tier A (the arithmetic) from Tier L (that these are the physical
   charges, with pins). Never change an existing locked statement; only add.
   Proposal: ${JSON.stringify(survey).slice(0, 4000)}`,
  { label: 'formalize', phase: 'Formalize' })

await agent(
  `Run the five gates for the affected library, one Lean process at a time, plus two mutation controls (a wrong
   O-plane charge, a wrong brane count) that must each be caught. Update docs/VERIFIED_FOUNDATION.md and README
   counts, commit, and report the numbers. Do not push.
   Work done: ${JSON.stringify(formalize).slice(0, 4000)}`,
  { label: 'gates', phase: 'Gates' })

return { survey, formalize }
