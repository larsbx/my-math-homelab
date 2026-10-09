"""Exact finite guards for the bounded-anchor proof ingredients.

These are contracts, not an infinite balance or bounded-gap certificate.
"""

from std.testing import assert_equal, assert_false, assert_raises, assert_true
from mojo_smoke.claims import require_contract
from sadic.balance import balance
from sadic.cocycle import prefix_matrix
from sadic.directive import arnoux_rauzy, words_of_length
from sadic.overlap import morphic_balance_bound, window_overlap_bound
from substitution_dynamics.substitution import Substitution


def test_literals() raises:
    assert_equal(morphic_balance_bound(2, 1, 1), 8)
    assert_equal(morphic_balance_bound(2, 1, 2), 16)
    assert_equal(morphic_balance_bound(3, 2, 3), 48)
    assert_equal(morphic_balance_bound(2, 0, 2), 8)
    var block: List[Int] = [2, 1, 1, 1]
    var fractional: List[Int] = [2, 3, 4, 5]
    assert_equal(window_overlap_bound(block, 2, 1, 2, 0), 42)
    assert_equal(window_overlap_bound(block, 2, 1, 2, 1), 148)
    assert_equal(window_overlap_bound(block, 2, 1, 2, 2), 552)
    assert_equal(window_overlap_bound(fractional, 2, 1, 2, 1), 115)
    assert_equal(window_overlap_bound(block, 2, 1, 1, Int.MAX), 42)


def test_invalid_inputs_and_overflows() raises:
    with assert_raises():
        _ = morphic_balance_bound(0, 1, 2)
    with assert_raises():
        _ = morphic_balance_bound(2, -1, 2)
    with assert_raises():
        _ = morphic_balance_bound(2, 1, 0)
    var block: List[Int] = [2, 1, 1, 1]
    var invalid: List[Int] = [1, 0, 1, 1]
    with assert_raises():
        _ = window_overlap_bound(block, 2, 1, 0, 1)
    with assert_raises():
        _ = window_overlap_bound(block, 2, 1, 2, -1)
    with assert_raises():
        _ = window_overlap_bound(block, 2, -1, 2, 1)
    with assert_raises():
        _ = window_overlap_bound(invalid, 2, 1, 2, 1)
    with assert_raises():
        _ = morphic_balance_bound(2, Int.MAX, 1)
    with assert_raises():
        _ = morphic_balance_bound(2, 0, Int.MAX)
    with assert_raises():
        _ = window_overlap_bound(block, 2, 0, 2, 63)
    # Intermediate balance arithmetic fits; final box scaling must still refuse.
    var huge_ratio: List[Int] = [Int.MAX, 1, 1, 1]
    with assert_raises():
        _ = window_overlap_bound(huge_ratio, 2, 0, 1, 0)


def test_morphic_images_and_negative_control() raises:
    var images = List[List[Int]]()
    for n in range(1, 3):
        for word in words_of_length(2, n):
            images.append(word.copy())
    for n in range(1, 5):
        for source in words_of_length(2, n):
            var c = balance(source, 2).value
            for a in images:
                for b in images:
                    var substitution_images: List[List[Int]] = [a.copy(), b.copy()]
                    var substitution = Substitution.checked(substitution_images)
                    var j = max(len(a), len(b))
                    assert_true(balance(substitution.apply(source), 2).value <= morphic_balance_bound(2, c, j))
    var source: List[Int] = [0, 1]
    for j in [2, 4, 8]:
        var a = List[Int]()
        var b = List[Int]()
        for _ in range(j):
            a.append(0)
            b.append(1)
        var substitution_images: List[List[Int]] = [a^, b^]
        var substitution = Substitution.checked(substitution_images)
        assert_equal(balance(substitution.apply(source), 2).value, j)
        assert_true(j > balance(source, 2).value)
    for m in [2, 10, 1000]:
        assert_true(3 * m + 2 > 2 * 3)
        assert_true(3 * m + 2 <= 2 * (m + 1) * 3)


def prefix_returns(word: List[Int], n: Int, length: Int) -> Bool:
    for i in range(length):
        if word[n + i] != word[i]:
            return False
    return True


def periodic_prefix(word: List[Int], length: Int, period: Int) -> Bool:
    for i in range(length - period):
        if word[i] != word[i + period]:
            return False
    return True


def test_prefix_overlap() raises:
    for word in words_of_length(2, 8):
        for n in range(1, 5):
            for p in range(1, 4):
                for length in range(p + 1, 9 - n - p):
                    if prefix_returns(word, n, length) and prefix_returns(word, n + p, length):
                        assert_true(periodic_prefix(word, length, p))
    var finite: List[Int] = [0, 0, 0, 0, 0, 0, 1]
    assert_true(prefix_returns(finite, 1, 3))
    assert_true(prefix_returns(finite, 3, 3))
    assert_true(periodic_prefix(finite, 3, 2))
    assert_false(periodic_prefix(finite, len(finite), 2))


def test_arnoux_rauzy_anchor_example() raises:
    # Generate Thue-Morse by its morphism, rather than the oracle's bit parity.
    var bits: List[Int] = [0]
    for _ in range(8):
        var next_bits = List[Int]()
        for bit in bits:
            next_bits.append(bit)
            next_bits.append(1 - bit)
        bits = next_bits^
    var directive = List[Int]()
    var previous_anchor = 0
    var max_gap = 0
    for i in range(len(bits)):
        directive.append(0)
        directive.append(1 if bits[i] == 0 else 2)
        directive.append(2 if bits[i] == 0 else 1)
        if bits[i] == 0:
            var anchor = 3 * (i + 1)
            max_gap = max(max_gap, anchor - previous_anchor)
            previous_anchor = anchor
            assert_equal(directive[anchor - 3], 0)
            assert_equal(directive[anchor - 2], 1)
            assert_equal(directive[anchor - 1], 2)
    assert_equal(max_gap, 9)
    for i in range(len(directive) - 1):
        assert_true(directive[i] != directive[i + 1])
    var word: List[Int] = [0, 1, 2]
    var matrix = prefix_matrix(arnoux_rauzy(3), word)
    assert_equal(window_overlap_bound(matrix, 3, 3, 2, 9), 34615296)


def main() raises:
    test_literals()
    test_invalid_inputs_and_overflows()
    test_morphic_images_and_negative_control()
    test_prefix_overlap()
    test_arnoux_rauzy_anchor_example()
    require_contract("MorphicBalancePropagation")
    require_contract("BoundedAnchorOverlapBox")
    require_contract("OverlappingPrefixReturns")
    require_contract("ThueMorseArnouxRauzyAnchors")
    print("bounded-anchor ingredients: all assertions passed")
