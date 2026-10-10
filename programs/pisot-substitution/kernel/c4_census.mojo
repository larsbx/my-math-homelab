"""Exact C4 calibration over the established alphabet-3 PIP corpus.

For every primitive irreducible Pisot substitution with image lengths <= 3,
classify the prefix/suffix endpoint maps into the seven C4-A types A..G. Then
inspect every recurrent noncoincident SCC and isolate noncoincident sink SCCs.

The census also records the degree-4 first-defect arithmetic survivor regime:
`|det M|=1` versus `|det M|>1`, with unimodular specimens split by cubic
discriminant into three-real-root and one-real/two-complex-root cases.

The output is finite evidence only. It does not prove C4, C1, G1, or PSC.
"""

from substitution_dynamics.automaton import Automaton
from psc.bpa import build, recurrent_noncoincident_sccs
from psc.carrier import SyncProfile, profile_component, state_sync
from psc.corpus import (
    REGIME_NONUNIMODULAR,
    REGIME_UNIMODULAR_COMPLEX,
    REGIME_UNIMODULAR_REAL,
    REGIME_ZERO_DISCRIMINANT,
    STATE_CAP,
    Specimen,
    arithmetic_regime,
    pip_corpus,
)
from psc.endpoint_core import endpoint_type, endpoint_type_name, prefix_endpoint_map, suffix_endpoint_map
from psc.histogram import Histogram

comptime ENDPOINT_TYPES = 7


def endpoint_pair_type(sigma: List[List[Int]]) -> Int:
    """`7 * type(sigma_+) + type(sigma_-)`, the joint endpoint-type cell."""
    return ENDPOINT_TYPES * endpoint_type(prefix_endpoint_map(sigma)) + endpoint_type(suffix_endpoint_map(sigma))


def pair_type_json(cell: Int) -> String:
    return (
        "\"plus\":\"" + endpoint_type_name(cell // ENDPOINT_TYPES)
        + "\",\"minus\":\"" + endpoint_type_name(cell % ENDPOINT_TYPES) + "\""
    )


def counts_csv(h: Histogram) -> String:
    var out = String("")
    for i in range(len(h.counts)):
        out += ("," if i > 0 else "") + String(h.counts[i])
    return out


def component_sync(sigma: List[List[Int]], a: Automaton, comp: List[Int]) -> SyncProfile:
    var sync = SyncProfile(False, False)
    for s in range(len(comp)):
        sync = sync.join(state_sync(sigma, a.states[comp[s]]))
    return sync^


def main() raises:
    var corpus = pip_corpus()
    var pip_pair_counts = Histogram(ENDPOINT_TYPES * ENDPOINT_TYPES)
    var sink_pair_counts = Histogram(ENDPOINT_TYPES * ENDPOINT_TYPES)
    var regimes = Histogram(4)

    var n_capped = 0
    var n_recurrent = 0
    var n_sink = 0
    var n_sink_direct_coincidence = 0
    var n_sink_no_direct_coincidence = 0
    var n_sink_newborn = 0
    var n_sink_inherited = 0
    var n_sink_any_sync = 0
    var n_sink_no_sync = 0
    var sinks_per_specimen = Histogram(64)

    for s in range(len(corpus)):
        ref spec = corpus[s]
        var regime = arithmetic_regime(spec.incidence)
        regimes.record(regime)
        if regime == REGIME_ZERO_DISCRIMINANT:
            print("PIP_ZERO_DISCRIMINANT_JSON {" + spec.json_fields() + "}")

        var cell = endpoint_pair_type(spec.sigma)
        pip_pair_counts.record(cell)

        var a = build(spec.sigma, STATE_CAP)
        if a.capped:
            n_capped += 1
            continue

        var specimen_sinks = 0
        var comps = recurrent_noncoincident_sccs(a)
        for ci in range(len(comps)):
            ref comp = comps[ci]
            n_recurrent += 1
            var shape = profile_component(a, comp)
            if not shape.is_sink():
                continue

            specimen_sinks += 1
            n_sink += 1
            sink_pair_counts.record(cell)
            var sync = component_sync(spec.sigma, a, comp)
            var record = (
                spec.json_fields() + ",\"scc\":" + String(ci)
                + ",\"size\":" + String(len(comp)) + "," + pair_type_json(cell)
            )

            if shape.direct_coincidence:
                n_sink_direct_coincidence += 1
            else:
                n_sink_no_direct_coincidence += 1
                print("SINK_NO_DIRECT_JSON {" + record + "}")

            n_sink_newborn += 1 if sync.newborn else 0
            n_sink_inherited += 1 if sync.inherited else 0
            if sync.any():
                n_sink_any_sync += 1
            else:
                n_sink_no_sync += 1
                print("SINK_NO_SYNC_JSON {" + record + "}")

        sinks_per_specimen.record(specimen_sinks)
        if specimen_sinks == 0:
            print("PIP_ZERO_SINK_JSON {" + spec.json_fields() + "}")
        elif specimen_sinks > 1:
            print("PIP_MULTI_SINK_JSON {" + spec.json_fields() + ",\"count\":" + String(specimen_sinks) + "}")

    var n_uncapped = len(corpus) - n_capped
    print("C4 endpoint-type sink-SCC census")
    print("PIP specimens:", len(corpus), " capped:", n_capped)
    print("degree4 unimodular PIP:", regimes.count(REGIME_UNIMODULAR_REAL) + regimes.count(REGIME_UNIMODULAR_COMPLEX) + regimes.count(REGIME_ZERO_DISCRIMINANT))
    print("degree4 nonunimodular PIP:", regimes.count(REGIME_NONUNIMODULAR))
    print("degree4 unimodular three-real-root PIP:", regimes.count(REGIME_UNIMODULAR_REAL))
    print("degree4 unimodular complex-pair PIP:", regimes.count(REGIME_UNIMODULAR_COMPLEX))
    print("PIP cubics with zero discriminant:", regimes.count(REGIME_ZERO_DISCRIMINANT))
    print("recurrent noncoincident SCCs:", n_recurrent)
    print("noncoincident sink SCCs:", n_sink)
    print("uncapped PIP with zero sink SCCs:", sinks_per_specimen.count(0))
    print("uncapped PIP with exactly one sink SCC:", sinks_per_specimen.count(1))
    print("uncapped PIP with multiple sink SCCs:", n_uncapped - sinks_per_specimen.count(0) - sinks_per_specimen.count(1))
    print("maximum sink SCCs per uncapped PIP:", sinks_per_specimen.maximum())
    print("sink SCCs with direct coincidence child:", n_sink_direct_coincidence)
    print("sink SCCs without direct coincidence child:", n_sink_no_direct_coincidence)
    print("sink SCCs with newborn synchronization:", n_sink_newborn)
    print("sink SCCs with inherited synchronization:", n_sink_inherited)
    print("sink SCCs with any boundary synchronization:", n_sink_any_sync)
    print("sink SCCs with no boundary synchronization:", n_sink_no_sync)
    print("PIP_TYPE_MATRIX " + counts_csv(pip_pair_counts))
    print("SINK_TYPE_MATRIX " + counts_csv(sink_pair_counts))

    for cell in range(ENDPOINT_TYPES * ENDPOINT_TYPES):
        var names = endpoint_type_name(cell // ENDPOINT_TYPES) + " " + endpoint_type_name(cell % ENDPOINT_TYPES)
        if pip_pair_counts.count(cell) > 0:
            print("PIP_TYPE_PAIR " + names + " " + String(pip_pair_counts.count(cell)))
        if sink_pair_counts.count(cell) > 0:
            print("SINK_TYPE_PAIR " + names + " " + String(sink_pair_counts.count(cell)))
