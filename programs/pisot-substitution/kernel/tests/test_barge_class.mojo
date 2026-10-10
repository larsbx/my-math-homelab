"""Regressions for Barge-class conjugacy witnesses (`psc.barge_class`)."""

from std.testing import assert_equal, assert_false, assert_true
from psc.barge_class import (
    KIND_DIRECT,
    KIND_LEFT_ROTATION,
    barge_witness,
    common_prefix_length,
    in_barge_class,
    in_mirror_class,
    rotate_left,
    rotate_right,
)
from mojo_smoke.claims import require_contract
from psc.dumont_thomas import power_substitution


def test_tribonacci_is_in_the_mirror_class() raises:
    """`0 -> 01, 1 -> 02, 2 -> 0`: constant on initial letters, injective on
    final letters (a classical pure-discrete-spectrum case)."""
    var w = barge_witness([[0, 1], [0, 2], [0]], 6)
    assert_equal(w.power, 1)
    assert_equal(w.kind, KIND_DIRECT)
    assert_true(w.mirror)


def test_catch_up_free_specimen_has_a_square_in_barges_class() raises:
    """`0 -> 1, 1 -> 22, 2 -> 012` (catch-up-free, the first total Q1 failure):
    `sigma^2 = (22, 012012, 122012)` is injective on initial letters and
    constant on final letters."""
    var sigma: List[List[Int]] = [[1], [2, 2], [0, 1, 2]]
    var square = power_substitution(sigma, 2)
    assert_true(in_barge_class(square))
    var w = barge_witness(sigma, 6)
    assert_equal(w.power, 2)
    assert_equal(w.kind, KIND_DIRECT)
    assert_false(w.mirror)


def test_left_rotation_by_the_common_prefix() raises:
    """`0 -> 00, 1 -> 010, 2 -> 020` is constant on both ends; rotating by the
    common prefix `0` gives `(00, 100, 200)`, which is in Barge's class."""
    var t: List[List[Int]] = [[0, 0], [0, 1, 0], [0, 2, 0]]
    assert_false(in_barge_class(t) or in_mirror_class(t))
    assert_equal(common_prefix_length(t), 1)
    var r = rotate_left(t, 1)
    assert_true(in_barge_class(r))
    assert_equal(r[1][0], 1)
    var back = rotate_right(r, 1)
    for a in range(3):
        assert_equal(len(back[a]), len(t[a]))
        for i in range(len(t[a])):
            assert_equal(back[a][i], t[a][i])
    var w = barge_witness(t, 1)
    assert_equal(w.kind, KIND_LEFT_ROTATION)


def test_plastic_has_no_witness() raises:
    var w = barge_witness([[1], [2], [0, 1]], 6)
    assert_false(w.found())


def main() raises:
    test_tribonacci_is_in_the_mirror_class()
    test_catch_up_free_specimen_has_a_square_in_barges_class()
    test_left_rotation_by_the_common_prefix()
    test_plastic_has_no_witness()
    print("[PASS] Barge-class witnesses: mirror control, catch-up-free square, rotation, no-witness control")
    require_contract("Barge-class membership of a power or maximal common-prefix/suffix rotation is decided exactly; Tribonacci is in the mirror class, 0 -> 1, 1 -> 22, 2 -> 012 has its square in Barge's class, the plastic substitution has no witness up to power 6")
