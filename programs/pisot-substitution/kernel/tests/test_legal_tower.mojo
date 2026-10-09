"""Canonical Mojo regressions for legal ancestry towers."""

from std.testing import assert_equal, assert_true, assert_false
from mojo_smoke.claims import require_claim
from psc.legal_tower import (
    descent_margin,
    first_legal_tower_cut,
    image_lengths_at_depth,
    substitution_max_image_length,
    tower_count_forces_existence,
    tower_source_cuts,
    verify_legal_tower,
)
from psc.words import Pair


def tribonacci() -> List[List[Int]]:
    return [[0, 1], [0, 2], [0]]


def nonpisot_strict() -> List[List[Int]]:
    return [[1], [0, 1, 2], [1]]


def swap_seed() -> Pair:
    var u: List[Int] = [0, 1]
    var v: List[Int] = [1, 0]
    return Pair(u, v)


def test_margin_recurrence() raises:
    assert_equal(descent_margin(1, 0, 2), 1)
    assert_equal(descent_margin(1, 1, 2), 4)
    assert_equal(descent_margin(1, 2, 2), 10)
    assert_equal(descent_margin(1, 3, 2), 22)


def test_image_length_dp_is_exact() raises:
    var lengths = image_lengths_at_depth(tribonacci(), 5)
    # Tribonacci image lengths at depth 5.
    assert_equal(lengths[0], 24)
    assert_equal(lengths[1], 20)
    assert_equal(lengths[2], 13)


def test_tribonacci_two_descent_tower() raises:
    var sigma = tribonacci()
    var p = swap_seed()
    var cut = first_legal_tower_cut(sigma, p, 5, 1, 2)
    assert_equal(cut, 10)
    assert_true(verify_legal_tower(sigma, p, 5, cut, 1, 2))
    var source = tower_source_cuts(sigma, p, 5, cut, 2)
    assert_equal(len(source), 2)
    assert_equal(source[0][0], 5)
    assert_equal(source[0][1], 5)
    assert_equal(source[1][0], 2)
    assert_equal(source[1][1], 2)


def test_unprotected_cut_is_rejected() raises:
    assert_false(verify_legal_tower(tribonacci(), swap_seed(), 5, 1, 1, 2))


def test_nonpisot_strict_calibration() raises:
    var sigma = nonpisot_strict()
    var p = swap_seed()
    assert_equal(substitution_max_image_length(sigma), 3)
    var cut = first_legal_tower_cut(sigma, p, 6, 1, 2)
    assert_equal(cut, 22)
    assert_true(verify_legal_tower(sigma, p, 6, cut, 1, 2))
    assert_true(
        tower_count_forces_existence(
            p,
            1024,
            2,
            1,
            2,
            3,
        )
    )


def main() raises:
    test_margin_recurrence()
    print("[PASS] test_margin_recurrence")
    test_image_length_dp_is_exact()
    print("[PASS] test_image_length_dp_is_exact")
    test_tribonacci_two_descent_tower()
    print("[PASS] test_tribonacci_two_descent_tower")
    test_unprotected_cut_is_rejected()
    print("[PASS] test_unprotected_cut_is_rejected")
    test_nonpisot_strict_calibration()
    print("[PASS] test_nonpisot_strict_calibration")
    print("5 legal-tower Mojo tests passed.")
    require_claim("C3Locality")
