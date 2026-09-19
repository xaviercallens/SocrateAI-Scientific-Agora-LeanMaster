"""
tests/test_leanstack.py — unit tests for leanstack/. No Lean build, no `lake` call; runs in seconds.

    python3 -m pytest tests/test_leanstack.py -q

The memory-guard tests spawn small Python children (a few hundred MB at most) to check that the
guard sums memory over the whole process group and kills it at the budget.
"""

import json
import sys
import textwrap
import time
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO))

from leanstack import cache, datastore, scheduler, source, warm  # noqa: E402
from leanstack.cli import main as cli_main  # noqa: E402
from leanstack.memory import LeanMemory  # noqa: E402
from leanstack.rag import LexicalIndex, Retriever, tokens  # noqa: E402

LAKEFILE = """import Lake
open Lake DSL

package «demo» where
  srcDir := "."
  leanOptions := #[
    ⟨`maxHeartbeats, (1000000 : Nat)⟩,
    ⟨`maxRecDepth, (8000 : Nat)⟩
  ]

-- lean_lib «Commented» where
lean_lib «Demo» where
  roots := #[`Demo]
"""


def make_repo(tmp: Path, files: dict[str, str], manifest_rev: str = "abc") -> Path:
    (tmp / "lakefile.lean").write_text(LAKEFILE)
    (tmp / "lean-toolchain").write_text("leanprover/lean4:v4.33.1\n")
    (tmp / "lake-manifest.json").write_text(json.dumps({"packages": [{"name": "mathlib", "rev": manifest_rev}]}))
    for rel, text in files.items():
        p = tmp / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(textwrap.dedent(text))
    return tmp


DEMO = {
    "Demo.lean": "import Demo.C\n",
    "Demo/A.lean": "-- A\ndef a : Nat := 1\n",
    "Demo/B.lean": "/- header -/\nimport Demo.A\n\ntheorem b : a = 1 := rfl\n",
    "Demo/C.lean": "import Demo.B\nimport Mathlib.Data.Nat.Basic\n\ntheorem c : a + 0 = 1 := by\n  decide +kernel\n",
}


@pytest.fixture
def mem(tmp_path):
    m = LeanMemory(tmp_path / "home")
    yield m
    m.close()


# ---- source ---------------------------------------------------------------------------------
def test_imports_header_only():
    text = "/- doc\nimport Fake -/\nmodule\npublic import A.B\nimport all C\nmeta import D  -- c\n\ndef x := 1\nimport NotHeader\n"
    assert source.imports(text) == ["A.B", "C", "D"]


def test_lakefile_parsing_on_real_repo():
    assert source.lake_lean_options(REPO) == ["-DmaxHeartbeats=1000000", "-DmaxRecDepth=8000"]
    libs = source.lean_libs(REPO)
    assert {"StringTheoryFoundation", "DualScaleStream2", "DualScaleDyons"} <= set(libs)
    assert libs["DualScaleDyons"] == ["DualScaleDyons"]


def test_lakefile_parsing_ignores_commented_libs(tmp_path):
    make_repo(tmp_path, DEMO)
    assert source.lean_libs(tmp_path) == {"Demo": ["Demo"]}
    assert set(source.own_modules(tmp_path)) == {"Demo", "Demo.A", "Demo.B", "Demo.C"}


def test_declarations_namespaces_docstrings_pins():
    text = textwrap.dedent('''
        namespace Foo.Bar
        /-- Uses `papers/foundations/hep-th_0301139.txt`, §2.2, ll. 160–163 (Tier L).
        theorem fake : True := trivial -/
        @[simp] theorem t1 (n : Nat) : n + 0 = n := by
          simp
        -- theorem commented : False := sorry
        private lemma t2 : 1 = 1 := rfl
        end Foo.Bar
        def top := 3
        ''')
    ds = source.declarations(text)
    assert [d["name"] for d in ds] == ["Foo.Bar.t1", "Foo.Bar.t2", "top"]
    t1 = ds[0]
    assert t1["statement"] == "@[simp] theorem t1 (n : Nat) : n + 0 = n"
    assert t1["pins"] == [{"file": "hep-th_0301139.txt", "lines": [160, 163]}]
    assert t1["tiers"] == ["L"]
    assert t1["line"] == 5 and ds[1]["kind"] == "theorem"


def test_statement_hash_matches_statement_lock():
    """Cross-check with an independent tool: every locked declaration's hash must be reproduced."""
    lock = json.loads((REPO / "docs" / "statement_lock.json").read_text())
    checked = mismatched = 0
    for f, decls in lock.items():
        p = REPO / f
        if not p.exists():
            continue
        got = {}
        for d in source.declarations(p.read_text()):
            got.setdefault(d["short"], source.statement_hash(d["statement"]))
        for name, h in decls.items():
            checked += 1
            mismatched += got.get(name) != h
    assert checked > 500 and mismatched == 0


def test_heavy_kernel_decls_ignore_comments():
    text = "theorem a : True := by\n  -- decide +kernel\n  trivial\ntheorem b : 2 = 2 := by\n  decide +kernel\n"
    assert [(h["short"], h["calls"]) for h in source.heavy_kernel_decls(text)] == [("b", 1)]


# ---- memory ---------------------------------------------------------------------------------
def test_blobs_content_addressed(mem):
    d = mem.put_blob("hello")
    assert d == mem.put_blob(b"hello")
    assert mem.get_blob(d) == b"hello"
    assert mem.get_blob("0" * 64) is None
    mem._blob_path(d).write_bytes(b"tampered")
    with pytest.raises(ValueError):
        mem.get_blob(d)


def test_wal_and_runs(mem):
    assert mem.db.execute("PRAGMA journal_mode").fetchone()[0] == "wal"
    rid = mem.record_run("M", "fp1", "build", ["lake", "build", "M"], "killed_budget", -9, 3.0,
                         peak_rss_kb=900, peak_anon_kb=700, log="out")
    mem.record_run("M", "fp1", "build", "lake build M", "ok", 0, 1.0, peak_anon_kb=500)
    assert mem.peak_memory_kb("M") == 700       # a killed run's peak counts
    assert mem.result("fp1", "build")["status"] == "ok"
    assert mem.get_blob(mem.runs("M")[-1]["log_blob"]) == b"out" and rid


def test_attempts_dedupe_and_failures(mem):
    assert mem.record_attempt("F.lean", "thm", "m", False, "error", "simp", "unsolved goals", 1.0, ts=5.0)
    assert not mem.record_attempt("F.lean", "thm", "m", False, "error", "simp", "unsolved goals", 1.0, ts=5.0)
    mem.record_failure("prover", "unsolved goals", decl="thm")
    mem.record_failure("prover", "unsolved goals", decl="thm")
    assert mem.failures(decl="thm")[0]["count"] == 2


# ---- cache ----------------------------------------------------------------------------------
def test_fingerprint_propagation(tmp_path):
    root = make_repo(tmp_path, DEMO)
    fp0 = {m: cache.Fingerprinter(root).fingerprint(m) for m in ("Demo.A", "Demo.B", "Demo.C")}
    (root / "Demo/A.lean").write_text("def a : Nat := 1 -- edited\n")
    fp1 = {m: cache.Fingerprinter(root).fingerprint(m) for m in fp0}
    assert all(fp0[m] != fp1[m] for m in fp0)            # A changed: A, B, C all change
    (root / "Demo/C.lean").write_text(DEMO["Demo/C.lean"] + "\n")
    fp2 = {m: cache.Fingerprinter(root).fingerprint(m) for m in fp0}
    assert fp2["Demo.A"] == fp1["Demo.A"] and fp2["Demo.B"] == fp1["Demo.B"] and fp2["Demo.C"] != fp1["Demo.C"]
    make_repo(root, {}, manifest_rev="def")              # Mathlib bump: only C imports Mathlib
    fp3 = {m: cache.Fingerprinter(root).fingerprint(m) for m in fp0}
    assert fp3["Demo.B"] == fp2["Demo.B"] and fp3["Demo.C"] != fp2["Demo.C"]
    fp4 = cache.Fingerprinter(root, options=["-DmaxHeartbeats=200000"]).fingerprint("Demo.A")
    assert fp4 != fp3["Demo.A"]                          # options are part of the key


def test_fingerprint_cycle(tmp_path):
    root = make_repo(tmp_path, {"Demo.lean": "import Demo.X\n", "Demo/X.lean": "import Demo.Y\n",
                                "Demo/Y.lean": "import Demo.X\n"})
    with pytest.raises(ValueError):
        cache.Fingerprinter(root).fingerprint("Demo")


def test_text_fingerprint_and_cache(tmp_path, mem):
    root = make_repo(tmp_path, DEMO)
    fp = cache.Fingerprinter(root)
    cand = "import Demo.B\ntheorem x : a = 1 := rfl\n"
    assert fp.fingerprint_text(cand) == fp.fingerprint_text(cand) != fp.fingerprint_text(cand + " ")
    lc = cache.LeanCache(mem, fp)
    assert lc.lookup("Demo.B") is None and lc.stale(["Demo.B"]) == ["Demo.B"]
    lc.record("Demo.B", "build", "ok", command="lake build Demo.B", returncode=0, wall_s=1.0)
    assert lc.is_fresh("Demo.B") and not lc.is_fresh("Demo.B", "audit")
    assert mem.module("Demo.B")["fingerprint"] == fp.fingerprint("Demo.B")


def test_impacted():
    graph = {"A": [], "B": ["A"], "C": ["B"], "D": []}
    assert cache.impacted(["A"], graph) == ["A", "B", "C"]
    assert cache.impacted(["D"], graph) == ["D"]


def test_lake_trace_reader(tmp_path):
    t = tmp_path / ".lake/build/lib/lean/Demo/A.trace"
    t.parent.mkdir(parents=True)
    t.write_text(json.dumps({"schemaVersion": "2025-09-10", "depHash": "5d66", "inputs": [
        ["Lean 4.33.1, commit 8198", "0051"], ["options", [["-DmaxHeartbeats=1000000", "4735"]]]]}))
    r = cache.lake_trace("Demo.A", tmp_path)
    assert r["dep_hash"] == "5d66" and r["toolchain"].startswith("Lean 4.33.1")
    assert r["options"] == ["-DmaxHeartbeats=1000000"]
    t.write_text(json.dumps({"schemaVersion": "2099-01-01", "depHash": "x"}))
    assert cache.lake_trace("Demo.A", tmp_path)["unknown_schema"]
    assert cache.lake_trace("Demo.Missing", tmp_path) is None


# ---- scheduler --------------------------------------------------------------------------------
def test_topo_order_and_cycle():
    assert scheduler.topo_order({"C": ["B"], "B": ["A"], "A": [], "Z": []}) == ["A", "B", "C", "Z"]
    with pytest.raises(ValueError):
        scheduler.topo_order({"A": ["B"], "B": ["A"]})


def test_plan_heavy_history_and_cache(tmp_path, mem):
    root = make_repo(tmp_path, DEMO)
    fp = cache.Fingerprinter(root)
    steps = {s.module: s for s in scheduler.plan(None, mem, fp)}
    assert list(steps) == ["Demo.A", "Demo.B", "Demo.C", "Demo"]
    assert steps["Demo.C"].heavy and steps["Demo.C"].estimate_kb == scheduler.DEFAULT_HEAVY_KB
    assert steps["Demo.A"].estimate_kb == scheduler.DEFAULT_CORE_KB
    assert steps["Demo"].estimate_kb == scheduler.DEFAULT_LIGHT_KB      # Mathlib via Demo.C
    cache.LeanCache(mem, fp).record("Demo.C", "build", "ok", wall_s=1, peak_anon_kb=2 * scheduler.GB)
    steps = {s.module: s for s in scheduler.plan(None, mem, fp)}
    assert steps["Demo.C"].action == "skip"
    assert not steps["Demo.C"].heavy and steps["Demo.C"].estimate_kb == int(2 * scheduler.GB * scheduler.MARGIN)
    assert "HEAVY" not in scheduler.format_plan(list(steps.values()), 20 * scheduler.GB)


def test_execute_heavy_alone_and_failure_skips(tmp_path, mem):
    root = make_repo(tmp_path, {**DEMO, "Demo/D.lean": "def d := 0\n", "Demo/E.lean": "def e := 0\n",
                                "Demo.lean": "import Demo.C\nimport Demo.D\nimport Demo.E\n"})
    fp = cache.Fingerprinter(root)
    steps = scheduler.plan(None, mem, fp)
    concurrency, running = [], set()

    def fake_runner(cmd, cwd, budget_kb, **kw):
        mod = cmd[-1]
        running.add(mod)
        concurrency.append(set(running))
        time.sleep(0.05)
        running.discard(mod)
        status = "error" if mod == "Demo.B" else "ok"
        return scheduler.RunResult(status, 0 if status == "ok" else 1, 0.05, 1000, 500,
                                   "Demo/B.lean:3:0: error: type mismatch\n" if status == "error" else "")

    summary = scheduler.execute(steps, mem, fp, budget_kb=20 * scheduler.GB, max_parallel=4,
                                runner=fake_runner, stop_on_failure=False)
    assert "Demo.B" in summary["failed"]
    assert {"Demo.C", "Demo"} <= set(summary["skipped_dep"])     # dependents of the failure never ran
    assert {"Demo.A", "Demo.D", "Demo.E"} <= set(summary["ok"])
    assert all(len(s) == 1 for s in concurrency if "Demo.C" in s)
    assert mem.failures(module="Demo.B")[0]["pattern"] == "type mismatch"
    assert len(mem.runs()) == 4


CHILD_ALLOC = "import time; b = b'x' * ({mb} * 1024 * 1024); time.sleep({sleep})"


def test_guard_kills_at_budget(tmp_path):
    cmd = [sys.executable, "-c", CHILD_ALLOC.format(mb=300, sleep=20)]
    t0 = time.time()
    r = scheduler.run_guarded(cmd, tmp_path, budget_kb=100 * 1024, poll_s=0.1)
    assert r.status == "killed_budget" and r.peak_anon_kb > 100 * 1024
    assert time.time() - t0 < 15


def test_guard_sums_process_group(tmp_path):
    """The parent uses almost nothing; its child allocates. Polling only the parent would miss it
    (this is `lake` spawning `lean`)."""
    child = CHILD_ALLOC.format(mb=300, sleep=20)
    parent = f"import subprocess, sys; subprocess.run([sys.executable, '-c', {child!r}])"
    r = scheduler.run_guarded([sys.executable, "-c", parent], tmp_path, budget_kb=150 * 1024, poll_s=0.1)
    assert r.status == "killed_budget"
    assert scheduler.group_pids(999999999) == []


def test_guard_ok_and_error(tmp_path):
    log = tmp_path / "log.txt"
    ok = scheduler.run_guarded([sys.executable, "-c", "print('hi')"], tmp_path, 10 * scheduler.GB, log_path=log)
    assert ok.status == "ok" and ok.output.strip() == "hi"
    bad = scheduler.run_guarded([sys.executable, "-c", "raise SystemExit(3)"], tmp_path, 10 * scheduler.GB)
    assert bad.status == "error" and bad.returncode == 3
    slow = scheduler.run_guarded([sys.executable, "-c", "import time; time.sleep(30)"], tmp_path,
                                 10 * scheduler.GB, timeout_s=0.5, poll_s=0.1)
    assert slow.status == "timeout"


def test_first_error_and_commands(tmp_path):
    assert scheduler.first_error("x\nF.lean:3:4: error: unknown identifier 'foo'\n") == "unknown identifier 'foo'"
    root = make_repo(tmp_path, DEMO)
    fp = cache.Fingerprinter(root)
    assert scheduler.command_for("Demo.A", fp, "build") == ["lake", "build", "Demo.A"]
    check = scheduler.command_for("Demo.A", fp, "check")
    assert check[:3] == ["lake", "env", "lean"] and "-DmaxHeartbeats=1000000" in check   # LL.md S2.4


# ---- datastore ----------------------------------------------------------------------------------
AUDIT_OUT = """OK      Demo.b  ['propext']
FAIL    Demo.c  ['Lean.ofReduceBool', 'propext']
MISSING Demo.gone  (no #print axioms output — name resolution failed)
OK      Demo.x  []

3 theorems audited, 2 failing
"""


def test_parse_axiom_audit():
    r = datastore.parse_axiom_audit(AUDIT_OUT)
    assert r["Demo.b"] == {"status": "OK", "axioms": ["propext"]}
    assert r["Demo.c"]["status"] == "FAIL" and r["Demo.gone"]["status"] == "MISSING"
    assert r["Demo.x"]["axioms"] == []


def test_ingest_lock_audit_and_kernel_status(tmp_path, mem):
    files = {"Demo.lean": "import Demo.B\n", "Demo/A.lean": "def a : Nat := 1\n",
             "Demo/B.lean": "import Demo.A\nnamespace Demo\ntheorem b : a = 1 := rfl\nend Demo\n"}
    root = make_repo(tmp_path, files)
    paths = [root / f for f in files]
    assert datastore.ingest_sources(mem, paths, root) == 2
    b = mem.declarations("short = 'b'")[0]
    assert b["name"] == "Demo.b" and datastore.kernel_status(b) == "unlocked"
    lock = tmp_path / "lock.json"
    lock.write_text(json.dumps({"Demo/B.lean": {"b": b["statement_hash"]}, "Demo/Gone.lean": {"z": "0"}}))
    assert datastore.ingest_statement_lock(mem, lock) == {"locked": 2, "matched": 1, "changed": 0, "not_in_store": 1}
    counts = datastore.ingest_axiom_audit(mem, AUDIT_OUT)
    assert counts["matched"] == 1 and counts["disagree"] == 0
    assert datastore.kernel_status(mem.declarations("short = 'b'")[0]) == "A"
    (root / "Demo/B.lean").write_text("import Demo.A\nnamespace Demo\ntheorem b : a = 2 - 1 := rfl\nend Demo\n")
    datastore.ingest_sources(mem, paths, root)
    row = mem.declarations("short = 'b'")[0]
    assert row["audit_status"] is None                       # statement changed: audit invalidated
    assert datastore.kernel_status(row) == "statement changed since lock"


def test_ingest_attempts_and_depgraph(tmp_path, mem):
    att = tmp_path / "a.jsonl"
    att.write_text("\n".join(json.dumps(x) for x in [
        {"ts": 1.0, "file": "F.lean", "theorem": "t", "model": "m", "accepted": False,
         "reason": "error", "proof": "simp", "first_error": "F.lean:3:2: unsolved goals 2"},
        {"ts": 2.0, "file": "F.lean", "theorem": "t", "model": "m", "accepted": True, "proof": "rfl"}]))
    assert datastore.ingest_prover_attempts(mem, att) == {"read": 2, "new": 2}
    assert datastore.ingest_prover_attempts(mem, att) == {"read": 2, "new": 0}   # idempotent
    assert mem.failures(decl="t")[0]["pattern"] == "unsolved goals N"
    dg = tmp_path / "dg.jsonl"
    dg.write_text('{"name":"X.t","type":["X.D"],"value":["X.l","X.t"]}\nnot json\n')
    assert datastore.ingest_depgraph(mem, dg) == 2
    assert mem.neighbours("X.D") == {"uses": [], "used_by": ["X.t"]}


# ---- rag ------------------------------------------------------------------------------------------
def test_tokens_split_identifiers():
    assert tokens("thetaShift_isODD") == ["theta", "shift", "is", "odd"]
    assert "e8" not in tokens("cartanE8_posDef") and "8" in tokens("cartanE8_posDef")


def test_bm25_ranking():
    idx = LexicalIndex({"a": "tadpole cancellation flux", "b": "moonshine mathieu", "c": "tadpole"})
    assert [k for k, _ in idx.search("tadpole flux")][0] == "a"
    assert idx.search("nothing here") == []


def test_retriever_expansion_embed_and_attempts(tmp_path, mem):
    files = {"Demo.lean": "import Demo.B\n",
             "Demo/B.lean": "/-- The tadpole cancels. -/\ntheorem tadpole_zero : 0 = 0 := rfl\n"
                            "theorem helper_lemma : 1 = 1 := rfl\ndef unrelated := 5\n"}
    root = make_repo(tmp_path, files)
    datastore.ingest_sources(mem, [root / f for f in files], root)
    mem.add_edges([("tadpole_zero", "helper_lemma", "value")])
    mem.record_attempt("Demo/B.lean", "tadpole_zero", "m", False, first_error="timeout", ts=1.0)
    mem.record_failure("prover", "timeout", decl="tadpole_zero")
    hits = Retriever(mem).search("tadpole", k=1, expand=2)
    assert hits[0]["name"] == "tadpole_zero" and hits[0]["kernel_status"] == "unlocked"
    assert hits[1]["name"] == "helper_lemma" and hits[1]["via"] == "dependency of tadpole_zero"
    calls = []

    def embed(texts):
        calls.append(len(texts))
        return [[1.0, 0.0] if "unrelated" in t or t == "number five" else [0.0, 1.0] for t in texts]

    dense_hits = Retriever(mem, embed=embed).search("number five", k=1, expand=0)
    assert dense_hits[0]["name"] == "unrelated" and calls
    pa = Retriever(mem).prior_attempts("Demo.tadpole_zero")
    assert pa["attempts"] == 1 and pa["failures"][0]["pattern"] == "timeout"


# ---- warm + cli -----------------------------------------------------------------------------------
def test_warm_files_and_closure(tmp_path):
    lib = tmp_path / ".lake/build/lib/lean"
    for mod, imps in {"P": ["P.Q"], "P.Q": ["P.R", "Ext.Missing"], "P.R": []}.items():
        rel = mod.replace(".", "/")
        (lib / (rel + ".olean")).parent.mkdir(parents=True, exist_ok=True)
        (lib / (rel + ".olean")).write_bytes(b"\0" * 5000)
        (tmp_path / (rel + ".lean")).parent.mkdir(parents=True, exist_ok=True)
        (tmp_path / (rel + ".lean")).write_text("".join(f"import {i}\n" for i in imps))
    (tmp_path / "lean-toolchain").write_text("none/none:v0\n")
    files, missing = warm.olean_closure(["P"], tmp_path)
    assert [f.name for f in files] == ["P.olean", "Q.olean", "R.olean"] and missing == ["Ext.Missing"]
    rep = warm.warm_files(files)
    assert rep["files"] == 3 and rep["bytes"] == 15000
    assert warm.warm_files(files, max_bytes=5000)["bytes"] == 5000
    assert len(warm.files_under(lib)) == 3
    (lib / "P.olean.private").write_bytes(b"\0" * 10)
    assert [f.name for f in warm.with_parts(files)] == ["P.olean", "P.olean.private", "Q.olean", "R.olean"]


def test_cli_smoke(tmp_path, capsys):
    home = str(tmp_path / "home")
    assert cli_main(["--home", home, "warm"]) == 2                       # no default target
    d = tmp_path / "d"
    d.mkdir()
    (d / "x.olean").write_bytes(b"1" * 1000)
    assert cli_main(["--home", home, "warm", "--path", str(d)]) == 0
    assert '"bytes": 1000' in capsys.readouterr().out
    assert cli_main(["--home", home, "plan", "--dry-run", "DualScaleCosmology"]) == 0
    out = capsys.readouterr().out
    assert "--dry-run: nothing was run." in out and "DualScaleCosmology.CKNBound" in out
    assert cli_main(["--home", home, "stats"]) == 0
