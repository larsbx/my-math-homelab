"""Exact first scattered-subword defect census over the 4554 PIP corpus.

Every noncoincident balanced-pair state has K1=0. This census computes K2,
K3 and K4 with streaming exact integer recurrences (`psc.defect_degree`) and
classifies the first nonzero defect as degree 2, 3, 4, or >=5. Counts are
separated into:

- every reachable noncoincident BPA state;
- recurrent noncoincident SCC states;
- states belonging to noncoincident sink SCCs.

The census is finite evidence only. It does not prove a degree bound for PIP
balanced-pair states and does not prove G1, C1, C4, or PSC.
"""

from psc.bpa import build, recurrent_noncoincident_sccs
from psc.carrier import carrier_flags
from psc.corpus import STATE_CAP, pip_corpus
from psc.defect_degree import DEGREE_FIVE_PLUS, DEGREE_FOUR, first_defect_degree
from psc.histogram import Histogram, max_int

comptime DEGREE_TABLE = DEGREE_FIVE_PLUS + 1


def print_counts(prefix: String, counts: Histogram):
    print(prefix + " degree2: " + String(counts.count(2)))
    print(prefix + " degree3: " + String(counts.count(3)))
    print(prefix + " degree4: " + String(counts.count(4)))
    print(prefix + " degree5plus: " + String(counts.count(DEGREE_FIVE_PLUS)))


def main() raises:
    var corpus = pip_corpus()
    var reachable = Histogram(DEGREE_TABLE)
    var recurrent = Histogram(DEGREE_TABLE)
    var sink = Histogram(DEGREE_TABLE)

    var n_capped = 0
    var specimens_reachable_d4plus = 0
    var specimens_recurrent_d4plus = 0
    var specimens_sink_d4plus = 0
    var max_d4_length = 0
    var max_d5plus_length = 0
    var printed_d4_example = False
    var printed_d5_example = False

    for s in range(len(corpus)):
        ref spec = corpus[s]
        var a = build(spec.sigma, STATE_CAP)
        if a.capped:
            n_capped += 1
            continue
        var flags = carrier_flags(a, recurrent_noncoincident_sccs(a))

        var reachable_d4plus = False
        var recurrent_d4plus = False
        var sink_d4plus = False
        for v in range(a.size()):
            ref p = a.states[v]
            if p.is_coincidence():
                continue
            var degree = first_defect_degree(p)
            var high = degree >= DEGREE_FOUR
            reachable.record(degree)
            reachable_d4plus = reachable_d4plus or high
            if degree == DEGREE_FOUR:
                max_d4_length = max_int(max_d4_length, p.length())
            if degree == DEGREE_FIVE_PLUS:
                max_d5plus_length = max_int(max_d5plus_length, p.length())

            var example = "{" + spec.json_fields() + ",\"state\":\"" + p.key() + "\",\"length\":" + String(p.length()) + "}"
            if degree == DEGREE_FOUR and not printed_d4_example:
                print("D4_EXAMPLE_JSON " + example)
                printed_d4_example = True
            if degree == DEGREE_FIVE_PLUS and not printed_d5_example:
                print("D5PLUS_EXAMPLE_JSON " + example)
                printed_d5_example = True

            if flags.recurrent[v]:
                recurrent.record(degree)
                recurrent_d4plus = recurrent_d4plus or high
            if flags.sink[v]:
                sink.record(degree)
                sink_d4plus = sink_d4plus or high

        specimens_reachable_d4plus += 1 if reachable_d4plus else 0
        specimens_recurrent_d4plus += 1 if recurrent_d4plus else 0
        specimens_sink_d4plus += 1 if sink_d4plus else 0

    print("C4 first-defect-degree census")
    print("PIP specimens:", len(corpus), " capped:", n_capped)
    print("reachable noncoincident states:", reachable.total())
    print_counts("reachable", reachable)
    print("recurrent noncoincident states:", recurrent.total())
    print_counts("recurrent", recurrent)
    print("sink noncoincident states:", sink.total())
    print_counts("sink", sink)
    print("PIP with reachable degree4plus state:", specimens_reachable_d4plus)
    print("PIP with recurrent degree4plus state:", specimens_recurrent_d4plus)
    print("PIP with sink degree4plus state:", specimens_sink_d4plus)
    print("maximum degree4 state length:", max_d4_length)
    print("maximum degree5plus state length:", max_d5plus_length)
