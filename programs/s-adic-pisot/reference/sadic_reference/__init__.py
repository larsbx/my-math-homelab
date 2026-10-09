"""Exact Python reference oracle for the S-adic kernel (kernel/sadic).

Non-authoritative: the Mojo modules are canonical and this package exists to
cross-check them in an independently written implementation (AGENTS.md).
Exact arithmetic only: `int` and `fractions.Fraction`.

Conventions (docs/sadic-kernel-g2-slice.md):
- letters and labels are 0-based;
- a substitution is a tuple of images, `sigma[a]` the image of letter `a`;
- the incidence matrix has `M[i][j] = |sigma(j)|_i`, so `M_{s o t} = M_s M_t`;
- a directive word `w = w_0 ... w_{n-1}` has composite
  `sigma_w = sigma_{w_0} o ... o sigma_{w_{n-1}}` and prefix matrix
  `M_w = M_{w_0} ... M_{w_{n-1}}`.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from functools import reduce
from itertools import product

Word = tuple[int, ...]
Substitution = tuple[Word, ...]
Matrix = tuple[tuple[int, ...], ...]


@dataclass(frozen=True)
class DirectiveShift:
    """A sofic directive shift: substitutions over one alphabet and a
    deterministic automaton over their labels (`transitions[q][label]` is the
    target state, -1 when the label is forbidden from `q`)."""

    name: str
    substitutions: tuple[Substitution, ...]
    transitions: tuple[tuple[int, ...], ...]
    initial: int

    @property
    def size(self) -> int:
        return len(self.substitutions[0])

    @property
    def labels(self) -> int:
        return len(self.substitutions)

    def run(self, word: Word, state: int) -> int:
        for label in word:
            if state < 0:
                break
            state = self.transitions[state][label]
        return state

    def admits(self, word: Word) -> bool:
        return self.run(word, self.initial) >= 0

    def admits_somewhere(self, word: Word) -> bool:
        return any(self.run(word, q) >= 0 for q in range(len(self.transitions)))


def full_shift(name: str, substitutions: tuple[Substitution, ...]) -> DirectiveShift:
    return DirectiveShift(name, substitutions, (tuple(0 for _ in substitutions),), 0)


def arnoux_rauzy(d: int) -> DirectiveShift:
    """BST19 (3.1): `alpha_i(i) = i`, `alpha_i(j) = j i` for `j != i`; full
    shift on d labels."""
    subs = tuple(tuple((i,) if j == i else (j, i) for j in range(d)) for i in range(d))
    return full_shift(f"arnoux-rauzy-{d}", subs)


def brun3() -> DirectiveShift:
    """BST19 (3.4): the Brun substitutions `beta_1, beta_2, beta_3`, whose
    incidence matrices are the linear Brun matrices (3.3); full shift on 3
    labels."""
    subs = (
        ((0,), (1, 2), (2,)),
        ((0,), (2,), (1, 2)),
        ((2,), (0,), (1, 2)),
    )
    return full_shift("brun-3", subs)


def apply(sigma: Substitution, word: Word) -> Word:
    return tuple(x for a in word for x in sigma[a])


def compose(outer: Substitution, inner: Substitution) -> Substitution:
    return tuple(apply(outer, img) for img in inner)


def compose_all(shift: DirectiveShift, word: Word) -> Substitution:
    return reduce(compose, (shift.substitutions[x] for x in word))


def image(shift: DirectiveShift, word: Word, letter: int) -> Word:
    out: Word = (letter,)
    for x in reversed(word):
        out = apply(shift.substitutions[x], out)
    return out


def incidence(sigma: Substitution) -> Matrix:
    d = len(sigma)
    return tuple(tuple(sigma[j].count(i) for j in range(d)) for i in range(d))


def matmul(a: Matrix, b: Matrix) -> Matrix:
    return tuple(tuple(sum(x * y for x, y in zip(row, col)) for col in zip(*b)) for row in a)


def identity(d: int) -> Matrix:
    return tuple(tuple(int(i == j) for j in range(d)) for i in range(d))


def prefix_matrix(shift: DirectiveShift, word: Word) -> Matrix:
    """`M_{w_0} ... M_{w_{n-1}}`; the identity for the empty word."""
    return reduce(matmul, (incidence(shift.substitutions[x]) for x in word), identity(shift.size))


def is_positive(m: Matrix) -> bool:
    return all(x > 0 for row in m for x in row)


def admissible_words(shift: DirectiveShift, n: int) -> list[Word]:
    """Words of length n labelling a path from the initial state, in
    lexicographic order."""
    return [w for w in product(range(shift.labels), repeat=n) if shift.admits(w)]


def positive_blocks(shift: DirectiveShift, max_len: int) -> list[Word]:
    """Words of length <= max_len, admissible from some state, with a strictly
    positive product and no proper prefix with one; by length, then
    lexicographically."""
    out = []
    for n in range(1, max_len + 1):
        for w in product(range(shift.labels), repeat=n):
            # a non-erasing factor keeps a positive product positive, so
            # minimality only needs the longest proper prefix
            minimal = n == 1 or not is_positive(prefix_matrix(shift, w[:-1]))
            if minimal and shift.admits_somewhere(w) and is_positive(prefix_matrix(shift, w)):
                out.append(w)
    return out


def first_positive_prefix(shift: DirectiveShift, word: Word) -> int:
    """The least n >= 1 with M_{w[:n]} > 0, or -1."""
    for n in range(1, len(word) + 1):
        if is_positive(prefix_matrix(shift, word[:n])):
            return n
    return -1


def cross_ratio_bound(m: Matrix) -> Fraction:
    """`Theta(M) = max m_ij m_kl / (m_il m_kj)` for a positive matrix: the
    exponential of the Hilbert-metric diameter of `M R^d_+`."""
    if not is_positive(m):
        raise ValueError("cross-ratio bound needs a strictly positive matrix")
    d = len(m)
    return max(Fraction(m[i][j] * m[k][l], m[i][l] * m[k][j])
               for i in range(d) for j in range(d) for k in range(d) for l in range(d))


@dataclass(frozen=True)
class BalanceWitness:
    """`value = |u|_letter - |v|_letter` for the factors `u = w[start_hi:+length]`
    and `v = w[start_lo:+length]`: the first maximal pair in (length, letter,
    position) order; all zero when no two factors differ."""

    value: int
    length: int
    letter: int
    start_hi: int
    start_lo: int


def balance(word: Word, size: int) -> BalanceWitness:
    """The balance of a finite word: the maximum over equal-length factors
    `u, v` and letters `a` of `|u|_a - |v|_a`, with a witness."""
    n = len(word)
    prefix = [[0] * (n + 1) for _ in range(size)]
    for a in range(size):
        for p, x in enumerate(word):
            prefix[a][p + 1] = prefix[a][p] + (x == a)
    best = BalanceWitness(0, 0, 0, 0, 0)
    for length in range(1, n + 1):
        for a in range(size):
            counts = [prefix[a][s + length] - prefix[a][s] for s in range(n - length + 1)]
            hi, lo = max(counts), min(counts)
            if hi - lo > best.value:
                best = BalanceWitness(hi - lo, length, a, counts.index(hi), counts.index(lo))
    return best


def image_balance(shift: DirectiveShift, word: Word, letter: int) -> int:
    """The balance of `sigma_w(letter)`: a lower bound on the balance constant
    of the language of every directive sequence with prefix `w`."""
    return balance(image(shift, word, letter), shift.size).value
