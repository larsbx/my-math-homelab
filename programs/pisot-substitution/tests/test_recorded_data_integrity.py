"""Recorded data is pinned: every SHA256SUMS verifies, and an evidence packet lists every file it holds.

evidence/ holds recorded run outputs, sources/ imported external material, archive/ superseded
records; all are verbatim, so a checksum mismatch is a modified record, never a refresh.
"""

from __future__ import annotations

import hashlib
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
SUMS = sorted(p for plane in ("evidence", "sources", "archive") for p in (ROOT / plane).glob("**/SHA256SUMS"))


def entries(sums: Path) -> dict[Path, str]:
    """``./x`` and a bare name are packet-relative; any other path is repository-relative (``sha256sum -c`` from the root)."""
    rows = (line.split(maxsplit=1) for line in sums.read_text(encoding="utf-8").splitlines() if line.strip())
    rels = ((digest, rel.strip()) for digest, rel in rows)
    return {(ROOT if "/" in rel and not rel.startswith("./") else sums.parent) / rel: digest for digest, rel in rels}


def test_every_evidence_packet_is_pinned():
    packets = [p for p in (ROOT / "evidence").iterdir() if p.is_dir()]
    assert packets and all((p / "SHA256SUMS").is_file() for p in packets)


@pytest.mark.parametrize("sums", SUMS, ids=lambda p: p.relative_to(ROOT).as_posix())
def test_checksums_verify(sums):
    pinned = entries(sums)
    assert pinned
    for path, digest in pinned.items():
        assert path.is_file(), path.relative_to(ROOT)
        assert hashlib.sha256(path.read_bytes()).hexdigest() == digest, path.relative_to(ROOT)
    if sums.is_relative_to(ROOT / "evidence"):
        held = {p for p in sums.parent.rglob("*") if p.is_file() and p != sums}
        assert held == set(pinned), "an evidence packet pins exactly the files it holds"
