"""
leanstack/mcp_server.py — an MCP server (stdio) that exposes LeanMaster to other Claude sessions.

    python -m leanstack.mcp_server              # needs the `mcp` package (1.x, FastMCP API)
    tools/leanmaster_mcp.sh                     # the launcher: venv python, cwd = repo

A thin layer over what already exists, nothing reimplemented:
  * retrieval       leanstack.rag.Retriever (BM25 + kernel-graph neighbours) over LeanMemory
  * status          leanstack.datastore.kernel_status — 'A' only for a theorem that is locked, unchanged
                    since the lock and audited OK. Here the statement hash and the lock hash are
                    re-read LIVE (current source, current docs/statement_lock.json), so a statement edited
                    after the last ingest is never reported as locked.
  * impact          leanstack.cache.impacted over the source import graph
  * lock check      tools/statement_lock.py --check (pure Python, no Lean)
  * snippet check   `lake env lean` under leanstack.scheduler.run_guarded (RSS guard, process-group kill),
                    one compile at a time (file lock), results cached by leanstack.cache fingerprint

Read-only by default: no tool edits the repository or ingests into the store. The one tool that
writes anything is `check_lean_snippet` (a scratch file on the data disk and a build_runs/results
row + log blob in LeanMemory).

A successful compile or a search hit is never a gate pass: the five gates are build, `sorry` grep,
tools/axiom_audit.py, tools/statement_lock.py --check, and producer != verifier.
"""

from __future__ import annotations

import fcntl
import json
import os
import re
import subprocess
import sys
import time
from contextlib import contextmanager
from pathlib import Path

from leanstack import cache, datastore, scheduler, source
from leanstack.memory import LeanMemory
from leanstack.rag import Retriever

ROOT = source.REPO_ROOT
DATA = Path("/mnt/disks/disk-socrateai-local-1/leanmaster/leanstack")
SCRATCH = Path(os.environ.get("LEANMASTER_MCP_SCRATCH") or (DATA / "scratch"))
LOCK_JSON = ROOT / "docs" / "statement_lock.json"
STANDARD_AXIOMS = sorted(datastore.STANDARD_AXIOMS)

NOT_A_GATE = ("A successful compile of a snippet is NOT a gate pass. Nothing is 'proved' until the five gates "
              "pass on the real library: lake build, sorry grep, tools/axiom_audit.py, "
              "tools/statement_lock.py --check, and producer != verifier (recompile it yourself).")
TIER_RULES = ("Tiers: A = kernel-checked (Lean statement locked, unchanged, axiom audit OK); L = literature "
              "(pin papers/foundations/<file>.txt + line numbers); C = conjecture. Tier A certifies the Lean "
              "statement, not its physical meaning. The only axioms allowed are propext, Classical.choice, "
              "Quot.sound — never write 'zero axioms' or '100% verified'.")
NO_AUDIT_HINT = ("The store holds no ingested axiom audit, so every theorem reads 'audit not run' here: that means "
                 "'not ingested into LeanMemory', not 'failed'. Refresh (compiles Lean, run it only on a quiet "
                 "machine): python3 tools/axiom_audit.py <Lib> > /path/audit.txt && python3 -m leanstack ingest "
                 "--audit /path/audit.txt")


# ---- helpers ---------------------------------------------------------------------------------
@contextmanager
def open_memory(home: str | Path | None = None):
    """One LeanMemory (one SQLite connection) per call: connections are thread-bound, and FastMCP may
    run tools on different threads. LEANSTACK_HOME / the data-disk default choose the store."""
    mem = LeanMemory(home)
    try:
        yield mem
    finally:
        mem.close()


def _json_field(value):
    if value is None or isinstance(value, (list, dict)):
        return value
    try:
        return json.loads(value)
    except (TypeError, ValueError):
        return value


_LOCK_CACHE: dict = {}
_SRC_CACHE: dict = {}


def _lock() -> dict:
    """docs/statement_lock.json, re-read when its mtime changes."""
    try:
        mtime = LOCK_JSON.stat().st_mtime
    except OSError:
        return {}
    if _LOCK_CACHE.get("mtime") != mtime:
        _LOCK_CACHE.update(mtime=mtime, data=json.loads(LOCK_JSON.read_text()))
    return _LOCK_CACHE["data"]


def _live_decls(file: str) -> dict[str, dict] | None:
    """short name -> declaration parsed from the CURRENT source (first occurrence, lock semantics);
    None if the file is gone. Cached per (file, mtime)."""
    p = ROOT / file
    try:
        mtime = p.stat().st_mtime
    except OSError:
        return None
    hit = _SRC_CACHE.get(file)
    if hit and hit[0] == mtime:
        return hit[1]
    out: dict[str, dict] = {}
    for d in source.declarations(p.read_text(encoding="utf-8", errors="ignore")):
        out.setdefault(d["short"], d)
    _SRC_CACHE[file] = (mtime, out)
    return out


def own_docstring(doc: str | None) -> str:
    """The declaration's own docstring. Workaround: `source.DOCSTRING_BEFORE` matches from the FIRST `/--` in
    the 20 000 characters before a declaration, so a stored docstring can contain the preceding declarations'
    docstrings and code; the declaration's own docstring is the text after the last `/--`."""
    doc = doc or ""
    return doc.rsplit("/--", 1)[-1].strip() if "/--" in doc else doc.strip()


def doc_fields(doc: str | None) -> dict:
    """Docstring, tier mentions and paper pins recomputed from the declaration's own docstring."""
    d = own_docstring(doc)
    return {"docstring": d, "tier_mentions": sorted(set(source.TIER.findall(d))), "pins": source.source_pins(d)}


def live_status(row: dict) -> dict:
    """Kernel status with the statement hash and lock hash read live. If the statement changed since the
    store's last ingest, the stored audit no longer applies (same rule as datastore.ingest_sources)."""
    live = dict(row)
    decls = _live_decls(row["file"]) if row.get("file") else None
    d = (decls or {}).get(row.get("short"))
    notes = []
    if decls is None:
        notes.append("source file no longer exists")
    elif d is None:
        notes.append("declaration no longer in the source (store is stale)")
    else:
        live["statement_hash"] = source.statement_hash(d["statement"])
        live["statement"] = d["statement"]
        live["line"] = d["line"]
        if live["statement_hash"] != row.get("statement_hash"):
            notes.append("statement changed since the last ingest; stored audit ignored")
            live["axioms"] = live["audit_status"] = None
    live["lock_hash"] = _lock().get(row.get("file"), {}).get(row.get("short"))
    return {"kernel_status": datastore.kernel_status(live), "current_hash": live.get("statement_hash"),
            "lock_hash": live["lock_hash"], "stored_hash": row.get("statement_hash"),
            "statement": live.get("statement"), "line": live.get("line"), "notes": notes,
            "axioms": _json_field(live.get("axioms")), "audit_status": live.get("audit_status")}


def _audited_count(mem: LeanMemory) -> int:
    return mem.db.execute("SELECT COUNT(*) FROM declarations WHERE audit_status IS NOT NULL").fetchone()[0]


def _last_ingest(mem: LeanMemory) -> str | None:
    r = mem.db.execute("SELECT MAX(ts) FROM events WHERE kind = 'ingest_sources'").fetchone()
    return time.strftime("%Y-%m-%d %H:%M:%S UTC", time.gmtime(r[0])) if r and r[0] else None


_LEX_CACHE: dict = {}


def _retriever(mem: LeanMemory, theorems_only: bool) -> Retriever:
    """Retriever over a fresh connection; the BM25 index is reused while the store is unchanged."""
    kinds = ("theorem",) if theorems_only else None
    r = Retriever(mem, kinds=kinds)
    sig = mem.db.execute("SELECT COUNT(*), MAX(updated) FROM declarations").fetchone()
    key = (kinds, tuple(sig), str(mem.root))
    if key in _LEX_CACHE:
        r._lex = _LEX_CACHE[key]
    else:
        for old in [kk for kk in _LEX_CACHE if kk[1:] != key[1:]]:   # store changed: drop stale indexes
            del _LEX_CACHE[old]
        _LEX_CACHE[key] = r.lexical
    return r


# ---- tools (plain functions; registered with FastMCP in build_server) --------------------------
def search_theorems(query: str, k: int = 10, theorems_only: bool = True, home: str | None = None) -> dict:
    """Find existing LeanMaster declarations (BM25 over names/statements/docstrings + kernel-graph
    neighbours). Each hit: name, file:line, statement, kernel_status, docstring excerpt, tier mentions,
    paper pins. Retrieval finds what exists; whether it is proved is the gates' answer."""
    k = max(1, min(int(k), 50))
    with open_memory(home) as mem:
        r = _retriever(mem, theorems_only)
        hits = []
        for h in r.search(query, k=k, expand=2):
            row = r.rows[h["name"]]
            st = live_status(row)
            df = doc_fields(row.get("docstring"))
            hits.append({
                "name": h["name"], "kind": h["kind"], "location": f"{row['file']}:{st['line'] or row['line']}",
                "statement": (st["statement"] or row.get("statement") or "")[:400],
                "kernel_status": st["kernel_status"], "docstring": df["docstring"][:300],
                "tier_mentions": df["tier_mentions"], "pins": df["pins"],
                "score": h["score"], "via": h["via"], **({"notes": st["notes"]} if st["notes"] else {}),
            })
        audited = _audited_count(mem)
    out = {"query": query, "hits": hits,
           "note": "kernel_status 'A' = locked, unchanged since lock, axiom audit OK (Lean statement only). "
                   "Tier mentions are what the docstring says, not assigned by this tool."}
    if not audited:
        out["audit_note"] = NO_AUDIT_HINT
    return out


def get_declaration(name: str, home: str | None = None) -> dict:
    """Full record of one declaration by qualified name (falls back to the short name): statement,
    docstring, file:line, lock hash vs current hash, axioms from the last ingested audit, pins,
    kernel-level dependencies and dependents."""
    with open_memory(home) as mem:
        rows = mem.declarations("name = ?", (name,))
        if not rows:
            rows = mem.declarations("short = ?", (name.split(".")[-1],))
            if len(rows) > 1:
                return {"error": f"'{name}' is ambiguous; use a qualified name",
                        "candidates": sorted(f"{r['name']} ({r['file']}:{r['line']})" for r in rows)[:30]}
        if not rows:
            return {"error": f"no declaration named '{name}' in the store (ingested at {_last_ingest(mem)}); "
                             "try search_theorems"}
        own = {r[0] for r in mem.db.execute("SELECT name FROM declarations")}
        records = []
        for row in rows:
            st = live_status(row)
            edges = {"uses": {"type": [], "value": []}, "used_by": {"type": [], "value": []}}
            for dst, kind in mem.db.execute("SELECT dst, kind FROM edges WHERE src = ?", (row["name"],)):
                edges["uses"][kind].append(dst)
            for src, kind in mem.db.execute("SELECT src, kind FROM edges WHERE dst = ?", (row["name"],)):
                edges["used_by"][kind].append(src)

            def summarise(names: list[str], cap: int = 40) -> dict:
                names = sorted(set(names))
                mine = [n for n in names if n in own]
                other = [n for n in names if n not in own]
                return {"project": mine[:cap], "n_project": len(mine), "n_other": len(other),
                        "other_sample": other[:15]}

            att = mem.attempts_for(row["short"])
            records.append({
                "name": row["name"], "short": row["short"], "kind": row["kind"], "module": row["module"],
                "location": f"{row['file']}:{st['line'] or row['line']}",
                "statement": st["statement"] or row.get("statement"),
                "docstring": doc_fields(row.get("docstring"))["docstring"],
                "kernel_status": st["kernel_status"],
                "statement_hash_current": st["current_hash"], "statement_hash_locked": st["lock_hash"],
                "statement_hash_at_ingest": st["stored_hash"],
                "locked_and_unchanged": bool(st["lock_hash"]) and st["lock_hash"] == st["current_hash"],
                "axioms_last_ingested_audit": st["axioms"], "audit_status": st["audit_status"] or "not ingested",
                "tier_mentions": doc_fields(row.get("docstring"))["tier_mentions"],
                "pins": doc_fields(row.get("docstring"))["pins"],
                "depends_on": {"in_statement": summarise(edges["uses"]["type"]),
                               "in_proof": summarise(edges["uses"]["value"])},
                "dependents": {"in_statement": summarise(edges["used_by"]["type"]),
                               "in_proof": summarise(edges["used_by"]["value"])},
                "prover_attempts": {"n": len(att), "accepted": sum(a["accepted"] for a in att),
                                    "failure_patterns": [{"pattern": f["pattern"], "count": f["count"]}
                                                         for f in mem.failures(decl=row["short"])][:10]},
                **({"notes": st["notes"]} if st["notes"] else {}),
            })
        audited = _audited_count(mem)
        stamp = _last_ingest(mem)
    out = {"records": records, "store_ingested_at": stamp,
           "edges_note": "'project' = declarations in the store; 'other' = Mathlib/core constants and auto-generated "
                         "names (instances, structure fields, recursors). Dependencies come from .leancache/depgraph.jsonl (kernel-level constants); libraries not "
                         "covered by tools/lean_depgraph.lean have no edges (docs/LEAN_SCALE_ARCHITECTURE.md §11)."}
    if not audited:
        out["audit_note"] = NO_AUDIT_HINT
    return out


README = ROOT / "README.md"
VERIFIED = ROOT / "docs" / "VERIFIED_FOUNDATION.md"
ROW = re.compile(r"^\|\s*(?:\*\*)?`?([A-Za-z0-9_]+|Total)`?(?:\*\*)?[^|]*\|\s*(?:\*\*)?(\d+)(?:\*\*)?\s*\|\s*(?:\*\*)?(\d+)(?:\*\*)?\s*\|\s*$")


def parse_audit_table(readme_text: str) -> dict:
    """The README's 'Theorems audited | Failing' table (the last recorded full audit)."""
    lines = readme_text.splitlines()
    for i, line in enumerate(lines):
        if re.match(r"^\|\s*Library\s*\|\s*Theorems audited\s*\|\s*Failing\s*\|", line):
            libs, total = {}, None
            intro = next((lines[j] for j in range(i - 1, max(-1, i - 4), -1) if lines[j].strip()), "")
            for row in lines[i + 2:]:
                if not row.startswith("|"):
                    break
                m = ROW.match(row)
                if not m:
                    continue
                name, n, failing = m.group(1), int(m.group(2)), int(m.group(3))
                if name == "Total":
                    total = {"audited": n, "failing": failing}
                else:
                    libs[name] = {"audited": n, "failing": failing}
            date = re.search(r"\d{4}-\d{2}-\d{2}", intro)
            return {"libraries": libs, "total": total, "date": date.group(0) if date else None,
                    "source": f"README.md l. {i + 1}", "context": intro.strip()[:400]}
    return {"error": "audit table not found in README.md"}


def parse_verified_foundation(text: str) -> dict:
    """The latest release paragraph and the last 'Total audited: **N**' of docs/VERIFIED_FOUNDATION.md."""
    totals = [(text.count("\n", 0, m.start()) + 1, int(m.group(1)))
              for m in re.finditer(r"[Tt]otal(?: audited)?:?\s*\*\*(\d+)\*\*", text)]
    releases = [(text.count("\n", 0, m.start()) + 1, m.group(1), m.group(2))
                for m in re.finditer(r"\*\*`(v\d+\.\d+\.\d+)` \((\d{4}-\d{2}-\d{2})\)", text)]
    latest = max(releases, key=lambda r: tuple(int(x) for x in r[1][1:].split("."))) if releases else None
    status = re.search(r"\*\*Status as of (\d{4}-\d{2}-\d{2})", text)
    return {"latest_release": {"version": latest[1], "date": latest[2], "line": latest[0]} if latest else None,
            "last_total_audited": {"value": totals[-1][1], "line": totals[-1][0]} if totals else None,
            "status_header_date": status.group(1) if status else None,
            "source": "docs/VERIFIED_FOUNDATION.md"}


def verified_status(home: str | None = None) -> dict:
    """The gate numbers AS LAST RECORDED in README.md / docs/VERIFIED_FOUNDATION.md (not re-run here),
    plus LeanMemory statistics. To confirm them, re-run the gates (docs/VERIFIED_FOUNDATION.md §4)."""
    out = {"label": "as last recorded in the repository documents — NOT re-run by this tool",
           "audit_table": parse_audit_table(README.read_text()) if README.exists() else {"error": "no README.md"},
           "verified_foundation": parse_verified_foundation(VERIFIED.read_text()) if VERIFIED.exists()
           else {"error": "no docs/VERIFIED_FOUNDATION.md"},
           "axioms_allowed": STANDARD_AXIOMS, "tier_rules": TIER_RULES}
    with open_memory(home) as mem:
        stats = mem.stats()
        q = mem.db.execute
        stats["theorems_in_store"] = q("SELECT COUNT(*) FROM declarations WHERE kind = 'theorem'").fetchone()[0]
        stats["declarations_with_lock_hash_at_ingest"] = q(
            "SELECT COUNT(*) FROM declarations WHERE lock_hash IS NOT NULL").fetchone()[0]
        stats["declarations_with_ingested_audit"] = _audited_count(mem)
        stats["last_source_ingest"] = _last_ingest(mem)
        out["leanstack_store"] = stats
        if not stats["declarations_with_ingested_audit"]:
            out["audit_note"] = NO_AUDIT_HINT
    out["how_to_confirm"] = ("Re-run the gates (they compile Lean): lake build <Lib>; python3 tools/axiom_audit.py <Lib>; "
                             "python3 tools/statement_lock.py --check <files>. If they disagree with the documents, "
                             "trust the commands.")
    return out


def _module_graph(root: Path = ROOT) -> dict[str, list[str]]:
    fp = cache.Fingerprinter(root)
    return {m: [i for i in fp.imports(m) if fp.is_own(i)] for m in source.own_modules(root)}


def impact(module: str) -> dict:
    """Reverse import closure: every first-party module whose build/audit/lock results a change to `module`
    can invalidate (the module itself included)."""
    graph = _module_graph()
    if module not in graph:
        close = sorted(m for m in graph if module.lower() in m.lower())[:20]
        return {"error": f"'{module}' is not a first-party module of this repository", "did_you_mean": close}
    hit = cache.impacted([module], graph)
    return {"module": module, "impacted": hit, "n": len(hit),
            "note": "source-level import graph; axiom sets propagate along it, so re-audit the whole impacted set."}


def _validate_repo_lean_file(f: str) -> Path:
    if not isinstance(f, str) or not f or f.startswith("-") or "\0" in f:
        raise ValueError(f"invalid file argument: {f!r}")
    p = (ROOT / f).resolve() if not os.path.isabs(f) else Path(f).resolve()
    if p.suffix != ".lean" or not p.is_file():
        raise ValueError(f"not an existing .lean file: {f}")
    try:
        p.relative_to(ROOT.resolve())
    except ValueError:
        raise ValueError(f"outside the repository: {f}") from None
    if ".lake" in p.relative_to(ROOT.resolve()).parts:
        raise ValueError(f"inside .lake: {f}")
    return p


def check_statement_lock(files: list[str] | None = None, timeout_s: float = 180) -> dict:
    """Run `tools/statement_lock.py --check` (pure Python, no Lean) and return its output verbatim.
    Default: every first-party .lean file of the lakefile's libraries (unlocked files print UNLOCKED,
    new declarations ADDED — expected, not failures; CHANGED/REMOVED fail)."""
    try:
        paths = [_validate_repo_lean_file(f) for f in files] if files else sorted(source.own_modules(ROOT).values())
    except ValueError as e:
        return {"error": str(e)}
    cmd = [sys.executable, str(ROOT / "tools" / "statement_lock.py"), "--check", "--", *map(str, paths)]
    env = {**os.environ, "LEAN_PROJECT_ROOT": str(ROOT)}
    try:
        p = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True, timeout=timeout_s, env=env)
    except subprocess.TimeoutExpired:
        return {"error": f"statement_lock.py timed out after {timeout_s} s"}
    lines = p.stdout.splitlines()
    summary = {k: sum(ln.startswith(k) for ln in lines) for k in ("CHANGED", "REMOVED", "ADDED", "UNLOCKED")}
    return {"exit_code": p.returncode, "ok": p.returncode == 0, "files_checked": len(paths), "summary": summary,
            "last_line": lines[-1] if lines else "", "output": p.stdout[-20000:], "stderr": p.stderr[-4000:],
            "note": "Exit 0 = no locked declaration CHANGED or REMOVED. ADDED/UNLOCKED lines are reported, not failures."}


def usage_guide() -> str:
    """How to depend on LeanMaster from another Lake project, how to use its gate tools, and how to cite."""
    doc = (ROOT / "docs" / "USING_LEANMASTER.md").read_text() if (ROOT / "docs" / "USING_LEANMASTER.md").exists() else ""
    head = f"""# LeanMaster usage guide (served by the leanmaster MCP server)

Repository: {ROOT}
Toolchain: leanprover/lean4:v4.33.1, Mathlib v4.33.1 (do not require a different revision).

## Tier rules (binding for anything you write on top of LeanMaster)
* {TIER_RULES}
* Cite a Lean result with its qualified name and file:line (get_declaration gives both), the release tag, and
  the gate status as recorded in docs/VERIFIED_FOUNDATION.md; re-run the gates rather than trusting a number.
* Retrieval (search_theorems) and a snippet compile (check_lean_snippet) are never a gate pass.
  {NOT_A_GATE}

## Depend on it from another Lake project (same machine)
Copy examples/consumer_demo (keeps the packagesDir line, reusing LeanMaster's built Mathlib), put large build
trees on /mnt/disks/disk-socrateai-local-1/, import only the modules you need
(e.g. `import DualScaleStream2.DFT.GeneralizedMetric`). Other machine: `require ... from git ... @ "<tag>"`,
then `lake exe cache get`. Details below.

---

"""
    return head + doc


# ---- check_lean_snippet --------------------------------------------------------------------------
EXTERNAL_ROOTS = {"Mathlib", "Batteries", "Aesop", "Std", "Init"}
MODULE_NAME = re.compile(r"^[A-Za-z_][A-Za-z0-9_']*(?:\.[A-Za-z_][A-Za-z0-9_']*)*$")
# Lean can run arbitrary IO at elaboration time (#eval, run_cmd, custom elaborators, initialize, extern code).
# This deny-list keeps the snippet tool to plain mathematics; it is a guard rail, NOT a sandbox.
DENY = [
    (re.compile(r"(?m)^\s*import\b"), "`import` lines (pass modules in `imports`)"),
    (re.compile(r"#eval!?|#exit|\brun_cmd\b|\brun_elab\b|\brun_meta\b|\brun_tac\b"), "#eval / run_cmd / run_elab / run_meta"),
    (re.compile(r"\b(?:elab|elab_rules|macro|macro_rules|syntax|declare_syntax_cat|notation3|initialize|"
                r"builtin_initialize)\b"), "elaborator / macro / syntax / initialize declarations"),
    (re.compile(r"\bunsafe\b|\bimplemented_by\b|\bextern\b|\bevalConst\b|\bLean\.Elab\b|\bLean\.Compiler\b"),
     "unsafe / implemented_by / extern / evalConst / Lean.Elab"),
    (re.compile(r"[A-Za-z_]*IO\b|\bSystem\b|\bProcess\b|\bIO\.FS\b"), "IO / System / Process"),
]
SAFE_ATTRS = {"simp", "reducible", "irreducible", "ext", "instance", "inline", "local", "scoped", "norm_cast",
              "push_cast", "simps", "symm", "refl", "trans", "mono", "gcongr", "positivity", "fun_prop",
              "specialize", "nolint", "coe", "match_pattern", "semireducible", "grind", "aesop"}
MSG = re.compile(r"^(?P<file>.*?\.lean):(?P<line>\d+):(?P<col>\d+): (?P<sev>error|warning|info)(?:\([^)]*\))?: (?P<msg>.*)$")


def _attr_words(block: str) -> list[str]:
    """The attribute names in `@[a, local b, -c, d x y]` -> ['a', 'b', 'c', 'd']."""
    words = []
    for part in block.split(","):
        toks = [t.lstrip("-") for t in part.split()]
        toks = [t for t in toks if t and t not in ("local", "scoped")]
        if toks:
            words.append(toks[0])
    return words


def screen_snippet(code: str, imports: list[str]) -> list[str]:
    """Reasons to refuse a snippet (empty = acceptable). Comments are blanked first."""
    problems = []
    if not isinstance(code, str) or not code.strip():
        return ["empty snippet"]
    if len(code) > 200_000:
        problems.append("snippet larger than 200 kB")
    if "\0" in code:
        problems.append("NUL byte in snippet")
    if not imports or len(imports) > 20:
        problems.append("imports must list 1-20 modules")
    for m in imports or []:
        if not isinstance(m, str) or not MODULE_NAME.match(m):
            problems.append(f"invalid module name in imports: {m!r}")
    code_nc = source.blank_comments(code)
    for rx, what in DENY:
        if rx.search(code_nc):
            problems.append(f"not allowed in snippets: {what}")
    blocks = re.findall(r"@\[([^\]]*)\]", code_nc) + re.findall(r"\battribute\s*\[([^\]]*)\]", code_nc)
    for block in blocks:
        for word in _attr_words(block):
            if word not in SAFE_ATTRS:
                problems.append(f"attribute [{word}] not allowed in snippets")
    return problems


def scan_forbidden(code: str) -> dict:
    code_nc = source.blank_comments(code)
    return {w: bool(re.search(rf"\b{w}\b", code_nc)) for w in ("sorry", "admit", "native_decide", "axiom")}


def parse_messages(output: str, header_lines: int) -> list[dict]:
    msgs, cur = [], None
    for line in output.splitlines():
        m = MSG.match(line)
        if m:
            cur = {"severity": m["sev"], "line": int(m["line"]) - header_lines, "col": int(m["col"]), "message": m["msg"]}
            msgs.append(cur)
        elif cur is not None and len(cur["message"]) < 4000:
            cur["message"] += "\n" + line
    return msgs


@contextmanager
def compile_lock(path: Path, wait_s: float):
    """Exclusive file lock: two callers (two MCP servers, two sessions) never compile at once."""
    path.parent.mkdir(parents=True, exist_ok=True)
    fh = open(path, "a+")
    deadline = time.time() + wait_s
    try:
        while True:
            try:
                fcntl.flock(fh, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except BlockingIOError:
                if time.time() >= deadline:
                    yield False
                    return
                time.sleep(1.0)
        yield True
    finally:
        try:
            fcntl.flock(fh, fcntl.LOCK_UN)
        finally:
            fh.close()


def check_lean_snippet(code: str, imports: list[str] | None = None, timeout_s: float = 600, memory_gb: float = 12,
                       home: str | None = None, runner=None, scratch: Path | None = None,
                       lock_wait_s: float = 30, min_free_gb: float | None = None) -> dict:
    """Compile a Lean snippet against LeanMaster with `lake env lean -DmaxHeartbeats=1000000 -DmaxRecDepth=8000`,
    under the RSS guard (whole process group killed at `memory_gb`), one compile at a time, cached by
    fingerprint. Returns errors/warnings and whether sorry/admit/native_decide/axiom appear.
    A successful compile is NOT a gate pass."""
    imports = list(imports) if imports else ["DualScaleDyons"]
    runner = runner or scheduler.run_guarded
    scratch = Path(scratch) if scratch else SCRATCH
    timeout_s = max(10.0, min(float(timeout_s), 1800.0))
    memory_gb = max(1.0, min(float(memory_gb), 24.0))
    base = {"not_a_gate_pass": NOT_A_GATE}
    problems = screen_snippet(code, imports)
    if problems:
        return {**base, "status": "refused", "problems": problems}
    header = "".join(f"import {m}\n" for m in imports) + "\n"
    text = header + code + ("" if code.endswith("\n") else "\n")
    header_lines = header.count("\n")
    forbidden = scan_forbidden(code)
    fp = cache.Fingerprinter(ROOT)
    for m in imports:
        if m.split(".")[0] not in EXTERNAL_ROOTS and not fp.is_own(m):
            return {**base, "status": "refused",
                    "problems": [f"unknown module {m} (not first-party, not one of {sorted(EXTERNAL_ROOTS)})"]}
    key = fp.fingerprint_text(text)
    with open_memory(home) as mem:
        hit = mem.result(key, "check")
        if hit and hit["status"] in ("ok", "error"):
            run = mem.db.execute("SELECT * FROM build_runs WHERE id = ?", (hit["run_id"],)).fetchone()
            log = (mem.get_blob(run["log_blob"]) or b"").decode(errors="replace") if run and run["log_blob"] else ""
            msgs = parse_messages(log, header_lines)
            return {**base, "status": hit["status"], "cached": True, "fingerprint": key,
                    "compiled_ok": hit["status"] == "ok", "messages": msgs, "forbidden_tokens": forbidden,
                    "uses_sorry_warning": any("declaration uses 'sorry'" in x["message"] for x in msgs),
                    "wall_s": run["wall_s"] if run else None}
    floor_kb = int((min_free_gb if min_free_gb is not None else memory_gb) * scheduler.GB)
    lean_file = scratch / f"snippet_{key[:24]}.lean"
    with compile_lock(scratch / ".compile.lock", lock_wait_s) as got:
        if not got:
            return {**base, "status": "busy", "message": f"another snippet compile holds the lock (waited {lock_wait_s} s)"}
        avail = scheduler.mem_available_kb()
        if runner is scheduler.run_guarded and avail < floor_kb:
            return {**base, "status": "refused_low_memory",
                    "message": f"MemAvailable {avail / scheduler.GB:.1f} GB < {floor_kb / scheduler.GB:.1f} GB needed; "
                               "another Lean process is probably running. Try later."}
        scratch.mkdir(parents=True, exist_ok=True)
        lean_file.write_text(text, encoding="utf-8")
        cmd = ["lake", "env", "lean", *source.lake_lean_options(ROOT), str(lean_file)]
        log_path = scratch / f"snippet_{key[:24]}.log"
        res = runner(cmd, ROOT, int(memory_gb * scheduler.GB), min_available_kb=2 * scheduler.GB,
                     timeout_s=timeout_s, log_path=log_path)
        log_path.unlink(missing_ok=True)
    msgs = parse_messages(res.output, header_lines)
    status = res.status
    if status == "error" and (not msgs or any(m["severity"] == "error" and (m["line"] <= 0 or "object file" in m["message"])
                                              for m in msgs)):
        # an import / build-state failure (e.g. a stale .olean), not a verdict on the snippet: never cached
        status = "infra_error"
    with open_memory(home) as mem:
        mem.record_run("<snippet>", key, "check", cmd, status, res.returncode, res.wall_s,
                       peak_rss_kb=res.peak_rss_kb, peak_anon_kb=res.peak_anon_kb, log=res.output or None,
                       note=res.note)
    return {**base, "status": status, "cached": False, "fingerprint": key, "compiled_ok": res.status == "ok",
            "messages": msgs, "forbidden_tokens": forbidden,
            "uses_sorry_warning": any("declaration uses 'sorry'" in x["message"] for x in msgs),
            "wall_s": round(res.wall_s, 2), "peak_anon_gb": round(res.peak_anon_kb / scheduler.GB, 2),
            "scratch_file": str(lean_file), **({"note": res.note} if res.note else {})}


# ---- server ------------------------------------------------------------------------------------
INSTRUCTIONS = f"""LeanMaster: Lean 4 (v4.33.1) + Mathlib formalization of T-duality, K3 x T^2 lattices, double field
theory, the dual-scale bound, moonshine and dyon counting. Use search_theorems before stating a new theorem,
get_declaration for the exact statement/location/status, verified_status for the recorded gate numbers,
usage_guide for how to depend on and cite it. {TIER_RULES} {NOT_A_GATE}"""


def build_server():
    from mcp.server.fastmcp import FastMCP
    from mcp.types import ToolAnnotations

    ro = ToolAnnotations(readOnlyHint=True, destructiveHint=False, openWorldHint=False)
    srv = FastMCP("leanmaster", instructions=INSTRUCTIONS)

    @srv.tool(name="search_theorems", annotations=ro)
    def search_theorems_tool(query: str, k: int = 10, theorems_only: bool = True) -> dict:
        """Search LeanMaster's declarations (BM25 + kernel-dependency neighbours). Returns name, file:line,
        statement, kernel_status ('A' only if locked, unchanged since lock and axiom-audited OK), docstring
        excerpt, tier mentions and paper pins. A hit is not a proof certificate."""
        return search_theorems(query, k, theorems_only)

    @srv.tool(name="get_declaration", annotations=ro)
    def get_declaration_tool(name: str) -> dict:
        """Full record of one declaration (qualified name preferred): statement, docstring, file:line,
        current vs locked statement hash, axioms from the last ingested audit, paper pins, kernel-level
        dependencies and dependents, prior prover attempts."""
        return get_declaration(name)

    @srv.tool(name="verified_status", annotations=ro)
    def verified_status_tool() -> dict:
        """Gate numbers as last recorded in README.md / docs/VERIFIED_FOUNDATION.md (per-library audited
        theorem counts, total, date; not re-run) plus LeanMemory store statistics."""
        return verified_status()

    @srv.tool(name="impact", annotations=ro)
    def impact_tool(module: str) -> dict:
        """Reverse import closure of a first-party module, e.g. 'DualScaleDyons.KummerD4': every module a
        change to it can invalidate."""
        return impact(module)

    @srv.tool(name="check_statement_lock", annotations=ro)
    def check_statement_lock_tool(files: list[str] | None = None) -> dict:
        """Run tools/statement_lock.py --check (pure Python, no Lean) on repo-relative .lean files (default:
        all first-party files). Exit 0 = no locked statement changed or removed."""
        return check_statement_lock(files)

    @srv.tool(name="usage_guide", annotations=ro)
    def usage_guide_tool() -> str:
        """How to depend on LeanMaster from another Lake project, use its gate tools, and cite results
        (tier rules A/L/C; axioms propext, Classical.choice, Quot.sound only)."""
        return usage_guide()

    @srv.tool(name="check_lean_snippet", annotations=ToolAnnotations(readOnlyHint=False, destructiveHint=False, idempotentHint=True,
                                          openWorldHint=False))
    async def check_lean_snippet_tool(code: str, imports: list[str] | None = None, timeout_s: float = 600,
                                      memory_gb: float = 12) -> dict:
        """Compile a Lean 4 snippet (no import lines; modules go in `imports`, default ['DualScaleDyons']) with
        lake env lean under a memory guard, one compile at a time, cached by fingerprint. Returns errors and
        whether sorry/admit/native_decide/axiom appear. Refuses #eval, macros/elaborators, IO, unsafe code.
        A successful compile is NOT a gate pass. Slow when the Mathlib .oleans are not in page cache."""
        import anyio
        return await anyio.to_thread.run_sync(lambda: check_lean_snippet(code, imports, timeout_s, memory_gb))

    @srv.resource("leanmaster://verified-foundation", mime_type="text/markdown",
                  description="docs/VERIFIED_FOUNDATION.md: verified status and the exact statements others may build on")
    def verified_foundation_doc() -> str:
        return VERIFIED.read_text()

    @srv.resource("leanmaster://lessons", mime_type="text/markdown", description="LL.md: lessons learned")
    def lessons_doc() -> str:
        return (ROOT / "LL.md").read_text()

    return srv


def main() -> None:
    build_server().run("stdio")


if __name__ == "__main__":
    main()
