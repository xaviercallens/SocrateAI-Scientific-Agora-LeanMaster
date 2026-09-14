#!/usr/bin/env python3
"""
prove2me_engine/cli.py
======================
Prove2Me Command-Line Interface

Provides full CLI controls for the decoupled theorem formalization engine:
  - status: Summary of verified cards, latencies, and epistemic tiers.
  - frontier: Lists cards unblocked and ready for proof exploration.
  - search <query>: Semantic NLP search over card summaries and mathematical concepts.
  - verify <card_id>: Ultra-fast isolated compilation of a single card (<300ms).
  - prompt <card_id>: Formats and displays the compressed prompt (<800 tokens) for LLM agents.
  - run: Runs the autonomous frontier crawler across all DAG levels.
  - recheck: Independent topological acyclicity & zero-sorry audit.
"""

import argparse
import json
import sys
from pathlib import Path

from orchestrator import Prove2MeOrchestrator
from recheck import Prove2MeRechecker

def cmd_status(args, orch: Prove2MeOrchestrator):
    print("\n" + "=" * 80)
    print(f"  PROVE2ME DAG STATUS: {orch.manifest.get('sprint')}")
    print("=" * 80)
    print(f"  {'#':<3} | {'Card ID':<11} | {'Label':<32} | {'Tier':<4} | {'Status':<8} | {'Latency'}")
    print("-" * 80)
    
    total = len(orch.cards)
    proved = 0
    total_latency = 0.0

    for card in orch.cards.values():
        status = card.get("status", "OPEN")
        if status in ["PROVED", "VERIFIED"]:
            proved += 1
        lat = card.get("latency_ms", 0.0)
        total_latency += lat
        print(f"  {card['number']:02d}  | {card['card_id']:<11} | {card['label']:<32} | {card['tier']:<4} | {status:<8} | {lat:.1f} ms")

    avg_lat = total_latency / proved if proved > 0 else 0.0
    print("-" * 80)
    print(f"  Progress: {proved}/{total} cards ({proved/total*100.0:.1f}%) | Avg Latency: {avg_lat:.1f} ms/card\n")

def cmd_frontier(args, orch: Prove2MeOrchestrator):
    frontier = orch.get_frontier()
    print(f"\nFrontier contains {len(frontier)} unblocked cards:")
    for c_id in frontier:
        card = orch.cards[c_id]
        print(f"  - [{c_id}] {card['label']} ({card['domain']}) -> {card['natural_language_summary']}")
    print()

def cmd_search(args, orch: Prove2MeOrchestrator):
    query = " ".join(args.query)
    results = orch.search(query, top_k=args.top_k)
    print(f"\nSemantic Search Results for query: '{query}'")
    print("-" * 75)
    if not results:
        print("  No matching cards found.")
    for score, card in results:
        status_tag = f"[{card.get('status')}]"
        print(f"  [Score: {score:4.1f}] {status_tag:<10} {card['card_id']} ({card['label']})")
        print(f"               Domain : {card['domain']}")
        print(f"               Summary: {card['natural_language_summary']}")
        print()

def cmd_suggest(args, orch: Prove2MeOrchestrator):
    query = " ".join(args.query)
    suggestions = orch.suggest_lemmas(query, top_k=args.top_k)
    print(f"\nRecommended Pre-Proven Lemmas for: '{query}'")
    print("-" * 75)
    if not suggestions:
        print("  No matching lemmas found in DAG.")
    for s in suggestions:
        print(f"  * [{s['card_id']}] {s['label']} (Relevance Score: {s['score']})")
        print(f"    Symbol : {s['statement_symbol']}")
        print(f"    Summary: {s['summary']}\n")

def cmd_verify(args, orch: Prove2MeOrchestrator):
    card_id = args.card_id
    print(f"\nCompiling isolated card: {card_id}...")
    ok, lat_ms, msg = orch.verify_card(card_id)
    if ok:
        print(f"  [PASS] Card {card_id} successfully verified in {lat_ms:.1f} ms!")
    else:
        print(f"  [FAIL] Verification error in {card_id} ({lat_ms:.1f} ms):\n{msg}")

def cmd_prompt(args, orch: Prove2MeOrchestrator):
    card_id = args.card_id
    prompt = orch.format_agent_prompt(card_id)
    print(f"\nCompressed Agent Prompt for Card {card_id}:")
    print("=" * 60)
    print(prompt)
    print("=" * 60)
    approx_tokens = len(prompt.split()) * 1.3
    print(f"Approximate Context Size: ~{int(approx_tokens)} tokens (vs. >18,000 in monolithic file)\n")

def cmd_run(args, orch: Prove2MeOrchestrator):
    orch.run_full_schedule()

def cmd_recheck(args, orch: Prove2MeOrchestrator):
    rechecker = Prove2MeRechecker()
    rechecker.run_full_recheck()

def main():
    parser = argparse.ArgumentParser(description="Prove2Me Engine CLI")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    subparsers.add_parser("status", help="Show DAG status")
    subparsers.add_parser("frontier", help="Show current DAG frontier")
    
    search_p = subparsers.add_parser("search", help="Semantic search for lemmas")
    search_p.add_argument("query", nargs="+", help="Query string")
    search_p.add_argument("--top-k", type=int, default=5, help="Number of results")

    suggest_p = subparsers.add_parser("suggest", help="Suggest pre-proven lemmas for a goal")
    suggest_p.add_argument("query", nargs="+", help="Goal query string")
    suggest_p.add_argument("--top-k", type=int, default=3, help="Number of suggestions")

    verify_p = subparsers.add_parser("verify", help="Verify single card")
    verify_p.add_argument("card_id", help="Card ID to verify")

    prompt_p = subparsers.add_parser("prompt", help="Show compressed agent prompt")
    prompt_p.add_argument("card_id", help="Card ID")

    subparsers.add_parser("run", help="Run full DAG schedule")
    subparsers.add_parser("recheck", help="Run independent recheck & certification")

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        sys.exit(0)

    orch = Prove2MeOrchestrator()
    dispatch = {
        "status": cmd_status,
        "frontier": cmd_frontier,
        "search": cmd_search,
        "suggest": cmd_suggest,
        "verify": cmd_verify,
        "prompt": cmd_prompt,
        "run": cmd_run,
        "recheck": cmd_recheck,
    }
    dispatch[args.command](args, orch)

if __name__ == "__main__":
    main()
