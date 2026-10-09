#!/usr/bin/env python3
"""Independent oracle for the formal-overlap carrier census receipts.

Recomputes the carriers of a strided sample of the corpus, plus any named
specimens, with ``psc_research.formal_overlap`` (its own box, tolerance, root
finder and SCC algorithm) and compares them with
``evidence/formal-overlap-carriers-2026-10-04/carriers.jsonl``. Also
checks that the receipt covers exactly the corpus labels it names and that its
summary totals are the sums of its records. Agreement is evidence about the
checked specimens only.

Usage: ``tools/check_formal_overlap_receipts.py [--stride N] [--label I J K ...]``
"""
from __future__ import annotations

import argparse
import itertools
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "reference"))
from psc_research.formal_overlap import Carrier, carriers  # noqa: E402
from psc_research.pip_screen import pip_corpus  # noqa: E402

EVIDENCE = ROOT / "evidence/formal-overlap-carriers-2026-10-04"
WORDS = [w for n in (1, 2, 3) for w in itertools.product((1, 2, 3), repeat=n)]


def corpus_labels() -> list[tuple[int, int, int]]:
    """The standing corpus in canonical order, as image-word indices."""
    index = {w: n for n, w in enumerate(WORDS)}
    return [tuple(index[tuple(s[a])] for a in (1, 2, 3)) for s in pip_corpus()]


def records() -> dict[tuple[int, int, int], list[Carrier]]:
    out: dict[tuple[int, int, int], list[Carrier]] = defaultdict(list)
    for line in (EVIDENCE / "carriers.jsonl").read_text().splitlines():
        r = json.loads(line)
        out[(r["i"], r["j"], r["k"])].append(
            Carrier(r["size"], r["cyclomatic"], r["realized"], r["closed"], r["aligned"], r["direct"], r["death"],
                    r["aligned_depth"], r["proper_aligned_depth"]))
    return out


def summary_matches(recs: dict[tuple[int, int, int], list[Carrier]]) -> None:
    text = (EVIDENCE / "summary.txt").read_text()
    every = [c for cs in recs.values() for c in cs]
    assert f"formal carriers: {len(every)} " in text
    for name, flag in (("unrealized", False), ("realized", True)):
        cs = [c for c in every if c.realized == flag]
        line = (f"{name} carriers: {len(cs)}  aligned: {sum(c.aligned for c in cs)}  "
                f"strict: {sum(not c.aligned for c in cs)}  closed: {sum(c.closed for c in cs)}  "
                f"with a direct coincidence child: {sum(c.direct for c in cs)}")
        assert line in text, line
        depths = Counter(c.death for c in cs)
        hist = " ".join(f"{d}:{depths[d]}" for d in sorted(depths))
        assert f"{name} carriers by death depth: {hist}" in text, name


def key(c: Carrier) -> tuple:
    return tuple(vars(c).values())


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--stride", type=int, default=0)
    ap.add_argument("--label", type=int, nargs=3, action="append", default=[])
    args = ap.parse_args()
    recs = records()
    labels = corpus_labels()
    assert len(labels) == 4554 and set(recs) <= set(labels), "receipt names a label outside the corpus"
    summary_matches(recs)
    sample = labels[:: args.stride] if args.stride else []
    sample += [tuple(x) for x in args.label]
    for label in sample:
        sigma = {a + 1: WORDS[label[a]] for a in range(3)}
        found, nonproductive = carriers(sigma)
        assert nonproductive == 0, f"{label}: formal nonproductive state"
        assert found == sorted(recs.get(label, []), key=key), f"{label}: carriers disagree"
    print(f"formal-overlap receipts: summary consistent; {len(sample)} specimens recomputed and equal")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
