"""
BaseLean4 Graph Builder & Knowledge Discovery Engine
Extracts, structures, and links the massive Lean 4 foundational corpora and papers:
- Meta AI ATLAS-Lean (AutoformBot, 2,653 papers)
- OpenAI Navier-Stokes & Euler (continuous Sobolev analysis on torus)
- Anthropic Fermat's Last Theorem & Modular Forms
- Xavier Callens Kummer Blowup Divisors & Mukai Lattice
- Lean Community PhysLib (spacetime kinematics)
- Oxford TNLean & inQWIRE Quantum
- Lean Stat Learning Theory
- Foundational Physics Papers (Witten 1995, Vafa 2005, Strominger SYZ 1996)
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Any, Optional

from leangraph.cache import LeanCacheManager
from leangraph.types import DeclType, EdgeKind

PAPERS_METADATA = [
    {
        "id": "Witten1995",
        "title": "String Theory Dynamics In Various Dimensions",
        "authors": ["Edward Witten"],
        "year": 1995,
        "citation": "Nucl. Phys. B 443 (1995) 85-126",
        "arxiv": "hep-th/9503124",
        "file": "papers/witten_string_dynamics_hep-th_9503124.pdf",
        "domain": "Frontier String Duality",
        "summary": "Established S-duality, T-duality, U-duality, and strong-weak coupling dualities connecting all five superstring theories and 11D M-theory, with compactifications on K3 and tori.",
        "bridge_module": "StringTheoryFoundation.StringTheory.WittenDuality"
    },
    {
        "id": "Vafa2005",
        "title": "The String Landscape and the Swampland",
        "authors": ["Cumrun Vafa"],
        "year": 2005,
        "citation": "hep-th/0509212",
        "arxiv": "hep-th/0509212",
        "file": "papers/vafa_swampland_hep-th_0509212.pdf",
        "domain": "Swampland Criteria",
        "summary": "Formulated the Swampland program delineating consistent effective field theories with quantum gravity completion from the surrounding landscape.",
        "bridge_module": "StringTheoryFoundation.StringTheory.VafaSwampland"
    },
    {
        "id": "StromingerSYZ1996",
        "title": "Mirror Symmetry is T-Duality",
        "authors": ["Andrew Strominger", "Shing-Tung Yau", "Eric Zaslow"],
        "year": 1996,
        "citation": "Nucl. Phys. B 479 (1996) 243-259",
        "arxiv": "hep-th/9606040",
        "file": "papers/strominger_syz_hep-th_9606040.pdf",
        "domain": "Mirror Symmetry & SYZ",
        "summary": "Demonstrated that mirror symmetry between Calabi-Yau 3-folds is geometric fiberwise T-duality along dual special Lagrangian 3-tori fibrations.",
        "bridge_module": "StringTheoryFoundation.StringTheory.StromingerSYZ"
    },
    {
        "id": "MetaATLAS2025",
        "title": "Formalizing Mathematics at Scale with AutoformBot",
        "authors": ["Meta AI Research Team"],
        "year": 2025,
        "citation": "Meta AI Research Preprint",
        "arxiv": "2501.xxxxx",
        "file": "lean4basesource/atlas-lean/v1/formalizing_mathematics_at_scale.pdf",
        "domain": "Meta ATLAS Differential Geometry",
        "summary": "Automated formalization of 2,653 mathematics papers into 46,000+ Lean 4 declarations across differential geometry, 4-manifolds, topology, and PDEs.",
        "bridge_module": "StringTheoryFoundation.Atlas.AtlasGeometryBridge"
    },
    {
        "id": "OpenAINavierStokes2025",
        "title": "Navier-Stokes and Euler Equations on the Torus in Lean 4",
        "authors": ["OpenAI Research Team"],
        "year": 2025,
        "citation": "OpenAI Technical Report",
        "arxiv": "2502.xxxxx",
        "file": "lean4basesource/openai-navierstokes",
        "domain": "Continuous Torus Fluid Dynamics",
        "summary": "Formal verification of fractional Sobolev spaces H^s(T^d), mild semigroup solutions, and energy dissipation bounds for fluid PDEs on the torus.",
        "bridge_module": "StringTheoryFoundation.FluidDynamics.NavierStokesBridge"
    },
    {
        "id": "AnthropicFLT2025",
        "title": "Formalizing Fermat's Last Theorem & Modular Curves in Lean 4",
        "authors": ["Anthropic Research Team"],
        "year": 2025,
        "citation": "Anthropic Technical Monograph",
        "arxiv": "2503.xxxxx",
        "file": "lean4basesource/anthropics-flt",
        "domain": "Fermat Modular Forms",
        "summary": "Formalized modular curves X_0(N), Hecke algebras, and elliptic curves leading to the proof of modularity and Kummer surface fibrations.",
        "bridge_module": "StringTheoryFoundation.ModularForms.FermatModularBridge"
    },
    {
        "id": "CallensKummer2026",
        "title": "Mechanized Kummer Divisors and Mukai Lattice Γ^{4,20} on K3 Surfaces",
        "authors": ["Xavier Callens"],
        "year": 2026,
        "citation": "SocrateAI Technical Series 01-2026",
        "arxiv": "2602.xxxxx",
        "file": "lean4basesource/xaviercallens-xflt",
        "domain": "Kummer Lattice & M24 Moonshine",
        "summary": "Mechanized resolution of 16 exceptional A_1 rational divisors on Kummer surfaces, proving the Mukai lattice signature (4, 20) and Mathieu M_24 rigidity ratio.",
        "bridge_module": "DualScaleM24Formalization.Moonshine.MathieuRigidity"
    },
    {
        "id": "PhysLib2024",
        "title": "PhysLib: Formal Physics in Lean 4",
        "authors": ["Lean Prover Community"],
        "year": 2024,
        "citation": "Lean Community Library",
        "arxiv": "2404.xxxxx",
        "file": "lean4basesource/physlib",
        "domain": "Spacetime Kinematics",
        "summary": "Formalized classical mechanics, relativistic kinematics, Lorentz signatures, and field theory equations across 19 physics domains.",
        "bridge_module": "StringTheoryFoundation.PhysLib.PhysLibKinematicsBridge"
    },
    {
        "id": "TNLean2024",
        "title": "TNLean: Holographic Tensor Networks in Lean 4",
        "authors": ["LionSR", "Oxford Quantum"],
        "year": 2024,
        "citation": "Oxford Quantum Computing Report",
        "arxiv": "2408.xxxxx",
        "file": "lean4basesource/tnlean",
        "domain": "Quantum Tensor Networks",
        "summary": "Formalized Matrix Product States (MPS), PEPS, tensor contractions, and the Ryu-Takayanagi holographic entanglement area law.",
        "bridge_module": "StringTheoryFoundation.Quantum.TensorNetworkBridge"
    },
    {
        "id": "LeanStatLearning2024",
        "title": "Statistical Learning Theory & PAC Generalization Bounds in Lean 4",
        "authors": ["YuanheZ"],
        "year": 2024,
        "citation": "Lean Mathematics Library",
        "arxiv": "2407.xxxxx",
        "file": "lean4basesource/lean-stat-learning-theory",
        "domain": "Statistical Learning Theory",
        "summary": "Formalized Rademacher complexities, Massart finite class lemmas, and PAC uniform convergence bounds for learning policies.",
        "bridge_module": "StringTheoryFoundation.StatisticalLearning.StatisticalLearningBridge"
    }
]

class BaseLeanGraphBuilder:
    def __init__(self, root_dir: Path):
        self.root_dir = root_dir
        self.cache = LeanCacheManager(root_dir)
        self.nodes = {}
        self.edges = []
        self.papers = {p["id"]: p for p in PAPERS_METADATA}

    def build_base_graph(self) -> Dict[str, Any]:
        """Build the full base graph indexing papers, foundation corpora, and bridge connections."""
        print("🏛️ Indexing Foundational Papers & Lean 4 Base Corpora...")

        # 1. Add Paper Nodes
        for p in PAPERS_METADATA:
            paper_node = {
                "id": f"paper:{p['id']}",
                "name": p["title"],
                "node_type": "paper",
                "authors": p["authors"],
                "year": p["year"],
                "citation": p["citation"],
                "arxiv": p["arxiv"],
                "domain": p["domain"],
                "summary": p["summary"],
                "file": p["file"],
                "cluster": p["domain"],
                "degree": 0
            }
            self.nodes[paper_node["id"]] = paper_node

        # 2. Add Foundation Repository Nodes
        foundations = [
            ("repo:openai-navierstokes", "OpenAI Navier-Stokes & Euler", "Continuous Analysis & PDEs", "lean4basesource/openai-navierstokes"),
            ("repo:anthropics-flt", "Anthropic Fermat's Last Theorem", "Arithmetic Geometry & Modular Forms", "lean4basesource/anthropics-flt"),
            ("repo:xaviercallens-xflt", "Callens Kummer Divisors & Mukai Lattice", "Kummer Lattices & Moonshine", "lean4basesource/xaviercallens-xflt"),
            ("repo:atlas-lean", "Meta AI ATLAS-Lean AutoformBot", "Differential Topology & Geometry", "lean4basesource/atlas-lean"),
            ("repo:physlib", "Lean Community PhysLib", "Relativistic Spacetime Kinematics", "lean4basesource/physlib"),
            ("repo:tnlean", "Oxford TNLean Tensor Networks", "Quantum Information & Holography", "lean4basesource/tnlean"),
            ("repo:lean-quantum", "inQWIRE LeanQuantum", "Quantum Circuit Verification", "lean4basesource/lean-quantum"),
            ("repo:lean-stat-learning", "Lean Statistical Learning Theory", "PAC Learning & Generalization", "lean4basesource/lean-stat-learning-theory")
        ]

        for f_id, f_name, f_domain, f_path in foundations:
            repo_node = {
                "id": f_id,
                "name": f_name,
                "node_type": "repository",
                "domain": f_domain,
                "path": f_path,
                "cluster": f_domain,
                "degree": 0
            }
            self.nodes[f_id] = repo_node

        # 3. Connect Papers to Repositories
        paper_to_repo = {
            "Witten1995": "repo:physlib",
            "Vafa2005": "repo:physlib",
            "StromingerSYZ1996": "repo:atlas-lean",
            "MetaATLAS2025": "repo:atlas-lean",
            "OpenAINavierStokes2025": "repo:openai-navierstokes",
            "AnthropicFLT2025": "repo:anthropics-flt",
            "CallensKummer2026": "repo:xaviercallens-xflt",
            "PhysLib2024": "repo:physlib",
            "TNLean2024": "repo:tnlean",
            "LeanStatLearning2024": "repo:lean-stat-learning"
        }

        for pid, rid in paper_to_repo.items():
            self.edges.append({
                "source": f"paper:{pid}",
                "target": rid,
                "kind": "formalized_in",
                "label": "Formalized In"
            })

        # 4. Connect Papers to Lean 4 Bridge Modules in StringTheoryFoundation
        for p in PAPERS_METADATA:
            mod_id = f"module:{p['bridge_module']}"
            if mod_id not in self.nodes:
                self.nodes[mod_id] = {
                    "id": mod_id,
                    "name": p["bridge_module"].split(".")[-1],
                    "node_type": "bridge_module",
                    "module": p["bridge_module"],
                    "cluster": p["domain"],
                    "degree": 0
                }
            self.edges.append({
                "source": f"paper:{p['id']}",
                "target": mod_id,
                "kind": "bridges_to",
                "label": "Bridges To"
            })

        # 5. Extract Key Landmark Declarations from Foundation Files (with caching)
        self._index_key_declarations()

        # 6. Compute Node Degrees
        for e in self.edges:
            if e["source"] in self.nodes:
                self.nodes[e["source"]]["degree"] = self.nodes[e["source"]].get("degree", 0) + 1
            if e["target"] in self.nodes:
                self.nodes[e["target"]]["degree"] = self.nodes[e["target"]].get("degree", 0) + 1

        self.cache.save_hashes()
        return {
            "format": "BaseLean4Graph.v1",
            "total_nodes": len(self.nodes),
            "total_edges": len(self.edges),
            "papers_count": len(PAPERS_METADATA),
            "repositories_count": len(foundations),
            "nodes": list(self.nodes.values()),
            "edges": self.edges
        }

    def _index_key_declarations(self):
        """Index landmark declarations from foundational repositories with caching."""
        target_files = [
            ("lean4basesource/openai-navierstokes/NavierStokes/TorusInverse.lean", "repo:openai-navierstokes", "OpenAI Navier-Stokes"),
            ("lean4basesource/openai-navierstokes/Euler/ParentEulerSobolev.lean", "repo:openai-navierstokes", "OpenAI Euler"),
            ("lean4basesource/openai-navierstokes/NavierStokes/R3EnergyBoundary.lean", "repo:openai-navierstokes", "OpenAI Navier-Stokes"),
            ("lean4basesource/atlas-lean/v1/Atlas/DifferentialGeometry.lean", "repo:atlas-lean", "Meta ATLAS Geometry"),
            ("lean4basesource/atlas-lean/v1/Atlas/GeometryOfManifolds.lean", "repo:atlas-lean", "Meta ATLAS Manifolds"),
            ("lean4basesource/atlas-lean/v1/Atlas/AlgebraicTopologyI.lean", "repo:atlas-lean", "Meta ATLAS Topology"),
            ("lean4basesource/atlas-lean/v1/Atlas/EllipticCurves.lean", "repo:atlas-lean", "Meta ATLAS Elliptic Curves"),
            ("lean4basesource/atlas-lean/v1/Atlas/FourierAnalysis.lean", "repo:atlas-lean", "Meta ATLAS Fourier Analysis"),
            ("lean4basesource/physlib/Physlib.lean", "repo:physlib", "Spacetime Kinematics"),
            ("lean4basesource/tnlean/TNLean.lean", "repo:tnlean", "Quantum Tensor Networks"),
            ("lean4basesource/tnlean/TNLean/PEPS.lean", "repo:tnlean", "Quantum Tensor Networks"),
            ("lean4basesource/lean-quantum/Quantumlib.lean", "repo:lean-quantum", "Quantum Information"),
            ("lean4basesource/lean-quantum/Quantumlib/Computation.lean", "repo:lean-quantum", "Quantum Information"),
            ("lean4basesource/lean-stat-learning-theory/lakefile.lean", "repo:lean-stat-learning", "Statistical Learning Theory"),
            ("lean4basesource/anthropics-flt/FinalCheck.lean", "repo:anthropics-flt", "Fermat Modular Forms"),
            ("lean4basesource/xaviercallens-xflt/FinalCheck.lean", "repo:xaviercallens-xflt", "Kummer Lattice & Moonshine"),
            ("StringTheoryFoundation/Atlas/AtlasGeometryBridge.lean", "repo:atlas-lean", "Meta ATLAS Geometry"),
            ("StringTheoryFoundation/FluidDynamics/NavierStokesBridge.lean", "repo:openai-navierstokes", "Continuous Fluid Dynamics"),
            ("StringTheoryFoundation/ModularForms/FermatModularBridge.lean", "repo:anthropics-flt", "Fermat Modular Forms"),
            ("StringTheoryFoundation/PhysLib/PhysLibKinematicsBridge.lean", "repo:physlib", "Spacetime Kinematics"),
            ("StringTheoryFoundation/Quantum/TensorNetworkBridge.lean", "repo:tnlean", "Quantum Tensor Networks"),
            ("StringTheoryFoundation/StatisticalLearning/StatisticalLearningBridge.lean", "repo:lean-stat-learning", "Statistical Learning Theory"),
            ("DoubleFieldTheory/GeneralizedGeometry.lean", "repo:dft", "Double Field Theory"),
            ("DoubleFieldTheory/CourantAlgebroid.lean", "repo:dft", "Courant Algebroid"),
            ("DoubleFieldTheory/ActionCurvature.lean", "repo:dft", "Curvature & Action"),
            ("DoubleFieldTheory/TDualityBuscher.lean", "repo:dft", "T-Duality & Buscher"),
            ("DoubleFieldTheory/TorusMoonshine.lean", "repo:dft", "Torus Moonshine"),
            ("DoubleFieldTheory/K3Topology.lean", "repo:dft", "K3 Surface & Kummer")
        ]

        decl_pattern = re.compile(
            r'(?:/--(?P<doc>[\s\S]*?)-/\s*)?'
            r'(?P<kind>theorem|lemma|def|structure)\s+'
            r'(?P<name>[A-Za-z0-9_\'\.]+)\s*'
            r'(?P<sig>:[^:=]+?|\([^)]*\)[^:=]*:)?\s*:=',
            re.MULTILINE
        )

        for rel_path, repo_id, domain in target_files:
            fp = self.root_dir / rel_path
            if not fp.exists():
                continue

            content = fp.read_text(encoding="utf-8", errors="ignore")
            decls_to_cache = []

            for m in decl_pattern.finditer(content):
                name = m.group("name")
                doc = (m.group("doc") or "").strip()
                kind = m.group("kind")
                sig = (m.group("sig") or "").strip()

                node_id = f"decl:{name}"
                decls_to_cache.append({
                    "id": node_id,
                    "name": name,
                    "module": rel_path.replace("/", ".").replace(".lean", ""),
                    "decl_type": kind,
                    "signature": sig[:160],
                    "docstring": doc[:200],
                    "paper": domain
                })

                if node_id not in self.nodes:
                    self.nodes[node_id] = {
                        "id": node_id,
                        "name": name,
                        "node_type": "declaration",
                        "decl_type": kind,
                        "signature": sig[:160],
                        "docstring": doc[:200],
                        "domain": domain,
                        "cluster": domain,
                        "file": rel_path,
                        "degree": 0
                    }

                    # Edge from repository to declaration
                    self.edges.append({
                        "source": repo_id,
                        "target": node_id,
                        "kind": "defines",
                        "label": "Defines"
                    })

            # Update cache
            self.cache.update_cached_file(fp, decls_to_cache, repo_id, domain)

    def export_all(self, out_dir: Path):
        """Export base graph in JSON, NDJSON, DOT, GEXF, JSONL, and interactive HTML."""
        out_dir.mkdir(parents=True, exist_ok=True)
        graph_data = self.build_base_graph()

        # 1. JSON
        (out_dir / "base_leangraph.json").write_text(json.dumps(graph_data, indent=2), encoding="utf-8")

        # 2. NDJSON
        with open(out_dir / "base_leangraph.ndjson", "w", encoding="utf-8") as f:
            for n in graph_data["nodes"]:
                f.write(json.dumps(n) + "\n")

        # 3. DOT
        dot_lines = [
            "digraph BaseLeanGraph {",
            "  rankdir=LR;",
            "  node [fontname=\"Helvetica\", fontsize=10, shape=box, style=filled];",
            "  edge [fontname=\"Helvetica\", fontsize=8];"
        ]
        for n in graph_data["nodes"]:
            color = "#bbdefb" if n.get("node_type") == "paper" else ("#ffe0b2" if n.get("node_type") == "repository" else "#c8e6c9")
            dot_lines.append(f'  "{n["id"]}" [label="{n["name"][:30]}", fillcolor="{color}"];')
        for e in graph_data["edges"]:
            dot_lines.append(f'  "{e["source"]}" -> "{e["target"]}" [label="{e.get("label", "")}"];')
        dot_lines.append("}\n")
        (out_dir / "base_leangraph.dot").write_text("\n".join(dot_lines), encoding="utf-8")

        # 4. GEXF
        gexf_lines = [
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<gexf xmlns="http://www.gexf.net/1.2draft" version="1.2">',
            '  <graph defaultedgetype="directed">',
            '    <nodes>'
        ]
        for n in graph_data["nodes"]:
            label = n["name"].replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', '&quot;')
            gexf_lines.append(f'      <node id="{n["id"]}" label="{label}" />')
        gexf_lines.append('    </nodes>')
        gexf_lines.append('    <edges>')
        for i, e in enumerate(graph_data["edges"]):
            gexf_lines.append(f'      <edge id="{i}" source="{e["source"]}" target="{e["target"]}" label="{e.get("label", "")}" />')
        gexf_lines.append('    </edges>')
        gexf_lines.append('  </graph>')
        gexf_lines.append('</gexf>')
        (out_dir / "base_leangraph.gexf").write_text("\n".join(gexf_lines), encoding="utf-8")

        # 5. Statements JSONL
        with open(out_dir / "export_statements.jsonl", "w", encoding="utf-8") as f:
            for n in graph_data["nodes"]:
                if n.get("node_type") == "declaration":
                    f.write(json.dumps(n) + "\n")

        # 6. Interactive HTML Explorer
        self._export_html(graph_data, out_dir / "index.html")

        print(f"\n📦 Successfully generated BaseLean4 Graph in {out_dir}/:")
        print(f"  - Total Nodes: {graph_data['total_nodes']} ({graph_data['papers_count']} papers, {graph_data['repositories_count']} repos)")
        print(f"  - Total Edges: {graph_data['total_edges']}")
        print(f"  - Output Artifacts: JSON, NDJSON, DOT, GEXF, JSONL, and HTML Explorer\n")

    def _export_html(self, graph_data: Dict[str, Any], out_file: Path):
        nodes_js = json.dumps(graph_data["nodes"])
        edges_js = json.dumps(graph_data["edges"])
        papers_js = json.dumps(PAPERS_METADATA)

        html_text = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BaseLean4 Graph - Foundational Papers & Open-Source Corpora</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
  <script src="https://d3js.org/d3.v7.min.js"></script>
  <style>
    :root {{
      --bg: #0d1117;
      --card-bg: #161b22;
      --border: #30363d;
      --text: #c9d1d9;
      --accent: #58a6ff;
      --gold: #f1e05a;
      --purple: #bc8cff;
      --green: #3fb950;
      --orange: #ffa657;
    }}
    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      background: var(--bg);
      color: var(--text);
      display: flex;
      height: 100vh;
      overflow: hidden;
    }}
    #sidebar {{
      width: 460px;
      min-width: 420px;
      background: var(--card-bg);
      border-right: 1px solid var(--border);
      display: flex;
      flex-direction: column;
      height: 100vh;
      z-index: 10;
      box-shadow: 2px 0 16px rgba(0,0,0,0.5);
    }}
    #header {{
      padding: 16px 20px;
      border-bottom: 1px solid var(--border);
    }}
    #header h1 {{
      font-size: 1.15rem;
      color: #fff;
      display: flex;
      align-items: center;
      gap: 8px;
    }}
    .badge {{
      font-size: 0.7rem;
      background: #1f6feb;
      color: #fff;
      padding: 2px 6px;
      border-radius: 12px;
    }}
    #stats {{
      padding: 10px 20px;
      background: rgba(0,0,0,0.2);
      font-size: 0.8rem;
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      border-bottom: 1px solid var(--border);
    }}
    .stat-val {{ font-weight: bold; color: var(--accent); }}
    #controls {{
      padding: 14px 20px;
      border-bottom: 1px solid var(--border);
      display: flex;
      flex-direction: column;
      gap: 8px;
    }}
    #search-box {{
      width: 100%;
      background: #0d1117;
      border: 1px solid var(--border);
      color: #fff;
      padding: 8px 12px;
      border-radius: 6px;
      font-size: 0.85rem;
    }}
    .filter-tags {{
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }}
    .tag-btn {{
      font-size: 0.72rem;
      padding: 3px 8px;
      border-radius: 4px;
      background: #21262d;
      color: #8b949e;
      border: 1px solid var(--border);
      cursor: pointer;
    }}
    .tag-btn.active {{
      background: #238636;
      color: #fff;
      border-color: #2ea043;
    }}
    #details {{
      flex: 1;
      overflow-y: auto;
      padding: 20px;
    }}
    .item-title {{
      font-size: 1.1rem;
      font-weight: bold;
      color: #fff;
      margin-bottom: 4px;
    }}
    .item-sub {{
      font-size: 0.8rem;
      color: #8b949e;
      margin-bottom: 12px;
    }}
    .card-block {{
      margin-bottom: 14px;
    }}
    .block-label {{
      font-size: 0.7rem;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      color: #8b949e;
      margin-bottom: 4px;
      font-weight: 600;
    }}
    .block-text {{
      font-size: 0.85rem;
      line-height: 1.5;
      background: #0d1117;
      padding: 10px;
      border-radius: 6px;
      border: 1px solid var(--border);
    }}
    #graph-view {{
      flex: 1;
      height: 100vh;
      position: relative;
      background: radial-gradient(circle at center, #161b22 0%, #0d1117 100%);
    }}
    svg {{ width: 100%; height: 100%; }}
    .link {{ stroke-opacity: 0.6; stroke: #58a6ff; }}
    .node circle {{ stroke: #fff; stroke-width: 1.5px; cursor: pointer; }}
    .node text {{ font-size: 9px; fill: #c9d1d9; pointer-events: none; }}
    .node:hover circle {{ stroke: var(--gold); stroke-width: 3px; }}
  </style>
</head>
<body>
  <div id="sidebar">
    <div id="header">
      <h1>🏛️ BaseLean4 Graph <span class="badge">Foundations & Papers</span></h1>
      <div style="font-size: 0.75rem; color: #8b949e; margin-top: 4px;">Massive Open-Source Corpora & Literature Cross-Index</div>
    </div>
    <div id="stats">
      <div>Nodes: <span class="stat-val">{graph_data['total_nodes']}</span></div>
      <div>Papers: <span class="stat-val">{graph_data['papers_count']}</span></div>
      <div>Repos: <span class="stat-val">{graph_data['repositories_count']}</span></div>
      <div>Edges: <span class="stat-val">{graph_data['total_edges']}</span></div>
    </div>
    <div id="controls">
      <input type="text" id="search-box" placeholder="🔍 Search papers, theorems, authors, corpora..." />
      <div class="filter-tags" id="type-filters">
        <span class="tag-btn active" data-type="all">All</span>
        <span class="tag-btn" data-type="paper">📄 Papers</span>
        <span class="tag-btn" data-type="repository">🏛️ Repos</span>
        <span class="tag-btn" data-type="bridge_module">🌉 Bridges</span>
        <span class="tag-btn" data-type="declaration">📜 Declarations</span>
      </div>
    </div>
    <div id="details">
      <div style="color: #8b949e; text-align: center; margin-top: 50px;">
        👈 Click any paper, repository, or declaration node in the graph to inspect foundational connections and mathematical summaries.
      </div>
    </div>
  </div>

  <div id="graph-view">
    <svg id="viewport"></svg>
  </div>

  <script>
    const nodes = {nodes_js};
    const edges = {edges_js};
    const papers = {papers_js};

    const typeColors = {{
      "paper": "#ffa657",
      "repository": "#58a6ff",
      "bridge_module": "#bc8cff",
      "declaration": "#3fb950"
    }};

    const svg = d3.select("#viewport");
    const width = document.getElementById("graph-view").clientWidth;
    const height = document.getElementById("graph-view").clientHeight;

    const g = svg.append("g");
    const zoom = d3.zoom().scaleExtent([0.1, 6]).on("zoom", (e) => g.attr("transform", e.transform));
    svg.call(zoom);

    let activeType = "all";

    const sim = d3.forceSimulation(nodes)
      .force("link", d3.forceLink(edges).id(d => d.id).distance(80))
      .force("charge", d3.forceManyBody().strength(-180))
      .force("center", d3.forceCenter(width / 2, height / 2))
      .force("collide", d3.forceCollide().radius(14));

    const link = g.append("g").selectAll(".link")
      .data(edges)
      .enter().append("line")
      .attr("class", "link")
      .attr("stroke-width", 1.5);

    const node = g.append("g").selectAll(".node")
      .data(nodes)
      .enter().append("g")
      .attr("class", "node")
      .call(d3.drag()
        .on("start", (event, d) => {{
          if (!event.active) sim.alphaTarget(0.3).restart();
          d.fx = d.x; d.fy = d.y;
        }})
        .on("drag", (event, d) => {{ d.fx = event.x; d.fy = event.y; }})
        .on("end", (event, d) => {{
          if (!event.active) sim.alphaTarget(0);
          d.fx = null; d.fy = null;
        }}));

    node.append("circle")
      .attr("r", d => d.node_type === "paper" ? 14 : (d.node_type === "repository" ? 12 : 8))
      .attr("fill", d => typeColors[d.node_type] || "#8b949e")
      .on("click", (event, d) => showDetails(d));

    node.append("text")
      .attr("dx", 12)
      .attr("dy", ".35em")
      .text(d => d.name.length > 25 ? d.name.slice(0, 22) + "..." : d.name);

    sim.on("tick", () => {{
      link
        .attr("x1", d => d.source.x)
        .attr("y1", d => d.source.y)
        .attr("x2", d => d.target.x)
        .attr("y2", d => d.target.y);

      node.attr("transform", d => `translate(${{d.x}},${{d.y}})`);
    }});

    function showDetails(d) {{
      const container = document.getElementById("details");
      let typeLabel = (d.node_type || "item").toUpperCase();
      let color = typeColors[d.node_type] || "#fff";

      container.innerHTML = `
        <div class="item-title" style="color:${{color}}">${{d.name}}</div>
        <div class="item-sub">${{typeLabel}} &bull; ${{d.domain || d.cluster || ''}}</div>

        ${{d.summary ? `
        <div class="card-block">
          <div class="block-label">Scientific Narrative & Abstract</div>
          <div class="block-text">${{d.summary}}</div>
        </div>` : ''}}

        ${{d.docstring ? `
        <div class="card-block">
          <div class="block-label">Lean 4 Docstring & Specification</div>
          <div class="block-text">${{d.docstring}}</div>
        </div>` : ''}}

        ${{d.signature ? `
        <div class="card-block">
          <div class="block-label">Formal Type Signature</div>
          <div class="block-text" style="font-family: monospace; color: #79c0ff;">${{d.signature}}</div>
        </div>` : ''}}

        ${{d.citation ? `
        <div class="card-block">
          <div class="block-label">Foundational Citation</div>
          <div class="block-text">${{d.citation}} (${{d.year}})</div>
        </div>` : ''}}

        ${{d.file ? `
        <div class="card-block">
          <div class="block-label">Corpus / File Path</div>
          <div class="block-text" style="font-family: monospace; font-size: 0.75rem;">${{d.file}}</div>
        </div>` : ''}}
      `;

      if (window.renderMathInElement) {{
        renderMathInElement(container, {{
          delimiters: [
            {{left: '$$', right: '$$', display: true}},
            {{left: '$', right: '$', display: false}}
          ]
        }});
      }}
    }}

    document.querySelectorAll(".tag-btn").forEach(btn => {{
      btn.addEventListener("click", () => {{
        document.querySelectorAll(".tag-btn").forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        activeType = btn.getAttribute("data-type");
        applyFilter();
      }});
    }});

    document.getElementById("search-box").addEventListener("input", applyFilter);

    function applyFilter() {{
      const q = document.getElementById("search-box").value.toLowerCase();
      node.style("display", d => {{
        if (activeType !== "all" && d.node_type !== activeType) return "none";
        if (q) {{
          const matchName = d.name.toLowerCase().includes(q);
          const matchSummary = (d.summary || "").toLowerCase().includes(q);
          const matchDoc = (d.docstring || "").toLowerCase().includes(q);
          return (matchName || matchSummary || matchDoc) ? "" : "none";
        }}
        return "";
      }});
    }}
  </script>
</body>
</html>
"""
        out_file.write_text(html_text, encoding="utf-8")
