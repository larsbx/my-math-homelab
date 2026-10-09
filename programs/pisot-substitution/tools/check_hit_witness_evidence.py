#!/usr/bin/env python3
"""Check committed hit-witness export integrity, optionally against a live run.

This is provenance tooling, not another implementation of catch-up reachability.
The canonical computation is kernel/psc/hit_witness.mojo. A matching export
certifies only the recorded finite domain, never a universal proof obligation.
"""

import argparse
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "evidence/catch-up-hits-2026-10-04"
FIELDS = {"schema", "i", "j", "k", "vertex", "catch_left", "catch_right", "new_left", "new_right"}


def check() -> None:
    if not __debug__:
        raise RuntimeError("evidence assertions must be enabled; refusing an unchecked run")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--live-output", type=Path)
    parser.add_argument("--entry", default="standing")
    args = parser.parse_args()
    manifest = json.loads((EVIDENCE / "manifest.json").read_text())
    assert manifest["schema"] == 1
    selected = None
    for entry in manifest["entries"]:
        packed = (EVIDENCE / entry["file"]).read_bytes()
        assert hashlib.sha256(packed).hexdigest() == entry["sha256"], entry["file"]
        payload = gzip.decompress(packed)
        assert hashlib.sha256(payload).hexdigest() == entry["payload_sha256"]
        seen = set()
        specimens = set()
        for line in payload.splitlines():
            r = json.loads(line)
            assert set(r) == FIELDS and r["schema"] == 1
            assert all(type(r[k]) is int for k in FIELDS - {"vertex"})
            assert len(r["vertex"]) == 5 and all(type(v) is int for v in r["vertex"])
            assert all(r[k] >= 0 for k in ("i", "j", "k"))
            assert all(0 <= v < 3 for v in r["vertex"][:2])
            assert any(r["vertex"][2:]), "offset-zero vertex outside the export contract"
            assert r["catch_left"] == r["catch_right"] == -1
            assert r["new_left"] >= 1 and r["new_right"] >= 1
            specimen = (r["i"], r["j"], r["k"])
            identity = specimen + tuple(r["vertex"])
            assert identity not in seen, "duplicate stable specimen/vertex label"
            seen.add(identity)
            specimens.add(specimen)
        assert len(seen) == entry["records"]
        assert len(specimens) == entry["failing_specimens"]
        summary = (EVIDENCE / (entry["name"] + "-summary.txt")).read_text().splitlines()
        assert summary == entry["summary"]
        if entry["name"] == args.entry:
            selected = (entry, payload)
        print(f"OK {entry['name']}: {len(seen)} labelled failures in {len(specimens)} specimens")
    assert selected is not None, "unknown evidence entry"
    if args.live_output is not None:
        entry, payload = selected
        lines = args.live_output.read_text().splitlines()
        assert lines[:5] == entry["summary"], "live domain, caps or census totals differ"
        live = ("\n".join(lines[5:]) + "\n").encode()
        assert live == payload, "live per-vertex export differs from committed evidence"
        print(f"OK live {args.entry}: exact ordered export matches the committed evidence")


if __name__ == "__main__":
    check()
