"""Route 2: determinantal divisors and integral lattice membership.

Imports no enumeration or source kernel code. Smith invariant factors are
recovered from gcds of ALL k-minors over Z, using exact cofactor determinants.
Suitable only for this deliberately tiny, resource-bounded fixture domain.
"""
from itertools import combinations
from math import gcd, prod


def determinant(square):
    if not square:
        return 1
    if len(square) == 1:
        return square[0][0]
    return sum((-1 if j % 2 else 1) * square[0][j] * determinant(
        [row[:j] + row[j+1:] for row in square[1:]])
        for j in range(len(square)))


def minor_gcd(rows, width, size):
    value = 0
    for ri in combinations(range(len(rows)), size):
        for ci in combinations(range(width), size):
            value = gcd(value, determinant([[rows[i][j] for j in ci] for i in ri]))
    return abs(value)


def smith_factors(rows, width):
    factors, previous = [], 1
    for size in range(1, min(len(rows), width) + 1):
        divisor = minor_gcd(rows, width, size)
        if divisor == 0:
            break
        if divisor % previous:
            raise ValueError("invalid determinantal-divisor chain")
        factors.append(divisor // previous)
        previous = divisor
    return factors


def arithmetic_signature(rows, columns):
    result = []
    for mask in range(1 << columns):
        indices = [j for j in range(columns) if mask & (1 << j)]
        sub = [[row[j] for j in indices] for row in rows]
        factors = smith_factors(sub, len(indices))
        result.append([len(factors), prod(factors)])
    return result


def kernel_order(factors, domain_dimension, modulus):
    return modulus ** (domain_dimension - len(factors)) * prod(
        gcd(modulus, factor) for factor in factors)


def gram_quotient(rows, columns, modulus):
    rank = len(rows)
    transpose = [[rows[i][j] for i in range(rank)] for j in range(columns)]
    gram = [[sum(a*b for a, b in zip(left, right)) for right in rows] for left in rows]
    transpose_factors = smith_factors(transpose, rank)
    gram_factors = smith_factors(gram, rank)
    numerator = kernel_order(gram_factors, rank, modulus)
    denominator = kernel_order(transpose_factors, rank, modulus)
    if numerator % denominator:
        raise ValueError("Gram kernel quotient is not integral")
    return {"gram": gram, "gram_smith_factors": gram_factors,
            "transpose_smith_factors": transpose_factors,
            "gram_kernel_order": numerator, "transpose_kernel_order": denominator,
            "bicycle_order": numerator // denominator}


def verify_witnesses(rows, columns, modulus, witnesses, expected_order):
    # A full-rank lattice L = A^T Z^r + n Z^e.  A vector x is a cut
    # exactly when adjoining it leaves the index [Z^e:L] unchanged.
    # This never generates potentials or imports the enumerator.
    if len(witnesses) != expected_order:
        raise ValueError("enumeration and independent Smith quotient disagree")
    if any(not isinstance(x, list) or len(x) != columns
           or any(type(v) is not int or not 0 <= v < modulus for v in x)
           for x in witnesses):
        raise ValueError("malformed or noncanonical witness")
    if len({tuple(x) for x in witnesses}) != len(witnesses):
        raise ValueError("duplicate witnesses cannot prove completeness")
    lattice = [[rows[i][j] for i in range(len(rows))] +
               [modulus if j == k else 0 for k in range(columns)]
               for j in range(columns)]
    width = len(rows) + columns
    index = minor_gcd(lattice, width, columns)
    for x in witnesses:
        if any(sum(row[j] * x[j] for j in range(columns)) % modulus for row in rows):
            raise ValueError("witness is not a cycle")
        augmented = [row + [x[j]] for j, row in enumerate(lattice)]
        if minor_gcd(augmented, width+1, columns) != index:
            raise ValueError("witness is not in the integral cut lattice")
    # Membership + distinctness + independently computed cardinality is complete.
    return True
