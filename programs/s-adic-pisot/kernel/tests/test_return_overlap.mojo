"""Finite regressions for T1-prime's positive-suffix and overlap ingredients.

The general statement is proved in docs/t1-uniform-overlap-finiteness.md.
These tests do not certify an infinite language's balance or recurrence.
"""

from std.testing import assert_equal, assert_raises, assert_true
from mojo_smoke.claims import require_contract
from sadic.balance import balance
from sadic.cocycle import matmul, prefix_matrix
from sadic.directive import arnoux_rauzy, brun3, words_of_length
from sadic.overlap import positive_suffix_ratio, return_overlap_bound


def test_literals() raises:
    var two: List[Int] = [2, 1, 1, 1]
    var fractional: List[Int] = [2, 3, 4, 5]
    var ratio = positive_suffix_ratio(two, 2)
    assert_equal(ratio.num, 2)
    assert_equal(ratio.den, 1)
    ratio = positive_suffix_ratio(fractional, 2)
    assert_equal(ratio.num, 3)
    assert_equal(ratio.den, 2)
    assert_equal(return_overlap_bound(fractional, 2, 0), 2)
    assert_equal(return_overlap_bound(fractional, 2, 1), 6)
    assert_equal(return_overlap_bound(fractional, 2, 2), 10)
    var one: List[Int] = [7]
    assert_equal(return_overlap_bound(one, 1, 0), 1)
    assert_equal(return_overlap_bound(one, 1, 3), 7)
    var asymmetric: List[Int] = [1, 100, 1, 101]
    ratio = positive_suffix_ratio(asymmetric, 2)
    assert_equal(ratio.num, 101)
    assert_equal(ratio.den, 1)
    # (1,1) B = (2,201) exceeds the wrong column bound 101/100.
    assert_true(201 * 100 > 2 * 101)
    var ar_word: List[Int] = [0, 1, 2]
    var brun_word: List[Int] = [2, 2, 2, 2]
    assert_equal(positive_suffix_ratio(prefix_matrix(arnoux_rauzy(3), ar_word), 3).num, 2)
    assert_equal(positive_suffix_ratio(prefix_matrix(brun3(), brun_word), 3).num, 3)


def test_refusals() raises:
    var empty = List[Int]()
    var short: List[Int] = [1, 2]
    var zero: List[Int] = [1, 0, 1, 1]
    var negative: List[Int] = [-1]
    for matrix in [empty.copy(), short.copy(), zero.copy()]:
        with assert_raises():
            _ = positive_suffix_ratio(matrix, 2)
    with assert_raises():
        _ = positive_suffix_ratio(empty, 0)
    with assert_raises():
        _ = positive_suffix_ratio(negative, 1)
    var ones: List[Int] = [1, 1, 1, 1]
    with assert_raises():
        _ = return_overlap_bound(ones, 2, -1)
    with assert_raises():
        _ = return_overlap_bound(ones, 2, Int.MAX)
    var singleton: List[Int] = [1]
    with assert_raises():
        _ = return_overlap_bound(singleton, 1, Int.MAX // 2 + 1)
    with assert_raises():
        _ = positive_suffix_ratio(ones, Int.MAX)
    # Ratio comparisons and scaling must also refuse overflowing intermediates.
    var huge: List[Int] = [Int.MAX, 1, Int.MAX - 1, Int.MAX - 2]
    with assert_raises():
        _ = positive_suffix_ratio(huge, 2)
    var large_ratio: List[Int] = [Int.MAX, 1, 1, 1]
    with assert_raises():
        _ = return_overlap_bound(large_ratio, 2, 1)


def test_suffix_order_and_all_left_rows() raises:
    var block: List[Int] = [2, 1, 1, 1]
    var shear: List[Int] = [1, 1000, 0, 1]
    var suffix = matmul(shear, block, 2)
    var prefix = matmul(block, shear, 2)
    var a = suffix[0] + suffix[2]
    var b = suffix[1] + suffix[3]
    assert_true(max(a, b) <= 2 * min(a, b))
    a = prefix[0] + prefix[2]
    b = prefix[1] + prefix[3]
    assert_true(max(a, b) > 2 * min(a, b))
    for entries in words_of_length(3, 4):
        var matrix = List[Int]()
        for x in entries:
            matrix.append(x + 1)
        var r = positive_suffix_ratio(matrix, 2)
        for weights in words_of_length(5, 2):
            if weights[0] == 0 and weights[1] == 0:
                continue
            a = weights[0] * matrix[0] + weights[1] * matrix[2]
            b = weights[0] * matrix[1] + weights[1] * matrix[3]
            assert_true(max(a, b) * r.den <= min(a, b) * r.num)


def count(word: List[Int], start: Int, end: Int, letter: Int) -> Int:
    var total = 0
    for i in range(start, end):
        if word[i] == letter:
            total += 1
    return total


def joint_balance(x: List[Int], y: List[Int]) -> Int:
    var best = 0
    for length in range(1, max(len(x), len(y)) + 1):
        for a in range(2):
            var hi = 0
            var lo = length
            for word in [x.copy(), y.copy()]:
                for start in range(len(word) - length + 1):
                    var value = count(word, start, start + length, a)
                    hi = max(hi, value)
                    lo = min(lo, value)
            best = max(best, hi - lo)
    return best


def test_wrong_prefix_overlap_box() raises:
    var block: List[Int] = [2, 1, 1, 1]
    var shear: List[Int] = [1, 12, 0, 1]
    var prefix = matmul(block, shear, 2)
    var lengths = [prefix[0] + prefix[2], prefix[1] + prefix[3]]
    assert_equal(lengths[0], 3)
    assert_equal(lengths[1], 38)
    var x = List[Int]()
    for _ in range(12):
        x.append(0)
    var y: List[Int] = [1]
    var c = joint_balance(x, y)
    assert_equal(c, 1)
    var box = return_overlap_bound(block, 2, c)
    assert_equal(box, 7)
    var u = x.copy()
    u.append(1)
    var v = y.copy()
    for a in x:
        v.append(a)
    var p = 8
    var q = 0
    assert_true(max(p * lengths[0], 0) < min((p + 1) * lengths[0], lengths[1]))
    assert_equal(count(v, 0, q, 0) - count(u, 0, p, 0), -8)
    assert_equal(count(v, 0, q, 1) - count(u, 0, p, 1), 0)
    assert_true(8 > box)
    var suffix = matmul(shear, block, 2)
    assert_equal(suffix[0] + suffix[2], 15)
    assert_equal(suffix[1] + suffix[3], 14)


def test_return_endpoint_indexing() raises:
    # A finite P/R guard only: neither C nor infinite PRICE is certified.
    # Blocks (identity, beta) and (beta, identity) have equal composites,
    # but their one-matrix terminal blocks are different.
    var identity: List[Int] = [1, 0, 0, 1]
    var positive: List[Int] = [2, 1, 1, 1]
    var original_product = matmul(identity, positive, 2)
    var returning_product = matmul(positive, identity, 2)
    for i in range(4):
        assert_equal(original_product[i], returning_product[i])
    assert_true(positive[1] != identity[1])
    var shift = arnoux_rauzy(3)
    var recurring_prefix: List[Int] = [0, 1, 2]
    var block = prefix_matrix(shift, recurring_prefix)
    var ratio = positive_suffix_ratio(block, 3)
    for run in [3, 11, 37]:
        var before = recurring_prefix.copy()
        for _ in range(run):
            before.append(0)
        var n = len(before)
        var ell = len(recurring_prefix)
        var h = ell
        var directive = before.copy()
        for label in recurring_prefix:
            directive.append(label)
        var t = n + ell
        var suffix = List[Int]()
        for i in range(t - h, t):
            assert_equal(directive[i], directive[i - n])
            suffix.append(directive[i])
        var suffix_matrix = prefix_matrix(shift, suffix)
        var before_matrix = prefix_matrix(shift, before)
        var endpoint_matrix = prefix_matrix(shift, directive)
        var factored = matmul(before_matrix, block, 3)
        for i in range(9):
            assert_equal(suffix_matrix[i], block[i])
            assert_equal(endpoint_matrix[i], factored[i])
        var lo = Int.MAX
        var hi = 0
        for a in range(3):
            var length = endpoint_matrix[a] + endpoint_matrix[3 + a] + endpoint_matrix[6 + a]
            lo = min(lo, length)
            hi = max(hi, length)
        assert_true(hi * ratio.den <= lo * ratio.num)
        var later = directive.copy()
        for _ in range(run):
            later.append(0)
        for matrix in [before_matrix.copy(), prefix_matrix(shift, later)]:
            lo = Int.MAX
            hi = 0
            for a in range(3):
                var length = matrix[a] + matrix[3 + a] + matrix[6 + a]
                lo = min(lo, length)
                hi = max(hi, length)
            assert_true(hi * ratio.den > lo * ratio.num)


def test_swap_walk_and_unjustified_balance() raises:
    var words = List[List[Int]]()
    for n in range(1, 5):
        for word in words_of_length(2, n):
            words.append(word.copy())
    for x in words:
        for y in words:
            var c = joint_balance(x, y)
            var u = x.copy()
            var v = y.copy()
            for a in y:
                u.append(a)
            for a in x:
                v.append(a)
            for j in range(len(u) + 1):
                for a in range(2):
                    assert_true(abs(count(u, 0, j, a) - count(v, 0, j, a)) <= c)
    var x: List[Int] = [0, 1]
    var y: List[Int] = [1, 0]
    var u: List[Int] = [0, 1, 1, 0]
    var v: List[Int] = [1, 0, 0, 1]
    assert_equal(joint_balance(x, y), 1)
    assert_equal(joint_balance(u, v), 2)
    # Equal tile lengths from a positive suffix do not confer balance.
    # This finite control is not a primitive unimodular BST19 specimen.
    var block: List[Int] = [1, 1, 1, 1]
    for n in [2, 5, 9]:
        x = List[Int]()
        y = List[Int]()
        for _ in range(n):
            x.append(0)
            y.append(1)
        var sampled_c = max(balance(x, 2).value, balance(y, 2).value)
        assert_equal(sampled_c, 0)
        assert_true(n > return_overlap_bound(block, 2, sampled_c))
        assert_true(n <= return_overlap_bound(block, 2, joint_balance(x, y)))
        # At p=q=n, the aligned top/bottom tiles start at length 2n.
        assert_equal(count(x, 0, n, 0) - count(y, 0, n, 0), n)


def test_literal_overlaps() raises:
    var block: List[Int] = [2, 1, 1, 1]
    var words = List[List[Int]]()
    for n in range(1, 4):
        for w in words_of_length(2, n):
            words.append(w.copy())
    var weights: List[List[Int]] = [[1, 0], [0, 1], [1, 1], [1000, 1]]
    for x in words:
        for y in words:
            var bound = return_overlap_bound(block, 2, joint_balance(x, y))
            var u = x.copy()
            var v = y.copy()
            for a in y:
                u.append(a)
            for a in x:
                v.append(a)
            for w in weights:
                var lengths = [2 * w[0] + w[1], w[0] + w[1]]
                var top: List[Int] = [0]
                var bottom: List[Int] = [0]
                for i in range(len(u)):
                    top.append(top[i] + lengths[u[i]])
                    bottom.append(bottom[i] + lengths[v[i]])
                for p in range(len(u)):
                    for q in range(len(v)):
                        if max(top[p], bottom[q]) >= min(top[p + 1], bottom[q + 1]):
                            continue
                        for a in range(2):
                            var delta = count(v, 0, q, a) - count(u, 0, p, a)
                            assert_true(abs(delta) <= bound)


def main() raises:
    test_literals()
    test_refusals()
    test_suffix_order_and_all_left_rows()
    test_wrong_prefix_overlap_box()
    test_return_endpoint_indexing()
    test_swap_walk_and_unjustified_balance()
    test_literal_overlaps()
    require_contract("PositiveSuffixLengthRatio")
    require_contract("ConditionalReturnOverlapBox")
    print("return-time overlap ingredients: all assertions passed")
