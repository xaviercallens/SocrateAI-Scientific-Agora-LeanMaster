"""
leanstack/datastore.py — LeanDatastore: load what the existing gate tools produce into LeanMemory.

Sources (all existing, none replaced):
  * the Lean sources           -> declarations (qualified name, kind, statement, docstring, line,
                                  tiers named in the docstring, papers/foundations pins)
  * docs/statement_lock.json   -> declarations.lock_hash (tools/statement_lock.py --update writes it)
  * tools/axiom_audit.py output-> declarations.axioms / audit_status (saved stdout; the tool prints
                                  "OK      Name  ['propext', ...]", "FAIL    …", "MISSING  …")
  * .leancache/depgraph.jsonl  -> edges (tools/lean_depgraph.lean: kernel-level type/value constants)
  * .leancache/prover_attempts.jsonl -> attempts (tools/prover_loop.py's log)
  * `decide +kernel` scan      -> heavy_decls (the registry the scheduler consults)
  * Lake .trace files          -> lake_traces

Honesty rules this module keeps:
  * The lock is compared with the hash of the *current* statement text (same hash as
    tools/statement_lock.py); 'locked' means equal, nothing else.
  * An axiom-audit result is invalidated (cleared) when a later source ingest sees the statement
    hash change; `kernel_status()` reports 'A' only if the audit said OK and the statement is locked
    and unchanged.
  * Tiers named in docstrings are stored as *mentions*; this module never assigns L or C itself.
"""

import ast
import json
import re
import time
from pathlib import Path

from leanstack import source
from leanstack.cache import lake_trace
from leanstack.memory import LeanMemory

AUDIT_LINE = re.compile(r"^(OK|FAIL|MISSING)\s+(\S+)\s*(.*)$")
STANDARD_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}


def rel(path: Path, root: Path) -> str:
    return str(Path(path).resolve().relative_to(root.resolve()))


def ingest_sources(memory: LeanMemory, files: list[Path], root: Path = source.REPO_ROOT,
                   force: bool = False) -> int:
    """Parse declarations from source files. Files whose source hash is unchanged since the last
    ingest are skipped (incremental). Returns the number of declarations (re)stored."""
    n = 0
    for f in files:
        f = Path(f)
        text = f.read_text(encoding="utf-8", errors="ignore")
        module = source.module_of(f, root)
        frel = rel(f, root)
        known = memory.module(module)
        if not force and known and known.get("source_sha") == source.sha256_bytes(text.encode()) \
                and known.get("n_lines") is not None:
            continue
        seen = set()
        code = source.blank_comments(text)
        for d in source.declarations(text, code):
            if d["short"] in seen:      # same short name twice in one file: keep the first (lock semantics)
                continue
            seen.add(d["short"])
            sh = source.statement_hash(d["statement"])
            old = memory.db.execute("SELECT statement_hash FROM declarations WHERE file = ? AND short = ?",
                                    (frel, d["short"])).fetchone()
            if old and old[0] != sh:     # statement changed: the old audit no longer applies
                memory.db.execute("UPDATE declarations SET axioms = NULL, audit_status = NULL, audit_ts = NULL "
                                  "WHERE file = ? AND short = ?", (frel, d["short"]))
            memory.upsert_declaration(
                frel, d["short"], commit=False, name=d["name"], module=module, kind=d["kind"],
                line=d["line"], statement=d["statement"], statement_hash=sh,
                docstring=d["docstring"], tiers=d["tiers"], pins=d["pins"])
            n += 1
        stale = memory.db.execute("SELECT short FROM declarations WHERE file = ?", (frel,)).fetchall()
        for (short,) in stale:
            if short not in seen:       # removed from the source: drop it (the event log keeps the history)
                memory.db.execute("DELETE FROM declarations WHERE file = ? AND short = ?", (frel, short))
                memory.event("declaration_removed", f"{frel}::{short}")
        memory.upsert_module(module, path=frel, library=source.library_of(module, root),
                             source_sha=source.sha256_bytes(text.encode()), n_lines=text.count("\n") + 1,
                             imports=source.imports(text))
        for h in source.heavy_kernel_decls(text, code):
            memory.upsert_heavy(module, h["short"], h["line"], h["calls"])
    memory.db.commit()
    memory.event("ingest_sources", str(len(files)), declarations=n)
    return n


def ingest_statement_lock(memory: LeanMemory, lock_path: Path) -> dict:
    """Attach lock hashes. Returns counts: locked entries, matched in the store, changed, missing."""
    lock = json.loads(Path(lock_path).read_text())
    counts = {"locked": 0, "matched": 0, "changed": 0, "not_in_store": 0}
    for file, decls in lock.items():
        for short, h in decls.items():
            counts["locked"] += 1
            row = memory.db.execute("SELECT statement_hash FROM declarations WHERE file = ? AND short = ?",
                                    (file, short)).fetchone()
            if row is None:
                counts["not_in_store"] += 1
                continue
            memory.db.execute("UPDATE declarations SET lock_hash = ? WHERE file = ? AND short = ?", (h, file, short))
            counts["matched" if row[0] == h else "changed"] += 1
    memory.db.commit()
    memory.event("ingest_statement_lock", str(lock_path), **counts)
    return counts


def parse_axiom_audit(text: str) -> dict[str, dict]:
    """Parse tools/axiom_audit.py stdout. name -> {'status': OK|FAIL|MISSING, 'axioms': [...]}."""
    out = {}
    for line in text.splitlines():
        m = AUDIT_LINE.match(line.strip())
        if not m:
            continue
        status, name, rest = m.groups()
        axioms = []
        rest = rest.strip()
        if rest.startswith("["):
            try:
                axioms = list(ast.literal_eval(rest))
            except (ValueError, SyntaxError):
                axioms = [a.strip(" '\"") for a in rest.strip("[]").split(",") if a.strip()]
        out[name] = {"status": status, "axioms": axioms}
    return out


def ingest_axiom_audit(memory: LeanMemory, text: str, audit_ts: float | None = None) -> dict:
    """Attach audit results to declarations by qualified name. The audit's own verdict is kept,
    and re-derived from the axiom list as a cross-check (they must agree)."""
    audit_ts = audit_ts or time.time()
    results = parse_axiom_audit(text)
    counts = {"parsed": len(results), "matched": 0, "unmatched": 0, "disagree": 0}
    for name, r in results.items():
        derived = "MISSING" if r["status"] == "MISSING" else ("OK" if set(r["axioms"]) <= STANDARD_AXIOMS else "FAIL")
        if derived != r["status"]:
            counts["disagree"] += 1
        rows = memory.db.execute("SELECT file, short, statement_hash FROM declarations WHERE name = ?", (name,)).fetchall()
        if not rows:
            counts["unmatched"] += 1
            continue
        for file, short, sh in rows:
            memory.db.execute("UPDATE declarations SET axioms = ?, audit_status = ?, audit_ts = ? WHERE file = ? AND short = ?",
                              (json.dumps(r["axioms"]), r["status"], audit_ts, file, short))
            memory.event("axiom_audit", name, status=r["status"], audit_stmt_hash=sh)
            counts["matched"] += 1
    memory.db.commit()
    return counts


def ingest_depgraph(memory: LeanMemory, path: Path) -> int:
    """Kernel-level edges from tools/lean_depgraph.lean output: 'type' = used in the statement,
    'value' = used in the proof/body."""
    rows = []
    for line in Path(path).read_text().splitlines():
        if not line.startswith("{"):
            continue
        d = json.loads(line)
        rows += [(d["name"], c, "type") for c in d.get("type", []) if c != d["name"]]
        rows += [(d["name"], c, "value") for c in d.get("value", []) if c != d["name"]]
    memory.add_edges(rows)
    memory.event("ingest_depgraph", str(path), edges=len(rows))
    return len(rows)


def ingest_prover_attempts(memory: LeanMemory, path: Path) -> dict:
    """tools/prover_loop.py's JSONL log -> attempts; rejected attempts also become failure patterns,
    so the next prover sees 'this exact error on this theorem, N times' before trying again."""
    counts = {"read": 0, "new": 0}
    for line in Path(path).read_text().splitlines():
        if not line.strip():
            continue
        a = json.loads(line)
        counts["read"] += 1
        new = memory.record_attempt(a.get("file", ""), a.get("theorem", ""), a.get("model", ""),
                                    a.get("accepted", False), a.get("reason", ""), a.get("proof", ""),
                                    a.get("first_error", ""), a.get("llm_latency_s", 0.0), a.get("ts"), str(path))
        if new:
            counts["new"] += 1
            if not a.get("accepted"):
                pattern = normalize_error(a.get("first_error") or a.get("reason", ""))
                memory.record_failure("prover", pattern, a.get("first_error", ""),
                                      module=a.get("file", ""), decl=a.get("theorem", ""))
    return counts


def normalize_error(msg: str) -> str:
    """Strip positions, file names and numbers so the same error in two places has one pattern."""
    msg = re.sub(r"\S+\.lean:\d+:\d+:?", "", msg)
    msg = re.sub(r"\b\d+\b", "N", msg)
    return " ".join(msg.split())[:200]


def ingest_lake_traces(memory: LeanMemory, modules: list[str], root: Path = source.REPO_ROOT) -> dict:
    counts = {"found": 0, "absent": 0, "unknown_schema": 0}
    for m in modules:
        t = lake_trace(m, root)
        if t is None:
            counts["absent"] += 1
        elif t.get("unknown_schema"):
            counts["unknown_schema"] += 1
        else:
            memory.upsert_lake_trace(m, t)
            counts["found"] += 1
    return counts


def kernel_status(row: dict) -> str:
    """'A' when the declaration is a theorem whose statement is locked and unchanged and whose axiom
    audit said OK; otherwise the reason it is not (yet) Tier A. This is about the Lean statement only —
    what the statement means physically is a separate, human-assigned tier (L or C)."""
    if row.get("kind") != "theorem":
        return "n/a (not a theorem)"
    if not row.get("lock_hash"):
        return "unlocked"
    if row["lock_hash"] != row.get("statement_hash"):
        return "statement changed since lock"
    if row.get("audit_status") != "OK":
        return f"audit {row.get('audit_status') or 'not run'}"
    return "A"
