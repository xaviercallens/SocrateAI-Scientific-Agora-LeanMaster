#!/usr/bin/env python3
"""
prove2me_engine/tools/atlas_ingest.py
=====================================
ATLAS-to-Prove2Me Ingestion Engine

Bridges Meta AI Research ATLAS and external Lean 4 repositories (Physlib, OpenAI NS, Mathlib)
into decoupled Prove2Me theorem cards:
  1. Parses Lean 4 source files using regex/AST extraction.
  2. Extracts theorem statements, propositions, and docstrings.
  3. Formulates decoupled specifications in specs/Specs/CardXX.lean.
  4. Generates leaf proof templates in proofs/Proofs/ProofXX.lean.
  5. Updates dag_manifest.json with semantic metadata and dependencies.
"""

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

ENGINE_DIR = Path(__file__).resolve().parent.parent
MANIFEST_PATH = ENGINE_DIR / "dag_manifest.json"
SPECS_DIR = ENGINE_DIR / "specs" / "Specs"
PROOFS_DIR = ENGINE_DIR / "proofs" / "Proofs"

class AtlasIngestor:
    def __init__(self, manifest_path: Path = MANIFEST_PATH):
        self.manifest_path = manifest_path
        if self.manifest_path.exists():
            with open(self.manifest_path, "r", encoding="utf-8") as f:
                self.manifest = json.load(f)
        else:
            self.manifest = {"framework": "Prove2Me", "cards": []}
        self.cards = {c["card_id"]: c for c in self.manifest.get("cards", [])}

    def parse_lean_file(self, file_path: Path) -> List[dict]:
        """
        Extracts theorems, lemmas, and docstrings from a Lean 4 source file.
        """
        text = file_path.read_text(encoding="utf-8")
        # Match docstrings and theorem/lemma definitions
        pattern = re.compile(
            r'(?:/-\s*([\s\S]*?)\s*-/\s*)?'
            r'(?:theorem|lemma)\s+([A-Za-z0-9_]+)\s*(\([^)]*\)|\{[^}]*\}|\[[^\]]*\]|\s)*\s*:\s*([^:=]+?)\s*:=',
            re.MULTILINE
        )

        extracted = []
        for m in pattern.finditer(text):
            docstring = (m.group(1) or "").strip()
            name = m.group(2).strip()
            prop_type = m.group(4).strip()
            
            # Clean up prop_type
            prop_type = re.sub(r'\s+', ' ', prop_type)
            
            summary = docstring if docstring else f"Formal theorem {name} asserting {prop_type}."
            extracted.append({
                "name": name,
                "prop": prop_type,
                "summary": summary,
                "source_file": str(file_path)
            })
        return extracted

    def ingest_file(self, file_path: Path, domain: str, tier: str = "A", max_cards: int = 10) -> int:
        extracted = self.parse_lean_file(file_path)
        print(f"  Found {len(extracted)} theorems in {file_path.name}")
        
        current_max_num = max([c.get("number", 0) for c in self.cards.values()] or [0])
        ingested = 0

        for item in extracted[:max_cards]:
            current_max_num += 1
            card_id = f"c_{domain.lower().replace('.', '_')}_{current_max_num:03d}"
            card_num_str = f"{current_max_num:02d}"

            spec_code = f"""namespace Prove2Me.Specs

-- Ingested from {file_path.name} ({item['name']})
-- Statement Proposition:
def Card{card_num_str}Statement : Prop :=
  {item['prop']}

end Prove2Me.Specs
"""
            proof_code = f"""import Specs.Card{card_num_str}

namespace Prove2Me.Proofs

theorem {item['name']}_proof : Prove2Me.Specs.Card{card_num_str}Statement := by
  sorry

end Prove2Me.Proofs
"""
            spec_file = SPECS_DIR / f"Card{card_num_str}.lean"
            proof_file = PROOFS_DIR / f"Proof{card_num_str}.lean"

            spec_file.write_text(spec_code, encoding="utf-8")
            proof_file.write_text(proof_code, encoding="utf-8")

            card_entry = {
                "card_id": card_id,
                "number": current_max_num,
                "label": item["name"],
                "domain": domain,
                "tier": tier,
                "natural_language_summary": item["summary"],
                "spec_file": f"specs/Specs/Card{card_num_str}.lean",
                "proof_file": f"proofs/Proofs/Proof{card_num_str}.lean",
                "dependencies": [],
                "theorems": [f"{item['name']}_proof"],
                "status": "OPEN",
                "kernel_verified": False,
                "sorry_count": 1,
                "acceptance_hash": None
            }
            self.cards[card_id] = card_entry
            ingested += 1

        self.manifest["cards"] = list(self.cards.values())
        self.manifest["total_cards"] = len(self.cards)
        with open(self.manifest_path, "w", encoding="utf-8") as f:
            json.dump(self.manifest, f, indent=2)

        print(f"  [SUCCESS] Ingested {ingested} cards into Prove2Me DAG.")
        return ingested

def main():
    parser = argparse.ArgumentParser(description="ATLAS-to-Prove2Me Ingestion Tool")
    parser.add_argument("--source", type=str, required=True, help="Path to Lean 4 file to ingest")
    parser.add_argument("--domain", type=str, required=True, help="Domain identifier (e.g. FluidMechanics.NavierStokes)")
    parser.add_argument("--tier", type=str, default="A", help="Epistemic Tier (default: A)")
    parser.add_argument("--max", type=int, default=5, help="Maximum number of theorems to ingest")

    args = parser.parse_args()
    source_path = Path(args.source)
    if not source_path.exists():
        print(f"Error: Source file {source_path} does not exist.")
        sys.exit(1)

    ingestor = AtlasIngestor()
    ingestor.ingest_file(source_path, domain=args.domain, tier=args.tier, max_cards=args.max)

if __name__ == "__main__":
    main()
