# leanautoresearch: Autonomous Agent Instructions

Welcome, autonomous researcher. You are operating the **`leanautoresearch`** system.
Your mission is to explore open problems at the intersection of **Continuous Fluid Mechanics (Navier-Stokes)**, **Arithmetic Geometry (Fermat/Wiles)**, and **Quantum Gravity (Double Field Theory & Dual-Scale String Theory)**, formulating new mathematical theorems and mechanically proving them in **Lean 4 with strictly ZERO `sorry` axioms**.

---

## 1. The 10 Selected Open Problems in AutoResearch

The following 10 open problems form the primary research frontier of the **Lean 5 Scientific Corpus**:

| ID | Domain | Problem Statement | Target Milestone |
| :--- | :--- | :--- | :--- |
| **`NSE-P1`** | Fluid Dynamics | **Navier-Stokes Global Helicity Conservation & Topological Dissipation Bound** | Prove that non-vanishing hydrodynamic helicity $\mathcal{H} \ge 1$ strictly bounds enstrophy $\Omega > 0$ and forces strictly positive viscous dissipation $\mathcal{D} > 0$. *(Goal 1: SOLVED)* |
| **`M24-P2`** | Number Theory & String Theory | **Mathieu $M_{24}$ Arithmetic Frobenius Rigidity & Modular Conductor Lock** | Prove that the BPS character lock $N_{\mathrm{BPS}} = 27720 = 2^3 \cdot 3^2 \cdot 5 \cdot 7 \cdot 11$ factors over the first 5 primes, containing all prime factors of chiral primaries $A_1 = 90$ and $A_2 = 462$. *(Goal 2: SOLVED)* |
| **`TCC-P3`** | Cosmology & Swampland | **Dual-Scale Trans-Planckian Censorship (TCC) Singularity Resolution** | Prove that the Buscher-invariant effective radius $R_{\mathrm{eff}}(R) = R + \alpha'/R \ge 2$ strictly forbids sub-Planckian modes $\lambda_{\mathrm{phys}} < l_{\mathrm{Pl}}$, guaranteeing cosmic horizon protection. *(Goal 3: SOLVED)* |
| **`MUK-P4`** | String Geometry | **Non-Perturbative Monodromy Invariance of the Mukai Lattice $\Gamma^{4,20}$** | Prove that the intersection form on $H^*(K3, \mathbb{Z})$ remains invariant under doubled $O(4,20)$ Buscher T-duality transformations. |
| **`TURB-P5`** | Turbulence | **Kolmogorov-41 $k^{-5/3}$ Energy Cascade Dissipation Rate Bound** | Formalize lower bounds on the inertial-range spectral transfer in a discrete Fourier Sobolev lattice. |
| **`FLUX-P6`** | Swampland | **Refined de Sitter Swampland Bound on Non-Trivially Fluxed Calabi-Yau 4-folds** | Prove that positive cosmological constant vacua with non-zero 4-form flux violate asymptotic moduli stabilization. |
| **`MOD-P7`** | Algebraic Geometry | **Modularity of Kummer Surface Fibrations over Modular Curves $X_0(p^k)$** | Formalize the Hecke eigenvalue correspondence for singular fiber components in elliptic $K3$ fibrations. |
| **`DFT-P8`** | Generalized Geometry | **Generalized Courant-Nijenhuis Torsion Vanishing on Doubled Torus $T^{2d}$** | Prove that the skew-symmetric C-bracket satisfies the generalized Jacobi identity up to an exact section. |
| **`GOL-P9`** | Quantum Information | **Holographic Quantum Error-Correcting Distance for Extended Golay Code $\mathcal{G}_{24}$** | Mechanize the minimum Hamming distance $d = 8$ protecting 1/4-BPS black hole microstate superselection sectors. |
| **`SYM-P10`** | Mathematical Physics | **Non-Perturbative Instanton Action Lower Bound in 4D $\mathcal{N}=4$ Super Yang-Mills** | Prove the topological bound $S_{\mathrm{inst}} = \frac{8\pi^2}{g^2} |k| > 0$ for non-zero second Chern number $k \ne 0$. |

---

## 2. In-Scope Files

- **`prepare.py`** — Foundation definitions, core constants, problem registry, and Lean 4 path configuration. Read-only.
- **`evaluator.py`** — Lean 4 compiler harness (`lake build`), AST parse for `sorry`/`admit`, and verification metric extractor. Read-only.
- **`prover.py`** — The file **YOU** edit and iterate on. Contains candidate theorem statements, lemma strategies, and proof tactics.
- **`results.tsv`** — Experiment log. Untracked by git. Automatically maintained by `engine.py`.

---

## 3. The Experiment Loop

```
LOOP INDEFINITELY:
  1. Inspect the current research state (review prover.py and results.tsv).
  2. Select an open problem or formulate a novel conjecture bridging foundations.
  3. Edit prover.py: formulate new definitions, write theorem statements, construct Lean 4 proofs.
  4. Run verification: python3 leanautoresearch/engine.py --run-once
  5. Inspect evaluation metrics:
     - Kernel Exit Code: 0 (compilation must succeed)
     - Zero-Sorry Audit: 0 sorry, 0 admit (STRICT INVARIANT)
     - Verified Theorems: count of newly established lemmas
     - Proof Complexity: verification latency & step count
  6. Decision:
     - If verified with 0 sorry: status = 'keep'. Advance and append claim to Epistemic Ledger.
     - If compilation fails or contains sorry: status = 'crash' or 'discard'. Diagnose Lean diagnostics and attempt fix.
  7. NEVER STOP: Do not pause to ask the user. Continue exploring, refining, and generalizing proofs.
```

---

## 4. Quality Invariants

- **STRICT ZERO SORRY:** A proof containing `sorry` or `admit` is an instant failure. No exceptions.
- **CONCISE & SELF-CONTAINED:** Favor core Lean 4 tactics (`omega`, `decide`, `rfl`, `dsimp`, `cases`, `exact`) over heavy external dependencies to maintain fast verification (<2s).
- **SCIENTIFIC NARRATIVE:** Every formal module must contain foundational literature citations, physical motivations, and mathematical derivations in its docstrings.
