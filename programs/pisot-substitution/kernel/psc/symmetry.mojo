"""Alphabet-3 view of `substitution_dynamics.symmetry` for the PSC kernel.

The relabelling and reversal normal forms of words, pairs and substitutions
are the package's, over an explicit alphabet; this module binds the pair
orbit and key parsing to `ALPHABET = 3`. `word_key` stays local: it is the
plain decimal concatenation reports use for any integer list (cycle lengths,
counts), not only for letters, so it must not adopt the package's bracketed
letter tokens. A substitution carries its own
alphabet, so the substitution normal forms are re-exported unchanged.
Catalogue taxonomies quote orbits under these actions with the
lexicographically least element of the orbit as representative.
"""

from substitution_dynamics.symmetry import (
    canonical_substitution,
    conjugated_substitution,
    inverse_permutation,
    normalised_pair,
    pair_less,
    permutations,
    relabel,
    relabelled_pair,
    reversed_pair,
    reversed_substitution,
    reversed_word,
    substitution_key,
    substitution_less,
    word_less,
)
from substitution_dynamics import symmetry as sd
from psc.words import ALPHABET, Pair


def permutations3() -> List[List[Int]]:
    """The six permutations of `{0,1,2}`, lexicographically."""
    return permutations(ALPHABET)


def canonical_pair(p: Pair) -> Pair:
    """Least normalised relabelling of `p` over `{0,1,2}`."""
    return sd.canonical_pair(p, ALPHABET)


def parse_substitution_key(key: String) raises -> List[List[Int]]:
    """Inverse of `substitution_key`; exactly three images over `0..2`."""
    return sd.parse_substitution_key(key, ALPHABET)


def word_key(w: List[Int]) -> String:
    """Decimal concatenation of the entries; a letter key on `{0,1,2}`."""
    var s = String("")
    for i in range(len(w)):
        s += String(w[i])
    return s
