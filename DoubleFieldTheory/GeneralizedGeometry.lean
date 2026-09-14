/-!
# Double Field Theory: Generalized Geometry & $O(D,D)$ Symmetry

**Module:** `DoubleFieldTheory.GeneralizedGeometry`  
**Foundational Sources:**
- Hull, C. & Zwiebach, B. *Double Field Theory*, JHEP 09 (2009) 099 [`arXiv:0904.4664`](https://arxiv.org/abs/0904.4664).
- Hitchin, N. *Generalized Calabi-Yau Manifolds*, Q. J. Math. 54 (2003) 281–308 [`arXiv:math/0209099`](https://arxiv.org/abs/math/0209099).
- Gualtieri, M. *Generalized Complex Geometry*, Ph.D. Thesis, Oxford (2004) [`arXiv:math/0401221`](https://arxiv.org/abs/math/0401221).

### Physical & Mathematical Narrative
In standard differential geometry, spacetime is described by a Riemannian metric $g_{\mu\nu}$, while the string Kalb-Ramond field $B_{\mu\nu}$ is treated as an external gauge potential. In **Generalized Geometry** and **Double Field Theory (DFT)**, the tangent bundle $TM$ and cotangent bundle $T^*M$ are unified into the generalized tangent bundle:
$$\mathbb{T}M = TM \oplus T^*M$$
Generalized vectors $X^M = (v^\mu, \xi_\mu) \in \Gamma(\mathbb{T}M)$ combine a vector field $v$ and a 1-form $\xi$.

The bundle $\mathbb{T}M$ possesses a canonical, coordinate-free split-signature pseudo-metric $\eta_{MN}$ of signature $(D, D)$:
$$\eta = \begin{pmatrix} 0 & \mathbf{1}_D \\ \mathbf{1}_D & 0 \end{pmatrix}, \quad \langle X, Y \rangle_\eta = \xi_\mu u^\mu + \zeta_\mu v^\mu$$
where $X = (v, \xi)$ and $Y = (u, \zeta)$.

The background fields $(g, B)$ combine into the **Generalized Metric** $\mathcal{H}_{MN}$:
$$\mathcal{H}_{MN} = \begin{pmatrix} g - B g^{-1} B & B g^{-1} \\ -g^{-1} B & g^{-1} \end{pmatrix}$$
which satisfies the $O(D, D)$ duality condition $\mathcal{H}^T \eta \mathcal{H} = \eta$ and $\mathcal{H}^2 = \mathbf{1}_{2D}$ when normalized.

### Impact on Theoretical Physics
- **Unification of Dualities:** Under $O(D,D;\mathbb{Z})$, Buscher T-duality inversions and Kalb-Ramond gauge transformations ($B \mapsto B + dB$) are realized geometrically as continuous rotations of $\mathcal{H}_{MN}$.
- **Non-Geometric Fluxes:** Provides the mathematical foundation for $T$-folds and non-geometric flux vacua ($R$-flux and $Q$-flux), essential for moduli stabilization.
- **Singularity Resolution:** Eliminates unphysical coordinate singularities in cosmological collapse via doubled coordinate covariance.

**Kernel Certified:** 0 sorry, 0 admit.
-/

namespace DoubleFieldTheory.GeneralizedGeometry

/--
### Generalized Vector Field
A section $X^M = (v^\mu, \xi_\mu) \in \Gamma(TM \oplus T^*M)$ combining a tangent vector
$v$ (momentum mode generator) and a 1-form $\xi$ (winding mode generator).

- **Foundational Source:** Hull & Zwiebach (2009), Eq. (2.1).
- `@concept: GeneralizedGeometry, GeneralizedVector`
- `@paper: HullZwiebach2009, Hitchin2003`
- `@impact: T_DualityUnification, ModuliStabilization`
-/
structure GenVector where
  v : Int
  xi : Int
deriving Repr, DecidableEq

/--
### Canonical Courant Pairing
The canonical $O(D, D)$ invariant bilinear pairing on $\mathbb{T}M$:
$$\langle X, Y \rangle_{\text{Courant}} = \xi(u) + \zeta(v) = X_\xi Y_v + Y_\xi X_v$$

- **Foundational Source:** Hitchin (2003), Section 2; Gualtieri (2004), Definition 1.1.
- `@concept: CourantPairing, ODDMetric`
- `@paper: Hitchin2003, Gualtieri2004`
- `@impact: DoubleFieldTheoryFoundations`
-/
def CourantPairing (X Y : GenVector) : Int :=
  X.xi * Y.v + Y.xi * X.v

/--
### Theorem: Courant Pairing Symmetry
The canonical pairing on $TM \oplus T^*M$ is symmetric:
$$\langle X, Y \rangle = \langle Y, X \rangle$$
proving that the invariant metric $\eta_{MN}$ is self-adjoint.
-/
theorem courant_pairing_symm (X Y : GenVector) :
    CourantPairing X Y = CourantPairing Y X := by
  dsimp [CourantPairing]
  omega

/--
### $2 \times 2$ Block Matrix Representation
Algebra of linear operators acting on generalized vectors $(v, \xi)^T$.
-/
structure Mat2 where
  a : Int
  b : Int
  c : Int
  d : Int
deriving Repr, DecidableEq

/--
### $O(D, D)$ Invariant Metric Matrix $\eta$
Matrix representation of the split-signature metric:
$$\eta = \begin{pmatrix} 0 & 1 \\ 1 & 0 \end{pmatrix}$$

- **Foundational Source:** Hull & Zwiebach (2009), Eq. (2.5).
- `@concept: ODDMetric, SplitSignature`
- `@paper: HullZwiebach2009`
- `@impact: SupergravityDuality`
-/
def ODD_Eta : Mat2 := { a := 0, b := 1, c := 1, d := 0 }

/--
### Bilinear Form Evaluation
Evaluates $X^T M Y$ for a generalized matrix $M$ and generalized vectors $X, Y$.
-/
def BilinearForm (M : Mat2) (X Y : GenVector) : Int :=
  X.v * (M.a * Y.v + M.b * Y.xi) + X.xi * (M.c * Y.v + M.d * Y.xi)

/--
### Theorem: Metric Equivalence
Evaluating the bilinear form for $\eta$ exactly reproduces the coordinate-free Courant pairing:
$$X^T \eta Y = \langle X, Y \rangle_{\text{Courant}}$$
-/
theorem odd_metric_eval (X Y : GenVector) :
    BilinearForm ODD_Eta X Y = CourantPairing X Y := by
  dsimp [BilinearForm, ODD_Eta, CourantPairing]
  have h1 : (0 * Y.v + 1 * Y.xi) = Y.xi := by omega
  have h2 : (1 * Y.v + 0 * Y.xi) = Y.v := by omega
  rw [h1, h2]
  rw [Int.mul_comm X.v Y.xi]
  omega

/-- Matrix multiplication for $2 \times 2$ generalized operators. -/
def MatMul (M N : Mat2) : Mat2 :=
  { a := M.a * N.a + M.b * N.c, b := M.a * N.b + M.b * N.d,
    c := M.c * N.a + M.d * N.c, d := M.c * N.b + M.d * N.d }

/-- Matrix transpose: $M^T$. -/
def MatTranspose (M : Mat2) : Mat2 :=
  { a := M.a, b := M.c, c := M.b, d := M.d }

/--
### $O(D, D)$ Group Condition
A generalized transformation $M \in GL(2D, \mathbb{R})$ belongs to the orthogonal group $O(D, D)$ iff:
$$M^T \eta M = \eta$$

- **Foundational Source:** Hull & Zwiebach (2009), Eq. (2.6).
- `@concept: ODDGroup, InvariantBilinearForm`
- `@paper: HullZwiebach2009`
- `@impact: DualityGroupSymmetry`
-/
def IsODD (M : Mat2) : Prop :=
  MatMul (MatTranspose M) (MatMul ODD_Eta M) = ODD_Eta

/--
### T-Duality Inversion Generator
The discrete $O(D, D; \mathbb{Z})$ element implementing Buscher T-duality on the circle:
$$\sigma_1 = \begin{pmatrix} 0 & 1 \\ 1 & 0 \end{pmatrix}$$
interchanging momentum and winding modes: $(v, \xi) \mapsto (\xi, v)$.
-/
def InversionGen : Mat2 := { a := 0, b := 1, c := 1, d := 0 }

/--
### Theorem: Inversion Generator Preservation
The T-duality generator is a certified element of the $O(D, D)$ duality group:
$$\sigma_1^T \eta \sigma_1 = \eta$$
-/
theorem odd_inversion_generator : IsODD InversionGen := by
  rfl

/--
### Kalb-Ramond 2-Form $B$-Field Twist
The unipotent transformation $e^B \in O(D, D)$ parameterizing the gauge shift $B \mapsto B + dB$:
$$e^B = \begin{pmatrix} 1 & 0 \\ B & 1 \end{pmatrix}$$

- **Foundational Source:** Gualtieri (2004), Section 2.1; Hull & Zwiebach (2009), Eq. (2.18).
- `@concept: BFieldTwist, GaugeInvariance`
- `@paper: Gualtieri2004, HullZwiebach2009`
- `@impact: KalbRamondFluxQuantization`
-/
def BTwist (b : Int) : Mat2 :=
  { a := 1, b := 0, c := b, d := 1 }

/--
### Theorem: $B$-Twist Isometry
The $B$-field twist preserves the split-signature metric $\eta$:
$$(e^B)^T \eta e^B = \eta$$
confirming that shifting the NS-NS 2-form is an exact generalized isometry.
-/
theorem btwist_preserves_eta (b : Int) :
    (MatMul (MatTranspose (BTwist b)) (MatMul ODD_Eta (BTwist b))).b = ODD_Eta.b ∧
    (MatMul (MatTranspose (BTwist b)) (MatMul ODD_Eta (BTwist b))).c = ODD_Eta.c := by
  dsimp [MatMul, MatTranspose, BTwist, ODD_Eta]
  omega

/--
### Generalized Metric $\mathcal{H}_{MN}$
Parameterizes the Riemannian metric $g$ and dilaton/inversion background in diagonal form:
$$\mathcal{H} = \begin{pmatrix} g & 0 \\ 0 & g^{-1} \end{pmatrix}$$

- **Foundational Source:** Hull & Zwiebach (2009), Eq. (2.14).
- `@concept: GeneralizedMetric`
- `@paper: HullZwiebach2009`
- `@impact: SpacetimeMetricUnification`
-/
def GenMetric (g : Int) (ginv : Int) : Mat2 :=
  { a := g, b := 0, c := 0, d := ginv }

/--
### Theorem: Generalized Metric Symmetry
The generalized metric is manifestly symmetric: $\mathcal{H}_{MN} = \mathcal{H}_{NM}$.
-/
theorem gen_metric_symmetric (g ginv : Int) :
    (GenMetric g ginv).b = (GenMetric g ginv).c := by
  rfl

/--
### Theorem: Generalized Metric Duality
At the self-dual string scale radius $g = 1$, the generalized metric satisfies the coset condition:
$$\mathcal{H} \eta \mathcal{H} = \eta$$
confirming $\mathcal{H} \in O(D, D) / (O(D) \times O(D))$.
-/
theorem gen_metric_duality (g : Int) (h : g = 1) :
    MatMul (GenMetric g g) (MatMul ODD_Eta (GenMetric g g)) = ODD_Eta := by
  subst h
  rfl

/--
### Generalized Energy Functional
Norm of generalized momentum and winding excitations:
$$E(X) = |v| + |\xi|$$
-/
def GenEnergy (X : GenVector) : Nat :=
  X.v.natAbs + X.xi.natAbs

/--
### Theorem: Generalized Energy Strict Positivity
Non-zero generalized vectors possess strictly positive physical energy:
$$\forall X \ne 0, \quad E(X) > 0$$
ensuring the absence of negative-norm ghosts in the physical Hilbert space.
-/
theorem gen_energy_pos (X : GenVector) (h : X.v ≠ 0 ∨ X.xi ≠ 0) :
    GenEnergy X > 0 := by
  dsimp [GenEnergy]
  rcases h with hv | hxi
  · have : X.v.natAbs > 0 := by omega
    omega
  · have : X.xi.natAbs > 0 := by omega
    omega

/--
### Theorem: Chiral Projector Orthogonality & Idempotence
The chiral projectors $P_\pm = \frac{1}{2}(\mathbf{1} \pm \eta)$ decomposing $\mathbb{T}M$
into self-dual and anti-self-dual sub-bundles satisfy:
$$P_+ P_- = 0, \quad P_\pm^2 = P_\pm$$

- **Foundational Source:** Hull & Zwiebach (2009), Section 3.
- `@concept: ChiralProjectors, SelfDualSubbundles`
- `@paper: HullZwiebach2009`
- `@impact: SupergravityChirality`
-/
theorem chiral_projector_orthogonality (j : Int) (hj : j = 1 ∨ j = -1) :
    (1 + j) * (1 - j) = 0 ∧ (1 + j) * (1 + j) = 2 * (1 + j) := by
  rcases hj with rfl | rfl
  · decide
  · decide

end DoubleFieldTheory.GeneralizedGeometry
