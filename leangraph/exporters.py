"""
LeanGraph Exporters
Generates multi-format outputs:
- JSON (Unified schema)
- NDJSON (aurasoph streaming schema for Prove2Me)
- DOT (Graphviz)
- GEXF (Gephi network analysis)
- Prove2Me Statement DAG (JSONL)
- Interactive Modern Web Viewer (HTML/JS)
"""

import json
from pathlib import Path
from typing import Dict, List, Any
import html

from leangraph.types import GraphNode, GraphEdge, GraphMetrics, EdgeKind, DeclType

def export_json(nodes: Dict[str, GraphNode], edges: List[GraphEdge], metrics: GraphMetrics, out_path: Path):
    data = {
        "format": "LeanGraph.Unified.v2",
        "metrics": {
            "total_nodes": metrics.total_nodes,
            "total_edges": metrics.total_edges,
            "theorems_count": metrics.theorems_count,
            "definitions_count": metrics.definitions_count,
            "structures_count": metrics.structures_count,
            "is_dag": metrics.is_dag,
            "redundant_transitive_edges": metrics.redundant_transitive_edges
        },
        "nodes": [n.to_dict() for n in nodes.values()],
        "edges": [e.to_dict() for e in edges]
    }
    out_path.write_text(json.dumps(data, indent=2), encoding="utf-8")

def export_ndjson(nodes: Dict[str, GraphNode], edges: List[GraphEdge], out_path: Path):
    """
    NDJSON format as specified in aurasoph/lean-graph:
    Each line is one JSON object representing a declaration with its edges.
    """
    # Group edges by source
    edge_map = {}
    for e in edges:
        if e.source not in edge_map:
            edge_map[e.source] = []
        edge_map[e.source].append({"target": e.target, "kind": e.kind.value})

    with open(out_path, "w", encoding="utf-8") as f:
        for node in nodes.values():
            rec = {
                "name": node.name,
                "full_name": node.id,
                "decl_type": node.decl_type.value,
                "module": node.module,
                "in_degree": node.in_degree,
                "out_degree": node.out_degree,
                "pagerank": round(node.pagerank, 5),
                "is_certified": node.is_certified,
                "cluster": node.cluster,
                "docstring": node.docstring[:150],
                "edges": edge_map.get(node.id, [])
            }
            f.write(json.dumps(rec) + "\n")

def export_dot(nodes: Dict[str, GraphNode], edges: List[GraphEdge], out_path: Path):
    """Export Graphviz DOT representation."""
    lines = [
        "digraph LeanGraph {",
        "  rankdir=LR;",
        "  node [fontname=\"Helvetica\", fontsize=10, shape=box, style=filled];",
        "  edge [fontname=\"Helvetica\", fontsize=8];\n"
    ]

    cluster_colors = {
        "Generalized Geometry": "#e1bee7",
        "Courant Algebroid": "#c5cae9",
        "Curvature & Action": "#ffcdd2",
        "T-Duality & Buscher": "#b2dfdb",
        "K3 Surface & Kummer": "#bbdefb",
        "Mathieu M24 Moonshine": "#ffe0b2",
        "Frontier String Duality": "#fff9c4",
        "OpenAI Navier-Stokes": "#b2ebf2",
        "Fermat & Modular Forms": "#d1c4e9",
        "Meta ATLAS Geometry": "#dcedc8",
        "Foundation Physics": "#f5f5f5"
    }

    edge_colors = {
        "proof": "#d32f2f",
        "def": "#1976d2",
        "sig": "#388e3c",
        "extends": "#7b1fa2",
        "field": "#f57c00",
        "docref": "#757575",
        "import": "#9e9e9e"
    }

    for n in nodes.values():
        color = cluster_colors.get(n.cluster, "#eeeeee")
        shape = "ellipse" if n.decl_type == DeclType.THEOREM else "box"
        lines.append(f'  "{n.id}" [label="{n.name}\\n({n.decl_type.value})", fillcolor="{color}", shape={shape}];')

    lines.append("")
    for e in edges:
        color = edge_colors.get(e.kind.value, "#333333")
        lines.append(f'  "{e.source}" -> "{e.target}" [color="{color}", label="{e.kind.value}"];')

    lines.append("}\n")
    out_path.write_text("\n".join(lines), encoding="utf-8")

def export_gexf(nodes: Dict[str, GraphNode], edges: List[GraphEdge], out_path: Path):
    """Export Gephi GEXF format."""
    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<gexf xmlns="http://www.gexf.net/1.2draft" version="1.2">',
        '  <graph defaultedgetype="directed">',
        '    <nodes>'
    ]
    for n in nodes.values():
        clean_name = html.escape(n.name)
        lines.append(f'      <node id="{html.escape(n.id)}" label="{clean_name}" />')
    lines.append('    </nodes>')
    lines.append('    <edges>')
    for i, e in enumerate(edges):
        lines.append(f'      <edge id="{i}" source="{html.escape(e.source)}" target="{html.escape(e.target)}" label="{e.kind.value}" />')
    lines.append('    </edges>')
    lines.append('  </graph>')
    lines.append('</gexf>')
    out_path.write_text("\n".join(lines), encoding="utf-8")

def export_prove2me_statements(nodes: Dict[str, GraphNode], edges: List[GraphEdge], out_path: Path):
    """Export statement DAG format for Prove2Me multi-agent proving engine."""
    with open(out_path, "w", encoding="utf-8") as f:
        for node in nodes.values():
            if node.decl_type in (DeclType.THEOREM, DeclType.DEFINITION, DeclType.STRUCTURE):
                deps = [e.target for e in edges if e.source == node.id and e.kind in (EdgeKind.PROOF, EdgeKind.DEF, EdgeKind.SIG)]
                rec = {
                    "theorem_id": node.id,
                    "name": node.name,
                    "module": node.module,
                    "type": node.decl_type.value,
                    "signature": node.signature,
                    "informal_description": node.docstring[:250] if node.docstring else f"Formalized {node.decl_type.value} for {node.name}",
                    "dependencies": deps,
                    "cluster": node.cluster,
                    "papers": node.papers,
                    "status": "Verified" if node.is_certified else "Pending"
                }
                f.write(json.dumps(rec) + "\n")

def export_interactive_html(nodes: Dict[str, GraphNode], edges: List[GraphEdge], metrics: GraphMetrics, out_path: Path):
    """Generate standalone high-performance interactive web dashboard."""
    nodes_json = json.dumps([n.to_dict() for n in nodes.values()])
    edges_json = json.dumps([e.to_dict() for e in edges])
    
    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>LeanGraph - Double Field Theory & Dual-Scale String Theory Knowledge Discovery</title>
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
      --green: #3fb950;
      --purple: #bc8cff;
      --red: #f85149;
    }}
    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      background: var(--bg);
      color: var(--text);
      display: flex;
      height: 100vh;
      overflow: hidden;
    }}
    #sidebar {{
      width: 440px;
      min-width: 400px;
      background: var(--card-bg);
      border-right: 1px solid var(--border);
      display: flex;
      flex-direction: column;
      height: 100vh;
      z-index: 10;
      box-shadow: 2px 0 16px rgba(0,0,0,0.4);
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
      background: #238636;
      color: #fff;
      padding: 2px 6px;
      border-radius: 12px;
      font-weight: bold;
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
    .stat-item {{
      display: flex;
      gap: 4px;
    }}
    .stat-val {{ font-weight: bold; color: var(--accent); }}
    #controls {{
      padding: 14px 20px;
      border-bottom: 1px solid var(--border);
      display: flex;
      flex-direction: column;
      gap: 10px;
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
    .filter-group {{
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }}
    .filter-tag {{
      font-size: 0.72rem;
      padding: 3px 8px;
      border-radius: 4px;
      cursor: pointer;
      border: 1px solid var(--border);
      background: #21262d;
      color: #8b949e;
      user-select: none;
    }}
    .filter-tag.active {{
      background: #1f6feb;
      color: #fff;
      border-color: #388bfd;
    }}
    .edge-toggles {{
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      font-size: 0.75rem;
      margin-top: 4px;
    }}
    .edge-toggle {{
      display: flex;
      align-items: center;
      gap: 4px;
      cursor: pointer;
    }}
    #node-details {{
      flex: 1;
      overflow-y: auto;
      padding: 20px;
    }}
    .empty-state {{
      text-align: center;
      color: #8b949e;
      margin-top: 60px;
      font-size: 0.9rem;
      line-height: 1.5;
    }}
    .node-title {{
      font-size: 1.1rem;
      font-weight: 700;
      color: #fff;
      margin-bottom: 4px;
      word-break: break-all;
    }}
    .node-module {{
      font-size: 0.78rem;
      color: #8b949e;
      margin-bottom: 12px;
    }}
    .card-section {{
      margin-bottom: 16px;
    }}
    .section-label {{
      font-size: 0.7rem;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      color: #8b949e;
      margin-bottom: 6px;
      font-weight: 600;
    }}
    .sig-code {{
      background: #0d1117;
      border: 1px solid var(--border);
      padding: 10px;
      border-radius: 6px;
      font-family: ui-monospace, SFMono-Regular, Consolas, monospace;
      font-size: 0.8rem;
      color: #79c0ff;
      overflow-x: auto;
      white-space: pre-wrap;
    }}
    .doc-content {{
      font-size: 0.84rem;
      line-height: 1.5;
      color: #c9d1d9;
      background: #0d1117;
      border: 1px solid var(--border);
      padding: 12px;
      border-radius: 6px;
      white-space: pre-wrap;
    }}
    .tag-list {{
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }}
    .tag {{
      font-size: 0.72rem;
      background: #23272d;
      border: 1px solid var(--border);
      padding: 2px 8px;
      border-radius: 4px;
      color: #58a6ff;
    }}
    .tag.paper {{ color: #f1e05a; border-color: rgba(241,224,90,0.3); }}
    .tag.concept {{ color: #bc8cff; border-color: rgba(188,140,255,0.3); }}
    .tag.impact {{ color: #3fb950; border-color: rgba(63,185,80,0.3); }}
    #graph-container {{
      flex: 1;
      height: 100vh;
      position: relative;
      background: radial-gradient(circle at center, #161b22 0%, #0d1117 100%);
    }}
    svg {{
      width: 100%;
      height: 100%;
    }}
    .link {{
      stroke-opacity: 0.6;
    }}
    .node circle {{
      stroke: #fff;
      stroke-width: 1.5px;
      cursor: pointer;
      transition: r 0.2s, stroke-width 0.2s;
    }}
    .node text {{
      font-size: 9px;
      fill: #c9d1d9;
      pointer-events: none;
      font-family: -apple-system, sans-serif;
    }}
    .node:hover circle {{
      stroke: var(--gold);
      stroke-width: 3px;
    }}
    .node.selected circle {{
      stroke: #f85149;
      stroke-width: 4px;
    }}
    #toolbar {{
      position: absolute;
      bottom: 20px;
      right: 20px;
      display: flex;
      gap: 8px;
      background: var(--card-bg);
      padding: 8px;
      border-radius: 8px;
      border: 1px solid var(--border);
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
    }}
    .btn {{
      background: #21262d;
      border: 1px solid var(--border);
      color: #c9d1d9;
      padding: 6px 12px;
      border-radius: 6px;
      font-size: 0.75rem;
      cursor: pointer;
    }}
    .btn:hover {{
      background: #30363d;
      color: #fff;
    }}
  </style>
</head>
<body>
  <div id="sidebar">
    <div id="header">
      <h1>🕸️ LeanGraph <span class="badge">Certified Zero-Sorry</span></h1>
      <div style="font-size: 0.75rem; color: #8b949e; margin-top: 4px;">Double Field Theory & Dual-Scale M₂₄ Discovery Engine</div>
    </div>
    <div id="stats">
      <div class="stat-item">Nodes: <span class="stat-val" id="stat-nodes">{metrics.total_nodes}</span></div>
      <div class="stat-item">Theorems: <span class="stat-val">{metrics.theorems_count}</span></div>
      <div class="stat-item">Defs: <span class="stat-val">{metrics.definitions_count}</span></div>
      <div class="stat-item">Edges: <span class="stat-val" id="stat-edges">{metrics.total_edges}</span></div>
      <div class="stat-item">Hasse Redundant: <span class="stat-val">{metrics.redundant_transitive_edges}</span></div>
    </div>
    <div id="controls">
      <input type="text" id="search-box" placeholder="🔍 Search theorem, concept, paper or module..." />
      <div class="filter-group" id="cluster-filters"></div>
      <div class="edge-toggles">
        <label class="edge-toggle"><input type="checkbox" id="toggle-proof" checked> <span style="color:#d32f2f;">Proof</span></label>
        <label class="edge-toggle"><input type="checkbox" id="toggle-sig" checked> <span style="color:#388e3c;">Signature</span></label>
        <label class="edge-toggle"><input type="checkbox" id="toggle-def" checked> <span style="color:#1976d2;">Def</span></label>
        <label class="edge-toggle"><input type="checkbox" id="toggle-extends" checked> <span style="color:#7b1fa2;">Extends</span></label>
        <label class="edge-toggle"><input type="checkbox" id="toggle-field" checked> <span style="color:#f57c00;">Field</span></label>
        <label class="edge-toggle"><input type="checkbox" id="toggle-docref" checked> <span style="color:#8b949e;">DocRef</span></label>
      </div>
    </div>
    <div id="node-details">
      <div class="empty-state">
        <p>👈 Select any node in the graph or use the search box to inspect certified Lean 4 theorems, signatures, and physical impact.</p>
      </div>
    </div>
  </div>

  <div id="graph-container">
    <svg id="canvas"></svg>
    <div id="toolbar">
      <button class="btn" id="btn-reset-zoom">Reset Zoom</button>
      <button class="btn" id="btn-hasse-toggle">Toggle Hasse (Reduction)</button>
    </div>
  </div>

  <script>
    const allNodes = {nodes_json};
    const allEdges = {edges_json};

    const clusterColors = {{
      "Generalized Geometry": "#ab47bc",
      "Courant Algebroid": "#5c6bc0",
      "Curvature & Action": "#ef5350",
      "T-Duality & Buscher": "#26a69a",
      "K3 Surface & Kummer": "#42a5f5",
      "Mathieu M24 Moonshine": "#ffa726",
      "Frontier String Duality": "#ffee58",
      "OpenAI Navier-Stokes": "#26c6da",
      "Fermat & Modular Forms": "#7e57c2",
      "Meta ATLAS Geometry": "#9ccc65",
      "Foundation Physics": "#78909c"
    }};

    const edgeColors = {{
      "proof": "#d32f2f",
      "def": "#1976d2",
      "sig": "#388e3c",
      "extends": "#7b1fa2",
      "field": "#f57c00",
      "docref": "#8b949e",
      "import": "#546e7a"
    }};

    // Populate Cluster Filter Buttons
    const clusters = Array.from(new Set(allNodes.map(n => n.cluster))).sort();
    const clusterContainer = document.getElementById("cluster-filters");
    let activeCluster = null;

    clusters.forEach(c => {{
      const btn = document.createElement("span");
      btn.className = "filter-tag";
      btn.textContent = c;
      btn.addEventListener("click", () => {{
        if (activeCluster === c) {{
          activeCluster = null;
          btn.classList.remove("active");
        }} else {{
          document.querySelectorAll(".filter-tag").forEach(b => b.classList.remove("active"));
          activeCluster = c;
          btn.classList.add("active");
        }}
        filterAndRender();
      }});
      clusterContainer.appendChild(btn);
    }});

    // Setup D3 Simulation
    const svg = d3.select("#canvas");
    const width = document.getElementById("graph-container").clientWidth;
    const height = document.getElementById("graph-container").clientHeight;

    const g = svg.append("g");
    const zoom = d3.zoom().scaleExtent([0.1, 8]).on("zoom", (e) => g.attr("transform", e.transform));
    svg.call(zoom);

    let simulation = d3.forceSimulation()
      .force("link", d3.forceLink().id(d => d.id).distance(60))
      .force("charge", d3.forceManyBody().strength(-140))
      .force("center", d3.forceCenter(width / 2, height / 2))
      .force("collision", d3.forceCollide().radius(d => 10 + (d.in_degree || 0) * 1.5));

    let linkG = g.append("g").attr("class", "links");
    let nodeG = g.append("g").attr("class", "nodes");

    function filterAndRender() {{
      const query = document.getElementById("search-box").value.toLowerCase();
      const showProof = document.getElementById("toggle-proof").checked;
      const showSig = document.getElementById("toggle-sig").checked;
      const showDef = document.getElementById("toggle-def").checked;
      const showExtends = document.getElementById("toggle-extends").checked;
      const showField = document.getElementById("toggle-field").checked;
      const showDocref = document.getElementById("toggle-docref").checked;

      let filteredNodes = allNodes.filter(n => {{
        if (activeCluster && n.cluster !== activeCluster) return false;
        if (query) {{
          const matchName = n.name.toLowerCase().includes(query);
          const matchMod = n.module.toLowerCase().includes(query);
          const matchDoc = n.docstring.toLowerCase().includes(query);
          const matchPaper = (n.papers || []).some(p => p.toLowerCase().includes(query));
          const matchConcept = (n.concepts || []).some(c => c.toLowerCase().includes(query));
          return matchName || matchMod || matchDoc || matchPaper || matchConcept;
        }}
        return true;
      }});

      const nodeSet = new Set(filteredNodes.map(n => n.id));

      let filteredEdges = allEdges.filter(e => {{
        if (!nodeSet.has(e.source) || !nodeSet.has(e.target)) return false;
        if (e.kind === "proof" && !showProof) return false;
        if (e.kind === "sig" && !showSig) return false;
        if (e.kind === "def" && !showDef) return false;
        if (e.kind === "extends" && !showExtends) return false;
        if (e.kind === "field" && !showField) return false;
        if (e.kind === "docref" && !showDocref) return false;
        return true;
      }});

      document.getElementById("stat-nodes").textContent = filteredNodes.length;
      document.getElementById("stat-edges").textContent = filteredEdges.length;

      // Update D3 Elements
      const link = linkG.selectAll(".link")
        .data(filteredEdges, d => `${{d.source.id || d.source}}->${{d.target.id || d.target}}`);
      link.exit().remove();
      const linkEnter = link.enter().append("line")
        .attr("class", "link")
        .attr("stroke", d => edgeColors[d.kind] || "#999")
        .attr("stroke-width", d => d.kind === "proof" ? 2 : 1);
      const allLinks = linkEnter.merge(link);

      const node = nodeG.selectAll(".node")
        .data(filteredNodes, d => d.id);
      node.exit().remove();
      const nodeEnter = node.enter().append("g")
        .attr("class", "node")
        .call(d3.drag()
          .on("start", (event, d) => {{
            if (!event.active) simulation.alphaTarget(0.3).restart();
            d.fx = d.x; d.fy = d.y;
          }})
          .on("drag", (event, d) => {{
            d.fx = event.x; d.fy = event.y;
          }})
          .on("end", (event, d) => {{
            if (!event.active) simulation.alphaTarget(0);
            d.fx = null; d.fy = null;
          }}));

      nodeEnter.append("circle")
        .attr("r", d => 6 + Math.min(18, (d.in_degree || 0) * 1.2))
        .attr("fill", d => clusterColors[d.cluster] || "#78909c")
        .on("click", (event, d) => showNodeDetails(d));

      nodeEnter.append("text")
        .attr("dx", 12)
        .attr("dy", ".35em")
        .text(d => d.name);

      const allNodeElements = nodeEnter.merge(node);

      simulation.nodes(filteredNodes).on("tick", () => {{
        allLinks
          .attr("x1", d => d.source.x)
          .attr("y1", d => d.source.y)
          .attr("x2", d => d.target.x)
          .attr("y2", d => d.target.y);

        allNodeElements
          .attr("transform", d => `translate(${{d.x}},${{d.y}})`);
      }});

      simulation.force("link").links(filteredEdges);
      simulation.alpha(0.6).restart();
    }}

    function showNodeDetails(d) {{
      d3.selectAll(".node").classed("selected", n => n.id === d.id);
      const container = document.getElementById("node-details");
      
      let papersHtml = (d.papers || []).map(p => `<span class="tag paper">📄 ${{p}}</span>`).join(" ");
      let conceptsHtml = (d.concepts || []).map(c => `<span class="tag concept">💡 ${{c}}</span>`).join(" ");
      let impactsHtml = (d.impacts || []).map(i => `<span class="tag impact">🚀 ${{i}}</span>`).join(" ");

      container.innerHTML = `
        <div class="node-title">${{d.name}}</div>
        <div class="node-module">${{d.module}} &bull; <span style="color:#58a6ff;">${{d.decl_type.toUpperCase()}}</span> &bull; Line ${{d.line_number}}</div>

        <div class="card-section">
          <div class="section-label">Cluster & Centrality</div>
          <div class="tag-list">
            <span class="tag" style="color:#fff; background:${{clusterColors[d.cluster] || '#333'}}">${{d.cluster}}</span>
            <span class="tag">In-Degree: ${{d.in_degree}}</span>
            <span class="tag">Out-Degree: ${{d.out_degree}}</span>
            <span class="tag">PageRank: ${{d.pagerank}}</span>
          </div>
        </div>

        ${{d.signature ? `
        <div class="card-section">
          <div class="section-label">Lean 4 Signature</div>
          <div class="sig-code">${{d.signature}}</div>
        </div>` : ''}}

        ${{d.docstring ? `
        <div class="card-section">
          <div class="section-label">Mathematical & Scientific Narrative</div>
          <div class="doc-content">${{d.docstring}}</div>
        </div>` : ''}}

        ${{papersHtml ? `
        <div class="card-section">
          <div class="section-label">Foundational Papers & Citations</div>
          <div class="tag-list">${{papersHtml}}</div>
        </div>` : ''}}

        ${{conceptsHtml ? `
        <div class="card-section">
          <div class="section-label">Frontier Physics Concepts</div>
          <div class="tag-list">${{conceptsHtml}}</div>
        </div>` : ''}}

        ${{impactsHtml ? `
        <div class="card-section">
          <div class="section-label">Physical Impact</div>
          <div class="tag-list">${{impactsHtml}}</div>
        </div>` : ''}}
      `;

      // Trigger KaTeX rendering
      if (window.renderMathInElement) {{
        renderMathInElement(container, {{
          delimiters: [
            {{left: '$$', right: '$$', display: true}},
            {{left: '$', right: '$', display: false}}
          ]
        }});
      }}
    }}

    document.getElementById("search-box").addEventListener("input", filterAndRender);
    document.querySelectorAll(".edge-toggle input").forEach(el => el.addEventListener("change", filterAndRender));
    document.getElementById("btn-reset-zoom").addEventListener("click", () => {{
      svg.transition().duration(500).call(zoom.transform, d3.zoomIdentity);
    }});

    filterAndRender();
  </script>
</body>
</html>
"""
    out_path.write_text(html_content, encoding="utf-8")
