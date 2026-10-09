import unittest

from support import load

P = load("experiments/n2/h3_pilot.py", "h3_pilot")
C = P.C
GUARDS_CLAIM = "H3PilotCollisions"


class TestH3Pilot(unittest.TestCase):
    def test_operator_collisions_share_their_defect_class(self):
        """Words with equal operator products have equal word defects, so they are not evidence for H3."""
        rows = list(P.words(5, 3))
        by_product = {}
        for value, product, cls in rows:
            self.assertEqual(by_product.setdefault((value, product), cls), cls)

    def test_words_are_reduced(self):
        gens = P.generators(5, 3)
        self.assertEqual(len(gens), 6)
        self.assertTrue(all(C.norm(g, 5) == 1 for g in gens))
        self.assertEqual(len(list(P.words(5, 3))), 6 * 5 ** 3)


if __name__ == "__main__":
    unittest.main()
