import unittest

from support import load

F = load("experiments/n2/lean_fixture.py", "lean_fixture")
P5 = F.P5
GUARDS_CONTRACT = "NoveltyLab/Fixture.lean is current and every case discriminates sign and order errors in the pentagon edges"


class TestLeanFixture(unittest.TestCase):
    def test_fixture_is_current(self):
        self.assertEqual(F.OUT.read_text(encoding="utf-8"), F.render())

    def test_tensor_is_non_associative(self):
        bs = P5.basis(F.DIM)
        self.assertTrue(any(any(P5.assoc(a, b, c, F.P)) for a in bs for b in bs for c in bs))

    def test_tensor_reproduces_the_experiment_product(self):
        t, bs = F.table(), P5.basis(F.DIM)
        for i in range(F.DIM):
            for j in range(F.DIM):
                self.assertEqual(tuple(t[i][j]), P5.mul(bs[i], bs[j], F.P))

    def test_cases_have_nonzero_edges_and_kill_mutants(self):
        """The Python mirror of the Lean mutation controls, so the fixture cannot be vacuous."""
        cases = F.cases()
        self.assertTrue(any(disc for _, disc in cases))
        for q, disc in cases:
            terms = P5.boundary_terms(*q, F.P)
            self.assertEqual(P5.boundary(*q, F.P), F.ZERO)
            self.assertTrue(any(any(e) for e in terms))
            for i, e in enumerate(terms):
                flipped = F._sum([P5.neg(x, F.P) if k == i else x for k, x in enumerate(terms)], F.P)
                self.assertEqual(any(flipped), any(e))
            if disc:
                self.assertTrue(all(any(e) for e in terms))
                self.assertTrue(all(any(m) for m in F.order_mutants(*q, F.P)))


if __name__ == "__main__":
    unittest.main()
