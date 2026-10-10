"""Canonical falsification/regression tests for joint G1b-2 local types."""

from std.testing import assert_equal, assert_false, assert_true
from mojo_smoke.claims import require_claim
from psc.joint_local_type import joint_local_type, same_joint_local_type
from psc.renewal_address import (
    build_renewal_address_tables,
    build_renewal_pair_census_state,
    renewal_cut_address_from_state,
    same_relative_address,
)
from psc.words import Pair


def nonunimodular_pisot_sigma() -> List[List[Int]]:
    # det(M)=2; characteristic polynomial x^3-x^2-2x-2.
    var a0: List[Int] = [1]
    var a1: List[Int] = [0, 2, 1]
    var a2: List[Int] = [0, 0, 1]
    var sigma = List[List[Int]]()
    sigma.append(a0^)
    sigma.append(a1^)
    sigma.append(a2^)
    return sigma^


def collision_pair_a() -> Pair:
    var u: List[Int] = [0, 0, 1]
    var v: List[Int] = [1, 0, 0]
    return Pair(u, v)


def collision_pair_b() -> Pair:
    var u: List[Int] = [0, 2, 1]
    var v: List[Int] = [1, 2, 0]
    return Pair(u, v)


def seed_pair() -> Pair:
    var u: List[Int] = [0, 1]
    var v: List[Int] = [1, 0]
    return Pair(u, v)


def test_full_level_one_address_still_needs_source_context() raises:
    var tables = build_renewal_address_tables(nonunimodular_pisot_sigma(), 1)
    var a_state = build_renewal_pair_census_state(tables, collision_pair_a())
    var b_state = build_renewal_pair_census_state(tables, collision_pair_b())

    var a_address = renewal_cut_address_from_state(a_state, 4)
    var b_address = renewal_cut_address_from_state(b_state, 6)
    assert_true(same_relative_address(a_address, b_address))

    # At depth one, digit_window=1 retains the entire symbolic address.  With
    # radius zero the selected source letters are also the same, so the joint
    # projection still collides.  Address data alone is therefore insufficient.
    var a0 = joint_local_type(a_state, 4, 0, 1)
    var b0 = joint_local_type(b_state, 6, 0, 1)
    assert_true(same_joint_local_type(a0, b0))
    assert_equal(a0.source_context, [1, 0])
    assert_equal(a0.top_head, [1, 2])
    assert_equal(a0.bottom_head, [0, 0])

    # Radius one sees the preceding 0/0 versus 2/2 source letters and separates
    # this known collision.  This is an example-level repair, not a theorem that
    # radius one is universally sufficient.
    var a1 = joint_local_type(a_state, 4, 1, 1)
    var b1 = joint_local_type(b_state, 6, 1, 1)
    assert_false(same_joint_local_type(a1, b1))
    assert_equal(a1.source_context, [0, 1, 3, 0, 0, 3])
    assert_equal(b1.source_context, [2, 1, 3, 2, 0, 3])


def test_one_level_head_tail_window_misses_middle_digit_change() raises:
    var tables = build_renewal_address_tables(nonunimodular_pisot_sigma(), 4)
    var state = build_renewal_pair_census_state(tables, seed_pair())

    # Both are certified depth-four zero returns of sigma^4(01,10).
    var a_address = renewal_cut_address_from_state(state, 35)
    var b_address = renewal_cut_address_from_state(state, 40)
    assert_false(same_relative_address(a_address, b_address))

    # The source pair has length two, so radius two already exposes the whole
    # source word (plus sentinels).  Nevertheless one digit level at each end
    # misses the differing middle ancestry and the bounded projection collides.
    var a1 = joint_local_type(state, 35, 2, 1)
    var b1 = joint_local_type(state, 40, 2, 1)
    assert_true(same_joint_local_type(a1, b1))
    assert_equal(a1.source_context, [3, 0, 1, 3, 3, 3, 1, 0, 3, 3])
    assert_equal(a1.top_head, [1, 2])
    assert_equal(a1.top_tail, [1, 0])
    assert_equal(a1.bottom_head, [0, 0])
    assert_equal(a1.bottom_tail, [1, 0])

    # A two-level head/tail window separates this particular collision.  The
    # regression deliberately records only that local fact; no universal window
    # bound is inferred from it.
    var a2 = joint_local_type(state, 35, 2, 2)
    var b2 = joint_local_type(state, 40, 2, 2)
    assert_false(same_joint_local_type(a2, b2))
    assert_equal(a2.top_head, [1, 2, 1, 0])
    assert_equal(b2.top_head, [1, 2, 1, 1])


def test_invalid_projection_parameters_fail_closed() raises:
    var tables = build_renewal_address_tables(nonunimodular_pisot_sigma(), 1)
    var state = build_renewal_pair_census_state(tables, collision_pair_a())

    var caught_radius = False
    try:
        _ = joint_local_type(state, 4, -1, 1)
    except:
        caught_radius = True
    assert_true(caught_radius)

    var caught_window = False
    try:
        _ = joint_local_type(state, 4, 0, -1)
    except:
        caught_window = True
    assert_true(caught_window)


def main() raises:
    test_full_level_one_address_still_needs_source_context()
    print("[PASS] test_full_level_one_address_still_needs_source_context")
    test_one_level_head_tail_window_misses_middle_digit_change()
    print("[PASS] test_one_level_head_tail_window_misses_middle_digit_change")
    test_invalid_projection_parameters_fail_closed()
    print("[PASS] test_invalid_projection_parameters_fail_closed")
    print("3 joint-local-type Mojo tests passed.")
    require_claim("G1b2RenewalFiniteness")
