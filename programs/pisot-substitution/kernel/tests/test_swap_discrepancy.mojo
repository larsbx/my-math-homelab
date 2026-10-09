"""Regressions for the exact swap-discrepancy kernel.

They pin the reduction step of the bounded-discrepancy theorem (every
zero-return block of an inflated swap seed inherits the swap-walk bound) and
the exact census values for the named examples.
"""

from std.testing import assert_equal, assert_true

from psc.bpa import build, decompose
from mojo_smoke.claims import require_claim
from psc.swap_discrepancy import (
    common_tile_count,
    discrepancy,
    iterate,
    max_reachable_discrepancy,
    swap_walk_profile,
    swap_walk_sup,
)
from psc.words import Pair


def reference_discrepancy(p: Pair) -> Int:
    """Original full-scan definition, retained only as a test oracle."""
    var diff: List[Int] = [0, 0, 0]
    var best = 0
    for i in range(len(p.u)):
        diff[p.u[i]] += 1
        diff[p.v[i]] -= 1
        for j in range(3):
            var magnitude = diff[j] if diff[j] >= 0 else -diff[j]
            if magnitude > best:
                best = magnitude
    return best


def tribonacci() -> List[List[Int]]:
    var s = List[List[Int]]()
    var w0: List[Int] = [0, 1]
    var w1: List[Int] = [0, 2]
    var w2: List[Int] = [0]
    s.append(w0^)
    s.append(w1^)
    s.append(w2^)
    return s^


def tau() -> List[List[Int]]:
    var s = List[List[Int]]()
    var w0: List[Int] = [1]
    var w1: List[Int] = [0, 2, 1]
    var w2: List[Int] = [0, 0, 1]
    s.append(w0^)
    s.append(w1^)
    s.append(w2^)
    return s^


def test_swap_seed_has_discrepancy_one() raises:
    var u: List[Int] = [0, 1]
    var v: List[Int] = [1, 0]
    assert_equal(discrepancy(Pair(u, v)), 1)
    assert_equal(swap_walk_sup(tribonacci(), 0, 1, 0), 1)


def test_unrolled_sign_branches_match_original_metric() raises:
    # These paths collectively update x and y through both signs, while each
    # orientation makes the strict positive/negative maximum occur on the
    # opposite updated coordinate.  Compare with the original definition.
    var cases = List[Pair]()
    cases.append(Pair([0, 0, 2, 2], [1, 2, 1, 0]))
    cases.append(Pair([1, 2, 1, 0], [0, 0, 2, 2]))
    cases.append(Pair([1, 1, 0, 2], [0, 0, 2, 1]))
    cases.append(Pair([0, 0, 2, 1], [1, 1, 0, 2]))
    for i in range(len(cases)):
        assert_equal(discrepancy(cases[i]), reference_discrepancy(cases[i]))


def test_blocks_inherit_the_swap_walk_bound() raises:
    var sigmas = List[List[List[Int]]]()
    sigmas.append(tribonacci())
    sigmas.append(tau())
    for s in range(len(sigmas)):
        for a in range(3):
            for b in range(a + 1, 3):
                for n in range(9):
                    var ab: List[Int] = [a, b]
                    var ba: List[Int] = [b, a]
                    var u = iterate(sigmas[s], ab, n)
                    var v = iterate(sigmas[s], ba, n)
                    var sup = swap_walk_sup(sigmas[s], a, b, n)
                    var blocks = decompose(u, v)
                    for i in range(len(blocks)):
                        assert_true(discrepancy(blocks[i]) <= sup)


def test_tribonacci_profile_is_flat() raises:
    var profile = swap_walk_profile(tribonacci(), 15)
    for n in range(len(profile)):
        assert_equal(profile[n], 1)


def test_tau_profile_and_reachable_maximum() raises:
    var expected: List[Int] = [1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5]
    assert_equal(swap_walk_profile(tau(), 18), expected)
    var a = build(tau(), 20000)
    assert_true(not a.capped)
    assert_equal(max_reachable_discrepancy(a), 5)
    assert_equal(max_reachable_discrepancy(build(tribonacci(), 20000)), 1)


def test_common_tile_counts_pin_exact_values() raises:
    var trib_common: List[Int] = [0, 1, 3, 7, 16, 33]
    var trib_total: List[Int] = [2, 4, 7, 13, 24, 44]
    var tau_common: List[Int] = [0, 1, 4, 11, 26, 62]
    var tau_total: List[Int] = [2, 4, 10, 22, 50, 114]
    for n in range(6):
        var t = common_tile_count(tribonacci(), 0, 1, n)
        assert_equal(t[0], trib_common[n])
        assert_equal(t[1], trib_total[n])
        var u = common_tile_count(tau(), 0, 1, n)
        assert_equal(u[0], tau_common[n])
        assert_equal(u[1], tau_total[n])


def main() raises:
    test_swap_seed_has_discrepancy_one()
    print("[PASS] test_swap_seed_has_discrepancy_one")
    test_unrolled_sign_branches_match_original_metric()
    print("[PASS] test_unrolled_sign_branches_match_original_metric")
    test_blocks_inherit_the_swap_walk_bound()
    print("[PASS] test_blocks_inherit_the_swap_walk_bound")
    test_tribonacci_profile_is_flat()
    print("[PASS] test_tribonacci_profile_is_flat")
    test_tau_profile_and_reachable_maximum()
    print("[PASS] test_tau_profile_and_reachable_maximum")
    test_common_tile_counts_pin_exact_values()
    print("[PASS] test_common_tile_counts_pin_exact_values")
    print("6 swap-discrepancy tests passed.")
    require_claim("G1b1BoundedDiscrepancy")
