# Stream 0 Epistemic Ledger (SocrateAI-Mathesis Standard)

**Epistemic Soundness Transitivity Theorem:**
> $\forall C \in \mathcal{L}, \text{tier}(C) = A \implies (\forall D \in \text{deps}(C), \text{tier}(D) = A)$.

| ID | Tier | Statement | Source | Dependencies |
|---|---|---|---|---|
| `K3T2-A-0001` | **A** | Epistemic Transitive Soundness Theorem: no claim in a sound ledger rests on a weaker claim. | [`Ledger.lean`](DualScaleM24Formalization/Epistemic/Ledger.lean) | None |
| `K3T2-A-0002` | **A** | Genesis No-Singularity Master Theorem: R_eff(R) > 0 for all R > 0 under Buscher metric bounce. | [`EffectiveMetric.lean`](DualScaleM24Formalization/DualScale/EffectiveMetric.lean) | K3T2-A-0001 |
| `K3T2-A-0003` | **A** | Symmetric-Square Lock Recurrence: Microscopic L2 operator quadratic image satisfies macroscopic L3 recurrence. | [`Sym2Lock.lean`](DualScaleM24Formalization/DualScale/Sym2Lock.lean) | K3T2-A-0001 |
| `K3T2-A-0004` | **A** | Mathieu M24 Moonshine Rigidity Ratio: R_BPS = 77/60 with gcd(77, 60) = 1 and 462*60 = 360*77 = 27720. | [`MathieuRigidity.lean`](DualScaleM24Formalization/Moonshine/MathieuRigidity.lean) | K3T2-A-0001 |
| `K3T2-A-0005` | **A** | Exact Kummer Orientifold Tadpole Cancellation: 16*4 + 4*(-16) = 0 and b3(K3xT2) = 44. | [`KummerTadpole.lean`](DualScaleM24Formalization/Moonshine/KummerTadpole.lean) | K3T2-A-0001 |
| `K3T2-A-0006` | **A** | Circle Bundle Gysin Sequence & BEM Duality: c1(E) cup c1(E_dual) = 0. | [`GysinBEMSequence.lean`](DualScaleM24Formalization/Moonshine/GysinBEMSequence.lean) | K3T2-A-0001 |
| `K3T2-A-0007` | **A** | Swampland Distance Conjecture Bounds: Picard rank 10 <= rho <= 20 and Fricke fixed point tau = i. | [`SwamplandDistance.lean`](DualScaleM24Formalization/FrontierTriad/SwamplandDistance.lean) | K3T2-A-0001 |
| `K3T2-A-0008` | **A** | Sen Tachyon Condensation Grothendieck K-Theory Charge Conservation: [E] - [F] = [D]. | [`TachyonCondensation.lean`](DualScaleM24Formalization/FrontierTriad/TachyonCondensation.lean) | K3T2-A-0001 |
| `K3T2-A-0009` | **A** | Holographic c-Theorem Monotonicity: Delta c < 0 across flux tunneling transitions. | [`FluxVacuumDecay.lean`](DualScaleM24Formalization/FrontierTriad/FluxVacuumDecay.lean) | K3T2-A-0001 |
| `K3T2-A-0010` | **A** | Mechanized Triad Invariant Contracts: TDA Mapper beta1 = 376 (V=187, E=557, b0=6) and WEC rho+p >= 0. | [`TriadContract.lean`](DualScaleM24Formalization/FrontierTriad/TriadContract.lean) | K3T2-A-0001 |
| `K3T2-B-0001` | **B** | Deterministic ℚ/ℤ Arithmetic Harness with 5 Adversarial Negative Controls. | [`exact_arithmetic_ladder.py`](tests/exact_arithmetic_ladder.py) | None |
| `K3T2-L-0001` | **L** | Eguchi-Ooguri-Tachikawa Mathieu M24 decomposition of K3 elliptic genus. | [`arXiv:1004.0956`](arXiv:1004.0956) | None |
| `K3T2-L-0002` | **L** | Bouwknegt-Evslin-Mathai Topological T-Duality & Gysin Sequence. | [`Commun. Math. Phys. 249, 383 (2004)`](Commun. Math. Phys. 249, 383 (2004)) | None |
| `K3T2-L-0003` | **L** | Xavier Callens Mechanized T-Duality and Frontier String Dynamics on K3 x T2. | [`T_duality_Alone.tex`](papers/T-dulaity alone/T_duality_Alone.tex) | None |
| `PROVE2ME-A-0001` | **A** | Courant Algebroid C-Bracket Symmetry & Exact Jacobiator: [X,Y]_C = -[Y,X]_C with vanishing vector projection of Jacobiator. | [`Card10.lean & Card13.lean`](prove2me_engine/specs/Specs/Card10.lean & Card13.lean) | K3T2-A-0001 |
| `PROVE2ME-A-0002` | **A** | Double Field Theory O(d,d) Invariant Bilinear Pairing & B-Twist: (e^B)^T eta (e^B) = eta for skew 2-form B. | [`Card02.lean & Card04.lean`](prove2me_engine/specs/Specs/Card02.lean & Card04.lean) | PROVE2ME-A-0001 |
| `PROVE2ME-A-0003` | **A** | Generalized Metric Duality & Positivity: H * eta * H = eta and X^T H X > 0 on non-zero generalized vectors. | [`Card06.lean & Card07.lean`](prove2me_engine/specs/Specs/Card06.lean & Card07.lean) | PROVE2ME-A-0002 |
| `PROVE2ME-A-0004` | **A** | Strong Section Condition & DFT Ricci Reduction: eta^MN d_M Phi d_N Psi = 0 and R_DFT reduction to NS-NS effective curvature. | [`Card14.lean & Card19.lean`](prove2me_engine/specs/Specs/Card14.lean & Card19.lean) | PROVE2ME-A-0002 |
| `PROVE2ME-A-0005` | **A** | Buscher T-Duality Inversion, Dilaton Invariance & Fixed-Point Rigidity: 2d' = 2d and unique fixed point at R = sqrt(alpha'). | [`Card24.lean, Card26.lean, Card27.lean`](prove2me_engine/specs/Specs/Card24.lean, Card26.lean, Card27.lean) | PROVE2ME-A-0003 |
| `PROVE2ME-A-0006` | **A** | K3 Calabi-Yau Geometry, Dirac Index = 2 & Mukai-M24 Moonshine Bridge: MukaiRank = 24 with Mathieu M24 group action. | [`Card28.lean, Card33.lean, Card36.lean`](prove2me_engine/specs/Specs/Card28.lean, Card33.lean, Card36.lean) | PROVE2ME-A-0005 |
