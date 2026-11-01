"""Route 1: literal finite-module enumeration, without Smith/Gram code."""
from itertools import product


def enumerate_bicycles(rows, columns, modulus):
    # Enumerate ALL edge vectors for ker(A), and ALL potentials for im(A^T).
    # No field rank, pivot normalization, or division modulo a composite.
    cuts = {
        tuple(sum(rows[i][j] * y[i] for i in range(len(rows))) % modulus
              for j in range(columns))
        for y in product(range(modulus), repeat=len(rows))
    }
    cycles = {
        x for x in product(range(modulus), repeat=columns)
        if all(sum(a * b for a, b in zip(row, x)) % modulus == 0
               for row in rows)
    }
    return sorted(cuts & cycles)
