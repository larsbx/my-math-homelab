import itertools
import unittest

from experiments.soddy import affine_row_structures as affine

GUARDS_CONTRACT = "complete affine row-structure family, ternary law and translation bundle"


class TestAffineRowStructures(unittest.TestCase):
    def test_complete_family_and_no_selection_promotion(self):
        result = affine.run()
        self.assertEqual(result["affine_structures"], 30)
        self.assertEqual(result["planes_per_structure"], 14)
        self.assertEqual(result["relabeling_stabilizer_order"], 1344)
        self.assertEqual(result["marked_decorations_per_labeled_configuration"], 240)
        self.assertFalse(result["distinguished_structure_selected"])
        self.assertFalse(result["lean_certified"])

    def test_heap_law_and_independent_xor_reference(self):
        planes = affine.standard_planes()
        for a,b,c in itertools.product(range(8), repeat=3):
            self.assertEqual(affine.heap(planes,a,b,c), a^b^c)
        for a,b,c,d,e in itertools.product(range(8), repeat=5):
            self.assertEqual((a^b^c)^d^e, a^b^(c^d^e))

    def test_all_translation_groups_are_root_independent(self):
        identity = tuple(range(8))
        for planes in affine.structures():
            group = set(affine.translations(planes, 0))
            self.assertEqual(len(group), 8)
            for origin in range(8):
                self.assertEqual(set(affine.translations(planes, origin)), group)
            for p in group:
                self.assertEqual(affine.compose(p,p), identity)
                for q in group:
                    self.assertIn(affine.compose(p,q), group)
                    self.assertEqual(affine.compose(p,q), affine.compose(q,p))

    def test_relabeling_equivariance_of_ternary_structure(self):
        planes = affine.standard_planes()
        for j in range(7):
            p = list(range(8))
            p[j],p[j+1] = p[j+1],p[j]
            moved = affine.relabel(planes,p)
            for a,b,c in itertools.product(range(8), repeat=3):
                self.assertEqual(affine.heap(moved,p[a],p[b],p[c]),
                                 p[affine.heap(planes,a,b,c)])

    def test_incomplete_planes_and_invalid_labels_are_refused(self):
        with self.assertRaises(ValueError):
            affine.heap((),0,1,2)
        with self.assertRaises(ValueError):
            affine.relabel(affine.standard_planes(),[0]*8)
        with self.assertRaises(ValueError):
            affine.heap(affine.standard_planes(),True,1,2)


if __name__ == "__main__":
    unittest.main()
