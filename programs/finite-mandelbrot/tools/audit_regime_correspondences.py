#!/usr/bin/env python3
"""Validate analytic-to-finite correspondence declarations and Mojo bindings."""

from __future__ import annotations
import re
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "schemas/regime_correspondences.toml"
SYMBOL_RE = re.compile(r"^(?:struct|def|fn)\s+([A-Za-z_][A-Za-z0-9_]*)", re.MULTILINE)
REQUIRED_FIELDS = {"id", "analytic_concepts", "finite_term", "class", "status", "preserves", "does_not_inherit", "domain_conditions", "symbols", "evidence", "proof_boundary"}


def load_spec() -> dict:
    with SPEC.open("rb") as handle:
        return tomllib.load(handle)


def tagged_symbols(path: Path) -> dict[str, set[str]]:
    result: dict[str, set[str]] = {}
    pending: str | None = None
    for line in path.read_text(encoding="utf-8").splitlines():
        tag = re.match(r"^\s*#\s*Regime correspondence:\s*([a-z0-9][a-z0-9-]*)\s*$", line)
        if tag:
            pending = tag.group(1)
            continue
        symbol = re.match(r"^(?:struct|def|fn)\s+([A-Za-z_][A-Za-z0-9_]*)", line)
        if symbol and pending:
            result.setdefault(pending, set()).add(symbol.group(1))
            pending = None
        elif line.strip() and not line.lstrip().startswith("#"):
            pending = None
    return result


def audit() -> list[str]:
    if not SPEC.exists():
        return ["schemas/regime_correspondences.toml is missing"]
    try:
        data = load_spec()
    except (OSError, tomllib.TOMLDecodeError) as exc:
        return [f"cannot load correspondence spec: {exc}"]
    errors: list[str] = []
    allowed_classes = set(data.get("allowed_classes", []))
    allowed_statuses = set(data.get("allowed_statuses", []))
    entries = data.get("correspondence", [])
    ids: set[str] = set()
    bindings: set[tuple[str, str, str]] = set()
    if data.get("schema_version") != 1:
        errors.append("schema_version must be 1")
    if not entries:
        errors.append("at least one correspondence is required")
    for index, entry in enumerate(entries):
        missing = REQUIRED_FIELDS - set(entry)
        if missing:
            errors.append(f"entry {index}: missing fields {sorted(missing)}")
            continue
        entry_id = entry["id"]
        if entry_id in ids:
            errors.append(f"duplicate correspondence id {entry_id!r}")
        ids.add(entry_id)
        if entry["class"] not in allowed_classes:
            errors.append(f"{entry_id}: unknown class {entry['class']!r}")
        if entry["status"] not in allowed_statuses:
            errors.append(f"{entry_id}: unknown status {entry['status']!r}")
        for field in ("analytic_concepts", "preserves", "does_not_inherit", "domain_conditions", "evidence"):
            if not entry[field] or not all(isinstance(item, str) and item.strip() for item in entry[field]):
                errors.append(f"{entry_id}: {field} must be a nonempty string list")
        for evidence in entry["evidence"]:
            if not (ROOT / evidence).exists():
                errors.append(f"{entry_id}: missing evidence path {evidence!r}")
        if entry["class"] == "prohibited_correspondence" and entry["symbols"]:
            errors.append(f"{entry_id}: prohibited correspondence must not bind executable symbols")
        for reference in entry["symbols"]:
            if reference.count("::") != 1:
                errors.append(f"{entry_id}: invalid symbol reference {reference!r}")
                continue
            path_text, symbol = reference.split("::")
            path = ROOT / path_text
            if not path.exists():
                errors.append(f"{entry_id}: missing symbol file {path_text}")
                continue
            if symbol not in SYMBOL_RE.findall(path.read_text(encoding="utf-8")):
                errors.append(f"{entry_id}: symbol {symbol!r} does not exist in {path_text}")
                continue
            if symbol not in tagged_symbols(path).get(entry_id, set()):
                errors.append(f"{entry_id}: {reference} lacks its source correspondence tag")
            bindings.add((path_text, symbol, entry_id))
    for path in (ROOT / "kernel" / "mojo").rglob("*.mojo"):
        path_text = path.relative_to(ROOT).as_posix()
        for entry_id, symbols in tagged_symbols(path).items():
            if entry_id not in ids:
                errors.append(f"{path_text}: undeclared correspondence tag {entry_id!r}")
            for symbol in symbols:
                if (path_text, symbol, entry_id) not in bindings:
                    errors.append(f"{path_text}::{symbol}: tag {entry_id!r} is not bound in the spec")
    return errors


def main() -> int:
    errors = audit()
    if errors:
        print("Regime correspondence audit failed:")
        for error in errors:
            print(f"- {error}")
        return 1
    print("Regime correspondence audit passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
