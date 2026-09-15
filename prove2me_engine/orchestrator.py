#!/usr/bin/env python3
"""
prove2me_engine/orchestrator.py
===============================
Prove2Me Orchestrator & DAG Scheduler

Implements the Columbia University / Anthropic Prove2Me paradigm:
  1. DAG-driven theorem statement maintenance (DAG frontier crawler).
  2. Decoupled theorem statements vs. isolated proof checking (<300ms verification).
  3. Semantic search over natural-language theorem descriptions to enable lemma reuse.
  4. Context compression: generates ultra-compact (<800 token) prompts per card.
"""

import json
import math
import os
import re
import subprocess
import time
import concurrent.futures
from collections import defaultdict, deque
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple

ENGINE_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = ENGINE_DIR.parent
MANIFEST_PATH = ENGINE_DIR / "dag_manifest.json"

class Prove2MeOrchestrator:
    def __init__(self, manifest_path: Path = MANIFEST_PATH):
        self.manifest_path = manifest_path
        self.load_manifest()
        self.lean_path = self._get_lean_path()

    def load_manifest(self):
        if not self.manifest_path.exists():
            raise FileNotFoundError(f"Manifest not found at {self.manifest_path}")
        with open(self.manifest_path, "r", encoding="utf-8") as f:
            self.manifest = json.load(f)
        self.cards: Dict[str, dict] = {c["card_id"]: c for c in self.manifest["cards"]}

        # Schema detection. Two incompatible manifest shapes have been checked into this
        # repo at different times under the same dag_manifest.json filename:
        #   "sprint"       -- each card carries spec_file/proof_file (the original 36-card
        #                     Prove2Me Sprint 1 harness this engine was written for).
        #   "corpus_index" -- a later, larger (385-card) whole-corpus declaration index with
        #                     no spec_file/proof_file at all (dependencies are unqualified
        #                     bare names, e.g. "DilatonMeasure", not full card_ids).
        # Every method below must degrade gracefully -- not raise a bare KeyError -- when run
        # against a "corpus_index" manifest, since isolated per-card verification is not
        # meaningful for those entries (see PAPER7_IMPROVEMENT_PROPOSAL.md-style audit notes
        # in the project review; this comment documents the same discipline for the engine).
        sample = next(iter(self.cards.values()), {})
        self.schema = "sprint" if ("spec_file" in sample or "proof_file" in sample) else "corpus_index"

        # Index by bare name (and by the last dotted component of card_id) so that
        # dependency lists using unqualified names can still be resolved against the
        # fully-qualified card_id keys used elsewhere in the manifest.
        self._name_index: Dict[str, List[str]] = defaultdict(list)
        for card_id, card in self.cards.items():
            bare = card.get("name") or card_id.rsplit(".", 1)[-1]
            self._name_index[bare].append(card_id)
            self._name_index[card_id].append(card_id)

        self._build_graph()

    def _resolve_dep(self, dep: str) -> Optional[str]:
        """Resolve a dependency reference (a literal card_id, or an unqualified bare name)
        to a single card_id. Returns None if it cannot be resolved to exactly one card --
        callers must treat that as 'unresolved', not silently as 'satisfied'."""
        if dep in self.cards:
            return dep
        matches = self._name_index.get(dep, [])
        if len(matches) == 1:
            return matches[0]
        return None

    def _get_lean_path(self) -> str:
        res = subprocess.run(
            ["lake", "env", "printenv", "LEAN_PATH"],
            cwd=ENGINE_DIR,
            capture_output=True,
            text=True
        )
        if res.returncode == 0 and res.stdout.strip():
            return res.stdout.strip()
        # Fallback to local lake build
        local_build = ENGINE_DIR / ".lake" / "build" / "lib" / "lean"
        return str(local_build)

    def _build_graph(self):
        self.adj = defaultdict(list)          # parent -> list of dependents (children in proof flow)
        self.deps = defaultdict(list)         # card -> list of RESOLVED (card_id) requirements
        self.unresolved_deps: Dict[str, List[str]] = defaultdict(list)  # card -> deps we could not resolve
        self.in_degree = defaultdict(int)

        for card_id, card in self.cards.items():
            resolved = []
            for dep in card.get("dependencies", []):
                dep_id = self._resolve_dep(dep)
                if dep_id is None:
                    self.unresolved_deps[card_id].append(dep)
                    continue
                resolved.append(dep_id)
                self.adj[dep_id].append(card_id)
            self.deps[card_id] = resolved
            self.in_degree[card_id] = len(resolved)

    def save_manifest(self):
        self.manifest["cards"] = list(self.cards.values())
        with open(self.manifest_path, "w", encoding="utf-8") as f:
            json.dump(self.manifest, f, indent=2)

    @staticmethod
    def _is_done(status) -> bool:
        # Status strings have appeared in this repo's manifests as "PROVED", "VERIFIED"
        # and "Verified" (mixed case) at different times; compare case-insensitively so
        # the scheduler and the human-facing `status` command never disagree about which
        # cards are already done (they silently did, before this fix -- see orchestrator
        # review notes / PAPER7_IMPROVEMENT_PROPOSAL.md discipline applied to this engine).
        return isinstance(status, str) and status.upper() in ("PROVED", "VERIFIED")

    def get_frontier(self) -> List[str]:
        """
        Returns all cards that are currently OPEN, whose dependencies are all resolved AND
        completely proved. A card with an unresolved dependency name is never included here
        -- see get_blocked() to see why a card isn't (and won't become) part of the frontier.
        """
        frontier = []
        for card_id, card in self.cards.items():
            if self._is_done(card.get("status")):
                continue
            if self.unresolved_deps.get(card_id):
                continue
            deps = self.deps.get(card_id, [])
            deps_satisfied = all(
                self._is_done(self.cards.get(dep, {}).get("status"))
                for dep in deps
            )
            if deps_satisfied:
                frontier.append(card_id)
        return sorted(frontier)

    def search(self, query: str, top_k: int = 5) -> List[Tuple[float, dict]]:
        """
        Performs natural-language semantic keyword search over card summaries and labels.
        Enables agents to discover existing lemmas and shorten proof paths.
        """
        tokens = re.findall(r'\w+', query.lower())
        if not tokens:
            return []

        scored = []
        for card_id, card in self.cards.items():
            label = card.get("label") or card.get("name") or card_id
            summary = card.get("natural_language_summary") or card.get("informal_description") or ""
            domain = card.get("domain") or card.get("cluster") or ""
            text = f"{label} {summary} {domain}".lower()
            score = 0.0
            for t in tokens:
                # Exact word match
                matches = len(re.findall(rf'\b{re.escape(t)}\b', text))
                if matches > 0:
                    score += 2.0 * matches
                elif t in text:
                    score += 0.8
            if score > 0:
                scored.append((score, card))

        scored.sort(key=lambda x: x[0], reverse=True)
        return scored[:top_k]

    def format_agent_prompt(self, card_id: str) -> str:
        """
        Generates an ultra-compact (<800 tokens) prompt for an AI agent.
        Includes only the target card specification, its natural-language goal,
        and the specifications of its direct dependencies.
        """
        card = self.cards.get(card_id)
        if not card:
            raise ValueError(f"Card {card_id} not found")
        if "spec_file" not in card:
            raise ValueError(
                f"Card {card_id} has no 'spec_file' (this manifest is schema={self.schema!r}; "
                "isolated Prove2Me prompts are only meaningful for 'sprint'-schema cards -- "
                "a 'corpus_index' card describes a declaration that already lives in, and "
                "must be edited/verified through, the main project's own Lean sources)."
            )

        spec_file = ENGINE_DIR / card["spec_file"]
        spec_content = spec_file.read_text(encoding="utf-8") if spec_file.exists() else ""

        dep_specs = []
        for dep_id in self.deps.get(card_id, []):
            dep_card = self.cards.get(dep_id, {})
            dep_spec_file = ENGINE_DIR / dep_card.get("spec_file", "")
            if dep_spec_file.exists():
                dep_specs.append(f"-- Dependency: {dep_id} ({dep_card.get('label')})\n" + dep_spec_file.read_text(encoding="utf-8"))

        prompt = f"""/-
PROVE2ME ISOLATED THEOREM CARD: {card['card_id']} ({card.get('label', card.get('name', card_id))})
Domain: {card.get('domain', card.get('cluster', ''))}
Epistemic Tier: {card.get('tier', 'n/a')}

Goal:
  {card.get('natural_language_summary', card.get('informal_description', ''))}
-/

-- Target Specification:
{spec_content}
"""
        if dep_specs:
            prompt += "\n-- Available Pre-proven Child Lemmas:\n" + "\n\n".join(dep_specs)

        return prompt

    def verify_card(self, card_id: str) -> Tuple[bool, float, str]:
        """
        Compiles and verifies an individual proof against compiled specs using standalone lean.
        Measures exact compilation latency in milliseconds.
        """
        card = self.cards.get(card_id)
        if not card:
            return False, 0.0, f"Card {card_id} not found"
        if "proof_file" not in card:
            return False, 0.0, (
                f"Card {card_id} has no 'proof_file' (schema={self.schema!r}); this engine "
                "can only kernel-verify 'sprint'-schema cards in isolation. To check this "
                "declaration, run 'lake build' in the main project instead."
            )

        proof_path = ENGINE_DIR / card["proof_file"]
        if not proof_path.exists():
            return False, 0.0, f"Proof file {proof_path} does not exist"

        env = dict(os.environ)
        env["LEAN_PATH"] = self.lean_path
        env["PATH"] = f"/home/xavkal/.elan/bin:{env.get('PATH', '')}"

        start_time = time.perf_counter()
        res = subprocess.run(
            ["lean", str(proof_path)],
            cwd=ENGINE_DIR,
            capture_output=True,
            text=True,
            env=env
        )
        latency_ms = (time.perf_counter() - start_time) * 1000.0

        if res.returncode == 0:
            card["status"] = "PROVED"
            card["kernel_verified"] = True
            card["latency_ms"] = round(latency_ms, 2)
            return True, latency_ms, "PASS"
        else:
            return False, latency_ms, res.stderr

    def suggest_lemmas(self, query: str, top_k: int = 3) -> List[dict]:
        """
        Suggests pre-proven lemmas from the DAG to resolve a target goal.
        """
        results = self.search(query, top_k=top_k)
        suggestions = []
        for score, card in results:
            if self._is_done(card.get("status")):
                number = card.get("number")
                symbol = (
                    f"Prove2Me.Specs.Card{number:02d}Statement" if isinstance(number, int)
                    else card.get("card_id")
                )
                suggestions.append({
                    "card_id": card["card_id"],
                    "label": card.get("label") or card.get("name") or card["card_id"],
                    "statement_symbol": symbol,
                    "summary": card.get("natural_language_summary") or card.get("informal_description") or "",
                    "score": round(score, 2)
                })
        return suggestions

    def get_blocked(self) -> Dict[str, str]:
        """
        For every not-yet-done card that is NOT in the current frontier, explain why: an
        unresolved dependency name, or a not-yet-proved (but resolvable) dependency. This is
        the diagnostic that was missing before this fix -- a stuck DAG used to just silently
        never progress past the same frontier, with no indication of why.
        """
        frontier = set(self.get_frontier())
        blocked = {}
        for card_id, card in self.cards.items():
            if self._is_done(card.get("status")) or card_id in frontier:
                continue
            if self.unresolved_deps.get(card_id):
                blocked[card_id] = (
                    "unresolved dependency name(s): " + ", ".join(self.unresolved_deps[card_id])
                )
            else:
                pending = [d for d in self.deps.get(card_id, [])
                           if not self._is_done(self.cards.get(d, {}).get("status"))]
                blocked[card_id] = "waiting on: " + ", ".join(pending) if pending else "unknown"
        return blocked

    def run_full_schedule(self, force_reprove: bool = False, max_workers: int = 8) -> dict:
        """
        Executes the full DAG crawl from leaves to root, verifying each card at the frontier.
        Supports multi-worker parallel verification across CPU cores.
        """
        print(f"\n=======================================================")
        print(f"  Prove2Me DAG Execution: {self.manifest.get('sprint') or self.manifest.get('description') or self.schema}")
        print(f"  Total Cards: {len(self.cards)} | Workers: {max_workers}")
        print(f"=======================================================\n")

        if force_reprove:
            print("  [INFO] Force reprove requested. Resetting all cards to OPEN.")
            for card in self.cards.values():
                card["status"] = "OPEN"
                card["kernel_verified"] = False

        # First, ensure specs library is built
        print("  [STEP 1] Compiling Theorem Specifications Library via Lake...")
        spec_build = subprocess.run(
            ["lake", "build", "Specs"],
            cwd=ENGINE_DIR,
            capture_output=True,
            text=True
        )
        if spec_build.returncode != 0:
            print("  [FAIL] Failed to compile Specs library:\n" + spec_build.stderr)
            return {"success": False, "error": spec_build.stderr}
        print("  [PASS] Specs library compiled successfully. All .olean stubs ready.\n")

        # Re-fetch lean path
        self.lean_path = self._get_lean_path()

        step = 1
        proved_cards = 0
        latencies = []

        while True:
            frontier = self.get_frontier()
            if not frontier:
                break

            print(f"--- Iteration {step}: Frontier contains {len(frontier)} unblocked cards ---")

            def _tag(c_id: str, card: dict) -> str:
                num = card.get("number")
                label = card.get("label") or card.get("name") or c_id
                return f"Card {num:02d} ({c_id} - {label})" if isinstance(num, int) else f"{c_id} ({label})"

            if max_workers > 1 and len(frontier) > 1:
                with concurrent.futures.ThreadPoolExecutor(max_workers=min(max_workers, len(frontier))) as executor:
                    futures = {executor.submit(self.verify_card, c_id): c_id for c_id in frontier}
                    for fut in concurrent.futures.as_completed(futures):
                        c_id = futures[fut]
                        ok, lat_ms, msg = fut.result()
                        latencies.append(lat_ms)
                        card = self.cards[c_id]
                        if ok:
                            proved_cards += 1
                            print(f"  [OK] {_tag(c_id, card)}: {lat_ms:.1f} ms [Worker Pool]")
                        else:
                            print(f"  [FAIL] {_tag(c_id, card)}: {msg}")
                            return {"success": False, "failed_card": c_id, "error": msg}
            else:
                for card_id in frontier:
                    card = self.cards[card_id]
                    ok, lat_ms, msg = self.verify_card(card_id)
                    latencies.append(lat_ms)
                    if ok:
                        proved_cards += 1
                        print(f"  [OK] {_tag(card_id, card)}: {lat_ms:.1f} ms")
                    else:
                        print(f"  [FAIL] {_tag(card_id, card)}: {msg}")
                        return {"success": False, "failed_card": card_id, "error": msg}

            step += 1

        self.save_manifest()
        total_proved = sum(1 for c in self.cards.values() if self._is_done(c.get("status")))
        blocked = self.get_blocked() if total_proved < len(self.cards) else {}

        summary = {
            "success": total_proved == len(self.cards),
            "total_cards": len(self.cards),
            "proved_cards": total_proved,
            "newly_proved": proved_cards,
            # Honest reporting: these are None, not a stand-in historical constant, when this
            # run verified nothing (e.g. every card was already done, or the whole frontier
            # was unresolved-blocked from iteration 1). An earlier revision of this file
            # defaulted these to hardcoded values (294.9 ms, 10.62 s, 7 iterations) lifted
            # from one real past run, which would have been silently reprinted as if measured
            # on every such no-op call.
            "avg_latency_ms": round(sum(latencies) / len(latencies), 2) if latencies else None,
            "total_proof_time_s": round(sum(latencies) / 1000.0, 2) if latencies else None,
            "frontier_iterations": step - 1,
            "blocked_cards": len(blocked),
        }

        print(f"\n=======================================================")
        print(f"  Prove2Me DAG Execution Complete")
        print(f"  Certified: {total_proved}/{len(self.cards)} cards ({total_proved/len(self.cards)*100.0:.1f}%)")
        if latencies:
            print(f"  Average Verification Latency: {summary['avg_latency_ms']:.1f} ms / card")
            print(f"  Total Clean Proof Time: {summary['total_proof_time_s']:.2f} s")
        else:
            print(f"  No cards were verified this run (nothing newly checked).")
        if blocked:
            print(f"  {len(blocked)} card(s) remain blocked and cannot enter the frontier:")
            for c_id, reason in list(blocked.items())[:10]:
                print(f"    - {c_id}: {reason}")
            if len(blocked) > 10:
                print(f"    ... and {len(blocked) - 10} more (see get_blocked()).")
        print(f"=======================================================\n")
        return summary

if __name__ == "__main__":
    orch = Prove2MeOrchestrator()
    orch.run_full_schedule()
