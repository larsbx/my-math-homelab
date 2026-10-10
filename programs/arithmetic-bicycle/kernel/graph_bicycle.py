"""Candidate exact graph maps; theorem authority lives in proof/, not here.

Only Python integers and Fraction are used. Enumeration is for small fixtures:
it visits n**(vertices - 1) normalized potentials, without silently capping it.
"""

from dataclasses import dataclass
from fractions import Fraction
from functools import cached_property, lru_cache
from itertools import product
from math import lcm


def modulus(n):
    if type(n) is not int or n < 2:
        raise ValueError("modulus must be an integer >= 2")
    return n


def integer_vector(values, length):
    values = tuple(values)
    if len(values) != length or any(type(x) is not int for x in values):
        raise ValueError("wrong vector length or non-integral coordinate")
    return values


@dataclass(frozen=True)
class Graph:
    """Finite connected undirected multigraph with oriented edge coordinates."""

    vertices: int
    edges: tuple

    def __post_init__(self):
        if type(self.vertices) is not int or self.vertices < 1:
            raise ValueError("a graph needs a positive integer vertex count")
        edges = tuple(tuple(e) for e in self.edges)
        for e in edges:
            if len(e) != 2 or any(
                type(v) is not int or not 0 <= v < self.vertices for v in e
            ):
                raise ValueError("invalid edge endpoints")
        object.__setattr__(self, "edges", edges)
        reached = {0}
        pending = [0]
        while pending:
            v = pending.pop()
            for a, b in edges:
                if a == v and b not in reached:
                    reached.add(b)
                    pending.append(b)
                if b == v and a not in reached:
                    reached.add(a)
                    pending.append(a)
        if len(reached) != self.vertices:
            raise ValueError("graph must be connected")

    @cached_property
    def incidence(self):
        rows = [[0] * len(self.edges) for _ in range(self.vertices)]
        for e, (tail, head) in enumerate(self.edges):
            rows[tail][e] -= 1
            rows[head][e] += 1
        return tuple(map(tuple, rows))

    @cached_property
    def laplacian(self):
        return tuple(
            tuple(sum(a * b for a, b in zip(row, other)) for other in self.incidence)
            for row in self.incidence
        )

    def gradient(self, potential):
        y = integer_vector(potential, self.vertices)
        return tuple(y[head] - y[tail] for tail, head in self.edges)

    def divergence(self, edge_values):
        b = integer_vector(edge_values, len(self.edges))
        return tuple(sum(x * y for x, y in zip(row, b)) for row in self.incidence)

    def laplacian_action(self, potential):
        return self.divergence(self.gradient(potential))

    def divisor(self, d):
        d = integer_vector(d, self.vertices)
        if sum(d):
            raise ValueError("critical-group divisor must have degree zero")
        return d

    def bicycle_potential(self, edge_values, n):
        """Recover the unique root-zero potential, or reject a non-bicycle."""
        modulus(n)
        b = tuple(x % n for x in integer_vector(edge_values, len(self.edges)))
        if any(x % n for x in self.divergence(b)):
            raise ValueError("edge vector is not a modular cycle")
        y = [None] * self.vertices
        y[0] = 0
        pending = [0]
        while pending:
            v = pending.pop()
            for e, (tail, head) in enumerate(self.edges):
                if tail == v:
                    w, value = head, (y[v] + b[e]) % n
                elif head == v:
                    w, value = tail, (y[v] - b[e]) % n
                else:
                    continue
                if y[w] is None:
                    y[w] = value
                    pending.append(w)
                elif y[w] != value:
                    raise ValueError("edge vector is not a modular cut")
        return tuple(y)

    def bicycle_to_divisor(self, edge_values, n, potential=None):
        """Phi_n: return a degree-zero divisor representing [Ly/n].

        Optional potential may be any integral lift, including negative entries.
        A raw edge lift cannot replace the integral gradient in this formula.
        """
        b = integer_vector(edge_values, len(self.edges))
        canonical = self.bicycle_potential(b, n)
        y = canonical if potential is None else integer_vector(potential, self.vertices)
        b = tuple(x % n for x in b)
        if tuple(x % n for x in self.gradient(y)) != b:
            raise ValueError("potential does not represent this bicycle")
        ly = self.laplacian_action(y)
        if any(x % n for x in ly):
            raise ValueError("Laplacian of potential is not divisible by modulus")
        return tuple(x // n for x in ly)

    def reduced_inverse(self, root=0):
        if type(root) is not int or not 0 <= root < self.vertices:
            raise ValueError("invalid root")
        return self._reduced_inverse(root)

    @lru_cache(maxsize=None)
    def _reduced_inverse(self, root):
        indices = [v for v in range(self.vertices) if v != root]
        size = len(indices)
        a = [
            [Fraction(self.laplacian[i][j]) for j in indices]
            + [Fraction(i == j) for j in indices]
            for i in indices
        ]
        for col in range(size):
            pivot = next((r for r in range(col, size) if a[r][col]), None)
            if pivot is None:
                raise ArithmeticError("connected graph has singular reduced Laplacian")
            a[col], a[pivot] = a[pivot], a[col]
            scale = a[col][col]
            a[col] = [x / scale for x in a[col]]
            for r in range(size):
                if r != col:
                    scale = a[r][col]
                    a[r] = [x - scale * y for x, y in zip(a[r], a[col])]
        return tuple(tuple(row[size:]) for row in a)

    def rational_potential(self, d, root=0):
        d = self.divisor(d)
        inverse = self.reduced_inverse(root)
        indices = [v for v in range(self.vertices) if v != root]
        y = [Fraction(0)] * self.vertices
        for v, row in zip(indices, inverse):
            y[v] = sum((x * d[w] for x, w in zip(row, indices)), Fraction(0))
        return tuple(y)

    def class_key(self, d, root=0):
        """Faithful rational-potential coordinate in (Q/Z)**(V-1)."""
        y = self.rational_potential(d, root)
        return tuple(x % 1 for v, x in enumerate(y) if v != root)

    def class_order(self, d):
        return lcm(*(x.denominator for x in self.class_key(d)))

    def divisor_to_bicycle(self, d, n, root=0):
        """Psi_n: solve Ly=nd exactly; reject a class outside K(G)[n]."""
        modulus(n)
        d = self.divisor(d)
        y = self.rational_potential(tuple(n * x for x in d), root)
        if any(x.denominator != 1 for x in y):
            raise ValueError("divisor class is not annihilated by modulus")
        y = tuple(int(x) for x in y)
        if self.laplacian_action(y) != tuple(n * x for x in d):
            raise ArithmeticError("exact inverse failed the full Laplacian equation")
        return tuple(x % n for x in self.gradient(y))

    def bicycles(self, n):
        """Exhaustive normalized-potential enumeration for small fixtures."""
        modulus(n)
        answer = {}
        for tail in product(range(n), repeat=self.vertices - 1):
            y = (0,) + tail
            if all(x % n == 0 for x in self.laplacian_action(y)):
                b = tuple(x % n for x in self.gradient(y))
                answer[b] = y
        return answer

    def reduce_bicycle(self, b, m, n):
        modulus(m)
        modulus(n)
        if m % n:
            raise ValueError("target modulus must divide source modulus")
        b = integer_vector(b, len(self.edges))
        self.bicycle_potential(b, m)
        return tuple(x % n for x in b)

    def inflate_bicycle(self, b, n, m):
        modulus(n)
        modulus(m)
        if m % n:
            raise ValueError("source modulus must divide target modulus")
        b = integer_vector(b, len(self.edges))
        self.bicycle_potential(b, n)
        return tuple((m // n) * x % m for x in b)
