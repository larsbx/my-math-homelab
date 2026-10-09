#!/usr/bin/env python3
"""Dimension semantics of Tier 2 loop-gain fixtures.

``schemas/tier2-loop-gain-fixture.schema.json`` fixes the shape of a fixture
and pins each fixed channel (``CHANNELS``) to its power basis and loop
composition. The rest is checked here: a recurrent component has at least
one vertex and one edge (the schema's ``minItems``, repeated so the check
fails closed on its own; an empty component is invalid evidence, not a
trivial module), every gain vector and every generated-module generator has
exactly one coordinate per basis label, the labels are distinct, a power
basis has rank equal to the degree of its monic minimal polynomial, and a
``beta_twisted`` composition (loop gain ``sum_i beta^(k-1-i) d_i``) is
declared only over a power basis, where ``beta`` acts. A fixture failing any
check has no unambiguous exact interpretation, so it is rejected rather than
read.

Usage:
    check_tier2_fixture.py FIXTURE.json...   exit 1 if any fixture is ill-formed,
                                             exit 2 if no fixture is given
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

SCHEMA = Path(__file__).resolve().parents[1] / "schemas" / "tier2-loop-gain-fixture.schema.json"

# Channels fixed by name: (basis rank, loop composition). Mirrored by the
# schema's ``allOf`` conditionals; tests/test_tier2_fixture_check.py keeps the
# two in sync. affine_forcing labels w' = beta*w + (q - p), so loops compose
# affinely: see docs/tier2-loop-gain-literature-gate-2026-09-27.md, Finding 5.
CHANNELS = {"affine_forcing": (3, "beta_twisted")}


def dimension_errors(doc: dict) -> tuple[str, ...]:
    basis = doc["arithmetic_basis"]
    labels = basis["labels"]
    rank = len(labels)
    channel = doc["gain_channel"]
    composition = doc["loop_composition"]
    power_basis = basis["kind"] == "integer_power_basis"
    poly = basis.get("minimal_polynomial")
    vectors = [(f"edge {e['edge_id']}", e["gain_coordinates"]) for e in doc["edges"]] + [
        (f"generator {i}", g) for i, g in enumerate(doc.get("generated_module_generators", []))
    ]
    checks = [
        (not doc["vertices"] or not doc["edges"], "a recurrent component needs a vertex and an edge"),
        (len(set(labels)) != rank, "basis labels are not distinct"),
        (
            channel in CHANNELS and (not power_basis or (rank, composition) != CHANNELS[channel]),
            f"channel {channel} requires (rank, composition) {CHANNELS.get(channel)} over a power basis",
        ),
        (
            composition == "beta_twisted" and not power_basis,
            "a beta_twisted composition needs the power basis beta acts on",
        ),
        (power_basis and poly is None, "a power basis needs its minimal polynomial"),
        (
            poly is not None and (len(poly) != rank + 1 or poly[-1] != 1),
            f"minimal polynomial must be monic of degree {rank} (the basis rank)",
        ),
    ] + [
        (len(v) != rank, f"{name} has {len(v)} coordinates for a rank-{rank} basis")
        for name, v in vectors
    ]
    return tuple(msg for failed, msg in checks if failed)


def main(paths: list[str]) -> int:
    if not paths:
        print(__doc__.split("Usage:")[1].rstrip(), file=sys.stderr)
        return 2
    failures = [
        f"{p}: {msg}" for p in paths for msg in dimension_errors(json.loads(Path(p).read_text()))
    ]
    print("\n".join(failures) or f"{len(paths)} Tier 2 fixture(s) dimensionally consistent")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
