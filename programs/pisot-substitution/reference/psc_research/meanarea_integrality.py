"""Three-state integrality sieve from the order-sensitive degree-2 signature.

For a proposed three-state strict degree-2 component, write

    area(w) = (N12-N21, N13-N31, N23-N32)

and J(T)=(area(u_T)+area(v_T))/2. The order-sensitive factorization identity
becomes the integer Sylvester equation

    (Lambda^2 M) J - J N = Omega_tau - C_sigma P.

When |C|=3, the Parikh intertwiner forces N to have the same irreducible cubic
characteristic polynomial as M. The spectra of M and Lambda^2 M are disjoint,
so the Sylvester operator is invertible over Q and the ordered child words force
one unique rational J. Actual balanced words require that J be integral and
that J +/- Q satisfy elementary word-area parity and magnitude constraints.

The (Parikh, area) multiplication law is the antisymmetric degree-2 truncation
of the Magnus/subword signature. With this integer normalization the central
commutator coordinate is doubled relative to a common Mal'cev normalization;
we therefore use the central-extension interpretation over Q without silently
identifying the integral lattices.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Sequence

from .bpa import State, Substitution, parikh
from .defect_intertwiner import exterior_square, k2_wedge
from .factorization_degree2 import ordered_cross_area, state_midarea, substitution_internal_area
from .intertwiner import IntMatrix, matmul, substitution_incidence

RatMatrix = tuple[tuple[Fraction, ...], ...]


def det3(matrix: Sequence[Sequence[int]]) -> int:
    if len(matrix) != 3 or any(len(row) != 3 for row in matrix):
        raise ValueError("det3 expects a 3x3 matrix")
    a = matrix
    return (
        a[0][0] * (a[1][1] * a[2][2] - a[1][2] * a[2][1])
        - a[0][1] * (a[1][0] * a[2][2] - a[1][2] * a[2][0])
        + a[0][2] * (a[1][0] * a[2][1] - a[1][1] * a[2][0])
    )


def child_incidence(size: int, child_words: Sequence[Sequence[int]]) -> IntMatrix:
    if len(child_words) != size:
        raise ValueError("one child word per state is required")
    out = [[0] * size for _ in range(size)]
    for parent, word in enumerate(child_words):
        for child in word:
            if child < 0 or child >= size:
                raise ValueError("child index outside state set")
            out[child][parent] += 1
    return tuple(tuple(row) for row in out)


def parikh_matrix(states: Sequence[State]) -> IntMatrix:
    if len(states) != 3:
        raise ValueError("three-state sieve requires exactly three states")
    cols = []
    for state in states:
        p = parikh(state[0], 3)
        if p != parikh(state[1], 3):
            raise ValueError("every state must be balanced")
        cols.append(p)
    return tuple(tuple(cols[j][i] for j in range(3)) for i in range(3))


def k2_matrix(states: Sequence[State]) -> IntMatrix:
    if len(states) != 3:
        raise ValueError("three-state sieve requires exactly three states")
    cols = tuple(k2_wedge(state) for state in states)
    return tuple(tuple(cols[j][i] for j in range(3)) for i in range(3))


def actual_meanarea_matrix(states: Sequence[State]) -> IntMatrix:
    """Return J=H/2 for actual balanced states, rejecting malformed inputs."""
    if len(states) != 3:
        raise ValueError("three-state sieve requires exactly three states")
    cols = []
    for state in states:
        if parikh(state[0], 3) != parikh(state[1], 3):
            raise ValueError("every state must be balanced")
        h = state_midarea(state)
        if any(x % 2 for x in h):
            raise AssertionError("balanced-state mid-area is not even")
        cols.append(tuple(x // 2 for x in h))
    return tuple(tuple(cols[j][i] for j in range(3)) for i in range(3))


def omega_matrix(states: Sequence[State], child_words: Sequence[Sequence[int]]) -> IntMatrix:
    if len(states) != 3 or len(child_words) != 3:
        raise ValueError("three states and three child words are required")
    cols = []
    for word in child_words:
        if any(i < 0 or i >= 3 for i in word):
            raise ValueError("child index outside state set")
        cols.append(ordered_cross_area(tuple(states[i] for i in word)))
    return tuple(tuple(cols[j][i] for j in range(3)) for i in range(3))


def _sub(a: Sequence[Sequence[int]], b: Sequence[Sequence[int]]) -> IntMatrix:
    if len(a) != len(b) or any(len(ra) != len(rb) for ra, rb in zip(a, b)):
        raise ValueError("matrix dimensions differ")
    return tuple(tuple(x - y for x, y in zip(ra, rb)) for ra, rb in zip(a, b))


def sylvester_matrix(left: IntMatrix, right: IntMatrix) -> IntMatrix:
    """9x9 matrix for X -> left*X-X*right in row-major X coordinates."""
    if len(left) != 3 or len(right) != 3 or any(len(row) != 3 for row in left + right):
        raise ValueError("sylvester_matrix expects two 3x3 matrices")
    out = [[0] * 9 for _ in range(9)]
    for i in range(3):
        for j in range(3):
            equation = 3 * i + j
            for k in range(3):
                out[equation][3 * k + j] += left[i][k]
                out[equation][3 * i + k] -= right[k][j]
    return tuple(tuple(row) for row in out)


def _solve_square(matrix: IntMatrix, rhs: Sequence[int]) -> tuple[Fraction, ...]:
    n = len(matrix)
    if n == 0 or len(rhs) != n or any(len(row) != n for row in matrix):
        raise ValueError("square matrix and matching rhs required")
    rows = [
        [Fraction(matrix[i][j]) for j in range(n)] + [Fraction(rhs[i])]
        for i in range(n)
    ]
    for col in range(n):
        pivot = next((r for r in range(col, n) if rows[r][col] != 0), None)
        if pivot is None:
            raise ValueError("Sylvester operator is singular")
        rows[col], rows[pivot] = rows[pivot], rows[col]
        pivot_value = rows[col][col]
        rows[col] = [x / pivot_value for x in rows[col]]
        for r in range(n):
            if r == col or rows[r][col] == 0:
                continue
            factor = rows[r][col]
            rows[r] = [rows[r][j] - factor * rows[col][j] for j in range(n + 1)]
    return tuple(rows[i][n] for i in range(n))


def cubic_coefficients(matrix: IntMatrix) -> tuple[int, int, int]:
    """Return T,U,d for x^3-T x^2+U x-d."""
    if len(matrix) != 3 or any(len(row) != 3 for row in matrix):
        raise ValueError("3x3 matrix required")
    t = matrix[0][0] + matrix[1][1] + matrix[2][2]
    u = (
        matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0]
        + matrix[0][0] * matrix[2][2] - matrix[0][2] * matrix[2][0]
        + matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]
    )
    return t, u, det3(matrix)


def forced_meanarea_solution(
    sigma: Substitution,
    states: Sequence[State],
    child_words: Sequence[Sequence[int]],
) -> RatMatrix:
    """Unique rational J forced by an ordered proposed three-state factorization.

    This routine enforces the three-state Parikh conditions used in the proof:
    P has rank three, P*N=M*P, and N has the same characteristic cubic as M.
    """
    if len(states) != 3:
        raise ValueError("three-state sieve requires exactly three states")
    m = substitution_incidence(sigma)
    ext = exterior_square(m)
    n = child_incidence(3, child_words)
    p = parikh_matrix(states)
    if det3(p) == 0:
        raise ValueError("three-state Parikh matrix must have rank three")
    if matmul(p, n) != matmul(m, p):
        raise ValueError("proposed child incidence does not satisfy P*N=M*P")
    if cubic_coefficients(n) != cubic_coefficients(m):
        raise ValueError("proposed child incidence does not share chi_M")

    omega = omega_matrix(states, child_words)
    internal = substitution_internal_area(sigma)
    rhs_matrix = _sub(omega, matmul(internal, p))
    operator = sylvester_matrix(ext, n)
    rhs = tuple(rhs_matrix[i][j] for i in range(3) for j in range(3))
    flat = _solve_square(operator, rhs)
    return tuple(tuple(flat[3 * i + j] for j in range(3)) for i in range(3))


def solution_denominators(solution: RatMatrix) -> tuple[int, ...]:
    return tuple(sorted({x.denominator for row in solution for x in row}))


def solution_is_integral(solution: RatMatrix) -> bool:
    return all(x.denominator == 1 for row in solution for x in row)


def integral_solution(solution: RatMatrix) -> IntMatrix:
    if not solution_is_integral(solution):
        raise ValueError("mean-area solution is not integral")
    return tuple(tuple(int(x) for x in row) for row in solution)


def side_area_columns(
    meanarea: IntMatrix,
    q: IntMatrix,
) -> tuple[tuple[tuple[int, ...], ...], tuple[tuple[tuple[int, ...], ...]]]:
    """Return area(u)=J+Q and area(v)=J-Q as column tuples."""
    if len(meanarea) != 3 or len(q) != 3:
        raise ValueError("three-row matrices required")
    left = []
    right = []
    for j in range(3):
        left.append(tuple(meanarea[i][j] + q[i][j] for i in range(3)))
        right.append(tuple(meanarea[i][j] - q[i][j] for i in range(3)))
    return tuple(left), tuple(right)  # type: ignore[return-value]


def area_vector_passes_parikh_bounds(area: Sequence[int], p: Sequence[int]) -> bool:
    """Necessary coordinatewise parity and magnitude conditions for a word area."""
    if len(area) != 3 or len(p) != 3:
        raise ValueError("three coordinates required")
    products = (p[0] * p[1], p[0] * p[2], p[1] * p[2])
    return all(
        abs(area[i]) <= products[i] and (area[i] - products[i]) % 2 == 0
        for i in range(3)
    )


def forced_side_areas_pass_bounds(states: Sequence[State], solution: RatMatrix) -> bool:
    if not solution_is_integral(solution):
        return False
    j = integral_solution(solution)
    q = k2_matrix(states)
    left, right = side_area_columns(j, q)
    ps = [parikh(state[0], 3) for state in states]
    return all(
        area_vector_passes_parikh_bounds(left[i], ps[i])
        and area_vector_passes_parikh_bounds(right[i], ps[i])
        for i in range(3)
    )


def determinant_fraction_free(matrix: IntMatrix) -> int:
    """Exact determinant by Bareiss elimination."""
    n = len(matrix)
    if n == 0 or any(len(row) != n for row in matrix):
        raise ValueError("square matrix required")
    a = [list(row) for row in matrix]
    sign = 1
    previous = 1
    for k in range(n - 1):
        if a[k][k] == 0:
            pivot = next((r for r in range(k + 1, n) if a[r][k] != 0), None)
            if pivot is None:
                return 0
            a[k], a[pivot] = a[pivot], a[k]
            sign *= -1
        pivot_value = a[k][k]
        for i in range(k + 1, n):
            for j in range(k + 1, n):
                a[i][j] = (a[i][j] * pivot_value - a[i][k] * a[k][j]) // previous
        previous = pivot_value
        for i in range(k + 1, n):
            a[i][k] = 0
        for j in range(k + 1, n):
            a[k][j] = 0
    return sign * a[n - 1][n - 1]


def characteristic_resultant_formula(t: int, u: int, d: int) -> int:
    """Res(chi_M, chi_Lambda2) with the standard resultant convention."""
    return -d * d * (t - u + d - 1) ** 2 * (
        -t * t * d - 2 * t * d + u * u + 2 * u * d + d * d - d
    )


def sylvester_operator_determinant_formula(t: int, u: int, d: int) -> int:
    """det[X -> (Lambda^2 M)X-XM] for a cubic with coefficients T,U,d.

    The operator determinant is the negative of Res(chi_M,chi_Lambda2):
    there are 3*3=9 pairwise eigenvalue differences and the order is reversed.
    """
    return -characteristic_resultant_formula(t, u, d)


def sylvester_determinant_for_substitution(sigma: Substitution) -> int:
    m = substitution_incidence(sigma)
    return determinant_fraction_free(sylvester_matrix(exterior_square(m), m))
