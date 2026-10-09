"""System-level Barge-Diamond good-edge compatibility for strict components.

This module bridges the endpoint-only first-child phase classifier to an actual
integer-indexed `DerivedSystem`. For each of the three possible unordered good
edges G it checks two necessary conditions for a strict PIP component:

1. every normalized state's first-letter pair is viable under the deterministic
   prefix endpoint map while avoiding G;
2. the actual first-child occurrence in the derived factorization has the same
   hub-residual bit as the endpoint-only selector phase q_+(h,G).

Barge-Diamond guarantees that a genuine strict PIP component has at least one
actual eventually-coincident letter pair. Therefore its candidate-good-edge
mask computed here must be nonzero. The finite kernel itself does not assert
that a surviving candidate is genuinely eventually coincident.

`DerivedSystem` is intentionally a public data structure, so every public
classifier validates its full strict-system contract before any candidate-level
early return. Malformed graph data must fail closed rather than masquerade as a
mathematical obstruction.
"""

from psc.bd_endpoint import complementary_hub_letter
from psc.bpa import coincidence_boundaries
from psc.words import is_balanced
from psc.derived_system import DerivedSystem
from psc.hub_cocycle import build_hub_cocycle
from psc.hub_selector import strict_star_pair_viable, strict_star_selector_phase


def _good_edge_letters(edge_id: Int) raises -> List[Int]:
    if edge_id == 0:
        return [0, 1]
    if edge_id == 1:
        return [0, 2]
    if edge_id == 2:
        return [1, 2]
    raise Error("good-edge id must lie in 0..2")


def _validate_endpoint_map(h: List[Int]) raises:
    if len(h) != 3:
        raise Error("prefix endpoint map must have exactly three letters")
    for i in range(3):
        if h[i] < 0 or h[i] >= 3:
            raise Error("prefix endpoint map value lies outside 0..2")


def _validate_strict_derived_system(system: DerivedSystem) raises:
    """Fail closed unless `system` satisfies the strict derived-system contract."""
    var n = system.size()
    if n <= 0:
        raise Error("derived system must be nonempty")
    if len(system.images) != n:
        raise Error("derived image array count does not match state count")
    if len(system.child_signs) != n:
        raise Error("derived child-sign array count does not match state count")
    if len(system.block_lengths) != n:
        raise Error("derived block-length array count does not match state count")

    for src in range(n):
        ref state = system.states[src]
        if state.length() <= 0:
            raise Error("strict state must be nonempty")
        if not is_balanced(state):
            raise Error("strict derived system contains an unbalanced state")
        if state.is_coincidence():
            raise Error("strict derived system contains a coincidence state")
        var boundaries = coincidence_boundaries(state.u, state.v)
        if len(boundaries) != 2 or boundaries[0] != 0 or boundaries[1] != state.length():
            raise Error("strict derived system contains a reducible balanced state")
        if system.block_lengths[src] != state.length():
            raise Error("derived block length does not match state length")
        if len(system.images[src]) == 0:
            raise Error("strict state has no derived children")
        if len(system.child_signs[src]) != len(system.images[src]):
            raise Error("derived child/sign arrays disagree")

        for j in range(len(system.images[src])):
            var dst = system.images[src][j]
            if dst < 0 or dst >= n:
                raise Error("derived child state ID out of range")
            var sign = system.child_signs[src][j]
            if sign != 1 and sign != -1:
                raise Error("derived child orientation must be +/-1")


def _candidate_good_edge_phase_validated(
    system: DerivedSystem, h: List[Int], edge_id: Int
) raises -> Int:
    """Candidate phase after endpoint/system validation has already succeeded."""
    var good = _good_edge_letters(edge_id)
    var phase = strict_star_selector_phase(h, good[0], good[1])
    if phase < 0 or phase > 1:
        return -1

    # Reject endpoint-incompatible candidates before constructing the hub gauge.
    # Otherwise a state using the proposed good edge would fail the hub-presence
    # invariant with an exception instead of being classified as a rejected
    # candidate.
    for src in range(system.size()):
        ref state = system.states[src]
        var a = state.u[0]
        var b = state.v[0]
        if not strict_star_pair_viable(h, good[0], good[1], a, b):
            return -1

    var hub = complementary_hub_letter(good[0], good[1])
    var cocycle = build_hub_cocycle(system, hub)

    for src in range(system.size()):
        if len(cocycle.residual_bits[src]) != len(system.images[src]):
            raise Error("hub residual/image lengths disagree")
        if cocycle.residual_bits[src][0] != phase:
            return -1
    return phase


def candidate_good_edge_phase(
    system: DerivedSystem, h: List[Int], edge_id: Int
) raises -> Int:
    """Return the common first-child phase for one system-level candidate.

    Return values:
      -1 : the edge cannot be the Barge-Diamond-good edge for this strict system;
       0/1: all state first pairs are viable and every actual first child realizes
            the endpoint-only selector phase.

    This is a necessary compatibility test, not a proof of eventual coincidence.
    """
    _validate_endpoint_map(h)
    _validate_strict_derived_system(system)
    return _candidate_good_edge_phase_validated(system, h, edge_id)


def candidate_good_edge_mask(system: DerivedSystem, h: List[Int]) raises -> Int:
    """Three-bit mask of good-edge placements compatible with the whole system."""
    _validate_endpoint_map(h)
    _validate_strict_derived_system(system)
    var mask = 0
    for edge_id in range(3):
        if _candidate_good_edge_phase_validated(system, h, edge_id) >= 0:
            mask |= 1 << edge_id
    return mask


def candidate_good_edge_count(system: DerivedSystem, h: List[Int]) raises -> Int:
    var mask = candidate_good_edge_mask(system, h)
    var count = 0
    for edge_id in range(3):
        if (mask & (1 << edge_id)) != 0:
            count += 1
    return count


def unique_candidate_hub(system: DerivedSystem, h: List[Int]) raises -> Int:
    """Return the forced hub when exactly one candidate good edge survives.

    Returns -1 when there are zero or multiple candidates.
    """
    var mask = candidate_good_edge_mask(system, h)
    var found = -1
    for edge_id in range(3):
        if (mask & (1 << edge_id)) == 0:
            continue
        if found != -1:
            return -1
        found = edge_id
    if found == -1:
        return -1
    var good = _good_edge_letters(found)
    return complementary_hub_letter(good[0], good[1])
