import hashlib
import json
import unittest

from support import ROOT, load

from proof_records.generate_ledgers import load_ledger
from proof_records.records import validate

GUARDS_CLAIM = "N3BaselineGrid"
LEDGER = load_ledger(ROOT / "research" / "ledger.json")


def evidence(name: str, key: str) -> str:
    return LEDGER.records[name].field(key)


class TestLedgerEvidence(unittest.TestCase):
    def test_every_record_validates(self):
        for name, record in LEDGER.records.items():
            with self.subTest(name=name):
                self.assertEqual(validate(record), record)

    def test_shell_count_digest_replays(self):
        H = load("experiments/n3/hurwitz_shell.py", "hurwitz_shell_ledger")
        sizes = json.dumps([len(H.shell(n)) for n in range(1, 201)]).encode()
        self.assertEqual(evidence("HurwitzShellCountFinite", "digest"), "sha256:" + hashlib.sha256(sizes).hexdigest())

    def test_grid_digest_replays(self):
        grid = (ROOT / "data" / "n3" / "grid-v1.json").read_bytes()
        self.assertEqual(evidence("N3BaselineGrid", "digest"), "sha256:" + hashlib.sha256(grid).hexdigest())


if __name__ == "__main__":
    unittest.main()
