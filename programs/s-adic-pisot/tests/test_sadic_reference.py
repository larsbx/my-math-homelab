"""Contracts of the Python reference oracle (non-authoritative; the Mojo kernel
under kernel/sadic is canonical). Every literal pinned here is pinned
independently by kernel/tests/test_*.mojo; tools/cross_check.py compares the
two implementations on a wider battery."""

from fractions import Fraction
from itertools import product

import pytest

from sadic_reference import (
    DirectiveShift,
    admissible_words,
    arnoux_rauzy,
    balance,
    brun3,
    compose_all,
    cross_ratio_bound,
    first_positive_prefix,
    image_balance,
    incidence,
    is_positive,
    matmul,
    positive_blocks,
    prefix_matrix,
)

AR2 = arnoux_rauzy(2)
AR3 = arnoux_rauzy(3)
BRUN = brun3()


def test_arnoux_rauzy_images():
    assert AR3.substitutions[0] == ((0,), (1, 0), (2, 0))
    assert AR3.substitutions[2] == ((0, 2), (1, 2), (2,))
    assert AR3.labels == 3 and AR3.size == 3


def test_brun_incidence_is_bst19_matrices():
    # BST19 (3.3): the linear Brun matrices
    assert incidence(BRUN.substitutions[0]) == ((1, 0, 0), (0, 1, 0), (0, 1, 1))
    assert incidence(BRUN.substitutions[1]) == ((1, 0, 0), (0, 0, 1), (0, 1, 1))
    assert incidence(BRUN.substitutions[2]) == ((0, 1, 0), (0, 0, 1), (1, 0, 1))


def test_full_shifts_admit_every_word():
    assert len(admissible_words(AR3, 4)) == 81
    assert len(admissible_words(BRUN, 3)) == 27


def test_sofic_shift_rejects_forbidden_words():
    # golden-mean constraint on two labels: label 1 never twice in a row
    shift = DirectiveShift("golden", AR2.substitutions, ((0, 1), (0, -1)), 0)
    assert shift.admits((0, 1, 0, 1))
    assert not shift.admits((1, 1))
    assert len(admissible_words(shift, 5)) == 13  # Fibonacci count


def test_prefix_matrix_is_the_incidence_of_the_composite():
    for shift in (AR3, BRUN):
        for word in admissible_words(shift, 4):
            assert prefix_matrix(shift, word) == incidence(compose_all(shift, word))


def test_empty_prefix_is_the_identity():
    assert prefix_matrix(BRUN, ()) == ((1, 0, 0), (0, 1, 0), (0, 0, 1))
    assert first_positive_prefix(AR3, ()) == -1
    assert image_balance(AR3, (), 0) == 0


def test_matmul_is_associative_on_cocycles():
    a, b, c = (incidence(s) for s in BRUN.substitutions)
    assert matmul(matmul(a, b), c) == matmul(a, matmul(b, c))


def test_positive_blocks_arnoux_rauzy():
    # every minimal positive AR3 block uses all three labels
    blocks = positive_blocks(AR3, 4)
    assert all(set(w) == {0, 1, 2} for w in blocks)
    assert (0, 1, 2) in blocks and len([w for w in blocks if len(w) == 3]) == 6


def test_first_positive_prefix():
    assert first_positive_prefix(AR3, (0, 0, 1, 2, 0)) == 4
    assert first_positive_prefix(AR3, (0, 1, 0, 1)) == -1


def test_cross_ratio_bound():
    assert cross_ratio_bound(((1, 1), (1, 1))) == Fraction(1)
    assert cross_ratio_bound(((2, 1), (1, 1))) == Fraction(2)
    with pytest.raises(ValueError):
        cross_ratio_bound(((1, 0), (1, 1)))
    m = prefix_matrix(AR3, (0, 1, 2))
    assert is_positive(m) and cross_ratio_bound(m) == Fraction(2)


def test_balance_of_words():
    assert balance((0, 0, 0), 2).value == 0
    assert balance((0, 1, 0, 1), 2).value == 1
    w = balance((0, 0, 1, 1), 2)
    assert w.value == 2 and (w.length, w.letter) == (2, 0)


def test_balance_witness_is_genuine():
    word = (0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1)
    w = balance(word, 2)
    hi = word[w.start_hi:w.start_hi + w.length].count(w.letter)
    lo = word[w.start_lo:w.start_lo + w.length].count(w.letter)
    assert hi - lo == w.value


def test_sturmian_images_are_one_balanced():
    # calibration: sigma_w(a) for Arnoux-Rauzy on two letters is a standard
    # Sturmian/Christoffel word, hence 1-balanced
    for n in range(1, 11):
        for word in product(range(2), repeat=n):
            for a in range(2):
                assert image_balance(AR2, word, a) <= 1


def test_tribonacci_images_are_two_balanced():
    # calibration: the Tribonacci word is 2-balanced and not 1-balanced
    values = {image_balance(AR3, (0, 1, 2) * k, a) for k in range(1, 5) for a in range(3)}
    assert max(values) == 2


def test_positive_blocks_brun():
    # BST19 Theorem 3.3 asks for a cylinder whose substitution has a positive
    # incidence matrix; for Brun the shortest such blocks have length 4
    blocks = positive_blocks(BRUN, 5)
    assert [len([w for w in blocks if len(w) == n]) for n in range(1, 6)] == [0, 0, 0, 6, 30]
    assert (2, 2, 2, 2) in blocks
    assert prefix_matrix(BRUN, (2, 2, 2, 2)) == ((1, 1, 1), (1, 1, 2), (2, 1, 3))
    assert cross_ratio_bound(prefix_matrix(BRUN, (2, 2, 2, 2))) == Fraction(3)
