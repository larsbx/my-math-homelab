"""Canonical Mojo regressions for the Barge-Diamond endpoint eliminator."""

from std.testing import assert_equal, assert_false, assert_true
from psc.bd_endpoint import (
    avoids_good_pair_and_contains_hub,
    complementary_hub_letter,
    pair_orbit_coalesces,
    pair_orbit_mask,
    strict_pip_endpoint_type_admissible,
    type_g_pair_action_is_transitive,
)
from mojo_smoke.claims import require_claim
from psc.endpoint_core import endpoint_type


def test_type_g_cycles_all_three_unordered_pairs() raises:
    var g1: List[Int] = [1, 2, 0]
    var g2: List[Int] = [2, 0, 1]
    assert_equal(endpoint_type(g1), 6)
    assert_equal(endpoint_type(g2), 6)
    assert_true(type_g_pair_action_is_transitive(g1))
    assert_true(type_g_pair_action_is_transitive(g2))
    for a in range(3):
        for b in range(a + 1, 3):
            assert_equal(pair_orbit_mask(g1, a, b), 7)
            assert_equal(pair_orbit_mask(g2, a, b), 7)
            assert_false(pair_orbit_coalesces(g1, a, b))
            assert_false(pair_orbit_coalesces(g2, a, b))


def test_a_b_g_are_eliminated_c_through_f_survive_this_filter() raises:
    var reps = List[List[Int]]()
    reps.append([0, 0, 0])  # A
    reps.append([0, 0, 1])  # B
    reps.append([0, 0, 2])  # C
    reps.append([0, 1, 2])  # D
    reps.append([0, 2, 1])  # E
    reps.append([1, 0, 0])  # F
    reps.append([1, 2, 0])  # G
    for t in range(7):
        assert_equal(endpoint_type(reps[t]), t)
        assert_equal(strict_pip_endpoint_type_admissible(reps[t]), t >= 2 and t <= 5)


def test_all_27_maps_match_type_level_filter() raises:
    var total = 0
    var admitted = 0
    var type_g = 0
    for a in range(3):
        for b in range(3):
            for c in range(3):
                var h: List[Int] = [a, b, c]
                var t = endpoint_type(h)
                var ok = strict_pip_endpoint_type_admissible(h)
                assert_equal(ok, t >= 2 and t <= 5)
                if t == 6:
                    type_g += 1
                    assert_true(type_g_pair_action_is_transitive(h))
                if ok:
                    admitted += 1
                total += 1
    assert_equal(total, 27)
    assert_equal(type_g, 2)
    # Class sizes C,D,E,F = 6+1+3+6.
    assert_equal(admitted, 16)


def test_surviving_types_have_a_proper_noncoalescing_pair_orbit() raises:
    var reps = List[List[Int]]()
    reps.append([0, 0, 2])  # C
    reps.append([0, 1, 2])  # D
    reps.append([0, 2, 1])  # E
    reps.append([1, 0, 0])  # F
    for r in range(len(reps)):
        var found = False
        for a in range(3):
            for b in range(a + 1, 3):
                if not pair_orbit_coalesces(reps[r], a, b):
                    var mask = pair_orbit_mask(reps[r], a, b)
                    if mask != 0 and mask != 7:
                        found = True
        assert_true(found)


def test_one_good_pair_forces_a_common_hub_on_every_other_edge() raises:
    for good_a in range(3):
        for good_b in range(good_a + 1, 3):
            var hub = complementary_hub_letter(good_a, good_b)
            assert_true(hub != good_a and hub != good_b)
            var allowed = 0
            for x in range(3):
                for y in range(x + 1, 3):
                    if avoids_good_pair_and_contains_hub(good_a, good_b, x, y):
                        assert_true(x == hub or y == hub)
                        allowed += 1
            assert_equal(allowed, 2)
            assert_false(avoids_good_pair_and_contains_hub(good_a, good_b, good_a, good_b))


def main() raises:
    test_type_g_cycles_all_three_unordered_pairs()
    print("[PASS] test_type_g_cycles_all_three_unordered_pairs")
    test_a_b_g_are_eliminated_c_through_f_survive_this_filter()
    print("[PASS] test_a_b_g_are_eliminated_c_through_f_survive_this_filter")
    test_all_27_maps_match_type_level_filter()
    print("[PASS] test_all_27_maps_match_type_level_filter")
    test_surviving_types_have_a_proper_noncoalescing_pair_orbit()
    print("[PASS] test_surviving_types_have_a_proper_noncoalescing_pair_orbit")
    test_one_good_pair_forces_a_common_hub_on_every_other_edge()
    print("[PASS] test_one_good_pair_forces_a_common_hub_on_every_other_edge")
    print("5 Barge-Diamond endpoint tests passed.")
    require_claim("GlobalEndpointSync")
