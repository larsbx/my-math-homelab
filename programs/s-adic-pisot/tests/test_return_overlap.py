"""Exact finite checks of the ingredients of the return-time overlap bound.

These do not certify balance of an infinite language or PRICE recurrence.
"""

from fractions import Fraction
from itertools import product

import pytest

from sadic_reference import arnoux_rauzy, balance, brun3, compose, image, incidence, matmul, prefix_matrix
from sadic_reference.overlap import positive_suffix_ratio, return_overlap_bound


def _lengths(weights, matrix):
    return tuple(sum(w * x for w, x in zip(weights, col)) for col in zip(*matrix))


def _joint_balance(x, y, d):
    best = 0
    for length in range(1, max(len(x), len(y)) + 1):
        for a in range(d):
            counts = [word[start:start + length].count(a)
                      for word in (x, y) for start in range(len(word) - length + 1)]
            best = max(best, max(counts) - min(counts))
    return best


def _overlap_vectors(x, y, lengths):
    """Independent literal interval oracle, using every pair of tile positions."""
    u, v = x + y, y + x
    top = [0]
    bottom = [0]
    for a in u:
        top.append(top[-1] + lengths[a])
    for a in v:
        bottom.append(bottom[-1] + lengths[a])
    for p in range(len(u)):
        for q in range(len(v)):
            if max(top[p], bottom[q]) < min(top[p + 1], bottom[q + 1]):
                yield tuple(v[:q].count(a) - u[:p].count(a) for a in range(len(lengths)))


def test_suffix_ratio_and_conditional_bound_literals():
    assert positive_suffix_ratio(((2, 1), (1, 1))) == Fraction(2)
    assert positive_suffix_ratio(((2, 3), (4, 5))) == Fraction(3, 2)
    assert return_overlap_bound(((2, 3), (4, 5)), 0) == 2
    assert return_overlap_bound(((2, 3), (4, 5)), 1) == 6
    assert return_overlap_bound(((2, 3), (4, 5)), 2) == 10
    assert return_overlap_bound(((7,),), 0) == 1
    assert return_overlap_bound(((7,),), 3) == 7
    # Python is arbitrary precision; the Mojo twin refuses this overflow.
    assert return_overlap_bound(((1, 1), (1, 1)), 2**63 - 1) == 3 * (2**63 - 1) + 1


def test_suffix_controls_every_nonnegative_left_row_and_is_sharp():
    for entries in product(range(1, 4), repeat=4):
        matrix = (entries[:2], entries[2:])
        ratio = positive_suffix_ratio(matrix)
        extrema = []
        for weights in product(range(5), repeat=2):
            if not any(weights):
                continue
            lengths = _lengths(weights, matrix)
            assert Fraction(max(lengths), min(lengths)) <= ratio
            if weights in ((1, 0), (0, 1)):
                extrema.append(Fraction(max(lengths), min(lengths)))
        assert max(extrema) == ratio


def test_positive_block_must_be_a_suffix_not_a_prefix():
    block = ((2, 1), (1, 1))
    shear = ((1, 1000), (0, 1))
    ratio = positive_suffix_ratio(block)
    after_suffix = _lengths((1, 1), matmul(shear, block))
    after_prefix = _lengths((1, 1), matmul(block, shear))
    assert Fraction(max(after_suffix), min(after_suffix)) <= ratio
    assert Fraction(max(after_prefix), min(after_prefix)) > ratio


def test_positive_prefix_can_violate_the_falsely_inferred_overlap_box():
    block = ((2, 1), (1, 1))
    shear = ((1, 12), (0, 1))
    x, y = (0,) * 12, (1,)
    c = _joint_balance(x, y, 2)
    assert c == 1
    box = return_overlap_bound(block, c)
    assert box == 7
    prefix_lengths = _lengths((1, 1), matmul(block, shear))
    assert prefix_lengths == (3, 38)
    assert (-8, 0) in set(_overlap_vectors(x, y, prefix_lengths))
    assert 8 > box
    suffix_lengths = _lengths((1, 1), matmul(shear, block))
    assert suffix_lengths == (15, 14)
    assert all(max(map(abs, vec)) <= box for vec in _overlap_vectors(x, y, suffix_lengths))


def test_length_rows_need_row_ratios_not_column_ratios():
    block = ((1, 100), (1, 101))
    assert positive_suffix_ratio(block) == 101
    column_ratio = max(Fraction(max(col), min(col)) for col in zip(*block))
    lengths = _lengths((1, 1), block)
    assert Fraction(max(lengths), min(lengths)) == Fraction(201, 2) > column_ratio


@pytest.mark.parametrize("run", [3, 11, 37])
def test_repeated_prefix_places_the_bound_at_its_endpoint(run):
    # A finite P/R indexing guard, not a certificate of infinite PRICE or C.
    shift = arnoux_rauzy(3)
    recurring_prefix = (0, 1, 2)
    before = recurring_prefix + (0,) * run
    directive = before + recurring_prefix
    n, ell, h = len(before), len(recurring_prefix), len(recurring_prefix)
    t = n + ell
    block = prefix_matrix(shift, recurring_prefix)
    ratio = positive_suffix_ratio(block)
    assert directive[n:t] == directive[:ell]
    assert prefix_matrix(shift, directive[ell - h:ell]) == block
    assert prefix_matrix(shift, directive[t - h:t]) == block
    assert prefix_matrix(shift, directive) == matmul(prefix_matrix(shift, directive[:t - h]), block)
    lengths = _lengths((1, 1, 1), prefix_matrix(shift, directive))
    assert lengths == _lengths(_lengths((1, 1, 1), prefix_matrix(shift, before)), block)
    assert Fraction(max(lengths), min(lengths)) <= ratio
    # The start n and a later depth need not share the endpoint's ratio bound.
    for wrong_depth in (before, directive + (0,) * run):
        wrong_lengths = _lengths((1, 1, 1), prefix_matrix(shift, wrong_depth))
        assert Fraction(max(wrong_lengths), min(wrong_lengths)) > ratio


def test_composite_equality_does_not_locate_the_terminal_block():
    identity = ((0,), (1,))
    positive = ((0, 0, 1), (0, 1))
    original, returning = (identity, positive), (positive, identity)
    assert compose(*original) == compose(*returning)
    assert original != returning
    assert incidence(original[-1]) == ((2, 1), (1, 1))
    assert incidence(returning[-1]) == ((1, 0), (0, 1))


def test_swap_walk_uses_image_factors_without_legal_concatenations():
    words = [word for n in range(1, 5) for word in product(range(2), repeat=n)]
    for x, y in product(words, repeat=2):
        c = _joint_balance(x, y, 2)
        u, v = x + y, y + x
        for j in range(len(u) + 1):
            assert max(abs(u[:j].count(a) - v[:j].count(a)) for a in range(2)) <= c
    # The artificial swap boundaries can exceed the language's balance.
    x, y = (0, 1), (1, 0)
    assert _joint_balance(x, y, 2) == 1
    assert _joint_balance(x + y, y + x, 2) == 2


def test_finite_image_balance_cannot_certify_the_supplied_constant():
    # Even complete single images can miss the cross-image balance witness.
    # This is not a BST19 specimen; it tests refusal to infer its hypotheses.
    block = ((1, 1), (1, 1))
    lengths = _lengths((1, 1), block)
    for n in (2, 5, 9):
        x, y = (0,) * n, (1,) * n
        sampled_c = max(balance(x, 2).value, balance(y, 2).value)
        assert sampled_c == 0
        vectors = list(_overlap_vectors(x, y, lengths))
        assert (-n, n) in vectors
        # The arithmetic helper accepts a supplied C; it does not certify it.
        unjustified_box = return_overlap_bound(block, sampled_c)
        assert n > unjustified_box
        justified_box = return_overlap_bound(block, _joint_balance(x, y, 2))
        assert all(max(map(abs, vec)) <= justified_box for vec in vectors)


@pytest.mark.parametrize("matrix", [(), ((),), ((1, 2),), ((1, 0), (1, 1)), ((-1,),)])
def test_rejects_nonpositive_or_nonsquare_matrices(matrix):
    with pytest.raises(ValueError):
        positive_suffix_ratio(matrix)
    with pytest.raises(ValueError):
        return_overlap_bound(matrix, 1)


def test_rejects_negative_balance():
    with pytest.raises(ValueError):
        return_overlap_bound(((1,),), -1)


def test_literal_overlaps_fit_the_conditional_box():
    # Exhaust unequal image lengths, both overlap orientations, and tight rows.
    block = ((2, 1), (1, 1))
    words = [word for n in range(1, 4) for word in product(range(2), repeat=n)]
    for x, y in product(words, repeat=2):
        c = _joint_balance(x, y, 2)
        bound = return_overlap_bound(block, c)
        for weights in ((1, 0), (0, 1), (1, 1), (1000, 1)):
            for vec in _overlap_vectors(x, y, _lengths(weights, block)):
                assert max(map(abs, vec)) <= bound


def test_arnoux_rauzy_and_brun_images_with_skew_left_lengths():
    for shift, positive_word in ((arnoux_rauzy(3), (0, 1, 2)), (brun3(), (2, 2, 2, 2))):
        block = prefix_matrix(shift, positive_word)
        for n in range(1, 4):
            for word in product(range(shift.labels), repeat=n):
                for a in range(3):
                    for b in range(a + 1, 3):
                        x, y = image(shift, word, a), image(shift, word, b)
                        bound = return_overlap_bound(block, _joint_balance(x, y, 3))
                        for weights in ((1, 1, 1), (1000, 1, 1), (1, 1000, 1)):
                            for vec in _overlap_vectors(x, y, _lengths(weights, block)):
                                assert max(map(abs, vec)) <= bound
