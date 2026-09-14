#!/usr/bin/env python3
"""
prove2me_engine/tools/query_base.py
===================================
Cross-Corpus Base Search & Lemma Retrieval Engine for Prove2Me
Enables multi-agent proving workflows to search across:
- Meta AI ATLAS-Lean
- OpenAI Navier-Stokes & Euler
- Anthropic Fermat's Last Theorem & Modular Forms
- Xavier Callens Kummer Mukai Lattice
- Lean Community PhysLib
- Oxford TNLean & LeanQuantum
- Lean Stat Learning Theory
"""

import argparse
import json
import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT_DIR))

from leangraph.cache import LeanCacheManager
from leangraph.base_graph import PAPERS_METADATA

def query_foundations(query: str, repo_filter: str = None, top_k: int = 10):
    cm = LeanCacheManager(ROOT_DIR)
    results = cm.search(query, repository=repo_filter, limit=top_k)

    print("\n" + "=" * 75)
    print(f"🔎 BASELEAN4 SEARCH RESULTS for query: '{query}'")
    if repo_filter:
        print(f"   Filtered to repository: {repo_filter}")
    print("=" * 75)

    # Also search paper metadata
    matched_papers = []
    q_lower = query.lower()
    for p in PAPERS_METADATA:
        if (q_lower in p["title"].lower() or 
            q_lower in p["domain"].lower() or 
            q_lower in p["summary"].lower() or
            any(q_lower in a.lower() for a in p["authors"])):
            matched_papers.append(p)

    if matched_papers:
        print("\n📄 MATCHED FOUNDATIONAL PAPERS:")
        for p in matched_papers:
            print(f"  * [{p['id']}] {p['title']} ({p['year']})")
            print(f"    Authors: {', '.join(p['authors'])}")
            print(f"    Domain : {p['domain']}")
            print(f"    Summary: {p['summary'][:120]}...")
            print(f"    Bridge : {p['bridge_module']}\n")

    if results:
        print("📜 MATCHED CACHED FORMAL DECLARATIONS:")
        for r in results:
            print(f"  * [{r['decl_type'].upper()}] {r['name']} ({r['repository']})")
            print(f"    Module   : {r['module']}")
            if r['signature']:
                print(f"    Signature: {r['signature']}")
            if r['docstring']:
                print(f"    Docstring: {r['docstring'][:100]}...")
            print()
    else:
        if not matched_papers:
            print("  No matching declarations or papers found.")
    print("=" * 75 + "\n")

def main():
    parser = argparse.ArgumentParser(description="Query BaseLean4 Foundations and Papers")
    parser.add_argument("query", type=str, help="Search query (e.g. 'Sobolev', 'Kummer', 'Laplacian')")
    parser.add_argument("--repo", type=str, default=None, help="Filter by repository (e.g. 'repo:openai-navierstokes')")
    parser.add_argument("--top-k", type=int, default=10, help="Max results to return")
    args = parser.parse_args()

    query_foundations(args.query, args.repo, args.top_k)

if __name__ == "__main__":
    main()
