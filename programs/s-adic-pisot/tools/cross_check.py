#!/usr/bin/env python3
"""Compare the Mojo vector battery (kernel/vectors.mojo) with the Python oracle.

Usage: cross_check.py MOJO_OUTPUT

Recomputes every line of the battery with `reference/sadic_reference` and
fails closed on any difference, missing line or extra line.
"""

from __future__ import annotations

import sys
from itertools import product
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "reference"))

from sadic_reference.periodic import brun_full_classes, brun_unordered, is_pip, periodic_verdict, periodic_words  # noqa: E402
from sadic_reference.overlap import morphic_balance_bound, positive_suffix_ratio, return_overlap_bound, window_overlap_bound  # noqa: E402
from sadic_reference.spectrum import Inconclusive, charpoly, disc_zero_count, irreducibility_verdict, pisot_verdict, primitivity_exponent  # noqa: E402
from sadic_reference import (  # noqa: E402
    arnoux_rauzy,
    brun3,
    cross_ratio_bound,
    first_positive_prefix,
    image_balance,
    is_positive,
    positive_blocks,
    prefix_matrix,
)

MAX_LEN = 5
SPECTRAL_LEN = 4
PERIODIC_LEN = 6
BRUN5_LEN = 6
BRUN5_CLASS_LEN = 7
POLYNOMIALS = (
    (-1, 5, -10, 10, -6, 1),
    (1, 0, 0, 0, 1),
    (1, -4, 6, -5, 1),
    (-1, -1, -1, -1, 1),
    (1, 1, 1, -1, -1, -1, 1),
    (1, -6, 16, -24, 20, -9, 1),
)
BPA_STATES = 20000
BPA_LENGTH = 2000


def spectral_lines(key: str, word: str, m) -> list[str]:
    f = charpoly(m)
    verdict, witness = irreducibility_verdict(f)
    out = [f"{key}|charpoly|{word}|" + ",".join(map(str, f)),
           f"{key}|primitivity|{word}|{primitivity_exponent(m)}",
           f"{key}|irreducible|{word}|{verdict},{witness}"]
    if verdict == 1:
        out.append(f"{key}|pisot|{word}|{pisot_verdict(f)}")
    return out


def polynomial_lines(f) -> list[str]:
    word = ",".join(map(str, f))
    verdict, witness = irreducibility_verdict(f)
    try:
        disc = str(disc_zero_count(f))
    except Inconclusive:
        disc = "inc"
    out = [f"poly|irreducible|{word}|{verdict},{witness}", f"poly|disc|{word}|{disc}"]
    if verdict == 1:
        out.append(f"poly|pisot|{word}|{pisot_verdict(f)}")
    return out


def battery() -> list[str]:
    out = [f"balance|morphic-{d}-{c}-{j}||{morphic_balance_bound(d, c, j)}"
           for d in range(1, 5) for c in range(4) for j in range(1, 5)]
    out.append(f"anchor-ar3|window||{window_overlap_bound(prefix_matrix(arnoux_rauzy(3), (0, 1, 2)), 3, 2, 9)}")
    for shift in (arnoux_rauzy(2), arnoux_rauzy(3), brun3()):
        key = shift.name
        for n in range(MAX_LEN + 1):
            for w in product(range(shift.labels), repeat=n):
                digits = "".join(map(str, w))
                m = prefix_matrix(shift, w)
                out.append(f"{key}|matrix|{digits}|" + ",".join(str(x) for row in m for x in row))
                out.append(f"{key}|first-positive|{digits}|{first_positive_prefix(shift, w)}")
                if is_positive(m):
                    r = cross_ratio_bound(m)
                    out.append(f"{key}|cross-ratio|{digits}|{r.numerator}/{r.denominator}")
                    suffix = positive_suffix_ratio(m)
                    out.append(f"{key}|suffix-ratio|{digits}|{suffix.numerator}/{suffix.denominator}")
                    for c in range(4):
                        out.append(f"{key}|return-overlap-{c}|{digits}|{return_overlap_bound(m, c)}")
                        for window in range(3):
                            out.append(f"{key}|window-overlap-{c}-{window}|{digits}|{window_overlap_bound(m, c, 2, window)}")
                for a in range(shift.size):
                    out.append(f"{key}|image-balance-{a}|{digits}|{image_balance(shift, w, a)}")
        out += [f"{key}|positive-block|{''.join(map(str, w))}|1" for w in positive_blocks(shift, MAX_LEN)]
    for shift in (arnoux_rauzy(3), brun3()):
        for n in range(1, SPECTRAL_LEN + 1):
            for w in product(range(shift.labels), repeat=n):
                out += spectral_lines(shift.name, "".join(map(str, w)), prefix_matrix(shift, w))
    shift = brun_unordered(4)
    for n in range(1, PERIODIC_LEN + 1):
        for w in periodic_words(shift, n):
            verdict = periodic_verdict(shift, w, BPA_STATES, BPA_LENGTH)
            out.append(f"{shift.name}|periodic|" + ",".join(map(str, w)) + f"|{verdict}")
    for f in POLYNOMIALS:
        out += polynomial_lines(f)
    shift = brun_unordered(5)
    for n in range(1, BRUN5_LEN + 1):
        for w in periodic_words(shift, n):
            out += spectral_lines(shift.name, ",".join(map(str, w)), prefix_matrix(shift, w))
    for n in range(1, BRUN5_CLASS_LEN + 1):
        classes = brun_full_classes(5, n)
        out.append(f"brun5|classes|{n}|{len(classes)},{sum(is_pip(shift, w) for w in classes)}")
    return out


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print(__doc__)
        return 2
    mojo = [line for line in Path(argv[1]).read_text(encoding="utf-8").splitlines() if "|" in line]
    oracle = battery()
    if mojo == oracle:
        print(f"OK: {len(oracle)} facts agree between the Mojo kernel and the Python oracle")
        return 0
    only_mojo = sorted(set(mojo) - set(oracle))
    only_oracle = sorted(set(oracle) - set(mojo))
    print(f"cross-language disagreement: {len(only_mojo)} Mojo-only, {len(only_oracle)} oracle-only lines")
    for line in only_mojo[:10]:
        print("  mojo:  ", line)
    for line in only_oracle[:10]:
        print("  oracle:", line)
    if not only_mojo and not only_oracle:
        print("  same facts in a different order")
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
