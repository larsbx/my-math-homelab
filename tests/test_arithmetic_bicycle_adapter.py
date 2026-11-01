"""Independent exact finite adapter: refuted ABC hypothesis stays refuted."""
from __future__ import annotations

from copy import deepcopy
import sys
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/"tools"))
from math_adapters.arithmetic_bicycle import (
    annihilator, arithmetic_signature_2x2, candidate_hull,
    checked_hull, determinant, lattice_index, verify_fixture,
)


def test_fixture():
    """Small local fixture is not an authoritative source replacement."""
    return {
        "schema": 1,
        "cases": [
            {"id": "index5-a1", "matrix": [[1, 1], [0, 5]],
             "columns": 2, "ambient_index": "5",
             "moduli": [5, 10, 25],
             "expected_orders": {"5": 1, "10": 1, "25": 5}},
            {"id": "index5-a2", "matrix": [[1, 2], [0, 5]],
             "columns": 2, "ambient_index": "5",
             "moduli": [5, 10, 25],
             "expected_orders": {"5": 5, "10": 5, "25": 5}},
            {"id": "scalar2", "matrix": [[2]], "columns": 1,
             "ambient_index": "2", "moduli": [2, 4],
             "expected_orders": {"2": 1, "4": 2}},
            {"id": "surjective-c13", "matrix": [[2, 3]],
             "columns": 2, "ambient_index": "1",
             "moduli": [13, 26],
             "expected_orders": {"13": 13, "26": 13}},
            {"id": "surjective-c49", "matrix": [[2, 0, 1], [0, 3, 1]],
             "columns": 3, "ambient_index": "1",
             "moduli": [7], "expected_orders": {"7": 7}},
            {"id": "rankzero", "matrix": [],
             "columns": 2, "ambient_index": "1",
             "moduli": [2], "expected_orders": {"2": 1}},
        ]
    }


class ExactMathematics(unittest.TestCase):
    def test_lattice_index_normalization(self):
        self.assertEqual(determinant([[1, 1], [0, 5]]), 5)
        self.assertEqual(lattice_index([(1, 0), (1, 5), (10, 0), (0, 10)], 2), 5)
        self.assertEqual(lattice_index([(2, 0), (0, 2)], 2), 4)
        self.assertEqual(lattice_index([(1,), (5,)], 1), 1)

    def test_original_refutation_and_composite_negative_control(self):
        a, b = ((1, 1), (0, 5)), ((1, 2), (0, 5))
        self.assertEqual(arithmetic_signature_2x2(a),
                         arithmetic_signature_2x2(b))
        for n, orders in ((5, (1, 5)), (10, (1, 5)), (25, (5, 5))):
            for matrix, order in zip((a, b), orders):
                first = candidate_hull(matrix, 2, n)
                second = checked_hull(matrix, 2, n)
                self.assertEqual(first, second)
                self.assertEqual(len(first), order)

    def test_full_mini_replay_reports_only_finite_evidence(self):
        r = verify_fixture(test_fixture(), source_commit="a"*40,
                           source_sha256="b"*64)
        self.assertEqual(r["specimens_checked"], 6)
        self.assertEqual(r["verdict"], "finite_specimens_verified")
        self.assertFalse(r["universal_claim_accepted"])
        self.assertEqual(len(r["counterexample_to_general_realization_invariance_at_5_and_10"]["5"]["a_prime"]), 5)
        self.assertIn("REFUTED", r["scope"])

    def test_mutated_source_expected_orders_rejected(self):
        tampered = test_fixture()
        tampered["cases"][1]["expected_orders"]["5"] = 1
        with self.assertRaisesRegex(ValueError, "expected order rejected"):
            verify_fixture(tampered, source_commit="a"*40, source_sha256="b"*64)

    def test_modified_realization_cannot_silently_survive(self):
        tampered = test_fixture()
        tampered["cases"][1]["matrix"][0][1] = 1
        with self.assertRaises(ValueError):
            verify_fixture(tampered, source_commit="a"*40, source_sha256="b"*64)

    def test_cap_and_membership_mutations_rejected(self):
        fixture = test_fixture()
        fixture["cases"][2]["moduli"] = [27]
        with self.assertRaisesRegex(ValueError, "modulus cap"):
            verify_fixture(fixture, source_commit="a"*40, source_sha256="b"*64)
        with self.assertRaisesRegex(ValueError, "source exact SHA"):
            verify_fixture(test_fixture(), source_commit="bad", source_sha256="b"*64)

    def test_module_profile_is_not_just_group_order(self):
        group = frozenset({(0, 0), (2, 0), (0, 2), (2, 2)})
        self.assertEqual(annihilator(group, 4)["2"], 4)


if __name__ == "__main__":
    unittest.main()
