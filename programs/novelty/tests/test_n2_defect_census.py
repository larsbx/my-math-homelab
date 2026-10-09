import hashlib
import random
import unittest

from support import ROOT, load

from proof_records.generate_ledgers import load_ledger

C = load("experiments/n2/defect_census.py", "defect_census")
GUARDS_CLAIM = "DefectCensus"
GUARDS_CONTRACT = "research/theorems.json N2-T03 square-root-free defect, checked on finite samples"


class TestModel(unittest.TestCase):
    def test_conjugate_inverts_left_multiplication(self):
        ell, rng = 7, random.Random(1)
        for _ in range(20):
            x = tuple(rng.randrange(ell) for _ in range(C.DIM))
            n = C.norm(x, ell)
            expected = tuple(tuple(n * int(i == j) for j in range(C.DIM)) for i in range(C.DIM))
            self.assertEqual(C.matmul(C.left(C.conj(x, ell), ell), C.left(x, ell), ell), expected)

    def test_norm_is_multiplicative(self):
        ell, rng = 5, random.Random(2)
        for _ in range(50):
            x, y = (tuple(rng.randrange(ell) for _ in range(C.DIM)) for _ in range(2))
            self.assertEqual(C.norm(C.mul(x, y, ell), ell), C.norm(x, ell) * C.norm(y, ell) % ell)


class TestDefect(unittest.TestCase):
    def test_every_property_on_fresh_samples(self):
        for ell in (3, 13):
            for x, y in C.samples(ell, random.Random(ell))[:120]:
                props, _ = C.checks(x, y, ell)
                with self.subTest(ell=ell, x=x, y=y):
                    self.assertTrue(all(props.values()), props)

    def test_scalar_pairs_are_flat(self):
        x, y = (2,) + (0,) * 7, (3,) + (0,) * 7
        props, stratum = C.checks(x, y, 7)
        self.assertTrue(all(props.values()))
        self.assertEqual(stratum[:2], (1, 0))

    def test_generic_pairs_move_exactly_q_perp(self):
        e1, e2 = C.BASIS[1], C.BASIS[2]
        _, stratum = C.checks(e1, e2, 7)
        self.assertEqual(stratum[:2], (4, 4))

    def test_checks_can_fail(self):
        """Negative control: without the N(xy)^{-1} scale, Delta is not an isometry."""
        ell, x, y = 7, (1, 1, 0, 0, 0, 0, 0, 0), (1, 0, 1, 0, 0, 0, 0, 0)
        xy = C.mul(x, y, ell)
        raw = C.matmul(C.matmul(C.left(x, ell), C.left(y, ell), ell), C.left(C.conj(xy, ell), ell), ell)
        self.assertNotEqual(C.norm(xy, ell), 1)
        self.assertNotEqual(C.matmul(C.transpose(raw), raw, ell), C.IDENTITY)


class TestCommittedCensus(unittest.TestCase):
    def test_census_is_current(self):
        self.assertEqual(C.OUT.read_text(encoding="utf-8"), C.render())

    def test_no_violations_recorded(self):
        import json
        rows = json.loads(C.OUT.read_text(encoding="utf-8"))["rows"]
        self.assertTrue(all(v == 0 for r in rows for v in r["violations"].values()))
        self.assertEqual({s["dim_Q"] for r in rows for s in r["strata"]}, {2, 3, 4})

    def test_ledger_digest_replays(self):
        record = load_ledger(ROOT / "research" / "ledger.json").records["DefectCensus"]
        self.assertEqual(record.field("digest"), "sha256:" + hashlib.sha256(C.OUT.read_bytes()).hexdigest())


if __name__ == "__main__":
    unittest.main()
