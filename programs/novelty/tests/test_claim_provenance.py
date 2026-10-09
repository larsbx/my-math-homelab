import copy
import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from support import ROOT, load

check = load("scripts/check_claim_provenance.py", "claim_provenance")
seal = load("tools/seal_ledger.py", "seal_provenance")
GUARDS_CONTRACT = "unreviewed proofs remain pending and linked theorem status agrees with the ledger"


class TestClaimProvenance(unittest.TestCase):
    def setUp(self):
        self.ledger = json.loads((ROOT / "research/ledger.json").read_text())
        self.theorems = json.loads((ROOT / "research/theorems.json").read_text())

    def check_mutant(self, ledger=None, theorems=None):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "research").mkdir()
            (root / "research/ledger.json").write_text(json.dumps(seal.seal(copy.deepcopy(ledger or self.ledger))))
            (root / "research/theorems.json").write_text(json.dumps(theorems or self.theorems))
            check.check_provenance(root)

    def test_current_evidence_is_pending(self):
        self.check_mutant()
        for name in ("DefectFixesQuaternionSubalgebra", "ZeroDivisorCertificateSoundness"):
            record = self.ledger["records"][name]
            self.assertEqual(record["kind"], "pending_dependency")
            self.assertEqual(dict(record["evidence"])["proof_reviewed"], "false")

    def test_owner_direction_cannot_supply_review_flag(self):
        record = self.ledger["records"]["DefectFixesQuaternionSubalgebra"]
        for pair in record["evidence"]:
            if pair[0] == "proof_reviewed":
                pair[1] = "true"
        with self.assertRaisesRegex(ValueError, "requires independent_reviewer"):
            self.check_mutant(ledger=self.ledger)

    def test_repository_theorem_requires_review(self):
        self.ledger["records"]["DefectFixesQuaternionSubalgebra"]["kind"] = "repository_theorem"
        with self.assertRaisesRegex(ValueError, "without a reviewed proof"):
            self.check_mutant(ledger=self.ledger)

    def test_promoted_registry_with_pending_ledger_is_refused(self):
        self.theorems["theorems"][0]["claim_class"] = "proved result"
        with self.assertRaisesRegex(ValueError, "registry status differs"):
            self.check_mutant(theorems=self.theorems)

    def test_missing_link_cannot_bypass_status_check(self):
        del self.theorems["theorems"][0]["ledger_record"]
        with self.assertRaisesRegex(ValueError, "missing ledger link"):
            self.check_mutant(theorems=self.theorems)

    def test_pending_theorem_rejects_failed_obligation(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(ROOT / "research", root / "research")
            for name in ("docs", "vendor", "NoveltyLab", "experiments", "data", "kernel", "tests", ".github"):
                (root / name).symlink_to(ROOT / name, target_is_directory=True)
            shutil.copytree(ROOT / "scripts", root / "scripts")
            command = [sys.executable, str(root / "scripts/check_registry.py")]
            baseline = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(baseline.returncode, 0, baseline.stdout + baseline.stderr)
            path = root / "research/obligations.json"
            obligations = json.loads(path.read_text())
            next(v for v in obligations["obligations"] if v["id"] == "N1-V06")["status"] = "failed"
            path.write_text(json.dumps(obligations))
            mutant = subprocess.run(command, capture_output=True, text=True)
            self.assertNotEqual(mutant.returncode, 0)
            self.assertIn("AssertionError", mutant.stderr)
