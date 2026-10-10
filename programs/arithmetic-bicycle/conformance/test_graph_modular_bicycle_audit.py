"""Independent review regressions: mixed signs, loops, and composite towers.

The literal two-vertex answer and the independently enumerated critical
quotient supply expectations; group size alone is never the map oracle.
"""

from itertools import permutations
import unittest

from kernel.graph_bicycle import Graph
from oracles.graph_snf import (
    critical_key, critical_representatives, reduced_laplacian,
    smith_invariants, tree_bicycles,
)


DOUBLED_TRIANGLE = ((0, 1), (0, 1), (1, 2), (1, 2), (2, 0), (2, 0))
COMPOSITE_TOWER = (2, 3, 4, 6, 8, 9, 12, 18, 24, 36, 72)


def key(g, d):
    return critical_key(g.vertices, g.edges, d)


class IndependentReviewTests(unittest.TestCase):
    def test_single_vertex_with_no_edges_and_loop_only_graphs(self):
        for edges in ((), ((0, 0),), ((0, 0), (0, 0))):
            g = Graph(1, edges)
            zero = (0,) * len(edges)
            self.assertEqual(g.laplacian, ((0,),))
            for n in (2, 4, 6, 12):
                self.assertEqual(set(g.bicycles(n)), {zero})
                self.assertEqual(set(tree_bicycles(1, edges, n)), {zero})
                self.assertEqual(g.bicycle_to_divisor(zero, n, (-(1 << 90),)), (0,))
                self.assertEqual(g.divisor_to_bicycle((0,), n), zero)
                self.assertEqual(g.class_order((0,)), 1)
                if edges:
                    bad = (1,) + zero[1:]
                    with self.assertRaisesRegex(ValueError, "not a modular cut"):
                        g.bicycle_to_divisor(bad, n)

    def test_literal_parallel_edges_with_loops_and_large_lift_changes(self):
        # With y=(0,u), cuts are (0,u,-u,0); cycles require n | 2u.
        g = Graph(2, ((0, 0), (0, 1), (1, 0), (1, 1)))
        self.assertEqual(g.laplacian, ((2, -2), (-2, 2)))
        for n in (*range(2, 37), 72, 144):
            expected = {(0, u, (-u) % n, 0): u for u in range(n) if (2 * u) % n == 0}
            self.assertEqual(set(g.bicycles(n)), set(expected))
            for b, u in expected.items():
                d = (-2 * u // n, 2 * u // n)
                self.assertEqual(g.bicycle_to_divisor(b, n, (0, u)), d)
                self.assertEqual(g.divisor_to_bicycle(d, n), b)
                z = (1 << 80, -(1 << 75))
                c = -(1 << 93)
                shifted = (c + n * z[0], u + c + n * z[1])
                shifted_d = g.bicycle_to_divisor(b, n, shifted)
                self.assertEqual(shifted_d, tuple(a + v for a, v in zip(d, g.laplacian_action(z))))
                self.assertEqual(key(g, shifted_d), key(g, d))
                self.assertEqual(g.divisor_to_bicycle(shifted_d, n, root=1), b)
                edge_lift = tuple(v + n * ((-1) ** i) * (1 << (70 + i)) for i, v in enumerate(b))
                self.assertEqual(key(g, g.bicycle_to_divisor(edge_lift, n)), key(g, d))
            with self.assertRaisesRegex(ValueError, "not a modular cut"):
                g.bicycle_to_divisor((1, 0, 0, 0), n)

    def test_every_mixed_orientation_and_vertex_permutation(self):
        g = Graph(3, DOUBLED_TRIANGLE)
        elements = {n: g.bicycles(n) for n in (6, 12)}
        for vertex_map in permutations(range(3)):
            for mask in range(1 << len(g.edges)):
                shift = mask % len(g.edges)
                edge_map = tuple(range(shift, len(g.edges))) + tuple(range(shift))
                if mask & 1:
                    edge_map = tuple(reversed(edge_map))
                changed_edges, signs = [], []
                for e in edge_map:
                    tail, head = g.edges[e]
                    sign = -1 if mask & (1 << e) else 1
                    if sign == -1:
                        tail, head = head, tail
                    changed_edges.append((vertex_map[tail], vertex_map[head]))
                    signs.append(sign)
                changed = Graph(3, changed_edges)
                for n, bicycles in elements.items():
                    for b, y in bicycles.items():
                        new_b = tuple(sign * b[e] % n for sign, e in zip(signs, edge_map))
                        d = g.bicycle_to_divisor(b, n, y)
                        new_d, new_y = [0] * 3, [0] * 3
                        for old, new in enumerate(vertex_map):
                            new_d[new], new_y[new] = d[old], y[old]
                        self.assertEqual(changed.bicycle_to_divisor(new_b, n, new_y), tuple(new_d))
                        self.assertEqual(key(changed, changed.bicycle_to_divisor(new_b, n)),
                                         key(changed, new_d))
                        for root in range(3):
                            self.assertEqual(changed.divisor_to_bicycle(new_d, n, root), new_b)

    def test_noncyclic_composite_tower_and_all_divisibility_chains(self):
        g = Graph(3, DOUBLED_TRIANGLE)
        self.assertEqual(smith_invariants(reduced_laplacian(3, g.edges)), (2, 6))
        classes = critical_representatives(3, g.edges)
        self.assertEqual(len(classes), 12)
        elements, divisors = {}, {}
        for n in COMPOSITE_TOWER:
            elements[n] = g.bicycles(n)
            divisors[n] = {b: g.bicycle_to_divisor(b, n) for b in elements[n]}
            expected = {k: d for k, d in classes.items() if all((n * x) % 1 == 0 for x in k)}
            self.assertEqual({key(g, d) for d in divisors[n].values()}, set(expected))
            self.assertEqual(len(elements[n]), len(expected))
            self.assertEqual({g.divisor_to_bicycle(d, n) for d in expected.values()}, set(elements[n]))
            for k, d in expected.items():
                b = g.divisor_to_bicycle(d, n)
                self.assertEqual(key(g, divisors[n][b]), k)
            if n <= 12:
                self.assertEqual(set(elements[n]), set(tree_bicycles(3, g.edges, n)))
        for n in COMPOSITE_TOWER:
            for m in COMPOSITE_TOWER:
                if m % n:
                    continue
                k = m // n
                for b, d in divisors[m].items():
                    reduced = g.reduce_bicycle(b, m, n)
                    self.assertEqual(key(g, divisors[n][reduced]), key(g, tuple(k * x for x in d)))
                    self.assertEqual(g.inflate_bicycle(reduced, n, m), tuple(k * x % m for x in b))
                inflated = {g.inflate_bicycle(b, n, m) for b in elements[n]}
                self.assertEqual(len(inflated), len(elements[n]))
                for b, d in divisors[n].items():
                    value = g.inflate_bicycle(b, n, m)
                    self.assertEqual(key(g, divisors[m][value]), key(g, d))
                    self.assertEqual(g.reduce_bicycle(value, m, n), tuple(k * x % n for x in b))
                for ell in COMPOSITE_TOWER:
                    if ell % m:
                        continue
                    for b in elements[ell]:
                        self.assertEqual(g.reduce_bicycle(g.reduce_bicycle(b, ell, m), m, n),
                                         g.reduce_bicycle(b, ell, n))
                    for b in elements[n]:
                        self.assertEqual(g.inflate_bicycle(g.inflate_bicycle(b, n, m), m, ell),
                                         g.inflate_bicycle(b, n, ell))
        # K is Z/2 + Z/6: this reduction is zero on its twelve-element domain.
        self.assertEqual(len(elements[12]), 12)
        self.assertEqual({g.reduce_bicycle(b, 72, 12) for b in elements[72]}, {(0,) * 6})


if __name__ == "__main__":
    unittest.main()
