"""Exact reference for the finite positive-suffix bound used by T1-prime.

This computes a conditional box from a supplied balance constant. It does
not verify balance of an infinite language or select PRICE return depths.
"""

from fractions import Fraction

from sadic_reference import Matrix


def positive_suffix_ratio(matrix: Matrix) -> Fraction:
    """The sharp bound on max(w B) / min(w B) for nonzero w >= 0.

The oracle enumerates ordered column pairs using arbitrary-precision ratios.
The canonical Mojo implementation instead compares each row's extrema.
"""
    d = len(matrix)
    if d < 1 or any(len(row) != d for row in matrix):
        raise ValueError("positive suffix needs a nonempty square matrix")
    if any(x <= 0 for row in matrix for x in row):
        raise ValueError("positive suffix needs a strictly positive matrix")
    return max(Fraction(row[a], row[b])
               for row in matrix for a in range(d) for b in range(d))


def return_overlap_bound(matrix: Matrix, balance_constant: int) -> int:
    """C + ceil(R_B (1 + d C)), conditional on the supplied C-balance."""
    if balance_constant < 0:
        raise ValueError("balance constant must be nonnegative")
    value = balance_constant + positive_suffix_ratio(matrix) * (1 + len(matrix) * balance_constant)
    return -(-value.numerator // value.denominator)


def morphic_balance_bound(d: int, balance_constant: int, max_image_len: int) -> int:
    """An upper bound for factors of images of a C-balanced language.

The source alphabet has d letters and every nonempty image has length <= J.
This is conditional on the supplied infinite-language balance constant.
"""
    if d < 1 or balance_constant < 0 or max_image_len < 1:
        raise ValueError("need d >= 1, C >= 0 and J >= 1")
    # An independent grouping of the proof's full-image and boundary terms.
    j = max_image_len
    full_image_error = d * balance_constant * j
    unmatched_image_length = full_image_error + 2 * j
    return full_image_error + unmatched_image_length + 2 * j


def window_overlap_bound(matrix: Matrix, balance_constant: int, image_max: int, window: int) -> int:
    """All-depth box conditional on balanced positive-suffix anchors.

image_max bounds the length of every substitution image. window bounds
both anchor gaps and the initial gap. Neither infinite condition is checked.
"""
    if balance_constant < 0 or image_max < 1 or window < 0:
        raise ValueError("need C >= 0, L >= 1 and D >= 0")
    ratio = positive_suffix_ratio(matrix)
    j = image_max ** window
    c = morphic_balance_bound(len(matrix), balance_constant, j)
    value = c + ratio * j * (1 + len(matrix) * c)
    return -(-value.numerator // value.denominator)
