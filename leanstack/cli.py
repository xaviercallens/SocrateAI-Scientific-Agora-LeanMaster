"""
leanstack/cli.py — `python -m leanstack <command>`.

  plan         [MODULE ...] [--dry-run] [--force] [--budget-gb G] [--parallel N] [--check]
               topological, memory-aware build plan; without --dry-run it RUNS the builds under the RSS guard
  fingerprint  MODULE ... [--trace]      leanstack fingerprint (+ Lake's depHash from the .trace, if any)
  impact       MODULE ...                modules whose results a change to MODULE can invalidate
  ingest       [--sources] [--lock] [--audit FILE] [--depgraph] [--attempts] [--traces] [--all]
               load the existing tools' outputs into LeanMemory
  search       QUERY [-k K] [--theorems] [--no-expand]
  warm         --path P | --closure MODULE ...  [--max-gb G] [--dry-run] [--resident] [--public-only]
  stats        row counts of LeanMemory

LeanMemory lives in $LEANSTACK_HOME (default /mnt/disks/disk-socrateai-local-1/leanmaster/leanstack);
--home overrides it.
"""

import argparse
import json
import sys
from pathlib import Path

from leanstack import cache, datastore, scheduler, source, warm
from leanstack.memory import LeanMemory
from leanstack.rag import Retriever

ROOT = source.REPO_ROOT


def own_files(root: Path) -> list[Path]:
    return list(source.own_modules(root).values())


def cmd_plan(a, mem: LeanMemory) -> int:
    fp = cache.Fingerprinter(ROOT)
    steps = scheduler.plan(a.modules or None, mem, fp, force=a.force)
    budget = int(a.budget_gb * scheduler.GB) if a.budget_gb else scheduler.default_budget_kb()
    print(scheduler.format_plan(steps, budget))
    if a.dry_run:
        print("\n--dry-run: nothing was run.")
        return 0
    summary = scheduler.execute(steps, mem, fp, budget, max_parallel=a.parallel,
                                action="check" if a.check else "build",
                                timeout_s=a.timeout, module_budget_kb=int(a.module_gb * scheduler.GB) if a.module_gb else None)
    print(json.dumps({k: len(v) for k, v in summary.items()}), json.dumps(summary["failed"]))
    return 1 if summary["failed"] else 0


def cmd_fingerprint(a, mem: LeanMemory) -> int:
    fp = cache.Fingerprinter(ROOT)
    lc = cache.LeanCache(mem, fp)
    for m in a.modules:
        hit = lc.lookup(m, "build")
        line = f"{m}  {fp.fingerprint(m)}  cache={'hit:' + hit['status'] if hit else 'miss'}"
        if a.trace:
            t = cache.lake_trace(m, ROOT)
            line += f"  lake_depHash={t.get('dep_hash') if t else 'no trace'}"
        print(line)
    return 0


def cmd_impact(a, mem: LeanMemory) -> int:
    fp = cache.Fingerprinter(ROOT)
    graph = {m: [i for i in fp.imports(m) if fp.is_own(i)] for m in source.own_modules(ROOT)}
    for m in cache.impacted(a.modules, graph):
        print(m)
    return 0


def cmd_ingest(a, mem: LeanMemory) -> int:
    report = {}
    if a.sources or a.all:
        report["declarations"] = datastore.ingest_sources(mem, own_files(ROOT), ROOT)
    if a.lock or a.all:
        report["statement_lock"] = datastore.ingest_statement_lock(mem, ROOT / "docs" / "statement_lock.json")
    if a.depgraph or a.all:
        p = ROOT / ".leancache" / "depgraph.jsonl"
        report["edges"] = datastore.ingest_depgraph(mem, p) if p.exists() else "absent"
    if a.attempts or a.all:
        p = ROOT / ".leancache" / "prover_attempts.jsonl"
        report["attempts"] = datastore.ingest_prover_attempts(mem, p) if p.exists() else "absent"
    if a.traces or a.all:
        report["lake_traces"] = datastore.ingest_lake_traces(mem, list(source.own_modules(ROOT)), ROOT)
    if a.audit:
        report["axiom_audit"] = datastore.ingest_axiom_audit(mem, Path(a.audit).read_text())
    print(json.dumps(report, indent=1))
    return 0


def cmd_search(a, mem: LeanMemory) -> int:
    r = Retriever(mem, kinds=("theorem",) if a.theorems else None)
    for h in r.search(a.query, k=a.k, expand=0 if a.no_expand else 2):
        via = f"   [{h['via']}]" if h["via"] else ""
        print(f"{h['score']:.4f}  {h['name']}  ({h['kind']}, {h['file']}:{h['line']}, {h['kernel_status']}){via}")
        print(f"        {h['statement'][:160]}")
    return 0


def cmd_warm(a, mem: LeanMemory) -> int:
    if a.closure:
        oleans, missing = warm.olean_closure(a.closure, ROOT)
        files = oleans if a.public_only else warm.with_parts(oleans)
        if missing:
            print(f"not found ({len(missing)}): {', '.join(missing[:8])}{' …' if len(missing) > 8 else ''}")
    elif a.path:
        files = [f for p in a.path for f in warm.files_under(Path(p), a.suffix)]
    else:
        print("warm: give --path DIR/FILE or --closure MODULE (nothing is warmed by default).")
        return 2
    size = sum(f.stat().st_size for f in files)
    print(f"{len(files)} files, {size / 1e9:.3f} GB")
    if a.resident:
        print("resident before:", warm.resident_bytes(files))
    if a.dry_run:
        return 0
    rep = warm.warm_files(files, max_bytes=int(a.max_gb * 1e9) if a.max_gb else None)
    print(json.dumps(rep))
    mem.event("warm", ",".join(a.closure or a.path), **rep)
    if a.resident:
        print("resident after:", warm.resident_bytes(files))
    return 0


def cmd_stats(a, mem: LeanMemory) -> int:
    print(json.dumps(mem.stats(), indent=1))
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="python -m leanstack", description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--home", help="LeanMemory root (default $LEANSTACK_HOME or the data-disk path)")
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("plan", help="memory-aware build plan (and run it unless --dry-run)")
    p.add_argument("modules", nargs="*")
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--force", action="store_true", help="ignore cached ok results")
    p.add_argument("--budget-gb", type=float, help="global memory budget (default MemTotal - 8 GB)")
    p.add_argument("--module-gb", type=float, help="per-module kill threshold (default from history)")
    p.add_argument("--parallel", type=int, default=1, help="max concurrent light modules (default 1)")
    p.add_argument("--check", action="store_true", help="single-file `lake env lean` checks instead of `lake build`")
    p.add_argument("--timeout", type=float, help="wall-clock limit per module, seconds")
    p.set_defaults(func=cmd_plan)

    p = sub.add_parser("fingerprint", help="module fingerprints and cache status")
    p.add_argument("modules", nargs="+")
    p.add_argument("--trace", action="store_true", help="also show Lake's depHash from the .trace file")
    p.set_defaults(func=cmd_fingerprint)

    p = sub.add_parser("impact", help="modules affected by a change")
    p.add_argument("modules", nargs="+")
    p.set_defaults(func=cmd_impact)

    p = sub.add_parser("ingest", help="load existing tool outputs into LeanMemory")
    for flag in ("sources", "lock", "depgraph", "attempts", "traces", "all"):
        p.add_argument(f"--{flag}", action="store_true")
    p.add_argument("--audit", help="saved stdout of tools/axiom_audit.py")
    p.set_defaults(func=cmd_ingest)

    p = sub.add_parser("search", help="hybrid retrieval over declarations")
    p.add_argument("query")
    p.add_argument("-k", type=int, default=10)
    p.add_argument("--theorems", action="store_true", help="theorems only")
    p.add_argument("--no-expand", action="store_true", help="no dependency-graph neighbours")
    p.set_defaults(func=cmd_search)

    p = sub.add_parser("warm", help="pre-fill the page cache with .olean files")
    p.add_argument("--path", nargs="+", help="files or directories to read")
    p.add_argument("--closure", nargs="+", help="warm exactly the oleans these modules import")
    p.add_argument("--suffix", default=".olean", help="file suffix under --path directories")
    p.add_argument("--public-only", action="store_true",
                   help="with --closure: only .olean, not the .olean.server/.olean.private parts")
    p.add_argument("--max-gb", type=float, help="stop after this many GB")
    p.add_argument("--dry-run", action="store_true", help="list and size only, read nothing")
    p.add_argument("--resident", action="store_true", help="report page-cache residency (fincore)")
    p.set_defaults(func=cmd_warm)

    p = sub.add_parser("stats", help="LeanMemory row counts")
    p.set_defaults(func=cmd_stats)

    a = ap.parse_args(argv)
    with LeanMemory(a.home) as mem:
        return a.func(a, mem)


if __name__ == "__main__":
    sys.exit(main())
