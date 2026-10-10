import json
import random
import unittest

from support import ROOT, load

H = load("experiments/n2/h3_integral.py", "h3_integral")
C, P = H.C, H.P
GUARDS_CLAIM = "H3IntegralPilot"
GUARDS_CONTRACT = "H3IntegralPilot exactness, certificate and DefectClassicalAnisotropic"
DATA = ROOT / "data/n2/h3-integral-v1.json"


class TestShell(unittest.TestCase):
    def test_shell_sizes_and_closure(self):
        """|S_p| = 16(p^3 + 1), and Z^8 is closed under the product (structure constants +-1)."""
        for p in (3, 5):
            shell = H.shell(p)
            self.assertEqual(len(shell), 16 * (p ** 3 + 1))
            rng = random.Random(p)
            for _ in range(50):
                x, y = (tuple(t % P for t in rng.choice(shell)) for _ in range(2))
                self.assertEqual(sum(t * t for t in H.lift(C.mul(x, y, P))), p * p)


class TestCertificate(unittest.TestCase):
    def test_value_only_collision_of_length_three(self):
        cert = H.certificate()
        self.assertTrue(cert["values_equal"])
        self.assertFalse(cert["operators_equal"])
        self.assertTrue(all(sum(t * t for t in a) == 3 for a in cert["left"] + cert["right"]))


class TestAnisotropic(unittest.TestCase):
    def test_commutator_norm_vanishes_only_when_dim_q_is_at_most_two(self):
        """Corollary 3.33 over the definite algebra: N(xy - yx) = 0 iff dim Q <= 2 iff Delta = I."""
        rng = random.Random(7)
        for _ in range(300):
            x = tuple(rng.randrange(-2, 3) for _ in range(C.DIM))
            y = tuple((rng.randrange(-2, 3) + rng.randrange(2) * s) for s in x) if rng.random() < 0.3 \
                else tuple(rng.randrange(-2, 3) for _ in range(C.DIM))
            if not (any(x) and any(y)):
                continue
            xm, ym = (tuple(t % P for t in v) for v in (x, y))
            xy = C.mul(xm, ym, P)
            c = H.lift(tuple((s - t) % P for s, t in zip(xy, C.mul(ym, xm, P))))
            flat = C.rank([C.BASIS[0], xm, ym, xy], P) <= 2
            self.assertEqual(sum(t * t for t in c) == 0, flat)
            self.assertEqual(C.defect(xm, ym, P)[0] == C.IDENTITY, flat)


class TestRows(unittest.TestCase):
    def test_a_committed_row_replays(self):
        rows = json.loads(DATA.read_text(encoding="utf-8"))["rows"]
        committed = next(r for r in rows if (r["p"], r["generators"], r["seed"]) == (3, 12, 2))
        self.assertEqual(H.row(3, 6, 2), committed)


if __name__ == "__main__":
    unittest.main()
