"""The coincidence formula decided by eliminating its quantifiers.

`psc.coincidence_formula` wires the conjunction into one automaton's accepting
condition. This is the other route: write the formula, give each conjunct to
the automaton that already recognises it, and let the kernel's product, union
and subset construction do the rest. The two must give one language, and that
is the substantive test here -- the direct automaton reads its letters off its
own state, the assembly reads them off the Dumont-Thomas letter map, and they
had never been made to agree.

The pieces are checked as well as the whole: the letter conjunct against
`path_letter` on enumerated pair words, and the projection against the
existential it is supposed to discharge, also by enumeration rather than by
trusting `project`.
"""

from std.testing import assert_equal, assert_false, assert_true

from finite_automata.dfa import minimised, same_language
from mojo_smoke.claims import require_contract
from psc.coincidence_elimination import (
    coincidence_by_elimination,
    coincident_positions,
    eliminated_witness,
    holds_by_elimination,
    reaching_one_letter,
)
from psc.coincidence_formula import (
    coincidence_automaton,
    coincidence_level,
    pair_paths,
    path_letter,
)
from psc.dumont_thomas import max_image_length
from psc.words import ALPHABET


def specimens() -> List[List[List[Int]]]:
    """The same four as `test_coincidence_formula.mojo`, coinciding at levels
    1, 3, 14 and 15."""
    var out = List[List[List[Int]]]()
    out.append([[0, 1], [0, 2], [0]])
    out.append([[1], [0, 1, 2], [0, 1, 0]])
    out.append([[1], [2], [0, 1]])
    out.append([[2], [0], [0, 1]])
    return out^


def words_of_length(letters: Int, length: Int) -> List[List[Int]]:
    var words: List[List[Int]] = [List[Int]()]
    for _ in range(length):
        var longer = List[List[Int]]()
        for w in range(len(words)):
            for c in range(letters):
                var next = words[w].copy()
                next.append(c)
                longer.append(next^)
        words = longer^
    return words^


def test_the_assembled_formula_is_the_direct_automaton() raises:
    var corpus = specimens()
    for s in range(len(corpus)):
        ref sigma = corpus[s]
        for i in range(ALPHABET):
            for j in range(ALPHABET):
                assert_true(
                    same_language(
                        coincidence_by_elimination(sigma, i, j),
                        minimised(coincidence_automaton(sigma, i, j)),
                    )
                )


def test_the_existential_is_discharged_at_the_same_level() raises:
    var corpus = specimens()
    for s in range(len(corpus)):
        ref sigma = corpus[s]
        for i in range(ALPHABET):
            for j in range(ALPHABET):
                assert_true(holds_by_elimination(sigma, i, j))
                var found = eliminated_witness(sigma, i, j)
                assert_false(found.empty)
                assert_equal(len(found.word), coincidence_level(sigma, i, j))
                assert_true(coincidence_automaton(sigma, i, j).accepts(found.word))


def test_the_letter_conjunct_is_the_letter_map() raises:
    """`reaching_one_letter` against `path_letter`, on every pair word of a
    stated length. An inadmissible path reaches no letter, and the conjunct
    must reject it rather than answering about a path that does not exist."""
    var sigma = specimens()[1].copy()
    var radix = max_image_length(sigma)
    var conjunct = reaching_one_letter(sigma, 0, 1)
    for length in range(4):
        var words = words_of_length(radix * radix, length)
        for w in range(len(words)):
            var paths = pair_paths(radix, words[w])
            var expected = False
            try:
                expected = path_letter(sigma, 0, paths[0]) == path_letter(
                    sigma, 1, paths[1]
                )
            except:
                expected = False
            assert_equal(conjunct.accepts(words[w]), expected)


def test_quantifying_the_other_path_away_leaves_the_positions() raises:
    """`coincident_positions` must accept a path exactly when some path of the
    same length completes it, which is what `project` claims to compute."""
    var sigma = specimens()[0].copy()
    var radix = max_image_length(sigma)
    var pairs = coincidence_by_elimination(sigma, 0, 1)
    var positions = coincident_positions(sigma, 0, 1)
    for length in range(5):
        var singles = words_of_length(radix, length)
        var others = words_of_length(radix, length)
        for a in range(len(singles)):
            var completed = False
            for b in range(len(others)):
                var packed = List[Int]()
                for t in range(length):
                    packed.append(singles[a][t] + radix * others[b][t])
                if pairs.accepts(packed):
                    completed = True
            assert_equal(positions.accepts(singles[a]), completed)


def test_malformed_input_raises() raises:
    var sigma = specimens()[0].copy()
    var not_a_letter = False
    try:
        _ = reaching_one_letter(sigma, 0, ALPHABET)
    except:
        not_a_letter = True
    assert_true(not_a_letter)

    var other_end = False
    try:
        _ = coincidence_by_elimination(sigma, -1, 0)
    except:
        other_end = True
    assert_true(other_end)


def main() raises:
    test_the_assembled_formula_is_the_direct_automaton()
    print("[PASS] test_the_assembled_formula_is_the_direct_automaton")
    test_the_existential_is_discharged_at_the_same_level()
    print("[PASS] test_the_existential_is_discharged_at_the_same_level")
    test_the_letter_conjunct_is_the_letter_map()
    print("[PASS] test_the_letter_conjunct_is_the_letter_map")
    test_quantifying_the_other_path_away_leaves_the_positions()
    print("[PASS] test_quantifying_the_other_path_away_leaves_the_positions")
    test_malformed_input_raises()
    print("[PASS] test_malformed_input_raises")
    print("5 coincidence elimination tests passed.")
    require_contract("the strong coincidence formula is decided by giving each conjunct to the automaton that recognises it and eliminating the existential with the automata kernel, and the language it assembles is the one the purpose-built automaton accepts; the Parikh-equality relation is the single predicate the numeration's own signature does not supply, and deciding the condition per substitution is not deciding it for the alphabet-3 Pisot family, which stays open")
