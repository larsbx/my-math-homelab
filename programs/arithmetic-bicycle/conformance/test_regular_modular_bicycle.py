"""Exact independent conformance for the fixed-TU theorem and its boundary."""

from itertools import combinations, product
import json
from math import gcd, prod
from pathlib import Path
import unittest

from kernel.graph_bicycle import Graph
from kernel.regular_bicycle import TURepresentation, integer_determinant
from oracles.graph_snf import edge_order, torsion_order_profile
from oracles.regular_snf import (
    cycle_bicycles, determinant, gram_matrix, integral_cramer_inverse,
    is_totally_unimodular, last_unimodular_basis, literal_bicycles,
    quotient_key, quotient_representatives, smith_invariants,
)

HERE = Path(__file__).parent
DATA = json.loads((HERE / "fixtures/regular-modular-bicycle-v1.json").read_text())
FIXTURES = DATA["fixtures"]


def representation(f):
    return TURepresentation(f["matrix"], f["columns"])


def add(a, b):
    return tuple(x + y for x, y in zip(a, b))


def scale(k, a):
    return tuple(k * x for x in a)


def key(a, d):
    return quotient_key(a.gram, d)


class RegularOracleTests(unittest.TestCase):
    def test_tu_certificates_gram_smith_and_right_inverses(self):
        for f in FIXTURES:
            a = representation(f)
            with self.subTest(fixture=f["id"]):
                self.assertTrue(is_totally_unimodular(a.rows, a.columns))
                self.assertEqual(a.gram, gram_matrix(a.rows, a.columns))
                self.assertEqual(smith_invariants(a.gram), tuple(f["smith"]))
                self.assertEqual(integer_determinant(a.gram), determinant(a.gram))
                for i in range(a.rank):
                    for j in range(a.rank):
                        self.assertEqual(sum(a.rows[i][k] * a.right_inverse[k][j]
                                             for k in range(a.columns)), int(i == j))
                basis = last_unimodular_basis(a.rows, a.columns)
                c = tuple(tuple(row[j] for j in basis) for row in a.rows)
                inverse = integral_cramer_inverse(c)
                for i in range(a.rank):
                    for j in range(a.rank):
                        self.assertEqual(sum(c[i][k] * inverse[k][j] for k in range(a.rank)), int(i == j))
                self.assertEqual(len(quotient_representatives(a.gram)), prod(f["smith"]))

    def test_cycle_oracle_against_literal_potential_and_edge_enumeration(self):
        for f in FIXTURES:
            if f["columns"] > 4:
                continue
            a = representation(f)
            for n in (2, 3, 4, 6):
                cuts = {tuple(sum(a.rows[i][j] * y[i] for i in range(a.rank)) % n
                              for j in range(a.columns))
                        for y in product(range(n), repeat=a.rank)}
                brute = {b for b in product(range(n), repeat=a.columns)
                         if b in cuts and all(sum(row[j] * b[j] for j in range(a.columns)) % n == 0
                                              for row in a.rows)}
                self.assertEqual(cycle_bicycles(a.rows, n, a.columns), brute)

    def test_cographic_fixture_is_an_integral_fundamental_cycle_basis(self):
        f = next(f for f in FIXTURES if f["id"] == "cographic-k33")
        a = representation(f)
        edges = tuple((left, right) for left in range(3) for right in range(3, 6))
        g = Graph(6, edges)
        for row in a.rows:
            self.assertEqual(g.divergence(row), (0,) * 6)
        chords = (4, 5, 7, 8)
        self.assertEqual(tuple(tuple(row[j] for j in chords) for row in a.rows),
                         tuple(tuple(int(i == j) for j in range(4)) for i in range(4)))
        self.assertTrue(is_totally_unimodular(a.rows))
        self.assertEqual(smith_invariants(a.gram), (1, 3, 3, 9))


class RegularMapTests(unittest.TestCase):
    def test_bijection_against_independently_enumerated_quotients(self):
        for f in FIXTURES:
            a = representation(f)
            classes = quotient_representatives(a.gram)
            for n in f["moduli"]:
                with self.subTest(fixture=f["id"], n=n):
                    bicycles = a.bicycles(n)
                    oracle = cycle_bicycles(a.rows, n, a.columns)
                    self.assertEqual(set(bicycles), oracle)
                    expected = {k: d for k, d in classes.items() if all((n * x) % 1 == 0 for x in k)}
                    images = set()
                    for b in bicycles:
                        d = a.bicycle_to_divisor(b, n)
                        images.add(key(a, d))
                        self.assertEqual(a.class_key(d), key(a, d))
                        self.assertEqual(a.divisor_to_bicycle(d, n), b)
                        self.assertEqual(a.class_order(d), edge_order(b, n))
                    self.assertEqual(images, set(expected))
                    self.assertEqual(len(images), len(bicycles))
                    inverse_image = set()
                    for k, d in classes.items():
                        if k not in expected:
                            with self.assertRaisesRegex(ValueError, "not annihilated"):
                                a.divisor_to_bicycle(d, n)
                        else:
                            b = a.divisor_to_bicycle(d, n)
                            inverse_image.add(b)
                            self.assertEqual(key(a, a.bicycle_to_divisor(b, n)), k)
                    self.assertEqual(inverse_image, oracle)
                    orders = {d: sum(edge_order(b, n) == d for b in bicycles)
                              for d in range(1, n + 1) if any(edge_order(b, n) == d for b in bicycles)}
                    self.assertEqual(orders, torsion_order_profile(f["smith"], n))

    def test_integral_lifts_divisor_changes_and_iterable_inputs(self):
        for f in FIXTURES:
            a = representation(f)
            z = tuple((-1) ** i * (1 << (80 + i)) for i in range(a.rank))
            for n in f["moduli"]:
                for b, y in a.bicycles(n).items():
                    d = a.bicycle_to_divisor(b, n, y)
                    lifted = add(y, scale(n, z))
                    shifted = a.bicycle_to_divisor(iter(b), n, lifted)
                    self.assertEqual(shifted, add(d, a.gram_action(z)))
                    self.assertEqual(key(a, shifted), key(a, d))
                    self.assertEqual(a.divisor_to_bicycle(iter(shifted), n), b)
                    edge_lift = tuple(value + n * ((-1) ** j) * (1 << (90 + j))
                                      for j, value in enumerate(b))
                    self.assertEqual(key(a, a.bicycle_to_divisor(edge_lift, n)), key(a, d))
                    self.assertEqual(a.reduce_bicycle(iter(b), n, n), b)
                    self.assertEqual(a.inflate_bicycle(iter(b), n, n), b)

    def test_linearity_on_every_fixture_bicycle_pair(self):
        for f in FIXTURES:
            a = representation(f)
            for n in f["moduli"]:
                bicycles = a.bicycles(n)
                keys = {b: key(a, a.bicycle_to_divisor(b, n)) for b in bicycles}
                for b in bicycles:
                    for c in bicycles:
                        total = tuple(x % n for x in add(b, c))
                        self.assertEqual(keys[total], tuple(x % 1 for x in add(keys[b], keys[c])))
                    for k in (-2, 0, 2, n, n + 1):
                        value = tuple(x % n for x in scale(k, b))
                        self.assertEqual(keys[value], tuple(x % 1 for x in scale(k, keys[b])))

    def test_modulus_maps_and_every_fixture_divisibility_chain(self):
        for f in FIXTURES:
            a = representation(f)
            elements = {n: a.bicycles(n) for n in f["moduli"]}
            divisors = {n: {b: a.bicycle_to_divisor(b, n) for b in elements[n]} for n in elements}
            for n in elements:
                for m in elements:
                    if m % n:
                        continue
                    k = m // n
                    for b, d in divisors[m].items():
                        reduced = a.reduce_bicycle(b, m, n)
                        self.assertIn(reduced, elements[n])
                        self.assertEqual(key(a, divisors[n][reduced]), key(a, scale(k, d)))
                        self.assertEqual(a.inflate_bicycle(reduced, n, m), tuple(x % m for x in scale(k, b)))
                    inflated = set()
                    for b, d in divisors[n].items():
                        value = a.inflate_bicycle(b, n, m)
                        inflated.add(value)
                        self.assertIn(value, elements[m])
                        self.assertEqual(key(a, divisors[m][value]), key(a, d))
                        self.assertEqual(a.reduce_bicycle(value, m, n), tuple(x % n for x in scale(k, b)))
                    self.assertEqual(len(inflated), len(elements[n]))
                    for ell in elements:
                        if ell % m:
                            continue
                        for b in elements[ell]:
                            self.assertEqual(a.reduce_bicycle(a.reduce_bicycle(b, ell, m), m, n),
                                             a.reduce_bicycle(b, ell, n))
                        for b in elements[n]:
                            self.assertEqual(a.inflate_bicycle(a.inflate_bicycle(b, n, m), m, ell),
                                             a.inflate_bicycle(b, n, ell))

    def test_signed_column_permutations(self):
        for f in FIXTURES:
            a = representation(f)
            permutation = tuple(reversed(range(a.columns)))
            signs = tuple((-1) ** j for j in range(a.columns))
            changed = TURepresentation(tuple(tuple(sign * row[j] for j, sign in zip(permutation, signs))
                                             for row in a.rows), a.columns)
            self.assertEqual(changed.gram, a.gram)
            for n in f["moduli"]:
                for b, y in a.bicycles(n).items():
                    new_b = tuple(sign * b[j] % n for j, sign in zip(permutation, signs))
                    d = a.bicycle_to_divisor(b, n, y)
                    self.assertEqual(changed.bicycle_to_divisor(new_b, n, y), d)
                    self.assertEqual(changed.divisor_to_bicycle(d, n), new_b)

    def test_nonorthogonal_unimodular_row_coordinates(self):
        a = TURepresentation(((-1, 0, 1), (1, -1, 0)))
        changed = TURepresentation((add(a.rows[0], a.rows[1]), a.rows[1]))
        self.assertNotEqual(changed.gram, a.gram)
        for n in (2, 3, 4, 6, 9, 12):
            self.assertEqual(set(changed.bicycles(n)), set(a.bicycles(n)))
            for b, y in a.bicycles(n).items():
                new_y = (y[0], y[1] - y[0])
                d = a.bicycle_to_divisor(b, n, y)
                new_d = (d[0] + d[1], d[1])
                self.assertEqual(changed.bicycle_to_divisor(b, n, new_y), new_d)
                self.assertEqual(changed.divisor_to_bicycle(new_d, n), b)
            for d in quotient_representatives(a.gram).values():
                if all((n * x) % 1 == 0 for x in key(a, d)):
                    new_d = (d[0] + d[1], d[1])
                    self.assertEqual(changed.divisor_to_bicycle(new_d, n), a.divisor_to_bicycle(d, n))

    def test_graph_specialization_at_every_fixture_root(self):
        graph_fixtures = json.loads((HERE / "fixtures/graph-modular-bicycle-v1.json").read_text())["fixtures"]
        for f in graph_fixtures:
            g = Graph(f["vertices"], f["edges"])
            for root in range(g.vertices):
                keep = tuple(v for v in range(g.vertices) if v != root)
                a = TURepresentation(tuple(g.incidence[v] for v in keep), len(g.edges))
                for n in (2, 3, 4, 6):
                    self.assertEqual(set(a.bicycles(n)), set(g.bicycles(n)))
                    for b, y in g.bicycles(n).items():
                        normalized = tuple(y[v] - y[root] for v in keep)
                        graph_d = g.bicycle_to_divisor(b, n, y)
                        matrix_d = tuple(graph_d[v] for v in keep)
                        self.assertEqual(a.bicycle_to_divisor(b, n, normalized), matrix_d)
                        self.assertEqual(a.divisor_to_bicycle(matrix_d, n), b)

    def test_all_729_ternary_two_by_three_matrices(self):
        accepted = 0
        for flat in product((-1, 0, 1), repeat=6):
            rows = (flat[:3], flat[3:])
            gram = gram_matrix(rows)
            supported = is_totally_unimodular(rows) and determinant(gram) != 0
            if not supported:
                with self.assertRaises(ValueError):
                    TURepresentation(rows)
                continue
            accepted += 1
            a = TURepresentation(rows)
            smith = smith_invariants(gram)
            for n in (2, 3, 4, 6):
                bicycles = a.bicycles(n)
                self.assertEqual(set(bicycles), cycle_bicycles(rows, n))
                self.assertEqual(len(bicycles), prod(gcd(s, n) for s in smith))
                for b in bicycles:
                    d = a.bicycle_to_divisor(b, n)
                    self.assertEqual(a.divisor_to_bicycle(d, n), b)
        self.assertGreater(accepted, 0)


class ArithmeticBoundaryTests(unittest.TestCase):
    def test_invalid_domains_and_non_tu_representations(self):
        for rows, width in (([[2]], None), ([[1, 1], [1, -1]], None),
                            ([[1, 1], [1, 1]], None), ([[1.0]], None),
                            ([[True]], None), ([[1], [1, 0]], None),
                            ([], -1), ([], True), ([[1]], 2)):
            with self.assertRaises(ValueError):
                TURepresentation(rows, width)
        a = TURepresentation(((1, -1),))
        a.bicycles(2)  # Populate caches before testing bool/float aliases.
        for n in (0, 1, -2, True, 2.0):
            with self.assertRaises(ValueError):
                a.bicycles(n)
            with self.assertRaises(ValueError):
                a.divisor_to_bicycle((0,), n)
        for b in ((0,), (0.0, 0), (True, 0)):
            with self.assertRaises(ValueError):
                a.bicycle_to_divisor(b, 2)
        with self.assertRaisesRegex(ValueError, "not a modular cycle"):
            a.bicycle_to_divisor((1, 0), 2)
        with self.assertRaisesRegex(ValueError, "not a modular cut"):
            a.bicycle_to_divisor((1, 1), 3)
        with self.assertRaisesRegex(ValueError, "does not represent"):
            a.bicycle_to_divisor((1, 1), 2, (0,))
        with self.assertRaisesRegex(ValueError, "not annihilated"):
            a.divisor_to_bicycle((1,), 3)
        for d in ((0, 0), (0.0,), (True,)):
            with self.assertRaises(ValueError):
                a.divisor_to_bicycle(d, 2)
        with self.assertRaises(ValueError):
            a.reduce_bicycle((0, 0), 3, 2)
        with self.assertRaises(ValueError):
            a.inflate_bicycle((0, 0), 2, 3)
        rank_zero = TURepresentation((), 2)
        with self.assertRaisesRegex(ValueError, "not a modular cut"):
            rank_zero.bicycle_to_divisor((1, 0), 4)

    def test_nonprimitive_potentials_make_the_formula_ambiguous(self):
        rows, gram = ((2,),), ((4,),)
        self.assertFalse(is_totally_unimodular(rows))
        with self.assertRaises(ValueError):
            TURepresentation(rows)
        self.assertEqual(literal_bicycles(rows, 2), {(0,)})
        self.assertNotEqual(quotient_key(gram, (0,)), quotient_key(gram, (2,)))
        # Both y=0 and y=1 represent b=0 modulo 2, but Qy/2 gives different classes.
        self.assertEqual(2 * 0 % 2, 2 * 1 % 2)
        self.assertEqual(len(quotient_representatives(gram)), 4)

    def test_torsion_free_does_not_imply_a_universal_group_model(self):
        rows = ((2,),)
        self.assertEqual(literal_bicycles(rows, 2), {(0,)})
        self.assertEqual(literal_bicycles(rows, 4), {(0,), (2,)})
        for n in range(2, 25):
            bicycles = literal_bicycles(rows, n)
            self.assertEqual(len(bicycles), gcd(n, 4) // gcd(n, 2))
        # Any nonzero 4-torsion element forces nonzero 2-torsion: either x or 2x.
        self.assertEqual(gcd(2, 4) // gcd(2, 2), 1)
        self.assertEqual(gcd(4, 4) // gcd(4, 2), 2)

    def test_tu_is_sufficient_and_not_necessary(self):
        rows, gram = ((1, 2),), ((5,),)
        self.assertFalse(is_totally_unimodular(rows))
        for n in (2, 3, 4, 5, 6, 10):
            bicycles = literal_bicycles(rows, n)
            self.assertEqual(bicycles, cycle_bicycles(rows, n))
            self.assertEqual(len(bicycles), gcd(5, n))
            images = {quotient_key(gram, (5 * b[0] // n,)) for b in bicycles}
            self.assertEqual(len(images), len(bicycles))

    def test_raw_edge_residues_do_not_supply_the_forward_divisor(self):
        a = representation(next(f for f in FIXTURES if f["id"] == "graphic-cycle-four"))
        b, y = (1, 1, 1, 1), (-3, -2, -1)
        correct = a.bicycle_to_divisor(b, 4, y)
        self.assertEqual(correct, (-1, 0, 0))
        self.assertEqual(a.class_order(correct), 4)
        wrong = tuple(x // 4 for x in a.divergence(b))
        self.assertNotEqual(key(a, wrong), key(a, correct))


if __name__ == "__main__":
    unittest.main()
