import random
import unittest
from itertools import product

from support import load

C = load("experiments/n2/defect_census.py", "defect_census_theorem")
GUARDS_CLAIM = "DefectFixesQuaternionSubalgebra"
GUARDS_CONTRACT = "CompositionIdentities hold in the cayley-dickson/v1 octonion model over F_ell"

ELLS = (3, 7, 13)


def pairs(ell: int, count: int = 25):
    rng = random.Random(ell)
    return C.samples(ell, rng)[:count]


def scalar(n: int, a, ell: int):
    return tuple(n * t % ell for t in a)


def unit(ell: int):
    return C.BASIS[0]


def words(x, y, ell: int):
    """Elements of A: all products of at most three letters from {1, x, y}, both bracketings."""
    letters = (unit(ell), x, y)
    two = [C.mul(a, b, ell) for a, b in product(letters, repeat=2)]
    three = [C.mul(C.mul(a, b, ell), c, ell) for a, b, c in product(letters, repeat=3)]
    three += [C.mul(a, C.mul(b, c, ell), ell) for a, b, c in product(letters, repeat=3)]
    return list(letters) + two + three


def dot(u, v, ell: int) -> int:
    return sum(a * b for a, b in zip(u, v)) % ell


class TestCompositionIdentities(unittest.TestCase):
    """(F1) on the model; hypotheses check for the imported record."""

    def test_alternative_multiplicative_and_conjugate(self):
        for ell in ELLS:
            for x, y in pairs(ell):
                with self.subTest(ell=ell):
                    self.assertEqual(C.mul(x, C.mul(x, y, ell), ell), C.mul(C.mul(x, x, ell), y, ell))
                    self.assertEqual(C.mul(C.mul(y, x, ell), x, ell), C.mul(y, C.mul(x, x, ell), ell))
                    self.assertEqual(C.norm(C.mul(x, y, ell), ell), C.norm(x, ell) * C.norm(y, ell) % ell)
                    trace = 2 * x[0] % ell
                    self.assertEqual(C.conj(x, ell), tuple((trace * e - t) % ell for e, t in zip(unit(ell), x)))

    def test_left_multiplication_by_conjugate(self):
        for ell in ELLS:
            for x, _ in pairs(ell):
                lx, lc = C.left(x, ell), C.left(C.conj(x, ell), ell)
                expected = tuple(scalar(C.norm(x, ell), r, ell) for r in C.IDENTITY)
                self.assertEqual(C.matmul(lx, lc, ell), expected)
                self.assertEqual(C.matmul(lc, lx, ell), expected)


class TestDeterminant(unittest.TestCase):
    """det L_x = N(x)^4, hence det Delta(x, y) = 1 (paper, Proposition on the determinant)."""

    def test_left_multiplication_determinant(self):
        for ell in ELLS:
            rng = random.Random(100 + ell)
            for _ in range(60):
                x = tuple(rng.randrange(ell) for _ in range(C.DIM))
                det = C.echelon([list(r) for r in C.left(x, ell)], ell)[1]
                self.assertEqual(det, pow(C.norm(x, ell), 4, ell))

    def test_defect_determinant_is_one(self):
        for ell in ELLS:
            for x, y in pairs(ell):
                delta, _ = C.defect(x, y, ell)
                self.assertEqual(C.echelon([list(r) for r in delta], ell)[1], 1)


class TestTheorem(unittest.TestCase):
    def test_delta_fixes_the_generated_subalgebra(self):
        """(2) on words of length <= 3, which lie in A."""
        for ell in ELLS:
            for x, y in pairs(ell):
                delta, _ = C.defect(x, y, ell)
                for w in words(x, y, ell):
                    self.assertEqual(C.apply(delta, w, ell), w)

    def test_delta_preserves_q_perp(self):
        """(3) for W = Q: B(Delta u, w) = B(u, w) for every u and every w in Q."""
        for ell in ELLS:
            for x, y in pairs(ell):
                delta, xy = C.defect(x, y, ell)
                for u in C.BASIS:
                    for w in (unit(ell), x, y, xy):
                        self.assertEqual(dot(C.apply(delta, u, ell), w, ell), dot(u, w, ell))

    def test_rank_bound(self):
        """(5) rank(Delta - I) <= 8 - dim Q."""
        for ell in ELLS:
            for x, y in pairs(ell):
                delta, xy = C.defect(x, y, ell)
                moved = C.rank([[(delta[i][j] - C.IDENTITY[i][j]) % ell for j in range(C.DIM)] for i in range(C.DIM)], ell)
                self.assertLessEqual(moved, C.DIM - C.rank((unit(ell), x, y, xy), ell))

    def test_negative_control_outside_a(self):
        """Delta is not the identity: some basis vector outside A moves."""
        delta, _ = C.defect(C.BASIS[1], C.BASIS[2], 7)
        self.assertTrue(any(C.apply(delta, e, 7) != e for e in C.BASIS[4:]))


if __name__ == "__main__":
    unittest.main()
