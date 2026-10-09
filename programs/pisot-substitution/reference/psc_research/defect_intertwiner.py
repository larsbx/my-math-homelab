"""Signed scattered-subword defect intertwiners for strict BPA components.

Balanced-pair states have K1=0. Their degree-2 defect K2 is automatically
skew-symmetric, hence a vector in Lambda^2(Q^3). If child occurrences are
weighted by their orientation signs, concatenation across balanced children has
no degree-2 cross-term defect, giving the exact relation

    Q2 S = (Lambda^2 M) Q2.

If every state also has K2=0, the degree-3 cross terms vanish as well and

    Q3 S = (M^{tensor 3}) Q3.

This is the SCC-level bridge from orientation monodromy to the existing
K2/K3/W3 spectral machinery. The routines use exact integer arithmetic only.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import Sequence

from .bpa import State, Substitution, alphabet_size, apply_substitution, parikh
from .intertwiner import IntMatrix, matmul
from .orientation_spectrum import OrientationIncidence, build_orientation_incidence


@dataclass(frozen=True)
class K2Intertwiner:
    orientation: OrientationIncidence
    defect_matrix: IntMatrix  # 3 x |C| in basis 12,13,23
    exterior_square: IntMatrix  # 3 x 3


@dataclass(frozen=True)
class K3Intertwiner:
    orientation: OrientationIncidence
    defect_matrix: IntMatrix  # 27 x |C|
    tensor_cube: IntMatrix  # 27 x 27


def n2(word: Sequence[int], size: int = 3) -> tuple[int, ...]:
    out = [0] * (size * size)
    for i in range(len(word)):
        for j in range(i + 1, len(word)):
            out[size * (word[i] - 1) + (word[j] - 1)] += 1
    return tuple(out)


def n3(word: Sequence[int], size: int = 3) -> tuple[int, ...]:
    out = [0] * (size * size * size)
    for i in range(len(word)):
        for j in range(i + 1, len(word)):
            for k in range(j + 1, len(word)):
                a, b, c = word[i] - 1, word[j] - 1, word[k] - 1
                out[size * size * a + size * b + c] += 1
    return tuple(out)


def _diff(a: Sequence[int], b: Sequence[int]) -> tuple[int, ...]:
    if len(a) != len(b):
        raise ValueError("vectors must have equal length")
    return tuple(x - y for x, y in zip(a, b))


def k2_full(state: State, size: int = 3) -> tuple[int, ...]:
    u, v = state
    if parikh(u, size) != parikh(v, size):
        raise ValueError("K2 requires a balanced pair")
    return _diff(n2(u, size), n2(v, size))


def k2_wedge(state: State) -> tuple[int, int, int]:
    """K2 in basis e1^e2, e1^e3, e2^e3.

    Equal Parikh vectors imply diagonal defects vanish and K2_ji=-K2_ij.
    """
    full = k2_full(state, 3)
    if full[0] or full[4] or full[8]:
        raise AssertionError("balanced-pair K2 has nonzero diagonal")
    if full[1] != -full[3] or full[2] != -full[6] or full[5] != -full[7]:
        raise AssertionError("balanced-pair K2 is not skew-symmetric")
    return (full[1], full[2], full[5])


def k3_full(state: State, size: int = 3) -> tuple[int, ...]:
    u, v = state
    if parikh(u, size) != parikh(v, size):
        raise ValueError("K3 requires a balanced pair")
    return _diff(n3(u, size), n3(v, size))


def exterior_square(matrix: Sequence[Sequence[int]]) -> IntMatrix:
    """Matrix of Lambda^2(M) in basis 12,13,23."""
    if len(matrix) != 3 or any(len(row) != 3 for row in matrix):
        raise ValueError("exterior_square currently expects a 3x3 matrix")
    pairs = ((0, 1), (0, 2), (1, 2))
    out = [[0] * 3 for _ in range(3)]
    for source, (a, b) in enumerate(pairs):
        for target, (i, j) in enumerate(pairs):
            out[target][source] = (
                matrix[i][a] * matrix[j][b] - matrix[j][a] * matrix[i][b]
            )
    return tuple(tuple(row) for row in out)


def tensor_cube(matrix: Sequence[Sequence[int]]) -> IntMatrix:
    """Matrix of M^{tensor 3} in lexicographic tensor coordinates."""
    if len(matrix) != 3 or any(len(row) != 3 for row in matrix):
        raise ValueError("tensor_cube currently expects a 3x3 matrix")
    out = [[0] * 27 for _ in range(27)]
    for a in range(3):
        for b in range(3):
            for c in range(3):
                source = 9 * a + 3 * b + c
                for i in range(3):
                    for j in range(3):
                        for k in range(3):
                            target = 9 * i + 3 * j + k
                            out[target][source] = (
                                matrix[i][a] * matrix[j][b] * matrix[k][c]
                            )
    return tuple(tuple(row) for row in out)


def _column(matrix: IntMatrix, index: int) -> IntMatrix:
    return tuple((row[index],) for row in matrix)


def build_k2_intertwiner(sigma: Substitution, comp: Sequence[State]) -> K2Intertwiner:
    """Build and verify Q2 S = (Lambda^2 M) Q2."""
    if alphabet_size(sigma) != 3:
        raise ValueError("K2 wedge implementation currently requires three letters")
    orientation = build_orientation_incidence(sigma, comp)
    cols = [k2_wedge(state) for state in orientation.states]
    q2 = tuple(tuple(col[row] for col in cols) for row in range(3))
    wedge = exterior_square(orientation.substitution_incidence)
    if matmul(q2, orientation.signed) != matmul(wedge, q2):
        raise AssertionError("K2 signed intertwining identity failed")

    # Independent word-level substitution check on each column.
    for j, state in enumerate(orientation.states):
        u, v = state
        inflated = (apply_substitution(sigma, u), apply_substitution(sigma, v))
        transformed = matmul(wedge, _column(q2, j))
        expected = tuple(transformed[row][0] for row in range(3))
        if k2_wedge(inflated) != expected:
            raise AssertionError("K2 substitution action disagrees with Lambda^2 M")

    return K2Intertwiner(orientation=orientation, defect_matrix=q2, exterior_square=wedge)


def build_k3_intertwiner(sigma: Substitution, comp: Sequence[State]) -> K3Intertwiner:
    """Build Q3 S = M^{tensor 3} Q3 when every component state has K2=0."""
    if alphabet_size(sigma) != 3:
        raise ValueError("K3 implementation currently requires three letters")
    orientation = build_orientation_incidence(sigma, comp)
    if any(any(k2_wedge(state)) for state in orientation.states):
        raise ValueError("K3 pure tensor intertwining requires K2=0 on every state")

    cols = [k3_full(state) for state in orientation.states]
    q3 = tuple(tuple(col[row] for col in cols) for row in range(27))
    cube = tensor_cube(orientation.substitution_incidence)
    if matmul(q3, orientation.signed) != matmul(cube, q3):
        raise AssertionError("K3 signed intertwining identity failed")

    for j, state in enumerate(orientation.states):
        u, v = state
        inflated = (apply_substitution(sigma, u), apply_substitution(sigma, v))
        transformed = matmul(cube, _column(q3, j))
        expected = tuple(transformed[row][0] for row in range(27))
        if k3_full(inflated) != expected:
            raise AssertionError("K3 substitution action disagrees with M^{tensor 3}")

    return K3Intertwiner(orientation=orientation, defect_matrix=q3, tensor_cube=cube)


def scattered_counts_sparse(word: Sequence[int], degree: int) -> dict[tuple[int, ...], int]:
    """Sparse scattered-subword counts, useful for locating the first defect degree."""
    if degree < 0:
        raise ValueError("degree must be nonnegative")
    if degree == 0:
        return {(): 1}
    out: dict[tuple[int, ...], int] = {}
    for positions in combinations(range(len(word)), degree):
        subword = tuple(word[i] for i in positions)
        out[subword] = out.get(subword, 0) + 1
    return out


def sparse_defect(state: State, degree: int) -> dict[tuple[int, ...], int]:
    u, v = state
    left = scattered_counts_sparse(u, degree)
    right = scattered_counts_sparse(v, degree)
    keys = set(left) | set(right)
    return {
        key: left.get(key, 0) - right.get(key, 0)
        for key in keys
        if left.get(key, 0) != right.get(key, 0)
    }


def lowest_nonzero_defect_degree(comp: Sequence[State]) -> int:
    """Least scattered-subword degree distinguishing some state in a component.

    Every balanced component starts with degree 1 equal. Since each state has
    finite equal-length but distinct words, some finite degree distinguishes it.
    """
    if not comp:
        raise ValueError("component must be nonempty")
    max_length = max(len(state[0]) for state in comp)
    for degree in range(1, max_length + 1):
        if any(sparse_defect(state, degree) for state in comp):
            return degree
    raise AssertionError("distinct finite words were not separated by scattered-subword counts")
