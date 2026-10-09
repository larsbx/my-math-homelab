"""Independent acceptance-review regressions for PR #3.

Expected classes use the separate Bareiss/Cramer quotient oracle. The
non-TU coordinate checks use literal modular cut/cycle enumeration, not
an extension or bypass of the candidate's TU-only executable contract.
"""

from fractions import Fraction
from itertools import permutations, product
import json
from math import gcd, prod
from pathlib import Path
import unittest

from kernel.regular_bicycle import TURepresentation
from oracles.regular_snf import (
    determinant, gram_matrix, is_totally_unimodular, literal_bicycles,
    quotient_key, quotient_representatives,
)


def action(matrix, vector):
    return tuple(sum(x * y for x, y in zip(row, vector)) for row in matrix)


def gradient(matrix, potential):
    return tuple(sum(row[j] * y for row, y in zip(matrix, potential))
                 for j in range(len(matrix[0])))


def cramer_solution(matrix, rhs):
    denominator = determinant(matrix)
    answer = []
    for j in range(len(matrix)):
        replaced = [list(row) for row in matrix]
        for i, value in enumerate(rhs):
            replaced[i][j] = value
        answer.append(Fraction(determinant(replaced), denominator))
    return tuple(answer)


class IndependentRegularReviewTests(unittest.TestCase):
    def test_all_signed_column_changes_with_a_non_tu_row_change(self):
        rows = ((-1, 0, 1), (1, -1, 0))
        a = TURepresentation(rows)
        u = ((2, 1), (1, 1))  # det=1; U A has an entry 2.
        inverse_transpose = ((1, -1), (-1, 2))
        row_changed = (
            tuple(2 * x + y for x, y in zip(*rows)),
            tuple(x + y for x, y in zip(*rows)),
        )
        self.assertEqual(determinant(u), 1)
        self.assertFalse(is_totally_unimodular(row_changed))
        for permutation in permutations(range(3)):
            for signs in product((-1, 1), repeat=3):
                changed = tuple(tuple(sign * row[j] for j, sign in zip(permutation, signs))
                                for row in row_changed)
                with self.assertRaises(ValueError):
                    TURepresentation(changed)
                q = gram_matrix(changed)
                for n in (2, 3, 4, 6, 9, 12):
                    expected = {tuple(sign * b[j] % n for j, sign in zip(permutation, signs))
                                for b in a.bicycles(n)}
                    self.assertEqual(literal_bicycles(changed, n), expected)
                    for b, y in a.bicycles(n).items():
                        new_b = tuple(sign * b[j] % n for j, sign in zip(permutation, signs))
                        new_y = action(inverse_transpose, y)
                        self.assertEqual(tuple(x % n for x in gradient(changed, new_y)), new_b)
                        qy = action(q, new_y)
                        self.assertTrue(all(x % n == 0 for x in qy))
                        new_d = action(u, a.bicycle_to_divisor(b, n, y))
                        self.assertEqual(tuple(x // n for x in qy), new_d)
                        solved = cramer_solution(q, tuple(n * x for x in new_d))
                        self.assertEqual(solved, new_y)
                        self.assertEqual(tuple(x % n for x in gradient(changed, solved)), new_b)

    def test_noncyclic_group_at_large_composite_moduli(self):
        data = json.loads((Path(__file__).parent / "fixtures/regular-modular-bicycle-v1.json").read_text())
        fixture = next(f for f in data["fixtures"] if f["id"] == "cographic-k33")
        a = TURepresentation(fixture["matrix"])
        classes = quotient_representatives(a.gram)
        self.assertEqual(len(classes), 81)
        for n in (12, 18, 27, 36, 54, 72, 108, 216, 9 * 2**80 * 5**4):
            expected = {key: d for key, d in classes.items()
                        if all((n * x) % 1 == 0 for x in key)}
            self.assertEqual(len(expected), prod(gcd(n, s) for s in fixture["smith"]))
            edges = set()
            for key, d in classes.items():
                y = cramer_solution(a.gram, tuple(n * x for x in d))
                if key not in expected:
                    self.assertTrue(any(x.denominator != 1 for x in y))
                    with self.assertRaises(ValueError):
                        a.divisor_to_bicycle(d, n)
                    continue
                self.assertTrue(all(x.denominator == 1 for x in y))
                y = tuple(map(int, y))
                b = tuple(x % n for x in gradient(a.rows, y))
                self.assertTrue(all(x % n == 0 for x in action(a.rows, b)))
                self.assertEqual(a.divisor_to_bicycle(d, n), b)
                self.assertEqual(a.bicycle_to_divisor(b, n, y), d)
                self.assertEqual(quotient_key(a.gram, a.bicycle_to_divisor(b, n)), key)
                edges.add(b)
            self.assertEqual(len(edges), len(expected))

    def test_noncyclic_tower_pairs_and_strict_chains(self):
        rows = ((1, -1, 0, -1, 1, 0, 0, 0, 0),
                (1, 0, -1, -1, 0, 1, 0, 0, 0),
                (1, -1, 0, 0, 0, 0, -1, 1, 0),
                (1, 0, -1, 0, 0, 0, -1, 0, 1))
        a = TURepresentation(rows)
        classes = quotient_representatives(a.gram)
        moduli = (2, 3, 6, 9, 12, 18, 27, 36, 54, 72, 108, 216)
        modules = {}
        for n in moduli:
            modules[n] = {}
            for key, d in classes.items():
                if all((n * x) % 1 == 0 for x in key):
                    y = cramer_solution(a.gram, tuple(n * x for x in d))
                    b = tuple(int(x) % n for x in gradient(rows, y))
                    modules[n][b] = key
        for n in moduli:
            for m in moduli:
                if m <= n or m % n:
                    continue
                k = m // n
                for b, key in modules[m].items():
                    reduced = a.reduce_bicycle(b, m, n)
                    self.assertEqual(modules[n][reduced], tuple(k * x % 1 for x in key))
                    self.assertEqual(a.inflate_bicycle(reduced, n, m), tuple(k * x % m for x in b))
                inflated = set()
                for b, key in modules[n].items():
                    value = a.inflate_bicycle(b, n, m)
                    self.assertEqual(modules[m][value], key)
                    self.assertEqual(a.reduce_bicycle(value, m, n), tuple(k * x % n for x in b))
                    inflated.add(value)
                self.assertEqual(len(inflated), len(modules[n]))
                for ell in moduli:
                    if ell <= m or ell % m:
                        continue
                    for b in modules[ell]:
                        self.assertEqual(a.reduce_bicycle(a.reduce_bicycle(b, ell, m), m, n),
                                         a.reduce_bicycle(b, ell, n))
                    for b in modules[n]:
                        self.assertEqual(a.inflate_bicycle(a.inflate_bicycle(b, n, m), m, ell),
                                         a.inflate_bicycle(b, n, ell))

    def test_scalar_obstruction_from_literal_edge_membership(self):
        for n in range(2, 129):
            cuts = {2 * y % n for y in range(n)}
            expected = {(b,) for b in range(n) if b in cuts and 2 * b % n == 0}
            self.assertEqual(literal_bicycles(((2,),), n), expected)
            self.assertEqual(len(expected), gcd(n, 4) // gcd(n, 2))
            if n % 2 == 0:
                # y=0 and y=n/2 give b=0, but Gram classes 0 and 2.
                self.assertEqual(2 * (n // 2) % n, 0)
                self.assertEqual(4 * (n // 2) // n, 2)
                self.assertNotEqual(quotient_key(((4,),), (0,)), quotient_key(((4,),), (2,)))
        self.assertEqual(literal_bicycles(((2,),), 2), {(0,)})
        self.assertEqual(literal_bicycles(((2,),), 4), {(0,), (2,)})


if __name__ == "__main__":
    unittest.main()
