#!/usr/bin/env python3
"""Reference checker for exact-type interval exclusions.

Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).

This is a temporary Python oracle for the finite-regime Mandelbrot project. It
checks the same-box exclusion requirement for H_{i,j}(beta)=Q_j(beta)-Q_i(beta)
using rational interval arithmetic. It is not the final Mojo certificate engine.

Core invariant preserved here:
  squarefree-localize on R_{ell,k}, then prove exact type by pointwise exclusion
  of every forbidden collision on the same box beta.

Interval arithmetic is the vendored `closed_interval` package
(vendor/python/closed_interval, pinned in vendored.toml): the Python twin of
the vendored Mojo `closed_q`, whose complex square is the sharp one of spec
section 2.5. This file keeps only the exclusion check over it.
"""

from __future__ import annotations

import sys
from fractions import Fraction
from itertools import combinations
from pathlib import Path

_VENDOR = str(Path(__file__).resolve().parents[3] / "vendor" / "python")
if _VENDOR not in sys.path:
    sys.path.insert(0, _VENDOR)

from closed_interval import IQ, ComplexIQ  # noqa: E402


def excludes_zero(box: ComplexIQ) -> bool:
    """``0 + 0i`` is outside ``box``; a rejected box excludes nothing."""
    return box.accepted() and not box.contains_zero()


def q_orbit_box(c: ComplexIQ, horizon: int) -> list[ComplexIQ]:
    zero = ComplexIQ.singleton(0, 0)
    out = [zero]
    z = zero
    for _ in range(horizon):
        z = z.square().add(c)
        out.append(z)
    return out


def intended_pairs(ell: int, period: int, horizon: int) -> set[tuple[int, int]]:
    return {
        (i, j)
        for i, j in combinations(range(horizon + 1), 2)
        if i >= ell and (j - i) % period == 0
    }


def forbidden_pairs(ell: int, period: int, horizon: int) -> set[tuple[int, int]]:
    all_pairs = set(combinations(range(horizon + 1), 2))
    return all_pairs - intended_pairs(ell, period, horizon)


def excluded_count(cbox: ComplexIQ, ell: int, period: int, horizon: int) -> tuple[int, int, list[tuple[int, int]]]:
    q = q_orbit_box(cbox, horizon)
    failures: list[tuple[int, int]] = []
    pairs = sorted(forbidden_pairs(ell, period, horizon))
    for i, j in pairs:
        hij = q[j].sub(q[i])
        if not excludes_zero(hij):
            failures.append((i, j))
    return (len(pairs) - len(failures), len(pairs), failures)


def dyadic_box(center_re_num: int, center_im_num: int, center_exp: int, half_exp: int) -> ComplexIQ:
    den = 2 ** center_exp
    h = Fraction(1, 2 ** half_exp)
    re = Fraction(center_re_num, den)
    im = Fraction(center_im_num, den)
    return ComplexIQ(IQ.of(re - h, re + h), IQ.of(im - h, im + h))


def c_minus_2_box() -> ComplexIQ:
    return ComplexIQ.of(Fraction(-33, 16), Fraction(-31, 16), Fraction(-1, 16), Fraction(1, 16))


def m41_box() -> ComplexIQ:
    # Center from the project notes, half-width 2^-25.
    return dyadic_box(-56912193317957, 538341446717435, 49, 25)


def main() -> int:
    ok, total, failures = excluded_count(c_minus_2_box(), 2, 1, 3)
    assert total == 5, (total, failures)
    assert ok == total, failures

    ok, total, failures = excluded_count(m41_box(), 4, 1, 6)
    assert total == 18, (total, failures)
    assert ok == total, failures

    print("OK: interval exclusion reference checks passed")
    print("  c=-2: 5/5 forbidden collisions excluded on same box")
    print("  M_4,1: 18/18 forbidden collisions excluded on same box")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
