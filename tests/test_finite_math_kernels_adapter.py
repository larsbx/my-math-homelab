"""Independent finite cyclotomic exact-replay controls; no germ theorem claims."""
from __future__ import annotations

from copy import deepcopy
import sys
from pathlib import Path
from math import gcd
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/"tools"))
from math_adapters.finite_math_kernels import (
    cyclotomic_table, exact_monic_division, multiply, primitive_power_reduction,
    verify_vectors,
)


def small_fixture():
    table = cyclotomic_table(8)
    return {
        "schema": "cyclotomic-germ/v1", "authority": "none",
        "cyclotomic_polynomials": {str(k):v for k,v in table.items()},
        "vectors": [
            {"q":q, "p":p,
             "parabolic_factor_constant": ["0"]*(len(table[q])-1),
             "reciprocal_coefficient": ["0"]*(len(table[q])-1)}
            for q in range(1,9) for p in range(1,q+1) if gcd(q,p)==1
        ],
    }


class ExactCyclotomicResearch(unittest.TestCase):
    def test_independent_recursive_polynomials(self):
        self.assertEqual(cyclotomic_table(8), {
            1:[-1,1], 2:[1,1], 3:[1,1,1], 4:[1,0,1],
            5:[1,1,1,1,1], 6:[1,-1,1],
            7:[1,1,1,1,1,1,1], 8:[1,0,0,0,1],
        })
        for n,phi in cyclotomic_table(8).items():
            for p in range(1,n+1):
                if gcd(n,p)==1:
                    self.assertEqual(primitive_power_reduction(n,p,phi),[0])

    def test_complete_22_vector_exact_finite_replay(self):
        evidence=verify_vectors(small_fixture(),source_commit="a"*40,
                                source_sha256="b"*64)
        self.assertEqual(evidence["polynomials_verified"],8)
        self.assertEqual(evidence["primitive_powers_verified"],22)
        self.assertEqual(evidence["verdict"],
                         "finite_cyclotomic_polynomial_fixtures_verified")
        self.assertFalse(evidence["parabolic_coefficients_checked"])
        self.assertFalse(evidence["byte_encoding_checked"])
        self.assertFalse(evidence["universal_mathematical_claim_accepted"])

    def test_changed_cyclotomic_polynomial_rejected(self):
        x=small_fixture()
        x["cyclotomic_polynomials"]["6"]=[1,1,1]
        with self.assertRaisesRegex(ValueError,"Phi_6"):
            verify_vectors(x,source_commit="a"*40,source_sha256="b"*64)

    def test_incomplete_primitive_coverage_rejected(self):
        x=small_fixture()
        x["vectors"].pop()
        with self.assertRaisesRegex(ValueError,"coverage incomplete"):
            verify_vectors(x,source_commit="a"*40,source_sha256="b"*64)

    def test_nonprimitive_power_rejected(self):
        x=small_fixture()
        x["vectors"][3]["p"]=3
        with self.assertRaises(ValueError):
            verify_vectors(x,source_commit="a"*40,source_sha256="b"*64)

    def test_dimension_and_division_mutations_rejected(self):
        x=small_fixture()
        x["vectors"][2]["reciprocal_coefficient"].append("0")
        with self.assertRaisesRegex(ValueError,"dimension"):
            verify_vectors(x,source_commit="a"*40,source_sha256="b"*64)
        with self.assertRaisesRegex(ValueError,"remainder"):
            exact_monic_division([1,0,1],[1,1])


if __name__ == "__main__":
    unittest.main()
