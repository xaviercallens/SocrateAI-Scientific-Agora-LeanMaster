"""
LeanGraph CLI - Dependency Extraction, Knowledge Graph & Prove2Me Tool
"""

import argparse
import sys
from pathlib import Path

from leangraph import build_graph, export_all

def main():
    parser = argparse.ArgumentParser(
        description="LeanGraph - Advanced Dependency Graph & Knowledge Discovery for Lean 4"
    )
    parser.add_argument(
        "--root", type=str, default=".",
        help="Root directory of the Lean 4 project (default: current directory)"
    )
    parser.add_argument(
        "--target", type=str, nargs="+", default=None,
        help="Target modules to analyze (e.g. DoubleFieldTheory DualScaleM24Formalization StringTheoryFoundation)"
    )
    parser.add_argument(
        "--out", type=str, default="graph",
        help="Output directory for generated graph artifacts (default: graph/)"
    )
    parser.add_argument(
        "--check-dag", action="store_true",
        help="Strictly verify that the logical dependency graph is a DAG"
    )

    args = parser.parse_args()

    print(f"🕸️ Running LeanGraph analysis on {args.root}...")
    if args.target:
        print(f"🎯 Target modules: {', '.join(args.target)}")
    else:
        print("🎯 Analyzing all certified string theory packages")

    nodes, edges, metrics = build_graph(args.root, args.target)

    print("\n" + "="*60)
    print("📊 LEANGRAPH SUMMARY")
    print("="*60)
    print(f"Total Declarations (Nodes): {metrics.total_nodes}")
    print(f"  - Theorems / Lemmas:     {metrics.theorems_count}")
    print(f"  - Definitions:           {metrics.definitions_count}")
    print(f"  - Structures / Classes:  {metrics.structures_count}")
    print(f"Total Dependencies (Edges):{metrics.total_edges}")
    for k, v in metrics.edge_counts.items():
        print(f"  - [{k.upper()}]: {v}")
    print(f"Is Logical DAG:            {metrics.is_dag}")
    print(f"Hasse Redundant Edges:     {metrics.redundant_transitive_edges}")
    if metrics.unused_imports:
        print(f"Unused Imports Detected:   {len(metrics.unused_imports)}")
        for u in metrics.unused_imports[:5]:
            print(f"  ⚠️ {u['module']} -> {u['unused_import']}")
    else:
        print("Unused Imports:            0 (Clean import hygiene)")
    print("="*60)

    if args.check_dag and not metrics.is_dag:
        print(f"❌ ERROR: Cycles detected in logical proof dependencies: {metrics.cycles}")
        sys.exit(1)

    print(f"\n📦 Exporting artifacts to {args.out}/...")
    export_all(nodes, edges, metrics, args.out)
    print(f"  ✅ {args.out}/leangraph.json (Unified schema)")
    print(f"  ✅ {args.out}/leangraph.ndjson (aurasoph streaming format)")
    print(f"  ✅ {args.out}/leangraph.dot (Graphviz)")
    print(f"  ✅ {args.out}/leangraph.gexf (Gephi)")
    print(f"  ✅ {args.out}/export_statements.jsonl (Prove2Me DAG format)")
    print(f"  ✅ {args.out}/index.html (Interactive Web Explorer)")
    print("✨ LeanGraph generation complete!\n")

if __name__ == "__main__":
    main()
