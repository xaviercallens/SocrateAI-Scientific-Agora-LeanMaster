"""
LeanGraph Core Types & Data Models
Inspired by aurasoph/lean-graph and patrik-cihal/lean-graph.
Defines semantic node types, 6 distinct edge kinds, and graph metrics.
"""

from dataclasses import dataclass, field
from enum import Enum
from typing import List, Dict, Any, Optional, Set

class DeclType(str, Enum):
    THEOREM = "theorem"
    DEFINITION = "def"
    AXIOM = "axiom"
    STRUCTURE = "structure"
    CLASS = "class"
    INDUCTIVE = "inductive"
    INSTANCE = "instance"
    MODULE = "module"
    OTHER = "other"

class EdgeKind(str, Enum):
    PROOF = "proof"       # Proof invocations (theorems used in proof term)
    DEF = "def"           # Definition invocations (constants used in value)
    SIG = "sig"           # Type signature dependencies
    EXTENDS = "extends"   # Structure inheritance (parentInfo)
    FIELD = "field"       # Structure field type dependency
    DOCREF = "docref"     # Docstring citations, @paper, @concept references
    IMPORT = "import"     # Module import dependency

@dataclass
class GraphNode:
    id: str
    name: str
    module: str
    decl_type: DeclType
    signature: str = ""
    docstring: str = ""
    latex_equations: List[str] = field(default_factory=list)
    papers: List[str] = field(default_factory=list)
    concepts: List[str] = field(default_factory=list)
    impacts: List[str] = field(default_factory=list)
    in_degree: int = 0
    out_degree: int = 0
    pagerank: float = 0.0
    line_number: int = 0
    is_certified: bool = True
    cluster: str = "General"

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "name": self.name,
            "module": self.module,
            "decl_type": self.decl_type.value,
            "signature": self.signature,
            "docstring": self.docstring,
            "latex_equations": self.latex_equations,
            "papers": self.papers,
            "concepts": self.concepts,
            "impacts": self.impacts,
            "in_degree": self.in_degree,
            "out_degree": self.out_degree,
            "pagerank": round(self.pagerank, 5),
            "line_number": self.line_number,
            "is_certified": self.is_certified,
            "cluster": self.cluster
        }

@dataclass
class GraphEdge:
    source: str
    target: str
    kind: EdgeKind
    metadata: Dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "source": self.source,
            "target": self.target,
            "kind": self.kind.value,
            "metadata": self.metadata
        }

@dataclass
class GraphMetrics:
    total_nodes: int = 0
    total_edges: int = 0
    theorems_count: int = 0
    definitions_count: int = 0
    structures_count: int = 0
    modules_count: int = 0
    edge_counts: Dict[str, int] = field(default_factory=dict)
    is_dag: bool = True
    cycles: List[List[str]] = field(default_factory=list)
    redundant_transitive_edges: int = 0
    unused_imports: List[Dict[str, str]] = field(default_factory=list)
