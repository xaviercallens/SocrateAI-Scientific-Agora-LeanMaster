export const meta = {
  name: 'stream9-orientifold-t6',
  description: 'Stream 9: the Narain lattice Gamma_{6,6} of T^6 and the orientifold involutions, certified',
  phases: [{ title: 'Scope' }, { title: 'Lattice' }, { title: 'Involutions' }, { title: 'Gates' }],
}

// D1 of docs/NEXT_DIRECTIONS.md. Motivation: K3 x T^2 is N = 4 and non-chiral (Stream 7); orientifolds of T^6
// reach N = 1 while staying finite arithmetic. This workflow builds the lattice layer only — no physics claim.
const scope = await agent(
  `In the LeanMaster repository, prepare Stream 9 without writing Lean yet.
   1. Read docs/COMMUNITY_ROADMAP.md (P-1), docs/STREAM7_HYPOTHESIS_INVENTORY.md and Stream 8 §12–§14 for what is
      already settled, and DualScaleStream2 for the existing O(d,d;Z) machinery (reuse it; do not duplicate).
   2. Pin the literature: for T^6/Gamma orientifolds and their tadpole conditions, find the primary sources,
      download to papers/foundations/ with a MANIFEST entry and sha256 (pdftotext for the .txt), and give exact
      line ranges for every statement you intend to use.
   3. Propose the Lean statements for the lattice layer (Gamma_{6,6} explicit, its automorphism conditions, the
      involutions defining the orientifold, the fixed loci count), each tagged Tier A or Tier L with its pin.
   Report the proposals and the pins. Write no .lean file in this step.`,
  { label: 'scope', phase: 'Scope' })

const lattice = await agent(
  `Create DualScaleStream2/Geometry/NarainT6.lean (or the path matching the library's layout) with the
   Gamma_{6,6} lattice: an explicit Gram matrix, evenness, unimodularity (fraction-free determinant as in
   K3Enhancement.bareiss), and the O(6,6;Z) generators already available in Stream 2 if they apply. Keep each
   decide +kernel declaration small and measure peak RSS; if a check exceeds ~10 GB, split it into its own module.
   Proposals: ${JSON.stringify(scope).slice(0, 4000)}`,
  { label: 'lattice', phase: 'Lattice' })

const involutions = await agent(
  `Add the orientifold involutions as explicit lattice isometries: each involution's matrix, that it squares to
   the identity, its eigenspace signature, and the arithmetic of the fixed loci (number of O-planes). State
   nothing about supersymmetry or spectra: that is Tier L/C and belongs in the docstring with pins.
   Lattice layer: ${JSON.stringify(lattice).slice(0, 4000)}`,
  { label: 'involutions', phase: 'Involutions' })

await agent(
  `Run the five gates for the affected library (one Lean process at a time), add mutation controls (a non-even
   Gram entry, an involution that does not square to the identity) that must each be caught, write
   docs/STREAM9_ORIENTIFOLD.md in the style of docs/STREAM8_WHICH_K3.md (What is proved / Tier L sources /
   Reading (Tier C) / what is NOT claimed), update VERIFIED_FOUNDATION.md and README counts, and commit.
   Do not push. Work: ${JSON.stringify({ lattice, involutions }).slice(0, 4000)}`,
  { label: 'gates', phase: 'Gates' })

return { scope, lattice, involutions }
