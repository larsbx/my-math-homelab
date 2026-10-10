#!/usr/bin/env python3
"""Python reference for kernel/mojo/c1/residual/residual_directive_carrier.mojo.

Exact rational arithmetic only. `kneading_prefix(theta)` is the 0/1 kneading
sequence of a periodic angle up to its `*`; `continuation_last_letter` picks
the periodic continuation whose internal address contains the period;
`tuning_pattern` combines them into the (prefix, twist) form of the vendored
`substitution_dynamics.tuning.TuningPattern`; `tune_angle` is exact angle
tuning by a component given by its two root angles, the independent oracle
the pinned instances are checked against. Usage: kneading_reference.py
"""

from __future__ import annotations

import sys
from fractions import Fraction

MAX_PERIOD = 62


def period(theta: Fraction) -> int | None:
    """Exact period of `theta` under doubling modulo one, or None if not periodic within MAX_PERIOD."""
    if theta.denominator % 2 == 0 or not 0 < theta < 1:
        return None
    a = theta
    for k in range(1, MAX_PERIOD + 1):
        a = (2 * a) % 1
        if a == theta:
            return k
    return None


def kneading_prefix(theta: Fraction) -> list[int] | None:
    """Letter k is 1 when 2^k theta lies strictly inside (theta/2, (theta+1)/2), 0 strictly outside;
    the sequence stops at the first boundary hit, position period - 1."""
    if period(theta) is None:
        return None
    low, high, a, out = theta / 2, (theta + 1) / 2, theta, []
    while a not in (low, high):
        out.append(1 if low < a < high else 0)
        a = (2 * a) % 1
    return out


def rho(nu: list[int], m: int) -> int | None:
    n = len(nu)
    return next((k for k in range(m + 1, m + 4 * n + 2) if nu[(k - 1) % n] != nu[(k - m - 1) % n]), None)


def internal_address(nu: list[int]) -> list[int]:
    address, m = [1], 1
    while (r := rho(nu, m)) is not None and r <= len(nu):
        address.append(r)
        m = r
    return address


def continuation_last_letter(prefix: list[int]) -> int | None:
    """The last letter of A(nu) for nu = prefix *, or None unless exactly one continuation qualifies."""
    n = len(prefix) + 1
    hits = [b for b in (0, 1) if n in internal_address(prefix + [b])]
    return hits[0] if len(hits) == 1 else None


def tuning_pattern(theta: Fraction) -> tuple[list[int], bool] | None:
    prefix = kneading_prefix(theta)
    if not prefix:
        return None
    last = continuation_last_letter(prefix)
    return None if last is None else (prefix, last == 0)


def substitute(pattern: tuple[list[int], bool], word: list[int]) -> list[int]:
    prefix, twist = pattern
    return [x for s in word for x in prefix + [s ^ int(twist)]]


def carrier_kneading_prefix(patterns: list[tuple[list[int], bool]]) -> list[int]:
    """Prefix of A_1 * ... * A_n, the star product of the vendored kernel."""
    (prefix, twist) = patterns[0]
    for (q, e) in patterns[1:]:
        prefix, twist = substitute((prefix, twist), q) + prefix, twist != e
    return prefix


def binary_block(theta: Fraction, n: int) -> str:
    digits, a = [], theta
    for _ in range(n):
        a = 2 * a
        digits.append("1" if a >= 1 else "0")
        a %= 1
    return "".join(digits)


def tune_angle(root_minus: Fraction, root_plus: Fraction, theta: Fraction) -> Fraction:
    """Douady's tuning of the periodic angle `theta` by the component whose root rays are
    `root_minus < root_plus` of period n: substitute each binary digit of theta by the n-digit
    block of the corresponding root angle."""
    n = period(root_minus)
    q = period(theta)
    assert n is not None and q is not None and period(root_plus) == n
    blocks = (binary_block(root_minus, n), binary_block(root_plus, n))
    word = "".join(blocks[int(d)] for d in binary_block(theta, q))
    return Fraction(int(word, 2), 2 ** (n * q) - 1)


COMPONENTS = {
    "doubling": (Fraction(1, 3), Fraction(2, 3)),
    "rabbit": (Fraction(1, 7), Fraction(2, 7)),
    "airplane": (Fraction(3, 7), Fraction(4, 7)),
    "primitive period 4": (Fraction(7, 15), Fraction(8, 15)),
    "satellite period 4": (Fraction(2, 5), Fraction(3, 5)),
}
PINNED = {  # angles, tuned angle: the Mojo smoke test asserts the same instances
    ((1, 3), (1, 3)): (2, 5),
    ((1, 3), (1, 3), (1, 3)): (7, 17),
    ((7, 15), (1, 3)): (8, 17),
    ((1, 7), (1, 3)): (10, 63),
    ((1, 7), (3, 7)): (82, 511),
}


def main() -> int:
    for levels, tuned in PINNED.items():
        patterns = [tuning_pattern(Fraction(*a)) for a in levels]
        assert None not in patterns
        assert carrier_kneading_prefix(patterns) == kneading_prefix(Fraction(*tuned)), levels
    print(f"OK: {len(PINNED)} pinned tuning instances agree with exact angle tuning.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
