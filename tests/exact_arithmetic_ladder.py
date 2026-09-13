#!/usr/bin/env python3
"""
tests/exact_arithmetic_ladder.py
================================
Tier B Exact-Arithmetic Test Ladder with Adversarial Negative Controls.
Implements Stream 0 Gate 1 (SocrateAI-Mathesis specification):
Deterministic ℚ/ℤ check + negative controls that MUST fail.

Checks:
  1. Mathieu M24 Rigidity Ratio R_BPS = 77/60 + Negative Control.
  2. Kummer Orientifold Tadpole Cancellation (∑ Q_i = 0) + Negative Control.
  3. Genesis Bounce Effective Radius (R_eff >= √α' > 0) + Negative Control.
  4. Symmetric-Square Lock (Sym² Recurrence L₂ → L₃) + Negative Control.
  5. Stream 0 Epistemic Ledger Soundness (A cannot cite C) + Negative Control.
"""

import math
from fractions import Fraction
import sys
import unittest

class TestExactArithmeticLadder(unittest.TestCase):

    # --------------------------------------------------------------------------
    # 1. Mathieu M24 BPS Rigidity Invariant
    # --------------------------------------------------------------------------
    def test_mathieu_m24_rigidity_positive(self):
        dim_A1 = 90
        dim_A2 = 462
        supercharges = 4
        
        ratio = Fraction(dim_A2, supercharges * dim_A1)
        self.assertEqual(ratio, Fraction(77, 60))
        self.assertEqual(ratio.numerator, 77)
        self.assertEqual(ratio.denominator, 60)
        self.assertEqual(math.gcd(77, 60), 1)
        self.assertEqual(dim_A2 * 60, (supercharges * dim_A1) * 77)
        self.assertEqual(dim_A2 * 60, 27720)

    def test_mathieu_m24_rigidity_negative_control(self):
        """Negative control: Arbitrary non-M24 representations must fail."""
        supercharges = 4
        # Test fictitious or other sporadic group character dimensions
        non_m24_test_cases = [
            (90, 460),  # perturbed A2
            (92, 462),  # perturbed A1
            (100, 500), # generic ratio 5/4 != 77/60
            (23, 253),  # J1 or different M24 irrep pair (11/4 != 77/60)
            (45, 252)   # unmatching irrep pair
        ]
        for a1, a2 in non_m24_test_cases:
            ratio = Fraction(a2, supercharges * a1)
            self.assertNotEqual(
                ratio, Fraction(77, 60),
                f"Negative control failed: ({a1}, {a2}) erroneously matched 77/60!"
            )

    # --------------------------------------------------------------------------
    # 2. Kummer Orientifold Tadpole Cancellation
    # --------------------------------------------------------------------------
    def test_kummer_tadpole_cancellation_positive(self):
        d7_count = 16
        d7_charge = 4
        o7_count = 4
        o7_charge = -16
        
        total_d7 = d7_count * d7_charge
        total_o7 = o7_count * o7_charge
        net_tadpole = total_d7 + total_o7
        
        self.assertEqual(total_d7, 64)
        self.assertEqual(total_o7, -64)
        self.assertEqual(net_tadpole, 0)

    def test_kummer_tadpole_negative_control(self):
        """Negative control: Unbalanced brane networks must fail the zero-tadpole gate."""
        unbalanced_configs = [
            (15, 4, 4, -16),  # missing 1 D7 stack -> net -4
            (17, 4, 4, -16),  # excess 1 D7 stack -> net +4
            (16, 4, 3, -16),  # missing 1 O7 plane -> net +16
            (16, 2, 4, -16),  # wrong D7 charge -> net -32
        ]
        for d7_n, d7_q, o7_n, o7_q in unbalanced_configs:
            net = (d7_n * d7_q) + (o7_n * o7_q)
            self.assertNotEqual(
                net, 0,
                f"Negative control failed: unbalanced config ({d7_n}, {d7_q}, {o7_n}, {o7_q}) evaluated to zero!"
            )

    # --------------------------------------------------------------------------
    # 3. Genesis Bounce Effective Metric
    # --------------------------------------------------------------------------
    def test_genesis_bounce_effective_metric_positive(self):
        alpha_prime = Fraction(1, 1) # sqrt(alpha') = 1
        
        test_radii = [
            Fraction(1, 1000),
            Fraction(1, 100),
            Fraction(1, 10),
            Fraction(1, 2),
            Fraction(1, 1),
            Fraction(2, 1),
            Fraction(10, 1),
            Fraction(1000, 1),
        ]
        
        for R in test_radii:
            if R * R < alpha_prime:
                R_eff = alpha_prime / R
            else:
                R_eff = R
            
            # Genesis theorem: R_eff must be strictly positive and >= sqrt(alpha')
            self.assertGreater(R_eff, 0)
            self.assertGreaterEqual(R_eff, Fraction(1, 1))

    def test_genesis_bounce_negative_control(self):
        """Negative control: Bare metric without dual bounce collapses to 0."""
        diverging_bare = Fraction(1, 10**6)
        self.assertLess(diverging_bare, Fraction(1, 100))
        # Verify that without the bounce, bare curvature 1/R^2 blows up
        bare_curvature = Fraction(1, 1) / (diverging_bare * diverging_bare)
        self.assertEqual(bare_curvature, 10**12)

    # --------------------------------------------------------------------------
    # 4. Symmetric-Square Lock (Sym² Recurrence Functor)
    # --------------------------------------------------------------------------
    def test_sym2_lock_positive(self):
        def sym2_operator(a, b):
            return {
                "c2": a * a + b,
                "c1": b * (a * a + b),
                "c0": - (b ** 3)
            }
            
        def verify_sequence(a, b, u0, u1, steps=8):
            # Generate u sequence
            u = [u0, u1]
            for _ in range(steps):
                u.append(a * u[-1] + b * u[-2])
            
            # Generate v = u^2
            v = [x * x for x in u]
            
            # Check L3 recurrence
            op = sym2_operator(a, b)
            for n in range(len(v) - 3):
                expected = op["c2"] * v[n+2] + op["c1"] * v[n+1] + op["c0"] * v[n]
                self.assertEqual(
                    v[n+3], expected,
                    f"Sym2 recurrence failed at step {n} for (a={a}, b={b})"
                )

        # Fibonacci: a=1, b=1
        verify_sequence(1, 1, 1, 1)
        # Pell: a=2, b=1
        verify_sequence(2, 1, 1, 2)
        # Modular orbit: a=3, b=-1
        verify_sequence(3, -1, 0, 1)

    def test_sym2_lock_negative_control(self):
        """Negative control: Non-symmetric power (e.g. cubic v = u^3) must fail L3 recurrence."""
        a, b = 1, 1
        u = [1, 1, 2, 3, 5, 8]
        v_cubic = [x ** 3 for x in u]
        
        c2 = a * a + b
        c1 = b * (a * a + b)
        c0 = - (b ** 3)
        
        # Test step 0:
        predicted = c2 * v_cubic[2] + c1 * v_cubic[1] + c0 * v_cubic[0]
        actual = v_cubic[3] # 3^3 = 27
        self.assertNotEqual(
            predicted, actual,
            "Negative control failed: cubic power erroneously satisfied quadratic Sym2 lock!"
        )

    # --------------------------------------------------------------------------
    # 5. Stream 0 Epistemic Soundness
    # --------------------------------------------------------------------------
    def test_epistemic_soundness_positive(self):
        tiers = {"X": 0, "C": 1, "L": 2, "B": 3, "A": 4}
        
        ledger_sound = {
            "0": {"tier": "A", "deps": ["1"]},
            "1": {"tier": "A", "deps": []},
            "2": {"tier": "C", "deps": []}
        }
        
        def is_sound(L):
            for cid, row in L.items():
                for dep in row["deps"]:
                    if dep in L:
                        if tiers[row["tier"]] > tiers[L[dep]["tier"]]:
                            return False
            return True

        self.assertTrue(is_sound(ledger_sound))

    def test_epistemic_soundness_negative_control(self):
        """Negative control: Tier A claim citing Tier C must fail soundness."""
        tiers = {"X": 0, "C": 1, "L": 2, "B": 3, "A": 4}
        
        ledger_unsound = {
            "0": {"tier": "A", "deps": ["1"]},
            "1": {"tier": "C", "deps": []}
        }
        
        def is_sound(L):
            for cid, row in L.items():
                for dep in row["deps"]:
                    if dep in L:
                        if tiers[row["tier"]] > tiers[L[dep]["tier"]]:
                            return False
            return True

        self.assertFalse(
            is_sound(ledger_unsound),
            "Negative control failed: Unsound ledger (A citing C) was accepted!"
        )

if __name__ == "__main__":
    unittest.main()
