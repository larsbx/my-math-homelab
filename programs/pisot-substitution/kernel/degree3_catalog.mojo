"""Exact catalogue of reachable K2-zero / K3-nonzero BPA states in the 4554 PIP corpus.

This is a focused companion to defect_degree_census.mojo.  It prints every
reachable noncoincident state whose first scattered-subword defect is degree 3,
with substitution indices and recurrent/sink flags, and then classifies the
rows by relabelling, reversal, incidence arithmetic and inflation shape
(`psc.degree3_taxonomy`).  A closed nonproductive first-degree-3 component is
emitted as a replayable countermodel before the summary.  Finite evidence only.
"""

from psc.bpa import build, recurrent_noncoincident_sccs
from psc.carrier import carrier_flags, emit_countermodel, productive_within_two, profile_component
from psc.corpus import STATE_CAP, pip_corpus
from psc.defect_degree import is_degree3
from psc.degree3_taxonomy import Degree3Row, Degree3Summary, commutes_with_theta
from psc.histogram import max_int
from psc.words import is_zero, k2, k3
from substitution_dynamics.automaton import Automaton


def is_first_degree3_component(a: Automaton, comp: List[Int]) -> Bool:
    """Every state has `K2 = 0` and at least one has `K3 != 0`."""
    var has_k3 = False
    for s in range(len(comp)):
        ref p = a.states[comp[s]]
        if not is_zero(k2(p)):
            return False
        has_k3 = has_k3 or not is_zero(k3(p))
    return has_k3


def main() raises:
    var corpus = pip_corpus()
    var rows = List[Degree3Row]()
    var n_specimens = 0
    var n_recurrent = 0
    var n_sink = 0
    var n_noncentralizer = 0
    var n_productive_within_two = 0
    var n_strict_components = 0
    var max_length = 0

    for s in range(len(corpus)):
        ref spec = corpus[s]
        var a = build(spec.sigma, STATE_CAP)
        if a.capped:
            print("INCONCLUSIVE_CAPPED", spec.label())
            raise Error("degree-3 catalogue is incomplete: state cap reached")

        var comps = recurrent_noncoincident_sccs(a)
        var flags = carrier_flags(a, comps)
        for ci in range(len(comps)):
            if profile_component(a, comps[ci]).is_closed_nonproductive() and is_first_degree3_component(a, comps[ci]):
                n_strict_components += 1
                emit_countermodel("D3", spec.json_fields(), ci, a, comps[ci])

        var specimen_rows = 0
        for v in range(a.size()):
            ref p = a.states[v]
            if p.is_coincidence() or not is_degree3(p):
                continue
            var row = Degree3Row(
                spec.sigma, p, flags.recurrent[v], flags.sink[v],
                commutes_with_theta(spec.incidence, p), productive_within_two(a, v),
            )
            specimen_rows += 1
            n_recurrent += 1 if row.recurrent else 0
            n_sink += 1 if row.sink else 0
            n_noncentralizer += 0 if row.centralizer else 1
            n_productive_within_two += 1 if row.productive_within_two else 0
            max_length = max_int(max_length, p.length())
            print(
                "D3_STATE_JSON {" + spec.json_fields() + ",\"state\":\"" + p.key()
                + "\",\"length\":" + String(p.length())
                + ",\"recurrent\":" + String(1 if row.recurrent else 0)
                + ",\"sink\":" + String(1 if row.sink else 0)
                + ",\"centralizer\":" + String(1 if row.centralizer else 0)
                + ",\"productive_within_two\":" + String(1 if row.productive_within_two else 0) + "}"
            )
            rows.append(row^)
        n_specimens += 1 if specimen_rows > 0 else 0

    print("C4 degree-3 state catalogue")
    print("PIP specimens:", len(corpus))
    print("PIP specimens with degree3 state:", n_specimens)
    print("degree3 states:", len(rows))
    print("degree3 recurrent states:", n_recurrent)
    print("degree3 sink states:", n_sink)
    print("maximum degree3 state length:", max_length)
    print("degree3 noncentralizer states:", n_noncentralizer)
    print("degree3 productive within two:", n_productive_within_two)
    print("strict first-degree3 components:", n_strict_components)
    Degree3Summary(rows).print_lines()
