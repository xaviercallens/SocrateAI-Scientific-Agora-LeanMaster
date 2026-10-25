"""The phase-2 gate must refuse every Lean escape hatch that compiles, not only `sorry`."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from workflowphase2 import count_escape_hatches  # noqa: E402


def test_each_escape_hatch_is_counted():
    src = """
theorem a : 1 = 1 := by sorry
theorem b : 2 = 2 := by admit
axiom cheat : False
theorem c : 3 = 3 := by native_decide
@[implemented_by fastImpl] def slow : Nat := 0
@[extern "c_fn"] opaque cFn : Nat → Nat
"""
    h = count_escape_hatches(src)
    assert h == {"sorry": 1, "admit": 1, "axiom": 1, "native_decide": 1, "implemented_by": 1, "extern": 1}


def test_prose_in_comments_is_not_flagged():
    src = """
/-! **Kernel Certified:** 0 sorry, 0 admit, no axiom, no native_decide. -/
-- uses no sorry and no axiom
theorem ok : 1 + 1 = 2 := rfl
"""
    assert sum(count_escape_hatches(src).values()) == 0


def test_axiom_must_be_a_declaration_not_a_word():
    # `propext` axioms in an explanation, or a field called `axiom_count`, are not declarations.
    src = "def axiom_count : Nat := 3\ntheorem t : axiom_count = 3 := rfl\n"
    assert count_escape_hatches(src)["axiom"] == 0
    assert count_escape_hatches("private axiom secret : False\n")["axiom"] == 1
