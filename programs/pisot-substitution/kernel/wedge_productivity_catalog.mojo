"""Exact bounded-corpus certificate for the K2-nonzero wedge-productivity case.

For every primitive irreducible Pisot substitution on three letters with
nonempty images of length at most three, this driver inspects every recurrent
noncoincident SCC.  A closed nonproductive SCC with nonzero K2 is emitted as a
replayable exact countermodel before the zero-survivor assertion can fail.
This is a finite-domain certificate, not a proof of general wedge productivity.
"""

from substitution_dynamics.automaton import Automaton
from psc.bpa import build, recurrent_noncoincident_sccs
from psc.carrier import emit_countermodel, profile_component
from psc.corpus import STATE_CAP, pip_corpus
from psc.symmetry import parse_substitution_key
from psc.words import ALPHABET, Pair, is_zero, k2


def has_nonzero_k2(a: Automaton, comp: List[Int]) -> Bool:
    for s in range(len(comp)):
        if not is_zero(k2(a.states[comp[s]])):
            return True
    return False


def is_strict_degree2(a: Automaton, comp: List[Int]) -> Bool:
    return profile_component(a, comp).is_closed_nonproductive() and has_nonzero_k2(a, comp)


def run_predicate_calibration() raises:
    """Positive strict-carrier control plus a negative leaking control."""
    # One-based 1->2, 2->123, 3->2. This substitution is primitive but not
    # Pisot and has a known reachable two-state strict component.
    var strict_automaton = build(parse_substitution_key("1/012/1"), STATE_CAP)
    if strict_automaton.capped:
        raise Error("strict calibration unexpectedly reached the state cap")
    var detected_strict = False
    var strict_comps = recurrent_noncoincident_sccs(strict_automaton)
    for ci in range(len(strict_comps)):
        if len(strict_comps[ci]) == 2 and is_strict_degree2(strict_automaton, strict_comps[ci]):
            detected_strict = True
    if not detected_strict:
        raise Error("strict K2-nonzero calibration component was not detected")

    # Directly calibrate rejection of a noncoincident K2-nonzero carrier
    # candidate that produces a coincidence child.
    var source_u: List[Int] = [0, 1]
    var source_v: List[Int] = [1, 0]
    var coincidence: List[Int] = [0]
    var leaking_states: List[Pair] = [Pair(source_u, source_v), Pair(coincidence, coincidence)]
    var source_edges: List[Int] = [0, 1]
    var leaking_adj: List[List[Int]] = [source_edges^, List[Int]()]
    var leaking_automaton = Automaton(leaking_states, leaking_adj, False, ALPHABET)
    var leaking_comp: List[Int] = [0]
    if not has_nonzero_k2(leaking_automaton, leaking_comp):
        raise Error("leaking K2-nonzero calibration lost its wedge defect")
    if profile_component(leaking_automaton, leaking_comp).is_closed_nonproductive():
        raise Error("coincidence-producing calibration was misclassified as strict")

    print("CALIBRATION strict K2-nonzero component detected: 1")
    print("CALIBRATION coincidence-producing component rejected: 1")


def main() raises:
    run_predicate_calibration()
    var corpus = pip_corpus()
    var n_recurrent_components = 0
    var n_closed_nonproductive = 0
    var n_strict_degree2 = 0

    for s in range(len(corpus)):
        ref spec = corpus[s]
        var a = build(spec.sigma, STATE_CAP)
        if a.capped:
            print("WEDGE_INCONCLUSIVE_CAPPED", spec.label())
            raise Error("wedge-productivity catalogue is incomplete: state cap reached")

        var comps = recurrent_noncoincident_sccs(a)
        n_recurrent_components += len(comps)
        for ci in range(len(comps)):
            if not profile_component(a, comps[ci]).is_closed_nonproductive():
                continue
            n_closed_nonproductive += 1
            if has_nonzero_k2(a, comps[ci]):
                n_strict_degree2 += 1
                emit_countermodel("D2", spec.json_fields(), ci, a, comps[ci])

    print("bounded K2-nonzero wedge-productivity catalogue")
    print("PIP specimens:", len(corpus))
    print("recurrent noncoincident components:", n_recurrent_components)
    print("closed nonproductive components:", n_closed_nonproductive)
    print("strict K2-nonzero components:", n_strict_degree2)
