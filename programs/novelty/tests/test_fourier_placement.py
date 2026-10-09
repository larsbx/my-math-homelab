import unittest

from experiments.soddy import fourier_placement as experiment
from experiments.soddy import n6_f7_orbits as arithmetic
from experiments.soddy import n6_f7_configurations as configuration

GUARDS_CONTRACT = "Fourier defect placement is admissible but invisible after row relabeling"


class TestFourierPlacement(unittest.TestCase):
    def test_fourier_character_identity(self):
        f = experiment.fourier()
        self.assertEqual(arithmetic.mat_mul(arithmetic.transpose(f), f), arithmetic.eye())
        self.assertEqual(arithmetic.mat_mul(f, f), arithmetic.eye())

    def test_defects_are_exact_binary_translations(self):
        translations = {
            arithmetic.matrix_key([[int(j == (i ^ t)) for j in range(8)]
                                    for i in range(8)]) for t in range(8)}
        self.assertEqual({arithmetic.matrix_key(d) for d in experiment.placed_defects()},
                         translations)

    def test_full_configs_cannot_observe_the_defects(self):
        w = configuration.replace(arithmetic.eye(), arithmetic.descartes_gram(), 3)
        for d in experiment.placed_defects():
            self.assertEqual(configuration.unlabeled_key(arithmetic.mat_mul(d, w)),
                             configuration.unlabeled_key(w))

    def test_four_centralizer_cases_and_no_uniqueness_promotion(self):
        result = experiment.run()
        self.assertEqual([c["graph_compatible"] for c in result["centralizer_cases"]],
                         [True, False, False, True])
        self.assertFalse(result["intrinsic_uniqueness_established"])


if __name__ == "__main__":
    unittest.main()
