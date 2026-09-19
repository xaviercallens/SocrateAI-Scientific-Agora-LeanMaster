"""
leanstack — LeanMemory + LeanCache + LeanDatastore + LeanGraph hooks + LeanRAG for LeanMaster.

Design and status (implemented vs proposed): docs/LEAN_SCALE_ARCHITECTURE.md.
Nothing in this package runs Lean except `scheduler.execute` (and the `plan` CLI without --dry-run),
which calls `lake build <Module>` / `lake env lean` under a memory guard.

    source     parse Lean text: imports, lean_libs, lakefile options, declarations, `decide +kernel`
    memory     LeanMemory: SQLite (WAL) + content-addressed blobs, the store every layer shares
    cache      LeanCache: fingerprints, (fingerprint, action) result cache, Lake .trace reader, impact
    scheduler  topological, memory-aware, RSS-guarded build runner
    datastore  LeanDatastore: ingest statement lock, axiom audit, depgraph, prover attempts, traces
    rag        LeanRAG: BM25 + optional embeddings + kernel-graph neighbours
    warm       page-cache warming for .olean files
"""
