"""Exact degree-4 free-Lie character data for the C4 first-defect program.

For a three-dimensional alphabet space V in characteristic zero,

    Lie_4(V) = S_(3,1)(V) + S_(2,1,1)(V)

in the representation ring.  This module verifies the decomposition from the
Witt character formula and records the three S_3 weight-orbit families that
control the degree-4 PIP spectral comparison.

No floating point or root finding is used here.  Spectral equality conditions
are encoded only after the algebraic proof in docs/c4-degree4-free-lie.md.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import permutations
from math import factorial
from typing import Mapping

Weight = tuple[int, int, int]
Character = dict[Weight, int]


def _add(a: Mapping[Weight, int], b: Mapping[Weight, int], scale: int = 1) -> Character:
    out = dict(a)
    for weight, multiplicity in b.items():
        out[weight] = out.get(weight, 0) + scale * multiplicity
        if out[weight] == 0:
            del out[weight]
    return out


def _mul(a: Mapping[Weight, int], b: Mapping[Weight, int]) -> Character:
    out: Character = {}
    for wa, ma in a.items():
        for wb, mb in b.items():
            weight = tuple(wa[i] + wb[i] for i in range(3))
            out[weight] = out.get(weight, 0) + ma * mb
    return out


def _power(a: Mapping[Weight, int], exponent: int) -> Character:
    if exponent < 0:
        raise ValueError("exponent must be nonnegative")
    out: Character = {(0, 0, 0): 1}
    for _ in range(exponent):
        out = _mul(out, a)
    return out


def complete_character(degree: int) -> Character:
    """Character of Sym^degree(V), i.e. the complete symmetric polynomial h_n."""
    if degree < 0:
        return {}
    out: Character = {}
    for a in range(degree + 1):
        for b in range(degree - a + 1):
            c = degree - a - b
            out[(a, b, c)] = 1
    return out


def schur_31_character() -> Character:
    """Jacobi--Trudi: s_(3,1) = h_3 h_1 - h_4."""
    return _add(_mul(complete_character(3), complete_character(1)), complete_character(4), -1)


def schur_211_character() -> Character:
    """s_(2,1,1) on dim(V)=3 is det(V) tensor V."""
    return {
        (2, 1, 1): 1,
        (1, 2, 1): 1,
        (1, 1, 2): 1,
    }


def lie4_witt_character() -> Character:
    """Degree-4 Witt character: (p_1^4 - p_2^2)/4 on three variables."""
    p1: Character = {(1, 0, 0): 1, (0, 1, 0): 1, (0, 0, 1): 1}
    p2: Character = {(2, 0, 0): 1, (0, 2, 0): 1, (0, 0, 2): 1}
    numerator = _add(_power(p1, 4), _power(p2, 2), -1)
    if any(value % 4 for value in numerator.values()):
        raise AssertionError("degree-4 Witt character is not integral")
    return {weight: value // 4 for weight, value in numerator.items() if value}


def lie4_schur_character() -> Character:
    return _add(schur_31_character(), schur_211_character())


def character_dimension(character: Mapping[Weight, int]) -> int:
    """Dimension obtained by evaluating the character at (1,1,1)."""
    return sum(character.values())


def orbit(weight: Weight) -> tuple[Weight, ...]:
    """Distinct coordinate permutations of one eigenvalue exponent pattern."""
    return tuple(sorted(set(permutations(weight))))


@dataclass(frozen=True)
class Degree4OrbitFamily:
    name: str
    representative: Weight
    orbit_size: int
    multiplicity_in_lie4: int
    dimension: int


def orbit_families() -> tuple[Degree4OrbitFamily, ...]:
    """The three weight-orbit families in Lie_4(Q^3)."""
    return (
        Degree4OrbitFamily("A_310", (3, 1, 0), 6, 1, 6),
        Degree4OrbitFamily("B_220", (2, 2, 0), 3, 1, 3),
        # multiplicity two in S_(3,1), plus one in S_(2,1,1)
        Degree4OrbitFamily("C_211", (2, 1, 1), 3, 3, 9),
    )


def low_growth_families(det_abs: int, stable_equal_modulus: bool) -> tuple[str, ...]:
    """Degree-4 rational factor families that can have spectral radius <= beta.

    This applies only after the PIP inequalities proved in
    docs/c4-degree4-free-lie.md.  `stable_equal_modulus` means the two
    non-Perron conjugates have equal modulus (the complex-pair case for an
    irreducible cubic; equality is impossible for three distinct real roots).
    """
    if det_abs < 1:
        raise ValueError("irreducible cubic incidence matrices have nonzero determinant")
    if det_abs != 1:
        return ()
    out = ["C_211"]
    if stable_equal_modulus:
        out.append("B_220")
    return tuple(out)


def degree4_witt_dimension(rank: int = 3) -> int:
    """Witt dimension in degree four: (rank^4-rank^2)/4."""
    if rank < 0:
        raise ValueError("rank must be nonnegative")
    return (rank**4 - rank**2) // 4
