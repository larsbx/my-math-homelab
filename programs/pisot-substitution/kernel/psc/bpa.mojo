"""Alphabet-3 view of `substitution_dynamics` for the PSC kernel.

Substitutions enter as `List[List[Int]]` over `{0,1,2}` and are validated on
every call by `sigma3`; the automaton and component routines are the package
routines. `build` returns a `capped` flag and callers must treat a capped run
as inconclusive, never as a counterexample or a proof (hypothesis G1 is not
proved here); the component and productivity queries raise on a capped graph.

The boundary-lineage helpers instrument conjecture C3. They distinguish a
zero-return boundary inherited from the previous inflation from a genuinely
newborn boundary, and test synchronization through the finite prefix/suffix
endpoint maps. These are exact finite diagnostics, not a proof of C3.
"""

from std.os import abort

from substitution_dynamics import balanced_pairs as sd
from substitution_dynamics.automaton import Automaton, build as sd_build, has_cycle, is_noncoincident, nonproductive_states, recurrent_noncoincident_sccs, require_complete, sccs
from substitution_dynamics.balanced_pairs import normalise, sync_after
from substitution_dynamics.substitution import Substitution
from psc.words import ALPHABET, Pair


def sigma3(sigma: List[List[Int]]) -> Substitution:
    """Validate a three-letter substitution or abort (a malformed substitution
    is invalid input to the census, never a negative result)."""
    if len(sigma) != ALPHABET:
        abort("substitution must have exactly three letters")
    for a in range(ALPHABET):
        if len(sigma[a]) == 0:
            abort("substitution image is erasing")
        for j in range(len(sigma[a])):
            if sigma[a][j] < 0 or sigma[a][j] >= ALPHABET:
                abort("substitution letter lies outside 0..2")
    return Substitution(sigma.copy(), ALPHABET)


def apply_substitution(sigma: List[List[Int]], w: List[Int]) -> List[Int]:
    return sigma3(sigma).apply(w)


def inflate_pair(sigma: List[List[Int]], p: Pair) -> Pair:
    """Inflate both sides without cutting into irreducible balanced blocks."""
    return sd.inflate_pair(sigma3(sigma), p)


def coincidence_boundaries(u: List[Int], v: List[Int]) -> List[Int]:
    """Positions `0 = k_0 < ... < k_m = |u|` where the Parikh prefixes agree."""
    return sd.coincidence_boundaries(u, v, ALPHABET)


def image_prefix_lengths(sigma: List[List[Int]], w: List[Int]) -> List[Int]:
    """Image length of every prefix `w[:k]`, for `0 <= k <= |w|`."""
    return sigma3(sigma).image_prefix_lengths(w)


def inherited_boundary_positions(sigma: List[List[Int]], u: List[Int], v: List[Int]) -> List[Int]:
    """Next-step zero-return positions inherited from current zero-return cuts."""
    return sd.inherited_boundary_positions(sigma3(sigma), u, v)


def newborn_boundary_positions(sigma: List[List[Int]], p: Pair) -> List[Int]:
    """Zero-return cuts created by one inflation rather than inherited."""
    return sd.newborn_boundary_positions(sigma3(sigma), p)


def prefix_endpoint_map(sigma: List[List[Int]]) -> List[Int]:
    """`sigma_+(a)`: first letter of `sigma(a)`."""
    return sigma3(sigma).prefix_endpoint_map()


def suffix_endpoint_map(sigma: List[List[Int]]) -> List[Int]:
    """`sigma_-(a)`: last letter of `sigma(a)`."""
    return sigma3(sigma).suffix_endpoint_map()


def synchronizing_boundary_positions(
    sigma: List[List[Int]], u: List[Int], v: List[Int], positions: List[Int]
) -> List[Int]:
    """Subset of zero-return positions caught by prefix/suffix synchronization."""
    return sd.synchronizing_boundary_positions(sigma3(sigma), u, v, positions)


def newborn_sync_positions(sigma: List[List[Int]], p: Pair) -> List[Int]:
    """Newborn zero-return cuts whose adjacent endpoint pair synchronizes."""
    return sd.newborn_sync_positions(sigma3(sigma), p)


def inherited_sync_positions(sigma: List[List[Int]], p: Pair) -> List[Int]:
    """Inherited zero-return cuts whose adjacent endpoint pair synchronizes."""
    return sd.inherited_sync_positions(sigma3(sigma), p)


def decompose(u: List[Int], v: List[Int]) -> List[Pair]:
    """Cut a balanced pair into its irreducible balanced blocks."""
    return sd.decompose(u, v, ALPHABET)


def children(sigma: List[List[Int]], p: Pair) -> List[Pair]:
    return sd.children(sigma3(sigma), p)


def seed_states() -> List[Pair]:
    return sd.seed_states(ALPHABET)


def build(sigma: List[List[Int]], max_states: Int = 20000) raises -> Automaton:
    """Reachable part of `B_sigma`; `capped` means inconclusive."""
    return sd_build(Substitution.checked(sigma), max_states)


def substitution_incidence(sigma: List[List[Int]]) -> List[Int]:
    """`M[i][j]` = number of occurrences of letter `i` in `sigma(j)`, row-major."""
    return sigma3(sigma).incidence()
