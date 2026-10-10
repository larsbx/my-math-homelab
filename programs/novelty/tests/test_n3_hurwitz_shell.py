import unittest
from itertools import product

from support import load

H = load("experiments/n3/hurwitz_shell.py", "hurwitz_shell")
A = load("experiments/n3/analyze_collisions.py", "n3_analyze")
GUARDS_CLAIM = "HurwitzShellCountFinite"


def odd_sigma(n: int) -> int:
    return sum(d for d in range(1, n + 1, 2) if n % d == 0)


def brute_shell(n: int) -> int:
    r = 2 * n
    return sum(1 for X in product(range(-r, r + 1), repeat=4)
               if sum(t * t for t in X) == 4 * n and len({t % 2 for t in X}) == 1)


class TestShell(unittest.TestCase):
    def test_count_matches_odd_divisor_sum(self):
        """Finite check of |S_n| = 24·σ_1(odd part of n) for n ≤ 200."""
        for n in range(1, 201):
            with self.subTest(n=n):
                self.assertEqual(len(H.shell(n)), 24 * odd_sigma(n))

    def test_enumeration_against_brute_force(self):
        for n in range(1, 7):
            self.assertEqual(len(H.shell(n)), brute_shell(n))

    def test_units_form_a_group_of_order_24(self):
        units = set(H.UNITS)
        self.assertEqual(len(units), 24)
        self.assertTrue(all(H.hmul(u, v) in units for u in units for v in units))

    def test_hurwitz_order_is_closed(self):
        for x in H.shell(3):
            for y in H.shell(5):
                self.assertIn(H.hmul(x, y), set(H.shell(15)))


class TestOccupancy(unittest.TestCase):
    CASES = [(n, ell) for ell in (3, 5, 7) for n in (1, 2, 4, 11, 26) if n % ell]

    def test_target_size_is_sl2_order(self):
        for n, ell in self.CASES:
            self.assertEqual(len(H.target(n, ell)), ell ** 3 - ell)

    def test_mass_and_orbit_counts(self):
        for n, ell in self.CASES:
            with self.subTest(n=n, ell=ell):
                plain, left = H.occupancy(n, ell), H.occupancy(n, ell, "left")
                self.assertEqual(sum(plain["multiplicities"]), 24 * odd_sigma(n))
                self.assertEqual(len(plain["multiplicities"]), ell ** 3 - ell)
                self.assertEqual(24 * sum(left["multiplicities"]), sum(plain["multiplicities"]))
                self.assertEqual(24 * len(left["multiplicities"]), len(plain["multiplicities"]))

    def test_unit_quotient_scales_the_histogram_by_24(self):
        """Free equivariant action: each plain fiber count equals its orbit's count, so only sample size changes."""
        for n, ell in self.CASES:
            plain = A.analyze(H.occupancy(n, ell))["observed_histogram"]
            left = A.analyze(H.occupancy(n, ell, "left"))["observed_histogram"]
            self.assertEqual(plain, [24 * c for c in left])

    def test_no_collisions_below_quarter_ell_squared(self):
        """x ≠ y with x − y ∈ ℓH needs ℓ² ≤ N(x − y) ≤ 4n."""
        for n, ell in ((11, 7), (29, 11), (41, 13)):
            self.assertLessEqual(max(H.occupancy(n, ell)["multiplicities"]), 1)
        self.assertGreater(max(H.occupancy(13, 7)["multiplicities"]), 1)

    def test_committed_grid_is_current(self):
        G = load("experiments/n3/grid.py", "n3_grid")
        self.assertEqual(G.OUT.read_text(encoding="utf-8"), G.render())

    def test_reduction_is_equivariant(self):
        ell = 7
        for u in H.UNITS:
            for x in H.shell(10):
                self.assertEqual(H.reduce_mod(H.hmul(u, x), ell),
                                 H.rmul(H.reduce_mod(u, ell), H.reduce_mod(x, ell), ell))

    def test_payload_feeds_the_analyzer(self):
        r = A.analyze(H.occupancy(31, 5))
        self.assertEqual((r["bins"], r["shell_size"]), (120, 768))

    def test_refusals(self):
        for args in ((10, 5), (7, 2), (7, 9), (7, 5, "right"), (0, 5)):
            with self.subTest(args=args), self.assertRaises(ValueError):
                H.occupancy(*args)


if __name__ == "__main__":
    unittest.main()
