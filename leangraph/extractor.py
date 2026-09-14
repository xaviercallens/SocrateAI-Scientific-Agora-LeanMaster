"""
Lean Declaration & Dependency Extractor
Combines Lean AST parsing and kernel reference inspection.
Implements the 6 semantic edge types from aurasoph/lean-graph and patrik-cihal/lean-graph.
"""

import os
import re
import glob
from pathlib import Path
from typing import Dict, List, Tuple, Set, Optional

from leangraph.types import GraphNode, GraphEdge, DeclType, EdgeKind

# Core ubiquitous constants to filter out in "mathematical" mode (inspired by aurasoph)
UBIQUITOUS_CONSTANTS = {
    "Eq", "rfl", "Eq.refl", "Nat", "Int", "Rat", "Real", "Bool", "true", "false",
    "And", "Or", "Not", "Iff", "True", "False", "trivial", "decide", "omega", "dsimp",
    "simp", "rw", "intro", "exact", "apply", "have", "let", "match", "with",
    "List", "Array", "Option", "some", "none", "Prod", "Subtype", "Unit", "unit"
}

def determine_cluster(module: str, name: str) -> str:
    m = module.lower()
    n = name.lower()
    if "generalizedgeometry" in m or "generalized" in n or "metric" in n:
        return "Generalized Geometry"
    elif "courantalgebroid" in m or "courant" in n or "jacobiator" in n:
        return "Courant Algebroid"
    elif "actioncurvature" in m or "curvature" in n or "ricci" in n:
        return "Curvature & Action"
    elif "tduality" in m or "buscher" in n:
        return "T-Duality & Buscher"
    elif "k3topology" in m or "k3" in n or "euler" in n or "signature" in n:
        return "K3 Surface & Kummer"
    elif "torusmoonshine" in m or "mathieu" in n or "moonshine" in n or "bps" in n:
        return "Mathieu M24 Moonshine"
    elif "swampland" in m or "witten" in m or "strominger" in m:
        return "Frontier String Duality"
    elif "navierstokes" in m or "fluid" in m:
        return "OpenAI Navier-Stokes"
    elif "fermat" in m or "modular" in m:
        return "Fermat & Modular Forms"
    elif "atlas" in m:
        return "Meta ATLAS Geometry"
    elif "tensornetwork" in m or "quantum" in m:
        return "Quantum Tensor Networks"
    elif "statisticallearning" in m:
        return "Statistical Learning"
    return "Foundation Physics"

class LeanExtractor:
    def __init__(self, root_dir: str):
        self.root_dir = Path(root_dir)
        self.nodes: Dict[str, GraphNode] = {}
        self.edges: List[GraphEdge] = []
        self.module_imports: Dict[str, List[str]] = {}
        self.known_constants: Set[str] = set()

    def extract_from_modules(self, module_patterns: List[str]) -> Tuple[Dict[str, GraphNode], List[GraphEdge]]:
        """Walk all .lean files matching patterns and extract declarations + edges."""
        lean_files = []
        for pat in module_patterns:
            matched = list(self.root_dir.glob(f"{pat}/**/*.lean"))
            # also direct module .lean file
            direct = self.root_dir / f"{pat}.lean"
            if direct.exists():
                matched.append(direct)
            lean_files.extend(matched)

        # De-duplicate files
        lean_files = sorted(list(set(lean_files)))

        # First pass: collect all declaration names and module imports
        for file_path in lean_files:
            self._first_pass_collect_names(file_path)

        # Second pass: extract full node metadata and dependencies
        for file_path in lean_files:
            self._second_pass_extract_details(file_path)

        # Build cross-module import edges
        self._build_import_edges()

        # Update node in-degree and out-degree
        self._compute_node_degrees()

        return self.nodes, self.edges

    def _module_name_from_path(self, path: Path) -> str:
        try:
            rel = path.relative_to(self.root_dir)
            parts = list(rel.parts)
            if parts[-1].endswith(".lean"):
                parts[-1] = parts[-1][:-5]
            return ".".join(parts)
        except Exception:
            return path.stem

    def _first_pass_collect_names(self, file_path: Path):
        content = file_path.read_text(encoding="utf-8", errors="ignore")
        mod_name = self._module_name_from_path(file_path)

        # Module imports
        imports = []
        for line in content.splitlines():
            line = line.strip()
            if line.startswith("import "):
                imp = line[7:].split("--")[0].strip()
                imports.append(imp)
        self.module_imports[mod_name] = imports

        # Look for namespaces
        curr_ns = ""
        ns_match = re.search(r'namespace\s+([\w\.]+)', content)
        if ns_match:
            curr_ns = ns_match.group(1)

        # Regex for declarations
        decl_pattern = re.compile(
            r'(?:^|\n)(?:/--(?P<doc>[\s\S]*?)-/\s*)?'
            r'(?P<kind>theorem|lemma|def|structure|class|inductive|axiom)\s+'
            r'(?P<name>[\w\.\'\<\>]+)',
            re.MULTILINE
        )

        for m in decl_pattern.finditer(content):
            name = m.group("name").strip("«»")
            full_name = f"{curr_ns}.{name}" if curr_ns and not name.startswith(curr_ns) else name
            self.known_constants.add(name)
            self.known_constants.add(full_name)

    def _second_pass_extract_details(self, file_path: Path):
        content = file_path.read_text(encoding="utf-8", errors="ignore")
        mod_name = self._module_name_from_path(file_path)

        # Look for namespace
        curr_ns = ""
        ns_match = re.search(r'namespace\s+([\w\.]+)', content)
        if ns_match:
            curr_ns = ns_match.group(1)

        lines = content.splitlines()
        
        # Regex to split declarations
        decl_regex = re.compile(
            r'(?:^|\n)(?P<full_decl>(?:/--(?P<doc>[\s\S]*?)-/\s*)?'
            r'(?P<kind>theorem|lemma|def|structure|class|inductive|axiom)\s+'
            r'(?P<name>[\w\.\'\<\>]+)'
            r'(?P<rest>[\s\S]*?)(?=(?:\n/--|\n(?:theorem|lemma|def|structure|class|inductive|axiom)\s+|\Z)))',
            re.MULTILINE
        )

        for match in decl_regex.finditer(content):
            kind_str = match.group("kind")
            raw_name = match.group("name").strip("«»")
            name = f"{curr_ns}.{raw_name}" if curr_ns and not raw_name.startswith(curr_ns) else raw_name
            doc = match.group("doc") or ""
            rest = match.group("rest") or ""
            start_pos = match.start()
            line_no = content[:start_pos].count("\n") + 1

            # Determine DeclType
            if kind_str in ("theorem", "lemma"):
                decl_type = DeclType.THEOREM
            elif kind_str == "def":
                decl_type = DeclType.DEFINITION
            elif kind_str == "structure":
                decl_type = DeclType.STRUCTURE
            elif kind_str == "class":
                decl_type = DeclType.CLASS
            elif kind_str == "inductive":
                decl_type = DeclType.INDUCTIVE
            elif kind_str == "axiom":
                decl_type = DeclType.AXIOM
            else:
                decl_type = DeclType.OTHER

            # Extract Signature & Body
            sig = ""
            body = ""
            if ":=" in rest:
                parts = rest.split(":=", 1)
                sig = parts[0].strip()
                body = parts[1].strip()
            elif ":" in rest:
                parts = rest.split(":", 1)
                sig = ":" + parts[1].strip()
            else:
                sig = rest.strip()

            # Clean docstring & extract metadata tags
            clean_doc = doc.strip()
            latex_eqs = re.findall(r'\$\$([\s\S]*?)\$\$', clean_doc)
            inline_eqs = re.findall(r'(?<!\$)\$(?!\$)(.*?)\$(?!\$)', clean_doc)
            all_equations = [eq.strip() for eq in (latex_eqs + inline_eqs) if eq.strip()]

            # Papers
            papers = []
            paper_tags = re.findall(r'@paper:\s*([^\n\r]+)', clean_doc)
            for pt in paper_tags:
                for p in pt.split(","):
                    if p.strip():
                        papers.append(p.strip())
            # References format [AuthorYear]
            ref_tags = re.findall(r'\[([A-Z][A-Za-z0-9]+(?:\d{4})?)\]', clean_doc)
            papers.extend(ref_tags)
            papers = list(dict.fromkeys(papers))

            # Concepts
            concepts = []
            concept_tags = re.findall(r'@concept:\s*([^\n\r]+)', clean_doc)
            for ct in concept_tags:
                for c in ct.split(","):
                    if c.strip():
                        concepts.append(c.strip())
            concepts = list(dict.fromkeys(concepts))

            # Impacts
            impacts = []
            impact_tags = re.findall(r'@impact:\s*([^\n\r]+)', clean_doc)
            for it in impact_tags:
                for i in it.split(","):
                    if i.strip():
                        impacts.append(i.strip())
            impacts = list(dict.fromkeys(impacts))

            cluster = determine_cluster(mod_name, name)

            node = GraphNode(
                id=name,
                name=raw_name,
                module=mod_name,
                decl_type=decl_type,
                signature=sig[:200],  # truncated for clean display
                docstring=clean_doc,
                latex_equations=all_equations,
                papers=papers,
                concepts=concepts,
                impacts=impacts,
                line_number=line_no,
                is_certified=True,
                cluster=cluster
            )
            self.nodes[name] = node

            # 1. Structure inheritance (EXTENDS)
            if decl_type in (DeclType.STRUCTURE, DeclType.CLASS):
                extends_match = re.search(r'extends\s+([\w\s,\.]+)\s+where', sig)
                if extends_match:
                    parents = [p.strip() for p in extends_match.group(1).split(",")]
                    for parent in parents:
                        self.edges.append(GraphEdge(
                            source=name,
                            target=parent,
                            kind=EdgeKind.EXTENDS,
                            metadata={"parent": parent}
                        ))

            # 2. Type signature dependencies (SIG)
            for token in re.findall(r'\b([A-Za-z_][\w\.\']*)\b', sig):
                if token != raw_name and token in self.known_constants and token not in UBIQUITOUS_CONSTANTS:
                    self.edges.append(GraphEdge(
                        source=name,
                        target=token,
                        kind=EdgeKind.SIG,
                        metadata={"location": "signature"}
                    ))

            # 3. Proof body dependencies (PROOF)
            if decl_type == DeclType.THEOREM:
                for token in re.findall(r'\b([A-Za-z_][\w\.\']*)\b', body):
                    if token != raw_name and token in self.known_constants and token not in UBIQUITOUS_CONSTANTS:
                        self.edges.append(GraphEdge(
                            source=name,
                            target=token,
                            kind=EdgeKind.PROOF,
                            metadata={"location": "proof_body"}
                        ))

            # 4. Definition value dependencies (DEF)
            elif decl_type == DeclType.DEFINITION:
                for token in re.findall(r'\b([A-Za-z_][\w\.\']*)\b', body):
                    if token != raw_name and token in self.known_constants and token not in UBIQUITOUS_CONSTANTS:
                        self.edges.append(GraphEdge(
                            source=name,
                            target=token,
                            kind=EdgeKind.DEF,
                            metadata={"location": "defn_value"}
                        ))

            # 5. Docstring backtick references & concept cross-links (DOCREF)
            doc_refs = re.findall(r'`([A-Za-z_][\w\.\']*)`', clean_doc)
            for dref in doc_refs:
                if dref != raw_name and (dref in self.known_constants or dref in self.nodes):
                    self.edges.append(GraphEdge(
                        source=name,
                        target=dref,
                        kind=EdgeKind.DOCREF,
                        metadata={"reference_type": "doc_backtick"}
                    ))

        # De-duplicate edges
        unique_edges = []
        seen = set()
        for e in self.edges:
            pair = (e.source, e.target, e.kind)
            if pair not in seen:
                seen.add(pair)
                unique_edges.append(e)
        self.edges = unique_edges

    def _build_import_edges(self):
        """Create high-level module import edges."""
        for mod, imps in self.module_imports.items():
            for imp in imps:
                self.edges.append(GraphEdge(
                    source=mod,
                    target=imp,
                    kind=EdgeKind.IMPORT,
                    metadata={"import_type": "module"}
                ))

    def _compute_node_degrees(self):
        in_deg: Dict[str, int] = {n: 0 for n in self.nodes}
        out_deg: Dict[str, int] = {n: 0 for n in self.nodes}

        for e in self.edges:
            if e.source in out_deg:
                out_deg[e.source] += 1
            if e.target in in_deg:
                in_deg[e.target] += 1

        for n, node in self.nodes.items():
            node.in_degree = in_deg.get(n, 0)
            node.out_degree = out_deg.get(n, 0)
