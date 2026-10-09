#!/usr/bin/env python3
"""Check (or write) the ESTATE.toml pins that this repository can compute itself.

The pin of a vendoring [[dep]] is the estate audit's digest of the vendored.toml
rows for that repository. Each row records a package's name, commit and root,
and the recorded and actual SHA-256 of every listed file; the rows are encoded
as canonical JSON and hashed with SHA-256. The estate-governance pin (the audit's
own hash) is not computed here; the CI policy job verifies it.

Usage: estate_pins.py            check; exit 1 and print the expected pins on drift
       estate_pins.py --write    rewrite drifted pins in ESTATE.toml in place
"""
from __future__ import annotations

import hashlib
import json
import re
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def vendored_digest(repository: str, root: Path = ROOT) -> str:
    rows = []
    for package in tomllib.loads((root / "vendored.toml").read_text(encoding="utf-8"))["package"]:
        if package["repository"] != repository:
            continue
        files = {}
        for rel, recorded in sorted(package["files"].items()):
            actual = hashlib.sha256((root / package["root"] / rel).read_bytes()).hexdigest()
            if actual != recorded:
                raise SystemExit(f"vendored file drift: {rel} (run vendor/vendoring/check_vendored_sync.py)")
            files[rel] = {"recorded": recorded, "actual": actual}
        rows.append({"name": package["name"], "commit": package["commit"], "root": package["root"], "files": files})
    rows.sort(key=lambda row: row["name"])
    return "sha256:" + hashlib.sha256(json.dumps(rows, sort_keys=True, separators=(",", ":")).encode()).hexdigest()


def expected_pins(root: Path = ROOT) -> dict[str, str]:
    """dep id -> expected pin, for every repository vendored.toml draws from."""
    sources = {p["repository"] for p in tomllib.loads((root / "vendored.toml").read_text(encoding="utf-8"))["package"]}
    return {source.split("/")[1]: vendored_digest(source, root) for source in sorted(sources)}


def drift(root: Path = ROOT) -> dict[str, tuple[str | None, str]]:
    deps = {d["id"]: d.get("pin") for d in tomllib.loads((root / "ESTATE.toml").read_text(encoding="utf-8")).get("dep", [])}
    return {dep: (deps.get(dep), pin) for dep, pin in expected_pins(root).items() if deps.get(dep) != pin}


def main(argv: list[str]) -> int:
    bad = drift()
    if not bad:
        print("OK: ESTATE.toml vendoring pins match vendored.toml")
        return 0
    if argv[1:] == ["--write"]:
        text = (ROOT / "ESTATE.toml").read_text(encoding="utf-8")
        for dep, (old, new) in bad.items():
            if old is None:
                raise SystemExit(f"ESTATE.toml has no [[dep]] {dep}; add one with pin = \"{new}\"")
            text = re.sub(re.escape(old), new, text, count=1)
        (ROOT / "ESTATE.toml").write_text(text, encoding="utf-8")
        print("rewrote: " + ", ".join(bad))
        return 0
    for dep, (old, new) in bad.items():
        print(f"ESTATE.toml [[dep]] {dep}: pin {old} != {new} (run python tools/estate_pins.py --write)")
    return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
