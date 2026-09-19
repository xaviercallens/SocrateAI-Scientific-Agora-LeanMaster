/-
Stream 8 · P8.4c — the `SO(44)` point (see `K3Enhancement.lean` for the statement, sources and reading).

Kept in its own file because the kernel evaluation of the root check needs about 14 GB, and the memory of a
file's `decide +kernel` calls accumulates.
-/
import DualScaleDyons.K3Enhancement

namespace DualScaleDyons.K3Enhancement

/-- **The `SO(44)` point of K3 × T².** `4·C(22, 2) = 924` roots of `D₂₂`, distinct by construction as above, orthogonal
to the 6-plane; the positive block gives the 60 roots of `D₆`. -/
theorem so44_point :
    enhancementCheck 6 = true ∧ (rootsD 28 6 22).length = 924 ∧
      (rootsD 28 0 6).length = 60 := by
  decide +kernel

end DualScaleDyons.K3Enhancement
