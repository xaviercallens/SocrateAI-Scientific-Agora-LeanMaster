#!/usr/bin/env python3
"""
pipeline_orchestrator.py
========================
Scientific Agora Swarm — String Theory Formalization Pipeline Orchestrator

This script drives the tri-partite ML formalization pipeline:
  Phase 1: Meta PDF-to-Lean  (signature generation)
  Phase 2: Fermat Agentic     (proof architecture)
  Phase 3: ML Tactic Search   (micro-tactic execution)

Usage:
    python3 pipeline_orchestrator.py --phase 1 --block FR5
    python3 pipeline_orchestrator.py --phase 2 --block FR3 --rag WS4,M2,FR1
    python3 pipeline_orchestrator.py --status
    python3 pipeline_orchestrator.py --dag
"""

import argparse
import json
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

# ── Project layout ────────────────────────────────────────────────────────────
PROJECT_ROOT = Path(__file__).parent
LEAN_SRC     = PROJECT_ROOT / "StringTheoryFormalization"
FRONTIER_DIR = LEAN_SRC / "Frontier"
PIPELINE_DIR = LEAN_SRC / "Pipeline"

# ── DAG definition (mirrors DAGOrchestrator.lean) ─────────────────────────────
@dataclass
class BlockNode:
    id: str
    name: str
    status: str           # "verified" | "in_progress" | "stub"
    phase: Optional[int]  # 1, 2, or 3; None for verified
    dependencies: list[str]
    sorry_count: int
    lean_file: str        # relative path

FORMALIZATION_DAG: list[BlockNode] = [
    # ── Foundations ──────────────────────────────────────────────────────────
    BlockNode("F1",   "MathlibCore",       "verified",     None, [],              0, "Foundations/MathlibCore.lean"),
    # ── NS Math ──────────────────────────────────────────────────────────────
    BlockNode("M1",   "FractionalSobolev", "in_progress",  3,    ["F1"],          2, "NSMath/FractionalSobolev.lean"),
    BlockNode("M2",   "FourierMultipliers","in_progress",  3,    ["M1"],          1, "NSMath/FourierMultipliers.lean"),
    BlockNode("M3",   "MildPDEs",          "in_progress",  2,    ["M1"],          1, "NSMath/MildPDEs.lean"),
    BlockNode("M4",   "EnergyBounds",      "in_progress",  3,    ["M1","M2"],     2, "NSMath/EnergyBounds.lean"),
    # ── String Dynamics ───────────────────────────────────────────────────────
    BlockNode("WS4",  "VertexOperators",   "verified",     None, ["F1","M2"],     0, "StringDynamics/VertexOperators.lean"),
    BlockNode("WS5",  "PicardSpectral",    "in_progress",  3,    ["WS4"],         1, "StringDynamics/PicardSpectral.lean"),
    BlockNode("WS6",  "KummerBlowup",      "verified",     None, ["F1"],          0, "StringDynamics/KummerBlowup.lean"),
    BlockNode("WS7",  "TadpoleConstraint", "verified",     None, ["WS6"],         0, "StringDynamics/TadpoleConstraint.lean"),
    BlockNode("WS8",  "MathieuM24",        "verified",     None, ["F1"],          0, "StringDynamics/MathieuM24.lean"),
    BlockNode("WS9",  "BPSMultiplicities", "verified",     None, ["WS8"],         0, "StringDynamics/BPSMultiplicities.lean"),
    BlockNode("WS10", "MukaiLattice",      "verified",     None, ["WS6"],         0, "StringDynamics/MukaiLattice.lean"),
    BlockNode("WS11", "FourierMukai",      "verified",     None, ["WS10"],        0, "StringDynamics/FourierMukai.lean"),
    BlockNode("WS12", "TDualityGysin",     "verified",     None, ["WS10"],        0, "StringDynamics/TDualityGysin.lean"),
    BlockNode("WS13", "ODDMetric",         "verified",     None, ["WS12"],        0, "StringDynamics/ODDMetric.lean"),
    BlockNode("WS14", "InvariantLocks",    "in_progress",  2,    ["WS13"],        1, "StringDynamics/InvariantLocks.lean"),
    BlockNode("WS15", "StiffIntegrators",  "in_progress",  2,    ["M3","WS14"],   2, "StringDynamics/StiffIntegrators.lean"),
    BlockNode("WS16", "SwamplandSafe",     "in_progress",  3,    ["M4","WS9"],    1, "StringDynamics/SwamplandSafe.lean"),
    BlockNode("WS17", "MukhanovSasaki",    "verified",     None, ["M3"],          0, "StringDynamics/MukhanovSasaki.lean"),
    BlockNode("WS18", "AutoEvolve",        "verified",     None, ["WS15","M3"],   0, "StringDynamics/AutoEvolve.lean"),
    BlockNode("WS19", "TDAMapper",         "verified",     None, ["F1"],          0, "StringDynamics/TDAMapper.lean"),
    # ── Frontier (Track A) ────────────────────────────────────────────────────
    BlockNode("FR1",  "CentralCharge",     "in_progress",  2,    ["M2","WS4"],    0, "Frontier/CentralCharge.lean"),
    BlockNode("FR2",  "ChiralPrimaries",   "in_progress",  2,    ["FR1"],         0, "Frontier/ChiralPrimaries.lean"),
    BlockNode("FR3",  "SL2CSymmetry",      "in_progress",  2,    ["M2","WS4","FR1"],0,"Frontier/SL2CSymmetry.lean"),
    # ── Frontier (Track B) ────────────────────────────────────────────────────
    BlockNode("FR4",  "HodgeNumbers",      "in_progress",  1,    ["WS10","WS6","FR2"],0,"Frontier/HodgeNumbers.lean"),
    BlockNode("FR5",  "FTermPotential",    "in_progress",  1,    ["WS10","WS7","FR4"],0,"Frontier/FTermPotential.lean"),
    BlockNode("FR6",  "ModuliGeodesics",   "in_progress",  2,    ["WS14","FR4","FR5"],0,"Frontier/ModuliGeodesics.lean"),
    # ── Pipeline ─────────────────────────────────────────────────────────────
    BlockNode("P1",   "DAGOrchestrator",   "verified",     None, [],              0, "Pipeline/DAGOrchestrator.lean"),
    BlockNode("P2",   "TacticSearch",      "stub",         3,    ["P1"],          0, "Pipeline/TacticSearch.lean"),
]

RAG_CONTEXT: dict[str, list[str]] = {
    "FR1": ["WS4", "M2", "F1"],
    "FR2": ["FR1", "WS4"],
    "FR3": ["M2", "WS4", "FR1"],
    "FR4": ["WS10", "WS6", "FR2"],
    "FR5": ["WS10", "WS7", "FR4"],
    "FR6": ["WS14", "FR4", "FR5"],
}

# ── Helper utilities ──────────────────────────────────────────────────────────

def get_block(block_id: str) -> Optional[BlockNode]:
    return next((b for b in FORMALIZATION_DAG if b.id == block_id), None)

def count_sorry(lean_file: Path) -> int:
    """Count remaining sorry axioms in a Lean file."""
    if not lean_file.exists():
        return 0
    text = lean_file.read_text()
    return text.count("sorry")

def scan_sorry_counts() -> dict[str, int]:
    """Re-scan all Lean files and update sorry counts."""
    counts = {}
    for block in FORMALIZATION_DAG:
        lean_path = LEAN_SRC / block.lean_file
        counts[block.id] = count_sorry(lean_path)
    return counts

def run_lake_build() -> tuple[int, str]:
    """Run `lake build` and return (returncode, output)."""
    result = subprocess.run(
        ["lake", "build"],
        cwd=PROJECT_ROOT,
        capture_output=True,
        text=True,
        timeout=600
    )
    return result.returncode, result.stdout + result.stderr

# ── CLI commands ──────────────────────────────────────────────────────────────

def cmd_status(args) -> None:
    """Print the current formalization status."""
    sorry_counts = scan_sorry_counts()
    total_blocks = len(FORMALIZATION_DAG)
    verified = sum(1 for b in FORMALIZATION_DAG if b.status == "verified")
    in_progress = sum(1 for b in FORMALIZATION_DAG if b.status == "in_progress")
    total_sorry = sum(sorry_counts.values())

    print("=" * 64)
    print("  String Theory Formalization — Block Tally")
    print("=" * 64)
    print(f"  Total blocks  : {total_blocks}")
    print(f"  ✅ Verified   : {verified} ({verified/total_blocks*100:.0f}%)")
    print(f"  🔄 In progress: {in_progress}")
    print(f"  📖 sorry count: {total_sorry}")
    print()
    print("  Frontier Blocks (Track A — Worldsheet CFT):")
    for bid in ["FR1", "FR2", "FR3"]:
        b = get_block(bid)
        sc = sorry_counts.get(bid, 0)
        status = "✅" if sc == 0 else f"⏳ ({sc} sorry)"
        print(f"    {bid}  {b.name:<20}  {status}")
    print()
    print("  Frontier Blocks (Track B — Supergravity & Geometry):")
    for bid in ["FR4", "FR5", "FR6"]:
        b = get_block(bid)
        sc = sorry_counts.get(bid, 0)
        status = "✅" if sc == 0 else f"⏳ ({sc} sorry)"
        print(f"    {bid}  {b.name:<20}  {status}")
    print("=" * 64)

def cmd_dag(args) -> None:
    """Emit the DAG as JSON for external graph tooling."""
    nodes = []
    for b in FORMALIZATION_DAG:
        nodes.append({
            "id": b.id,
            "name": b.name,
            "status": b.status,
            "phase": b.phase,
            "dependencies": b.dependencies,
            "sorry_count": b.sorry_count,
            "lean_file": b.lean_file,
            "rag_context": RAG_CONTEXT.get(b.id, [])
        })
    print(json.dumps({"nodes": nodes}, indent=2))

def cmd_phase(args) -> None:
    """Run a specific phase of the ML pipeline on a block."""
    block = get_block(args.block)
    if block is None:
        print(f"Error: block '{args.block}' not found.")
        sys.exit(1)

    lean_path = LEAN_SRC / block.lean_file
    rag = args.rag.split(",") if args.rag else RAG_CONTEXT.get(args.block, [])

    if args.phase == 1:
        print(f"[Phase 1] Meta PDF-to-Lean: generating signatures for {args.block}")
        print(f"  Target file : {lean_path}")
        print(f"  Dependencies: {block.dependencies}")
        print(f"  Action: Feed relevant sections of Polchinski/GSW to the")
        print(f"          Meta auto-formalization engine.")
        print(f"  Expected output: Blueprint DAG of Lean 4 sorry lemmas.")

    elif args.phase == 2:
        print(f"[Phase 2] Fermat Agentic: proof architecture for {args.block}")
        print(f"  RAG context : {rag}")
        print(f"  Action: Fermat retrieves verified blocks {rag}")
        print(f"          and writes the macroscopic proof structure.")
        print(f"  Directive: Apply linear_combination + ring + Fourier tactics.")

    elif args.phase == 3:
        print(f"[Phase 3] ML Tactic Search: closing sorry axioms in {args.block}")
        sorry_count = count_sorry(lean_path)
        print(f"  Current sorry count: {sorry_count}")
        print(f"  Beam width   : {64}")
        print(f"  Max depth    : {64}")
        print(f"  Action: Neural aesop + norm_num extension tree search.")
        print(f"  Failure loop : failures logged back to Fermat Phase 2.")

def cmd_build(args) -> None:
    """Run lake build and report results."""
    print("Running `lake build`...")
    rc, output = run_lake_build()
    print(output)
    if rc == 0:
        print("✅ Build succeeded.")
    else:
        print(f"❌ Build failed (exit {rc}).")
    sys.exit(rc)

# ── Entry point ───────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="String Theory Formalization Pipeline Orchestrator")
    sub = parser.add_subparsers(dest="command")

    # status
    p_status = sub.add_parser("status", help="Show formalization progress")
    p_status.set_defaults(func=cmd_status)

    # dag
    p_dag = sub.add_parser("dag", help="Emit DAG as JSON")
    p_dag.set_defaults(func=cmd_dag)

    # phase
    p_phase = sub.add_parser("phase", help="Run a pipeline phase on a block")
    p_phase.add_argument("--phase", type=int, required=True, choices=[1,2,3])
    p_phase.add_argument("--block", type=str, required=True)
    p_phase.add_argument("--rag", type=str, default="", help="Comma-separated RAG block IDs")
    p_phase.set_defaults(func=cmd_phase)

    # build
    p_build = sub.add_parser("build", help="Run lake build")
    p_build.set_defaults(func=cmd_build)

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        sys.exit(0)
    args.func(args)

if __name__ == "__main__":
    main()
