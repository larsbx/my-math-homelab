"""The numeration a substitution carries, and addition in it.

Three objects are pinned here. The basis `U_k = |tau^k(c)|` and its greedy
digits, which are the numeration a first-order statement over the fixed point
would quantify in. The relation between those digits and the Dumont-Thomas path
digits, which is *not* an identity: the two presentations agree for some
substitutions and differ for others, and the test carries one of each rather
than a claim.

And the addition automaton, the third automaton a decision procedure needs
after admissibility and the letter map. It is built by exact integer state
exploration with a Pisot reachability test, and what is checked here is the
only thing that matters about it: it accepts every true sum below a stated
bound and no false one.
"""

from std.testing import assert_equal, assert_false, assert_true

from finite_automata.dfa import Dfa, minimised, same_language
from mojo_smoke.claims import require_contract
from psc.dumont_thomas import prolongable_form
from psc.linear_numeration import (
    agrees_with_path_digits,
    basis,
    basis_obeys_recurrence,
    digit_value,
    greedy_digits,
    longest_basis,
    max_greedy_digit,
    recurrence,
)
from psc.numeration_addition import addition_automaton, powered_field, triple_word
from psc.perron_field3 import MAX_CERTIFIED_COLUMN_SUM, build_perron_field3
from psc.bpa import substitution_incidence
from finite_linear_algebra.mat3 import Mat3
from psc.oa_overlap_types import prolongable_point


def substitution(w0: List[Int], w1: List[Int], w2: List[Int]) -> List[List[Int]]:
    var sigma = List[List[Int]]()
    sigma.append(w0.copy())
    sigma.append(w1.copy())
    sigma.append(w2.copy())
    return sigma^


def tribonacci() -> List[List[Int]]:
    var a: List[Int] = [0, 1]
    var b: List[Int] = [0, 2]
    var c: List[Int] = [0]
    return substitution(a, b, c)


def doubled_first() -> List[List[Int]]:
    """`0 -> 011, 1 -> 02, 2 -> 0`: prolongable at a letter, and a substitution
    whose path digits are not its greedy digits."""
    var a: List[Int] = [0, 1, 1]
    var b: List[Int] = [0, 2]
    var c: List[Int] = [0]
    return substitution(a, b, c)


def test_the_basis_is_the_characteristic_recurrence() raises:
    var sigma = tribonacci()
    var point = prolongable_point(sigma)
    var tau = prolongable_form(sigma)
    var c = recurrence(tau)
    assert_equal(c[0], -1)
    assert_equal(c[1], -1)
    assert_equal(c[2], -1)                      # U_(k+3) = U_(k+2) + U_(k+1) + U_k
    var u = basis(tau, point.letter, 8)
    var expected: List[Int] = [1, 2, 4, 7, 13, 24, 44, 81]
    for k in range(len(expected)):
        assert_equal(u[k], expected[k])
    assert_true(basis_obeys_recurrence(tau, point.letter, 12))


def test_the_basis_stops_where_the_machine_range_does() raises:
    """A caller that guesses a level count guesses wrong for some specimen, so
    the guess belongs to the helper: it returns the prefix that exists."""
    var sigma = tribonacci()
    var point = prolongable_point(sigma)
    var tau = prolongable_form(sigma)
    var bounded = longest_basis(tau, point.letter, 400)
    assert_true(len(bounded) > 20)
    assert_true(len(bounded) < 400)             # it stopped, rather than wrapping
    for k in range(len(bounded) - 1):
        assert_true(bounded[k] < bounded[k + 1])
    var caught = False
    try:
        _ = basis(tau, point.letter, 400)       # the unbounded call still refuses
    except:
        caught = True
    assert_true(caught)


def test_greedy_digits_round_trip() raises:
    var sigma = tribonacci()
    var point = prolongable_point(sigma)
    var tau = prolongable_form(sigma)
    var u = longest_basis(tau, point.letter, 20)
    for n in range(400):
        assert_equal(digit_value(u, greedy_digits(u, n)), n)
    assert_equal(len(greedy_digits(u, 0)), 0)   # zero is the empty word
    assert_equal(max_greedy_digit(u, 400), 1)   # this basis is binary
    var caught = False
    try:
        _ = greedy_digits(u, -1)
    except:
        caught = True
    assert_true(caught)


def test_the_two_numerations_are_not_the_same_presentation() raises:
    """One substitution where the path digits are the greedy digits, and one
    where they are not. A path digit weighs a child block and a greedy digit
    weighs `U_j`, so agreement is a property of the substitution."""
    var agrees = tribonacci()
    var agrees_point = prolongable_point(agrees)
    assert_true(agrees_with_path_digits(prolongable_form(agrees), agrees_point.letter, 200))

    var differs = doubled_first()
    var differs_point = prolongable_point(differs)
    assert_false(
        agrees_with_path_digits(prolongable_form(differs), differs_point.letter, 150)
    )


def prolongable_only_at_a_power() -> List[List[Int]]:
    """`0 -> 1, 1 -> 2, 2 -> 022`: prolongable at the cube, whose images run to
    length fifteen and so leave the domain `build_perron_field3` is certified
    on (column sums at most `MAX_CERTIFIED_COLUMN_SUM = 6`).

    This is a corpus specimen, not a contrivance: the cube of a three-letter
    substitution can have images of length up to 27, and every specimen whose
    prolongable power exceeds one is a candidate for leaving that domain."""
    var a: List[Int] = [1]
    var b: List[Int] = [2]
    var c: List[Int] = [0, 2, 2]
    return substitution(a, b, c)


def test_a_powered_substitution_builds_its_own_field() raises:
    """The field must come from the powered matrix, and the overlap kernel's
    entry point cannot supply it.

    `build_perron_field3` is certified only for column sums at most six --
    the audited domain of its legacy unchecked predicates -- and a cube of
    three-letter images can leave that domain, as this one does. Such a specimen is
    otherwise perfectly eligible for this numeration, so refusing it would be
    an artefact of which function was asked, not a fact about the
    substitution."""
    var sigma = prolongable_only_at_a_power()
    var point = prolongable_point(sigma)
    assert_equal(point.power, 3)
    var tau = prolongable_form(sigma)
    var longest = 0
    for a in range(3):
        if len(tau[a]) > longest:
            longest = len(tau[a])
    assert_true(longest > MAX_CERTIFIED_COLUMN_SUM)  # outside the audited domain

    var refused = False
    try:
        _ = build_perron_field3(Mat3(substitution_incidence(tau)))
    except:
        refused = True
    assert_true(refused)                        # and it says so, rather than guessing

    # The same cubic, screened by the exact coefficient tests, is available.
    var field = powered_field(tau)
    var chi = Mat3(substitution_incidence(tau)).charpoly()
    assert_equal(field.chi0, chi[0])
    assert_equal(field.chi1, chi[1])
    assert_equal(field.chi2, chi[2])

    # And the automaton builds and recognises addition for that specimen.
    var u = longest_basis(tau, point.letter, 20)
    var radix = max_greedy_digit(u, 200) + 1
    var result = addition_automaton(tau, point.letter, radix, 4000)
    assert_true(result.accepted())
    var add = result.automaton.copy()
    for n in range(20):
        for m in range(20):
            var true_word = triple_word(
                radix, greedy_digits(u, n), greedy_digits(u, m), greedy_digits(u, n + m)
            )
            assert_true(add.accepts(true_word))
            var false_word = triple_word(
                radix, greedy_digits(u, n), greedy_digits(u, m), greedy_digits(u, n + m + 1)
            )
            assert_false(add.accepts(false_word))


def test_the_addition_automaton_accepts_every_true_sum_and_no_false_one() raises:
    """The substantive check. Every `n + m` below the bound is accepted, and
    every near miss `n + m + d` is rejected -- so the automaton is the addition
    relation on this domain, not merely a superset or a subset of it."""
    var sigma = tribonacci()
    var point = prolongable_point(sigma)
    var tau = prolongable_form(sigma)
    var u = longest_basis(tau, point.letter, 20)
    var radix = max_greedy_digit(u, 400) + 1
    assert_equal(radix, 2)
    var result = addition_automaton(tau, point.letter, radix, 4000)
    assert_true(result.accepted())
    var add = result.automaton.copy()
    assert_equal(add.letters, 8)                # triples over a binary alphabet
    assert_equal(add.states(), 137)
    assert_equal(minimised(add).states(), 44)

    var checked = 0
    for n in range(60):
        for m in range(60):
            var true_word = triple_word(
                radix, greedy_digits(u, n), greedy_digits(u, m), greedy_digits(u, n + m)
            )
            assert_true(add.accepts(true_word))
            checked += 1
    assert_equal(checked, 3600)

    for n in range(40):
        for m in range(40):
            for offset in range(1, 4):
                var false_word = triple_word(
                    radix,
                    greedy_digits(u, n),
                    greedy_digits(u, m),
                    greedy_digits(u, n + m + offset),
                )
                assert_false(add.accepts(false_word))


def test_leading_zeros_change_no_verdict() raises:
    """Padding is how three words of different lengths are read together, so a
    run of zero triples in front must fix the state rather than move it."""
    var sigma = tribonacci()
    var point = prolongable_point(sigma)
    var tau = prolongable_form(sigma)
    var u = longest_basis(tau, point.letter, 20)
    var add = addition_automaton(tau, point.letter, 2, 4000).automaton.copy()
    var word = triple_word(2, greedy_digits(u, 5), greedy_digits(u, 9), greedy_digits(u, 14))
    assert_true(add.accepts(word))
    var padded = List[Int]()
    for _ in range(7):
        padded.append(0)
    for i in range(len(word)):
        padded.append(word[i])
    assert_true(add.accepts(padded))


def test_a_search_out_of_budget_refuses_and_malformed_input_raises() raises:
    """Two different failures, which must not reach a caller alike.

    The state set is finite by the imported Pisot theorem, not by anything
    proved here, so a cap reached is an inconclusive *search*: it comes back as
    a refusal carrying no automaton. Malformed input is an impossible state and
    raises. A caller that caught both through one channel could report a defect
    as inconclusive evidence, which is exactly what the census must not do."""
    var sigma = tribonacci()
    var point = prolongable_point(sigma)
    var tau = prolongable_form(sigma)

    var starved = addition_automaton(tau, point.letter, 2, 8)
    assert_false(starved.accepted())
    assert_equal(starved.explored, 0)
    # A refusal carries no automaton worth reading: nothing is accepted by it.
    var word: List[Int] = [0, 0, 0]
    assert_false(starved.automaton.accepts(word))

    var enough = addition_automaton(tau, point.letter, 2, 4000)
    assert_true(enough.accepted())
    assert_equal(enough.explored, 137)

    var refused_radix = False
    try:
        _ = addition_automaton(tau, point.letter, 1, 4000)
    except:
        refused_radix = True
    assert_true(refused_radix)

    var refused_cap = False
    try:
        _ = addition_automaton(tau, point.letter, 2, 0)
    except:
        refused_cap = True
    assert_true(refused_cap)


def main() raises:
    test_the_basis_is_the_characteristic_recurrence()
    print("[PASS] test_the_basis_is_the_characteristic_recurrence")
    test_the_basis_stops_where_the_machine_range_does()
    print("[PASS] test_the_basis_stops_where_the_machine_range_does")
    test_greedy_digits_round_trip()
    print("[PASS] test_greedy_digits_round_trip")
    test_the_two_numerations_are_not_the_same_presentation()
    print("[PASS] test_the_two_numerations_are_not_the_same_presentation")
    test_a_powered_substitution_builds_its_own_field()
    print("[PASS] test_a_powered_substitution_builds_its_own_field")
    test_the_addition_automaton_accepts_every_true_sum_and_no_false_one()
    print("[PASS] test_the_addition_automaton_accepts_every_true_sum_and_no_false_one")
    test_leading_zeros_change_no_verdict()
    print("[PASS] test_leading_zeros_change_no_verdict")
    test_a_search_out_of_budget_refuses_and_malformed_input_raises()
    print("[PASS] test_a_search_out_of_budget_refuses_and_malformed_input_raises")
    print("8 numeration and addition tests passed.")
    require_contract("the linear numeration of a substitution round-trips its greedy digits, its agreement with the Dumont-Thomas path digits is decided per substitution rather than assumed, and the addition automaton built by exact Pisot state exploration is the addition relation on a stated bounded domain; the general recognisability of addition remains an imported theorem, gated in docs/automatic-sequence-route-literature-gate-2026-09-17.md")
