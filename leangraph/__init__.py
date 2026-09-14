"""
LeanGraph Package Initialization
Provides high-level programmatic interface for dependency extraction,
graph compilation, analysis, and multi-format exports.
"""

from pathlib import Path
from typing import List, Optional, Tuple, Dict

from leangraph.types import GraphNode, GraphEdge, GraphMetrics, EdgeKind, DeclType
from leangraph.extractor import LeanExtractor
from leangraph.algorithms import (
    compute_pagerank,
    compute_transitive_reduction,
    verify_dag_and_toposort,
    analyze_unused_and_redundant_imports
)
from leangraph.exporters import (
    export_json,
    export_ndjson,
    export_dot,
    export_gexf,
    export_prove2me_statements,
    export_interactive_html
)

def build_graph(
    root_dir: str,
    modules: Optional[List[str]] = None
) -> Tuple[Dict[str, GraphNode], List[GraphEdge], GraphMetrics]:
    """
    Extract declarations and dependencies across specified modules.
    Computes graph metrics, PageRank, topological order, and Hasse reduction.
    """
    if modules is None:
        modules = [
            "DoubleFieldTheory",
            "DualScaleM24Formalization",
            "StringTheoryFoundation"
        ]

    extractor = LeanExtractor(root_dir)
    nodes, edges = extractor.extract_from_modules(modules)

    # Compute PageRank
    compute_pagerank(nodes, edges)

    # Verify DAG on logical dependencies
    is_dag, topo_order, cycles = verify_dag_and_toposort(nodes, edges)

    # Compute Transitive Reduction (Hasse diagram)
    reduced_edges, redundant_count = compute_transitive_reduction(nodes, edges)

    # Analyze unused & redundant imports
    unused_imps, redundant_imps = analyze_unused_and_redundant_imports(
        extractor.module_imports, nodes, edges
    )

    # Compile metrics
    theorems = sum(1 for n in nodes.values() if n.decl_type == DeclType.THEOREM)
    defs = sum(1 for n in nodes.values() if n.decl_type == DeclType.DEFINITION)
    structs = sum(1 for n in nodes.values() if n.decl_type in (DeclType.STRUCTURE, DeclType.CLASS))
    
    edge_counts = {}
    for e in edges:
        edge_counts[e.kind.value] = edge_counts.get(e.kind.value, 0) + 1

    metrics = GraphMetrics(
        total_nodes=len(nodes),
        total_edges=len(edges),
        theorems_count=theorems,
        definitions_count=defs,
        structures_count=structs,
        modules_count=len(extractor.module_imports),
        edge_counts=edge_counts,
        is_dag=is_dag,
        cycles=cycles,
        redundant_transitive_edges=redundant_count,
        unused_imports=unused_imps
    )

    return nodes, edges, metrics

def export_all(
    nodes: Dict[str, GraphNode],
    edges: List[GraphEdge],
    metrics: GraphMetrics,
    output_dir: str
):
    """Export all artifact formats to the given output directory."""
    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)

    export_json(nodes, edges, metrics, out / "leangraph.json")
    export_ndjson(nodes, edges, out / "leangraph.ndjson")
    export_dot(nodes, edges, out / "leangraph.dot")
    export_gexf(nodes, edges, out / "leangraph.gexf")
    export_prove2me_statements(nodes, edges, out / "export_statements.jsonl")
    export_interactive_html(nodes, edges, metrics, out / "index.html")

__all__ = [
    "GraphNode", "GraphEdge", "GraphMetrics", "EdgeKind", "DeclType",
    "LeanExtractor", "build_graph", "export_all",
    "compute_pagerank", "compute_transitive_reduction",
    "verify_dag_and_toposort", "analyze_unused_and_redundant_imports"
]
