import random
import unittest
from collections import Counter
from itertools import combinations, permutations, product

from support import load

R = load("experiments/n2/rank_law.py", "rank_law_charpoly")
C = R.C
GUARDS_CLAIM = "DefectCharacteristicPolynomial"
GUARDS_CONTRACT = "QuaternionDoubling right-multiplication form of Delta on Q-perp in the cayley-dickson/v1 octonion model"


def rand(ell, rng):
    return tuple(rng.randrange(ell) for _ in range(C.DIM))


def sub(u, v, ell):
    return tuple((s - t) % ell for s, t in zip(u, v))


def polymul(a, b, ell):
    out = [0] * (len(a) + len(b) - 1)
    for i, s in enumerate(a):
        for j, t in enumerate(b):
            out[i + j] = (out[i + j] + s * t) % ell
    return tuple(out)


def permutation_determinant(a, ell):
    """Independent small-matrix determinant from the Leibniz formula, with no division."""
    n, total = len(a), 0
    for order in permutations(range(n)):
        inversions = sum(order[i] > order[j] for i in range(n) for j in range(i + 1, n))
        term = (-1) ** inversions
        for i, j in enumerate(order):
            term *= a[i][j]
        total += term
    return total % ell


def principal_minor_charpoly(a, ell):
    """Coefficient of Y^(n-k) is (-1)^k times the sum of principal k-minors.

    This oracle uses neither Hessenberg reduction nor the defect factorization.
    Its division-free formula also works when the characteristic divides n!.
    """
    n = len(a)
    coefficients = [0] * (n + 1)
    for k in range(n + 1):
        total = sum(permutation_determinant([[a[i][j] for j in indices] for i in indices], ell)
                    for indices in combinations(range(n), k))
        coefficients[n - k] = (-1) ** k * total % ell
    return tuple(coefficients)


def shifted(a, scalar, ell):
    return tuple(tuple((t + scalar * (i == j)) % ell for j, t in enumerate(row))
                 for i, row in enumerate(a))


def matrix_power(a, exponent, ell):
    out = C.IDENTITY
    for _ in range(exponent):
        out = C.matmul(out, a, ell)
    return out


def anisotropic_vector(basis, ell):
    """In odd characteristic, a nondegenerate space has a nonisotropic basis vector or pairwise sum."""
    candidates = list(basis) + [tuple((s + t) % ell for s, t in zip(u, v))
                                for u, v in combinations(basis, 2)]
    return next((v for v in candidates if C.norm(v, ell)), None)


def predicted(nu, nc, ell):
    """(Y - nu)^4 (Y^2 - (2 nu - N(c)) Y + nu^2)^2, coefficients low -> high."""
    out = (1,)
    for f in [((-nu) % ell, 1)] * 4 + [(nu * nu % ell, (nc - 2 * nu) % ell, 1)] * 2:
        out = polymul(out, f, ell)
    return out


def pairs(ell, rng, count):
    """Random pairs, a fifth of them with y = a + b x so that dim Q <= 2 is covered."""
    for i in range(count):
        x, y = rand(ell, rng), rand(ell, rng)
        if i % 5 == 0:
            a, b = rng.randrange(ell), rng.randrange(1, ell)
            y = tuple((b * s + a * (k == 0)) % ell for k, s in enumerate(x))
        yield x, y


class TestCharpolyHelper(unittest.TestCase):
    def test_against_a_companion_matrix(self):
        ell = 7
        coeffs = (3, 0, 5, 1, 6, 2, 0, 4)                    # monic degree 8: c0 + c1 Y + ... + Y^8
        companion = [[0] * 8 for _ in range(8)]
        for i in range(1, 8):
            companion[i][i - 1] = 1
        for i in range(8):
            companion[i][7] = -coeffs[i] % ell
        self.assertEqual(C.charpoly(companion, ell), coeffs + (1,))

    def test_against_independent_oracle_on_all_small_matrices(self):
        for ell in (2, 3, 5):
            for entries in product(range(ell), repeat=4):
                a = [entries[:2], entries[2:]]
                self.assertEqual(C.charpoly(a, ell), principal_minor_charpoly(a, ell))
        for entries in product(range(2), repeat=9):
            a = [entries[3 * i:3 * i + 3] for i in range(3)]
            self.assertEqual(C.charpoly(a, 2), principal_minor_charpoly(a, 2))

    def test_arbitrary_matrices_and_structured_boundaries(self):
        rng = random.Random(20261003)
        for ell in (2, 3, 5, 7, 11, 13):
            self.assertEqual(C.charpoly([], ell), (1,))
            for n in range(1, 7):
                zero = [[0] * n for _ in range(n)]
                identity = [[int(i == j) for j in range(n)] for i in range(n)]
                jordan = [[int(j == i + 1) for j in range(n)] for i in range(n)]
                matrices = [zero, identity, jordan]
                matrices.extend([[rng.randrange(-ell, 2 * ell) for _ in range(n)] for _ in range(n)]
                                for _ in range(3))
                for a in matrices:
                    with self.subTest(ell=ell, n=n, a=a):
                        self.assertEqual(C.charpoly(a, ell), principal_minor_charpoly(a, ell))


class TestGramIdentity(unittest.TestCase):
    def test_gram_determinant_is_squared_commutator_norm(self):
        """det Gram_B(1, x, y, xy) = N(xy - yx)^2 for all x, y."""
        for ell in (3, 5, 7, 11):
            rng = random.Random(ell)
            for x, y in pairs(ell, rng, 300):
                xy = C.mul(x, y, ell)
                q = [C.BASIS[0], x, y, xy]
                gram = C.echelon([[R.bilinear(u, v, ell) for v in q] for u in q], ell)[1]
                commutator = C.norm(sub(xy, C.mul(y, x, ell), ell), ell)
                self.assertEqual(gram, commutator * commutator % ell)


class TestCharacteristicPolynomial(unittest.TestCase):
    def test_polynomial_identity_on_all_strata(self):
        """det(Y - L_x L_y L_conj(xy)) = (Y - nu)^4 (Y^2 - (2 nu - N(c)) Y + nu^2)^2, nu = N(x)N(y), c = xy - yx."""
        for ell in (3, 5, 7, 11, 13):
            rng = random.Random(100 + ell)
            coverage = Counter()
            for x, y in pairs(ell, rng, 250):
                xy = C.mul(x, y, ell)
                m = C.matmul(C.matmul(C.left(x, ell), C.left(y, ell), ell), C.left(C.conj(xy, ell), ell), ell)
                nu = C.norm(x, ell) * C.norm(y, ell) % ell
                nc = C.norm(sub(xy, C.mul(y, x, ell), ell), ell)
                self.assertEqual(C.charpoly(m, ell), predicted(nu, nc, ell))
                coverage["norm_zero_nonzero_commutator"] += not nu and bool(nc)
                coverage["degenerate_dim_four"] += bool(nu) and not nc and C.rank([C.BASIS[0], x, y, xy], ell) == 4
                coverage["nondegenerate_admissible"] += bool(nu) and bool(nc)
            for boundary in ("norm_zero_nonzero_commutator", "degenerate_dim_four", "nondegenerate_admissible"):
                self.assertGreater(coverage[boundary], 0, (ell, boundary))

    def test_dim_three_pairs_over_f3(self):
        """Sliced projective pairs over F_3 exercise the otherwise rare middle stratum."""
        ell, found, admissible = 3, 0, 0
        points = R.projective_pure(ell)
        for i, x in enumerate(points):
            for y in points[i + 1:i + 40]:
                xy = C.mul(x, y, ell)
                if C.rank([C.BASIS[0], x, y, xy], ell) != 3:
                    continue
                found += 1
                self.assertEqual(C.norm(sub(xy, C.mul(y, x, ell), ell), ell), 0)
                if C.norm(x, ell) and C.norm(y, ell):
                    admissible += 1
                    d, _ = C.defect(x, y, ell)
                    self.assertEqual(C.charpoly(d, ell), predicted(1, 0, ell))
        self.assertGreater(found, 50)
        self.assertGreater(admissible, 0)

    def test_zero_scalar_and_norm_zero_operands(self):
        zero = (0,) * C.DIM
        isotropic_tails = {3: (1, 1, 1), 5: (1, 2, 0), 7: (1, 2, 3),
                           11: (1, 1, 3), 13: (1, 3, 4)}
        for ell in (3, 5, 7, 11, 13):
            for x, y in ((zero, zero), (zero, C.BASIS[1]), (C.BASIS[1], zero),
                         (C.BASIS[0], C.BASIS[0]), (C.BASIS[0], C.BASIS[1]),
                         (C.BASIS[1], C.BASIS[1])):
                xy = C.mul(x, y, ell)
                m = C.matmul(C.matmul(C.left(x, ell), C.left(y, ell), ell), C.left(C.conj(xy, ell), ell), ell)
                nu = C.norm(x, ell) * C.norm(y, ell) % ell
                self.assertEqual(C.charpoly(m, ell), predicted(nu, 0, ell))
                if nu:
                    self.assertEqual(C.defect(x, y, ell)[0], C.IDENTITY)
                else:
                    with self.assertRaises(ValueError):
                        C.defect(x, y, ell)
            # nu=0 does not imply that the unnormalized operator is nilpotent.
            x, y = (0,) + isotropic_tails[ell] + (0,) * 4, C.BASIS[1]
            self.assertEqual(C.norm(x, ell), 0)
            xy = C.mul(x, y, ell)
            nc = C.norm(sub(xy, C.mul(y, x, ell), ell), ell)
            self.assertNotEqual(nc, 0)
            m = C.matmul(C.matmul(C.left(x, ell), C.left(y, ell), ell), C.left(C.conj(xy, ell), ell), ell)
            self.assertEqual(C.charpoly(m, ell), predicted(0, nc, ell))
            self.assertTrue(any(t for row in matrix_power(m, 8, ell) for t in row))
            with self.assertRaises(ValueError):
                C.defect(x, y, ell)


class TestCorollaryBoundaries(unittest.TestCase):
    UNIPOTENT_PAIRS = (
        (C.BASIS[0], C.BASIS[0], 1, 0),
        ((0, 0, 0, 0, 2, 0, 2, 0), (0, 0, 1, 2, 0, 2, 2, 2), 3, 2),
        ((0, 2, 0, 2, 0, 1, 2, 2), (0, 1, 0, 2, 1, 0, 2, 2), 4, 4),
    )

    def test_unipotence_dimension_and_degeneracy_are_distinct(self):
        ell = 3
        polynomials, ranks = set(), set()
        for x, y, dim_q, moved in self.UNIPOTENT_PAIRS:
            xy = C.mul(x, y, ell)
            q = [C.BASIS[0], x, y, xy]
            self.assertEqual(C.norm(x, ell) * C.norm(y, ell) % ell, 1)
            self.assertEqual(C.norm(sub(xy, C.mul(y, x, ell), ell), ell), 0)
            self.assertEqual(C.rank(q, ell), dim_q)
            # Restrict the Gram form to an actual independent basis of Q.
            basis = []
            for v in q:
                if C.rank(basis + [v], ell) > len(basis):
                    basis.append(v)
            degenerate = not R.gram_nondegenerate(basis, ell)
            self.assertEqual(degenerate, dim_q in (3, 4))
            self.assertTrue(dim_q <= 3 or degenerate)
            d, _ = C.defect(x, y, ell)
            self.assertEqual(C.charpoly(d, ell), predicted(1, 0, ell))
            self.assertFalse(any(t for row in matrix_power(shifted(d, -1, ell), 8, ell) for t in row))
            self.assertEqual(sum(d[i][i] for i in range(C.DIM)) % ell, 8 % ell)
            self.assertEqual(C.rank(shifted(d, -1, ell), ell), moved)
            polynomials.add(C.charpoly(d, ell))
            ranks.add(moved)
        self.assertEqual(len(polynomials), 1)
        self.assertEqual(ranks, {0, 2, 4})  # conjugacy cannot change these ranks

    def test_tau_minus_two_does_not_determine_jordan_type(self):
        ell = 3
        pairs = ((C.BASIS[1], C.BASIS[2]),
                 ((2, 0, 0, 1, 0, 0, 0, 0), (0, 0, 2, 2, 0, 0, 0, 0)))
        polynomials, ranks = [], []
        for x, y in pairs:
            xy = C.mul(x, y, ell)
            q = [C.BASIS[0], x, y, xy]
            self.assertEqual(C.rank(q, ell), 4)
            self.assertTrue(R.gram_nondegenerate(q, ell))
            nu = C.norm(x, ell) * C.norm(y, ell) % ell
            nc = C.norm(sub(xy, C.mul(y, x, ell), ell), ell)
            self.assertEqual((nu, nc), (1, 1))
            tau = (2 - nc * pow(nu, -1, ell)) % ell
            self.assertEqual(tau, -2 % ell)
            d, _ = C.defect(x, y, ell)
            polynomials.append(C.charpoly(d, ell))
            ranks.append(C.rank(shifted(C.matmul(d, d, ell), -1, ell), ell))
            self.assertEqual(sum(d[i][i] for i in range(C.DIM)) % ell, (8 - 2 * nc) % ell)
            self.assertTrue(any(t for row in matrix_power(shifted(d, -1, ell), 8, ell) for t in row))
            annihilator = C.matmul(shifted(d, -1, ell), matrix_power(shifted(d, 1, ell), 2, ell), ell)
            self.assertFalse(any(t for row in annihilator for t in row))
        self.assertEqual(polynomials[0], polynomials[1])
        self.assertEqual(ranks, [0, 2])


class TestRightMultiplicationForm(unittest.TestCase):
    def test_delta_on_q_perp_is_right_multiplication_by_g(self):
        """For nondegenerate Q and v in Q-perp with N(v) != 0: Delta(uv) = (u g) v, g = (xy)^-1 (yx)."""
        for ell in (3, 5, 7):
            rng, done = random.Random(ell), 0
            for _ in range(1000):
                if done == 25:
                    break
                x, y = rand(ell, rng), rand(ell, rng)
                xy = C.mul(x, y, ell)
                q = [C.BASIS[0], x, y, xy]
                nu = C.norm(x, ell) * C.norm(y, ell) % ell
                if not nu or C.rank(q, ell) != 4 or not R.gram_nondegenerate(q, ell):
                    continue
                perp = R.orthogonal_complement(q, ell)
                v = anisotropic_vector(perp, ell)
                self.assertIsNotNone(v, "Nondegenerate Q-perp must have an anisotropic vector or pairwise sum")
                self.assertTrue(all(R.bilinear(w, v, ell) == 0 for w in q))
                done += 1
                g = tuple(t * pow(nu, -1, ell) % ell for t in C.mul(C.conj(xy, ell), C.mul(y, x, ell), ell))
                nc = C.norm(sub(xy, C.mul(y, x, ell), ell), ell)
                tau = (2 - nc * pow(nu, -1, ell)) % ell
                self.assertEqual(C.norm(g, ell), 1)
                self.assertEqual(2 * g[0] % ell, tau)
                self.assertEqual(C.norm(sub(g, C.BASIS[0], ell), ell), nc * pow(nu, -1, ell) % ell)
                d, _ = C.defect(x, y, ell)
                for u in q:
                    uv = C.mul(u, v, ell)
                    self.assertEqual(C.apply(d, uv, ell), C.mul(C.mul(u, g, ell), v, ell))
            self.assertEqual(done, 25)

    def test_anisotropic_vector_when_every_basis_vector_is_isotropic(self):
        ell = 5
        basis = ((1, 2, 0, 0, 0, 0, 0, 0), (1, 3, 0, 0, 0, 0, 0, 0))
        self.assertTrue(all(C.norm(v, ell) == 0 for v in basis))
        self.assertTrue(R.gram_nondegenerate(basis, ell))
        v = anisotropic_vector(basis, ell)
        self.assertIsNotNone(v)
        self.assertNotEqual(C.norm(v, ell), 0)


if __name__ == "__main__":
    unittest.main()
