"""Integral-image certificates for the three-state mean-area lift.

For an invertible integer matrix L, the equation Lx=b has an integer solution
iff det(L) divides every Cramer numerator det(L_i(b)).  In the three-state C4
mean-area problem L is the 9x9 Sylvester operator

    X -> (Lambda^2 M) X - X N.

This is a complete integral-lattice membership test in the nonsingular case.
It is equivalent in decision power to computing Smith/Hermite normal form for
this one right-hand side, but it keeps the implementation dependency-free and
produces a compact divisibility certificate.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import gcd
from typing import Sequence

from .bpa import State, Substitution
from .defect_intertwiner import exterior_square
from .factorization_degree2 import substitution_internal_area
from .intertwiner import IntMatrix, matmul, substitution_incidence
from .meanarea_integrality import (
    child_incidence,
    cubic_coefficients,
    det3,
    determinant_fraction_free,
    omega_matrix,
    parikh_matrix,
    sylvester_matrix,
)


@dataclass(frozen=True)
class IntegralImageCertificate:
    determinant: int
    cramer_numerators: tuple[int, ...]

    @property
    def is_integral(self) -> bool:
        return all(n % self.determinant == 0 for n in self.cramer_numerators)

    @property
    def reduced_denominators(self) -> tuple[int, ...]:
        d = abs(self.determinant)
        return tuple(d // gcd(d, abs(n)) for n in self.cramer_numerators)

    @property
    def obstruction_coordinates(self) -> tuple[int, ...]:
        return tuple(
            i for i, n in enumerate(self.cramer_numerators)
            if n % self.determinant != 0
        )


def replace_column(
    matrix: Sequence[Sequence[int]],
    column: int,
    rhs: Sequence[int],
) -> IntMatrix:
    n = len(matrix)
    if n == 0 or any(len(row) != n for row in matrix) or len(rhs) != n:
        raise ValueError("square matrix and matching rhs required")
    if column < 0 or column >= n:
        raise ValueError("replacement column outside matrix")
    return tuple(
        tuple(rhs[i] if j == column else matrix[i][j] for j in range(n))
        for i in range(n)
    )


def integral_image_certificate(
    operator: IntMatrix,
    rhs: Sequence[int],
) -> IntegralImageCertificate:
    """Return the exact Cramer certificate for Lx=b over the integer lattice."""
    determinant = determinant_fraction_free(operator)
    if determinant == 0:
        raise ValueError("Cramer certificate requires a nonsingular operator")
    numerators = tuple(
        determinant_fraction_free(replace_column(operator, j, rhs))
        for j in range(len(operator))
    )
    return IntegralImageCertificate(determinant, numerators)


def _subtract(a: IntMatrix, b: IntMatrix) -> IntMatrix:
    if len(a) != len(b) or any(len(x) != len(y) for x, y in zip(a, b)):
        raise ValueError("matrix dimensions differ")
    return tuple(tuple(x - y for x, y in zip(ra, rb)) for ra, rb in zip(a, b))


def meanarea_lattice_certificate(
    sigma: Substitution,
    states: Sequence[State],
    child_words: Sequence[Sequence[int]],
) -> IntegralImageCertificate:
    """Certify whether the ordered three-state mean-area lift exists over Z.

    The same three-state hypotheses as the rational solver are enforced here:
    P is invertible, P*N=M*P, and N shares the characteristic cubic of M.
    """
    if len(states) != 3:
        raise ValueError("three-state lattice sieve requires exactly three states")
    m = substitution_incidence(sigma)
    n = child_incidence(3, child_words)
    p = parikh_matrix(states)
    if det3(p) == 0:
        raise ValueError("three-state Parikh matrix must have rank three")
    if matmul(p, n) != matmul(m, p):
        raise ValueError("proposed child incidence does not satisfy P*N=M*P")
    if cubic_coefficients(n) != cubic_coefficients(m):
        raise ValueError("proposed child incidence does not share chi_M")

    omega = omega_matrix(states, child_words)
    internal_term = matmul(substitution_internal_area(sigma), p)
    rhs_matrix = _subtract(omega, internal_term)
    rhs = tuple(rhs_matrix[i][j] for i in range(3) for j in range(3))
    operator = sylvester_matrix(exterior_square(m), n)
    return integral_image_certificate(operator, rhs)
