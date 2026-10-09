import importlib.util
import pathlib
import unittest

ROOT = pathlib.Path(__file__).parents[1]
GUARDS_CONTRACT = "EXP-SG-001 exact finite orbit witness"
PATH = ROOT / "experiments" / "soddy" / "n6_f7_orbits.py"
SPEC = importlib.util.spec_from_file_location("n6_f7_orbits", PATH)
EXP = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(EXP)


class TestN6F7OrbitComparison(unittest.TestCase):
    def test_joint_action_requires_a_relative_framing(self):
        self.assertEqual(EXP.framing_audit(), {
            "original_combined_orbit": 2240,
            "alternate_combined_orbit": 137600,
            "alternate_defect_orbit": 8,
        })

    def test_explicit_bridge_isometry(self):
        q = EXP.descartes_gram()
        phi, phi_inv = EXP.bridge_isometry()
        self.assertEqual(EXP.mat_mul(phi, phi_inv), EXP.eye())
        self.assertEqual(
            EXP.mat_mul(EXP.transpose(phi), EXP.mat_mul(q, phi)), EXP.eye())

    def test_generators_preserve_descartes_form(self):
        q = EXP.descartes_gram()
        defect = EXP.defect_generators()
        apollonian = EXP.apollonian_generators()
        self.assertEqual((len(defect), len(apollonian)), (8, 8))
        self.assertTrue(all(EXP.gram_preserved(g, q)
                            for g in defect + apollonian))

    def test_exact_projective_orbits(self):
        result = EXP.run()
        self.assertEqual(result["defect_projective_orbit_size"], 8)
        self.assertEqual(result["apollonian_projective_orbit_size"], 168)
        self.assertEqual(result["combined_projective_orbit_size"], 2240)


if __name__ == "__main__":
    unittest.main()
