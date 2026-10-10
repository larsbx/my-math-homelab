"""Fail closed on disagreement between the claim ledger and dossier headings."""

from __future__ import annotations

import argparse
from pathlib import Path
import re
import tomllib

ROOT = Path(__file__).resolve().parents[1]
ALLOWED = {
    "PROVED", "COMPUTED", "IMPORTED", "CANDIDATE", "HEURISTIC", "OPEN", "WITHDRAWN"
}
CLAIM_ID = re.compile(r"PV-[A-Z0-9]+(?:-[A-Z0-9]+)*")
CLAIM_HEADING = re.compile(r" {0,3}### (PV-[A-Z0-9-]+) — ([A-Z]+)\s*")


def dossier_statuses(dossier: str) -> tuple[dict[str, str], list[str]]:
    """Read actual claim headings, ignoring fenced examples and HTML comments."""
    statuses: dict[str, str] = {}
    errors: list[str] = []
    fence: tuple[str, int] | None = None
    dossier = re.sub(r"<!--.*?-->", "", dossier, flags=re.DOTALL)
    for number, line in enumerate(dossier.splitlines(), start=1):
        if fence is not None:
            char, length = fence
            if re.fullmatch(rf" {{0,3}}{char}{{{length},}}\s*", line):
                fence = None
            continue
        opening = re.match(r" {0,3}(\x60{3,}|~{3,})", line)
        if opening:
            marker = opening.group(1)
            fence = (marker[0], len(marker))
            continue
        if not re.match(r" {0,3}#{1,6}\s+PV-", line):
            continue
        heading = CLAIM_HEADING.fullmatch(line)
        if heading is None:
            errors.append(
                f"docs/dossier.md:{number}: malformed claim heading; "
                "expected '### PV-CLAIM-ID — STATUS'"
            )
            continue
        cid, status = heading.groups()
        if not CLAIM_ID.fullmatch(cid):
            errors.append(f"docs/dossier.md:{number}: invalid claim id {cid!r}")
        if cid in statuses:
            errors.append(f"{cid}: duplicate dossier claim heading")
        else:
            statuses[cid] = status
        if status not in ALLOWED:
            errors.append(f"{cid}: invalid dossier status {status!r}")
    return statuses, errors


def validate_claims(data: dict, dossier: str) -> list[str]:
    """Return all ledger/dossier errors; no status is inferred from prose."""
    claims = data.get("claim")
    if not isinstance(claims, list) or not claims:
        return ["no claims declared"]
    statuses, errors = dossier_statuses(dossier)
    ids: set[str] = set()
    for claim in claims:
        if not isinstance(claim, dict):
            errors.append("invalid claim record")
            continue
        cid, status = claim.get("id"), claim.get("status")
        if not isinstance(cid, str) or not CLAIM_ID.fullmatch(cid):
            errors.append(f"invalid claim id: {cid!r}")
            continue
        if cid in ids:
            errors.append(f"duplicate ledger claim id: {cid}")
        ids.add(cid)
        if not isinstance(status, str) or status not in ALLOWED:
            errors.append(f"{cid}: invalid ledger status {status!r}")
        if cid not in statuses:
            errors.append(f"{cid}: missing claim heading from docs/dossier.md")
        elif statuses[cid] != status:
            errors.append(
                f"{cid}: status mismatch: ledger={status}, dossier={statuses[cid]}"
            )
        for field in ("statement", "does_not_establish"):
            value = claim.get(field)
            if not isinstance(value, str) or not value.strip():
                errors.append(f"{cid}: missing {field}")
    for cid in sorted(statuses.keys() - ids):
        errors.append(f"{cid}: dossier claim has no authoritative ledger record")
    return errors


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT)
    args = parser.parse_args()
    try:
        data = tomllib.loads(
            (args.root / "proof" / "claims.toml").read_text(encoding="utf-8")
        )
        dossier = (args.root / "docs" / "dossier.md").read_text(encoding="utf-8")
    except (OSError, tomllib.TOMLDecodeError) as exc:
        raise SystemExit(f"claim audit failed: {exc}") from exc
    errors = validate_claims(data, dossier)
    if errors:
        raise SystemExit("\n".join(errors))
    print(
        f"claim audit: {len(data['claim'])} claims, "
        "ledger and dossier statuses match one for one"
    )


if __name__ == "__main__":
    main()
