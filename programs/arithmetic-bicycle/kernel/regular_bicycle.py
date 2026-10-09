"""Candidate exact maps for fixed full-row-rank TU representations.

Every TU minor is verified. Enumeration and certification are intended for
small exact fixtures, not a scalable TU-recognition algorithm.
"""

from dataclasses import dataclass, field
from fractions import Fraction
from functools import cached_property, lru_cache
from itertools import combinations, product
from math import lcm

from kernel.graph_bicycle import integer_vector, modulus


def rectangular_matrix(rows, columns=None):
    rows = tuple(tuple(row) for row in rows)
    inferred = len(rows[0]) if rows else 0
    columns = inferred if columns is None else columns
    if type(columns) is not int or columns < 0:
        raise ValueError("column count must be a nonnegative integer")
    if any(len(row) != columns or any(type(x) is not int for x in row) for row in rows):
        raise ValueError("expected a rectangular integer matrix")
    return rows, columns


def integer_determinant(matrix):
    """Exact rational elimination, separate from the Bareiss oracle."""
    a = [[Fraction(x) for x in row] for row in matrix]
    size = len(a)
    if any(len(row) != size for row in a):
        raise ValueError("expected a square matrix")
    determinant = Fraction(1)
    for col in range(size):
        pivot = next((r for r in range(col, size) if a[r][col]), None)
        if pivot is None:
            return 0
        if pivot != col:
            a[col], a[pivot] = a[pivot], a[col]
            determinant = -determinant
        diagonal = a[col][col]
        determinant *= diagonal
        for r in range(col + 1, size):
            multiple = a[r][col] / diagonal
            for j in range(col + 1, size):
                a[r][j] -= multiple * a[col][j]
            a[r][col] = Fraction(0)
    if determinant.denominator != 1:
        raise ArithmeticError("integer determinant became non-integral")
    return int(determinant)


def rational_inverse(matrix):
    size = len(matrix)
    a = [[Fraction(x) for x in row] + [Fraction(i == j) for j in range(size)]
         for i, row in enumerate(matrix)]
    for col in range(size):
        pivot = next((r for r in range(col, size) if a[r][col]), None)
        if pivot is None:
            raise ValueError("matrix is singular")
        a[col], a[pivot] = a[pivot], a[col]
        value = a[col][col]
        a[col] = [x / value for x in a[col]]
        for r in range(size):
            if r != col:
                value = a[r][col]
                a[r] = [x - value * y for x, y in zip(a[r], a[col])]
    return tuple(tuple(row[size:]) for row in a)


@dataclass(frozen=True)
class TURepresentation:
    rows: tuple
    columns: int | None = None
    basis: tuple = field(init=False)

    def __post_init__(self):
        rows, columns = rectangular_matrix(self.rows, self.columns)
        object.__setattr__(self, "rows", rows)
        object.__setattr__(self, "columns", columns)
        rank = len(rows)
        for size in range(1, min(rank, columns) + 1):
            for rr in combinations(range(rank), size):
                for cc in combinations(range(columns), size):
                    if integer_determinant([[rows[i][j] for j in cc] for i in rr]) not in (-1, 0, 1):
                        raise ValueError("matrix is not totally unimodular")
        basis = next((cc for cc in combinations(range(columns), rank)
                      if abs(integer_determinant([[row[j] for j in cc] for row in rows])) == 1), None)
        if basis is None:
            raise ValueError("TU representation must have full row rank")
        object.__setattr__(self, "basis", basis)

    @property
    def rank(self):
        return len(self.rows)

    @cached_property
    def gram(self):
        return tuple(tuple(sum(x * y for x, y in zip(row, other)) for other in self.rows)
                     for row in self.rows)

    @cached_property
    def right_inverse(self):
        inverse = rational_inverse(tuple(tuple(row[j] for j in self.basis) for row in self.rows))
        if any(x.denominator != 1 for row in inverse for x in row):
            raise ArithmeticError("unimodular basis inverse is not integral")
        answer = [[0] * self.rank for _ in range(self.columns)]
        for j, row in zip(self.basis, inverse):
            answer[j] = [int(x) for x in row]
        if any(sum(self.rows[i][j] * answer[j][k] for j in range(self.columns)) != (i == k)
               for i in range(self.rank) for k in range(self.rank)):
            raise ArithmeticError("integral right inverse does not split A")
        return tuple(map(tuple, answer))

    def gradient(self, potential):
        y = integer_vector(potential, self.rank)
        return tuple(sum(self.rows[i][j] * y[i] for i in range(self.rank))
                     for j in range(self.columns))

    def divergence(self, edge_values):
        b = integer_vector(edge_values, self.columns)
        return tuple(sum(x * y for x, y in zip(row, b)) for row in self.rows)

    def gram_action(self, potential):
        return self.divergence(self.gradient(potential))

    def bicycle_potential(self, edge_values, n):
        modulus(n)
        b = tuple(x % n for x in integer_vector(edge_values, self.columns))
        if any(x % n for x in self.divergence(b)):
            raise ValueError("edge vector is not a modular cycle")
        y = tuple(sum(self.right_inverse[j][i] * b[j] for j in range(self.columns)) % n
                  for i in range(self.rank))
        if tuple(x % n for x in self.gradient(y)) != b:
            raise ValueError("edge vector is not a modular cut")
        return y

    def bicycle_to_divisor(self, edge_values, n, potential=None):
        b = integer_vector(edge_values, self.columns)
        y = self.bicycle_potential(b, n)
        if potential is not None:
            y = integer_vector(potential, self.rank)
        if tuple(x % n for x in self.gradient(y)) != tuple(x % n for x in b):
            raise ValueError("potential does not represent this bicycle")
        qy = self.gram_action(y)
        if any(x % n for x in qy):
            raise ArithmeticError("bicycle potential has nondivisible Gram image")
        return tuple(x // n for x in qy)

    @cached_property
    def gram_inverse(self):
        return rational_inverse(self.gram)

    def rational_potential(self, divisor):
        d = integer_vector(divisor, self.rank)
        return tuple(sum((x * y for x, y in zip(row, d)), Fraction(0))
                     for row in self.gram_inverse)

    def class_key(self, divisor):
        return tuple(x % 1 for x in self.rational_potential(divisor))

    def class_order(self, divisor):
        return lcm(*(x.denominator for x in self.class_key(divisor)))

    def divisor_to_bicycle(self, divisor, n):
        modulus(n)
        d = integer_vector(divisor, self.rank)
        y = self.rational_potential(tuple(n * x for x in d))
        if any(x.denominator != 1 for x in y):
            raise ValueError("divisor class is not annihilated by modulus")
        y = tuple(int(x) for x in y)
        if self.gram_action(y) != tuple(n * x for x in d):
            raise ArithmeticError("inverse failed the full Gram equation")
        return tuple(x % n for x in self.gradient(y))

    def bicycles(self, n):
        modulus(n)
        return dict(self._bicycles(n))

    @lru_cache(maxsize=None)
    def _bicycles(self, n):
        answer = []
        for y in product(range(n), repeat=self.rank):
            if all(x % n == 0 for x in self.gram_action(y)):
                answer.append((tuple(x % n for x in self.gradient(y)), y))
        return tuple(answer)

    def reduce_bicycle(self, edge_values, m, n):
        modulus(m)
        modulus(n)
        if m % n:
            raise ValueError("target modulus must divide source modulus")
        b = integer_vector(edge_values, self.columns)
        self.bicycle_potential(b, m)
        return tuple(x % n for x in b)

    def inflate_bicycle(self, edge_values, n, m):
        modulus(n)
        modulus(m)
        if m % n:
            raise ValueError("source modulus must divide target modulus")
        b = integer_vector(edge_values, self.columns)
        self.bicycle_potential(b, n)
        return tuple((m // n) * x % m for x in b)
