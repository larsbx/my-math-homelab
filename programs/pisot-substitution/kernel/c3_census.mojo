"""Exact one-step census for the C3 newborn-boundary mechanism.

Corpus: every primitive irreducible Pisot substitution on {0,1,2} whose three
images have length 1, 2 or 3, i.e. the same 4554-specimen corpus as census.mojo.

Why one step is the right finite unit. Decompose any balanced pair P at all of
its zero-return cuts into irreducible blocks t_j. Under one more inflation, the
images of the old cuts are exactly the inherited cuts. Therefore every newborn
cut of sigma(P) lies strictly between two consecutive inherited cuts, hence
inside sigma(t_j), and is a one-step newborn cut of that irreducible block.

Consequently, in the counterexample regime relevant to C1 -- a closed,
nonproductive recurrent SCC -- any higher-inflation newborn escape must already
appear as a one-step newborn escape from some state of that SCC. This program
therefore scans every state of every recurrent noncoincident SCC once, instead
of inflating whole pairs exponentially.

For SCCs with no boundary-synchronization witness of either lineage, the census
also distinguishes a direct coincidence sibling, a noncoincident escape edge,
and a genuinely closed/no-direct-coincidence obstruction candidate. Only the
last class is relevant to the closed-nonproductive counterexample regime.

The scan is finite evidence and a diagnostic for the locality reduction. It is
not a proof of G1, C1, C2, C3, or PSC.
"""

from substitution_dynamics.automaton import Automaton
from psc.bpa import build, recurrent_noncoincident_sccs
from psc.carrier import SyncProfile, profile_component, state_sync
from psc.corpus import STATE_CAP, pip_corpus


struct SyncTally(Copyable, Movable):
    """Counts of states by synchronization lineage inside one component."""

    var newborn: Int
    var inherited: Int
    var clean_newborn: Int

    def __init__(out self):
        self.newborn = 0
        self.inherited = 0
        self.clean_newborn = 0

    def profile(self) -> SyncProfile:
        return SyncProfile(self.newborn > 0, self.inherited > 0)


def tally_component(sigma: List[List[Int]], a: Automaton, comp: List[Int]) -> SyncTally:
    var tally = SyncTally()
    for s in range(len(comp)):
        var sync = state_sync(sigma, a.states[comp[s]])
        tally.newborn += 1 if sync.newborn else 0
        tally.inherited += 1 if sync.inherited else 0
        tally.clean_newborn += 1 if sync.clean_newborn() else 0
    return tally^


def main() raises:
    var corpus = pip_corpus()
    var n_capped = 0
    var n_scc = 0
    var n_states = 0

    var scc_with_newborn = 0
    var scc_without_newborn = 0
    var scc_with_inherited = 0
    var scc_with_both = 0
    var scc_with_neither = 0
    var scc_with_clean_newborn = 0

    var states_with_newborn = 0
    var states_with_inherited = 0
    var states_with_clean_newborn = 0

    # Audit the no-synchronization residual class.
    var no_sync_singleton = 0
    var no_sync_with_direct_coincidence = 0
    var no_sync_with_noncoincident_exit = 0
    var no_sync_closed_candidate = 0

    for s in range(len(corpus)):
        ref spec = corpus[s]
        var a = build(spec.sigma, STATE_CAP)
        if a.capped:
            n_capped += 1
            print("CAPPED_JSON {\"type\":\"capped\"," + spec.json_fields() + "}")
            continue

        var comps = recurrent_noncoincident_sccs(a)
        for ci in range(len(comps)):
            ref comp = comps[ci]
            n_scc += 1
            n_states += len(comp)

            var tally = tally_component(spec.sigma, a, comp)
            var sync = tally.profile()
            states_with_newborn += tally.newborn
            states_with_inherited += tally.inherited
            states_with_clean_newborn += tally.clean_newborn

            scc_with_newborn += 1 if sync.newborn else 0
            scc_without_newborn += 0 if sync.newborn else 1
            scc_with_inherited += 1 if sync.inherited else 0
            scc_with_both += 1 if sync.newborn and sync.inherited else 0
            scc_with_clean_newborn += 1 if tally.clean_newborn > 0 else 0
            if not sync.newborn:
                print(
                    "NO_NEWBORN_JSON {\"type\":\"no_newborn\"," + spec.json_fields()
                    + ",\"scc\":" + String(ci) + ",\"size\":" + String(len(comp)) + "}"
                )
            if sync.any():
                continue

            scc_with_neither += 1
            var shape = profile_component(a, comp)
            no_sync_singleton += 1 if len(comp) == 1 else 0
            no_sync_with_direct_coincidence += 1 if shape.direct_coincidence else 0
            no_sync_with_noncoincident_exit += 1 if shape.noncoincident_exit else 0
            no_sync_closed_candidate += 1 if shape.is_closed_nonproductive() else 0
            print(
                "NO_SYNC_JSON {\"type\":\"no_sync\"," + spec.json_fields()
                + ",\"scc\":" + String(ci) + ",\"size\":" + String(len(comp))
                + ",\"direct_coincidence\":" + String(1 if shape.direct_coincidence else 0)
                + ",\"noncoincident_exit\":" + String(1 if shape.noncoincident_exit else 0)
                + ",\"state\":\"" + a.states[comp[0]].key() + "\"}"
            )

    print("C3 local one-step census")
    print("PIP specimens:", len(corpus), " capped:", n_capped)
    print("recurrent noncoincident SCCs:", n_scc, " states:", n_states)
    print("SCCs with newborn synchronization:", scc_with_newborn)
    print("SCCs without newborn synchronization:", scc_without_newborn)
    print("SCCs with inherited synchronization:", scc_with_inherited)
    print("SCCs with both lineages synchronizing:", scc_with_both)
    print("SCCs with neither lineage synchronizing:", scc_with_neither)
    print("SCCs with clean-newborn state:", scc_with_clean_newborn)
    print("states with newborn synchronization:", states_with_newborn)
    print("states with inherited synchronization:", states_with_inherited)
    print("states with clean-newborn synchronization:", states_with_clean_newborn)
    print("no-sync SCCs that are singleton:", no_sync_singleton)
    print("no-sync SCCs with direct coincidence sibling:", no_sync_with_direct_coincidence)
    print("no-sync SCCs with noncoincident exit:", no_sync_with_noncoincident_exit)
    print("no-sync closed/no-direct-coincidence candidates:", no_sync_closed_candidate)
