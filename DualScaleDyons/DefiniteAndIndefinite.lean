/-
Stream 8/9 bridge · G6 — why one question has a unique answer and the other has none.

Two questions in this programme are posed in the same language and behave in opposite ways. *Which surface does
the smallest black hole pick?* has one answer (`D = −3`, `T_S = A₂`, `τ = ω + 1`; `AttractorCharges.lean`).
*How many flux configurations does the budget permit?* has infinitely many, and keeps having infinitely many
after the orbifold projection and under every quantisation factor (`DualScaleStream2/Flux/`). Both are questions
about integer vectors in a lattice. Why does one of them decide?

The tempting answer — "the black hole problem has more structure" — is wrong, and this file shows it is wrong in
the sharpest available way: **the very lattice in which the black hole charges live already contains infinitely
many vectors of the same norm.** The charge lattice `U ⊕ U` is indefinite. It has as little determinacy as the
flux lattice does.

### The resolution
Definiteness is not a property of the ambient lattice. It is a condition the **physics** imposes on the object
being counted. A black hole with a horizon requires its charge *form* `Q_{p,q}` to be positive definite
(Moore (3.4)–(3.5); supergravity needs `p² > 0` and `Q_{p,q} > 0`), and a definite form has a minimum, attained
by finitely many classes. The flux problem imposes no such condition — until supersymmetry does, through
imaginary self-duality, which is exactly where `Flux/ISDFiniteness.lean` finds its finiteness.

So the two outcomes are not a puzzle about how hard each problem is. They are a consequence of which problem
carries a definiteness condition. Stated once: **arithmetic decides when, and only when, the physics hands it a
definite form.**

### What is proved (Tier A)
* `roots_norm_two`, `roots_injective`: in the charge lattice `U ⊕ U`, the family `v(n) = (n, 1, 1 − n, 1)` has
  norm exactly `2` for **every** integer `n`, and `n ↦ v(n)` is injective. Infinitely many vectors share one
  invariant, in the same lattice the attractor charges live in.
* `ambient_is_indefinite`: that lattice carries vectors of norm `+2` and of norm `−2`, so it is indefinite — the
  structural reason the family above can exist at all.
* `definite_pair_has_a_floor`: by contrast, once a *pair* `(p, q)` is required to span a positive definite form,
  the discriminant satisfies `D ≤ −3` (`AttractorCharges.discriminant_gap`), so a smallest case exists.
* `the_dichotomy`: the two facts side by side — one vector's norm does not determine it, one definite pair's
  form does have a minimum.

### Tier C, and the limit of the reading
That the physical condition on a black hole is definiteness of `Q_{p,q}` is Tier L (Moore, pinned in
`AttractorCharges.lean`); that supersymmetry is what supplies definiteness on the flux side is Tier L (GKP,
pinned in `Flux/ISDFiniteness.lean`). What this file adds is the arithmetic that makes the contrast exact. It
does **not** prove that every selection question in the programme is of one of these two types, and it is not a
statement about vacua.
-/
import DualScaleDyons.AttractorCharges

namespace DualScaleDyons.DefiniteAndIndefinite

open DualScaleDyons.AttractorCharges

/-- The norm of a vector of `U ⊕ U`. -/
def norm (x : Fin 4 → ℤ) : ℤ := pair x x

/-- A one-parameter family in the charge lattice. -/
def root (n : ℤ) : Fin 4 → ℤ := ![n, 1, 1 - n, 1]

/-- **Infinitely many vectors of norm 2**, in the lattice where the attractor charges live. -/
theorem roots_norm_two (n : ℤ) : norm (root n) = 2 := by
  simp [norm, pair, root]
  ring

theorem roots_injective : Function.Injective root := by
  intro m n h
  have := congrFun h 0
  simpa [root] using this

/-- The ambient lattice is indefinite: it carries both signs of the norm. -/
theorem ambient_is_indefinite :
    norm ![1, 1, 0, 0] = 2 ∧ norm ![1, -1, 0, 0] = -2 := by
  constructor <;> simp [norm, pair]

/-- By contrast, a **definite** pair has a floor: positivity of the form forces `4ac − b² ≥ 3`, so the
discriminant `D = b² − 4ac` satisfies `D ≤ −3` and a smallest case exists. -/
theorem definite_pair_has_a_floor (a b c : ℤ) (h : 0 < 4 * a * c - b * b) :
    b * b - 4 * a * c ≤ -3 := by
  have := (discriminant_gap a b c h).1
  linarith

/-- **The dichotomy, in one statement.** One vector's norm does not determine the vector — infinitely many share
it. One *definite* pair's form does have a minimum. Same lattice; the difference is the definiteness condition,
and the physics is what supplies it. -/
theorem the_dichotomy :
    (∀ n : ℤ, norm (root n) = 2) ∧ Function.Injective root ∧
      (∀ a b c : ℤ, 0 < 4 * a * c - b * b → b * b - 4 * a * c ≤ -3) :=
  ⟨roots_norm_two, roots_injective, definite_pair_has_a_floor⟩

end DualScaleDyons.DefiniteAndIndefinite
