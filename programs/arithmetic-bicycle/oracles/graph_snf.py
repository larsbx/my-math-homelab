"""Independent small-graph oracle: minors/SNF, tree cycles, Cramer classes.

No imports from kernel/. Smith factors are computed from determinantal
divisors, not field ranks or a floating-point eigendecomposition. This is
exponential in matrix dimension and intended for the pinned small fixtures.
"""

from fractions import Fraction
from itertools import combinations, product
from math import gcd, lcm, prod


def square_matrix(matrix):
    a = [list(row) for row in matrix]
    if any(len(row) != len(a) or any(type(x) is not int for x in row) for row in a):
        raise ValueError("expected a square integer matrix")
    return a


def determinant(matrix):
    """Fraction-free Bareiss determinant, including row swaps and singularity."""
    a = square_matrix(matrix)
    size = len(a)
    if not size:
        return 1
    sign, previous = 1, 1
    for k in range(size - 1):
        pivot = next((r for r in range(k, size) if a[r][k]), None)
        if pivot is None:
            return 0
        if pivot != k:
            a[k], a[pivot] = a[pivot], a[k]
            sign = -sign
        for i in range(k + 1, size):
            for j in range(k + 1, size):
                numerator = a[k][k] * a[i][j] - a[i][k] * a[k][j]
                value, remainder = divmod(numerator, previous)
                if remainder:
                    raise ArithmeticError("Bareiss division was not exact")
                a[i][j] = value
            a[i][k] = 0
        previous = a[k][k]
    return sign * a[-1][-1]


def smith_invariants(matrix):
    """The nonnegative diagonal of SNF, via gcds of all k by k minors.

    With Delta_0=1 and Delta_k the gcd of the k-minors, s_k=Delta_k/Delta_(k-1).
    Once all k-minors vanish, the remaining Smith factors are zero.
    No change-of-basis matrices are needed for this independent group oracle.
    """
    a = square_matrix(matrix)
    size = len(a)
    factors, previous = [], 1
    for k in range(1, size + 1):
        delta = 0
        for rows in combinations(range(size), k):
            for cols in combinations(range(size), k):
                minor = [[a[i][j] for j in cols] for i in rows]
                delta = gcd(delta, abs(determinant(minor)))
        if not delta:
            return tuple(factors + [0] * (size - len(factors)))
        factor, remainder = divmod(delta, previous)
        if remainder or (factors and factor % factors[-1]):
            raise ArithmeticError("invalid determinantal-divisor chain")
        factors.append(factor)
        previous = delta
    return tuple(factors)


def graph_data(vertices, edges):
    if type(vertices) is not int or vertices < 1:
        raise ValueError("invalid vertex count")
    edges = tuple(tuple(e) for e in edges)
    if any(len(e) != 2 or any(type(v) is not int or not 0 <= v < vertices for v in e)
           for e in edges):
        raise ValueError("invalid endpoints")
    return edges


def graph_laplacian(vertices, edges):
    """Construct from edge multiplicities directly, without incidence products."""
    edges = graph_data(vertices, edges)
    a = [[0] * vertices for _ in range(vertices)]
    for tail, head in edges:
        if tail != head:
            a[tail][tail] += 1
            a[head][head] += 1
            a[tail][head] -= 1
            a[head][tail] -= 1
    return a


def reduced_laplacian(vertices, edges, root=None):
    root = vertices - 1 if root is None else root
    if type(root) is not int or not 0 <= root < vertices:
        raise ValueError("invalid root")
    a = graph_laplacian(vertices, edges)
    keep = [i for i in range(vertices) if i != root]
    return [[a[i][j] for j in keep] for i in keep]


def critical_key(vertices, edges, divisor):
    """Faithful class coordinate, computed by Cramer's rule at the LAST root."""
    d = tuple(divisor)
    if len(d) != vertices or any(type(x) is not int for x in d) or sum(d):
        raise ValueError("invalid degree-zero divisor")
    a = reduced_laplacian(vertices, edges)
    denominator = determinant(a)
    if not denominator:
        raise ValueError("singular reduced Laplacian")
    key = []
    for col in range(vertices - 1):
        replaced = [row[:] for row in a]
        for row in range(vertices - 1):
            replaced[row][col] = d[row]
        key.append(Fraction(determinant(replaced), denominator) % 1)
    return tuple(key)


def critical_representatives(vertices, edges):
    """Enumerate the finite quotient from divisor generators and Cramer keys.

    Independent of bicycle enumeration and of the claimed map. The determinant
    is a fail-closed check on exhaustion, not a truncation of the search.
    """
    order = abs(determinant(reduced_laplacian(vertices, edges)))
    if not order:
        raise ValueError("singular reduced Laplacian")
    zero = (Fraction(0),) * (vertices - 1)
    representatives = {zero: (0,) * vertices}
    pending = [zero]
    generators = []
    for v in range(vertices - 1):
        d = [0] * vertices
        d[v], d[-1] = 1, -1
        generators.append((critical_key(vertices, edges, d), tuple(d)))
    for key in pending:
        d = representatives[key]
        for generator_key, generator in generators:
            new_key = tuple((a + b) % 1 for a, b in zip(key, generator_key))
            if new_key not in representatives:
                representatives[new_key] = tuple(a + b for a, b in zip(d, generator))
                pending.append(new_key)
                if len(representatives) > order:
                    raise ArithmeticError("class enumeration exceeds determinant")
    if len(representatives) != order:
        raise ArithmeticError("class enumeration disagrees with determinant")
    return representatives


def tree_bicycles(vertices, edges, n):
    """Enumerate ALL cycles from chord values, then retain exact modular cuts.

    Tree incidence entries are +/-1, so leaf elimination is valid over any
    Z/n. There are n**(E-V+1) iterations, including loop chords, without a cap.
    """
    if type(n) is not int or n < 2:
        raise ValueError("invalid modulus")
    edges = graph_data(vertices, edges)
    adjacency = [[] for _ in range(vertices)]
    for e, (tail, head) in enumerate(edges):
        if tail != head:
            adjacency[tail].append((head, e, -1))
            adjacency[head].append((tail, e, 1))
    root = vertices - 1
    parent, parent_edge, parent_sign = {}, {}, {}
    order, reached = [root], {root}
    for v in order:
        for w, e, sign_at_v in adjacency[v]:
            if w not in reached:
                reached.add(w)
                order.append(w)
                parent[w], parent_edge[w], parent_sign[w] = v, e, -sign_at_v
    if len(reached) != vertices:
        raise ValueError("graph must be connected")
    tree = set(parent_edge.values())
    chords = [e for e in range(len(edges)) if e not in tree]
    for values in product(range(n), repeat=len(chords)):
        b, divergence = [0] * len(edges), [0] * vertices
        for e, value in zip(chords, values):
            b[e] = value
            tail, head = edges[e]
            divergence[tail] -= value
            divergence[head] += value
        for v in reversed(order[1:]):
            e, sign = parent_edge[v], parent_sign[v]
            value = (-sign * divergence[v]) % n
            b[e] = value
            divergence[v] += sign * value
            divergence[parent[v]] -= sign * value
        if any(value % n for value in divergence):
            raise ArithmeticError("tree cycle completion failed")
        potential = [0] * vertices
        for v in order[1:]:
            potential[v] = (potential[parent[v]] + parent_sign[v] * b[parent_edge[v]]) % n
        if all((potential[head] - potential[tail]) % n == b[e]
               for e, (tail, head) in enumerate(edges)):
            yield tuple(b)


def edge_order(b, n):
    return lcm(*(n // gcd(n, x) for x in b))


def torsion_factors(smith, n):
    if type(n) is not int or n < 2 or any(s < 1 for s in smith):
        raise ValueError("expected positive Smith factors and modulus >= 2")
    return tuple(gcd(s, n) for s in smith)


def torsion_order_profile(smith, n):
    """Order distribution of direct sum Z/gcd(s_i,n), without enumerating it."""
    factors = torsion_factors(smith, n)
    counts = {}
    for d in range(1, n + 1):
        if n % d == 0:
            divides = prod(gcd(f, d) for f in factors)
            exact = divides - sum(count for smaller, count in counts.items() if d % smaller == 0)
            if exact:
                counts[d] = exact
    return counts
