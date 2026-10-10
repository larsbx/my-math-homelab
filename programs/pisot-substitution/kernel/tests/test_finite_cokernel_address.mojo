"""Exact finite regressions for the G1b-2 sidewise cokernel diagnostic."""

from std.testing import assert_equal, assert_false, assert_true
from mojo_smoke.claims import require_claim
from psc.finite_cokernel_address import (
    audit_sidewise_cokernel,
    build_cokernel_lattice,
    same_cokernel_class,
    sidewise_prefix_translation,
)
from psc.joint_local_type import same_joint_local_type
from psc.loop_quotient_census import (
    AddressedJointLocalSample,
    addressed_samples_through_depth,
)
from psc.renewal import Diff3
from psc.renewal_address import build_renewal_address_tables
from psc.words import Pair


def nonunimodular_pisot_sigma() -> List[List[Int]]:
    var a0: List[Int] = [1]
    var a1: List[Int] = [0, 2, 1]
    var a2: List[Int] = [0, 0, 1]
    var sigma = List[List[Int]]()
    sigma.append(a0^)
    sigma.append(a1^)
    sigma.append(a2^)
    return sigma^


def seed_pair() -> Pair:
    var u: List[Int] = [0, 1]
    var v: List[Int] = [1, 0]
    return Pair(u, v)


def test_cokernel_orders_match_det_power() raises:
    var tables = build_renewal_address_tables(nonunimodular_pisot_sigma(), 10)
    var expected: List[Int] = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
    for level in range(1, 11):
        var lattice = build_cokernel_lattice(tables, level)
        assert_equal(lattice.order(), expected[level - 1])


def test_cokernel_membership_is_exact() raises:
    var tables = build_renewal_address_tables(nonunimodular_pisot_sigma(), 3)
    var zero = Diff3(0, 0, 0)
    var e0 = Diff3(1, 0, 0)
    for level in range(1, 4):
        var lattice = build_cokernel_lattice(tables, level)
        assert_true(same_cokernel_class(lattice, lattice.c0, zero))
        assert_true(same_cokernel_class(lattice, lattice.c1, zero))
        assert_true(same_cokernel_class(lattice, lattice.c2, zero))
    var level_one = build_cokernel_lattice(tables, 1)
    assert_false(same_cokernel_class(level_one, e0, zero))


def test_sidewise_prefix_reconstruction_matches_correction() raises:
    var sigma = nonunimodular_pisot_sigma()
    var samples = addressed_samples_through_depth(sigma, seed_pair(), 0, 3, 2, 1)
    var tables = build_renewal_address_tables(sigma, 3)
    assert_true(len(samples) > 0)
    for i in range(len(samples)):
        var translations = sidewise_prefix_translation(tables, samples[i].address)
        var correction = samples[i].address.correction.copy()
        assert_equal(translations.top.x - translations.bottom.x, correction.x)
        assert_equal(translations.top.y - translations.bottom.y, correction.y)
        assert_equal(translations.top.z - translations.bottom.z, correction.z)


def test_fixed_window_sidewise_cokernel_staircase() raises:
    var sigma = nonunimodular_pisot_sigma()
    var samples = addressed_samples_through_depth(sigma, seed_pair(), 0, 7, 2, 1)
    var expected_orders: List[Int] = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
    var expected_survivors: List[Int] = [11520, 10828, 6897, 3538, 1540, 500, 83, 56, 26, 1]
    var expected_separated: List[Int] = [0, 692, 4623, 7982, 9980, 11020, 11437, 11464, 11494, 11519]
    var expected_same_depth: List[Int] = [4645, 4353, 2773, 1453, 674, 262, 82, 55, 25, 0]
    var previous_survivors = 11520
    var previous_same_depth = 4645
    for level in range(1, 11):
        var audit = audit_sidewise_cokernel(samples, sigma, level)
        assert_equal(audit.sample_count, 601)
        assert_equal(audit.projection_collision_pair_count, 12466)
        assert_equal(audit.symbolic_quotiented_pair_count, 946)
        assert_equal(audit.residual_pair_count, 11520)
        assert_equal(audit.same_depth_residual_pair_count, 4645)
        assert_equal(audit.cokernel_order, expected_orders[level - 1])
        assert_equal(audit.cokernel_surviving_pair_count, expected_survivors[level - 1])
        assert_equal(audit.cokernel_separated_pair_count, expected_separated[level - 1])
        assert_equal(audit.same_depth_cokernel_surviving_pair_count, expected_same_depth[level - 1])
        assert_equal(audit.exact_sidewise_surviving_pair_count, 1)
        assert_equal(
            audit.cokernel_surviving_pair_count + audit.cokernel_separated_pair_count,
            audit.residual_pair_count,
        )
        assert_true(audit.cokernel_surviving_pair_count <= previous_survivors)
        assert_true(audit.same_depth_cokernel_surviving_pair_count <= previous_same_depth)
        previous_survivors = audit.cokernel_surviving_pair_count
        previous_same_depth = audit.same_depth_cokernel_surviving_pair_count


def test_exact_sidewise_countercalibration_is_present() raises:
    var sigma = nonunimodular_pisot_sigma()
    var samples = addressed_samples_through_depth(sigma, seed_pair(), 0, 7, 2, 1)
    var tables = build_renewal_address_tables(sigma, 7)
    var left = -1
    var right = -1
    for i in range(len(samples)):
        if samples[i].depth == 7 and samples[i].cut == 14:
            left = i
        elif samples[i].depth == 5 and samples[i].cut == 14:
            right = i
    assert_true(left >= 0)
    assert_true(right >= 0)
    assert_true(same_joint_local_type(samples[left].projection, samples[right].projection))
    var left_translation = sidewise_prefix_translation(tables, samples[left].address)
    var right_translation = sidewise_prefix_translation(tables, samples[right].address)
    assert_true(left_translation.top == right_translation.top)
    assert_true(left_translation.bottom == right_translation.bottom)
    assert_equal(left_translation.top.x, 5)
    assert_equal(left_translation.top.y, 6)
    assert_equal(left_translation.top.z, 3)
    assert_equal(left_translation.bottom.x, 5)
    assert_equal(left_translation.bottom.y, 6)
    assert_equal(left_translation.bottom.z, 3)

    var level_ten = audit_sidewise_cokernel(samples, sigma, 10)
    assert_equal(level_ten.cokernel_surviving_pair_count, 1)
    var a = level_ten.first_cokernel_survivor_left
    var b = level_ten.first_cokernel_survivor_right
    assert_true(a >= 0)
    assert_true(b >= 0)
    var forward = (
        samples[a].depth == 7
        and samples[a].cut == 14
        and samples[b].depth == 5
        and samples[b].cut == 14
    )
    var reverse = (
        samples[b].depth == 7
        and samples[b].cut == 14
        and samples[a].depth == 5
        and samples[a].cut == 14
    )
    assert_true(forward or reverse)


def test_cokernel_audit_rejects_invalid_level_and_mixed_specimens() raises:
    var sigma = nonunimodular_pisot_sigma()
    var samples = addressed_samples_through_depth(sigma, seed_pair(), 0, 2, 2, 1)
    var caught_level = False
    try:
        _ = audit_sidewise_cokernel(samples, sigma, 0)
    except:
        caught_level = True
    assert_true(caught_level)
    var other = addressed_samples_through_depth(sigma, seed_pair(), 1, 2, 2, 1)
    samples.append(other[0].copy())
    var caught_specimen = False
    try:
        _ = audit_sidewise_cokernel(samples, sigma, 1)
    except:
        caught_specimen = True
    assert_true(caught_specimen)


def main() raises:
    test_cokernel_orders_match_det_power()
    print("[PASS] test_cokernel_orders_match_det_power")
    test_cokernel_membership_is_exact()
    print("[PASS] test_cokernel_membership_is_exact")
    test_sidewise_prefix_reconstruction_matches_correction()
    print("[PASS] test_sidewise_prefix_reconstruction_matches_correction")
    test_fixed_window_sidewise_cokernel_staircase()
    print("[PASS] test_fixed_window_sidewise_cokernel_staircase")
    test_exact_sidewise_countercalibration_is_present()
    print("[PASS] test_exact_sidewise_countercalibration_is_present")
    test_cokernel_audit_rejects_invalid_level_and_mixed_specimens()
    print("[PASS] test_cokernel_audit_rejects_invalid_level_and_mixed_specimens")
    print("6 finite-cokernel-address Mojo tests passed.")
    require_claim("G1b2RenewalFiniteness")
