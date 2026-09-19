"""
tests/test_mcp_server.py — tests for leanstack/mcp_server.py. No Lean is compiled: `check_lean_snippet` runs
with a mocked runner, and the stdio smoke test only lists tools and reads the recorded status.

    /mnt/disks/disk-socrateai-local-1/leanmaster/mcp-venv/bin/python -m pytest tests/test_mcp_server.py -q

(the `mcp` package lives in that venv; the tool functions themselves need only the standard library).
"""

import json
import os
import sqlite3
import sys
import textwrap
import threading
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO))

from leanstack import datastore, scheduler  # noqa: E402
from leanstack import mcp_server as srv  # noqa: E402
from leanstack.memory import LeanMemory, default_root  # noqa: E402

LAKEFILE = """import Lake
open Lake DSL

package «demo» where
  leanOptions := #[
    ⟨`maxHeartbeats, (1000000 : Nat)⟩,
    ⟨`maxRecDepth, (8000 : Nat)⟩
  ]

lean_lib «Demo» where
  roots := #[`Demo]
"""

DEMO_B = textwrap.dedent('''\
    import Demo.A
    namespace Demo
    /-- An earlier declaration's docstring that mentions Tier C and papers/foundations/other.txt l. 1. -/
    def helper : Nat := 0
    /-- The tadpole cancels (Tier A); see `papers/foundations/hep-th_0301139.txt`, ll. 160–163. -/
    theorem tadpole_zero : a = 1 := rfl
    theorem uses_tadpole : a = 1 := tadpole_zero
    end Demo
    ''')


def make_repo(tmp: Path) -> Path:
    tmp.mkdir(parents=True, exist_ok=True)
    (tmp / "lakefile.lean").write_text(LAKEFILE)
    (tmp / "lean-toolchain").write_text("leanprover/lean4:v4.33.1\n")
    (tmp / "lake-manifest.json").write_text(json.dumps({"packages": [{"name": "mathlib", "rev": "abc"}]}))
    (tmp / "Demo").mkdir()
    (tmp / "Demo.lean").write_text("import Demo.B\nimport Demo.C\n")
    (tmp / "Demo/A.lean").write_text("def a : Nat := 1\n")
    (tmp / "Demo/B.lean").write_text(DEMO_B)
    (tmp / "Demo/C.lean").write_text("import Demo.A\nnamespace Other\ntheorem tadpole_zero : 2 = 2 := rfl\nend Other\n")
    return tmp


@pytest.fixture
def demo(tmp_path, monkeypatch):
    """A temporary Lake repo + a LeanMemory seeded by leanstack's own ingest (sources, lock, audit, edges)."""
    root = make_repo(tmp_path / "repo")
    home = tmp_path / "home"
    files = [root / f for f in ("Demo.lean", "Demo/A.lean", "Demo/B.lean", "Demo/C.lean")]
    with LeanMemory(home) as mem:
        datastore.ingest_sources(mem, files, root)
        rows = {r["name"]: r for r in mem.declarations()}
        lock = root / "docs" / "statement_lock.json"
        lock.parent.mkdir()
        lock.write_text(json.dumps({"Demo/B.lean": {"tadpole_zero": rows["Demo.tadpole_zero"]["statement_hash"],
                                                    "uses_tadpole": rows["Demo.uses_tadpole"]["statement_hash"]}}))
        datastore.ingest_statement_lock(mem, lock)
        datastore.ingest_axiom_audit(mem, "OK      Demo.tadpole_zero  []\n"
                                          "FAIL    Demo.uses_tadpole  ['sorryAx']\n")
        mem.add_edges([("Demo.uses_tadpole", "Demo.tadpole_zero", "value"), ("Demo.tadpole_zero", "Eq", "type")])
    monkeypatch.setattr(srv, "ROOT", root)
    monkeypatch.setattr(srv, "LOCK_JSON", lock)
    srv._SRC_CACHE.clear()
    srv._LOCK_CACHE.clear()
    srv._LEX_CACHE.clear()
    return root, str(home)


# ---- search / get_declaration on a seeded store -------------------------------------------------
def test_search_kernel_status_docstring_pins(demo):
    root, home = demo
    r = srv.search_theorems("tadpole cancels", k=2, home=home)
    top = r["hits"][0]
    assert top["name"] == "Demo.tadpole_zero" and top["location"] == "Demo/B.lean:6"
    assert top["kernel_status"] == "A"                         # locked, unchanged, audit OK
    # own docstring only (the stored one also swallowed `helper`'s docstring: source.DOCSTRING_BEFORE)
    assert top["docstring"].startswith("The tadpole cancels") and "earlier" not in top["docstring"]
    assert top["tier_mentions"] == ["A"]
    assert top["pins"] == [{"file": "hep-th_0301139.txt", "lines": [160, 163]}]
    by_name = {h["name"]: h for h in r["hits"]}
    assert by_name["Demo.uses_tadpole"]["kernel_status"] == "audit FAIL"
    assert "audit_note" not in r                               # the store has audits


def test_get_declaration_full_record_and_edges(demo):
    _, home = demo
    rec = srv.get_declaration("Demo.tadpole_zero", home=home)["records"][0]
    assert rec["locked_and_unchanged"] and rec["statement_hash_current"] == rec["statement_hash_locked"]
    assert rec["axioms_last_ingested_audit"] == [] and rec["audit_status"] == "OK"
    assert rec["dependents"]["in_proof"]["project"] == ["Demo.uses_tadpole"]
    assert rec["depends_on"]["in_statement"] == {"project": [], "n_project": 0, "n_other": 1, "other_sample": ["Eq"]}
    amb = srv.get_declaration("tadpole_zero", home=home)            # short name, two files
    assert "ambiguous" in amb["error"] and len(amb["candidates"]) == 2
    assert "error" in srv.get_declaration("Demo.nope", home=home)


def test_live_statement_change_is_not_tier_a(demo):
    """Edit a statement after ingest (no re-ingest): the live hash differs from the lock, the stored audit is ignored."""
    root, home = demo
    (root / "Demo/B.lean").write_text(DEMO_B.replace("theorem tadpole_zero : a = 1", "theorem tadpole_zero : a = 2 - 1"))
    srv._SRC_CACHE.clear()
    rec = srv.get_declaration("Demo.tadpole_zero", home=home)["records"][0]
    assert rec["kernel_status"] == "statement changed since lock"
    assert not rec["locked_and_unchanged"] and rec["audit_status"] == "not ingested"
    assert any("changed since the last ingest" in n for n in rec["notes"])


def test_no_audit_note_when_store_has_no_audit(tmp_path, monkeypatch):
    root = make_repo(tmp_path / "repo")
    with LeanMemory(tmp_path / "home") as mem:
        datastore.ingest_sources(mem, [root / "Demo/B.lean"], root)
    monkeypatch.setattr(srv, "ROOT", root)
    monkeypatch.setattr(srv, "LOCK_JSON", root / "missing.json")
    srv._SRC_CACHE.clear()
    r = srv.search_theorems("tadpole", home=str(tmp_path / "home"))
    assert r["hits"][0]["kernel_status"] == "unlocked" and "not ingested" in r["audit_note"]


@pytest.fixture(scope="module")
def real_store_copy(tmp_path_factory):
    """A consistent copy (SQLite backup API, WAL-safe) of the ingested LeanMemory; skipped if absent."""
    src = default_root() / "memory.db"
    if not src.exists():
        pytest.skip("no ingested LeanMemory on this machine")
    home = tmp_path_factory.mktemp("realstore")
    s = sqlite3.connect(f"file:{src}?mode=ro", uri=True)
    d = sqlite3.connect(str(home / "memory.db"))
    s.backup(d)
    s.close()
    d.close()
    return str(home)


def test_search_real_store_copy(real_store_copy):
    r = srv.search_theorems("K3 Euler characteristic 24", k=5, home=real_store_copy)
    names = [h["name"] for h in r["hits"]]
    assert "DoubleFieldTheory.K3Topology.k3_euler_characteristic" in names
    for h in r["hits"]:
        assert h["kernel_status"] and ":" in h["location"]
    rec = srv.get_declaration("DualScaleStream2.Lattice.Signature.add_pos", home=real_store_copy)["records"][0]
    assert rec["statement"].startswith("@[simp] theorem add_pos") and "structure Signature" not in rec["docstring"]


# ---- status, impact, lock, guide ----------------------------------------------------------------------
def test_parse_audit_table_and_verified_status(real_store_copy):
    t = srv.parse_audit_table("x\nLast full run (2026-01-02), **3 theorems**:\n\n| Library | Theorems audited | Failing |\n"
                              "|---|:---:|:---:|\n| `A` (note) | 1 | 0 |\n| `B` | 2 | 0 |\n| **Total** | **3** | **0** |\n\nafter\n")
    assert t["libraries"] == {"A": {"audited": 1, "failing": 0}, "B": {"audited": 2, "failing": 0}}
    assert t["total"] == {"audited": 3, "failing": 0} and t["date"] == "2026-01-02"
    v = srv.verified_status(home=real_store_copy)
    assert "NOT re-run" in v["label"]
    table = v["audit_table"]
    assert table["total"]["audited"] == sum(x["audited"] for x in table["libraries"].values())
    assert len(table["libraries"]) >= 10
    assert v["verified_foundation"]["last_total_audited"]["value"] > 0
    assert v["axioms_allowed"] == ["Classical.choice", "Quot.sound", "propext"]
    assert v["leanstack_store"]["declarations"] > 1000


def test_impact_real_repo():
    r = srv.impact("DualScaleDyons.KummerD4")
    assert "DualScaleDyons.KummerD4" in r["impacted"] and "DualScaleDyons" in r["impacted"]
    assert "error" in srv.impact("Not.A.Module")


def test_check_statement_lock_real_and_path_guard(tmp_path):
    r = srv.check_statement_lock(["DualScaleDyons/KummerD4.lean"])
    assert r["exit_code"] in (0, 1) and r["files_checked"] == 1 and r["last_line"].startswith("statement lock")
    outside = tmp_path / "x.lean"
    outside.write_text("theorem t : True := trivial\n")
    for bad in ["--update", "../../etc/passwd.lean", str(outside), "README.md", "Nope/Missing.lean"]:
        assert "error" in srv.check_statement_lock([bad]), bad


def test_usage_guide_tier_rules():
    g = srv.usage_guide()
    for s in ("Tier", "propext", "Classical.choice", "Quot.sound", "never write 'zero axioms'", "consumer_demo"):
        assert s in g


# ---- check_lean_snippet (mocked runner: nothing is compiled) ---------------------------------------
def test_snippet_screening():
    ok = "theorem t (n : Nat) : n + 0 = n := by simp\n@[simp] lemma u : 1 = 1 := rfl\n-- #eval in a comment is fine\n"
    assert srv.screen_snippet(ok, ["DualScaleDyons"]) == []
    for bad in ["#eval 1", "run_cmd pure ()", "import Mathlib\ntheorem t : True := trivial",
                "elab \"x\" : term => pure default", "def f : IO Unit := pure ()", "unsafe def g := 1",
                "@[implemented_by g] def h := 1", "attribute [command_elab x] y", "initialize foo : Nat ← pure 1",
                "def p := System.FilePath.mk \"/\"", "def q := liftIO"]:
        assert srv.screen_snippet(bad, ["DualScaleDyons"]), bad
    assert srv.screen_snippet("theorem t : True := trivial", ["../../etc"])
    assert srv.screen_snippet("theorem t : True := trivial", [])
    assert srv.check_lean_snippet("#eval 1", runner=lambda *a, **k: 1 / 0)["status"] == "refused"
    assert srv.check_lean_snippet("theorem t : True := trivial", imports=["Evil"],
                                  runner=lambda *a, **k: 1 / 0)["status"] == "refused"


def test_snippet_mock_runner_cache_and_messages(tmp_path):
    home, scratch, calls = str(tmp_path / "home"), tmp_path / "scratch", []

    def fake_runner(cmd, cwd, budget_kb, **kw):
        calls.append((cmd, cwd, budget_kb, kw))
        f = cmd[-1]
        assert Path(f).read_text().startswith("import DualScaleDyons\n\n")
        out = (f"{f}:3:8: warning: declaration uses 'sorry'\n"
               f"{f}:4:30: error: unsolved goals\n⊢ 1 = 2\n")
        return scheduler.RunResult("error", 1, 0.5, 1000, 500, out)

    code = "theorem s : 1 = 1 := by\n  sorry\ntheorem t : 1 = 1 := by native_decide\ntheorem u : 1 = 2 := by simp\n"
    r = srv.check_lean_snippet(code, home=home, runner=fake_runner, scratch=scratch, memory_gb=6, timeout_s=99)
    (cmd, cwd, budget_kb, kw), = calls
    assert cmd[:3] == ["lake", "env", "lean"]
    assert cmd[3:5] == ["-DmaxHeartbeats=1000000", "-DmaxRecDepth=8000"] and len(cmd) == 6
    assert Path(cmd[5]).parent == scratch and Path(cmd[5]).name.startswith("snippet_")
    assert cwd == srv.ROOT and budget_kb == 6 * scheduler.GB and kw["timeout_s"] == 99
    assert r["status"] == "error" and not r["compiled_ok"] and not r["cached"]
    assert r["forbidden_tokens"] == {"sorry": True, "admit": False, "native_decide": True, "axiom": False}
    assert r["uses_sorry_warning"]
    err = [m for m in r["messages"] if m["severity"] == "error"][0]
    assert err["line"] == 2 and "⊢ 1 = 2" in err["message"]         # snippet-relative line (2 header lines)
    assert "NOT a gate pass" in r["not_a_gate_pass"]
    again = srv.check_lean_snippet(code, home=home, runner=fake_runner, scratch=scratch)
    assert again["cached"] and len(calls) == 1 and again["messages"] == r["messages"]
    # killed runs are not served from the cache
    kill = lambda *a, **k: scheduler.RunResult("killed_budget", -9, 1.0, 9, 9, "", "RssAnon > budget")  # noqa: E731
    k1 = srv.check_lean_snippet(code + "\n", home=home, runner=kill, scratch=scratch)
    assert k1["status"] == "killed_budget" and k1["note"]
    calls.clear()
    srv.check_lean_snippet(code + "\n", home=home, runner=fake_runner, scratch=scratch)
    assert len(calls) == 1
    # an import failure (stale .olean) is reported as infra_error and never cached
    stale = lambda cmd, *a, **k: scheduler.RunResult(  # noqa: E731
        "error", 1, 0.1, 1, 1, f"{cmd[-1]}:1:0: error: object file .../DualScaleDyons.olean does not exist\n")
    code2 = "theorem v : 3 = 3 := rfl\n"
    assert srv.check_lean_snippet(code2, home=home, runner=stale, scratch=scratch)["status"] == "infra_error"
    calls.clear()
    srv.check_lean_snippet(code2, home=home, runner=fake_runner, scratch=scratch)
    assert len(calls) == 1


def test_snippet_lock_serialises(tmp_path):
    scratch = tmp_path / "scratch"
    held, release = threading.Event(), threading.Event()

    def holder():
        with srv.compile_lock(scratch / ".compile.lock", 5) as got:
            assert got
            held.set()
            release.wait(10)

    t = threading.Thread(target=holder)
    t.start()
    held.wait(5)
    try:
        r = srv.check_lean_snippet("theorem t : True := trivial", home=str(tmp_path / "home"), scratch=scratch,
                                   runner=lambda *a, **k: 1 / 0, lock_wait_s=0)
        assert r["status"] == "busy"
    finally:
        release.set()
        t.join()


# ---- the MCP layer over stdio ---------------------------------------------------------------------
EXPECTED_TOOLS = {"search_theorems", "get_declaration", "verified_status", "impact", "check_statement_lock",
                  "usage_guide", "check_lean_snippet"}


def test_stdio_smoke():
    mcp = pytest.importorskip("mcp")
    import anyio
    from mcp import ClientSession, StdioServerParameters
    from mcp.client.stdio import stdio_client

    launcher = REPO / "tools" / "leanmaster_mcp.sh"
    env = {**os.environ, "LEANMASTER_MCP_PYTHON": sys.executable}
    params = StdioServerParameters(command=str(launcher), args=[], env=env, cwd=str(REPO))

    async def run():
        with anyio.fail_after(90):
            async with stdio_client(params) as (read, write):
                async with ClientSession(read, write) as session:
                    init = await session.initialize()
                    assert init.serverInfo.name == "leanmaster"
                    tools = {t.name: t for t in (await session.list_tools()).tools}
                    assert set(tools) == EXPECTED_TOOLS
                    assert tools["search_theorems"].annotations.readOnlyHint
                    assert not tools["check_lean_snippet"].annotations.readOnlyHint
                    uris = {str(r.uri) for r in (await session.list_resources()).resources}
                    assert {"leanmaster://verified-foundation", "leanmaster://lessons"} <= uris
                    for uri, marker in (("leanmaster://verified-foundation", "Verified foundation"),
                                        ("leanmaster://lessons", "Lesson")):
                        body = (await session.read_resource(uri)).contents[0].text
                        assert marker in body, uri
                    res = await session.call_tool("impact", {"module": "DualScaleDyons.KummerD4"})
                    assert not res.isError and "DualScaleDyons.KummerOmegaE4" in res.content[0].text

    anyio.run(run)
    assert mcp
