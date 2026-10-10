"""Alphabet-3 view of `substitution_dynamics.words` for the PSC kernel.

Letters are zero-based (`0,1,2` for the alphabet `{1,2,3}`). `Pair` is the
package type; the invariants `K1, K2, K3` and balance are the package
functions bound to alphabet size three, so the `27`-coordinate `K3` matches
`psc.tensor3` lex indexing (`idx3(a, b, c) == 9a + 3b + c`).
"""

from substitution_dynamics.words import Pair, is_zero
from substitution_dynamics import words as sd

comptime ALPHABET = 3


def parikh(w: List[Int]) -> List[Int]:
    """`N_i(w)` for `i` in `{0,1,2}`."""
    return sd.parikh(w, ALPHABET)


def n2(w: List[Int]) -> List[Int]:
    """`N_{ij}(w)` flattened row-major into `Z^9`, streamed in O(n)."""
    return sd.n2(w, ALPHABET)


def n3(w: List[Int]) -> List[Int]:
    """`N_{ijk}(w)` in lex coordinates of `V^(x3)`, streamed in O(n)."""
    return sd.n3(w, ALPHABET)


def is_balanced(p: Pair) -> Bool:
    return sd.is_balanced(p, ALPHABET)


def k1(p: Pair) -> List[Int]:
    return sd.k1(p, ALPHABET)


def k2(p: Pair) -> List[Int]:
    return sd.k2(p, ALPHABET)


def k3(p: Pair) -> List[Int]:
    return sd.k3(p, ALPHABET)
