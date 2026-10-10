"""Regression for the fixed-substitution coincidence-depth bound.

The first test pins the graph-theoretic inequality on substitutions with least
strong-coincidence levels 1, 3, 14 and 15.  The second is a negative control for
a uniform proof: the unimodular cubic PIP family

    0 -> 1,  1 -> 2,  2 -> 0 2^n,  n >= 3

has unbounded image length and incidence height.  The accompanying note proves
the family statement algebraically.  The finite samples here only guard the
encoding and must not be cited as that proof.
"""

from std.testing import assert_equal, assert_true

from finite_linear_algebra.mat3 import Mat3
from psc.bpa import apply_substitution, substitution_incidence
from mojo_smoke.claims import require_contract
from psc.coincidence_level_bound import pair_depth_bound, substitution_depth_bound
from psc.dumont_thomas import max_image_length
from psc.numeration_addition import powered_field
from psc.words import ALPHABET


def deep_specimens() -> List[List[List[Int]]]:
    var out = List[List[List[Int]]]()
    out.append([[0, 1], [0, 2], [0]])
    out.append([[1], [0, 1, 2], [0, 1, 0]])
    out.append([[1], [2], [0, 1]])
    out.append([[2], [0], [0, 1]])
    return out^


def height_family(n: Int) raises -> List[List[Int]]:
    if n < 3:
        raise Error("the documented irreducible family starts at n = 3")
    var zero: List[Int] = [1]
    var one: List[Int] = [2]
    var two: List[Int] = [0]
    for _ in range(n):
        two.append(2)
    var sigma = List[List[Int]]()
    sigma.append(zero^)
    sigma.append(one^)
    sigma.append(two^)
    return sigma^


def test_shortest_level_is_bounded_by_coaccessible_states() raises:
    var expected: List[Int] = [1, 3, 14, 15]
    var corpus = deep_specimens()
    for s in range(len(corpus)):
        var whole = substitution_depth_bound(corpus[s])
        assert_true(not whole.empty)
        assert_equal(whole.level, expected[s])
        assert_true(whole.level <= whole.upper)
        assert_true(whole.coaccessible <= whole.states)
        for top in range(ALPHABET):
            for bottom in range(top + 1, ALPHABET):
                var pair = pair_depth_bound(corpus[s], top, bottom)
                assert_true(pair.certifies_level())
                assert_true(pair.coaccessible <= pair.states)
                # The rejecting sink is reachable but cannot reach acceptance.
                assert_true(pair.coaccessible < pair.states)


def test_unimodular_pip_inputs_have_unbounded_syntactic_parameters() raises:
    var ns: List[Int] = [3, 7, 31, 63]
    for i in range(len(ns)):
        var n = ns[i]
        var sigma = height_family(n)
        _ = powered_field(sigma)
        var incidence = Mat3(substitution_incidence(sigma))
        assert_equal(incidence.det(), 1)
        assert_equal(max_image_length(sigma), n + 1)
        assert_equal(incidence.at(2, 2), n)



def inflated(sigma: List[List[Int]], letter: Int, level: Int) -> List[Int]:
    var word: List[Int] = [letter]
    for _ in range(level):
        word = apply_substitution(sigma, word)
    return word^


def assert_balanced_witness(
    sigma: List[List[Int]],
    top: Int,
    bottom: Int,
    level: Int,
    position: Int,
    expected0: Int,
    expected1: Int,
    expected2: Int,
) raises:
    var above = inflated(sigma, top, level)
    var below = inflated(sigma, bottom, level)
    assert_true(position < len(above) and position < len(below))
    var ca = List[Int](length=ALPHABET, fill=0)
    var cb = List[Int](length=ALPHABET, fill=0)
    for p in range(position):
        ca[above[p]] += 1
        cb[below[p]] += 1
    for a in range(ALPHABET):
        assert_equal(ca[a], cb[a])
    assert_equal(ca[0], expected0)
    assert_equal(ca[1], expected1)
    assert_equal(ca[2], expected2)
    assert_equal(above[position], below[position])


def test_height_cancels_in_explicit_level_four_witnesses() raises:
    var ns: List[Int] = [3, 7, 31]
    for i in range(len(ns)):
        var n = ns[i]
        var sigma = height_family(n)
        # sigma^3(1), sigma^3(2) begin 1022... and 2102...
        assert_balanced_witness(sigma, 1, 2, 3, 3, 1, 1, 1)
        # sigma^4(0) = sigma^3(1).
        assert_balanced_witness(sigma, 0, 1, 4, 3, 1, 1, 1)
        # The n-dependent position has the same two-zero, one-one balance.
        assert_balanced_witness(sigma, 0, 2, 4, n + 4, 2, 1, n + 1)

def test_the_current_field_ceiling_refuses_instead_of_narrowing_the_theorem() raises:
    var refused = False
    try:
        _ = powered_field(height_family(65))
    except:
        refused = True
    assert_true(refused)


def main() raises:
    test_shortest_level_is_bounded_by_coaccessible_states()
    print("[PASS] test_shortest_level_is_bounded_by_coaccessible_states")
    test_unimodular_pip_inputs_have_unbounded_syntactic_parameters()
    print("[PASS] test_unimodular_pip_inputs_have_unbounded_syntactic_parameters")
    test_height_cancels_in_explicit_level_four_witnesses()
    print("[PASS] test_height_cancels_in_explicit_level_four_witnesses")
    test_the_current_field_ceiling_refuses_instead_of_narrowing_the_theorem()
    print("[PASS] test_the_current_field_ceiling_refuses_instead_of_narrowing_the_theorem")
    print("4 coincidence-level-bound tests passed.")
    require_contract("a nonempty pair coincidence language has least level at most the coaccessible affine-state count minus one; the unbounded-height unimodular family 0->1, 1->2, 2->0 2^n has explicit pair witnesses by level four; the current powered-field ceiling refuses member 65 rather than narrowing either mathematical statement, and no uniform alphabet-three PIP bound or pair nonemptiness theorem is claimed")
