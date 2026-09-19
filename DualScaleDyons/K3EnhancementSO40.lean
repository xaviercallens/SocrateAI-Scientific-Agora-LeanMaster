/-
Stream 8 · P8.4c — the `SO(40)` point (see `K3Enhancement.lean` for the statement, sources and reading).

Kept in its own file because the kernel evaluation of the root check needs about 11 GB, and the memory of a
file's `decide +kernel` calls accumulates.
-/
import DualScaleDyons.K3Enhancement

namespace DualScaleDyons.K3Enhancement

/-- **The `SO(40)` point of the K3 factor.** The enumeration `rootsD` has `4·C(20, 2) = 760` entries, one for each
`(i < j, signs)`, so they are pairwise distinct by construction (a vector with two non-zero entries determines its
support and signs; not kernel-checked, because `Nodup` on 760 integer lists exceeds 14 GB in the kernel). All lie in
`Γ₄`, are orthogonal to `Π` and have norm `−2`, and the positive block gives 24 roots of `D₄`. -/
theorem so40_point :
    enhancementCheck 4 = true ∧ (rootsD 24 4 20).length = 760 ∧
      (rootsD 24 0 4).length = 24 := by
  decide +kernel

end DualScaleDyons.K3Enhancement
