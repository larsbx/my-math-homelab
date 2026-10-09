"""Relating the two numerations a substitution carries.

The Dumont-Thomas path digits and the greedy digits of the linear numeration
are different presentations of the same positions, and
`test_the_two_numerations_are_not_the_same_presentation` in
`test_numeration_addition.mojo` shows they really do differ. The conversion
automaton is what lets a formula speak both, and what is checked here is the
only thing that matters about it: below a stated bound it pairs each position's
path word with that position's digit word and with no other, and the letter map
carried across it answers exactly as reading the fixed point does.

The pruning bound is checked rather than asserted. Narrowing it by one changes
the language for one of these specimens and widening it does not, so the
constant is measured on both sides instead of being a number in the source with
nothing behind it.
"""

from std.testing import assert_equal, assert_false, assert_true

from finite_linear_algebra.mat3 import Mat3

from finite_automata.dfa import minimised, same_language
from psc.bpa import substitution_incidence
from psc.pisot_state import incidence_step
from mojo_smoke.claims import require_contract
from psc.dumont_thomas import digits, letter_at
from psc.linear_numeration import greedy_digits, longest_basis
from psc.numeration_conversion import (
    conversion_automaton,
    conversion_automaton_with,
    greedy_letter_automaton,
    letter_in_conversion,
    pair_word,
)


comptime TRIBONACCI_RADIX = 3
comptime SPREAD_RADIX = 4


def tribonacci() -> List[List[Int]]:
    """`0 -> 01, 1 -> 02, 2 -> 0`, where the two numerations agree."""
    var out: List[List[Int]] = [[0, 1], [0, 2], [0]]
    return out^


def spread() -> List[List[Int]]:
    """`0 -> 011, 1 -> 02, 2 -> 0`, where they do not: a path digit here weighs
    a block whose length its position in the basis does not predict."""
    var out: List[List[Int]] = [[0, 1, 1], [0, 2], [0]]
    return out^


def test_each_position_is_paired_with_itself_and_with_nothing_else() raises:
    var taus: List[List[List[Int]]] = [tribonacci(), spread()]
    var radices: List[Int] = [TRIBONACCI_RADIX, SPREAD_RADIX]
    for i in range(len(taus)):
        ref tau = taus[i]
        var radix = radices[i]
        var built = conversion_automaton(tau, 0, radix, 60000)
        assert_true(built.accepted())
        var u = longest_basis(tau, 0, 30)
        for n in range(80):
            assert_true(
                built.automaton.accepts(
                    pair_word(radix, digits(tau, 0, n), greedy_digits(u, n))
                )
            )
        for n in range(40):
            for m in range(40):
                if n == m:
                    continue
                assert_false(
                    built.automaton.accepts(
                        pair_word(radix, digits(tau, 0, n), greedy_digits(u, m))
                    )
                )


def test_leading_zeros_change_no_verdict() raises:
    var tau = spread()
    var built = conversion_automaton(tau, 0, SPREAD_RADIX, 60000)
    assert_true(built.accepted())
    var u = longest_basis(tau, 0, 30)
    for n in range(40):
        var path = digits(tau, 0, n)
        var greedy = greedy_digits(u, n)
        var padded_path = List[Int]()
        for _ in range(3):
            padded_path.append(0)
        for i in range(len(path)):
            padded_path.append(path[i])
        var plain = built.automaton.accepts(pair_word(SPREAD_RADIX, path, greedy))
        var padded = built.automaton.accepts(
            pair_word(SPREAD_RADIX, padded_path, greedy)
        )
        assert_equal(plain, padded)
        assert_true(padded)


def test_the_letter_map_transfers_to_the_greedy_digits() raises:
    var taus: List[List[List[Int]]] = [tribonacci(), spread()]
    var radices: List[Int] = [TRIBONACCI_RADIX, SPREAD_RADIX]
    for i in range(len(taus)):
        ref tau = taus[i]
        var radix = radices[i]
        var built = conversion_automaton(tau, 0, radix, 60000)
        assert_true(built.accepted())
        var u = longest_basis(tau, 0, 30)
        for target in range(3):
            var map = letter_in_conversion(built.automaton, tau, 0, target, radix)
            for n in range(80):
                assert_equal(
                    map.accepts(greedy_digits(u, n)),
                    letter_at(tau, 0, n) == target,
                )


def test_the_whole_entry_point_agrees_with_the_shared_conversion() raises:
    var tau = tribonacci()
    var built = conversion_automaton(tau, 0, TRIBONACCI_RADIX, 60000)
    assert_true(built.accepted())
    for target in range(3):
        var shared = letter_in_conversion(built.automaton, tau, 0, target, TRIBONACCI_RADIX)
        var whole = greedy_letter_automaton(tau, 0, target, TRIBONACCI_RADIX, 60000)
        assert_true(whole.accepted())
        assert_true(same_language(shared, whole.automaton))


def test_the_pruning_bound_does_not_decide_the_language() raises:
    """The reserve is computed from limiting ratios and applied at finite
    levels, so it is drawn wider than the computation asks. Wider still must
    change nothing -- it only admits states a minimisation then merges -- and
    the narrowest bound the computation would suggest must be shown to be too
    narrow, or the margin would be superstition."""
    var tau = spread()
    var reference = minimised(
        conversion_automaton_with(tau, 0, SPREAD_RADIX, 200000, 2).automaton
    )
    for slack in range(3, 6):
        var other = conversion_automaton_with(tau, 0, SPREAD_RADIX, 200000, slack)
        assert_true(other.accepted())
        assert_true(same_language(reference, minimised(other.automaton)))
    var tight = conversion_automaton_with(tau, 0, SPREAD_RADIX, 200000, 1)
    assert_true(tight.accepted())
    assert_false(same_language(reference, minimised(tight.automaton)))


def test_a_short_budget_refuses_and_malformed_input_raises() raises:
    var tau = spread()
    var refused = conversion_automaton(tau, 0, SPREAD_RADIX, 8)
    assert_false(refused.accepted())
    assert_equal(refused.explored, 0)

    var narrow = False
    try:
        _ = conversion_automaton(tau, 0, 2, 60000)
    except:
        narrow = True
    assert_true(narrow)

    var no_budget = False
    try:
        _ = conversion_automaton(tau, 0, SPREAD_RADIX, 0)
    except:
        no_budget = True
    assert_true(no_budget)

    var not_a_letter = False
    try:
        _ = conversion_automaton(tau, 3, SPREAD_RADIX, 60000)
    except:
        not_a_letter = True
    assert_true(not_a_letter)

    var refused_map = greedy_letter_automaton(tau, 0, 1, SPREAD_RADIX, 8)
    assert_false(refused_map.accepted())


def test_a_large_digit_alphabet_is_not_refused_for_the_matrix_bound() raises:
    """A greedy digit is a state contribution, not an incidence entry.

    The shared step checks both on the way in, and briefly checked the
    contribution against the *matrix* bound of 64: a radix past that made a
    legitimate transition raise while the start state was still being expanded,
    though `conversion_automaton` documents no such ceiling. A small cap turns
    the search into a refusal, which is an outcome and is what this must see --
    raising would not be, and was the defect.

    The step itself is checked at the value: a contribution far past the matrix
    bound is arithmetic this is expected to do, and only the machine range may
    refuse it."""
    var tau = tribonacci()
    var wide = conversion_automaton(tau, 0, 70, 40)
    assert_false(wide.accepted())

    var m = Mat3(substitution_incidence(tau))
    var zero = List[Int](length=3, fill=0)
    var large: List[Int] = [1000, -1000, 0]
    var stepped = incidence_step(m, zero, large)
    assert_equal(stepped[0], 1000)
    assert_equal(stepped[1], -1000)
    assert_equal(stepped[2], 0)

    var past_the_range = False
    try:
        _ = incidence_step(m, zero, [1 << 60, 0, 0])
    except:
        past_the_range = True
    assert_true(past_the_range)


def main() raises:
    test_each_position_is_paired_with_itself_and_with_nothing_else()
    print("[PASS] test_each_position_is_paired_with_itself_and_with_nothing_else")
    test_leading_zeros_change_no_verdict()
    print("[PASS] test_leading_zeros_change_no_verdict")
    test_the_letter_map_transfers_to_the_greedy_digits()
    print("[PASS] test_the_letter_map_transfers_to_the_greedy_digits")
    test_the_whole_entry_point_agrees_with_the_shared_conversion()
    print("[PASS] test_the_whole_entry_point_agrees_with_the_shared_conversion")
    test_the_pruning_bound_does_not_decide_the_language()
    print("[PASS] test_the_pruning_bound_does_not_decide_the_language")
    test_a_short_budget_refuses_and_malformed_input_raises()
    print("[PASS] test_a_short_budget_refuses_and_malformed_input_raises")
    test_a_large_digit_alphabet_is_not_refused_for_the_matrix_bound()
    print("[PASS] test_a_large_digit_alphabet_is_not_refused_for_the_matrix_bound")
    print("7 numeration conversion tests passed.")
    require_contract("the conversion automaton pairs a Dumont-Thomas path word with the digit word of the same position and with no other, on a stated bounded domain, and the letter map carried across it answers as the fixed point does; its pruning bound is measured on both sides rather than asserted, and the finiteness of the state set it explores remains an imported theorem, gated in docs/automatic-sequence-route-literature-gate-2026-09-17.md")
