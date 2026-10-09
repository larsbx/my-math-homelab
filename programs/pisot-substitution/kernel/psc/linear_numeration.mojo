"""The linear numeration system a substitution carries, and greedy digits.

`U_k = |tau^k(c)|` is a linear recurrence sequence: the incidence matrix
annihilates its own characteristic polynomial, so with
`chi(x) = c0 + c1 x + c2 x^2 + x^3` the lengths satisfy

    U_(k+3) = -c2 U_(k+2) - c1 U_(k+1) - c0 U_k

and a position of the fixed point is written greedily against that basis, most
significant digit first. This is the numeration a decision procedure over the
sequence would quantify in, and it is a different presentation from the
Dumont-Thomas path of `psc.dumont_thomas`: the digits there weigh a child
block, which depends on the letters along the path, while the digits here weigh
`U_j` alone. The two agree for some substitutions and not for others, which
`agrees_with_path_digits` decides per specimen rather than assuming.

Everything is exact integer arithmetic, and every accumulation is checked: a
basis past the machine range raises rather than wrapping, because a wrapped
basis value would silently misplace every digit computed against it.
"""

from finite_linear_algebra.mat3 import Mat3
from psc.bpa import substitution_incidence
from psc.dumont_thomas import digits, image_lengths, max_image_length


def recurrence(tau: List[List[Int]]) raises -> List[Int]:
    """`(c0, c1, c2)` of the characteristic polynomial of the incidence matrix,
    which is the recurrence the basis obeys."""
    var chi = Mat3(substitution_incidence(tau)).charpoly()
    var out: List[Int] = [chi[0], chi[1], chi[2]]
    return out^


def basis(tau: List[List[Int]], letter: Int, levels: Int) raises -> List[Int]:
    """`U_0 .. U_(levels-1)`, the image lengths of one letter by level."""
    if levels < 1:
        raise Error("a basis has at least one term")
    var out = List[Int]()
    for k in range(levels):
        out.append(image_lengths(tau, k)[letter])
    return out^


def longest_basis(tau: List[List[Int]], letter: Int, max_levels: Int) raises -> List[Int]:
    """As many basis terms as the machine integer range holds, up to
    `max_levels`.

    Image lengths grow like the Perron root, and a power substitution's root is
    large: the corpus reaches terms past `Int` well before level twenty. A
    caller that guesses a level count therefore guesses wrong for some
    specimen, so the guess belongs here, where the failure is visible and the
    answer is the prefix that exists rather than an error about the part that
    does not."""
    var out = List[Int]()
    for k in range(max_levels):
        try:
            out.append(image_lengths(tau, k)[letter])
        except:
            return out^
    return out^


def basis_obeys_recurrence(tau: List[List[Int]], letter: Int, levels: Int) raises -> Bool:
    """Whether the basis really is the recurrence sequence, checked rather than
    assumed: the identity is Cayley-Hamilton applied to the length vector, and
    it is cheap to verify on the terms actually used."""
    var u = longest_basis(tau, letter, levels)
    if len(u) < 4:
        raise Error("too few basis terms in range to check the recurrence")
    var c = recurrence(tau)
    for k in range(len(u) - 3):
        if u[k + 3] != -c[2] * u[k + 2] - c[1] * u[k + 1] - c[0] * u[k]:
            return False
    return True


def greedy_digits(u: List[Int], n: Int) raises -> List[Int]:
    """The greedy representation of `n` against the basis, most significant
    first, with no leading zero. `0` is the empty word."""
    if n < 0:
        raise Error("a position is not negative")
    if n == 0:
        return List[Int]()
    var top = 0
    while top + 1 < len(u) and u[top + 1] <= n:
        top += 1
    if u[top] > n:
        raise Error("the basis does not reach this position")
    var out = List[Int]()
    var rest = n
    for j in range(top, -1, -1):
        var d = 0
        while u[j] <= rest:
            rest -= u[j]
            d += 1
        out.append(d)
    if rest != 0:
        raise Error("greedy digits left a remainder: the basis is malformed")
    return out^


def digit_value(u: List[Int], word: List[Int]) raises -> Int:
    """The number a digit word denotes, most significant digit first."""
    if len(word) > len(u):
        raise Error("digit word is longer than the basis")
    var total = 0
    for i in range(len(word)):
        var weight = u[len(word) - 1 - i]
        var add = word[i] * weight
        if word[i] != 0 and add // word[i] != weight:
            raise Error("digit value exceeds the machine integer range")
        if total > Int.MAX - add:
            raise Error("digit value exceeds the machine integer range")
        total += add
    return total


def max_greedy_digit(u: List[Int], bound: Int) raises -> Int:
    """The largest digit any greedy representation below `bound` uses.

    The alphabet of an addition automaton is cubic in this number, so it is
    measured rather than over-estimated by the alphabet size of the
    substitution."""
    var largest = 0
    for n in range(bound):
        var word = greedy_digits(u, n)
        for i in range(len(word)):
            if word[i] > largest:
                largest = word[i]
    return largest


def agrees_with_path_digits(
    tau: List[List[Int]], letter: Int, bound: Int
) raises -> Bool:
    """Whether the greedy digits against the basis are the Dumont-Thomas path
    digits, for every position below `bound`.

    A path digit weighs a child block and a greedy digit weighs `U_j`, so the
    two coincide exactly when every child block of the path has the length its
    position in the basis predicts. That is a property of the substitution, not
    a convention, and this decides it on a stated range."""
    var u = longest_basis(tau, letter, 40)
    for n in range(bound):
        var path = digits(tau, letter, n)
        var trimmed = List[Int]()
        var seen = False
        for i in range(len(path)):
            if path[i] != 0:
                seen = True
            if seen:
                trimmed.append(path[i])
        var greedy = greedy_digits(u, n)
        if len(trimmed) != len(greedy):
            return False
        for i in range(len(greedy)):
            if trimmed[i] != greedy[i]:
                return False
    return True
