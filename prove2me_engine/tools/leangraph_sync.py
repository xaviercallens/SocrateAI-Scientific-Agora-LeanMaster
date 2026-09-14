"""
prove2me_engine/tools/leangraph_sync.py
Syncs LeanGraph extracted theorem statements into the Prove2Me DAG manifest.
"""

import json
from pathlib import Path

def sync_leangraph_to_prove2me():
    root = Path(__file__).resolve().parent.parent.parent
    graph_json = root / "graph" / "leangraph.json"
    manifest_path = root / "prove2me_engine" / "dag_manifest.json"

    if not graph_json.exists():
        print(f"LeanGraph file not found at {graph_json}. Run leangraph first.")
        return

    with open(graph_json, "r", encoding="utf-8") as f:
        graph_data = json.load(f)

    cards = []
    for node in graph_data.get("nodes", []):
        if node["decl_type"] in ("theorem", "def", "structure"):
            # find outgoing dependencies
            deps = [
                e["target"] for e in graph_data.get("edges", [])
                if e["source"] == node["id"] and e["kind"] in ("proof", "def", "sig")
            ]
            card = {
                "card_id": node["id"],
                "name": node["name"],
                "module": node["module"],
                "type": node["decl_type"],
                "signature": node["signature"],
                "informal_description": node["docstring"][:300] if node["docstring"] else f"Formalized {node['decl_type']} for {node['name']}",
                "dependencies": deps,
                "cluster": node["cluster"],
                "status": "Verified" if node.get("is_certified", True) else "Pending",
                "papers": node.get("papers", []),
                "concepts": node.get("concepts", []),
                "impacts": node.get("impacts", [])
            }
            cards.append(card)

    out_manifest = {
        "format": "Prove2Me.DAGManifest.v2",
        "description": "Unified Prove2Me DAG Manifest synchronized from LeanGraph",
        "total_cards": len(cards),
        "cards": cards
    }

    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(out_manifest, f, indent=2)

    print(f"✅ Successfully synchronized {len(cards)} cards from LeanGraph into {manifest_path}")

if __name__ == "__main__":
    sync_leangraph_to_prove2me()
