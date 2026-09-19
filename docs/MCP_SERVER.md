# The `leanmaster` MCP server

An MCP server (stdio) that lets other Claude sessions and projects use LeanMaster without reading the repository:
it finds theorems, gives their exact statements and status, reports the recorded gate numbers, runs the
statement-lock check, and (optionally) compiles a Lean snippet against the library under a memory guard.

It is a thin layer over code that already exists: `leanstack` (LeanMemory store, LeanRAG retrieval, LeanCache
fingerprints, the RSS-guarded runner) and the gate tools `tools/statement_lock.py` / `tools/axiom_audit.py`
(through the audit results ingested into LeanMemory). Source: `leanstack/mcp_server.py`; launcher:
`tools/leanmaster_mcp.sh`; tests: `tests/test_mcp_server.py`.


## What it exposes

| Tool | What it returns | Runs Lean? |
|---|---|---|
| `search_theorems(query, k=10, theorems_only=True)` | BM25 hits plus their kernel-graph neighbours (`leanstack.rag.Retriever`). Each hit gives its qualified name, `file:line`, statement, `kernel_status`, a docstring excerpt, the tiers the docstring mentions, and its paper pins. | no |
| `get_declaration(name)` | The full record: statement, docstring, `file:line`, the current / locked / at-ingest statement hashes, the axioms from the last ingested audit, pins, the kernel-level dependencies and dependents (statement vs proof), and prior prover attempts. A short name works when it is unique; otherwise you get the list of candidates. | no |
| `verified_status()` | The gate numbers **as last recorded** in `README.md` (the per-library audit table, its total and date) and `docs/VERIFIED_FOUNDATION.md` (latest release, last "Total audited"), plus the LeanMemory statistics. Nothing is re-run. | no |
| `impact(module)` | The reverse import closure (`leanstack.cache.impacted`): every module that a change to `module` can invalidate. | no |
| `check_statement_lock(files=None)` | Runs `tools/statement_lock.py --check` (pure Python) and returns its output verbatim, with the exit code and CHANGED / REMOVED / ADDED / UNLOCKED counts. By default it checks every first-party file. | no |
| `usage_guide()` | How to depend on LeanMaster from another Lake project and how to cite it, with the tier rules and `docs/USING_LEANMASTER.md` served live. | no |
| `check_lean_snippet(code, imports=["DualScaleDyons"], timeout_s=600, memory_gb=12)` | Compiles a snippet with `lake env lean -DmaxHeartbeats=1000000 -DmaxRecDepth=8000` and returns the errors and warnings (line numbers relative to the snippet). It also reports whether `sorry`, `admit`, `native_decide` or `axiom` appear. **A successful compile is not a gate pass.** | **yes** |

Resources: `leanmaster://verified-foundation` (`docs/VERIFIED_FOUNDATION.md`), `leanmaster://lessons` (`LL.md`).
The server's `instructions` carry the tier rules to the client.

### What `kernel_status` means
`"A"` means three things hold, as computed by `leanstack.datastore.kernel_status`:
* the theorem's statement is in `docs/statement_lock.json`;
* its **current** statement hash equals the lock hash;
* the last ingested axiom audit said OK (only `propext`, `Classical.choice`, `Quot.sound`).

The server re-reads the statement hash from the current source and the lock hash from the current lock file
on every call. A statement edited after the last ingest therefore never reads as locked, and its stored audit is
ignored. Any other value is the reason the theorem is not Tier A: `unlocked`, `statement changed since lock`,
`audit not run` or `audit FAIL`. Tier A covers the Lean statement only. What the statement means physically is a
separate, human-assigned tier: L (literature, pinned to `papers/foundations/<file>.txt` + lines) or C
(conjecture). Never write "zero axioms" or "100% verified".

**Current state of the store (2026-09-19): no axiom audit has been ingested into LeanMemory.** Every theorem
therefore reads `audit not run`, which here means "not ingested", not "failed". The tools add an `audit_note`
saying so. The documents record **693 audited theorems, 0 failing** (README audit table, re-audited after
v3.27.0). The MCP store records **0 ingested audits**. Both numbers are reported, and neither is derived from the
other. To make `A` reachable, run the following on a quiet machine (it compiles Lean):
```bash
python3 tools/axiom_audit.py <Lib> > /mnt/disks/disk-socrateai-local-1/leanmaster/audit_<Lib>.txt
python3 -m leanstack ingest --audit /mnt/disks/disk-socrateai-local-1/leanmaster/audit_<Lib>.txt
```

## Install (once per machine)
```bash
python3 -m venv /mnt/disks/disk-socrateai-local-1/leanmaster/mcp-venv        # data disk, not $HOME
/mnt/disks/disk-socrateai-local-1/leanmaster/mcp-venv/bin/pip install "mcp>=1.2,<2"
python3 -m leanstack ingest --all          # (already done) fills LeanMemory; no Lean is run
```
Installed and tested: `mcp` **1.30.0** on Python 3.10.12. The server uses the FastMCP API, and its tool
functions need only the standard library and `leanstack`.

## Register it
**Inside this repository** nothing is needed. `.mcp.json` at the repo root registers `leanmaster` at project
scope; it was written by `claude mcp add leanmaster -s project -- …/tools/leanmaster_mcp.sh`. Claude Code asks
you to approve a project-scoped server the first time it starts in the repo.

**From another project** (same machine), run this once in that project:
```bash
claude mcp add leanmaster -- /mnt/disks/disk-socrateai-local-1/callensxavier_home_data/SocrateAI-Scientific-Agora-LeanMaster/tools/leanmaster_mcp.sh
```
The default scope is `local` (this project, this user). Add `-s user` to make it available in every project,
or `-s project` to write that project's `.mcp.json`. Check it with `claude mcp get leanmaster`. The syntax was
checked with `claude mcp add --help` on this VM: `claude mcp add [options] <name> -- <command> [args...]`.

The launcher runs the venv python with cwd = the repository and puts `~/.elan/bin` on `PATH` for `lake`.
You can override these with environment variables (for example `claude mcp add leanmaster -e LEANSTACK_HOME=/path -- …`):
* `LEANMASTER_MCP_PYTHON`: the interpreter;
* `LEANSTACK_HOME`: another LeanMemory store;
* `LEANMASTER_MCP_SCRATCH`: the snippet scratch directory. The default is
  `/mnt/disks/disk-socrateai-local-1/leanmaster/leanstack/scratch/`.

## Examples (tool calls as a client sends them)
```text
search_theorems {"query": "K3 Euler characteristic 24", "k": 5}
  -> DoubleFieldTheory.K3Topology.k3_euler_characteristic   DoubleFieldTheory/K3Topology.lean:51   unlocked
     Lean5Corpus.Problems.KummerModularity.k3_euler_characteristic_identity   ...:50   unlocked
     SocrateAI.Moonshine.k3_euler_eq_24   DualScaleM24Formalization/Moonshine/KummerTadpole.lean:49   audit not run
get_declaration {"name": "DualScaleStream2.Lattice.Signature.add_pos"}
  -> statement "@[simp] theorem add_pos (a b : Signature) : (a + b).pos = a.pos + b.pos",
     locked_and_unchanged true, audit_status "not ingested", depends_on / dependents ...
impact {"module": "DualScaleDyons.KummerD4"}
  -> 6 modules: DualScaleDyons, …K3Enhancement, …K3EnhancementSO40, …K3EnhancementSO44, …KummerD4, …KummerOmegaE4
check_statement_lock {}
  -> exit 0, "statement lock: OK", 150 files checked, 57 UNLOCKED (files with no lock entry), 0 CHANGED/REMOVED
check_lean_snippet {"code": "example : (2 : ℕ) + 2 = 4 := by norm_num", "imports": ["Mathlib.Tactic"]}
```
The first four outputs are real (this VM, 2026-09-19). The last example is the call shape only; see "Limits".

## Limits (read before relying on it)
* **The snippet compiler has never been run for real.** When this server was written the main session was
  running memory-heavy kernel checks, and a parallel compile gets processes OOM-killed. The tests use a mocked
  runner, which checks that the command is exactly `lake env lean -DmaxHeartbeats=1000000 -DmaxRecDepth=8000
  <scratch file>`, plus caching, message parsing, the `sorry` scan and the file lock. When the VM is quiet,
  smoke-test it by hand:
  ```bash
  cd /mnt/disks/disk-socrateai-local-1/callensxavier_home_data/SocrateAI-Scientific-Agora-LeanMaster
  /mnt/disks/disk-socrateai-local-1/leanmaster/mcp-venv/bin/python -c "import json; from leanstack import mcp_server as s; \
  print(json.dumps(s.check_lean_snippet('example : (2 : Nat) + 2 = 4 := rfl', imports=['DualScaleStream2'], memory_gb=8), indent=1))"
  ```
  A cold run re-reads the Mathlib `.olean` files, which can take 20–40 minutes on this disk
  (`docs/LEAN_SCALE_ARCHITECTURE.md` §2). Warm the page cache first with
  `python3 -m leanstack warm --closure <Lib>`.
* **Snippet safety is a guard rail, not a sandbox.** Lean can run IO at elaboration time. The server refuses:
  `import` lines, `#eval`/`run_cmd`/`run_elab`/`run_meta`/`run_tac`, `elab`/`macro`/`syntax`/`initialize`,
  `unsafe`/`implemented_by`/`extern`/`evalConst`/`Lean.Elab`, any identifier ending in `IO`, `System`/`Process`,
  and attributes outside a small allow-list. Imports must be first-party modules or `Mathlib`/`Batteries`/
  `Aesop`/`Std`/`Init` modules. The only process started is `lake env lean` on a scratch file whose name is
  derived from the text's fingerprint. No caller text reaches a path or a shell.
* **Snippet resources.** The whole process group is killed at `memory_gb` (RssAnon, capped at 24 GB) or when
  system MemAvailable falls under 2 GB. The call is refused if MemAvailable is below `memory_gb` when it would
  start. Only one snippet compiles at a time (a `flock` in the scratch directory; a second caller waits 30 s,
  then gets `busy`). Results `ok`/`error` are cached by `leanstack` fingerprint (text + imports' closure +
  toolchain + options); killed or timed-out runs, and `infra_error` runs (an error in the import header or a missing `.olean`, i.e. a build-state problem rather than a verdict on the snippet), are recorded but not served from the cache. The main
  session's own `lake` runs do not take this lock: the MemAvailable check is the only protection against
  them.
* **Freshness.** Search and dependency data come from the last `python3 -m leanstack ingest --all`. The source
  ingest is from 2026-09-19 15:25 UTC. A declaration added later (for example in a file created after the ingest)
  is not found until the next ingest. Statements, line numbers and lock hashes are re-read live. The
  dependency edges come from `.leancache/depgraph.jsonl`, which covers 7 of the 10 libraries
  (`docs/LEAN_SCALE_ARCHITECTURE.md` §11).
* **Docstrings.** `leanstack.source.DOCSTRING_BEFORE` starts matching at the *first* `/--` within the 20 000
  characters before a declaration. The stored docstrings (and the tiers and pins parsed from them) can
  therefore include earlier declarations' docstrings and code. The server works around this by keeping the
  text after the last `/--` and recomputing the tiers and pins from it. The store itself is unchanged; the
  parser should be fixed in `leanstack/source.py`.
* **Read-only by default.** No tool edits the repository or ingests. `check_lean_snippet` writes a scratch
  file, plus a `build_runs`/`results` row and a log blob in LeanMemory.
* `verified_status` parses documents: if a document's layout changes, the parse reports an error rather than
  guessing.

## Tests
```bash
cd /mnt/disks/disk-socrateai-local-1/callensxavier_home_data/SocrateAI-Scientific-Agora-LeanMaster
/mnt/disks/disk-socrateai-local-1/leanmaster/mcp-venv/bin/python -m pytest tests/test_leanstack.py tests/test_mcp_server.py -q
```
Result on 2026-09-19: 42 passed (29 + 13) in about 18 s, with no Lean compiled. `tests/test_mcp_server.py` does
three things:
* It calls the tool functions directly against a temporary LeanMemory seeded by `leanstack`'s own ingest (the
  only place `"A"` is reachable, because it has a synthetic audit), and against a SQLite-backup copy of the real
  store.
* It checks the statement-lock and path guards on the real repository.
* It starts the server through `tools/leanmaster_mcp.sh` over stdio with the `mcp` client (`initialize`,
  `tools/list`, `resources/list`, both `resources/read`, one `tools/call`).
