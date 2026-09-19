"""
leanstack/memory.py — LeanMemory, the one store every other layer reads and writes.

Layout under the root (default /mnt/disks/disk-socrateai-local-1/leanmaster/leanstack, never the
root disk — LL.md Lesson 0.8; override with LEANSTACK_HOME or the `root` argument):

    <root>/memory.db        SQLite in WAL mode: entities + an append-only event log
    <root>/blobs/ab/cdef…   content-addressed blobs (sha256 of the bytes): build logs, proofs, outputs
    <root>/logs/            live logs of running builds (moved into blobs when the run ends)

Tables (entities):
    modules         one row per Lean module: path, library, source hash, last fingerprint
    declarations    one row per (file, short name): statement + lock hash, axiom-audit result,
                    tiers named in the docstring, source pins (papers/foundations/<file>.txt + lines)
    edges           declaration -> declaration, kind 'type' or 'value' (kernel level, from depgraph.jsonl)
    build_runs      every build/check the scheduler ran: fingerprint, status, wall time, peak memory
    results         the LeanCache: (fingerprint, action) -> last status and the run that produced it
    attempts        prover attempts (episodic memory; tools/prover_loop.py's log is ingested here)
    failures        normalized failure patterns: what went wrong, where, how often
    lessons         short durable lessons keyed by a slug (the machine-readable side of LL.md)
    heavy_decls     declarations known or suspected to need a lot of kernel memory
    lake_traces     Lake's own per-module trace (depHash, toolchain, options) for cross-checking
    events          append-only log: (ts, kind, entity, payload JSON)

Nothing in this file interprets Lean. It stores what the other layers found.
"""

import hashlib
import json
import os
import sqlite3
import time
from pathlib import Path

DEFAULT_ROOT = Path("/mnt/disks/disk-socrateai-local-1/leanmaster/leanstack")

SCHEMA = """
CREATE TABLE IF NOT EXISTS modules (
    name TEXT PRIMARY KEY, path TEXT, library TEXT, source_sha TEXT, fingerprint TEXT,
    n_lines INTEGER, imports TEXT, updated REAL
);
CREATE TABLE IF NOT EXISTS declarations (
    file TEXT, short TEXT, name TEXT, module TEXT, kind TEXT, line INTEGER,
    statement TEXT, statement_hash TEXT, lock_hash TEXT, docstring TEXT,
    axioms TEXT, audit_status TEXT, audit_ts REAL, tiers TEXT, pins TEXT, updated REAL,
    PRIMARY KEY (file, short)
);
CREATE INDEX IF NOT EXISTS decl_name ON declarations (name);
CREATE INDEX IF NOT EXISTS decl_module ON declarations (module);
CREATE TABLE IF NOT EXISTS edges (
    src TEXT, dst TEXT, kind TEXT, PRIMARY KEY (src, dst, kind)
);
CREATE INDEX IF NOT EXISTS edges_dst ON edges (dst);
CREATE TABLE IF NOT EXISTS build_runs (
    id INTEGER PRIMARY KEY AUTOINCREMENT, module TEXT, fingerprint TEXT, action TEXT, command TEXT,
    status TEXT, returncode INTEGER, wall_s REAL, peak_rss_kb INTEGER, peak_anon_kb INTEGER,
    started REAL, ended REAL, log_blob TEXT, note TEXT
);
CREATE INDEX IF NOT EXISTS runs_module ON build_runs (module);
CREATE TABLE IF NOT EXISTS results (
    fingerprint TEXT, action TEXT, module TEXT, status TEXT, run_id INTEGER, ts REAL,
    PRIMARY KEY (fingerprint, action)
);
CREATE TABLE IF NOT EXISTS attempts (
    id INTEGER PRIMARY KEY AUTOINCREMENT, file TEXT, theorem TEXT, model TEXT, accepted INTEGER,
    reason TEXT, proof_blob TEXT, first_error TEXT, latency_s REAL, ts REAL, source TEXT,
    UNIQUE (file, theorem, model, ts)
);
CREATE TABLE IF NOT EXISTS failures (
    id INTEGER PRIMARY KEY AUTOINCREMENT, kind TEXT, module TEXT, decl TEXT, pattern TEXT,
    message TEXT, count INTEGER DEFAULT 1, first_ts REAL, last_ts REAL,
    UNIQUE (kind, module, decl, pattern)
);
CREATE TABLE IF NOT EXISTS lessons (
    key TEXT PRIMARY KEY, text TEXT, source TEXT, ts REAL
);
CREATE TABLE IF NOT EXISTS heavy_decls (
    module TEXT, short TEXT, line INTEGER, kernel_calls INTEGER, peak_anon_kb INTEGER, note TEXT,
    PRIMARY KEY (module, short)
);
CREATE TABLE IF NOT EXISTS lake_traces (
    module TEXT PRIMARY KEY, dep_hash TEXT, schema_version TEXT, toolchain TEXT, options TEXT,
    trace_mtime REAL, ts REAL
);
CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY AUTOINCREMENT, ts REAL, kind TEXT, entity TEXT, payload TEXT
);
"""


def default_root() -> Path:
    return Path(os.environ.get("LEANSTACK_HOME") or DEFAULT_ROOT)


class LeanMemory:
    def __init__(self, root: Path | str | None = None):
        self.root = Path(root) if root else default_root()
        (self.root / "blobs").mkdir(parents=True, exist_ok=True)
        (self.root / "logs").mkdir(parents=True, exist_ok=True)
        self.db_path = self.root / "memory.db"
        self.db = sqlite3.connect(str(self.db_path), timeout=30)
        self.db.row_factory = sqlite3.Row
        self.db.execute("PRAGMA journal_mode=WAL")
        self.db.execute("PRAGMA synchronous=NORMAL")
        self.db.executescript(SCHEMA)
        self.db.commit()

    def close(self) -> None:
        self.db.close()

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()

    # ---- content-addressed blobs ---------------------------------------------------------
    def _blob_path(self, digest: str) -> Path:
        return self.root / "blobs" / digest[:2] / digest[2:]

    def put_blob(self, data: bytes | str) -> str:
        if isinstance(data, str):
            data = data.encode("utf-8")
        digest = hashlib.sha256(data).hexdigest()
        path = self._blob_path(digest)
        if not path.exists():
            path.parent.mkdir(parents=True, exist_ok=True)
            tmp = path.with_suffix(f".tmp{os.getpid()}")
            tmp.write_bytes(data)
            os.replace(tmp, path)  # atomic: a reader never sees a half-written blob
        return digest

    def get_blob(self, digest: str) -> bytes | None:
        path = self._blob_path(digest)
        if not path.exists():
            return None
        data = path.read_bytes()
        if hashlib.sha256(data).hexdigest() != digest:
            raise ValueError(f"blob {digest} is corrupt")
        return data

    def put_file(self, path: Path) -> str:
        return self.put_blob(Path(path).read_bytes())

    # ---- events ---------------------------------------------------------------------------
    def event(self, kind: str, entity: str, **payload) -> None:
        self.db.execute("INSERT INTO events (ts, kind, entity, payload) VALUES (?,?,?,?)",
                        (time.time(), kind, entity, json.dumps(payload, sort_keys=True, default=str)))
        self.db.commit()

    def events(self, kind: str | None = None, limit: int = 50) -> list[dict]:
        q = "SELECT * FROM events" + (" WHERE kind = ?" if kind else "") + " ORDER BY id DESC LIMIT ?"
        rows = self.db.execute(q, ((kind, limit) if kind else (limit,))).fetchall()
        return [dict(r) | {"payload": json.loads(r["payload"])} for r in rows]

    # ---- modules --------------------------------------------------------------------------
    def upsert_module(self, name: str, **fields) -> None:
        fields = {**fields, "updated": time.time()}
        if "imports" in fields and not isinstance(fields["imports"], str):
            fields["imports"] = json.dumps(fields["imports"])
        cols = ", ".join(fields)
        marks = ", ".join("?" for _ in fields)
        update = ", ".join(f"{c}=excluded.{c}" for c in fields)
        self.db.execute(f"INSERT INTO modules (name, {cols}) VALUES (?, {marks}) "
                        f"ON CONFLICT(name) DO UPDATE SET {update}", (name, *fields.values()))
        self.db.commit()

    def module(self, name: str) -> dict | None:
        r = self.db.execute("SELECT * FROM modules WHERE name = ?", (name,)).fetchone()
        return dict(r) if r else None

    # ---- declarations ---------------------------------------------------------------------
    def upsert_declaration(self, file: str, short: str, commit: bool = True, **fields) -> None:
        fields = {k: (json.dumps(v) if isinstance(v, (list, dict)) else v) for k, v in fields.items()}
        fields["updated"] = time.time()
        cols = ", ".join(fields)
        marks = ", ".join("?" for _ in fields)
        update = ", ".join(f"{c}=excluded.{c}" for c in fields)
        self.db.execute(f"INSERT INTO declarations (file, short, {cols}) VALUES (?, ?, {marks}) "
                        f"ON CONFLICT(file, short) DO UPDATE SET {update}", (file, short, *fields.values()))
        if commit:
            self.db.commit()

    def declarations(self, where: str = "1=1", params: tuple = ()) -> list[dict]:
        return [dict(r) for r in self.db.execute(f"SELECT * FROM declarations WHERE {where}", params)]

    # ---- edges ----------------------------------------------------------------------------
    def add_edges(self, rows: list[tuple[str, str, str]]) -> None:
        self.db.executemany("INSERT OR IGNORE INTO edges (src, dst, kind) VALUES (?,?,?)", rows)
        self.db.commit()

    def neighbours(self, name: str) -> dict[str, list[str]]:
        uses = [r[0] for r in self.db.execute("SELECT DISTINCT dst FROM edges WHERE src = ?", (name,))]
        used_by = [r[0] for r in self.db.execute("SELECT DISTINCT src FROM edges WHERE dst = ?", (name,))]
        return {"uses": uses, "used_by": used_by}

    # ---- build runs and the result cache --------------------------------------------------
    def record_run(self, module: str, fingerprint: str, action: str, command: list[str] | str,
                   status: str, returncode: int | None, wall_s: float, peak_rss_kb: int = 0,
                   peak_anon_kb: int = 0, started: float | None = None, log: bytes | str | None = None,
                   note: str = "") -> int:
        log_blob = self.put_blob(log) if log else None
        ended = time.time()
        cur = self.db.execute(
            "INSERT INTO build_runs (module, fingerprint, action, command, status, returncode, wall_s, "
            "peak_rss_kb, peak_anon_kb, started, ended, log_blob, note) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (module, fingerprint, action, command if isinstance(command, str) else " ".join(command),
             status, returncode, wall_s, peak_rss_kb, peak_anon_kb, started or ended - wall_s, ended,
             log_blob, note))
        run_id = cur.lastrowid
        self.db.execute(
            "INSERT INTO results (fingerprint, action, module, status, run_id, ts) VALUES (?,?,?,?,?,?) "
            "ON CONFLICT(fingerprint, action) DO UPDATE SET status=excluded.status, run_id=excluded.run_id, "
            "ts=excluded.ts, module=excluded.module", (fingerprint, action, module, status, run_id, ended))
        self.db.commit()
        self.event("build_run", module, run_id=run_id, status=status, action=action,
                   peak_anon_kb=peak_anon_kb, wall_s=round(wall_s, 3))
        return run_id

    def result(self, fingerprint: str, action: str) -> dict | None:
        r = self.db.execute("SELECT * FROM results WHERE fingerprint = ? AND action = ?",
                            (fingerprint, action)).fetchone()
        return dict(r) if r else None

    def peak_memory_kb(self, module: str) -> int | None:
        """Largest anonymous-memory peak ever observed for this module (killed runs included:
        a run killed at the budget proves the module needs at least that much)."""
        r = self.db.execute("SELECT MAX(peak_anon_kb) FROM build_runs WHERE module = ? AND peak_anon_kb > 0",
                            (module,)).fetchone()
        return r[0] if r and r[0] else None

    def runs(self, module: str | None = None, limit: int = 20) -> list[dict]:
        q = "SELECT * FROM build_runs" + (" WHERE module = ?" if module else "") + " ORDER BY id DESC LIMIT ?"
        return [dict(r) for r in self.db.execute(q, ((module, limit) if module else (limit,)))]

    # ---- episodic memory: attempts, failures, lessons ------------------------------------
    def record_attempt(self, file: str, theorem: str, model: str, accepted: bool, reason: str = "",
                       proof: str = "", first_error: str = "", latency_s: float = 0.0,
                       ts: float | None = None, source: str = "") -> bool:
        """Returns False when the same attempt (file, theorem, model, ts) was already stored."""
        cur = self.db.execute(
            "INSERT OR IGNORE INTO attempts (file, theorem, model, accepted, reason, proof_blob, first_error, "
            "latency_s, ts, source) VALUES (?,?,?,?,?,?,?,?,?,?)",
            (file, theorem, model, int(bool(accepted)), reason, self.put_blob(proof) if proof else None,
             first_error, latency_s, ts or time.time(), source))
        self.db.commit()
        return cur.rowcount == 1

    def attempts_for(self, theorem: str) -> list[dict]:
        return [dict(r) for r in self.db.execute(
            "SELECT * FROM attempts WHERE theorem = ? ORDER BY ts", (theorem,))]

    def record_failure(self, kind: str, pattern: str, message: str = "", module: str = "", decl: str = "") -> None:
        now = time.time()
        self.db.execute(
            "INSERT INTO failures (kind, module, decl, pattern, message, first_ts, last_ts) VALUES (?,?,?,?,?,?,?) "
            "ON CONFLICT(kind, module, decl, pattern) DO UPDATE SET count = count + 1, last_ts = excluded.last_ts, "
            "message = excluded.message", (kind, module, decl, pattern, message[:2000], now, now))
        self.db.commit()

    def failures(self, module: str | None = None, decl: str | None = None) -> list[dict]:
        where, params = [], []
        if module:
            where.append("module = ?")
            params.append(module)
        if decl:
            where.append("decl = ?")
            params.append(decl)
        q = "SELECT * FROM failures" + (" WHERE " + " AND ".join(where) if where else "") + " ORDER BY count DESC"
        return [dict(r) for r in self.db.execute(q, params)]

    def add_lesson(self, key: str, text: str, source: str = "") -> None:
        self.db.execute("INSERT INTO lessons (key, text, source, ts) VALUES (?,?,?,?) ON CONFLICT(key) DO UPDATE "
                        "SET text=excluded.text, source=excluded.source, ts=excluded.ts",
                        (key, text, source, time.time()))
        self.db.commit()

    def lessons(self) -> list[dict]:
        return [dict(r) for r in self.db.execute("SELECT * FROM lessons ORDER BY key")]

    # ---- heavy declarations and Lake traces -----------------------------------------------
    def upsert_heavy(self, module: str, short: str, line: int, kernel_calls: int,
                     peak_anon_kb: int | None = None, note: str = "") -> None:
        self.db.execute(
            "INSERT INTO heavy_decls (module, short, line, kernel_calls, peak_anon_kb, note) VALUES (?,?,?,?,?,?) "
            "ON CONFLICT(module, short) DO UPDATE SET line=excluded.line, kernel_calls=excluded.kernel_calls, "
            "peak_anon_kb=COALESCE(excluded.peak_anon_kb, heavy_decls.peak_anon_kb), "
            "note=CASE WHEN excluded.note != '' THEN excluded.note ELSE heavy_decls.note END",
            (module, short, line, kernel_calls, peak_anon_kb, note))
        self.db.commit()

    def heavy(self, module: str | None = None) -> list[dict]:
        q = "SELECT * FROM heavy_decls" + (" WHERE module = ?" if module else "") + " ORDER BY module, line"
        return [dict(r) for r in self.db.execute(q, ((module,) if module else ()))]

    def upsert_lake_trace(self, module: str, trace: dict) -> None:
        self.db.execute(
            "INSERT INTO lake_traces (module, dep_hash, schema_version, toolchain, options, trace_mtime, ts) "
            "VALUES (?,?,?,?,?,?,?) ON CONFLICT(module) DO UPDATE SET dep_hash=excluded.dep_hash, "
            "schema_version=excluded.schema_version, toolchain=excluded.toolchain, options=excluded.options, "
            "trace_mtime=excluded.trace_mtime, ts=excluded.ts",
            (module, trace.get("dep_hash"), trace.get("schema_version"), trace.get("toolchain"),
             json.dumps(trace.get("options", [])), trace.get("mtime"), time.time()))
        self.db.commit()

    def stats(self) -> dict:
        tables = ["modules", "declarations", "edges", "build_runs", "results", "attempts", "failures",
                  "lessons", "heavy_decls", "lake_traces", "events"]
        out = {t: self.db.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0] for t in tables}
        out["root"] = str(self.root)
        return out
