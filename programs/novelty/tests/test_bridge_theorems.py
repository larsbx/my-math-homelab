import importlib.util, pathlib, unittest
P=pathlib.Path(__file__).parents[1]/"scripts/verify_bridge_theorems.py"
S=importlib.util.spec_from_file_location("bridges",P); M=importlib.util.module_from_spec(S); S.loader.exec_module(M)
GUARDS_CONTRACT = "research/theorems.json N3-T01 falling-factorial identity, exhaustive on small maps"
class TestBridgeTheorems(unittest.TestCase):
    def test_exhaustive_small_maps(self):
        self.assertGreater(M.verify(max_x=4,max_s=3,max_k=4),100)
    def test_second_factorial_moment(self):
        images=(0,0,1,0)
        self.assertEqual(M.lhs(images,2,2),6)
        self.assertEqual(M.rhs(images,2),6)
    def test_ordered_third_collisions(self):
        images=(1,1,1,0)
        self.assertEqual(M.lhs(images,2,3),6)
        self.assertEqual(M.rhs(images,3),6)
if __name__=="__main__": unittest.main()
