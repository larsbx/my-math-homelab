"""Exploratory: do the literature overlap types sit inside the seed patch?

Over a strided sample of the alphabet-3 PIP corpus, this driver finds the
least prefix length `k <= KMAX` for which every noncoincidence overlap type of
the Sirvent--Solomyak graph `G_O(T, x(W))`, `W = u[:k]` and `u` a fixed point
of a prolongable power of `sigma`, is a vertex type of the seed-patch graph
`O_sigma`. Productivity of an overlap depends only on its type, so such an
inclusion transfers seed-patch productivity to the literature graph.

For a specimen with no inclusion up to `KMAX` the driver closes the union of
every level-zero type over every prolongable point and every prefix length at
once, and reports whether that closure is productive and how it differs from
the seed patch.

This is exploratory, not a certificate: level-zero types are read off a finite
prefix of `u`, an uncertified factor set. It establishes nothing about the
whole tiling, and nothing about substitutions outside the sample.
"""

from psc.corpus import STATE_CAP, pip_corpus
from psc.histogram import Histogram
from psc.oa_overlap_types import (
    fixed_point_prefix,
    prolongable_points,
    type_inclusion_report,
    union_probe,
)
from psc.overlap_seed_patch import PerronCache, build_seed_overlap_graph_from_tables

comptime STRIDE = 10
comptime KMAX = 8
comptime MIN_PREFIX = 6000


def main() raises:
    var corpus = pip_corpus()
    # Field and tile lengths are read off the incidence matrix, which the
    # corpus repeats: one per matrix, not one per specimen (psc.overlap_seed_patch).
    var perron = PerronCache()
    var least_k = Histogram(KMAX + 2)
    var sampled = 0
    var without_inclusion = 0
    var nonproductive_literature = 0
    var union_not_contained = 0

    for s in range(0, len(corpus), STRIDE):
        ref spec = corpus[s]
        sampled += 1
        var tables = perron.tables_for(spec.sigma)
        var seed_graph = build_seed_overlap_graph_from_tables(tables, STATE_CAP)
        if seed_graph.capped:
            raise Error("seed-patch overlap graph capped: the sample is inconclusive")

        var points = prolongable_points(spec.sigma)
        if len(points) == 0:
            raise Error("PIP specimen without a prolongable power")
        var u = fixed_point_prefix(spec.sigma, points[0], MIN_PREFIX)

        var found = 0
        for k in range(1, KMAX + 1):
            var report = type_inclusion_report(tables, seed_graph, u, points[0], k)
            if not report.oa_all_productive:
                # A nonproductive literature type is the mathematical event
                # this scan exists to detect; record it before any statistic.
                nonproductive_literature += 1
                print("OA_NONPRODUCTIVE_JSON {" + spec.json_fields() + "," + report.json_fields() + "}")
            if report.includes():
                found = k
                break

        if found > 0:
            least_k.record(found)
            continue

        without_inclusion += 1
        least_k.record(KMAX + 1)  # the "not found up to KMAX" bucket
        var probe = union_probe(tables, seed_graph, spec.sigma, MIN_PREFIX, KMAX, STATE_CAP)
        if probe.union_minus_seed > 0:
            union_not_contained += 1
        print("OA_NO_INCLUSION_JSON {" + spec.json_fields() + "," + probe.json_fields() + "}")

    print("Sirvent-Solomyak overlap-type inclusion scan (exploratory)")
    print("corpus:", len(corpus), " stride:", STRIDE, " sampled:", sampled)
    print("prefix bound KMAX:", KMAX, " fixed-point prefix at least:", MIN_PREFIX)
    print("specimens with type inclusion:", sampled - without_inclusion)
    print("specimens without inclusion up to KMAX:", without_inclusion)
    print("specimens whose union closure is not contained:", union_not_contained)
    print("literature graphs with a nonproductive type:", nonproductive_literature)
    print(least_k.line("specimens by least k with inclusion (" + String(KMAX + 1) + " = none):"))
