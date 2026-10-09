"""Cross-check reviewed proof provenance and linked theorem/ledger status."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "vendor"))
from proof_records.generate_ledgers import analyse, load_ledger

# Explicit links prevent deleting a registry field from bypassing reconciliation.
THEOREM_RECORDS = {"N1-T01": "ZeroDivisorCertificateSoundness"}


def check_provenance(root: Path) -> None:
    ledger = load_ledger(root / "research/ledger.json")
    for name, record in ledger.records.items():
        if record.field("proof_reviewed") == "true":
            if not (record.field("independent_reviewer") or "").strip() or not (record.field("review") or "").strip():
                raise ValueError(f"{name}: reviewed proof requires independent_reviewer and review evidence")
    entries = {entry.name: entry for entry in analyse(ledger).entries}
    theorems = json.loads((root / "research/theorems.json").read_text())["theorems"]
    by_id = {t["id"]: t for t in theorems}
    for theorem_id, name in THEOREM_RECORDS.items():
        theorem = by_id[theorem_id]
        if theorem.get("ledger_record") != name:
            raise ValueError(f"{theorem_id}: missing ledger link to {name}")
        expected = ledger.status_labels[entries[name].status]
        if theorem["claim_class"] != expected:
            raise ValueError(f"{theorem_id}: registry status differs from {name}: expected {expected}")


if __name__ == "__main__":
    check_provenance(ROOT)
    print("OK: proof-review provenance and linked theorem status agree")
