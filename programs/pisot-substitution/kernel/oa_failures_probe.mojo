"""Exploratory: what happens where short-prefix overlap-type inclusion fails?

`oa_type_inclusion_census.mojo` finds, for each sampled specimen, the least
prefix length `k <= KMAX` giving type inclusion of the Sirvent--Solomyak
overlap types into the seed-patch vertex types. This driver takes the
specimens where no such `k` exists and asks three further questions:

* does a longer prefix, up to `EXTENDED_KMAX`, give inclusion?
* does another fixed point do, over every prolongable `(q, c)`?
* is the union of every probed family productive, and how does it sit
  against the seed patch?

A nonproductive type in any probed family is the event worth keeping, and is
printed before any aggregate. Everything here is exploratory: level-zero types
are read off a finite prefix, an uncertified factor set, so a failure of
inclusion is not a mathematical obstruction and a success is not a theorem.
"""

from psc.corpus import STATE_CAP, pip_corpus
from psc.histogram import max_int, min_int
from psc.oa_overlap_types import (
    extended_inclusion_witness,
    fixed_point_prefix,
    least_inclusion_k,
    prolongable_points,
    union_probe,
)
from psc.overlap_seed_patch import PerronCache, build_seed_overlap_graph_from_tables

comptime STRIDE = 10
comptime KMAX = 8
comptime EXTENDED_KMAX = 24
comptime MIN_PREFIX = 6000


struct Range(Copyable, Movable):
    """The observed interval of one statistic over the probed specimens."""

    var low: Int
    var high: Int
    var seen: Bool

    def __init__(out self):
        self.low = 0
        self.high = 0
        self.seen = False

    def absorb(mut self, value: Int):
        self.low = value if not self.seen else min_int(self.low, value)
        self.high = value if not self.seen else max_int(self.high, value)
        self.seen = True

    def line(self, label: String) -> String:
        if not self.seen:
            return label + " (none)"
        return label + " " + String(self.low) + " to " + String(self.high)


def main() raises:
    var corpus = pip_corpus()
    # Field and tile lengths are read off the incidence matrix, which the
    # corpus repeats: one per matrix, not one per specimen (psc.overlap_seed_patch).
    var perron = PerronCache()
    var sampled = 0
    var failures = 0
    var extended_hits = 0
    var nonproductive = 0
    var union_noncoincidence = Range()
    var seed_types = Range()
    var union_minus_seed = Range()
    var seed_minus_union = Range()
    var witnesses = List[String]()

    for s in range(0, len(corpus), STRIDE):
        ref spec = corpus[s]
        sampled += 1
        var tables = perron.tables_for(spec.sigma)
        var seed_graph = build_seed_overlap_graph_from_tables(tables, STATE_CAP)
        if seed_graph.capped:
            raise Error("seed-patch overlap graph capped: the sample is inconclusive")
        var points = prolongable_points(spec.sigma)
        var u = fixed_point_prefix(spec.sigma, points[0], MIN_PREFIX)
        if least_inclusion_k(tables, seed_graph, u, points[0], KMAX, STATE_CAP) > 0:
            continue

        failures += 1
        var witness = extended_inclusion_witness(
            tables, seed_graph, spec.sigma, MIN_PREFIX, EXTENDED_KMAX, STATE_CAP
        )
        if witness.found:
            extended_hits += 1
            witnesses.append(witness.key())
        var probe = union_probe(
            tables, seed_graph, spec.sigma, MIN_PREFIX, EXTENDED_KMAX, STATE_CAP
        )
        if not probe.union_all_productive:
            nonproductive += 1
            print("OA_UNION_NONPRODUCTIVE_JSON {" + spec.json_fields() + "," + probe.json_fields() + "}")

        var seed_noncoincidence = 0
        for i in range(seed_graph.size()):
            if not seed_graph.states[i].is_coincidence():
                seed_noncoincidence += 1
        union_noncoincidence.absorb(probe.union_noncoincidence)
        seed_types.absorb(seed_noncoincidence)
        union_minus_seed.absorb(probe.union_minus_seed)
        seed_minus_union.absorb(probe.seed_minus_union)
        print(
            "OA_PROBE_JSON {" + spec.json_fields() + ",\"witness\":\"" + witness.key()
            + "\",\"seed_noncoincidence\":" + String(seed_noncoincidence) + ","
            + probe.json_fields() + "}"
        )

    var witness_line = String("least extended witnesses (q,c,k):")
    sort(witnesses)
    for i in range(len(witnesses)):
        witness_line += " " + witnesses[i]

    print("Sirvent-Solomyak inclusion-failure probe (exploratory)")
    print("corpus:", len(corpus), " stride:", STRIDE, " sampled:", sampled)
    print("prefix bounds: KMAX", KMAX, " extended", EXTENDED_KMAX, " fixed-point prefix at least:", MIN_PREFIX)
    print("specimens without inclusion up to KMAX:", failures)
    print("of those, inclusion found with a longer prefix or another fixed point:", extended_hits)
    print("of those, no inclusion up to the extended bound:", failures - extended_hits)
    print("probed unions with a nonproductive type:", nonproductive)
    print(union_noncoincidence.line("union noncoincidence types:"))
    print(seed_types.line("seed-patch noncoincidence vertex types:"))
    print(union_minus_seed.line("union types outside the seed patch:"))
    print(seed_minus_union.line("seed-patch types met by no probed family:"))
    print(witness_line)
