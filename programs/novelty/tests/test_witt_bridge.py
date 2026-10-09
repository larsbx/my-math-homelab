import importlib.util, pathlib, unittest
P=pathlib.Path(__file__).parents[1]/"experiments/soddy/witt_bridge.py"
S=importlib.util.spec_from_file_location("wb",P); M=importlib.util.module_from_spec(S); S.loader.exec_module(M)
GUARDS_CONTRACT = "research/theorems.json Witt-stabilized Soddy bridge square-class gates on experiments/soddy/witt_bridge.py"
class TestWittBridge(unittest.TestCase):
    def test_dimension_six_square_class_gate(self):
        self.assertTrue(M.bridge_descriptor(6,7)["available"])
        self.assertFalse(M.bridge_descriptor(6,5)["available"])
    def test_minimal_complement(self):
        for n in range(7,15):
            d=M.bridge_descriptor(n,17)
            self.assertEqual(d["complement_dim"],n-6)
            prod=1
            for x in d["complement_diag"]: prod=prod*x%17
            self.assertEqual(prod,d["descartes_det"])
    def test_rejects_degenerate_characteristic(self):
        with self.assertRaises(ValueError): M.bridge_descriptor(7,7)
    def test_rejects_sub_octonion_dimension(self):
        with self.assertRaises(ValueError): M.bridge_descriptor(5,11)
if __name__=="__main__": unittest.main()
