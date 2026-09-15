#!/usr/bin/env python3
"""
tools/commentsworkflow.py
=========================
Automated workflow for auditing, enriching, and standardizing Lean 4 documentation
with theoretical physics narratives, RAG search keys, and LeanGraph metadata.

Usage:
  python3 tools/commentsworkflow.py audit
  python3 tools/commentsworkflow.py enrich
  python3 tools/commentsworkflow.py verify
"""

import os
import sys
import re
import json
import subprocess
import argparse
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent

LEAN_DIRS = [
    ROOT_DIR / "StringTheoryFoundation",
    ROOT_DIR / "DoubleFieldTheory",
    ROOT_DIR / "DualScaleM24Formalization",
    ROOT_DIR / "DualScaleValidation",
    ROOT_DIR / "Lean5Corpus",
]

DECL_PATTERN = re.compile(
    r"(?:/--\s*(.*?)\s*-/\s*)?(?:@\[[^\]]+\]\s*)*(?:theorem|def|lemma|structure)\s+([A-Za-z0-9_]+)(.*?):=",
    re.DOTALL
)

class CommentsWorkflow:
    def __init__(self, root: Path = ROOT_DIR):
        self.root = root

    def get_all_lean_files(self):
        files = []
        for ldir in LEAN_DIRS:
            if ldir.exists():
                for f in sorted(ldir.rglob("*.lean")):
                    # Exclude lakefiles and setup files
                    if f.name not in ["lakefile.lean"]:
                        files.append(f)
        return files

    def audit_file(self, fpath: Path):
        text = fpath.read_text(encoding="utf-8", errors="ignore")
        rel_path = fpath.relative_to(self.root)

        total_decls = 0
        with_doc = 0
        with_phys_meaning = 0
        with_concept = 0
        with_rag_query = 0
        with_graph_node = 0
        narrative_complete = 0
        gaps = []  # per-declaration: (name, missing-pieces list) for --gap-list

        # Scan declarations
        for m in DECL_PATTERN.finditer(text):
            total_decls += 1
            doc = m.group(1) or ""
            name = m.group(2)
            doc_lower = doc.lower()

            has_doc = bool(doc)
            # A docstring that is (or degenerates to) the template's own literal example line is
            # not a genuine narrative -- it's the propagation bug this project's own audit found
            # (templates/LEAN4_PHYSICS_RAG_GRAPH_TEMPLATE.md bakes in this exact string as sample
            # text). Require a Physical Meaning marker AND more prose than just that one line.
            has_phys_meaning = has_doc and (
                "physical meaning:" in doc_lower or "### theorem:" in doc_lower or "### definition:" in doc_lower
            )
            is_template_copy = (
                has_phys_meaning
                and "100% certified (0 sorry, 0 admit)" in doc_lower
                and len(doc.strip()) < 400  # the template's own example block is short; a real
                                              # theorem-specific narrative this terse next to that
                                              # exact phrase is almost certainly copy-pasted
            )
            has_concept = "@concept:" in doc
            has_rag_query = "@rag_query:" in doc
            has_graph_node = "@graph_node:" in doc or "@graph_edge:" in doc

            if has_doc:
                with_doc += 1
            if has_phys_meaning and not is_template_copy:
                with_phys_meaning += 1
            if has_concept:
                with_concept += 1
            if has_rag_query:
                with_rag_query += 1
            if has_graph_node:
                with_graph_node += 1

            complete = (
                has_doc and has_phys_meaning and not is_template_copy
                and has_concept and has_rag_query and has_graph_node
            )
            if complete:
                narrative_complete += 1
            else:
                missing = []
                if not has_doc:
                    missing.append("doc")
                if not has_phys_meaning:
                    missing.append("phys_meaning")
                elif is_template_copy:
                    missing.append("phys_meaning(template-copy)")
                if not has_concept:
                    missing.append("@concept")
                if not has_rag_query:
                    missing.append("@rag_query")
                if not has_graph_node:
                    missing.append("@graph_node")
                gaps.append((name, missing))

        return {
            "file": str(rel_path),
            "total_decls": total_decls,
            "with_doc": with_doc,
            "with_phys_meaning": with_phys_meaning,
            "with_concept": with_concept,
            "with_rag_query": with_rag_query,
            "with_graph_node": with_graph_node,
            "narrative_complete": narrative_complete,
            "gaps": gaps,
        }

    def audit(self, composite: bool = False, gap_list: bool = False):
        files = self.get_all_lean_files()
        print("=" * 80)
        print(" 📋 LEAN 4 PHYSICIST & RAG-GRAPH COMMENTS WORKFLOW: COMPREHENSIVE AUDIT")
        print("=" * 80)
        print(f"Auditing {len(files)} Lean 4 files across 5 foundational directories...\n")

        file_reports = []
        tot_decls = 0
        tot_doc = 0
        tot_phys = 0
        tot_concept = 0
        tot_rag = 0
        tot_graph = 0
        tot_complete = 0

        for f in files:
            rep = self.audit_file(f)
            file_reports.append(rep)
            tot_decls += rep["total_decls"]
            tot_doc += rep["with_doc"]
            tot_phys += rep["with_phys_meaning"]
            tot_concept += rep["with_concept"]
            tot_rag += rep["with_rag_query"]
            tot_graph += rep["with_graph_node"]
            tot_complete += rep["narrative_complete"]

        # Print top files needing upgrade
        print(f"{'Module File':<50} {'Decls':<6} {'Doc%':<7} {'Phys%':<7} {'RAG%':<7} {'Graph%':<7}")
        print("-" * 88)
        for r in file_reports[:25]:
            d_pct = f"{int(r['with_doc']/r['total_decls']*100)}%" if r['total_decls'] else "N/A"
            p_pct = f"{int(r['with_phys_meaning']/r['total_decls']*100)}%" if r['total_decls'] else "N/A"
            r_pct = f"{int(r['with_rag_query']/r['total_decls']*100)}%" if r['total_decls'] else "N/A"
            g_pct = f"{int(r['with_graph_node']/r['total_decls']*100)}%" if r['total_decls'] else "N/A"
            short_name = r['file'][-48:] if len(r['file']) > 48 else r['file']
            print(f"{short_name:<50} {r['total_decls']:<6} {d_pct:<7} {p_pct:<7} {r_pct:<7} {g_pct:<7}")

        print("=" * 88)
        print("📊 CORPUS-WIDE AUDIT TOTALS (marginal -- NOT intersected; see --composite):")
        print(f"• Total Declarations Analyzed     : {tot_decls}")
        print(f"• Declarations with Docstrings    : {tot_doc} ({tot_doc/tot_decls*100:.1f}%)" if tot_decls else "")
        print(f"• Physical Meaning Narrative      : {tot_phys} ({tot_phys/tot_decls*100:.1f}%)" if tot_decls else "")
        print(f"• Semantic Concept Tags (@concept): {tot_concept} ({tot_concept/tot_decls*100:.1f}%)" if tot_decls else "")
        print(f"• RAG Query Anchors (@rag_query)  : {tot_rag} ({tot_rag/tot_decls*100:.1f}%)" if tot_decls else "")
        print(f"• LeanGraph Node Tags (@graph_node): {tot_graph} ({tot_graph/tot_decls*100:.1f}%)" if tot_decls else "")
        print("=" * 88 + "\n")

        if composite:
            pct = (tot_complete / tot_decls * 100) if tot_decls else 0.0
            print("=" * 88)
            print("🎯 COMPOSITE 'NARRATIVE-COMPLETE' COVERAGE (doc AND phys_meaning AND @concept AND")
            print("   @rag_query AND @graph_node/@graph_edge, all on the SAME declaration -- this is")
            print("   the number that matters, not any single marginal percentage above):")
            print(f"   {tot_complete} / {tot_decls} = {pct:.1f}%   (target: 80.0%)")
            if pct < 80.0 and tot_decls:
                remaining = int(round(tot_decls * 0.80)) - tot_complete
                print(f"   Gap to target: {max(remaining, 0)} declarations")
            print("=" * 88 + "\n")

        if gap_list:
            print("=" * 88)
            print("📝 GAP LIST (per file, declarations not yet Narrative-Complete, and why)")
            print("=" * 88)
            for r in file_reports:
                if not r["gaps"]:
                    continue
                print(f"\n{r['file']}  ({len(r['gaps'])}/{r['total_decls']} incomplete)")
                for name, missing in r["gaps"]:
                    print(f"   - {name}: missing {', '.join(missing)}")
            print()

        return {
            "total_decls": tot_decls, "with_doc": tot_doc, "with_phys_meaning": tot_phys,
            "with_concept": tot_concept, "with_rag_query": tot_rag, "with_graph_node": tot_graph,
            "narrative_complete": tot_complete,
            "composite_pct": (tot_complete / tot_decls * 100) if tot_decls else 0.0,
        }

    def verify_compilation(self):
        print("🔨 Verifying Lean 4 Kernel Soundness with lake build...")
        res = subprocess.run(["lake", "build"], cwd=self.root, capture_output=True, text=True)
        if res.returncode != 0:
            print("❌ Lean 4 build failed:")
            print(res.stderr or res.stdout)
            return False
        print("✅ lake build succeeded (exit 0).")
        # A successful build does NOT by itself mean 0 sorry/admit -- a file containing `sorry`
        # still compiles (with a kernel warning, not a failure). Check separately, the same
        # tactic-position-aware way used elsewhere in this project (not a naive substring match,
        # which would false-positive on this repo's own docstrings that say "0 sorry").
        sorry_pattern = re.compile(
            r"(:=|by|<;>|;)\s*sorry\b|^\s*sorry\s*$|(:=|by|<;>|;)\s*admit\b", re.MULTILINE
        )
        hits = []
        for f in self.get_all_lean_files():
            text = f.read_text(encoding="utf-8", errors="ignore")
            if sorry_pattern.search(text):
                hits.append(str(f.relative_to(self.root)))
        if hits:
            print(f"❌ {len(hits)} file(s) contain a bare sorry/admit tactic despite the clean build:")
            for h in hits:
                print(f"   - {h}")
            return False
        print("✅ 0 sorry / 0 admit tactics found (tactic-position grep, not a build-exit-code inference).")
        return True

def main():
    parser = argparse.ArgumentParser(description="Lean 4 Physicist & RAG-Graph Comments Workflow")
    subparsers = parser.add_subparsers(dest="command")

    audit_p = subparsers.add_parser("audit", help="Audit comment coverage and RAG/Graph metadata")
    audit_p.add_argument("--composite", action="store_true",
                          help="Report the intersected 'Narrative-Complete' percentage, not just marginals")
    audit_p.add_argument("--gap-list", action="store_true",
                          help="List, per declaration, which pieces (doc/phys_meaning/@concept/@rag_query/@graph_node) are missing")
    subparsers.add_parser("verify", help="Verify Lean 4 compilation soundness")

    args = parser.parse_args()
    workflow = CommentsWorkflow()

    if args.command == "audit":
        workflow.audit(composite=args.composite, gap_list=args.gap_list)
    elif args.command == "verify":
        success = workflow.verify_compilation()
        sys.exit(0 if success else 1)
    else:
        workflow.audit()

if __name__ == "__main__":
    main()
