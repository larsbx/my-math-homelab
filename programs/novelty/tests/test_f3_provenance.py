import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from support import ROOT, load

GUARDS_CONTRACT = "F3 Lean tensor provenance matches independent Cayley-Dickson replay; single-entry mutations are refused"

F = load("scripts/check_f3_table.py", "f3_provenance")


class TestF3Provenance(unittest.TestCase):
    def setUp(self):
        self.source = (ROOT / "NoveltyLab/OctonionF3.lean").read_text()

    def test_independent_replay_matches_lean_tensor_and_digest(self):
        self.assertEqual(F.verify(self.source), F.EXPECTED)
        self.assertEqual(F.verify(self.source, F.canonical(F.TABLE) + "\n"), F.EXPECTED)

    def test_single_source_entry_mutants_fail_cli(self):
        for name, old, new in (("productIndex", "#[0,1,2,3,4,5,6,7]", "#[1,1,2,3,4,5,6,7]"),
                               ("productCoeff", "#[1,1,1,1,1,1,1,1]", "#[2,1,1,1,1,1,1,1]")):
            with self.subTest(name=name), tempfile.TemporaryDirectory() as directory:
                prefix, section = self.source.split("def " + name, 1)
                mutant = prefix + "def " + name + section.replace(old, new, 1)
                self.assertNotEqual(mutant, self.source)
                path = Path(directory) / "mutant.lean"
                path.write_text(mutant)
                result = subprocess.run([sys.executable, str(ROOT / "scripts/check_f3_table.py"),
                                         "--lean-source", str(path)], capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("Lean tensor differs", result.stderr)

    def test_single_exported_tensor_entry_mutant_fails(self):
        mutant = json.loads(F.canonical(F.TABLE))["table"]
        mutant[0][0][0] = 2
        with self.assertRaisesRegex(ValueError, "serialization mismatch"):
            F.verify(self.source, F.canonical(mutant) + "\n")

    def test_source_parser_refuses_invalid_shape_range_or_syntax(self):
        for replacement in ("#[8,1,2,3,4,5,6,7]", "#[0,1,2]", "#[0+0,1,2,3,4,5,6,7]"):
            with self.subTest(replacement=replacement), self.assertRaises(ValueError):
                F.verify(self.source.replace("#[0,1,2,3,4,5,6,7]", replacement, 1))


if __name__ == "__main__":
    unittest.main()
