"""Finite critical-relation adapter adversarial and independent arithmetic tests."""
from __future__ import annotations

import sys
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/"tools"))
from math_adapters.finite_mandelbrot import (
    parse_golden, dual_critical_relation, polynomial_relation,
    verify_golden, critical_polynomials,
)


GOLDEN_TEXT = """
Golden(137462, 4, 5, 1048583, True, True, True)
Golden(247423, 3, 6, 1048583, True, True, True)
Golden(6268, 2, 8, 1048583, True, True, True)
Golden(16992, 9, 1, 1048583, True, True, True)
Golden(1047843, 9, 3, 16777259, True, True, True)
Golden(3503477, 8, 4, 16777259, True, True, True)
Golden(-2, 2, 1, 4294967291, True, True, True)
Golden(-1, 0, 2, 4294967291, True, True, True)
Golden(0, 2, 1, 4294967291, True, False, False)
Golden(-2, 1, 1, 4294967291, False, False, True)
Golden(12345, 5, 7, 4294967291, False, False, True)
"""


class FiniteMandelbrotAdapter(unittest.TestCase):
    def test_all_eleven_exact_finite_replays(self):
        result=verify_golden(GOLDEN_TEXT,source_commit="a"*40,
                             source_sha256="b"*64)
        self.assertEqual(result["finite_vectors_checked"],11)
        self.assertEqual(result["verdict"],
                         "finite_critical_relation_golden_vectors_verified")
        self.assertFalse(result["proves_mlc"])
        self.assertFalse(result["universal_claim_accepted"])
        self.assertEqual(len(result["certificates"]),11)

    def test_two_algorithms_match_named_negative_controls(self):
        for c,ell,k,p,expected in parse_golden(GOLDEN_TEXT):
            a=dual_critical_relation(c,ell,k,p)
            b=polynomial_relation(c,ell,k,p)
            self.assertEqual(a,b)
            self.assertEqual(a,expected)

    def test_first_exact_critical_polynomials(self):
        self.assertEqual(critical_polynomials(101,3)[:4],[
            (0,), (0,1), (0,1,1), (0,1,2,2,1)])
        # Q_3=C^4+2C^3+C^2+C, a purely finite-field identity.

    def test_modified_or_missing_golden_rejected(self):
        broken=GOLDEN_TEXT.replace("True, False, False",
                                   "True, True, False")
        with self.assertRaisesRegex(ValueError,"Golden finite fixture mismatch"):
            verify_golden(broken,source_commit="a"*40,
                          source_sha256="b"*64)
        missing=GOLDEN_TEXT.replace("Golden(12345, 5, 7, 4294967291, False, False, True)","")
        with self.assertRaisesRegex(ValueError,"domain changed"):
            parse_golden(missing)

    def test_composite_field_and_unbounded_horizon_rejected(self):
        bad=GOLDEN_TEXT.replace("1048583, True", "1048584, True",1)
        with self.assertRaisesRegex(ValueError,"prime field"):
            parse_golden(bad)
        bad=GOLDEN_TEXT.replace("12345, 5, 7", "12345, 6, 7")
        with self.assertRaisesRegex(ValueError,"horizon cap"):
            parse_golden(bad)


if __name__=="__main__":
    unittest.main()
