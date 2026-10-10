"""Exact necessary-condition census for hypothetical three-state degree-2 SCCs.

If a strict closed degree-2 SCC C has |C|=3, the Parikh and signed K2
intertwiners force

    N_C ~ M_sigma,        S_C ~ Lambda^2 M_sigma,

while N_C=A+B and S_C=A-B for nonnegative integer A,B. Hence for every k>=1

    tr(M^k) - tr((Lambda^2 M)^k)
      = 2 * sum_{words with odd B-count} tr(word(A,B)) >= 0.

For k=2 the difference is exactly 4 tr(A B), hence divisible by four.
This finite census first applies the mod-2 three-state parity sieve, then the
proved global-endpoint synchronization eliminator (types A/B), then tests the
trace conditions (`psc.degree2_sieve`). For the surviving actual substitutions
it also builds the BPA and records whether any recurrent or noncoincident-sink
SCC really has size 3.

Finite evidence only: surviving/absent specimens do not prove a general theorem.
"""

from psc.bpa import build, recurrent_noncoincident_sccs
from psc.carrier import profile_component
from psc.corpus import STATE_CAP, pip_corpus
from psc.degree2_sieve import first_trace_failure, parity_allows_three_states, survives_through
from psc.endpoint_core import endpoint_type, prefix_endpoint_map, suffix_endpoint_map
from psc.histogram import Histogram, min_int

comptime MAX_POWER = 12
comptime NONSYNCHRONIZING_TYPE = 2  # types C..G are not globally synchronizing


def endpoints_can_be_counterexample(sigma: List[List[Int]]) -> Bool:
    """Both endpoint maps must be non-globally-synchronizing (types C..G)."""
    return (
        endpoint_type(prefix_endpoint_map(sigma)) >= NONSYNCHRONIZING_TYPE
        and endpoint_type(suffix_endpoint_map(sigma)) >= NONSYNCHRONIZING_TYPE
    )


def survivors_through(failures: Histogram, k: Int) -> Int:
    """Specimens whose first trace failure is absent or beyond power `k`."""
    var n = 0
    for f in range(len(failures.counts)):
        if survives_through(f, k):
            n += failures.count(f)
    return n


def main() raises:
    var corpus = pip_corpus()
    var parity_survivors = 0
    var parity_endpoint_survivors = 0
    var endpoint_trace_survivors = 0
    var endpoint_trace_capped = 0
    var with_recurrent_size3 = 0
    var with_sink_size3 = 0
    var minimum_recurrent_size = 1000000
    var minimum_sink_size = 1000000
    var trace_failures = Histogram(MAX_POWER + 1)
    var printed_survivor = False
    var printed_endpoint_survivor = False

    for s in range(len(corpus)):
        ref spec = corpus[s]
        var chi = spec.incidence.charpoly()
        var t = -chi[2]
        var u = chi[1]
        var d = -chi[0]
        if not parity_allows_three_states(t, u, d):
            continue
        parity_survivors += 1
        var endpoint_ok = endpoints_can_be_counterexample(spec.sigma)
        parity_endpoint_survivors += 1 if endpoint_ok else 0

        var first_fail = first_trace_failure(t, u, d, MAX_POWER)
        trace_failures.record(first_fail)
        if first_fail != 0:
            continue

        var cubic = "\"T\":" + String(t) + ",\"U\":" + String(u) + ",\"d\":" + String(d)
        if not printed_survivor:
            print("TRACE12_SURVIVOR_JSON {" + spec.json_fields() + "," + cubic + "}")
            printed_survivor = True
        if not endpoint_ok:
            continue

        endpoint_trace_survivors += 1
        if not printed_endpoint_survivor:
            print(
                "ENDPOINT_TRACE12_SURVIVOR_JSON {" + spec.json_fields() + "," + cubic
                + ",\"plus\":" + String(endpoint_type(prefix_endpoint_map(spec.sigma)))
                + ",\"minus\":" + String(endpoint_type(suffix_endpoint_map(spec.sigma))) + "}"
            )
            printed_endpoint_survivor = True

        var a = build(spec.sigma, STATE_CAP)
        if a.capped:
            endpoint_trace_capped += 1
            continue
        var recurrent_size3 = False
        var sink_size3 = False
        var comps = recurrent_noncoincident_sccs(a)
        for ci in range(len(comps)):
            ref comp = comps[ci]
            minimum_recurrent_size = min_int(minimum_recurrent_size, len(comp))
            recurrent_size3 = recurrent_size3 or len(comp) == 3
            if profile_component(a, comp).is_sink():
                minimum_sink_size = min_int(minimum_sink_size, len(comp))
                sink_size3 = sink_size3 or len(comp) == 3
        with_recurrent_size3 += 1 if recurrent_size3 else 0
        with_sink_size3 += 1 if sink_size3 else 0

    print("C4 degree-2 three-state necessary-condition census")
    print("PIP specimens:", len(corpus))
    print("three-state parity survivors:", parity_survivors)
    print("parity survivors with both endpoint maps nonsynchronizing:", parity_endpoint_survivors)
    print("survive trace k<=1:", survivors_through(trace_failures, 1))
    print("survive trace k<=2 plus mod4:", survivors_through(trace_failures, 2))
    print("survive trace k<=3:", survivors_through(trace_failures, 3))
    print("survive trace k<=6:", survivors_through(trace_failures, 6))
    print("survive trace k<=12:", survivors_through(trace_failures, MAX_POWER))
    print("survive parity + nonsync endpoints + trace k<=12:", endpoint_trace_survivors)
    print("combined survivors with capped BPA:", endpoint_trace_capped)
    print("combined survivors with recurrent size-3 SCC:", with_recurrent_size3)
    print("combined survivors with sink size-3 SCC:", with_sink_size3)
    print("minimum recurrent SCC size among combined survivors:", minimum_recurrent_size)
    print("minimum sink SCC size among combined survivors:", minimum_sink_size)
    for power in range(1, MAX_POWER + 1):
        if trace_failures.count(power) > 0:
            print("first failure at k=" + String(power) + ": " + String(trace_failures.count(power)))
