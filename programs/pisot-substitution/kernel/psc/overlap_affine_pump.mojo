"""Exact occurrence-labelled affine pumps for the strict overlap zipper.

For an actual ordered child occurrence the offset obeys

    w' = beta*w + q - p,

where ``p`` and ``q`` are the top and bottom proper-prefix lengths.  In the
integral power basis this is the integer-coordinate form of the incidence
recurrence ``w' = M w + q - p``.  Certificates retain occurrence ordinals and
both child indices, so repeated child types are never collapsed.

Extraction and replay are finite diagnostics.  A certified cycle need not be
child-closed or nonproductive and is not a universal counterexample.
"""

from psc.overlap_recurrence import zero_shift_free_recurrent_sccs
from psc.overlap_seed_patch import OverlapState, SeedOverlapAutomaton, SeedOverlapTables
from psc.overlap_zipper import ordered_child_occurrences
from psc.perron_field3 import (
    CubicElt,
    cubic_add_checked,
    cubic_mul_beta,
    cubic_sub_checked,
)


struct AffineOccurrenceEdge(Copyable, Movable):
    var parent_index: Int
    var occurrence_ordinal: Int
    var child_index: Int
    var top_child_index: Int
    var bottom_child_index: Int
    var top_prefix: CubicElt
    var bottom_prefix: CubicElt
    var forcing: CubicElt

    def __init__(
        out self,
        parent_index: Int,
        occurrence_ordinal: Int,
        child_index: Int,
        top_child_index: Int,
        bottom_child_index: Int,
        top_prefix: CubicElt,
        bottom_prefix: CubicElt,
        forcing: CubicElt,
    ):
        self.parent_index = parent_index
        self.occurrence_ordinal = occurrence_ordinal
        self.child_index = child_index
        self.top_child_index = top_child_index
        self.bottom_child_index = bottom_child_index
        self.top_prefix = top_prefix
        self.bottom_prefix = bottom_prefix
        self.forcing = forcing


struct AffinePumpCertificate(Copyable, Movable):
    var state_indices: List[Int]
    var edges: List[AffineOccurrenceEdge]

    def __init__(
        out self, state_indices: List[Int], edges: List[AffineOccurrenceEdge]
    ):
        self.state_indices = state_indices.copy()
        self.edges = edges.copy()


def _state_index(
    a: SeedOverlapAutomaton, state_index_hint: Int, state: OverlapState
) raises -> Int:
    # The hint is normally supplied by the graph adjacency and makes the hot
    # path constant-time.  Equality is still checked fail-closed.
    if state_index_hint >= 0 and state_index_hint < a.size():
        if a.states[state_index_hint] == state:
            return state_index_hint
    for i in range(a.size()):
        if a.states[i] == state:
            return i
    raise Error("ordered child occurrence is absent from the seed-patch graph")


def occurrence_edges(
    tables: SeedOverlapTables, a: SeedOverlapAutomaton, parent_index: Int
) raises -> List[AffineOccurrenceEdge]:
    """Return all actual child occurrences in prefix-grid order."""
    if a.capped:
        raise Error("affine occurrence edges are undefined for a capped graph")
    if parent_index < 0 or parent_index >= a.size():
        raise Error("affine occurrence parent index is out of range")
    var parent = a.states[parent_index]
    var out = List[AffineOccurrenceEdge]()
    if parent.is_coincidence():
        return out^
    var occurrences = ordered_child_occurrences(tables, parent)
    for ordinal in range(len(occurrences)):
        var occurrence = occurrences[ordinal]
        var top_prefix = tables.prefix(parent.top, occurrence.top_index)
        var bottom_prefix = tables.prefix(parent.bottom, occurrence.bottom_index)
        var forcing = cubic_sub_checked(bottom_prefix, top_prefix)
        var expected = cubic_add_checked(
            cubic_mul_beta(tables.field, parent.shift), forcing
        )
        if occurrence.state.shift != expected:
            raise Error("ordered child violates the exact affine offset recurrence")
        var hint = -1
        if ordinal < len(a.adj[parent_index]):
            hint = a.adj[parent_index][ordinal]
        var child_index = _state_index(a, hint, occurrence.state)
        out.append(
            AffineOccurrenceEdge(
                parent_index,
                ordinal,
                child_index,
                occurrence.top_index,
                occurrence.bottom_index,
                top_prefix,
                bottom_prefix,
                forcing,
            )
        )
    return out^


def first_zero_shift_free_affine_pump(
    tables: SeedOverlapTables, a: SeedOverlapAutomaton
) raises -> List[AffinePumpCertificate]:
    """Return zero or one deterministic occurrence-labelled cycle."""
    if a.capped:
        raise Error("affine pump extraction is undefined for a capped graph")
    var components = zero_shift_free_recurrent_sccs(a)
    if len(components) == 0:
        return List[AffinePumpCertificate]()
    ref component = components[0]
    var member = List[Bool]()
    var seen = List[Int]()
    for _ in range(a.size()):
        member.append(False)
        seen.append(-1)
    var current = component[0]
    for i in range(len(component)):
        member[component[i]] = True
        if component[i] < current:
            current = component[i]

    var states = List[Int]()
    var edges = List[AffineOccurrenceEdge]()
    while seen[current] < 0:
        seen[current] = len(states)
        states.append(current)
        var candidates = occurrence_edges(tables, a, current)
        var found = False
        for i in range(len(candidates)):
            if member[candidates[i].child_index]:
                edges.append(candidates[i].copy())
                current = candidates[i].child_index
                found = True
                break
        if not found:
            raise Error("recurrent component has no internal occurrence edge")

    var start = seen[current]
    var cycle_states = List[Int]()
    var cycle_edges = List[AffineOccurrenceEdge]()
    for i in range(start, len(states)):
        cycle_states.append(states[i])
        cycle_edges.append(edges[i].copy())
    var out = List[AffinePumpCertificate]()
    out.append(AffinePumpCertificate(cycle_states, cycle_edges))
    return out^


def verify_affine_pump(
    tables: SeedOverlapTables,
    a: SeedOverlapAutomaton,
    certificate: AffinePumpCertificate,
) raises -> Bool:
    """Replay occurrence order and the exact iterated affine cycle identity."""
    if a.capped:
        raise Error("affine pump verification is undefined for a capped graph")
    var n = len(certificate.state_indices)
    if n == 0 or n != len(certificate.edges):
        return False
    var shift = a.states[certificate.state_indices[0]].shift
    for k in range(n):
        var parent_index = certificate.state_indices[k]
        var child_index = certificate.state_indices[(k + 1) % n]
        var edge = certificate.edges[k].copy()
        if edge.parent_index != parent_index or edge.child_index != child_index:
            return False
        var actual = occurrence_edges(tables, a, parent_index)
        if edge.occurrence_ordinal < 0 or edge.occurrence_ordinal >= len(actual):
            return False
        var replay = actual[edge.occurrence_ordinal].copy()
        if (
            replay.child_index != edge.child_index
            or replay.top_child_index != edge.top_child_index
            or replay.bottom_child_index != edge.bottom_child_index
            or replay.top_prefix != edge.top_prefix
            or replay.bottom_prefix != edge.bottom_prefix
            or replay.forcing != edge.forcing
        ):
            return False
        shift = cubic_add_checked(
            cubic_mul_beta(tables.field, shift), edge.forcing
        )
        if shift != a.states[child_index].shift or shift.is_zero():
            return False
    return shift == a.states[certificate.state_indices[0]].shift
