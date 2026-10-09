"""A substitution-local upper bound on the least strong-coincidence level.

This module extracts the quantitative statement that follows from the affine
coincidence automaton without promoting it to a uniform family theorem.  If the
language for a letter pair is nonempty, a shortest accepting run is simple, so
its length is at most the number of coaccessible automaton states minus one.
The graph computation (`PairDepthBound`, `coaccessible_state_count`,
`depth_bound`) is `substitution_dynamics.strong_coincidence`; the automaton is
`psc.coincidence_formula`'s.

The graph inequality is unconditional, but the executable construction is
exact only when the shared powered-field kernel accepts the input; that kernel
currently has a documented incidence-entry bound of 64 and raises outside it.
Such a refusal is inconclusive. Uniform use over the alphabet-three PIP family
therefore also requires removal of that implementation boundary, as well as a
substitution-independent coaccessible-state bound and a proof of nonemptiness.
"""

from psc.coincidence_formula import coincidence_automaton
from psc.words import ALPHABET
from substitution_dynamics.strong_coincidence import (
    PairDepthBound,
    coaccessible_state_count,
    depth_bound,
    worst_depth_bound,
)


def pair_depth_bound(
    sigma: List[List[Int]], top: Int, bottom: Int
) raises -> PairDepthBound:
    """Build the complete reachable affine automaton for one pair and read off
    its bound: when the language is nonempty, the shortest level is at most
    `coaccessible - 1`.

    The shared exact field constructor currently raises when an incidence entry
    exceeds 64. That is an explicit executable-domain refusal, not a negative
    coincidence result and not a restriction in the mathematical proposition.
    """
    return depth_bound(coincidence_automaton(sigma, top, bottom))


def substitution_depth_bound(sigma: List[List[Int]]) raises -> PairDepthBound:
    """The maximum fixed-substitution bound over the three unordered pairs.

    `empty` records whether some pair language is empty.  In that case
    `level = -1`; the state bound remains diagnostic and is not a coincidence
    theorem.
    """
    var pairs = List[PairDepthBound]()
    for top in range(ALPHABET):
        for bottom in range(top + 1, ALPHABET):
            pairs.append(pair_depth_bound(sigma, top, bottom))
    return worst_depth_bound(pairs)
