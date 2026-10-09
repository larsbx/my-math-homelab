import unittest

from experiments.soddy import n6_f7_configurations as config
from experiments.soddy import n6_f7_orbits as arithmetic

GUARDS_CONTRACT = "F7 full configuration Gram preservation and unlabeled replacement graph"


class TestFullConfigurations(unittest.TestCase):
    def test_full_configuration_replacement_and_tangency_gram(self):
        target = arithmetic.descartes_gram()
        w = arithmetic.eye()
        for i in (0, 3, 7, 2):
            before = w
            w = config.replace(w, target, i)
            self.assertEqual(config.replace(w, target, i), before)
            self.assertEqual(config.gram(w), target)
            # Row Gram in the dual ambient form is the fixed Descartes
            # inverse, including every pairwise entry, not just one column.
            row_gram = arithmetic.mat_mul(w, arithmetic.mat_mul(
                arithmetic.mat_inv(target), arithmetic.transpose(w)))
            self.assertEqual(row_gram, arithmetic.mat_inv(target))

    def test_permutations_normalize_the_replacement_family(self):
        generators = arithmetic.apollonian_generators()
        for j in range(7):
            p = config.adjacent_swap(j)
            for i, s in enumerate(generators):
                index = j + 1 if i == j else j if i == j + 1 else i
                self.assertEqual(arithmetic.mat_mul(p, arithmetic.mat_mul(s, p)),
                                 generators[index])

    def test_unlabeled_multigraph_and_failure_of_fixed_generator_descent(self):
        target = arithmetic.descartes_gram()
        w = config.replace(arithmetic.eye(), target, 3)
        p = config.adjacent_swap(0)
        pw = arithmetic.mat_mul(p, w)
        self.assertEqual(config.unlabeled_key(w), config.unlabeled_key(pw))
        self.assertEqual(config.neighbors(w, target), config.neighbors(pw, target))
        self.assertEqual(sum(config.neighbors(w, target).values()), 8)
        # Equal unlabeled inputs need not give equal outputs under S_0.
        self.assertNotEqual(config.unlabeled_key(config.replace(w, target, 0)),
                            config.unlabeled_key(config.replace(pw, target, 0)))

    def test_refuses_malformed_or_gram_inconsistent_configurations(self):
        target = arithmetic.descartes_gram()
        for bad in ([[0]*8 for _ in range(8)], [[1]],
                    [[True]*8 for _ in range(8)]):
            with self.assertRaises(ValueError):
                config.replace(bad, target, 0)
        bad = arithmetic.eye()
        bad[0][1] = 1
        with self.assertRaises(ValueError):
            config.replace(bad, target, 0)


if __name__ == "__main__":
    unittest.main()
