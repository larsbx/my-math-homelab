"""First scattered-subword defect degree of a balanced pair.

Every noncoincident balanced pair has `K1 = 0`; its *first defect degree* is
the least `d >= 2` with `K_d != 0`, where `K_d(u, v) = N_d(u) - N_d(v)` is the
difference of the scattered-subword counts of length `d`. `N2` and `N3` are
the alphabet-3 package kernels; `N4` is streamed here by the same prefix
recurrence in `O(n)` with an `81`-coordinate accumulator. Degrees above four
are reported as `DEGREE_FIVE_PLUS` (no defect through degree four), which is
a census classification, not a claim that such a defect exists.
"""

from psc.words import ALPHABET, Pair, is_zero, k2, k3

comptime DEGREE_TWO = 2
comptime DEGREE_THREE = 3
comptime DEGREE_FOUR = 4
comptime DEGREE_FIVE_PLUS = 5


def n4(w: List[Int]) -> List[Int]:
    """`N_{abcd}(w)` in lex coordinates of `Z^81`, streamed in `O(n)`."""
    var seen = List[Int](length=ALPHABET, fill=0)
    var pairs = List[Int](length=ALPHABET * ALPHABET, fill=0)
    var triples = List[Int](length=ALPHABET * ALPHABET * ALPHABET, fill=0)
    var out = List[Int](length=ALPHABET * ALPHABET * ALPHABET * ALPHABET, fill=0)
    for pos in range(len(w)):
        var d = w[pos]
        for a in range(ALPHABET):
            for b in range(ALPHABET):
                for c in range(ALPHABET):
                    out[27 * a + 9 * b + 3 * c + d] += triples[9 * a + 3 * b + c]
        for a in range(ALPHABET):
            for b in range(ALPHABET):
                triples[9 * a + 3 * b + d] += pairs[3 * a + b]
        for a in range(ALPHABET):
            pairs[3 * a + d] += seen[a]
        seen[d] += 1
    return out^


def k4(p: Pair) -> List[Int]:
    var lhs = n4(p.u)
    var rhs = n4(p.v)
    var out = List[Int](capacity=len(lhs))
    for i in range(len(lhs)):
        out.append(lhs[i] - rhs[i])
    return out^


def first_defect_degree(p: Pair) -> Int:
    """`2`, `3`, `4`, or `DEGREE_FIVE_PLUS` when `K2 = K3 = K4 = 0`."""
    if not is_zero(k2(p)):
        return DEGREE_TWO
    if not is_zero(k3(p)):
        return DEGREE_THREE
    if not is_zero(k4(p)):
        return DEGREE_FOUR
    return DEGREE_FIVE_PLUS


def is_degree3(p: Pair) -> Bool:
    return is_zero(k2(p)) and not is_zero(k3(p))
