#!/usr/bin/env python3
"""Recompute the content-addressed identifiers of research/ledger.json in place.

Authoring aid only: a dependency edge may name its target as ``@Name`` (or by a
stale identifier of a record in the ledger), and sealing rewrites every
identifier in dependency order. The generator (vendor/proof_records) still
verifies every identifier; sealing decides nothing, it only saves arithmetic.

Usage: seal_ledger.py [LEDGER]   (default research/ledger.json)
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "vendor"))

from proof_records.generate_ledgers import record_from_json  # noqa: E402
from proof_records.records import identity  # noqa: E402


def seal(data: dict) -> dict:
    records = data["records"]
    name_of = {r["id"]: name for name, r in records.items() if r.get("id")}

    def target(ref: str) -> str:
        name = ref[1:] if ref.startswith("@") else name_of.get(ref)
        if name not in records:
            raise ValueError(f"edge target {ref!r} names no record; write it as @Name")
        return name

    sealed: dict[str, str] = {}

    def visit(name: str, path: tuple[str, ...] = ()) -> str:
        if name in path:
            raise ValueError(f"dependency cycle through {name}")
        if name not in sealed:
            rec = records[name]
            for edge in rec.get("depends_on", []):
                edge[0] = visit(target(edge[0]), path + (name,))
            rec["id"] = identity(record_from_json({**rec, "id": ""}))
            sealed[name] = rec["id"]
        return sealed[name]

    for name in records:
        visit(name)
    return data


def main(argv: list[str]) -> int:
    path = Path(argv[1]) if len(argv) > 1 else ROOT / "research" / "ledger.json"
    path.write_text(json.dumps(seal(json.loads(path.read_text(encoding="utf-8"))), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"sealed {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
