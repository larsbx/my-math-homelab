"""Independent-oracle checks of the formal-overlap carrier census receipts."""
from __future__ import annotations

import itertools
import json
from collections import defaultdict
from pathlib import Path

import pytest

from psc_research.formal_overlap import Carrier, carriers

EVIDENCE = Path(__file__).resolve().parents[1] / "evidence/formal-overlap-carriers-2026-10-04"
WORDS = [w for n in (1, 2, 3) for w in itertools.product((1, 2, 3), repeat=n)]


def _records() -> dict[tuple[int, int, int], list[Carrier]]:
    out: dict[tuple[int, int, int], list[Carrier]] = defaultdict(list)
    for line in (EVIDENCE / "carriers.jsonl").read_text().splitlines():
        r = json.loads(line)
        out[(r["i"], r["j"], r["k"])].append(Carrier(
            r["size"], r["cyclomatic"], r["realized"], r["closed"], r["aligned"], r["direct"], r["death"],
            r["aligned_depth"], r["proper_aligned_depth"]))
    return out


RECORDS = _records()


def test_census_records_are_well_formed() -> None:
    every = [c for cs in RECORDS.values() for c in cs]
    assert every, "the census recorded no carrier"
    assert not any(c.closed for c in every), "a closed formal carrier is a nonproductive obstruction"
    assert all(c.death >= 1 and c.size >= 1 and c.cyclomatic >= 1 for c in every)
    # a coincidence is offset zero, so the first offset-zero hit is never later
    assert all(0 <= c.aligned_depth <= c.death for c in every)


# Fast specimens: the Padovan/plastic substitution with one realized and one
# unrealized carrier, and its neighbour with a single realized carrier.
@pytest.mark.parametrize("label", [(1, 2, 4), (1, 2, 5)])
def test_oracle_reproduces_canonical_carriers(label: tuple[int, int, int]) -> None:
    sigma = {a + 1: WORDS[label[a]] for a in range(3)}
    found, nonproductive = carriers(sigma)
    assert nonproductive == 0
    canonical = sorted(RECORDS[label], key=lambda c: tuple(vars(c).values()))
    assert found == canonical
