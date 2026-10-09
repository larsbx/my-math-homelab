from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import grow_corpus as grow  # noqa: E402


def test_band_partition_sizes_and_identity_are_stable():
    assert grow.image_word_count(3) == 39
    assert grow.image_word_count(4) == 120
    assert grow.band_total(3) == 57_591
    assert grow.band_total(4) == 1_668_681

    seen = set()
    previous = grow.image_word_count(1)
    width = grow.image_word_count(2)
    for offset in range(grow.band_total(2)):
        triple = grow.band_indices(2, offset)
        assert max(triple) >= previous
        flat = (triple[0] * width + triple[1]) * width + triple[2]
        assert flat not in seen
        seen.add(flat)


def test_initial_state_starts_after_the_frozen_theorem_corpus():
    path = ROOT / "experiments" / "growing-corpus" / "state.json"
    state = json.loads(path.read_text(encoding="utf-8"))
    assert state["schema"] == grow.STATE_SCHEMA
    assert state["alphabet"] == 3
    assert state["next_max_image_length"] == 4
    assert state["next_band_offset"] == 0
    assert state["total_screened"] == 0
    assert state["total_accepted"] == 0


def test_driver_parser_rejects_count_drift():
    text = "\n".join(
        [
            "schema\tpsc-growing-corpus-shard/v1",
            "max_image_length\t4",
            "start_offset\t0",
            "screened\t1",
            "accepted\t0",
            "next_offset\t1",
            "band_total\t1668681",
            "columns\toffset\tsubstitution\tchi0\tchi1\tchi2",
        ]
    )
    header, accepted = grow.parse_driver_output(text)
    assert accepted == []
    assert header["schema"] == grow.SHARD_SCHEMA


def test_known_band_offset_reconstructs_a_three_image_substitution():
    key = grow.sigma_key_for_offset(4, 0)
    parts = key.split("/")
    assert len(parts) == 3
    assert len(parts[0]) == 4
    assert all(set(part) <= set("012") for part in parts)
