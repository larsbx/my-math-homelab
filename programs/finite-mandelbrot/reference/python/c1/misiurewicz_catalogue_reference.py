#!/usr/bin/env python3
"""Python reference for kernel/mojo/certificates/misiurewicz_catalogue.mojo.

Integer arithmetic only. The exact preperiod and period of a ray address
`p/q` under doubling are read off `q` in lowest terms: write `q = 2^l m` with
`m` odd, and the address has preperiod `l` and period the multiplicative order
of `2` modulo `m`, with `m = 1` giving period one because zero is fixed. An
address is of Misiurewicz type when `l >= 1`.

The catalogue of exact type `(l, k)` is the finite set of such addresses, and
its size obeys

    count(l, k) = 2^(l-1) * sum_{d | k} mu(k/d) (2^d - 1).

`main` replays the round-one angle-count regression: enumeration against the
identity for every type with `1 <= l, k <= 7`.
Usage: misiurewicz_catalogue_reference.py
"""

from __future__ import annotations

import sys
from math import gcd

MAX_TYPE_INDEX = 20
MAX_CATALOGUE_DENOMINATOR = 1 << 20
REGRESSION = 7


def exact_type(num: int, den: int) -> tuple[int, int] | None:
    """`(preperiod, period)`, or None for an address outside `[0, 1)` or beyond the
    denominator bound.  An accepted type is a true fact about the address, not a
    promise that a catalogue of that type exists here: see `catalogueable_type`."""
    if den <= 0 or num < 0 or num >= den or den > MAX_CATALOGUE_DENOMINATOR:
        return None
    reduced = den // gcd(num, den)
    preperiod = 0
    while reduced % 2 == 0:
        reduced //= 2
        preperiod += 1
    if reduced == 1:
        return (preperiod, 1)
    period, power = 1, 2 % reduced
    while power != 1:
        power = (power * 2) % reduced
        period += 1
    return (preperiod, period)


def catalogueable_type(preperiod: int, period: int) -> bool:
    """Whether a catalogue of exact type `(l, k)` exists here.  Strictly stronger
    than `exact_type` accepting an address of that type: `1/58` is of type
    `(1, 28)`, past the index bound, and `1/50` is of type `(1, 20)`, whose
    indices are inside it while `2 (2^20 - 1)` is past the denominator bound."""
    return catalogue_denominator(preperiod, period) > 0


def misiurewicz(num: int, den: int) -> bool:
    found = exact_type(num, den)
    return found is not None and found[0] >= 1


def moebius(n: int) -> int:
    if n < 1:
        return 0
    rest, sign, factor = n, 1, 2
    while factor * factor <= rest:
        if rest % factor == 0:
            rest //= factor
            if rest % factor == 0:
                return 0
            sign = -sign
        factor += 1
    return -sign if rest > 1 else sign


def catalogue_denominator(preperiod: int, period: int) -> int:
    """`2^l (2^k - 1)`, or -1 when the type is out of range or the denominator is too large."""
    if not (1 <= preperiod <= MAX_TYPE_INDEX and 1 <= period <= MAX_TYPE_INDEX):
        return -1
    odd_part, scale = (1 << period) - 1, 1 << preperiod
    if odd_part > MAX_CATALOGUE_DENOMINATOR // scale:
        return -1
    return scale * odd_part


def catalogue_count(preperiod: int, period: int) -> int:
    if catalogue_denominator(preperiod, period) < 0:
        return -1
    total = sum(moebius(period // d) * ((1 << d) - 1) for d in range(1, period + 1) if period % d == 0)
    return (1 << (preperiod - 1)) * total


def catalogue(preperiod: int, period: int) -> list[int]:
    den = catalogue_denominator(preperiod, period)
    if den < 0:
        return []
    return [num for num in range(den) if exact_type(num, den) == (preperiod, period)]


def main() -> int:
    checked = 0
    for preperiod in range(1, REGRESSION + 1):
        for period in range(1, REGRESSION + 1):
            if catalogue_denominator(preperiod, period) < 0:
                continue
            assert len(catalogue(preperiod, period)) == catalogue_count(preperiod, period), (preperiod, period)
            checked += 1
    assert catalogue(1, 1) == [1] and catalogue(2, 1) == [1, 3]
    assert catalogue(1, 2) == [1, 5] and catalogue(1, 3) == [1, 3, 5, 9, 11, 13]
    print(f"OK: the angle-count identity matches the enumeration for {checked} exact types.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
