"""Independent TU and Gram-group oracle; no imports from kernel/."""

from fractions import Fraction
from functools import lru_cache
from itertools import combinations, product

from oracles.graph_snf import determinant, smith_invariants


def matrix_data(rows, columns=None):
    matrix = tuple(tuple(row) for row in rows)
    width = (len(matrix[0]) if matrix else 0) if columns is None else columns
    if type(width) is not int or width < 0:
        raise ValueError("invalid column count")
    if any(len(row) != width or any(type(x) is not int for x in row) for row in matrix):
        raise ValueError("expected rectangular integer data")
    return matrix, width


def is_totally_unimodular(rows, columns=None):
    a, width = matrix_data(rows, columns)
    for k in range(1, min(len(a), width) + 1):
        for rr in combinations(range(len(a)), k):
            for cc in combinations(range(width), k):
                if abs(determinant([[a[i][j] for j in cc] for i in rr])) > 1:
                    return False
    return True


def gram_matrix(rows, columns=None):
    a, width = matrix_data(rows, columns)
    return tuple(tuple(sum(a[i][k] * a[j][k] for k in range(width)) for j in range(len(a)))
                 for i in range(len(a)))


def last_unimodular_basis(a, width):
    for cols in reversed(tuple(combinations(range(width), len(a)))):
        square = [[row[j] for j in cols] for row in a]
        if abs(determinant(square)) == 1:
            return cols
    raise ValueError("no unimodular column basis")


def integral_cramer_inverse(matrix):
    denominator = determinant(matrix)
    if abs(denominator) != 1:
        raise ValueError("basis is not unimodular")
    size = len(matrix)
    inverse = [[0] * size for _ in range(size)]
    for rhs in range(size):
        for col in range(size):
            replaced = [list(row) for row in matrix]
            for row in range(size):
                replaced[row][col] = int(row == rhs)
            inverse[col][rhs] = determinant(replaced) // denominator
    return tuple(map(tuple, inverse))


def cycle_bicycles(rows, n, columns=None):
    if type(n) is not int or n < 2:
        raise ValueError("invalid modulus")
    a, width = matrix_data(rows, columns)
    return set(_cycle_bicycles(a, width, n))


@lru_cache(maxsize=None)
def _cycle_bicycles(a, width, n):
    rank = len(a)
    if rank == 0:
        return ((0,) * width,)
    basis = last_unimodular_basis(a, width)
    free = tuple(j for j in range(width) if j not in basis)
    inverse = integral_cramer_inverse([[row[j] for j in basis] for row in a])
    answer = []
    for values in product(range(n), repeat=len(free)):
        b = [0] * width
        for j, value in zip(free, values):
            b[j] = value
        rhs = [sum(a[i][j] * b[j] for j in free) for i in range(rank)]
        for j, row in zip(basis, inverse):
            b[j] = -sum(x * y for x, y in zip(row, rhs)) % n
        if any(sum(a[i][j] * b[j] for j in range(width)) % n for i in range(rank)):
            raise ArithmeticError("basis cycle completion failed")
        # b_basis = C^T y, hence y = (C^-1)^T b_basis.
        y = [sum(inverse[j][i] * b[basis[j]] for j in range(rank)) % n for i in range(rank)]
        if all(sum(a[i][j] * y[i] for i in range(rank)) % n == b[j] for j in range(width)):
            answer.append(tuple(b))
    return tuple(answer)


def quotient_key(gram, divisor):
    q = tuple(tuple(row) for row in gram)
    d = tuple(divisor)
    if len(d) != len(q) or any(type(x) is not int for x in d):
        raise ValueError("invalid quotient representative")
    denominator = determinant(q)
    if not denominator:
        raise ValueError("Gram matrix is singular")
    key = []
    for col in range(len(q)):
        replaced = [list(row) for row in q]
        for row in range(len(q)):
            replaced[row][col] = d[row]
        key.append(Fraction(determinant(replaced), denominator) % 1)
    return tuple(key)


def quotient_representatives(gram):
    order = abs(determinant(gram))
    if not order:
        raise ValueError("Gram matrix is singular")
    rank = len(gram)
    zero = (Fraction(0),) * rank
    representatives, pending = {zero: (0,) * rank}, [zero]
    generators = []
    for i in range(rank):
        d = tuple(int(j == i) for j in range(rank))
        generators.append((quotient_key(gram, d), d))
    for key in pending:
        d = representatives[key]
        for generator_key, generator in generators:
            next_key = tuple((x + y) % 1 for x, y in zip(key, generator_key))
            if next_key not in representatives:
                representatives[next_key] = tuple(x + y for x, y in zip(d, generator))
                pending.append(next_key)
                if len(representatives) > order:
                    raise ArithmeticError("quotient exceeds determinant order")
    if len(representatives) != order:
        raise ArithmeticError("quotient enumeration disagrees with determinant")
    return representatives


def literal_bicycles(rows, n, columns=None):
    """Literal potential enumeration for controls, including non-TU matrices."""
    if type(n) is not int or n < 2:
        raise ValueError("invalid modulus")
    a, width = matrix_data(rows, columns)
    cuts = {tuple(sum(a[i][j] * y[i] for i in range(len(a))) % n for j in range(width))
            for y in product(range(n), repeat=len(a))}
    return {b for b in cuts if all(sum(row[j] * b[j] for j in range(width)) % n == 0 for row in a)}
