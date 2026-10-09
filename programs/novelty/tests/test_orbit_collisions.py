import importlib.util, pathlib, unittest
P=pathlib.Path(__file__).parents[1]/"scripts/verify_orbit_collisions.py"
S=importlib.util.spec_from_file_location("orbit",P); M=importlib.util.module_from_spec(S); S.loader.exec_module(M)
GUARDS_CONTRACT = "research/theorems.json N3-T02 quotient occupancies via Burnside averages"
class TestOrbitCollisions(unittest.TestCase):
    def test_free_action_divides_fibers(self):
        perms=[(0,1,2,3),(1,0,3,2)]; labels=(0,0,1,1)
        self.assertEqual(M.quotient_occupancies(perms,labels,2),[1,1])
        self.assertEqual(M.burnside_occupancies(perms,labels,2),[1,1])
    def test_nonfree_action_uses_fixed_points(self):
        perms=[(0,1,2,3),(1,0,2,3)]; labels=(0,0,1,1)
        self.assertEqual(M.quotient_occupancies(perms,labels,2),[1,2])
        self.assertEqual(M.burnside_occupancies(perms,labels,2),[1,2])
    def test_rejects_noninvariant_labels(self):
        with self.assertRaises(ValueError):
            M.quotient_occupancies([(0,1),(1,0)],(0,1),2)
    def test_regression_suite(self):
        self.assertGreater(M.verify(),5)
if __name__=="__main__": unittest.main()
