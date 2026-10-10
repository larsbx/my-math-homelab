import random
import unittest

from support import load

R = load("experiments/n2/rank_law.py", "rank_law_class")
C = R.C
GUARDS_CLAIM = "DefectClassIsClassical"
GUARDS_CONTRACT = "DefectReflectionFactorization"


def rand(ell, rng):
    return tuple(rng.randrange(ell) for _ in range(C.DIM))


def gram_det(vectors, ell):
    return C.echelon([[R.bilinear(u, v, ell) for v in vectors] for u in vectors], ell)[1]


def commutator_norm(x, y, ell):
    return C.norm(tuple((a - b) % ell for a, b in zip(C.mul(x, y, ell), C.mul(y, x, ell))), ell)


class TestCommutatorNormIsGramData(unittest.TestCase):
    def test_twice_commutator_norm_is_gram_determinant_of_one_x_y(self):
        """2 N(xy - yx) = det Gram_B(1, x, y): tau is a function of the Gram matrix of (1, x, y)."""
        for ell in (3, 5, 7, 11, 13):
            rng = random.Random(ell)
            for _ in range(400):
                x, y = rand(ell, rng), rand(ell, rng)
                self.assertEqual(2 * commutator_norm(x, y, ell) % ell, gram_det([C.BASIS[0], x, y], ell))


class TestSemisimplicity(unittest.TestCase):
    def test_delta_is_annihilated_by_the_split_quadratic_for_tau_not_two(self):
        """For tau != +-2, (Delta - I)(Delta^2 - tau Delta + I) = 0, so Delta is semisimple and its
        similarity class is fixed by its characteristic polynomial."""
        for ell in (5, 7, 11, 13):
            rng, checked = random.Random(ell), 0
            while checked < 60:
                x, y = rand(ell, rng), rand(ell, rng)
                nu = C.norm(x, ell) * C.norm(y, ell) % ell
                if not nu:
                    continue
                tau = (2 - commutator_norm(x, y, ell) * pow(nu, -1, ell)) % ell
                if tau in (2, ell - 2):
                    continue
                checked += 1
                d, _ = C.defect(x, y, ell)
                n = C.DIM
                eye = [[int(i == j) for j in range(n)] for i in range(n)]
                d2 = C.matmul(d, d, ell)
                quad = [[(d2[i][j] - tau * d[i][j] + eye[i][j]) % ell for j in range(n)] for i in range(n)]
                lin = [[(d[i][j] - eye[i][j]) % ell for j in range(n)] for i in range(n)]
                self.assertFalse(any(any(r) for r in C.matmul(lin, quad, ell)))


def reflection(a, ell):
    """s_a(z) = z - B(z, a)/N(a) a, as a matrix acting on column vectors."""
    inv = pow(C.norm(a, ell), -1, ell)
    images = [tuple((s - R.bilinear(e, a, ell) * inv * t) % ell for s, t in zip(e, a)) for e in C.BASIS]
    return C.transpose(images)


def spinor_class(d, ell):
    """Square class (+1/-1) of the discriminant of the Wall form on W = Im(d - I); +1 for d = I."""
    m = [[(d[i][j] - int(i == j)) % ell for j in range(C.DIM)] for i in range(C.DIM)]
    sources, images = [], []
    for e in C.BASIS:
        im = C.apply(m, e, ell)
        if C.rank(images + [im], ell) > len(images):
            sources.append(e)
            images.append(im)
    if not images:
        return 1
    disc = C.echelon([[R.bilinear(u, w, ell) for w in images] for u in sources], ell)[1]
    assert disc, "the Wall form is nondegenerate"
    return 1 if pow(disc, (ell - 1) // 2, ell) == 1 else -1


class TestReflectionFactorization(unittest.TestCase):
    def test_delta_is_a_product_of_four_reflections(self):
        """For nondegenerate Q and v in Q-perp with N(v) != 0: Delta = s_xv s_v s_yv s_(xy)v."""
        for ell in (3, 5, 7, 11, 13):
            rng, done = random.Random(ell), 0
            while done < 40:
                x, y = rand(ell, rng), rand(ell, rng)
                xy = C.mul(x, y, ell)
                if not (C.norm(x, ell) and C.norm(y, ell) and commutator_norm(x, y, ell)):
                    continue
                v = next((w for w in R.orthogonal_complement([C.BASIS[0], x, y, xy], ell) if C.norm(w, ell)), None)
                if v is None:
                    continue
                done += 1
                factors = [reflection(C.mul(a, v, ell), ell) for a in (x, C.BASIS[0], y, xy)]
                product = C.matmul(C.matmul(factors[0], factors[1], ell), C.matmul(factors[2], factors[3], ell), ell)
                self.assertEqual(product, C.defect(x, y, ell)[0])

    def test_spinor_norm_is_trivial_on_every_stratum(self):
        """Wall-form discriminant of Delta is a square, including the unipotent strata N(xy - yx) = 0."""
        for ell in (3, 5, 7, 11):
            rng, seen = random.Random(20 + ell), {True: 0, False: 0}
            while min(seen.values()) < 25:
                x, y = rand(ell, rng), rand(ell, rng)
                if rng.random() < 0.3:
                    a, b = rng.randrange(ell), rng.randrange(1, ell)
                    y = tuple((a * (k == 0) + b * s) % ell for k, s in enumerate(x))
                if not (C.norm(x, ell) and C.norm(y, ell)):
                    continue
                unipotent = commutator_norm(x, y, ell) == 0
                if seen[unipotent] >= 25:
                    continue
                seen[unipotent] += 1
                self.assertEqual(spinor_class(C.defect(x, y, ell)[0], ell), 1)


class TestNonSemisimpleNotClassical(unittest.TestCase):
    def test_equal_gram_unipotent_defects_with_different_ranks(self):
        """Paper Remark 3.25: the semisimplicity hypothesis of Corollary 3.22 cannot be dropped."""
        ell = 3
        first = ((1, 0, 2, 1, 0, 1, 0, 0), (0, 1, 2, 2, 0, 0, 2, 1))
        second = ((1, 2, 2, 2, 1, 2, 1, 0), (0, 2, 0, 0, 2, 1, 1, 1))
        gram = lambda x, y: [[R.bilinear(u, v, ell) for v in (C.BASIS[0], x, y)] for u in (C.BASIS[0], x, y)]
        self.assertEqual(gram(*first), gram(*second))
        ranks = []
        for x, y in (first, second):
            self.assertEqual(commutator_norm(x, y, ell), 0)
            d, _ = C.defect(x, y, ell)
            ranks.append(C.rank([[(d[i][j] - int(i == j)) % ell for j in range(C.DIM)] for i in range(C.DIM)], ell))
        self.assertEqual(ranks, [4, 2])


if __name__ == "__main__":
    unittest.main()
