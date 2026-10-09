import contextlib
import io
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from support import load

M = load("scripts/lean_mutation_suite.py", "lean_mutation_suite")
GUARDS_CONTRACT = "Lean mutation report generation records survivors while check mode rejects them without writing"


class TestMutationReportModes(unittest.TestCase):
    def test_survivor_report_is_saved_only_in_generation_mode(self):
        report = '{"mutants": [{"mutant": "survivor", "killed": false}]}\n'
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "report.json"
            for args, existing, expected in [
                ([], "old report\n", report),
                (["--check"], "old report\n", "old report\n"),
                (["--check"], report, report),
            ]:
                with self.subTest(args=args, existing=existing):
                    output.write_text(existing, encoding="utf-8")
                    with patch.object(M, "OUT", output), patch.object(
                        M, "report", return_value=(report, "surviving mutants: ['survivor']")
                    ), contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                        self.assertEqual(M.main(["suite"] + args), 1)
                    self.assertEqual(output.read_text(encoding="utf-8"), expected)

    def test_baseline_failure_preserves_existing_report(self):
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "report.json"
            output.write_text("old report\n", encoding="utf-8")
            with patch.object(M, "OUT", output), patch.object(
                M, "report", return_value=(None, "baseline does not pass")
            ), contextlib.redirect_stderr(io.StringIO()):
                self.assertEqual(M.main(["suite"]), 1)
            self.assertEqual(output.read_text(encoding="utf-8"), "old report\n")
