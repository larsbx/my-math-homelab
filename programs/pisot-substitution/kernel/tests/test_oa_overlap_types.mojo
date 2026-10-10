"""Regressions for the Sirvent--Solomyak overlap-type layer.

They pin the prolongable points and the exact enumeration window, the two
named calibrations of docs/overlap-finiteness-and-coincidence-density-
2026-09-13.md (Tribonacci, where the literature types and the seed-patch types
coincide; the non-unimodular `tau`, where a one-letter prefix misses two types
and a longer prefix restores inclusion), and the fail-closed guards that keep
an under-sized window or prefix from silently dropping overlaps.
"""

from std.testing import assert_equal, assert_false, assert_true

from mojo_smoke.claims import require_contract, require_claim
from psc.oa_overlap_types import (
    extended_inclusion_witness,
    fixed_point_prefix,
    least_inclusion_k,
    oa_level_zero_states,
    oa_type_graph,
    oa_window,
    parikh_prefix_sums,
    prolongable_point,
    prolongable_points,
    tile_length_combination,
    type_inclusion_report,
    union_probe,
)
from psc.overlap_seed_patch import (
    build_seed_overlap_graph_from_tables,
    build_seed_overlap_tables,
    nonproductive_overlap_states,
)
from psc.perron_field3 import CubicElt
from psc.symmetry import parse_substitution_key

comptime PREFIX = 6000


def tribonacci() raises -> List[List[Int]]:
    return parse_substitution_key("01/02/0")


def tau() raises -> List[List[Int]]:
    """The standing non-unimodular calibration `1 -> 2, 2 -> 132, 3 -> 112`."""
    return parse_substitution_key("1/021/001")


def test_prolongable_points_are_the_first_letter_cycles() raises:
    var points = prolongable_points(tribonacci())
    # The first-letter map of Tribonacci is constant at 0: the letter 0 is
    # fixed, so it is prolongable at its minimal power 1 only (the higher
    # powers give the same fixed-point word), and nothing else is prolongable.
    assert_equal(len(points), 1, "Tribonacci has one prolongable point")
    assert_equal(points[0].power, 1, "the letter 0 is fixed: minimal power 1")
    assert_equal(points[0].letter, 0, "only the letter 0 is prolongable")
    assert_equal(prolongable_point(tribonacci()).power, 1)
    assert_equal(prolongable_point(tribonacci()).letter, 0)


def test_the_fixed_point_prefix_is_long_enough_and_prolongs() raises:
    var sigma = tribonacci()
    var point = prolongable_point(sigma)
    var u = fixed_point_prefix(sigma, point, PREFIX)
    assert_true(len(u) >= PREFIX)
    assert_equal(u[0], point.letter)
    var shorter = fixed_point_prefix(sigma, point, 16)
    for i in range(len(shorter)):
        assert_equal(shorter[i], u[i])


def test_prefix_sums_are_the_parikh_vectors() raises:
    var w: List[Int] = [0, 2, 0, 1]
    var prefix = parikh_prefix_sums(w)
    var expected: List[Int] = [0, 0, 0, 1, 0, 0, 1, 0, 1, 2, 0, 1, 2, 1, 1]
    assert_equal(prefix, expected)


def test_the_enumeration_window_is_exact_and_fails_closed() raises:
    var sigma = tribonacci()
    var tables = build_seed_overlap_tables(sigma)
    var u = fixed_point_prefix(sigma, prolongable_point(sigma), PREFIX)
    var window = oa_window(tables, u, 1)
    assert_equal(window, 4)
    assert_true(oa_window(tables, u, 4) >= window)

    var cache = Dict[CubicElt, Int]()
    var failed = False
    try:
        _ = oa_level_zero_states(tables, cache, u, 1, window - 1)
    except:
        failed = True
    assert_true(failed)

    var short_prefix = fixed_point_prefix(sigma, prolongable_point(sigma), 4)
    var short_failed = False
    try:
        _ = oa_level_zero_states(tables, cache, short_prefix, 1, window)
    except:
        short_failed = True
    assert_true(short_failed)


def test_a_zero_combination_is_the_zero_translation() raises:
    var tables = build_seed_overlap_tables(tribonacci())
    var zero: List[Int] = [0, 0, 0]
    assert_true(tile_length_combination(tables, zero).is_zero())
    var one: List[Int] = [1, 0, 0]
    assert_false(tile_length_combination(tables, one).is_zero())


def test_tribonacci_types_coincide_with_the_seed_patch() raises:
    var sigma = tribonacci()
    var tables = build_seed_overlap_tables(sigma)
    var seed_graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var point = prolongable_point(sigma)
    var u = fixed_point_prefix(sigma, point, PREFIX)
    var report = type_inclusion_report(tables, seed_graph, u, point, 1)
    assert_true(report.includes())
    assert_equal(report.oa_types, 29)
    assert_equal(report.seed_types, 29)
    assert_equal(report.oa_minus_seed, 0)
    assert_equal(report.seed_minus_oa, 0)
    assert_true(report.oa_all_productive)
    assert_equal(least_inclusion_k(tables, seed_graph, u, point, 8), 1)

    var literature = oa_type_graph(tables, u, 1)
    assert_false(literature.capped)
    assert_equal(len(nonproductive_overlap_states(literature)), 0)


def test_tau_needs_a_longer_prefix_than_one_letter() raises:
    var sigma = tau()
    var tables = build_seed_overlap_tables(sigma)
    var seed_graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var point = prolongable_point(sigma)
    var u = fixed_point_prefix(sigma, point, PREFIX)
    var first = type_inclusion_report(tables, seed_graph, u, point, 1)
    assert_false(first.includes())
    assert_equal(first.oa_minus_seed, 2)
    assert_true(first.oa_all_productive)
    assert_true(first.missing_all_productive)
    # The note writes this prefix as the word `13`: the fixed point of the
    # least prolongable power begins `1 3 ...`, so inclusion arrives at k = 2.
    assert_equal(u[0], 0)
    assert_equal(u[1], 2)
    assert_equal(least_inclusion_k(tables, seed_graph, u, point, 13), 2)

    var witness = extended_inclusion_witness(tables, seed_graph, sigma, PREFIX, 13)
    assert_true(witness.found)
    assert_equal(witness.prefix_length, 2)
    assert_equal(witness.key(), "(2,0,2)")

    var probe = union_probe(tables, seed_graph, sigma, PREFIX, 2)
    assert_true(probe.union_all_productive)
    assert_true(probe.union_noncoincidence > 0)
    assert_true(probe.points >= 1)


def main() raises:
    test_prolongable_points_are_the_first_letter_cycles()
    print("[PASS] test_prolongable_points_are_the_first_letter_cycles")
    test_the_fixed_point_prefix_is_long_enough_and_prolongs()
    print("[PASS] test_the_fixed_point_prefix_is_long_enough_and_prolongs")
    test_prefix_sums_are_the_parikh_vectors()
    print("[PASS] test_prefix_sums_are_the_parikh_vectors")
    test_the_enumeration_window_is_exact_and_fails_closed()
    print("[PASS] test_the_enumeration_window_is_exact_and_fails_closed")
    test_a_zero_combination_is_the_zero_translation()
    print("[PASS] test_a_zero_combination_is_the_zero_translation")
    test_tribonacci_types_coincide_with_the_seed_patch()
    print("[PASS] test_tribonacci_types_coincide_with_the_seed_patch")
    test_tau_needs_a_longer_prefix_than_one_letter()
    print("[PASS] test_tau_needs_a_longer_prefix_than_one_letter")
    print("7 overlap-type tests passed.")
    require_claim("SwapOverlapFiniteness")
    require_contract("the Sirvent-Solomyak overlap-type layer agrees with the repository seed-patch graph on the tribonacci calibration")
