"""The Brun d = 4 periodic census through period 8 (docs/sadic-g3-brun4-census.md).

Every Lyndon representative of a primitive periodic point of the unordered
Brun shift (BST23 (6.9), (6.10)) with period <= 8 is classified; every
composite that is primitive, irreducible and Pisot passes the balanced pair
algorithm within the budgets, and no verdict is open.
"""

from std.testing import assert_equal

from mojo_smoke.claims import require_claim
from sadic.periodic import brun_unordered, periodic_verdict, periodic_words, verdict_index, verdict_names

comptime MAX_STATES = 200000
comptime MAX_LENGTH = 20000


def main() raises:
    var shift = brun_unordered(4)
    # per period: words, not-primitive, irreducible:0, pisot:0, bpa:terminates
    var expected: List[List[Int]] = [
        [12, 12, 0, 0, 0], [6, 6, 0, 0, 0], [20, 20, 0, 0, 0], [60, 54, 0, 0, 6],
        [204, 156, 0, 0, 48], [670, 410, 12, 0, 248], [2340, 1140, 48, 0, 1152],
        [8160, 3060, 144, 24, 4932],
    ]
    var names = verdict_names()
    for n in range(1, 9):
        var counts = List[Int]()
        for _ in range(len(names)):
            counts.append(0)
        var words = periodic_words(shift, n)
        for w in words:
            counts[verdict_index(periodic_verdict(shift, w, MAX_STATES, MAX_LENGTH))] += 1
        var e = expected[n - 1].copy()
        assert_equal(len(words), e[0])
        assert_equal(counts[verdict_index("not-primitive")], e[1])
        assert_equal(counts[verdict_index("irreducible:0")], e[2])
        assert_equal(counts[verdict_index("pisot:0")], e[3])
        assert_equal(counts[verdict_index("bpa:terminates")], e[4])
        assert_equal(e[1] + e[2] + e[3] + e[4], e[0])  # nothing open, nothing fails
    require_claim("BrunFourPeriodicCensus")
    print("Brun d=4 periodic census through period 8: all assertions passed")
