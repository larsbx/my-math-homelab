"""Exact, finite instrumentation for the exponential-window Hankel proof.

No function infers an infinite-tail hypothesis from finite input. Recurrence
coefficients below are local candidates, checked on the displayed window.
See docs/exponential-window-hankel.md for the general mathematical proofs.
"""

from fractions import Fraction
from typing import Sequence

Exact = int | Fraction


def _fraction(value: Exact) -> Fraction:
    if not isinstance(value, (int, Fraction)):
        raise TypeError("use integers or Fraction, never floating point")
    return Fraction(value)


def determinant(matrix: Sequence[Sequence[Exact]]) -> Fraction:
    """Compute a square determinant by exact Gaussian elimination."""
    size = len(matrix)
    if any(len(row) != size for row in matrix):
        raise ValueError("matrix must be square")
    rows = [[_fraction(value) for value in row] for row in matrix]
    result = Fraction(1)
    for col in range(size):
        pivot_row = next((i for i in range(col, size) if rows[i][col]), None)
        if pivot_row is None:
            return Fraction(0)
        if pivot_row != col:
            rows[col], rows[pivot_row] = rows[pivot_row], rows[col]
            result = -result
        pivot = rows[col][col]
        result *= pivot
        for i in range(col + 1, size):
            factor = rows[i][col] / pivot
            for j in range(col + 1, size):
                rows[i][j] -= factor * rows[col][j]
            rows[i][col] = Fraction(0)
    return result


def _hankel_matrix(
    values: Sequence[Exact], start: int, size: int
) -> list[list[Exact]]:
    if start < 0 or size < 0:
        raise ValueError("start and size must be nonnegative")
    needed = start + (2 * size - 1 if size else 0)
    if needed > len(values):
        raise ValueError("not enough sequence values")
    return [[values[start + i + j] for j in range(size)] for i in range(size)]


def hankel_minor(values: Sequence[Exact], start: int, size: int) -> Fraction:
    """The actual contiguous minor, with the empty determinant equal to 1."""
    return determinant(_hankel_matrix(values, start, size))


def dodgson_sides(
    values: Sequence[Exact], start: int, order: int
) -> tuple[Fraction, Fraction]:
    """Return both sides of D_(r+1)(n) D_(r-1)(n+2)=D_r(n)D_r(n+2)-D_r(n+1)^2."""
    if order < 1:
        raise ValueError("order must be positive")
    left = hankel_minor(values, start, order + 1) * hankel_minor(
        values, start + 2, order - 1
    )
    right = hankel_minor(values, start, order) * hankel_minor(
        values, start + 2, order
    ) - hankel_minor(values, start + 1, order) ** 2
    return left, right


def hankel_exponent(gamma: Exact, size: int) -> Fraction:
    """Exponent of alpha^n in the fixed-size rank-one bound (exact rational gamma)."""
    if size < 2:
        raise ValueError("size must be at least two")
    gamma = _fraction(gamma)
    if gamma >= 1:
        raise ValueError("the exponential window requires gamma < 1")
    return 1 - (size - 1) * (1 - gamma)


def admissible_hankel_size(gamma: Exact) -> int:
    """Least size with strictly negative bound exponent, including equality cases."""
    gamma = _fraction(gamma)
    if gamma >= 1:
        raise ValueError("the exponential window requires gamma < 1")
    reciprocal = 1 / (1 - gamma)
    return reciprocal.numerator // reciprocal.denominator + 2


def _solve(
    matrix: Sequence[Sequence[Exact]], rhs: Sequence[Exact]
) -> tuple[Fraction, ...]:
    size = len(matrix)
    if len(rhs) != size or any(len(row) != size for row in matrix):
        raise ValueError("linear system must be square")
    rows = [
        [_fraction(value) for value in row] + [_fraction(rhs[i])]
        for i, row in enumerate(matrix)
    ]
    for col in range(size):
        pivot_row = next((i for i in range(col, size) if rows[i][col]), None)
        if pivot_row is None:
            raise ValueError("singular lower Hankel layer; descend before solving")
        rows[col], rows[pivot_row] = rows[pivot_row], rows[col]
        pivot = rows[col][col]
        rows[col] = [value / pivot for value in rows[col]]
        for i in range(size):
            if i != col:
                factor = rows[i][col]
                rows[i] = [
                    value - factor * other
                    for value, other in zip(rows[i], rows[col])
                ]
    return tuple(row[-1] for row in rows)


def recurrence_coefficients(
    values: Sequence[Exact], start: int, order: int
) -> tuple[Fraction, ...]:
    """Solve q_0,...,q_(r-1) and check all r+1 equations in a 2r+1-term window.

    The convention is a_(n+r)=sum(q_j*a_(n+j)). An invertible r-layer and
    a zero (r+1)-layer are required locally. This returns no tail certificate.
    """
    if order < 1:
        raise ValueError("order must be positive")
    _hankel_matrix(values, start, order + 1)  # Check the entire window is present.
    matrix = _hankel_matrix(values, start, order)
    rhs = [values[start + i + order] for i in range(order)]
    coefficients = _solve(matrix, rhs)
    last_residual = _fraction(values[start + 2 * order]) - sum(
        coefficients[j] * _fraction(values[start + order + j])
        for j in range(order)
    )
    if last_residual:
        raise ValueError("the next Hankel layer does not vanish in this window")
    return coefficients


def recurrence_residuals(
    values: Sequence[Exact], coefficients: Sequence[Exact], start: int = 0
) -> tuple[Fraction, ...]:
    """Check every available equation in a finite prefix; empty coefficients mean zero."""
    order = len(coefficients)
    if start < 0 or start + order > len(values):
        raise ValueError("invalid start or insufficient sequence values")
    exact_coefficients = tuple(_fraction(value) for value in coefficients)
    return tuple(
        _fraction(values[n + order]) - sum(
            exact_coefficients[j] * _fraction(values[n + j]) for j in range(order)
        )
        for n in range(start, len(values) - order)
    )
