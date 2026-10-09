"""Validate registry syntax, authority-plane locators, and proof evidence links."""

from pathlib import Path
import tomllib

ROOT = Path(__file__).resolve().parents[1]


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def local_file(path):
    require(isinstance(path, str) and path, "missing evidence path")
    resolved = (ROOT / path).resolve()
    require(resolved.is_relative_to(ROOT) and resolved.is_file(), f"missing local file: {path}")
    return resolved


def main():
    estate = tomllib.loads((ROOT / "ESTATE.toml").read_text())
    registry = tomllib.loads((ROOT / "proof/claims.toml").read_text())
    require(estate["repo"]["slug"] == "larsbx/arithmetic-bicycle-conjecture-research", "wrong estate")
    for plane in estate["plane"]:
        if plane["required"]:
            for path in plane["current"]:
                require((ROOT / path).exists(), f"missing required authority surface: {path}")
    statuses = set(registry["meta"]["status_values"])
    ids = set()
    for claim in registry["claim"]:
        require(claim["id"] not in ids, f"duplicate claim: {claim['id']}")
        ids.add(claim["id"])
        require(claim["status"] in statuses, f"invalid state: {claim['id']}")
        if claim["status"] == "proved":
            record = local_file(claim.get("proof_record"))
            require(claim["id"] in record.read_text(), "proof record does not identify its claim")
            local_file(claim.get("audit_record"))
            require(claim.get("evidence"), "proved claim has no independent evidence locators")
            for path in claim["evidence"]:
                local_file(path)
    require("ABC-GRAPH-MODULAR-BICYCLE" in ids, "missing graph claim")
    print(f"PASS: {len(ids)} claims; required authority surfaces and proof locators exist")


if __name__ == "__main__":
    main()
