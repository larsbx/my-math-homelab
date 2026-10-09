import copy
import random
import unittest
from fractions import Fraction as F
from itertools import product

from support import load

from n1 import cayley_dickson as cd
from n1.certificate import check
from n1.hilbert import bad_places, hilbert

search = load("experiments/n1/search.py", "n1_search")
GUARDS_CLAIM = "ZeroDivisorCertificateSoundness"
GUARDS_CONTRACT = "cayley-dickson/v1 convention and Hilbert-symbol arithmetic over Q"

RNG = random.Random(20261001)
PAIRS = [(F(a), F(b)) for a, b in product([-7, -3, -2, -1, 1, 2, 3, 5, 6, 10], repeat=2)]


def basis(i: int, n: int) -> cd.Element:
    return tuple(F(int(k == i)) for k in range(1 << n))


def rand_element(n: int) -> cd.Element:
    return tuple(F(RNG.randint(-5, 5), RNG.randint(1, 3)) for _ in range(1 << n))


class TestConvention(unittest.TestCase):
    def test_quaternion_relations(self):
        a, b = F(-2), F(5)
        i, j, k = (basis(t, 2) for t in (1, 2, 3))
        m = lambda x, y: cd.mul(x, y, (a, b))  # noqa: E731
        self.assertEqual(m(i, i), cd.scale(a, basis(0, 2)))
        self.assertEqual(m(j, j), cd.scale(b, basis(0, 2)))
        self.assertEqual(m(i, j), k)
        self.assertEqual(m(j, i), cd.scale(F(-1), k))

    def test_associative_at_two_alternative_at_three(self):
        for n, law in ((2, lambda x, y, z, m: m(m(x, y), z) == m(x, m(y, z))),
                       (3, lambda x, y, z, m: m(x, m(x, y)) == m(m(x, x), y))):
            params = (F(-1), F(3), F(-5))[:n]
            m = lambda x, y, p=params: cd.mul(x, y, p)  # noqa: E731
            for _ in range(20):
                with self.subTest(n=n):
                    self.assertTrue(law(rand_element(n), rand_element(n), rand_element(n), m))

    def test_not_alternative_at_four(self):
        params = (F(-1),) * 4
        m = lambda x, y: cd.mul(x, y, params)  # noqa: E731
        self.assertTrue(any(m(x, m(x, y)) != m(m(x, x), y)
                            for x, y in ((rand_element(4), rand_element(4)) for _ in range(10))))

    def test_norm_is_scalar_through_octonions(self):
        for n in (1, 2, 3):
            params = (F(-1), F(2), F(-3))[:n]
            x = rand_element(n)
            norm = cd.mul(x, cd.conj(x), params)
            self.assertFalse(any(norm[1:]))


class TestHilbert(unittest.TestCase):
    def test_hamilton_quaternions_ramify_at_two_and_infinity(self):
        self.assertEqual([v for v in bad_places(F(-1), F(-1)) if hilbert(F(-1), F(-1), v) == -1], ["inf", "2"])

    def test_product_formula(self):
        """Falsification check: ∏_v (a, b)_v = 1 (Hilbert reciprocity) on a random sample."""
        for _ in range(400):
            a, b = (F(RNG.choice([-1, 1]) * RNG.randint(1, 300), RNG.randint(1, 20)) for _ in range(2))
            with self.subTest(a=a, b=b):
                self.assertEqual(sum(hilbert(a, b, v) == -1 for v in bad_places(a, b)) % 2, 0)

    def test_square_class_invariance(self):
        for a, b in PAIRS:
            for v in bad_places(a, b):
                self.assertEqual(hilbert(a, b, v), hilbert(a * 9, b / 4, v))

    def test_refuses_non_places(self):
        for v in ("4", "1", "02", "-3", "x"):
            with self.subTest(v=v), self.assertRaises(ValueError):
                hilbert(F(1), F(1), v)


class TestSearchAgainstChecker(unittest.TestCase):
    def test_every_search_output_is_accepted(self):
        for n in (2, 3, 4):
            for a, b in PAIRS:
                params = (a, b, F(-1), F(-1))[:n]
                cert = search.search(params)
                if cert is not None:
                    with self.subTest(params=params):
                        self.assertTrue(check(cert).accepted, check(cert).reason)

    def test_two_routes_never_disagree(self):
        """A ramified place and a rational isotropic vector must never coexist."""
        for a, b in PAIRS:
            with self.subTest(a=a, b=b):
                self.assertFalse(search.ramified_place(a, b) and search.isotropic_vector(a, b, 12))

    def test_quaternion_pairs_are_decided(self):
        for a, b in PAIRS:
            with self.subTest(a=a, b=b):
                self.assertIsNotNone(search.search((a, b)))


class TestCheckerRefusals(unittest.TestCase):
    def setUp(self):
        self.split = search.search((F(1), F(1)))
        self.division = search.search((F(-1), F(-1)))

    def refused(self, cert):
        verdict = check(cert)
        self.assertFalse(verdict.accepted)
        return verdict.reason

    def mutate(self, base, path, value):
        cert = copy.deepcopy(base)
        target = cert
        for key in path[:-1]:
            target = target[key]
        target[path[-1]] = value
        return cert

    def test_tampering(self):
        cases = [
            (self.split, ("witness", "x", 0), "2"),
            (self.split, ("witness", "x"), ["0"] * 4),
            (self.split, ("witness", "y"), ["1"] * 3),
            (self.split, ("parameters", 0), "0"),
            (self.split, ("parameters", 0), "2/4"),
            (self.split, ("parameters", 0), "1.0"),
            (self.split, ("convention",), "cayley-dickson/v0"),
            (self.split, ("verdict",), "split"),
            (self.division, ("witness", "place"), "3"),
            (self.division, ("witness", "place"), "4"),
            (self.division, ("witness",), []),
            (self.division, ("witness", "x"), ["1"] * 4),
            (self.division, ("verdict",), "zero_divisor"),
            (self.division, ("parameters",), ["-1", "-1", "-1"]),
        ]
        for base, path, value in cases:
            with self.subTest(path=path, value=value):
                self.refused(self.mutate(base, path, value))

    def test_malformed_inputs_are_refused_not_raised(self):
        for cert in (None, [], {}, {**self.split, "extra": 1}, {**self.split, "parameters": "1,1"},
                     {**self.split, "verdict": ["division"]}, {**self.split, "parameters": [1, 1]}):
            with self.subTest(cert=cert):
                self.refused(cert)


if __name__ == "__main__":
    unittest.main()
