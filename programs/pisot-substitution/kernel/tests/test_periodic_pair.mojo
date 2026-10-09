"""Exact regressions for the interior-occurrence pair certificates (Theorem B of
docs/p1b-strict-zipper-periodic-pair-2026-10-02.md)."""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_contract
from psc.overlap_seed_patch import OverlapState, build_seed_overlap_tables
from psc.periodic_pair import (
    PAIR_CAPPED,
    PAIR_SHARED_VERTEX,
    PairCensus,
    certify_pair,
    centre_offset,
    integer_hit_depth,
    interior_occurrences,
    periodic_pair_census,
    replay_cycle,
)
from psc.perron_field3 import CubicElt


def sigma_of(a: List[Int], b: List[Int], c: List[Int]) -> List[List[Int]]:
    var sigma = List[List[Int]]()
    sigma.append(a.copy())
    sigma.append(b.copy())
    sigma.append(c.copy())
    return sigma^


def tribonacci() -> List[List[Int]]:
    return sigma_of([0, 1], [0, 2], [0])


def cube_image() -> List[List[Int]]:
    return sigma_of([1], [2, 2, 2], [0, 2, 2, 2])


def golden_pump() -> List[List[Int]]:
    """`0 -> 1, 1 -> 021, 2 -> 001`, determinant two."""
    return sigma_of([1], [0, 2, 1], [0, 0, 1])


def assert_census(c: PairCensus, pairs: Int, integral: Int, shared: Int, deepest: Int) raises:
    assert_equal(c.pairs, pairs)
    assert_equal(c.integral, integral)
    assert_equal(c.shared, shared)
    assert_equal(c.strict_zipper, 0)
    assert_equal(c.capped, 0)
    assert_equal(c.deepest, deepest)


def test_census_pins_agree_with_the_independent_oracle() raises:
    """Every integral centre-difference pair of three productive specimens shares
    a vertex; counts and depths match an independent integer-only oracle."""
    assert_census(periodic_pair_census(tribonacci(), 6), 908, 18, 18, 3)
    assert_census(periodic_pair_census(cube_image(), 3), 232, 8, 8, 1)
    assert_census(periodic_pair_census(golden_pump(), 4), 366, 20, 20, 7)


def test_centre_offset_is_exact_and_integrality_is_decided() raises:
    var sigma = tribonacci()
    var total = 0
    var integral = 0
    for r in range(1, 7):
        var occ0 = interior_occurrences(sigma, 0, r)
        var occ1 = interior_occurrences(sigma, 1, r)
        for p in range(len(occ0)):
            for q in range(len(occ1)):
                total += 1
                if len(centre_offset(sigma, r, occ0[p].prefix, occ1[q].prefix)) == 3:
                    integral += 1
    assert_true(integral > 0)
    assert_true(integral < total)


def test_the_cycle_replay_refuses_a_wrong_start() raises:
    var sigma = golden_pump()
    var tables = build_seed_overlap_tables(sigma)
    var occ = interior_occurrences(sigma, 1, 2)
    var other = interior_occurrences(sigma, 2, 2)
    var refused = False
    try:
        replay_cycle(tables, 2, occ[0], other[0], OverlapState(1, 2, CubicElt()))
    except:
        refused = True
    assert_true(refused)


def test_a_capped_closure_is_never_a_verdict() raises:
    var sigma = golden_pump()
    var tables = build_seed_overlap_tables(sigma)
    var found = False
    for r in range(1, 5):
        var a = interior_occurrences(sigma, 1, r)
        var b = interior_occurrences(sigma, 2, r)
        for p in range(len(a)):
            for q in range(len(b)):
                if found:
                    continue
                var full = certify_pair(tables, r, a[p], b[q])
                if full.kind != PAIR_SHARED_VERTEX or full.closure_size < 2:
                    continue
                assert_equal(certify_pair(tables, r, a[p], b[q], 1).kind, PAIR_CAPPED)
                assert_equal(integer_hit_depth(sigma, 1, 2, full.offset, full.depth), full.depth)
                found = True
    assert_true(found)


def main() raises:
    test_census_pins_agree_with_the_independent_oracle()
    print("[PASS] test_census_pins_agree_with_the_independent_oracle")
    test_centre_offset_is_exact_and_integrality_is_decided()
    print("[PASS] test_centre_offset_is_exact_and_integrality_is_decided")
    test_the_cycle_replay_refuses_a_wrong_start()
    print("[PASS] test_the_cycle_replay_refuses_a_wrong_start")
    test_a_capped_closure_is_never_a_verdict()
    print("[PASS] test_a_capped_closure_is_never_a_verdict")
    require_contract("interior-occurrence pair census: tribonacci r<=6 908/18/18 depth 3, cube r<=3 232/8/8 depth 1, golden pump r<=4 366/20/20 depth 7, no strict zipper")
    require_contract("centre offset (M^r - I)^{-1}(pi(P) - pi(Q)) is computed over Z and replayed exactly")
    require_contract("periodic-pair cycle replay fails closed when the chain does not close on its start")
    require_contract("a capped periodic-pair descendant closure is reported as capped, not as a strict zipper")
