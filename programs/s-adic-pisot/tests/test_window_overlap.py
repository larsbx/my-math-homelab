"""Finite checks for the morphic balance and bounded-anchor ingredients.

No finite test certifies the required infinite family of balanced anchors.
"""

from itertools import product

import pytest

from sadic_reference import apply, arnoux_rauzy, balance, prefix_matrix
from sadic_reference.overlap import morphic_balance_bound, window_overlap_bound


def test_morphic_balance_bound_literals():
    assert morphic_balance_bound(2, 1, 1) == 8
    assert morphic_balance_bound(2, 1, 2) == 16
    assert morphic_balance_bound(3, 2, 3) == 48
    assert morphic_balance_bound(2, 0, 2) == 8


def test_window_bound_literals_and_power_zero():
    block = ((2, 1), (1, 1))
    assert window_overlap_bound(block, 1, 2, 0) == 42
    assert window_overlap_bound(block, 1, 2, 1) == 148
    assert window_overlap_bound(block, 1, 2, 2) == 552
    assert window_overlap_bound(((2, 3), (4, 5)), 1, 2, 1) == 115
    assert window_overlap_bound(block, 1, 1, 2**63 - 1) == 42


@pytest.mark.parametrize("d,c,j", [(0, 1, 2), (-1, 1, 2), (2, -1, 2), (2, 1, 0)])
def test_morphic_bound_rejects_invalid_parameters(d, c, j):
    with pytest.raises(ValueError):
        morphic_balance_bound(d, c, j)


@pytest.mark.parametrize("matrix,c,l,h", [
    ((), 1, 2, 1), (((1, 0), (1, 1)), 1, 2, 1),
    (((1,),), -1, 2, 1), (((1,),), 1, 0, 1), (((1,),), 1, 2, -1),
])
def test_window_bound_rejects_invalid_parameters(matrix, c, l, h):
    with pytest.raises(ValueError):
        window_overlap_bound(matrix, c, l, h)


def test_morphic_image_balance_and_negative_control():
    words = [w for n in range(1, 5) for w in product(range(2), repeat=n)]
    images = [w for n in (1, 2) for w in product(range(2), repeat=n)]
    for source in words:
        c = balance(source, 2).value
        for substitution in product(images, repeat=2):
            j = max(map(len, substitution))
            assert balance(apply(substitution, source), 2).value <= morphic_balance_bound(2, c, j)
    # A balanced depth does not confer the same constant on earlier depths.
    for j in (2, 4, 8):
        substitution = ((0,) * j, (1,) * j)
        assert balance((0, 1), 2).value == 1
        assert balance(apply(substitution, (0, 1)), 2).value == j > 1


def test_length_ratio_can_grow_after_a_positive_anchor():
    # The length row starts at (3, 2) = (1, 1) B, B = [[2,1],[1,1]].
    # A shear block has column sums 1 and m+1, so J=m+1 controls the growth.
    for m in (2, 10, 1000):
        lengths = (3, 3 * m + 2)
        assert max(lengths) > 2 * min(lengths)
        assert max(lengths) <= 2 * (m + 1) * min(lengths)


def test_nonperiodic_arnoux_rauzy_anchor_example():
    # Finite guard for the infinite construction proved in the note.
    bits = tuple(i.bit_count() % 2 for i in range(256))
    directive = tuple(a for bit in bits for a in ((0, 1, 2) if bit == 0 else (0, 2, 1)))
    assert all(a != b for a, b in zip(directive, directive[1:]))
    anchors = [3 * (i + 1) for i, bit in enumerate(bits) if bit == 0]
    assert anchors[0] == 3
    assert max(b - a for a, b in zip(anchors, anchors[1:])) == 9
    for r in anchors:
        assert directive[r - 3:r] == (0, 1, 2)
    block = prefix_matrix(arnoux_rauzy(3), (0, 1, 2))
    assert block == ((4, 3, 2), (2, 2, 1), (1, 1, 1))
    assert window_overlap_bound(block, 3, 2, 9) == 34615296


def _periodic_prefix(word, length, period):
    return all(word[i] == word[i + period] for i in range(length - period))


def test_overlapping_prefix_returns_force_the_prefix_period():
    for word in product(range(2), repeat=8):
        for n in range(1, 5):
            for p in range(1, 4):
                for length in range(p + 1, 9 - n - p):
                    if word[n:n + length] == word[:length] and word[n + p:n + p + length] == word[:length]:
                        assert _periodic_prefix(word, length, p)
    # Finite returns only constrain the overlapping prefix, not the whole word.
    word = (0, 0, 0, 0, 0, 0, 1)
    assert word[1:4] == word[:3] == word[3:6]
    assert _periodic_prefix(word, 3, 2)
    assert not _periodic_prefix(word, len(word), 2)
