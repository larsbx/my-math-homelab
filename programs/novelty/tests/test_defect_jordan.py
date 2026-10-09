import json
import random
import unittest

from support import ROOT, load

J = load("experiments/n2/defect_jordan.py", "defect_jordan")
C, R = J.C, J.R
GUARDS_CLAIM = "DefectJordanType"
GUARDS_CONTRACT = "DefectJordanType proof steps"


def pairs(ell, seed, count):
    """Admissible pairs, enriched for the rare strata dim Q = 3 and tau = -2."""
    rng, out = random.Random(seed), []
    while len(out) < count:
        x, y = J.admissible(ell, rng), J.admissible(ell, rng)
        if J.stratum(x, y, ell) in ("dimQ<=2", "semisimple") and rng.random() < 0.9:
            continue
        out.append((x, y))
    return out


class TestAnnihilator(unittest.TestCase):
    def test_cubic_annihilates_delta_on_every_stratum(self):
        """(Delta - I)(Delta^2 - tau Delta + I) = 0 for every pair with nu != 0, by Zariski density."""
        for ell in (3, 5, 7):
            for x, y in pairs(ell, ell, 40):
                d, tau = C.defect(x, y, ell)[0], J.tau(x, y, ell)
                self.assertFalse(any(any(r) for r in C.matmul(J.shift(d, 1, ell),
                                                                J.quadratic(d, tau, ell), ell)))


class TestProofSteps(unittest.TestCase):
    def test_square_rank_is_rank_of_B_on_Q_when_dim_Q_is_four(self):
        """dim Q = 4: rank (Delta - I)^2 = 4 - dim(Q cap Q-perp), and B|_Q has rank 1 or 2 when degenerate."""
        for ell in (3, 5):
            seen = 0
            for x, y in pairs(ell, 10 + ell, 60):
                q = (C.BASIS[0], x, y, C.mul(x, y, ell))
                if J.stratum(x, y, ell) not in ("unipotent-rank1", "unipotent-rank2"):
                    continue
                seen += 1
                a = J.shift(C.defect(x, y, ell)[0], 1, ell)
                rank_bq = C.rank([[R.bilinear(u, w, ell) for w in q] for u in q], ell)
                self.assertIn(rank_bq, (1, 2))
                self.assertEqual(C.rank(C.matmul(a, a, ell), ell), rank_bq)
            self.assertGreater(seen, 0)

    def test_tau_minus_two_semisimple_iff_x_y_pure_orthogonal(self):
        """tau = -2: Delta is semisimple iff xy + yx = 0 iff T(x) = T(y) = B(x, y) = 0 (Gram data)."""
        one = C.BASIS[0]
        for ell in (3, 5, 7):
            rng, hits = random.Random(30 + ell), {True: 0, False: 0}
            while min(hits.values()) < 5:
                x, y = J.admissible(ell, rng), J.admissible(ell, rng)
                if rng.random() < 0.5:   # project to pure, orthogonal parts to reach the semisimple case
                    x = J.pure(x, ell)
                    y = J.pure(y, ell)
                    y = tuple((s - R.bilinear(x, y, ell) * pow(2 * C.norm(x, ell), -1, ell) * t) % ell
                              for s, t in zip(y, x)) if C.norm(x, ell) else y
                    if not (C.norm(x, ell) and C.norm(y, ell)):
                        continue
                if J.tau(x, y, ell) != ell - 2:
                    continue
                gram = R.bilinear(x, one, ell) == R.bilinear(y, one, ell) == R.bilinear(x, y, ell) == 0
                anti = not any((s + t) % ell for s, t in zip(C.mul(x, y, ell), C.mul(y, x, ell)))
                d = C.defect(x, y, ell)[0]
                semisimple = C.rank(J.shift(d, -1, ell), ell) == 4
                self.assertEqual(gram, anti)
                self.assertEqual(anti, semisimple)
                hits[semisimple] += 1


class TestGramOfQ(unittest.TestCase):
    def test_gram_of_one_x_y_xy_is_a_function_of_gram_of_one_x_y(self):
        """Corollary 3.30: B(1, xy) = T(x)T(y) - B(x, y), B(x, xy) = N(x)T(y), B(y, xy) = N(y)T(x), B(xy, xy) = 2 nu."""
        one = C.BASIS[0]
        for ell in (3, 5, 7, 11):
            rng = random.Random(50 + ell)
            for _ in range(200):
                x, y = (tuple(rng.randrange(ell) for _ in range(C.DIM)) for _ in range(2))
                xy, b = C.mul(x, y, ell), (lambda u, w: R.bilinear(u, w, ell))
                t = lambda a: b(a, one)
                self.assertEqual(b(one, xy), (t(x) * t(y) - b(x, y)) % ell)
                self.assertEqual(b(x, xy), C.norm(x, ell) * t(y) % ell)
                self.assertEqual(b(y, xy), C.norm(y, ell) * t(x) % ell)
                self.assertEqual(b(xy, xy), 2 * C.norm(x, ell) * C.norm(y, ell) % ell)


class TestCensus(unittest.TestCase):
    def test_committed_census_is_current_and_has_no_violations(self):
        text = (ROOT / "data/n2/defect-jordan-v1.json").read_text(encoding="utf-8")
        self.assertEqual(text, J.render())
        self.assertEqual([row["violations"] for row in json.loads(text)["rows"]], [0] * len(J.ELLS))


if __name__ == "__main__":
    unittest.main()
