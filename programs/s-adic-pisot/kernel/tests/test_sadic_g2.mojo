"""Regressions for the G2 slice of the sadic kernel (docs/sadic-kernel-g2-slice.md).

Every literal here is pinned independently by tests/test_sadic_reference.py
against the Python oracle; tools/cross_check.py compares both on a wider
battery.
"""

from std.testing import assert_equal, assert_false, assert_raises, assert_true

from mojo_smoke.claims import require_claim
from sadic.balance import balance, image_balance
from sadic.cocycle import cross_ratio_bound, first_positive_prefix, is_positive, matmul, positive_blocks, prefix_matrix
from sadic.directive import DirectiveShift, admissible_words, arnoux_rauzy, brun3, words_of_length


def same(a: List[Int], b: List[Int]) -> Bool:
    if len(a) != len(b):
        return False
    for i in range(len(a)):
        if a[i] != b[i]:
            return False
    return True


def test_families() raises:
    var ar = arnoux_rauzy(3)
    var expected_a0: List[List[Int]] = [[0], [1, 0], [2, 0]]
    for j in range(3):
        assert_true(same(ar.substitutions[0].images[j], expected_a0[j]))
    var brun = brun3()
    var b0: List[Int] = [1, 0, 0, 0, 1, 0, 0, 1, 1]
    var b1: List[Int] = [1, 0, 0, 0, 0, 1, 0, 1, 1]
    var b2: List[Int] = [0, 1, 0, 0, 0, 1, 1, 0, 1]
    assert_true(same(brun.substitutions[0].incidence(), b0))
    assert_true(same(brun.substitutions[1].incidence(), b1))
    assert_true(same(brun.substitutions[2].incidence(), b2))


def test_admissibility() raises:
    assert_equal(len(admissible_words(arnoux_rauzy(3), 4)), 81)
    assert_equal(len(admissible_words(brun3(), 3)), 27)
    # golden-mean constraint: label 1 never twice in a row
    var ar2 = arnoux_rauzy(2)
    var table: List[Int] = [0, 1, 0, -1]
    var golden = DirectiveShift.checked("golden", ar2.substitutions, table, 0)
    var ok: List[Int] = [0, 1, 0, 1]
    var bad: List[Int] = [1, 1]
    assert_true(golden.admits(ok))
    assert_false(golden.admits(bad))
    assert_equal(len(admissible_words(golden, 5)), 13)
    var broken: List[Int] = [0, 2]
    with assert_raises():
        _ = DirectiveShift.checked("broken", ar2.substitutions, broken, 0)


def test_prefix_matrix_is_incidence_of_composite() raises:
    for shift in [arnoux_rauzy(3), brun3()]:
        for w in words_of_length(3, 4):
            assert_true(same(prefix_matrix(shift, w), shift.composite(w).incidence()))


def test_positive_blocks() raises:
    var ar_blocks = positive_blocks(arnoux_rauzy(3), 4)
    assert_equal(len(ar_blocks), 24)
    var first: List[Int] = [0, 1, 2]
    assert_true(same(ar_blocks[0], first))
    var brun_blocks = positive_blocks(brun3(), 5)
    var by_length = [0, 0, 0, 0, 0, 0]
    for w in brun_blocks:
        by_length[len(w)] += 1
    for n in range(1, 4):
        assert_equal(by_length[n], 0)
    assert_equal(by_length[4], 6)
    assert_equal(by_length[5], 30)
    var w1: List[Int] = [0, 0, 1, 2, 0]
    var w2: List[Int] = [0, 1, 0, 1]
    assert_equal(first_positive_prefix(arnoux_rauzy(3), w1), 4)
    assert_equal(first_positive_prefix(arnoux_rauzy(3), w2), -1)


def test_cross_ratio_bound() raises:
    var ones: List[Int] = [1, 1, 1, 1]
    var two: List[Int] = [2, 1, 1, 1]
    var zero: List[Int] = [1, 0, 1, 1]
    assert_equal(cross_ratio_bound(ones, 2).num, 1)
    assert_equal(cross_ratio_bound(two, 2).num, 2)
    with assert_raises():
        _ = cross_ratio_bound(zero, 2)
    var w: List[Int] = [0, 1, 2]
    var r = cross_ratio_bound(prefix_matrix(arnoux_rauzy(3), w), 3)
    assert_equal(r.num, 2)
    assert_equal(r.den, 1)
    var b: List[Int] = [2, 2, 2, 2]
    var m = prefix_matrix(brun3(), b)
    var expected: List[Int] = [1, 1, 1, 1, 1, 2, 2, 1, 3]
    assert_true(same(m, expected))
    assert_equal(cross_ratio_bound(m, 3).num, 3)


def test_overflow_is_refused() raises:
    var big: List[Int] = [Int.MAX, 1, 1, 1]
    with assert_raises():
        _ = matmul(big, big, 2)


def test_balance() raises:
    var w0: List[Int] = [0, 0, 0]
    var w1: List[Int] = [0, 1, 0, 1]
    var w2: List[Int] = [0, 0, 1, 1]
    assert_equal(balance(w0, 2).value, 0)
    assert_equal(balance(w1, 2).value, 1)
    var b = balance(w2, 2)
    assert_equal(b.value, 2)
    assert_equal(b.length, 2)
    assert_equal(b.letter, 0)
    var w3: List[Int] = [0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1]
    var c = balance(w3, 2)
    assert_equal(c.value, 2)
    assert_equal(c.start_hi, 2)
    assert_equal(c.start_lo, 9)


def test_sturmian_images_are_one_balanced() raises:
    var ar2 = arnoux_rauzy(2)
    for n in range(1, 11):
        for w in words_of_length(2, n):
            for a in range(2):
                assert_true(image_balance(ar2, w, a) <= 1)


def test_tribonacci_images_are_two_balanced() raises:
    var ar3 = arnoux_rauzy(3)
    var best = 0
    for k in range(1, 5):
        var w = List[Int]()
        for _ in range(k):
            w.append(0)
            w.append(1)
            w.append(2)
        for a in range(3):
            best = max(best, image_balance(ar3, w, a))
    assert_equal(best, 2)


def main() raises:
    test_families()
    test_admissibility()
    test_prefix_matrix_is_incidence_of_composite()
    test_positive_blocks()
    test_cross_ratio_bound()
    test_overflow_is_refused()
    test_balance()
    test_sturmian_images_are_one_balanced()
    test_tribonacci_images_are_two_balanced()
    require_claim("SturmianImageBalance")
    require_claim("ImageBalanceLowerBound")
    require_claim("BrunPositiveBlocks")
    print("sadic G2 slice: all assertions passed")
