import hashlib
import json
import random
import unittest
from math import comb

from support import ROOT, load

from proof_records.generate_ledgers import load_ledger

R = load("experiments/n2/rank_law.py", "rank_law")
C = R.C
GUARDS_CLAIM = "RankLawExhaustiveF3"


def phi_rank_and_dim_q(x, y, ell):
    xy = C.mul(x, y, ell)
    phi = R.matsub(C.matmul(C.left(x, ell), C.left(y, ell), ell), C.left(xy, ell), ell)
    return C.rank(phi, ell), C.rank((C.BASIS[0], x, y, xy), ell)


class TestReduction(unittest.TestCase):
    """The exact reduction behind the census: shifts by scalars and rescaling change neither invariant."""

    def test_invariance_under_affine_scalar_changes(self):
        for ell in (3, 5, 7):
            rng = random.Random(ell)
            for _ in range(40):
                x, y = (tuple(rng.randrange(ell) for _ in range(C.DIM)) for _ in range(2))
                lam, mu = rng.randrange(1, ell), rng.randrange(1, ell)
                alpha, beta = rng.randrange(ell), rng.randrange(ell)
                x2 = tuple((lam * t + (alpha if k == 0 else 0)) % ell for k, t in enumerate(x))
                y2 = tuple((mu * t + (beta if k == 0 else 0)) % ell for k, t in enumerate(y))
                self.assertEqual(phi_rank_and_dim_q(x, y, ell), phi_rank_and_dim_q(x2, y2, ell))

    def test_projective_points_are_complete_and_distinct(self):
        points = R.projective_pure(3)
        self.assertEqual(len(points), (3 ** 7 - 1) // 2)
        self.assertEqual(len(set(points)), len(points))

    def test_rank_law_on_other_primes_sampled(self):
        for ell in (5, 7):
            rng = random.Random(100 + ell)
            for _ in range(150):
                x, y = (tuple(rng.randrange(ell) for _ in range(C.DIM)) for _ in range(2))
                r, d = phi_rank_and_dim_q(x, y, ell)
                self.assertEqual(r, 2 * max(0, d - 2))


class TestCommittedCensus(unittest.TestCase):
    def test_census_covers_every_pair_without_violation(self):
        row = json.loads(R.OUT.read_text(encoding="utf-8"))["rows"][0]
        self.assertEqual(row["ell"], 3)
        self.assertEqual(row["violations"], 0)
        self.assertEqual(row["unordered_pairs"], comb(row["projective_points"], 2))
        self.assertEqual(sum(s["pairs"] for s in row["strata"]), row["unordered_pairs"])

    def test_ledger_digest_replays(self):
        record = load_ledger(ROOT / "research" / "ledger.json").records["RankLawExhaustiveF3"]
        self.assertEqual(record.field("digest"), "sha256:" + hashlib.sha256(R.OUT.read_bytes()).hexdigest())


if __name__ == "__main__":
    unittest.main()
