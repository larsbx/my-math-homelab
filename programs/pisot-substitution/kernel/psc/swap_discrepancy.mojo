"""Alphabet-3 view of `substitution_dynamics.discrepancy` (bounded discrepancy, G1b-1).

For a seed `(ab, ba)` and a level `n` the *swap walk* is the prefix-difference
walk of the inflated pair `(sigma^n(ab), sigma^n(ba))`; every state of
`B_sigma` is a zero-return block of some such pair, so

    Disc(T) <= max_j ||Delta_n(j)||_inf.

The bounded-discrepancy theorem
(sources/issue-45/g1b1-bounded-discrepancy-reconstruction.md)
proves that this supremum is uniformly bounded in `n`; the package only
evaluates it exactly, with a fixed three-coordinate accumulator and no
floating point.
"""

from substitution_dynamics import discrepancy as sd
from substitution_dynamics.discrepancy import max_reachable_discrepancy, max_state_length
from psc.bpa import sigma3
from psc.words import ALPHABET, Pair


def discrepancy(p: Pair) -> Int:
    """`max_k ||parikh(u[:k]) - parikh(v[:k])||_inf` over the prefixes of a balanced pair."""
    return sd.discrepancy(p, ALPHABET)


def iterate(sigma: List[List[Int]], w: List[Int], level: Int) -> List[Int]:
    """`sigma^level(w)`."""
    return sigma3(sigma).apply_n(w, level)


def swap_walk_sup(sigma: List[List[Int]], a: Int, b: Int, level: Int) -> Int:
    """`max_j ||Delta_level(j)||_inf` for the seed `(ab, ba)`."""
    return sd.swap_walk_sup(sigma3(sigma), a, b, level)


def swap_walk_profile(sigma: List[List[Int]], max_level: Int) -> List[Int]:
    """Entry `n` is the maximum over the three seeds of the level-`n` swap-walk supremum."""
    return sd.swap_walk_profile(sigma3(sigma), max_level)


def common_tile_count(sigma: List[List[Int]], a: Int, b: Int, level: Int) -> List[Int]:
    """[common tiles, all tiles] of the level-`level` swap pair `(ab, ba)`."""
    return sd.common_tile_count(sigma3(sigma), a, b, level)
