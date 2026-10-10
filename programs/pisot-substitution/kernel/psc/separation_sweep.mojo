"""Bounded separation survey using the already reviewed occurrence contract.

A proper-power witness is a structural nonseparation result, not a radius-cap
failure. Otherwise every radius 0..12 is searched; an exhausted bound refuses
completion. No general theorem is inferred from the survey.
"""
from psc.overlap_collar import collapsing_seed_pair_count, separation_radius
from psc.overlap_seed_patch import SeedOverlapTables, SeedOverlapAutomaton
from psc.symmetry import canonical_substitution, reversed_substitution, substitution_less, substitution_key

comptime SEPARATION_RADIUS_CAP = 12
comptime COLLARED_STATE_CAP = 2000000
comptime COLLAPSE_LEVEL_CAP = 6


def orbit_key(sigma: List[List[Int]]) -> String:
    var forward = canonical_substitution(sigma)
    var backward = canonical_substitution(reversed_substitution(sigma))
    return substitution_key(backward) if substitution_less(backward, forward) else substitution_key(forward)


def classify_separation(
    tables: SeedOverlapTables,
    graph: SeedOverlapAutomaton,
    radius_cap: Int = SEPARATION_RADIUS_CAP,
    state_cap: Int = COLLARED_STATE_CAP,
) raises -> Int:
    """Nonnegative: exact least radius; -1: proper-power obstruction.

    Resource exhaustion raises, never returns the obstruction sentinel.
    The witness search is bounded; its absence is not a mathematical verdict.
    """
    if radius_cap < 0 or state_cap <= 0:
        raise Error("invalid separation survey budget")
    if graph.capped:
        raise Error("capped overlap graph cannot support separation evidence")
    if collapsing_seed_pair_count(tables.sigma, COLLAPSE_LEVEL_CAP) > 0:
        return -1
    var radius = separation_radius(tables, graph, radius_cap, state_cap)
    if radius < 0:
        raise Error("unresolved collision at separation radius cap")
    return radius
