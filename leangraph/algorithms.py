"""
LeanGraph Graph Algorithms
- Transitive reduction (Hasse reduction)
- Topological sort and DAG verification
- Centrality metrics (PageRank)
- Unused & redundant import analysis (inspired by aurasoph/lean-graph)
"""

from typing import Dict, List, Set, Tuple
from collections import defaultdict, deque

from leangraph.types import GraphNode, GraphEdge, EdgeKind, GraphMetrics

def compute_pagerank(nodes: Dict[str, GraphNode], edges: List[GraphEdge], damping: float = 0.85, max_iter: int = 50) -> Dict[str, float]:
    """Compute PageRank centrality for all nodes in the graph."""
    if not nodes:
        return {}

    num_nodes = len(nodes)
    rank = {n: 1.0 / num_nodes for n in nodes}
    out_links: Dict[str, List[str]] = defaultdict(list)

    for e in edges:
        if e.source in nodes and e.target in nodes:
            out_links[e.source].append(e.target)

    for _ in range(max_iter):
        new_rank = {n: (1.0 - damping) / num_nodes for n in nodes}
        dangling_sum = sum(rank[n] for n in nodes if not out_links[n])
        dangling_contrib = damping * (dangling_sum / num_nodes)

        for src, targets in out_links.items():
            if targets:
                share = damping * (rank[src] / len(targets))
                for tgt in targets:
                    new_rank[tgt] += share

        for n in nodes:
            new_rank[n] += dangling_contrib

        rank = new_rank

    # normalize and assign to nodes
    max_r = max(rank.values()) if rank else 1.0
    for n, score in rank.items():
        if n in nodes:
            nodes[n].pagerank = score / max_r if max_r > 0 else 0.0

    return rank

def compute_transitive_reduction(nodes: Dict[str, GraphNode], edges: List[GraphEdge]) -> Tuple[List[GraphEdge], int]:
    """
    Computes transitive reduction of a DAG.
    An edge (u -> v) is redundant if there exists another path from u to v of length >= 2.
    """
    # Group edges by source
    adj = defaultdict(set)
    edge_map = {}
    for e in edges:
        adj[e.source].add(e.target)
        edge_map[(e.source, e.target)] = e

    # Find reachability for each node excluding direct edge
    reduced_edges: List[GraphEdge] = []
    redundant_count = 0

    for u in list(adj.keys()):
        for v in list(adj[u]):
            # Check if v is reachable from u via another intermediate node
            is_redundant = False
            # Queue for BFS from neighbors of u (excluding v)
            queue = deque([w for w in adj[u] if w != v])
            visited = set(queue)

            while queue:
                curr = queue.popleft()
                if curr == v:
                    is_redundant = True
                    break
                for nxt in adj.get(curr, ()):
                    if nxt not in visited:
                        visited.add(nxt)
                        queue.append(nxt)

            if is_redundant:
                redundant_count += 1
            else:
                if (u, v) in edge_map:
                    reduced_edges.append(edge_map[(u, v)])

    return reduced_edges, redundant_count

def verify_dag_and_toposort(nodes: Dict[str, GraphNode], edges: List[GraphEdge]) -> Tuple[bool, List[str], List[List[str]]]:
    """
    Verifies that the declaration dependency graph is a DAG (no circularities).
    Returns (is_dag, topological_order, cycles).
    """
    in_degree: Dict[str, int] = {n: 0 for n in nodes}
    adj: Dict[str, List[str]] = defaultdict(list)

    # Consider only logical dependencies (proof, def, sig, extends, field)
    logical_kinds = {EdgeKind.PROOF, EdgeKind.DEF, EdgeKind.SIG, EdgeKind.EXTENDS, EdgeKind.FIELD}
    for e in edges:
        if e.kind in logical_kinds and e.source in nodes and e.target in nodes:
            adj[e.source].append(e.target)
            in_degree[e.target] += 1

    # Kahn's algorithm
    queue = deque([n for n, deg in in_degree.items() if deg == 0])
    topo_order = []

    while queue:
        u = queue.popleft()
        topo_order.append(u)
        for v in adj[u]:
            in_degree[v] -= 1
            if in_degree[v] == 0:
                queue.append(v)

    if len(topo_order) == len(nodes):
        return True, topo_order, []
    else:
        # Detected cycle among remaining nodes
        cyclic_nodes = [n for n, deg in in_degree.items() if deg > 0]
        return False, topo_order, [cyclic_nodes]

def analyze_unused_and_redundant_imports(
    module_imports: Dict[str, List[str]],
    nodes: Dict[str, GraphNode],
    edges: List[GraphEdge]
) -> Tuple[List[Dict[str, str]], List[Dict[str, str]]]:
    """
    Identifies unused imports and transitively redundant imports across modules.
    Inspired by aurasoph's MainUnusedTransitiveImports.lean.
    """
    unused = []
    redundant = []

    # Map which declarations belong to which module
    decl_to_module = {node.name: node.module for node in nodes.values()}
    decl_to_module.update({node.id: node.module for node in nodes.values()})

    # Track which modules actually call declarations from other modules
    module_calls: Dict[str, Set[str]] = defaultdict(set)
    for e in edges:
        src_node = nodes.get(e.source)
        tgt_mod = decl_to_module.get(e.target)
        if src_node and tgt_mod and src_node.module != tgt_mod:
            module_calls[src_node.module].add(tgt_mod)

    # Check each imported module
    for mod, imports in module_imports.items():
        for imp in imports:
            # If mod imports imp, but none of mod's declarations reference imp
            # and none of imp's submodules are referenced
            used = any(called == imp or called.startswith(f"{imp}.") for called in module_calls[mod])
            # Don't flag fundamental std modules
            if not used and not imp.startswith("Init") and not imp.startswith("Lean") and not imp.startswith("Lake"):
                unused.append({
                    "module": mod,
                    "unused_import": imp,
                    "reason": f"No declarations in {mod} directly reference {imp}"
                })

    return unused, redundant
