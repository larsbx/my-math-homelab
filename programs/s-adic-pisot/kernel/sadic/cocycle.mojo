"""The incidence cocycle of a directive shift, in checked integer arithmetic.

A matrix is a row-major `List[Int]` of `d * d` entries with
`M[i][j] = |sigma(j)|_i` (the vendored `Substitution.incidence`), so the
prefix matrix of a directive word is `M_w = M_{w_0} ... M_{w_{n-1}}`, the
incidence matrix of the composite. Every product is checked: an overflow
raises and is inconclusive, never a wrong number.

Positive blocks are the finite data of the hypothesis of BST19 Theorem 3.3
that some cylinder carries a substitution with a positive incidence matrix.
`cross_ratio_bound` is the exact quantity behind Birkhoff's contraction
coefficient: for a positive `M`, the Hilbert-metric diameter of `M R^d_+` is
`log Theta(M)` (G. Birkhoff, "Extensions of Jentzsch's theorem", Trans. Amer.
Math. Soc. 85 (1957) 219-227). No logarithm is taken here.

Reference oracle: `reference/sadic_reference`.
"""

from finite_exact.checked_int import checked_add, checked_mul
from sadic.directive import DirectiveShift, words_of_length


def matmul(a: List[Int], b: List[Int], d: Int) raises -> List[Int]:
    if len(a) != d * d or len(b) != d * d:
        raise Error("matmul needs two d x d matrices")
    var out = List[Int]()
    for i in range(d):
        for j in range(d):
            var s = 0
            for k in range(d):
                s = checked_add(s, checked_mul(a[i * d + k], b[k * d + j]))
            out.append(s)
    return out^


def prefix_matrix(shift: DirectiveShift, word: List[Int]) raises -> List[Int]:
    """`M_{w_0} ... M_{w_{n-1}}`; the identity for the empty word."""
    var d = shift.size()
    var m = List[Int]()
    for i in range(d):
        for j in range(d):
            m.append(1 if i == j else 0)
    for label in word:
        if label < 0 or label >= shift.labels():
            raise Error("directive label out of range: " + String(label))
        m = matmul(m, shift.substitutions[label].incidence(), d)
    return m^


def is_positive(m: List[Int]) -> Bool:
    for x in m:
        if x <= 0:
            return False
    return True


def first_positive_prefix(shift: DirectiveShift, word: List[Int]) raises -> Int:
    """The least n >= 1 with `M_{w[:n]} > 0`, or -1."""
    var d = shift.size()
    var m = prefix_matrix(shift, List[Int]())
    for n in range(len(word)):
        m = matmul(m, shift.substitutions[word[n]].incidence(), d)
        if is_positive(m):
            return n + 1
    return -1


def positive_blocks(shift: DirectiveShift, max_len: Int) raises -> List[List[Int]]:
    """Words of length <= max_len, admissible from some state, with a strictly
    positive product and no proper prefix with one; by length, then
    lexicographically. A non-erasing factor keeps a positive product positive,
    so minimality only needs the longest proper prefix."""
    var out = List[List[Int]]()
    for n in range(1, max_len + 1):
        for w in words_of_length(shift.labels(), n):
            var m = prefix_matrix(shift, w)
            if not is_positive(m):
                continue
            var shorter = w.copy()
            _ = shorter.pop()
            if n > 1 and is_positive(prefix_matrix(shift, shorter)):
                continue
            if shift.admits_somewhere(w):
                out.append(w.copy())
    return out^


@fieldwise_init
struct Ratio(Copyable, Movable):
    """A positive rational `num / den`, unreduced."""

    var num: Int
    var den: Int


def cross_ratio_bound(m: List[Int], d: Int) raises -> Ratio:
    """`Theta(M) = max m_ij m_kl / (m_il m_kj)` for a strictly positive matrix,
    reduced to lowest terms."""
    if len(m) != d * d:
        raise Error("cross-ratio bound needs a d x d matrix")
    if not is_positive(m):
        raise Error("cross-ratio bound needs a strictly positive matrix")
    var best = Ratio(1, 1)
    for i in range(d):
        for j in range(d):
            for k in range(d):
                for l in range(d):
                    var num = checked_mul(m[i * d + j], m[k * d + l])
                    var den = checked_mul(m[i * d + l], m[k * d + j])
                    if checked_mul(num, best.den) > checked_mul(best.num, den):
                        best = Ratio(num, den)
    var g = _gcd(best.num, best.den)
    return Ratio(best.num // g, best.den // g)


def _gcd(a: Int, b: Int) -> Int:
    var x = a
    var y = b
    while y != 0:
        var t = x % y
        x = y
        y = t
    return x
