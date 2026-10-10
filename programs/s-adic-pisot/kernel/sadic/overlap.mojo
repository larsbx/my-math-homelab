"""Checked finite ingredients of the return-time overlap bound (T1-prime).

The supplied matrix must be the positive suffix at the selected depth and
the supplied C must be justified separately. These routines certify neither
an infinite language's balance nor PRICE recurrence. Overflow raises and
makes a computation inconclusive. Reference: sadic_reference/overlap.py.

The bounded-anchor extension also takes a supplied image-length cap and
window bound. It does not infer them from PRICE or finite samples.
"""

from finite_exact.checked_int import checked_add, checked_mul
from sadic.cocycle import Ratio


def positive_suffix_ratio(matrix: List[Int], d: Int) raises -> Ratio:
    """R_B = max_i max_a B_ia / min_b B_ib, in lowest terms.

If w >= 0 is nonzero, then (w B)_a <= R_B (w B)_b for all a, b.
Strict positivity is required; a positive prefix has no such guarantee.
"""
    if d <= 0:
        raise Error("positive suffix needs positive dimension")
    if len(matrix) != checked_mul(d, d):
        raise Error("positive suffix needs a d x d matrix")
    var best = Ratio(1, 1)
    for i in range(d):
        var hi = 0
        var lo = Int.MAX
        for a in range(d):
            var value = matrix[i * d + a]
            if value <= 0:
                raise Error("positive suffix needs a strictly positive matrix")
            hi = max(hi, value)
            lo = min(lo, value)
        if checked_mul(hi, best.den) > checked_mul(best.num, lo):
            best = Ratio(hi, lo)
    var x = best.num
    var y = best.den
    while y != 0:
        var remainder = x % y
        x = y
        y = remainder
    return Ratio(best.num // x, best.den // x)


def return_overlap_bound(matrix: List[Int], d: Int, balance_constant: Int) raises -> Int:
    """C + ceil(R_B (1 + d C)), conditional on C-balance at the depth."""
    if balance_constant < 0:
        raise Error("balance constant must be nonnegative")
    var ratio = positive_suffix_ratio(matrix, d)
    var scale = checked_add(1, checked_mul(d, balance_constant))
    var numerator = checked_mul(ratio.num, scale)
    var rounded = numerator // ratio.den
    if numerator % ratio.den != 0:
        rounded = checked_add(rounded, 1)
    return checked_add(balance_constant, rounded)


def morphic_balance_bound(d: Int, balance_constant: Int, max_image_len: Int) raises -> Int:
    """F(d,C,J) = 2 J (d C + 2), for non-erasing images."""
    if d <= 0 or balance_constant < 0 or max_image_len <= 0:
        raise Error("need d >= 1, C >= 0 and J >= 1")
    return checked_mul(checked_mul(2, max_image_len), checked_add(checked_mul(d, balance_constant), 2))


def _checked_power(base: Int, exponent: Int) raises -> Int:
    """Nonnegative powers, with checked products and logarithmic work."""
    var result = 1
    var factor = base
    var remaining = exponent
    while remaining > 0:
        if remaining % 2 == 1:
            result = checked_mul(result, factor)
        remaining //= 2
        if remaining > 0:
            factor = checked_mul(factor, factor)
    return result


def window_overlap_bound(matrix: List[Int], d: Int, balance_constant: Int, image_max: Int, window: Int) raises -> Int:
    """F + ceil(R_B J (1+d F)), J=L^D, conditional on anchor hypotheses.

The window covers both consecutive balanced-anchor gaps and the initial
gap from depth zero. It is not a bound on growing PRICE prefix returns.
"""
    if balance_constant < 0 or image_max <= 0 or window < 0:
        raise Error("need C >= 0, L >= 1 and D >= 0")
    var ratio = positive_suffix_ratio(matrix, d)
    var j = _checked_power(image_max, window)
    var c = morphic_balance_bound(d, balance_constant, j)
    var scale = checked_add(1, checked_mul(d, c))
    var numerator = checked_mul(checked_mul(ratio.num, j), scale)
    var rounded = numerator // ratio.den
    if numerator % ratio.den != 0:
        rounded = checked_add(rounded, 1)
    return checked_add(c, rounded)
