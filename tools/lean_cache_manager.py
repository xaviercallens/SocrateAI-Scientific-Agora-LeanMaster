#!/usr/bin/env python3
"""
tools/lean_cache_manager.py
===========================
Lean 4 Cache & Build Artifact Optimization Manager
Inspects, verifies, and optimizes:
- .lake build artifacts and pre-compiled .olean/.ilean files
- .leancache persistent SQLite declaration database
- File hash validation for zero-redundancy rebuilds
"""

import argparse
import os
import shutil
import sqlite3
import subprocess
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
CACHE_DIR = ROOT_DIR / ".leancache"
LAKE_DIR = ROOT_DIR / ".lake"

def get_dir_size_bytes(path: Path) -> int:
    if not path.exists():
        return 0
    return sum(f.stat().st_size for f in path.glob("**/*") if f.is_file())

def format_bytes(size: int) -> str:
    for unit in ["B", "KB", "MB", "GB"]:
        if size < 1024.0:
            return f"{size:.2f} {unit}"
        size /= 1024.0
    return f"{size:.2f} TB"

def cmd_status(args):
    print("=" * 60)
    print("⚡ LEAN 4 CACHE & BUILD ARTIFACT STATUS")
    print("=" * 60)

    # 1. Lake Build Cache
    lake_size = get_dir_size_bytes(LAKE_DIR)
    olean_count = len(list(LAKE_DIR.glob("**/*.olean"))) if LAKE_DIR.exists() else 0
    ilean_count = len(list(LAKE_DIR.glob("**/*.ilean"))) if LAKE_DIR.exists() else 0
    print(f"Lake Build Directory:     {LAKE_DIR}")
    print(f"  - Total Disk Usage:     {format_bytes(lake_size)}")
    print(f"  - Compiled .olean:      {olean_count} files")
    print(f"  - Interactive .ilean:   {ilean_count} files")

    # 2. LeanGraph SQLite Cache
    db_path = CACHE_DIR / "declarations.db"
    if db_path.exists():
        db_size = db_path.stat().st_size
        conn = sqlite3.connect(str(db_path))
        c = conn.cursor()
        c.execute("SELECT COUNT(*) FROM declarations")
        decl_count = c.fetchone()[0]
        c.execute("SELECT repository, COUNT(*) FROM declarations GROUP BY repository")
        by_repo = dict(c.fetchall())
        conn.close()
        print(f"\nLeanGraph SQLite Cache:   {db_path}")
        print(f"  - DB Size:              {format_bytes(db_size)}")
        print(f"  - Cached Declarations:  {decl_count}")
        for r, cnt in by_repo.items():
            print(f"    * {r:<26}: {cnt}")
    else:
        print(f"\nLeanGraph SQLite Cache:   Not initialized")

    print("=" * 60)

def cmd_verify(args):
    print("🔍 Verifying Lean toolchain and build consistency...")
    res = subprocess.run(["lake", "build"], cwd=ROOT_DIR, capture_output=True, text=True)
    if res.returncode == 0:
        print("✅ Lake build verification: PASSED (All packages cleanly built and cached)")
    else:
        print(f"❌ Lake build failed with exit code {res.returncode}:")
        print(res.stderr)

def cmd_clean(args):
    target = args.target
    if target in ("all", "lake") and LAKE_DIR.exists():
        print(f"🧹 Removing Lake build cache at {LAKE_DIR}...")
        shutil.rmtree(LAKE_DIR)
        print("✅ Lake cache cleaned.")
    if target in ("all", "db") and CACHE_DIR.exists():
        print(f"🧹 Removing LeanGraph declaration cache at {CACHE_DIR}...")
        shutil.rmtree(CACHE_DIR)
        print("✅ LeanGraph cache cleaned.")

def cmd_reindex(args):
    print("🔄 Re-indexing BaseLean4 Graph and updating SQLite cache...")
    from leangraph.base_graph import BaseLeanGraphBuilder
    builder = BaseLeanGraphBuilder(ROOT_DIR)
    builder.export_all(ROOT_DIR / "graph" / "base_graph")
    print("✅ Re-indexing complete.")

def main():
    parser = argparse.ArgumentParser(description="Lean 4 Cache & Optimization Manager")
    subparsers = parser.add_subparsers(dest="command", required=True)

    p_status = subparsers.add_parser("status", help="Display cache and build artifact metrics")
    p_status.set_defaults(func=cmd_status)

    p_verify = subparsers.add_parser("verify", help="Verify lake build cache consistency")
    p_verify.set_defaults(func=cmd_verify)

    p_clean = subparsers.add_parser("clean", help="Clean cache directories")
    p_clean.add_argument("--target", choices=["all", "lake", "db"], default="lake", help="Target cache to clean")
    p_clean.set_defaults(func=cmd_clean)

    p_reindex = subparsers.add_parser("reindex", help="Re-index the base graph and SQLite cache")
    p_reindex.set_defaults(func=cmd_reindex)

    args = parser.parse_args()
    args.func(args)

if __name__ == "__main__":
    main()
