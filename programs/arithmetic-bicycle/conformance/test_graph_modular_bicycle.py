"""Independent finite evidence for the integral proof; no field-rank shortcuts."""

from collections import Counter
from itertools import combinations, permutations, product
import json
from math import gcd, prod
from pathlib import Path
import random
import unittest

from kernel.graph_bicycle import Graph
from oracles.graph_snf import (
    critical_key, critical_representatives, determinant, edge_order,
    graph_laplacian, reduced_laplacian, smith_invariants,
    torsion_factors, torsion_order_profile, tree_bicycles,
)

FIXTURE_PATH = Path(__file__).parent / "fixtures/graph-modular-bicycle-v1.json"
FIXTURES = json.loads(FIXTURE_PATH.read_text())["fixtures"]


def graph(f):
    return Graph(f["vertices"], f["edges"])


def add(a, b):
    return tuple(x + y for x, y in zip(a, b))


def scale(k, a):
    return tuple(k * x for x in a)


def oracle_key(g, d):
    return critical_key(g.vertices, g.edges, d)


class ExactOracleTests(unittest.TestCase):
    def test_bareiss_against_permutation_determinants(self):
        rng = random.Random(20261008)
        for size in range(6):
            for _ in range(10):
                a = [[rng.randrange(-9, 10) for _ in range(size)] for _ in range(size)]
                expected = 0
                for p in permutations(range(size)):
                    inversions = sum(p[i] > p[j] for i in range(size) for j in range(i + 1, size))
                    expected += (-1) ** inversions * prod(a[i][p[i]] for i in range(size))
                self.assertEqual(determinant(a), expected)

    def test_smith_factors_of_planted_unimodular_transforms(self):
        rng = random.Random(83021)
        for diagonal in ((), (1,), (2,), (1, 4, 4), (2, 6, 30), (1, 2, 8, 24), (2, 0, 0)):
            size = len(diagonal)
            a = [[diagonal[i] if i == j else 0 for j in range(size)] for i in range(size)]
            if size > 1:
                for _ in range(30):
                    i, j = rng.sample(range(size), 2)
                    k = rng.choice((-3, -2, -1, 1, 2, 3))
                    if rng.randrange(2):
                        a[i] = [x + k * y for x, y in zip(a[i], a[j])]
                    else:
                        for row in a:
                            row[i] += k * row[j]
                a[0] = [-x for x in a[0]]
            self.assertEqual(smith_invariants(a), diagonal)
        self.assertEqual(smith_invariants([[0, 2], [3, 0]]), (1, 6))
        self.assertEqual(smith_invariants([[0, 0], [0, 0]]), (0, 0))

    def test_snf_fixtures_at_every_root(self):
        for f in FIXTURES:
            g = graph(f)
            with self.subTest(fixture=f["id"]):
                self.assertEqual(g.laplacian, tuple(map(tuple, graph_laplacian(g.vertices, g.edges))))
                for root in range(g.vertices):
                    a = reduced_laplacian(g.vertices, g.edges, root)
                    self.assertEqual(smith_invariants(a), tuple(f["smith"]))
                    self.assertEqual(abs(determinant(a)), prod(f["smith"]))
                self.assertEqual(len(critical_representatives(g.vertices, g.edges)), prod(f["smith"]))

    def test_tree_cycle_oracle_against_all_edge_vectors(self):
        for f in FIXTURES:
            if len(f["edges"]) > 4:
                continue
            g = graph(f)
            for n in (2, 3, 4, 6):
                brute = set()
                # Literal enumeration of edges and endpoint potentials: a third route.
                cuts = {
                    tuple((y[h] - y[t]) % n for t, h in g.edges)
                    for y in product(range(n), repeat=g.vertices)
                }
                for b in product(range(n), repeat=len(g.edges)):
                    divergence = [0] * g.vertices
                    for value, (tail, head) in zip(b, g.edges):
                        divergence[tail] -= value
                        divergence[head] += value
                    if b in cuts and all(x % n == 0 for x in divergence):
                        brute.add(b)
                self.assertEqual(set(tree_bicycles(g.vertices, g.edges, n)), brute)


class GraphMapTests(unittest.TestCase):
    def test_iterable_edge_inputs_are_consumed_once(self):
        g = Graph(4, [(0, 1), (1, 2), (2, 3), (3, 0)])
        b = (1, 1, 1, 1)
        self.assertEqual(g.bicycle_to_divisor(iter(b), 4), g.bicycle_to_divisor(b, 4))
        self.assertEqual(g.reduce_bicycle(iter(b), 4, 2), (1, 1, 1, 1))
        self.assertEqual(g.inflate_bicycle(iter(b), 4, 12), (3, 3, 3, 3))

    def test_bicycle_sets_snf_and_element_orders(self):
        for f in FIXTURES:
            g = graph(f)
            for n in f["moduli"]:
                with self.subTest(fixture=f["id"], n=n):
                    candidate = g.bicycles(n)
                    oracle = set(tree_bicycles(g.vertices, g.edges, n))
                    self.assertEqual(set(candidate), oracle)
                    self.assertEqual(len(candidate), prod(torsion_factors(f["smith"], n)))
                    self.assertEqual(Counter(edge_order(b, n) for b in candidate),
                                     torsion_order_profile(f["smith"], n))
                    classes = set()
                    for b in candidate:
                        d = g.bicycle_to_divisor(b, n)
                        key = oracle_key(g, d)
                        classes.add(key)
                        self.assertTrue(all(x == 0 for x in oracle_key(g, scale(n, d))))
                        self.assertEqual(g.class_key(d, root=g.vertices - 1), key)
                        self.assertEqual(g.class_order(d), edge_order(b, n))
                        self.assertEqual(g.divisor_to_bicycle(d, n), b)
                    self.assertEqual(len(classes), len(candidate))

    def test_inverse_on_independently_enumerated_critical_group(self):
        for f in FIXTURES:
            g = graph(f)
            classes = critical_representatives(g.vertices, g.edges)
            for n in f["moduli"]:
                image = set()
                for key, d in classes.items():
                    if any((n * x) % 1 for x in key):
                        with self.assertRaisesRegex(ValueError, "not annihilated"):
                            g.divisor_to_bicycle(d, n)
                        continue
                    b = g.divisor_to_bicycle(d, n)
                    image.add(b)
                    self.assertEqual(oracle_key(g, g.bicycle_to_divisor(b, n)), key)
                    for root in range(g.vertices):
                        self.assertEqual(g.divisor_to_bicycle(d, n, root), b)
                self.assertEqual(image, set(tree_bicycles(g.vertices, g.edges, n)))

    def test_potential_and_divisor_representative_changes(self):
        for f in FIXTURES:
            g = graph(f)
            z = tuple(2 * v - 3 for v in range(g.vertices))
            for n in f["moduli"]:
                for b, y in g.bicycles(n).items():
                    d = g.bicycle_to_divisor(b, n, y)
                    shifted_y = add(add(y, scale(n, z)), (7,) * g.vertices)
                    shifted_d = g.bicycle_to_divisor(b, n, shifted_y)
                    self.assertEqual(shifted_d, add(d, g.laplacian_action(z)))
                    self.assertEqual(oracle_key(g, shifted_d), oracle_key(g, d))
                    self.assertEqual(g.divisor_to_bicycle(shifted_d, n), b)

    def test_additivity_and_scalar_linearity(self):
        for f in FIXTURES:
            g = graph(f)
            for n in f["moduli"]:
                elements = g.bicycles(n)
                divisors = {b: g.bicycle_to_divisor(b, n) for b in elements}
                for b in elements:
                    for c in elements:
                        total = tuple(x % n for x in add(b, c))
                        self.assertEqual(oracle_key(g, divisors[total]),
                                         oracle_key(g, add(divisors[b], divisors[c])))
                    for k in (-2, 0, 2, n, n + 1):
                        kb = tuple(x % n for x in scale(k, b))
                        self.assertEqual(oracle_key(g, divisors[kb]),
                                         oracle_key(g, scale(k, divisors[b])))

    def test_tower_reduction_inflation_and_composition(self):
        for f in FIXTURES:
            g = graph(f)
            elements = {n: g.bicycles(n) for n in f["moduli"]}
            for n in elements:
                for m in elements:
                    if m % n:
                        continue
                    k = m // n
                    for b in elements[m]:
                        reduced = g.reduce_bicycle(b, m, n)
                        self.assertIn(reduced, elements[n])
                        self.assertEqual(oracle_key(g, g.bicycle_to_divisor(reduced, n)),
                                         oracle_key(g, scale(k, g.bicycle_to_divisor(b, m))))
                        self.assertEqual(g.inflate_bicycle(reduced, n, m),
                                         tuple(x % m for x in scale(k, b)))
                    inflated = set()
                    for b in elements[n]:
                        value = g.inflate_bicycle(b, n, m)
                        inflated.add(value)
                        self.assertIn(value, elements[m])
                        self.assertEqual(oracle_key(g, g.bicycle_to_divisor(value, m)),
                                         oracle_key(g, g.bicycle_to_divisor(b, n)))
                        self.assertEqual(g.reduce_bicycle(value, m, n),
                                         tuple(x % n for x in scale(k, b)))
                    self.assertEqual(len(inflated), len(elements[n]))
                    for ell in elements:
                        if ell % m:
                            continue
                        for b in elements[ell]:
                            self.assertEqual(g.reduce_bicycle(g.reduce_bicycle(b, ell, m), m, n),
                                             g.reduce_bicycle(b, ell, n))
                        for b in elements[n]:
                            self.assertEqual(g.inflate_bicycle(g.inflate_bicycle(b, n, m), m, ell),
                                             g.inflate_bicycle(b, n, ell))

    def test_signed_edge_permutations_and_vertex_isomorphisms(self):
        for f in FIXTURES:
            g = graph(f)
            vertex_map = tuple(reversed(range(g.vertices)))
            edge_map = tuple(reversed(range(len(g.edges))))
            reversed_edges = tuple((vertex_map[g.edges[e][1]], vertex_map[g.edges[e][0]])
                                   for e in edge_map)
            changed = Graph(g.vertices, reversed_edges)
            for n in f["moduli"]:
                for b in g.bicycles(n):
                    new_b = tuple(-b[e] % n for e in edge_map)
                    d = g.bicycle_to_divisor(b, n)
                    new_d = [0] * g.vertices
                    for old, new in enumerate(vertex_map):
                        new_d[new] = d[old]
                    self.assertEqual(oracle_key(changed, changed.bicycle_to_divisor(new_b, n)),
                                     oracle_key(changed, new_d))
                    self.assertEqual(changed.divisor_to_bicycle(new_d, n), new_b)

    def test_all_connected_labeled_simple_graphs_up_to_four_vertices(self):
        count = 0
        for size in range(1, 5):
            possible = list(combinations(range(size), 2))
            for mask in range(1 << len(possible)):
                edges = [e for i, e in enumerate(possible) if mask & (1 << i)]
                try:
                    g = Graph(size, edges)
                except ValueError:
                    continue
                count += 1
                smith = smith_invariants(reduced_laplacian(size, edges))
                for n in (2, 3, 4, 6):
                    candidate = g.bicycles(n)
                    oracle = set(tree_bicycles(size, edges, n))
                    self.assertEqual(set(candidate), oracle)
                    self.assertEqual(len(candidate), prod(gcd(s, n) for s in smith))
                    for b in candidate:
                        d = g.bicycle_to_divisor(b, n)
                        self.assertEqual(g.divisor_to_bicycle(d, n), b)
        self.assertEqual(count, 44)


class InvalidConstructionTests(unittest.TestCase):
    def test_invalid_domains_fail_closed(self):
        for size, edges in ((0, []), (2, []), (3, [(0, 1)]), (1, [(0, 1)]),
                            (True, []), (2, [(0, 1.0)])):
            with self.assertRaises(ValueError):
                Graph(size, edges)
        g = Graph(3, [(0, 1), (1, 2), (2, 0)])
        for n in (0, 1, -2, True, 3.0):
            with self.assertRaises(ValueError):
                g.bicycles(n)
            with self.assertRaises(ValueError):
                g.divisor_to_bicycle((0, 0, 0), n)
        for d in ((1, 0, 0), (0, 0), (0.0, 0, 0)):
            with self.assertRaises(ValueError):
                g.divisor_to_bicycle(d, 3)
        for b in ((0, 0), (0.0, 0, 0)):
            with self.assertRaises(ValueError):
                g.bicycle_to_divisor(b, 3)
        for root in (-1, 3, True):
            with self.assertRaises(ValueError):
                g.class_key((0, 0, 0), root)
        with self.assertRaises(ValueError):
            g.reduce_bicycle((0, 0, 0), 3, 2)
        with self.assertRaises(ValueError):
            g.inflate_bicycle((0, 0, 0), 2, 3)
        with self.assertRaises(ValueError):
            smith_invariants([[1, 2]])
        with self.assertRaises(ValueError):
            determinant([[1.0]])
        with self.assertRaises(ValueError):
            list(tree_bicycles(2, [], 4))

    def test_cycles_and_cuts_are_both_required(self):
        triangle = Graph(3, [(0, 1), (1, 2), (2, 0)])
        with self.assertRaisesRegex(ValueError, "not a modular cut"):
            triangle.bicycle_to_divisor((1, 1, 1), 2)
        with self.assertRaisesRegex(ValueError, "not a modular cycle"):
            triangle.bicycle_to_divisor((1, 0, 1), 2)
        with self.assertRaisesRegex(ValueError, "does not represent"):
            triangle.bicycle_to_divisor((1, 1, 1), 3, (0, 0, 0))
        with self.assertRaisesRegex(ValueError, "not annihilated"):
            triangle.divisor_to_bicycle((1, -1, 0), 2)

    def test_arbitrary_edge_lift_cannot_replace_gradient_lift(self):
        square = Graph(4, [(0, 1), (1, 2), (2, 3), (3, 0)])
        b, y = (1, 1, 1, 1), (0, 1, 2, 3)
        correct = square.bicycle_to_divisor(b, 4, y)
        self.assertEqual(correct, (-1, 0, 0, 1))
        self.assertEqual(square.class_order(correct), 4)
        # B applied to the residues is zero; B applied to B^T y is not.
        wrong = tuple(x // 4 for x in square.divergence(b))
        self.assertNotEqual(oracle_key(square, wrong), oracle_key(square, correct))
        wrong_potential = correct
        with self.assertRaisesRegex(ValueError, "does not represent"):
            square.bicycle_to_divisor(b, 4, wrong_potential)

    def test_reduction_is_not_inclusion_or_necessarily_surjective(self):
        parallel = Graph(2, [(0, 1), (0, 1)])
        self.assertEqual(set(parallel.bicycles(2)), {(0, 0), (1, 1)})
        self.assertEqual(set(parallel.bicycles(4)), {(0, 0), (2, 2)})
        self.assertEqual({parallel.reduce_bicycle(b, 4, 2) for b in parallel.bicycles(4)}, {(0, 0)})
        self.assertEqual(parallel.inflate_bicycle((1, 1), 2, 4), (2, 2))
        with self.assertRaisesRegex(ValueError, "not a modular cycle"):
            parallel.bicycle_to_divisor((1, 1), 4)

    def test_prime_ranks_miss_prime_power_exponents(self):
        parallel = Graph(2, [(0, 1), (0, 1)])
        square = Graph(4, [(0, 1), (1, 2), (2, 3), (3, 0)])
        self.assertEqual(len(parallel.bicycles(2)), len(square.bicycles(2)))
        self.assertEqual(len(parallel.bicycles(4)), 2)
        self.assertEqual(len(square.bicycles(4)), 4)
        self.assertEqual(torsion_order_profile((2,), 4), {1: 1, 2: 1})
        self.assertEqual(torsion_order_profile((1, 1, 4), 4), {1: 1, 2: 1, 4: 2})


if __name__ == "__main__":
    unittest.main()
