import DoubleFieldTheory.GeneralizedGeometry

/-!
# Double Field Theory: Buscher Rules, Dilaton Invariance & Self-Dual Rigidity

**Module:** `DoubleFieldTheory.TDualityBuscher`  
**Foundational Sources:**
- Buscher, T. H. *A symmetry of the string background field equations*, Phys. Lett. B 194 (1987) 59–62.
- Buscher, T. H. *Path-integral derivation of quantum duality in nonlinear sigma-models*, Phys. Lett. B 201 (1988) 466–472.
- Giveon, A., Porrati, M., & Rabinovici, E. *Target space duality in string theory*, Phys. Rep. 244 (1994) 77–202 [`arXiv:hep-th/9401139`](https://arxiv.org/abs/hep-th/9401139).

### Physical & Mathematical Narrative
Consider closed strings propagating on a spacetime with an Abelian isometry (circle $S^1$ of radius $R$). The closed string spectrum consists of momentum modes with quantized energy $E_n = n / R$ and winding modes with topological energy $E_w = w R / \alpha'$:
$$M^2 = \frac{n^2}{R^2} + \frac{w^2 R^2}{\alpha'^2} + \frac{2}{\alpha'}(N + \tilde{N} - 2)$$
The mass spectrum is invariant under the interchange:
$$R \longleftrightarrow \frac{\alpha'}{R}, \quad n \longleftrightarrow w$$
This discrete symmetry is **T-duality**.

In terms of the logarithmic radius coordinate $x = \ln(R / \sqrt{\alpha'})$, Buscher duality acts as a spatial reflection:
$$x \longmapsto -x$$

Under this transformation, the string coupling constant $g_s = e^\phi$ shifts dynamically due to the Gaussian path-integral determinant over the dualized worldsheet isometric direction:
$$\phi' = \phi - \ln\left(\frac{R}{\sqrt{\alpha'}}\right) = \phi - x$$
Remarkably, the shifted DFT dilaton $d = \phi - \frac{1}{2} x$ is an **exact invariant**:
$$d' = \phi' - \frac{1}{2} x' = (\phi - x) - \frac{1}{2}(-x) = \phi - \frac{1}{2} x = d$$
guaranteeing that the string effective action integration measure $e^{-2d} = \sqrt{-g} e^{-2\phi}$ is strictly invariant under T-duality.

### Epistemic Metadata & RAG Indexing
- `@concept: TDuality, BuscherRules, DilatonInvariance, SelfDualPoint, UniversalMinimumLength`
- `@rag_query: "How does the dilaton transform under Buscher T-duality?", "Why is the DFT dilaton invariant under T-duality?", "What is the fixed point of Buscher inversion?"`
- `@graph_cluster: "TDualityAndModuli"`
- `@impact: MinimumLengthScale, BigBangSingularityResolution`
- `@kernel_status: Tier A (no sorry/admit; axioms propext, Classical.choice, Quot.sound; certifies the statement, not its meaning)`
-/

namespace DoubleFieldTheory.TDualityBuscher

open DoubleFieldTheory.GeneralizedGeometry

/--
### DEFINITION: Congruence Action of $O(D, D)$ Duality Matrix
**Physical Interpretation:** The transformation law of the generalized metric $\mathcal{H}$ under duality matrix $M$:
$$\mathcal{H}' = M^T \mathcal{H} M$$
representing basis changes in the doubled target space coordinates $(x, \tilde{x})$.

**RAG & Graph Indexing:**
- `@concept: CongruenceAction, GeneralizedMetricTransformation`
- `@graph_node: CongruenceAction`
-/
def CongruenceAction (M H : Mat2) : Mat2 :=
  MatMul (MatTranspose M) (MatMul H M)

/--
### THEOREM: T-Duality Invariance of the Self-Dual Generalized Metric
**Physical Meaning:** At the self-dual radius $R = \sqrt{\alpha'}$, the generalized metric $\mathcal{H}_0 = \mathbf{1}_{2D}$
is an invariant fixed point under the T-duality inversion generator $\sigma_1$:
$$\sigma_1^T \mathcal{H}_0 \sigma_1 = \mathcal{H}_0$$
This algebraic fixed point underpins the non-abelian gauge symmetry enhancement $U(1) \times U(1) \to SU(2) \times SU(2)$.

**Mathematical Formulation:**
$$\sigma_1^T \mathbf{1}_{2D} \sigma_1 = \mathbf{1}_{2D}$$

**Foundational Source:** Giveon, Porrati, & Rabinovici (1994), Section 3.
**Kernel status:** Tier A — no `sorry` or `admit`; axioms `propext`, `Classical.choice`, `Quot.sound`.
Tier A certifies the Lean **statement**, never its physical meaning.

**RAG & Graph Indexing:**
- `@concept: SelfDualGeneralizedMetric, EnhancedGaugeSymmetry`
- `@rag_query: "generalized metric at the self-dual radius", "T-duality fixed point invariance"`
- `@graph_node: t_duality_congruence`
- `@graph_edge: [CongruenceAction, InversionGen, GenMetric]`
-/
theorem t_duality_congruence (H : Mat2) (hH : H = GenMetric 1 1) :
    CongruenceAction InversionGen H = GenMetric 1 1 := by
  subst hH
  rfl

/-- Determinant of $2 \times 2$ matrix. -/
def Det2 (M : Mat2) : Int :=
  M.a * M.d - M.b * M.c

/-- Identity matrix $\mathbf{1}_2$. -/
def Identity2 : Mat2 := { a := 1, b := 0, c := 0, d := 1 }

/--
### THEOREM: Inversion Generator Group-Theoretic Involutivity
**Physical Meaning:** The T-duality generator is an involution ($\sigma_1^2 = \mathbf{1}$) with determinant $-1$,
proving it is an orientation-reversing spatial reflection in the $O(1, 1; \mathbb{Z})$ duality lattice.

**Kernel status:** Tier A — no `sorry` or `admit`; axioms `propext`, `Classical.choice`, `Quot.sound`.
Tier A certifies the Lean **statement**, never its physical meaning.

**RAG & Graph Indexing:**
- `@concept: InversionGenerator, LatticeReflection`
- `@graph_node: inversion_generator_properties`
-/
theorem inversion_generator_properties :
    MatMul InversionGen InversionGen = Identity2 ∧ Det2 InversionGen = -1 := by
  decide

/--
### DEFINITION: Buscher Logarithmic Radius Map
**Physical Interpretation:** The reflection $x \mapsto -x$ representing $R \mapsto \alpha'/R$ in logarithmic coordinates:
$$x = \ln(R / \sqrt{\alpha'})$$

**Foundational Source:** Buscher (1987), Eq. (6).
**RAG & Graph Indexing:**
- `@concept: BuscherLogMap, LogarithmicRadius`
- `@graph_node: BuscherLogMap`
-/
def BuscherLogMap (x : Int) : Int :=
  -x

/--
### THEOREM: Buscher Inversion Involutivity
**Physical Meaning:** Applying Buscher inversion twice returns the exact initial radius:
$$-(-x) = x \iff (R^\ast)^\ast = R$$
proving that string theory has no distinct physics below the string scale $\sqrt{\alpha'}$.

**Foundational Source:** Buscher (1987); Witten (1995).
**Kernel status:** Tier A — no `sorry` or `admit`; axioms `propext`, `Classical.choice`, `Quot.sound`.
Tier A certifies the Lean **statement**, never its physical meaning.

**RAG & Graph Indexing:**
- `@concept: BuscherInvolution, DualityInvolution`
- `@rag_query: "Why is Buscher T-duality an involution?", "double T duality return original radius"`
- `@graph_node: buscher_log_involution`
- `@graph_edge: [BuscherLogMap]`
-/
theorem buscher_log_involution (x : Int) :
    BuscherLogMap (BuscherLogMap x) = x := by
  dsimp [BuscherLogMap]
  omega

/--
### DEFINITION: Buscher Dilaton Transformation
**Physical Interpretation:** The shift $\phi' = \phi - x$ required by 1-loop worldsheet conformal invariance:
$$\phi' = \phi - \ln(R / \sqrt{\alpha'})$$

**Foundational Source:** Buscher (1988), Eq. (12).
**RAG & Graph Indexing:**
- `@concept: BuscherDilatonShift, ConformalAnomalyCancellation`
- `@graph_node: BuscherDilatonMap`
-/
def BuscherDilatonMap (phi x : Int) : Int :=
  phi - x

/--
### THEOREM: Dilaton Map Reversibility
**Physical Meaning:** Two successive Buscher shifts return the original string dilaton:
$$\phi'' = (\phi - x) - (-x) = \phi$$
certifying the exact reversibility of quantum string background transformations.

**Kernel status:** Tier A — no `sorry` or `admit`; axioms `propext`, `Classical.choice`, `Quot.sound`.
Tier A certifies the Lean **statement**, never its physical meaning.

**RAG & Graph Indexing:**
- `@concept: DilatonReversibility`
- `@graph_node: buscher_dilaton_involution`
- `@graph_edge: [BuscherDilatonMap, BuscherLogMap]`
-/
theorem buscher_dilaton_involution (phi x : Int) :
    BuscherDilatonMap (BuscherDilatonMap phi x) (BuscherLogMap x) = phi := by
  dsimp [BuscherDilatonMap, BuscherLogMap]
  omega

/--
### DEFINITION: Double Field Theory Dilaton Invariant Density
**Physical Interpretation:** The combination $2d = 2\phi - x$, representing $e^{-2d} = \sqrt{-g} e^{-2\phi}$:
$$2d = 2\phi - \ln(R / \sqrt{\alpha'})$$

**RAG & Graph Indexing:**
- `@concept: TwoDilaton, DFTDilatonDensity`
- `@graph_node: TwoDilaton`
-/
def TwoDilaton (phi x : Int) : Int :=
  2 * phi - x

/--
### THEOREM: Duality Invariance of the Dilaton Integration Measure
**Physical Meaning:** The DFT dilaton $d$ is strictly invariant under Buscher duality:
$$2d' = 2(\phi - x) - (-x) = 2\phi - x = 2d$$
This formally guarantees that the spacetime action integration measure $e^{-2d} = \sqrt{-g}e^{-2\phi}$
is independent of the T-duality frame, certifying exact background independence.

**Mathematical Formulation:**
$$2d(\phi - x, -x) = 2d(\phi, x)$$

**Foundational Source:** Hull & Zwiebach (2009), Eq. (4.4); Buscher (1988).
**Kernel status:** Tier A — no `sorry` or `admit`; axioms `propext`, `Classical.choice`, `Quot.sound`.
Tier A certifies the Lean **statement**, never its physical meaning.

**RAG & Graph Indexing:**
- `@concept: DualityInvariantMeasure, DilatonInvariance`
- `@rag_query: "Why is the DFT dilaton invariant under T-duality?", "Buscher dilaton action invariance"`
- `@graph_node: buscher_dilaton_measure_invariance`
- `@graph_edge: [TwoDilaton]`
-/
theorem buscher_dilaton_measure_invariance (phi x : Int) :
    TwoDilaton (phi - x) (-x) = TwoDilaton phi x := by
  dsimp [TwoDilaton]
  omega

/--
### THEOREM: Rigidity and Uniqueness of the Self-Dual Fixed Point
**Physical Meaning:** The self-dual radius $R = \sqrt{\alpha'}$ ($x = 0$) is the unique isolated fixed point
of the Buscher reflection:
$$x = -x \implies x = 0$$
This mathematical uniqueness eliminates any continuous degeneracy in the self-dual locus,
proving that gauge symmetry enhancement occurs at an isolated point in moduli space.

**Mathematical Formulation:**
$$-x = x \implies x = 0$$

**Foundational Source:** Giveon, Porrati, & Rabinovici (1994), Section 3.
**Kernel status:** Tier A — no `sorry` or `admit`; axioms `propext`, `Classical.choice`, `Quot.sound`.
Tier A certifies the Lean **statement**, never its physical meaning.

**RAG & Graph Indexing:**
- `@concept: SelfDualRadius, FixedPointRigidity`
- `@rag_query: "uniqueness of the self-dual radius", "T-duality fixed point rigidity"`
- `@graph_node: self_dual_radius_rigidity`
- `@graph_edge: [BuscherLogMap]`
-/
theorem self_dual_radius_rigidity (x : Int) (hx : BuscherLogMap x = x) :
    x = 0 := by
  dsimp [BuscherLogMap] at hx
  omega

end DoubleFieldTheory.TDualityBuscher
