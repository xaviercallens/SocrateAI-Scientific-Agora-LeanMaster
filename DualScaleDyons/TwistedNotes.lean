/-
Stream 5 · reading note made checkable — the sign of `c_g(−1)`.

Cheng (`papers/foundations/1005_5415.txt`, l. 960) writes `c_g(−1) = −2` when deriving the pole
factorisation (3.11). In his own formula (2.5), `Z_{g_p} = (2/(p+1))φ₀,₁ + …`, and in the normalisation
used throughout this repository (`Z = 2φ₀,₁ = 2y + 20 + 2y⁻¹ + O(q)`), the coefficient is `+2`. The twisted
products of `TwistedDyons.lean` use `+2`, and they recover the untwisted product (`twisted_product_untwisted`)
and the twined Göttsche numbers (`twisted_goettsche`) — so `+2` is the consistent value here.

### What is proved (Tier A)
* `twisted_genus_q0`: for all 26 classes, the `q⁰` term of `Z_g` is `2y + (χ_g − 4) + 2y⁻¹`.
* `c_minus_one`: hence `c_g(−1) = +2` for every class (the polar coefficient that sets `h₁` in every
  Newton factor of the twisted product). The printed `−2` is therefore a sign convention or a misprint,
  not a property of the twisted genera used here.
-/
import DualScaleDyons.TwistedDyons

namespace DualScaleDyons

open DualScaleMoonshine

theorem twisted_genus_q0 :
    (List.range 26).all (fun j => Ser.eqB [((zTw j 4).getD 0 LP.zero)] [(-1, [2, chiShadow.getD j 0 - 4, 2])]) = true := by
  decide +kernel

theorem c_minus_one : (List.range 26).all (fun j => cTw j (-1) == 2) = true := by decide +kernel

end DualScaleDyons
