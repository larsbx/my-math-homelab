"""Tier-2 exact gain fixtures built from existing PSC overlap machinery.

This module is an adapter, not a spectral theorem.

The first channel exported here is 'affine_forcing': for an ordered overlap
occurrence with exact recurrence

    w' = beta*w + q - p,

the edge gain is the cubic field element q - p already stored as
AffineOccurrenceEdge.forcing.

No claim is made that 'affine_forcing' is the Penrose exact-prefix cocycle
Phi from the Growth Bridge notes. A future Penrose adapter must name that
channel separately and prove its own interpretation.

Fixtures retain occurrence multiplicity and global overlap-state indices.
Only edges whose source and target both lie in the selected component are
included. Capped graphs are rejected.
"""

from psc.overlap_affine_pump import occurrence_edges
from psc.overlap_recurrence import zero_shift_free_recurrent_sccs
from psc.overlap_seed_patch import SeedOverlapAutomaton, SeedOverlapTables
from psc.perron_field3 import CubicElt


struct Tier2CubicGainEdge(Copyable, Movable):
    var source_index: Int
    var target_index: Int
    var occurrence_ordinal: Int
    var gain: CubicElt

    def __init__(
        out self,
        source_index: Int,
        target_index: Int,
        occurrence_ordinal: Int,
        gain: CubicElt,
    ):
        self.source_index = source_index
        self.target_index = target_index
        self.occurrence_ordinal = occurrence_ordinal
        self.gain = gain


struct Tier2CubicGainFixture(Copyable, Movable):
    var gain_channel: String
    var state_indices: List[Int]
    var edges: List[Tier2CubicGainEdge]

    def __init__(
        out self,
        gain_channel: String,
        state_indices: List[Int],
        edges: List[Tier2CubicGainEdge],
    ):
        self.gain_channel = gain_channel
        self.state_indices = state_indices.copy()
        self.edges = edges.copy()


def cubic_gain_coordinates(gain: CubicElt) -> List[Int]:
    """Coordinates in the integral power basis (1, beta, beta^2)."""
    return [gain.a0, gain.a1, gain.a2]


def affine_forcing_fixture_for_component(
    tables: SeedOverlapTables,
    a: SeedOverlapAutomaton,
    component: List[Int],
) raises -> Tier2CubicGainFixture:
    if a.capped:
        raise Error("Tier-2 gain fixtures are undefined for a capped overlap graph")
    if len(component) == 0:
        raise Error("Tier-2 gain fixture requires a nonempty component")

    var member = List[Bool]()
    for _ in range(a.size()):
        member.append(False)

    for k in range(len(component)):
        var state_index = component[k]
        if state_index < 0 or state_index >= a.size():
            raise Error("Tier-2 component state index is out of range")
        if member[state_index]:
            raise Error("Tier-2 component contains a duplicate state index")
        member[state_index] = True

    # Canonical state order is graph-index order, independent of the SCC
    # algorithm's output order.
    var states = List[Int]()
    for state_index in range(a.size()):
        if member[state_index]:
            states.append(state_index)

    var edges = List[Tier2CubicGainEdge]()
    for source_index in range(a.size()):
        if not member[source_index]:
            continue
        var occurrences = occurrence_edges(tables, a, source_index)
        for j in range(len(occurrences)):
            var edge = occurrences[j].copy()
            if not member[edge.child_index]:
                continue
            edges.append(
                Tier2CubicGainEdge(
                    source_index,
                    edge.child_index,
                    edge.occurrence_ordinal,
                    edge.forcing,
                )
            )

    if len(edges) == 0:
        raise Error("Tier-2 recurrent component fixture contains no internal occurrence edge")
    return Tier2CubicGainFixture("affine_forcing", states, edges)


def zero_shift_free_affine_forcing_fixtures(
    tables: SeedOverlapTables,
    a: SeedOverlapAutomaton,
) raises -> List[Tier2CubicGainFixture]:
    if a.capped:
        raise Error("Tier-2 gain fixtures are undefined for a capped overlap graph")
    var components = zero_shift_free_recurrent_sccs(a)
    var out = List[Tier2CubicGainFixture]()
    for i in range(len(components)):
        out.append(
            affine_forcing_fixture_for_component(tables, a, components[i])
        )
    return out^
