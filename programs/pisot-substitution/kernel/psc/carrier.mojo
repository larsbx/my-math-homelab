"""Taxonomy of the recurrent noncoincident components of `B_sigma`.

A recurrent noncoincident SCC is classified by two exact edge facts:

* `direct_coincidence`: some state has a coincidence child;
* `noncoincident_exit`: some state has a noncoincident child outside the SCC.

A *sink* SCC has no noncoincident exit; a *closed nonproductive* (strict
carrier) SCC has neither fact, and is the only shape a counterexample to
productivity can take. `carrier_flags` lifts the classification to per-state
recurrent/sink masks; `emit_countermodel` prints a replayable exact record of
a survivor before any summary can fail closed. Membership is decided through a
mask over the automaton, never by scanning the component per edge.

Boundary synchronization (`SyncProfile`) records whether a state's newborn or
inherited zero-return cuts synchronize through the endpoint maps; these are
the C3 lineage diagnostics of `psc.bpa`.
"""

from substitution_dynamics.automaton import Automaton
from psc.bpa import inherited_sync_positions, newborn_sync_positions
from psc.words import Pair


struct ComponentProfile(Copyable, Movable):
    var size: Int
    var direct_coincidence: Bool
    var noncoincident_exit: Bool

    def __init__(out self, size: Int, direct_coincidence: Bool, noncoincident_exit: Bool):
        self.size = size
        self.direct_coincidence = direct_coincidence
        self.noncoincident_exit = noncoincident_exit

    def is_sink(self) -> Bool:
        return not self.noncoincident_exit

    def is_closed_nonproductive(self) -> Bool:
        """The strict-carrier condition: no coincidence child, no exit."""
        return not self.direct_coincidence and not self.noncoincident_exit


def member_mask(size: Int, comp: List[Int]) -> List[Bool]:
    var mask = List[Bool](length=size, fill=False)
    for s in range(len(comp)):
        mask[comp[s]] = True
    return mask^


def profile_component(a: Automaton, comp: List[Int]) -> ComponentProfile:
    """Both edge facts in one pass over the component's out-edges."""
    var inside = member_mask(a.size(), comp)
    var direct = False
    var exit = False
    for s in range(len(comp)):
        ref edges = a.adj[comp[s]]
        for e in range(len(edges)):
            var child = edges[e]
            if a.states[child].is_coincidence():
                direct = True
            elif not inside[child]:
                exit = True
    return ComponentProfile(len(comp), direct, exit)


struct CarrierFlags(Copyable, Movable):
    """Per-state masks: lies in a recurrent noncoincident SCC / in a sink SCC."""

    var recurrent: List[Bool]
    var sink: List[Bool]

    def __init__(out self, var recurrent: List[Bool], var sink: List[Bool]):
        self.recurrent = recurrent^
        self.sink = sink^


def carrier_flags(a: Automaton, comps: List[List[Int]]) -> CarrierFlags:
    var recurrent = List[Bool](length=a.size(), fill=False)
    var sink = List[Bool](length=a.size(), fill=False)
    for c in range(len(comps)):
        ref comp = comps[c]
        var is_sink = profile_component(a, comp).is_sink()
        for s in range(len(comp)):
            recurrent[comp[s]] = True
            if is_sink:
                sink[comp[s]] = True
    return CarrierFlags(recurrent^, sink^)


def has_coincidence_child(a: Automaton, state: Int) -> Bool:
    ref edges = a.adj[state]
    for e in range(len(edges)):
        if a.states[edges[e]].is_coincidence():
            return True
    return False


def productive_within_two(a: Automaton, state: Int) -> Bool:
    """A coincidence child or grandchild."""
    if has_coincidence_child(a, state):
        return True
    ref edges = a.adj[state]
    for e in range(len(edges)):
        if has_coincidence_child(a, edges[e]):
            return True
    return False


struct SyncProfile(Copyable, Movable):
    var newborn: Bool
    var inherited: Bool

    def __init__(out self, newborn: Bool, inherited: Bool):
        self.newborn = newborn
        self.inherited = inherited

    def clean_newborn(self) -> Bool:
        return self.newborn and not self.inherited

    def any(self) -> Bool:
        return self.newborn or self.inherited

    def join(self, other: SyncProfile) -> SyncProfile:
        return SyncProfile(self.newborn or other.newborn, self.inherited or other.inherited)


def state_sync(sigma: List[List[Int]], p: Pair) -> SyncProfile:
    return SyncProfile(
        len(newborn_sync_positions(sigma, p)) > 0,
        len(inherited_sync_positions(sigma, p)) > 0,
    )


def emit_countermodel(
    prefix: String, specimen_fields: String, comp_id: Int, a: Automaton, comp: List[Int]
):
    """Replayable exact record of a component: every state and every edge."""
    print(
        prefix + "_COUNTERMODEL_BEGIN {" + specimen_fields
        + ",\"component\":" + String(comp_id) + ",\"size\":" + String(len(comp)) + "}"
    )
    for s in range(len(comp)):
        var state = comp[s]
        print(prefix + "_COUNTERMODEL_STATE", state, a.states[state].key())
        ref edges = a.adj[state]
        for e in range(len(edges)):
            print(prefix + "_COUNTERMODEL_EDGE", state, edges[e])
    print(prefix + "_COUNTERMODEL_END")
