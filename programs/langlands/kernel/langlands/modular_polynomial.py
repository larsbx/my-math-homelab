"""Classical modular polynomials Phi_2, Phi_3 in Z[X, Y] as sparse monomial dicts."""
from __future__ import annotations

from typing import Callable, Mapping

Monomials = Mapping[tuple[int, int], int]

PHI_2: Monomials = {
    (3, 0): 1, (0, 3): 1, (2, 2): -1,
    (2, 1): 1488, (1, 2): 1488,
    (2, 0): -162000, (0, 2): -162000,
    (1, 1): 40773375,
    (1, 0): 8748000000, (0, 1): 8748000000,
    (0, 0): -157464000000000,
}

PHI_3: Monomials = {
    (4, 0): 1, (0, 4): 1, (3, 3): -1,
    (3, 2): 2232, (2, 3): 2232,
    (3, 1): -1069956, (1, 3): -1069956,
    (3, 0): 36864000, (0, 3): 36864000,
    (2, 2): 2587918086,
    (2, 1): 8900222976000, (1, 2): 8900222976000,
    (2, 0): 452984832000000, (0, 2): 452984832000000,
    (1, 1): -770845966336000000,
    (1, 0): 1855425871872000000000, (0, 1): 1855425871872000000000,
}

MODULAR_POLYNOMIALS: dict[int, Monomials] = {2: PHI_2, 3: PHI_3}


def phi_int(ell: int, x: int, y: int) -> int:
    return sum(c * x**i * y**j for (i, j), c in MODULAR_POLYNOMIALS[ell].items())


def phi_univariate(ell: int, x, F) -> tuple:
    """Phi_ell(x, Y) as a polynomial in Y over the finite field F (coefficients low -> high),
    for x an element of F."""
    coeffs = [F.zero] * (ell + 2)
    for (i, j), c in MODULAR_POLYNOMIALS[ell].items():
        coeffs[j] = F.add(coeffs[j], F.mul(F.from_int(c), F.pow(x, i)))
    return tuple(coeffs)
