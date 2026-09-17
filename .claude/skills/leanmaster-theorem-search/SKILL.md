---
name: leanmaster-theorem-search
description: Use before stating or proving a new Lean theorem about lattices, T-duality, O(d,d), generalized metric, K3, tadpoles, moonshine or related topics, to find what LeanMaster already proves, what depends on what, and which theorems are similar or share dependencies (RAG over a SQLite index plus a kernel-level dependency graph).
---

# Finding and relating theorems in LeanMaster

All commands from `~/SocrateAI-Scientific-Agora-LeanMaster`.

**Refresh (after any Lean change)**
```bash
python3 tools/index_declarations.py                              # SQLite: .leancache/declarations.db
lake env lean tools/lean_depgraph.lean > .leancache/depgraph.jsonl   # true dependencies from the compiled env
python3 tools/theorem_atlas.py                                   # papers/book/generated/{lean_catalogue,atlas}.md, atlas_data.json
```

**Search**
```bash
grep -n -i "unimodular\|posdef" papers/book/generated/lean_catalogue.md          # every declaration + statement head
sqlite3 .leancache/declarations.db "select module,name,signature from declarations
   where decl_type='theorem' and (name like '%tadpole%' or docstring like '%tadpole%')"
python3 tools/socrateai_oracle.py --help                                          # oracle / JSON export for the web blueprint
```

**Relate** (`papers/book/generated/atlas.md`, machine-readable `atlas_data.json`)
* *Hubs*: own definitions most theorems depend on (`TDuality.Charge`, `Lattice.Gram`, `TDuality.eta`, `IsODD`, `k3HodgeNumber`).
* *Bridges*: theorems that tie two libraries together (e.g. `hyperbolicU_eq_narain_gram`: Stream 2's U is
  literally Stream 1's Narain Gram matrix; `massForm_circle` ↔ `momentumMassSq`).
* *Intersection* = weighted Jaccard of kernel dependencies; *similarity* = TF-IDF cosine of statements.
* *Unification candidates*: similar statements with disjoint proofs — the same fact proved more than once
  (χ(K3)=24 in four libraries, Mukai rank, tadpole cancellation). Reuse the Stream 2 / Mathlib-based
  version; do not add another copy.

The older regex-based `graph/leangraph.json` records variable names as dependencies; prefer
`depgraph.jsonl`. Always open the `.lean` file and read the statement before citing it.
