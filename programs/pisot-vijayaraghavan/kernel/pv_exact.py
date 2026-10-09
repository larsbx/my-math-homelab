"""Exact integer kernel for Pisot--Vijayaraghavan research.

This module proves no theorem by computation. It exposes exact identities used
by the research notes and deterministic generators for finite experiments.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import gcd
from typing import Sequence


def nearest_integer(q: Fraction) -> int:
    """Return the unique nearest integer to q; reject half-integer ties."""
    lo = q.numerator // q.denominator
    frac = q - lo
    half = Fraction(1, 2)
    if frac < half:
        return lo
    if frac > half:
        return lo + 1
    raise ValueError(f"nearest-integer tie at {q}")


def next_e(a: int, b: int) -> int:
    if a <= 0:
        raise ValueError("E-sequence denominator must be positive")
    return nearest_integer(Fraction(b * b, a))


def generate_e(a0: int, a1: int, length: int) -> list[int]:
    if length < 2:
        raise ValueError("length must be at least 2")
    if a0 <= 0 or a1 <= 0:
        raise ValueError("seed must be positive")
    out = [a0, a1]
    while len(out) < length:
        out.append(next_e(out[-2], out[-1]))
    return out


def defect(a: int, b: int, c: int) -> int:
    return a * c - b * b


def defects(values: Sequence[int]) -> list[int]:
    return [
        defect(values[i], values[i + 1], values[i + 2])
        for i in range(len(values) - 2)
    ]


def determinant_bareiss(matrix: Sequence[Sequence[int]]) -> int:
    """Exact determinant by fraction-free Bareiss elimination."""
    n = len(matrix)
    if n == 0:
        return 1
    if any(len(row) != n for row in matrix):
        raise ValueError("matrix must be square")
    a = [list(map(int, row)) for row in matrix]
    sign = 1
    prev = 1
    for k in range(n - 1):
        if a[k][k] == 0:
            swap = next((r for r in range(k + 1, n) if a[r][k] != 0), None)
            if swap is None:
                return 0
            a[k], a[swap] = a[swap], a[k]
            sign = -sign
        pivot = a[k][k]
        for i in range(k + 1, n):
            for j in range(k + 1, n):
                num = a[i][j] * pivot - a[i][k] * a[k][j]
                if k:
                    if num % prev:
                        raise ArithmeticError("Bareiss division was not exact")
                    num //= prev
                a[i][j] = num
        prev = pivot
    return sign * a[n - 1][n - 1]


def hankel_minor(values: Sequence[int], start: int, k: int) -> int:
    if k < 1:
        raise ValueError("k must be positive")
    need = start + 2 * k - 1
    if start < 0 or need > len(values):
        raise ValueError("not enough sequence values")
    return determinant_bareiss(
        [[values[start + i + j] for j in range(k)] for i in range(k)]
    )


def desnanot_jacobi_holds(values: Sequence[int], start: int, k: int) -> bool:
    if k < 2:
        raise ValueError("k must be at least 2")
    lhs = (
        hankel_minor(values, start, k + 1)
        * hankel_minor(values, start + 2, k - 1)
    )
    rhs = (
        hankel_minor(values, start, k)
        * hankel_minor(values, start + 2, k)
        - hankel_minor(values, start + 1, k) ** 2
    )
    return lhs == rhs


def transport_congruence_holds(a: int, b: int, c: int, d: int) -> bool:
    """Check a^2 c_{n+1} + c_n^2 == 0 modulo b."""
    if b == 0:
        raise ValueError("modulus must be nonzero")
    cn = defect(a, b, c)
    cnext = defect(b, c, d)
    return (a * a * cnext + cn * cn) % abs(b) == 0


@dataclass(frozen=True)
class TransitionData:
    g_n: int
    g_next: int
    u_n: int
    v_n: int
    c_n: int
    h_n: int
    b_n: int
    d_n: int
    primitive_det: int


def transition_data(a: int, b: int, c: int) -> TransitionData:
    """Return the exact bounded-gcd normalization for one transition."""
    g_n = gcd(a, b)
    g_next = gcd(b, c)
    u_n = a // g_n
    v_n = b // g_n
    c_n = defect(a, b, c)
    if c_n % g_n:
        raise ArithmeticError("g_n must divide the defect")
    h_n = c_n // g_n
    b_n = gcd(v_n, h_n)
    if g_next % b_n:
        raise ArithmeticError("primitive-overlap factor must divide g_{n+1}")
    d_n = g_next // b_n
    if g_n % d_n:
        raise ArithmeticError("inherited factor must divide g_n")
    if c_n % (g_n * g_next):
        raise ArithmeticError("g_n g_{n+1} must divide the defect")
    primitive_det = c_n // (g_n * g_next)
    return TransitionData(
        g_n=g_n,
        g_next=g_next,
        u_n=u_n,
        v_n=v_n,
        c_n=c_n,
        h_n=h_n,
        b_n=b_n,
        d_n=d_n,
        primitive_det=primitive_det,
    )


def prime_factors(n: int) -> set[int]:
    n = abs(n)
    out: set[int] = set()
    p = 2
    while p * p <= n:
        if n % p == 0:
            out.add(p)
            while n % p == 0:
                n //= p
        p = 3 if p == 2 else p + 2
    if n > 1:
        out.add(n)
    return out


def large_prime_freshness_holds(values: Sequence[int], n: int, G: int) -> bool:
    a, b, c = values[n : n + 3]
    cn = defect(a, b, c)
    for p in prime_factors(cn):
        if p > G and (a % p == 0 or b % p == 0 or c % p == 0):
            return False
    return True


def gcd_state(values: Sequence[int]) -> list[int]:
    return [gcd(values[i], values[i + 1]) for i in range(len(values) - 1)]


@dataclass(frozen=True)
class Period4Run:
    start: int
    end: int
    state_count: int
    full_periods: int
    pattern: tuple[int, int]
    phase: tuple[int, int, int, int]


def period4_aabb_runs(
    states: Sequence[int], min_periods: int = 2
) -> list[Period4Run]:
    """Return maximal A,A,B,B-type runs, allowing cyclic phase shifts."""
    if min_periods < 1:
        raise ValueError("min_periods must be positive")
    out: list[Period4Run] = []
    n = len(states)
    width = 4 * min_periods
    for start in range(max(0, n - width + 1)):
        block = tuple(states[start : start + 4])
        if len(block) < 4:
            continue
        pattern = None
        for shift in range(4):
            candidate = block[shift:] + block[:shift]
            if (
                candidate[0] == candidate[1]
                and candidate[2] == candidate[3]
                and candidate[0] != candidate[2]
            ):
                pattern = tuple(sorted((candidate[0], candidate[2])))
                break
        if pattern is None:
            continue
        if start > 0 and states[start - 1] == block[3]:
            continue
        end = start
        while end < n and states[end] == block[(end - start) % 4]:
            end += 1
        count = end - start
        if count >= width:
            out.append(
                Period4Run(
                    start=start,
                    end=end,
                    state_count=count,
                    full_periods=count // 4,
                    pattern=pattern,
                    phase=block,
                )
            )
    return out


def period4_aabb_tail(
    states: Sequence[int], repeats: int = 3
) -> tuple[int, int] | None:
    """Detect an A,A,B,B period-4 suffix up to cyclic shift, with A != B."""
    width = 4 * repeats
    if repeats < 2 or len(states) < width:
        return None
    tail = list(states[-width:])
    block = tail[:4]
    if any(tail[i] != block[i % 4] for i in range(width)):
        return None
    for shift in range(4):
        candidate = block[shift:] + block[:shift]
        if (
            candidate[0] == candidate[1]
            and candidate[2] == candidate[3]
            and candidate[0] != candidate[2]
        ):
            return tuple(sorted((candidate[0], candidate[2])))
    return None
