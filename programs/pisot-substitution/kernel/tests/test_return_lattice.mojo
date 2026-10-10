"""Exact regressions for the return lattices of radius-`n` patches."""

from std.testing import assert_equal, assert_raises, assert_true
from mojo_smoke.claims import require_contract
from psc.return_lattice import (
    TriangularLattice,
    covering_level,
    factor_set,
    return_index_profile,
    sampled_return_index,
    verify_index_profile,
)


def tribonacci() -> List[List[Int]]:
    # Unimodular: 0 -> 01, 1 -> 02, 2 -> 0.
    return [[0, 1], [0, 2], [0]]


def det_two() -> List[List[Int]]:
    # |det M| = 2 corpus calibration: 0 -> 22, 1 -> 20, 2 -> 221.
    return [[2, 2], [2, 0], [2, 2, 1]]


def test_hermite_form_index() raises:
    var lattice = TriangularLattice(3)
    var a: List[Int] = [4, 0, 0]
    var b: List[Int] = [6, 3, 0]
    var c: List[Int] = [0, 5, 1]
    lattice.insert(a)
    lattice.insert(b)
    assert_equal(lattice.rank(), 2)
    with assert_raises():
        _ = lattice.index()
    lattice.insert(c)
    # det [[4,0,0],[6,3,0],[0,5,1]] = 12, and gcd(4, 6) = 2 brings in (2,3,0).
    assert_equal(lattice.index(), 12)
    var d: List[Int] = [2, 0, 0]
    lattice.insert(d)
    assert_equal(lattice.index(), 6)


def test_tribonacci_factor_complexity() raises:
    # Tribonacci is Arnoux-Rauzy: exactly 2n + 1 factors of length n.
    for n in range(1, 11):
        assert_equal(len(factor_set(tribonacci(), n)), 2 * n + 1)


def test_unimodular_returns_span_every_order() raises:
    var profile = return_index_profile(tribonacci(), 12)
    for n in range(12):
        assert_equal(profile[n], 1)


def test_det_two_returns_shrink() raises:
    # The overstrong variant "return vectors of every patch span Z<ell>" is
    # refuted here: tiles span, radius-4 patches do not.
    var expected: List[Int] = [1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4]
    assert_equal(return_index_profile(det_two(), 13), expected)


def test_exact_agrees_with_sampled_route() raises:
    for n in range(1, 9):
        var trib = return_index_profile(tribonacci(), n)[n - 1]
        var two = return_index_profile(det_two(), n)[n - 1]
        assert_equal(sampled_return_index(tribonacci(), n, 20000), trib)
        assert_equal(sampled_return_index(det_two(), n, 20000), two)


def test_covering_bound() raises:
    # |sigma^K(a)|: (1,1,1), (2,2,1), (4,3,2), ... so radius 2 needs K = 2.
    assert_equal(covering_level(tribonacci(), 1), 0)
    assert_equal(covering_level(tribonacci(), 2), 2)
    var profile = return_index_profile(det_two(), 16)
    for n in range(1, 17):
        var bound = 1
        for _ in range(covering_level(det_two(), n)):
            bound *= 2
        assert_true(bound % profile[n - 1] == 0)
        if n > 1:
            assert_true(profile[n - 1] % profile[n - 2] == 0)


def test_verify_accepts_valid_profiles() raises:
    var good = return_index_profile(det_two(), 13)
    verify_index_profile(det_two(), 2, good)
    var unimodular = return_index_profile(tribonacci(), 12)
    verify_index_profile(tribonacci(), 1, unimodular)


def test_verify_refuses_broken_chain() raises:
    # Every index divides its covering bound (1, 2, 4), but 2 does not
    # divide the next index 1. The covering check cannot mask this failure.
    var unchained: List[Int] = [1, 2, 1]
    with assert_raises():
        verify_index_profile(det_two(), 2, unchained)


def test_verify_refuses_broken_covering_bound() raises:
    # The chain holds (1 divides 2), but index 2 at order 2 does not
    # divide the unimodular covering bound 1. The chain cannot mask this.
    var unbounded: List[Int] = [1, 2]
    with assert_raises():
        verify_index_profile(tribonacci(), 1, unbounded)


def main() raises:
    test_hermite_form_index()
    print("[PASS] test_hermite_form_index")
    test_tribonacci_factor_complexity()
    print("[PASS] test_tribonacci_factor_complexity")
    test_unimodular_returns_span_every_order()
    print("[PASS] test_unimodular_returns_span_every_order")
    test_det_two_returns_shrink()
    print("[PASS] test_det_two_returns_shrink")
    test_exact_agrees_with_sampled_route()
    print("[PASS] test_exact_agrees_with_sampled_route")
    test_covering_bound()
    print("[PASS] test_covering_bound")
    test_verify_accepts_valid_profiles()
    print("[PASS] test_verify_accepts_valid_profiles")
    test_verify_refuses_broken_chain()
    print("[PASS] test_verify_refuses_broken_chain")
    test_verify_refuses_broken_covering_bound()
    print("[PASS] test_verify_refuses_broken_covering_bound")
    print("9 return-lattice Mojo tests passed.")
    require_contract("return lattice of radius-n patches is the Rauzy-graph cycle image")
    require_contract("return-lattice census refuses broken chain and covering-bound profiles")
