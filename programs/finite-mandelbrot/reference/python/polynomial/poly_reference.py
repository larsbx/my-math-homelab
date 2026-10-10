#!/usr/bin/env python3
"""Reference polynomial oracle for finite-regime Mandelbrot scaffolding.

This file is intentionally a development oracle, not the certificate engine.
It uses Python integer arithmetic to verify the polynomial identities that the
Mojo layer must eventually check natively over an arbitrary-precision backend.

Core invariant: exact-type filtering is squarefree-localize plus pointwise
forbidden-collision exclusion. Never remove lower-collision factors globally.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import gcd
from typing import Iterable


@dataclass(frozen=True)
class PolyZ:
    coeffs: tuple[int, ...]  # ascending powers of C

    def norm(self) -> "PolyZ":
        xs = list(self.coeffs)
        while len(xs) > 1 and xs[-1] == 0:
            xs.pop()
        if not xs:
            xs = [0]
        return PolyZ(tuple(xs))

    @staticmethod
    def zero() -> "PolyZ":
        return PolyZ((0,))

    @staticmethod
    def one() -> "PolyZ":
        return PolyZ((1,))

    @staticmethod
    def c() -> "PolyZ":
        return PolyZ((0, 1))

    def degree(self) -> int:
        n = self.norm().coeffs
        return -1 if n == (0,) else len(n) - 1

    def lead(self) -> int:
        return self.norm().coeffs[-1]

    def __add__(self, other: "PolyZ") -> "PolyZ":
        n = max(len(self.coeffs), len(other.coeffs))
        out = []
        for i in range(n):
            a = self.coeffs[i] if i < len(self.coeffs) else 0
            b = other.coeffs[i] if i < len(other.coeffs) else 0
            out.append(a + b)
        return PolyZ(tuple(out)).norm()

    def __sub__(self, other: "PolyZ") -> "PolyZ":
        n = max(len(self.coeffs), len(other.coeffs))
        out = []
        for i in range(n):
            a = self.coeffs[i] if i < len(self.coeffs) else 0
            b = other.coeffs[i] if i < len(other.coeffs) else 0
            out.append(a - b)
        return PolyZ(tuple(out)).norm()

    def __neg__(self) -> "PolyZ":
        return PolyZ(tuple(-x for x in self.coeffs)).norm()

    def __mul__(self, other: "PolyZ") -> "PolyZ":
        if self.norm().coeffs == (0,) or other.norm().coeffs == (0,):
            return PolyZ.zero()
        out = [0] * (len(self.coeffs) + len(other.coeffs) - 1)
        for i, a in enumerate(self.coeffs):
            for j, b in enumerate(other.coeffs):
                out[i + j] += a * b
        return PolyZ(tuple(out)).norm()

    def derivative(self) -> "PolyZ":
        if len(self.coeffs) <= 1:
            return PolyZ.zero()
        return PolyZ(tuple(i * a for i, a in enumerate(self.coeffs[1:], start=1))).norm()

    def content(self) -> int:
        g = 0
        for a in self.coeffs:
            g = gcd(g, abs(a))
        return g

    def primitive(self) -> "PolyZ":
        g = self.content()
        if g in (0, 1):
            out = self.norm()
        else:
            out = PolyZ(tuple(a // g for a in self.coeffs)).norm()
        if out.lead() < 0:
            out = -out
        return out

    def scale(self, k: int) -> "PolyZ":
        return PolyZ(tuple(k * a for a in self.coeffs)).norm()

    def __str__(self) -> str:
        return f"PolyZ{self.norm().coeffs}"


def q_polys(n: int) -> list[PolyZ]:
    qs = [PolyZ.zero()]
    c = PolyZ.c()
    for _ in range(n):
        qs.append((qs[-1] * qs[-1] + c).norm())
    return qs


def return_poly(ell: int, k: int) -> PolyZ:
    qs = q_polys(ell + k)
    return (qs[ell + k] - qs[ell]).norm()


def factor_product(factors: Iterable[PolyZ]) -> PolyZ:
    out = PolyZ.one()
    for f in factors:
        out = out * f
    return out.norm()


def assert_equal(name: str, got: PolyZ, expected: PolyZ) -> None:
    if got.norm() != expected.norm():
        raise AssertionError(f"{name}: got {got}, expected {expected}")


def check_r21() -> None:
    c = PolyZ.c()
    r = return_poly(2, 1)
    expected_r = factor_product([c, c, c, PolyZ((2, 1))])
    expected_p = factor_product([c, PolyZ((2, 1))])
    assert_equal("R_2_1", r, expected_r)
    # Squarefree expectation, recorded for Mojo witness layer.
    print("R_2_1 =", r)
    print("P_2_1 =", expected_p)


def check_r41_factorization() -> None:
    c = PolyZ.c()
    f3 = PolyZ((2, 2, 2, 1))
    f7 = PolyZ((2, 2, 4, 6, 6, 6, 4, 1))
    r = return_poly(4, 1)
    expected = factor_product([c, c, c, c, c, PolyZ((2, 1)), f3, f7])
    expected_p = factor_product([c, PolyZ((2, 1)), f3, f7])
    assert_equal("R_4_1 factorization", r, expected)
    print("R_4_1 factorization OK")
    print("P_4_1 expected =", expected_p)


def main() -> int:
    check_r21()
    check_r41_factorization()
    print("OK: reference polynomial identities hold")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
