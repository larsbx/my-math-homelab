"""Seed-relative occurrence multiplicities for the overlap graph.

The adjacency of ``SeedOverlapAutomaton`` is a multiple-edge adjacency:
repeated child overlap types at different pairs of prefix positions remain
distinct entries.  Starting with the actual overlaps in one inherited period
of each swap seed, the update below therefore counts actual noncoincident
overlap occurrences in the iterated periodic patches.

Coincidence vertices are terminal in the seed-patch graph.  These routines
accordingly count the residual noncoincident occurrences only; they must not
be presented as counts of all geometric overlaps after a coincidence.
"""

from psc.overlap_seed_patch import (
    SeedOverlapAutomaton,
    SeedOverlapTables,
    seed_overlap_states,
)


struct OccurrenceMultiplicity(Copyable, Movable):
    var level: Int
    var counts: List[Int]
    var max_count: Int

    def __init__(out self, level: Int, counts: List[Int], max_count: Int):
        self.level = level
        self.counts = counts.copy()
        self.max_count = max_count

    def total(self) raises -> Int:
        var out = 0
        for i in range(len(self.counts)):
            out = _checked_add_bounded(out, self.counts[i], self.max_count)
        return out


def _checked_add_bounded(a: Int, b: Int, max_count: Int) raises -> Int:
    if a < 0 or b < 0 or max_count < 0:
        raise Error("occurrence multiplicities require nonnegative counts")
    if a > max_count - b:
        raise Error("occurrence multiplicity exceeded its exact count cap")
    return a + b


def seed_occurrence_multiplicity(
    tables: SeedOverlapTables, graph: SeedOverlapAutomaton, max_count: Int
) raises -> OccurrenceMultiplicity:
    """Multiplicity of graph states in one inherited period of all swap seeds."""
    if graph.capped:
        raise Error("occurrence multiplicity is undefined for a capped graph")
    if max_count < 1:
        raise Error("occurrence multiplicity needs a positive exact count cap")
    var counts = List[Int]()
    for _ in range(graph.size()):
        counts.append(0)
    var seeds = seed_overlap_states(tables)
    for k in range(len(seeds)):
        var found = -1
        for i in range(graph.size()):
            if graph.states[i] == seeds[k]:
                found = i
                break
        if found < 0:
            raise Error("swap-seed occurrence is absent from the seed-patch graph")
        counts[found] = _checked_add_bounded(counts[found], 1, max_count)
    return OccurrenceMultiplicity(0, counts, max_count)


def inflate_occurrence_multiplicity(
    graph: SeedOverlapAutomaton,
    current: OccurrenceMultiplicity,
    max_count: Int,
) raises -> OccurrenceMultiplicity:
    """Apply one exact multiple-edge update to residual occurrence counts."""
    if graph.capped:
        raise Error("occurrence multiplicity is undefined for a capped graph")
    if len(current.counts) != graph.size():
        raise Error("occurrence count vector disagrees with overlap graph size")
    if current.level < 0:
        raise Error("occurrence multiplicity level must be nonnegative")
    if current.max_count != max_count:
        raise Error("occurrence multiplicity exact count cap changed between levels")
    var next = List[Int]()
    for _ in range(graph.size()):
        next.append(0)
    for parent in range(graph.size()):
        var multiplicity = current.counts[parent]
        if multiplicity < 0:
            raise Error("occurrence multiplicity cannot be negative")
        # Coincidences are terminal by contract.  Every repeated adjacency
        # entry is a distinct geometric child occurrence and is counted.
        for e in range(len(graph.adj[parent])):
            var child = graph.adj[parent][e]
            if child < 0 or child >= graph.size():
                raise Error("overlap adjacency leaves the graph")
            next[child] = _checked_add_bounded(next[child], multiplicity, max_count)
    return OccurrenceMultiplicity(current.level + 1, next, max_count)


def occurrence_multiplicity_at_level(
    tables: SeedOverlapTables,
    graph: SeedOverlapAutomaton,
    level: Int,
    max_count: Int = 1_000_000_000,
) raises -> OccurrenceMultiplicity:
    """Residual state multiplicities after ``level`` substitutions.

    ``max_count`` is an explicit exactness budget.  Exhausting it raises; it
    never wraps a machine integer into false finite evidence.
    """
    if level < 0:
        raise Error("occurrence multiplicity level must be nonnegative")
    var out = seed_occurrence_multiplicity(tables, graph, max_count)
    for _ in range(level):
        out = inflate_occurrence_multiplicity(graph, out, max_count)
    return out^
