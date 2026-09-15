# LeanAutoResearch (Lean-AutoResearch)

[![Lean 4](https://img.shields.io/badge/Lean_4-v4.33.1-blue.svg)](https://leanprover.github.io/)
[![Zero Sorry](https://img.shields.io/badge/Zero--Sorry-100%25_Certified-success.svg)](https://github.com/xaviercallens/SocrateAI-Scientific-Agora-LeanMaster)
[![License](https://img.shields.io/badge/License-Apache_2.0-green.svg)](LICENSE)

*Inspired by Andrej Karpathy's [`autoresearch`](https://github.com/karpathy/autoresearch), adapted for autonomous formal mathematical research, theoretical physics discovery, and Lean 4 zero-sorry proof certification.*

---

## 1. The Core Idea: AutoResearch for Formal Mathematics

In March 2026, Andrej Karpathy introduced **`autoresearch`**: giving an autonomous AI agent a single mutable file (`train.py`), a fixed time budget (5 minutes on a GPU), and a scalar metric (`val_bpb`) to let it iterate indefinitely overnight.

**`leanautoresearch`** reimagines this paradigm for **formal mathematics and theoretical physics**:
- Instead of training an LLM on GPU tokens, the agent's goal is **epistemic discovery and theorem certification**.
- Instead of an empirical loss function (`val_bpb`), the ground-truth arbiter is the **Lean 4 interactive theorem prover kernel** (`lake build`).
- A proof either compiles with **zero `sorry` axioms**, or it is rejected.
- Instead of tuning hyperparameters, the agent explores mathematical conjectures, formalizes open problems, finds proof paths using verified lemmas, minimizes proof complexity, and registers certified claims into an **Epistemic Directed Acyclic Graph (DAG)**.

---

## 2. Architecture Comparison: Karpathy vs. LeanAutoResearch

| Component | Karpathy `autoresearch` | SocrateAI `leanautoresearch` |
| :--- | :--- | :--- |
| **Domain** | Deep Learning / LLM Pretraining | Formal Mathematics & Theoretical Physics |
| **Ground-Truth Arbiter** | PyTorch / GPU Evaluation | **Lean 4 Kernel Compiler** (`lake build`) |
| **Mutable Target** | `train.py` (model, optimizer, loop) | `prover.py` (theorems, tactics, lemma discovery) |
| **Fixed Baseline** | `prepare.py` (data, tokenizer, eval) | `prepare.py` (foundations: NSE, Fermat, String Theory) |
| **Primary Metric** | `val_bpb` (lower is better) | **Zero-Sorry Certification** (0 sorry, proof path length) |
| **Soft Constraint** | GPU VRAM / Memory | Verification Latency (<2s) & DAG Acyclicity |
| **Experiment Budget** | Fixed 5 minutes per run | Fast compilation (~1.5s per module) |
| **Decision Rule** | If `val_bpb` improves: `keep`, else `discard` | If 0-sorry & kernel verified: `keep`, else `discard` |
| **Persistence** | `results.tsv` | `results.tsv` + **Epistemic Ledger** (`ledger.jsonl`) |

---

## 3. Foundations Ingested into the Corpus

`leanautoresearch` operates directly on top of the **Lean 5 Scientific Agora Corpus**, integrating:
1. **OpenAI Navier-Stokes (`lean4basesource/openai-navierstokes`)**: Continuous Sobolev spaces, fluid dissipation, and mild PDE bounds.
2. **Anthropic Fermat's Last Theorem (`lean4basesource/anthropics-flt`)**: Modular forms, Galois representations, elliptic curve conductors, and Kummer surfaces.
3. **Double Field Theory (`DoubleFieldTheory`)**: $O(D,D)$ split-signature geometry, Courant algebroid C-bracket, and generalized Ricci curvature.
4. **Callens Dual-Scale String Theory (`DualScaleValidation`)**: Buscher log involution, Mathieu $M_{24}$ Moonshine 27720 character lock, and Swampland Frontier Triad.

---

## 4. Project Structure

```
leanautoresearch/
├── README.md        — architecture overview and conceptual paradigm
├── program.md       — instructions and operational protocol for autonomous agents
├── prepare.py       — foundation constants, problem definitions, baseline harness
├── prover.py        — mutable theorem discovery file (agent modifies and extends this)
├── evaluator.py     — Lean 4 kernel verification harness (AST parse, zero-sorry check)
├── engine.py        — autonomous experiment loop runner
└── results.tsv      — experiment log recording verified theorems and proof metrics
```

---

## 5. Quick Start

```bash
# 1. Run a single formal verification experiment
python3 leanautoresearch/engine.py --run-once

# 2. Run the continuous autonomous loop across the 10 open problems
python3 leanautoresearch/engine.py --loop

# 3. View the experiment results log
cat leanautoresearch/results.tsv
```
