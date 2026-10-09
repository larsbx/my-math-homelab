import importlib.util, pathlib, unittest
P=pathlib.Path(__file__).parents[1]/"experiments/n3/analyze_collisions.py"
GUARDS_CONTRACT = "analyze_collisions.py descriptive statistics are deterministic and refuse malformed input"
S=importlib.util.spec_from_file_location("n3",P); M=importlib.util.module_from_spec(S); S.loader.exec_module(M)
class TestN3(unittest.TestCase):
    def test_constant_occupancy(self):
        r=M.analyze({"multiplicities":[1,1,1,1]})
        self.assertEqual(r["shell_size"],4); self.assertEqual(r["variance"],0)
        self.assertEqual(r["claim_status"],"experimental descriptive statistic; not a Poisson theorem")
    def test_zeros_are_retained(self):
        r=M.analyze({"multiplicities":[0,0,2,2]})
        self.assertEqual(r["bins"],4); self.assertEqual(r["lambda"],1)
        self.assertEqual(r["observed_histogram"],[2,0,2])
    def test_refuses_bad_counts(self):
        for x in ([],[1,-1],[1,1.5],"1,2"):
            with self.subTest(x=x), self.assertRaises(ValueError): M.analyze({"multiplicities":x})
    def test_digest_is_key_order_independent(self):
        a=M.analyze({"multiplicities":[0,1],"ell":5})
        b=M.analyze({"ell":5,"multiplicities":[0,1]})
        self.assertEqual(a["input_sha256"],b["input_sha256"])
if __name__=="__main__": unittest.main()
