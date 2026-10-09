"""Focused regressions for Mojo-native streaming word kernels.

These checks pin exact `N2/N3` coordinates and global combinatorial mass so a
future optimization cannot silently change the scattered-subword convention.
"""

from std.testing import assert_equal
from mojo_smoke.claims import require_claim
from psc.words import n2, n3


def _sum(xs: List[Int]) -> Int:
    var out = 0
    for i in range(len(xs)):
        out += xs[i]
    return out


def test_streamed_n2_exact_coordinates() raises:
    var w: List[Int] = [0, 1, 2, 0, 2]
    var expected: List[Int] = [1, 1, 3, 1, 0, 2, 1, 0, 1]
    assert_equal(n2(w), expected)
    assert_equal(_sum(n2(w)), 10)  # C(5,2)


def test_streamed_n3_exact_coordinates() raises:
    var w: List[Int] = [0, 1, 2, 0, 2]
    var expected: List[Int] = [
        0, 0, 1,
        1, 0, 2,
        1, 0, 1,
        0, 0, 1,
        0, 0, 0,
        1, 0, 1,
        0, 0, 1,
        0, 0, 0,
        0, 0, 0,
    ]
    assert_equal(n3(w), expected)
    assert_equal(_sum(n3(w)), 10)  # C(5,3)


def test_repeated_letter_mass() raises:
    var w: List[Int] = [2, 2, 2, 2, 2, 2]
    var pairs = n2(w)
    var triples = n3(w)
    assert_equal(pairs[8], 15)      # C(6,2)
    assert_equal(triples[26], 20)   # C(6,3)
    assert_equal(_sum(pairs), 15)
    assert_equal(_sum(triples), 20)


def main() raises:
    test_streamed_n2_exact_coordinates()
    print("[PASS] test_streamed_n2_exact_coordinates")
    test_streamed_n3_exact_coordinates()
    print("[PASS] test_streamed_n3_exact_coordinates")
    test_repeated_letter_mass()
    print("[PASS] test_repeated_letter_mass")
    print("3 streaming word-kernel tests passed.")
    require_claim("DefectIntertwiner")
