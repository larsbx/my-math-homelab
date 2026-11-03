"""Exact, bounded PV Hankel and recurrence independent replay regressions."""
from __future__ import annotations

import sys
from pathlib import Path
import unittest
from fractions import Fraction

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/"tools"))
from math_adapters.pisot_vijayaraghavan import (
    bareiss_det, leibniz_det, input_specimens, recurrence_sequence,
    companion_sequence, recover_coefficients, verify_pv_finite,
)

FIXTURES = [
    ([1],[2]), ([2,1],[1,1]), ([0,1],[-1,0]),
    ([1,4],[-4,4]), ([3,3,9],[1,0,3]),
    ([1,8,36],[8,-12,6]),
    ([4,17,87,503],[-210,247,-101,17]),
]
def source(tests=FIXTURES):
    # Pure AST data, not executable imported source.
    return "@pytest.mark.parametrize(('initial','coefficients'), "+repr(tests)+")\n" \
           "def test_overlap_coefficients_are_stable_and_det_ratio_matches(initial, coefficients):\n    pass\n"

CLAIMS = """
version = 1
[[claim]]
id = "PV-HANKEL-RANK-BRIDGE"
status = "PROVED"
[[claim]]
id = "PV-COPRIME-TAIL"
status = "OPEN"
[[claim]]
id = "PV-THREE-STATE-MINIMAL"
status = "WITHDRAWN"
"""


class FinitePVResearch(unittest.TestCase):
    def test_all_seven_current_source_recurrences(self):
        o=verify_pv_finite(source(),CLAIMS,source_commit="a"*40,
                           source_sha256={"test_hankel":"b"*64,"claims":"c"*64})
        self.assertEqual(o["specimens"],7)
        self.assertEqual(o["verified_hankel_windows"],140)
        self.assertEqual(o["verdict"],"finite_pv_hankel_specimens_replayed")
        self.assertFalse(o["general_pv_problem_proved"])
        self.assertFalse(o["coprime_tail_problem_solved"])
        self.assertEqual(o["claim_status_changes"],[])

    def test_independent_determinants_with_pivot_and_zeros(self):
        for matrix,expected in [
            ([],1), ([[0,2],[3,4]],-6),
            ([[0,1,0],[0,0,1],[1,0,0]],1),
            ([[1,2],[2,4]],0),
        ]:
            self.assertEqual(bareiss_det(matrix),expected)
            self.assertEqual(leibniz_det(matrix),expected)

    def test_companion_recurrence_and_fractional_recovery(self):
        a=[3,3,9]; c=[1,0,3]
        direct=recurrence_sequence(a,c,35)
        self.assertEqual(direct,companion_sequence(a,c,35))
        self.assertEqual(recover_coefficients(direct,4,3),
                         tuple(map(Fraction,c)))

    def test_missing_or_modified_specimens_rejected(self):
        with self.assertRaisesRegex(ValueError,"seven"):
            input_specimens(source(FIXTURES[:-1]))
        tampered=list(FIXTURES)
        tampered[1]=([2,1],[1,2])
        with self.assertRaisesRegex(ValueError,"Lucas/cubic"):
            verify_pv_finite(source(tampered),CLAIMS,source_commit="a"*40,
                source_sha256={"test_hankel":"b"*64,"claims":"c"*64})

    def test_pv_open_and_withdrawn_claim_firewall(self):
        with self.assertRaisesRegex(ValueError,"claim boundary drift"):
            verify_pv_finite(source(),CLAIMS.replace(
                'id = "PV-COPRIME-TAIL"\nstatus = "OPEN"',
                'id = "PV-COPRIME-TAIL"\nstatus = "PROVED"'),
                source_commit="a"*40,
                source_sha256={"test_hankel":"b"*64,"claims":"c"*64})

    def test_finite_hankel_rank_is_not_an_infinite_tail_proof(self):
        # Same first ten terms as a rank-one exponential; changing the
        # unobserved eleventh breaks the rank-one Hankel condition.
        initial=[2**n for n in range(10)]
        self.assertEqual(bareiss_det([
            [initial[i+j] for j in range(2)] for i in range(2)]),0)
        extended=initial+[2**10+1]
        self.assertNotEqual(
            bareiss_det([[extended[8+i+j] for j in range(2)]
                         for i in range(2)]),0)


if __name__=="__main__":
    unittest.main()
