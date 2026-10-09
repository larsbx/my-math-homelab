"""Contracts for deterministic growing-corpus band enumeration."""

from std.testing import assert_equal, assert_false, assert_true

from mojo_smoke.claims import require_contract
from psc.growing_corpus import (
    band_index,
    band_total,
    image_word_count,
    run_growth_band,
)


def assert_same_offsets(a: List[Int], b: List[Int]) raises:
    assert_equal(len(a), len(b))
    for i in range(len(a)):
        assert_equal(a[i], b[i])


def test_band_sizes_are_exact_differences() raises:
    assert_equal(image_word_count(1), 3)
    assert_equal(image_word_count(2), 12)
    assert_equal(image_word_count(3), 39)
    assert_equal(image_word_count(4), 120)
    assert_equal(band_total(1), 27)
    assert_equal(band_total(2), 1701)
    assert_equal(band_total(3), 57591)
    assert_equal(band_total(4), 1668681)


def test_every_band_two_offset_is_unique_and_new() raises:
    var w = image_word_count(2)
    var previous = image_word_count(1)
    var seen = List[Bool](length=w * w * w, fill=False)
    for offset in range(band_total(2)):
        var t = band_index(2, offset)
        assert_true(t.i >= previous or t.j >= previous or t.k >= previous)
        var flat = (t.i * w + t.j) * w + t.k
        assert_false(seen[flat])
        seen[flat] = True


def test_max_parallelism_does_not_change_acceptance_order() raises:
    comptime SAMPLE = 96
    var one = run_growth_band(4, 0, SAMPLE, 1)
    var four = run_growth_band(4, 0, SAMPLE, 4)
    assert_equal(one.screened, SAMPLE)
    assert_equal(four.screened, SAMPLE)
    assert_same_offsets(one.accepted_offsets, four.accepted_offsets)


def test_invalid_slice_fails_closed() raises:
    var rejected = False
    try:
        _ = run_growth_band(4, band_total(4), 1, 2)
    except:
        rejected = True
    assert_true(rejected)


def main() raises:
    test_band_sizes_are_exact_differences()
    print("[PASS] test_band_sizes_are_exact_differences")
    test_every_band_two_offset_is_unique_and_new()
    print("[PASS] test_every_band_two_offset_is_unique_and_new")
    test_max_parallelism_does_not_change_acceptance_order()
    print("[PASS] test_max_parallelism_does_not_change_acceptance_order")
    test_invalid_slice_fails_closed()
    print("[PASS] test_invalid_slice_fails_closed")
    print("4 growing-corpus tests passed.")
    require_contract("the growing research corpus partitions substitutions by exact maximum image length, screens each candidate once, and is worker-count invariant")
