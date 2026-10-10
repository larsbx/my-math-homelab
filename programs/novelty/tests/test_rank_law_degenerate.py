import random
import unittest
from itertools import product

from support import load

R = load("experiments/n2/rank_law.py", "rank_law_degenerate")
C = R.C
GUARDS_CLAIM = "RankLawDegenerate"
GUARDS_CONTRACT = "ZornPeirce structure at every nontrivial idempotent of the cayley-dickson/v1 octonion model over F_3"


def rand(ell, rng):
    return tuple(rng.randrange(ell) for _ in range(C.DIM))


def combination(vectors, coeffs, ell):
    return tuple(sum(c * v[i] for c, v in zip(coeffs, vectors)) % ell for i in range(C.DIM))


def phi(x, y, ell):
    return R.matsub(C.matmul(C.left(x, ell), C.left(y, ell), ell), C.left(C.mul(x, y, ell), ell), ell)


def assoc(x, y, z, ell):
    return tuple((s - t) % ell for s, t in zip(C.mul(x, C.mul(y, z, ell), ell), C.mul(C.mul(x, y, ell), z, ell)))


def span_dim(vectors, ell):
    return C.rank(list(vectors), ell) if vectors else 0


def pairs(ell, dim_q, degenerate, count, seed):
    """Random pairs (x, y) whose Q = span{1, x, y, xy} has the given dimension and degeneracy."""
    rng, found = random.Random(seed), 0
    while found < count:
        x, y = rand(ell, rng), rand(ell, rng)
        q = [C.BASIS[0], x, y, C.mul(x, y, ell)]
        basis = [v for i, v in enumerate(q) if span_dim(q[:i + 1], ell) > span_dim(q[:i], ell)]
        if len(basis) == dim_q and (dim_q == 3 or R.gram_nondegenerate(basis, ell) != degenerate):
            found += 1
            yield x, y, basis


class TestLinearAlgebra(unittest.TestCase):
    def test_nullspace_and_radical(self):
        ell = 5
        rows = [(1, 2, 0, 0, 0, 0, 0, 0), (0, 0, 1, 0, 0, 0, 0, 3)]
        basis = R.nullspace(rows, ell)
        self.assertEqual(len(basis), 6)
        self.assertTrue(all(sum(r * z for r, z in zip(row, v)) % ell == 0 for row in rows for v in basis))
        iso = (0, 1, 2, 0, 0, 0, 0, 0)                       # N = 1 + 4 = 0 mod 5
        rad = R.radical([C.BASIS[0], iso], ell)              # B(1, iso) = 0 and B(iso, iso) = 2 N(iso) = 0
        self.assertEqual(span_dim(rad + [iso], ell), 1)


class TestSkewAdjoint(unittest.TestCase):
    def test_associator_is_skew_for_the_polar_form(self):
        """B([x, y, z], w) = -B(z, [x, y, w]): phi is skew-adjoint, so its rank is even."""
        for ell in (3, 5, 7):
            rng = random.Random(ell)
            for _ in range(300):
                x, y, z, w = (rand(ell, rng) for _ in range(4))
                self.assertEqual(R.bilinear(assoc(x, y, z, ell), w, ell), -R.bilinear(z, assoc(x, y, w, ell), ell) % ell)


class TestIsotropicLeftMultiplication(unittest.TestCase):
    def test_rank_four_and_hyperbolic_anticommutator(self):
        """For pure isotropic n != 0: L_n^2 = 0 and rank L_n = 4; L_n L_m + L_m L_n = -B(n, m) I."""
        ell = 3
        identity = tuple(tuple(int(i == j) for j in range(C.DIM)) for i in range(C.DIM))
        for n in (p for p in R.projective_pure(ell) if C.norm(p, ell) == 0):
            ln = C.left(n, ell)
            self.assertFalse(any(any(row) for row in C.matmul(ln, ln, ell)))
            self.assertEqual(C.rank(ln, ell), 4)
        rng = random.Random(5)
        for ell in (5, 7):
            for _ in range(40):
                n, m = rand(ell, rng), rand(ell, rng)
                anti = [[(a + b) % ell for a, b in zip(r, s)]
                        for r, s in zip(C.matmul(C.left(n, ell), C.left(m, ell), ell), C.matmul(C.left(m, ell), C.left(n, ell), ell))]
                # the general identity is L_n L_m + L_m L_n = L_{nm + mn} = T(n) L_m + T(m) L_n - B(n, m) I
                tn, tm, b = R.bilinear(n, C.BASIS[0], ell), R.bilinear(m, C.BASIS[0], ell), R.bilinear(n, m, ell)
                expected = [[(tn * C.left(m, ell)[i][j] + tm * C.left(n, ell)[i][j] - b * identity[i][j]) % ell
                             for j in range(C.DIM)] for i in range(C.DIM)]
                self.assertEqual(anti, expected)


class TestZornPeirce(unittest.TestCase):
    def test_every_nontrivial_idempotent_over_f3(self):
        """C10 = {u : eu = u, ue = 0} is 3-dimensional, e(C10 C10) = 0, and uu' = 0 only for dependent u, u'."""
        ell = 3
        idempotents = [e for e in product(range(ell), repeat=C.DIM)
                       if R.bilinear(e, C.BASIS[0], ell) == 1 and C.norm(e, ell) == 0]
        self.assertTrue(idempotents)
        for e in idempotents:
            self.assertEqual(C.mul(e, e, ell), e)
            le, re = C.left(e, ell), C.transpose([C.mul(b, e, ell) for b in C.BASIS])
            rows = [[(le[i][j] - int(i == j)) % ell for j in range(C.DIM)] for i in range(C.DIM)] + [list(r) for r in re]
            c10 = R.nullspace(rows, ell)
            self.assertEqual(len(c10), 3)
            points = [combination(c10, cs, ell) for cs in product(range(ell), repeat=3) if any(cs)]
            for u in points:
                for v in points:
                    uv = C.mul(u, v, ell)
                    self.assertFalse(any(C.mul(e, uv, ell)))
                    self.assertEqual(not any(uv), span_dim([u, v], ell) == 1)


class TestAssociativeSubalgebraBound(unittest.TestCase):
    def test_no_maximal_isotropic_perp_is_associative_over_f3(self):
        """The only case of the bound not settled by dimension counting: B = R-perp, R a 3-dim isotropic subspace of Im C."""
        ell = 3
        iso = [v for v in R.projective_pure(ell) if C.norm(v, ell) == 0]
        seen = set()
        for i, a in enumerate(iso):
            for j in range(i + 1, len(iso)):
                b = iso[j]
                if R.bilinear(a, b, ell):
                    continue
                for c in iso[j + 1:]:
                    if R.bilinear(a, c, ell) or R.bilinear(b, c, ell):
                        continue
                    key = tuple(R.nullspace([a, b, c], ell))     # canonical for span{a, b, c}
                    if len(key) != 5 or key in seen:
                        continue
                    seen.add(key)
                    perp = R.orthogonal_complement([a, b, c], ell)
                    closed = all(span_dim(perp + [C.mul(u, v, ell)], ell) == len(perp) for u in perp for v in perp)
                    associative = closed and all(not any(assoc(u, v, w, ell)) for u in perp for v in perp for w in perp)
                    self.assertFalse(associative)
        self.assertEqual(len(seen), 1120)


class TestDegenerateRankLaw(unittest.TestCase):
    def test_dim_three(self):
        """dim Q = 3: n in rad Q with nt in kn, nC in ker phi, dim(Q + nC) >= 5, and rank phi = 2."""
        for ell, count in ((3, 60), (5, 30), (7, 15)):
            for x, y, q in pairs(ell, 3, True, count, ell):
                with self.subTest(ell=ell, x=x, y=y):
                    rad = R.radical(q, ell)
                    q0 = R.nullspace([[R.bilinear(C.BASIS[0], e, ell) for e in C.BASIS]] +
                                     [list(r) for r in R.orthogonal_complement(q, ell)], ell)
                    self.assertEqual(span_dim(q0, ell), 2)
                    # choose n as in the proof: rad Q of dim 1, or a spanning element of (rad Q)^2 when rad Q = Q_0
                    squares = [C.mul(a, b, ell) for a in rad for b in rad if any(C.mul(a, b, ell))]
                    n = squares[0] if len(rad) == 2 and squares else rad[0]
                    t = next(v for v in q0 if span_dim([n, v], ell) == 2)
                    nt = C.mul(n, t, ell)
                    self.assertLessEqual(span_dim([n, nt], ell), 1)
                    for e in C.BASIS:
                        self.assertFalse(any(assoc(n, t, C.mul(n, e, ell), ell)))
                    n_c = [C.mul(n, e, ell) for e in C.BASIS]
                    self.assertEqual(span_dim(n_c, ell), 4)
                    self.assertGreaterEqual(span_dim(q + n_c, ell), 5)
                    self.assertEqual(C.rank(phi(x, y, ell), ell), 2)

    def test_dim_four_degenerate(self):
        """dim Q = 4 with B|Q degenerate: ker phi = Q."""
        for ell, count in ((3, 60), (5, 30), (7, 15)):
            for x, y, q in pairs(ell, 4, True, count, 10 + ell):
                with self.subTest(ell=ell, x=x, y=y):
                    ker = R.nullspace(phi(x, y, ell), ell)
                    self.assertEqual(len(ker), 4)
                    self.assertEqual(span_dim(q + ker, ell), 4)


if __name__ == "__main__":
    unittest.main()
