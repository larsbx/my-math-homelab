import importlib.util, pathlib, unittest
P=pathlib.Path(__file__).parents[1]/"experiments/n2/pentagon.py"
S=importlib.util.spec_from_file_location("pentagon",P); M=importlib.util.module_from_spec(S); S.loader.exec_module(M)
GUARDS_CONTRACT = "research/theorems.json N2-T04 pentagon boundary closes on the Cayley-Dickson experiment"
class TestPentagon(unittest.TestCase):
    def test_basis_exhaustion(self):
        r=M.experiment(3)
        self.assertEqual(r["basis_quadruples"],4096)
        self.assertGreater(r["nonflat_boundaries"],0)
        self.assertIsNotNone(r["witness"])
    def test_boundary_closes_on_dense_vectors(self):
        p=5
        a=tuple(range(8)); b=tuple((2*i+1)%p for i in range(8))
        c=tuple((i*i+1)%p for i in range(8)); d=tuple((3*i+2)%p for i in range(8))
        self.assertEqual(M.boundary(a,b,c,d,p),(0,)*8)
    def test_edge_terms_match_vertex_differences(self):
        p=3; a,b,c,d=M.basis(8)[:4]
        vs=M.vertices(a,b,c,d,p); ts=M.boundary_terms(a,b,c,d,p)
        for i in range(5): self.assertEqual(ts[i],M.sub(vs[(i+1)%5],vs[i],p))
if __name__=="__main__": unittest.main()
