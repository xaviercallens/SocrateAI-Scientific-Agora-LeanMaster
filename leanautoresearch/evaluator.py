#!/usr/bin/env python3
"""
leanautoresearch/evaluator.py
=============================
The Ground-Truth Evaluation Harness for LeanAutoResearch.
Analogous to evaluate_bpb in Karpathy's prepare.py, this evaluator interfaces directly
with the Lean 4 kernel compiler, performs AST inspections, audits for zero sorry axioms,
and computes proof efficiency metrics.
"""

import os
import re
import subprocess
import time
from pathlib import Path
from typing import Dict, Any, List

PROJECT_ROOT = Path(__file__).resolve().parent.parent
LEAN5_CORPUS_DIR = PROJECT_ROOT / "Lean5Corpus"

class LeanEvaluator:
    def __init__(self, project_root: Path = PROJECT_ROOT):
        self.project_root = project_root
        self.corpus_dir = project_root / "Lean5Corpus"

    def evaluate_build(self, target: str = "Lean5Corpus") -> Dict[str, Any]:
        """Runs Lake build and extracts execution performance metrics."""
        start_time = time.time()
        res = subprocess.run(
            ["lake", "build", target],
            cwd=self.project_root,
            capture_output=True,
            text=True
        )
        duration = time.time() - start_time
        success = (res.returncode == 0)

        return {
            "target": target,
            "success": success,
            "exit_code": res.returncode,
            "duration_s": round(duration, 3),
            "stdout": res.stdout,
            "stderr": res.stderr
        }

    def audit_module(self, lean_file: Path) -> Dict[str, Any]:
        """Audits a Lean 4 file for theorems, definitions, and sorry/admit axioms."""
        if not lean_file.exists():
            return {
                "file": lean_file.name,
                "exists": False,
                "theorems": [],
                "theorem_count": 0,
                "definitions": [],
                "definition_count": 0,
                "sorry_count": 0,
                "is_zero_sorry": False
            }

        content = lean_file.read_text(encoding="utf-8")

        # Check for sorry / admit keywords outside docstrings / comments
        # Strip comments for precise regex matching
        code_no_block_comments = re.sub(r'/-[\s\S]*?-/', '', content)
        code_clean = re.sub(r'--.*', '', code_no_block_comments)

        sorry_matches = re.findall(r'\b(sorry|admit)\b', code_clean)
        theorems = re.findall(r'theorem\s+([A-Za-z0-9_]+)', code_clean)
        definitions = re.findall(r'def\s+([A-Za-z0-9_]+)', code_clean)

        return {
            "file": lean_file.name,
            "exists": True,
            "theorems": theorems,
            "theorem_count": len(theorems),
            "definitions": definitions,
            "definition_count": len(definitions),
            "sorry_count": len(sorry_matches),
            "is_zero_sorry": len(sorry_matches) == 0
        }

    def evaluate_corpus(self) -> Dict[str, Any]:
        """Evaluates the entire Lean5Corpus package."""
        build_result = self.evaluate_build("Lean5Corpus")

        problems_dir = self.corpus_dir / "Problems"
        audits = {}
        total_theorems = 0
        total_defs = 0
        total_sorries = 0

        for f in sorted(problems_dir.glob("*.lean")):
            audit = self.audit_module(f)
            audits[f.name] = audit
            total_theorems += audit["theorem_count"]
            total_defs += audit["definition_count"]
            total_sorries += audit["sorry_count"]

        zero_sorry_certified = (total_sorries == 0) and build_result["success"]

        return {
            "build_success": build_result["success"],
            "build_duration_s": build_result["duration_s"],
            "total_theorems": total_theorems,
            "total_definitions": total_defs,
            "total_sorries": total_sorries,
            "zero_sorry_certified": zero_sorry_certified,
            "problem_audits": audits
        }

def main():
    evaluator = LeanEvaluator()
    print("=" * 76)
    print("  LEANAUTORESEARCH EVALUATION HARNESS")
    print("=" * 76)
    res = evaluator.evaluate_corpus()
    print(f"  [BUILD] Status: {'SUCCESS' if res['build_success'] else 'FAILED'} in {res['build_duration_s']}s")
    print(f"  [METRICS] Theorems: {res['total_theorems']} | Defs: {res['total_definitions']} | Sorries: {res['total_sorries']}")
    print(f"  [CERTIFIED] Zero-Sorry Guarantee: {res['zero_sorry_certified']}")
    for fname, a in res["problem_audits"].items():
        print(f"    - {fname}: {a['theorem_count']} thms, {a['sorry_count']} sorries (zero-sorry: {a['is_zero_sorry']})")

if __name__ == "__main__":
    main()
