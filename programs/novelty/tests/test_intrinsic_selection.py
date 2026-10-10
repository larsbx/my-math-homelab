import copy
import ast
import pathlib
import re
import unittest

from experiments.soddy import intrinsic_selection as selection
from experiments.soddy import n6_f7_configurations as configuration
from experiments.soddy import n6_f7_orbits as arithmetic

GUARDS_CONTRACT = "global F7 linear quotient adjacency certificates and fail-closed intrinsic selection"


class TestIntrinsicSelection(unittest.TestCase):
    def test_lean_patterns_match_independent_cayley_dickson_replay(self):
        source = (pathlib.Path(__file__).parents[1] /
                  "NoveltyLab/IntrinsicSelectionF7.lean").read_text()
        match = re.search(r"def patterns : List \(List Nat\) :=\s*(\[.*?\])\s*\n\s*def diagonal", source, re.S)
        self.assertIsNotNone(match)
        rows = ast.literal_eval(match.group(1))
        phi, inv = arithmetic.bridge_isometry()
        declared = [arithmetic.mat_mul(phi, arithmetic.mat_mul(
            [[row[i] if i == j else 0 for j in range(8)] for i in range(8)],
            inv)) for row in rows]
        self.assertEqual(declared, arithmetic.defect_generators())
        changed = copy.deepcopy(rows)
        changed[1][4] = 1
        altered = [arithmetic.mat_mul(phi, arithmetic.mat_mul(
            [[row[i] if i == j else 0 for j in range(8)] for i in range(8)],
            inv)) for row in changed]
        self.assertNotEqual(altered, arithmetic.defect_generators())

    def test_identity_and_relabelings_pass(self):
        for b in [arithmetic.eye()] + [configuration.adjacent_swap(i)
                                      for i in range(7)]:
            cert = selection.certify(b)
            self.assertTrue(cert["accepted"])
            self.assertTrue(selection.replay(b, cert))

    def test_scalar_action_passes_without_selecting_octonions(self):
        b = [[-x % 7 for x in row] for row in arithmetic.eye()]
        self.assertTrue(selection.certify(b)["accepted"])

    def test_all_nonidentity_basis_defects_fail(self):
        for d in arithmetic.defect_generators():
            cert = selection.certify(d)
            self.assertEqual(cert["accepted"], d == arithmetic.eye())
            if d != arithmetic.eye():
                self.assertFalse(cert["quotient_well_defined"])
                self.assertFalse(cert["neighbor_identity"])
                i = cert["first_failed_swap"]
                p = configuration.adjacent_swap(i)
                # Replay two equivalent inputs whose images are inequivalent.
                self.assertEqual(configuration.unlabeled_key(p),
                                 configuration.unlabeled_key(arithmetic.eye()))
                self.assertNotEqual(configuration.unlabeled_key(d),
                    configuration.unlabeled_key(arithmetic.mat_mul(d, p)))

    def test_modified_tensor_or_certificate_fails_replay(self):
        d = arithmetic.eye()
        cert = selection.certify(d)
        bad = copy.deepcopy(cert)
        bad["accepted"] = False
        self.assertFalse(selection.replay(d, bad))
        bad = copy.deepcopy(cert)
        bad["neighbor_counts"]["transport_then_replace"][0]["multiplicity"] += 1
        self.assertFalse(selection.replay(d, bad))
        altered = copy.deepcopy(d)
        altered[0][1] = 1
        self.assertFalse(selection.replay(altered, cert))

    def test_census_never_promotes_trivial_survivor(self):
        result = selection.census()
        self.assertEqual(result["distinct_candidates"], 8)
        self.assertEqual(result["accepted_candidates"], 1)
        self.assertEqual(result["accepted_nonidentity_candidates"], 0)
        self.assertFalse(result["all_placements_enumerated"])
        self.assertFalse(result["intrinsic_selection_established"])


if __name__ == "__main__":
    unittest.main()
