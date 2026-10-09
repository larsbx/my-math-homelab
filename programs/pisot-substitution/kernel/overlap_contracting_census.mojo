"""Exact census: first left-aligned depth against the contracting lower bound.

For every alphabet-3 PIP substitution with images of length at most 3, builds
the seed-patch overlap graph, computes the first left-aligned depth `b` of
every vertex (`psc.overlap_seed_patch`) and the contracting lower bound `m_0`
of manuscript Proposition 5.42 (`psc.overlap_contracting`), checks `m_0 <= b`
on every vertex and `m_0 = 0` exactly at offset zero, and reports the
distributions of `m_0` and of the excess `b - m_0`.  A nonproductive graph is
recorded before any depth statistic.  The Python oracle
`oracles/python/overlap_contracting_census.py` prints the same summary lines (all
but the specimen-count header).
"""

from psc.corpus import STATE_CAP, Specimen, pip_corpus, report_progress
from psc.histogram import Histogram, max_int
from psc.overlap_contracting import ContractingBoundCache
from psc.overlap_seed_patch import (
    PerronCache,
    SeedOverlapAutomaton,
    build_seed_overlap_graph_from_tables,
    first_left_aligned_depths,
    nonproductive_overlap_states,
)


struct RegimeExtremes(Copyable, Movable):
    """Specimen count and maxima of `m_0` and of the excess within one
    spectral regime (complex conjugate pair or three real roots)."""

    var specimens: Int
    var max_m0: Int
    var max_excess: Int

    def __init__(out self):
        self.specimens = 0
        self.max_m0 = 0
        self.max_excess = 0

    def absorb(mut self, m0: Int, excess: Int):
        self.specimens += 1
        self.max_m0 = max_int(self.max_m0, m0)
        self.max_excess = max_int(self.max_excess, excess)

    def line(self, label: String) -> String:
        return (
            label + " " + String(self.specimens) + "  maximal m0: " + String(self.max_m0)
            + "  maximal excess: " + String(self.max_excess)
        )


def main() raises:
    var corpus = pip_corpus()
    # Field and tile lengths are read off the incidence matrix, which the
    # corpus repeats: one per matrix, not one per specimen (psc.overlap_seed_patch).
    var perron = PerronCache()
    # One bound per distinct (cubic, digit set), shared across the specimens
    # that carry it, with its computed levels beside it (psc.overlap_contracting).
    var bounds = ContractingBoundCache()
    var n_nonproductive = 0
    var n_failed = 0
    var complex_regime = RegimeExtremes()
    var real_regime = RegimeExtremes()
    var vertex_m0 = Histogram()
    var vertex_excess = Histogram()
    var specimen_m0 = Histogram()
    var specimen_excess = Histogram()

    for s in range(len(corpus)):
        ref spec = corpus[s]
        try:
            var tables = perron.tables_for(spec.sigma)
            var g = build_seed_overlap_graph_from_tables(tables, STATE_CAP)
            if g.capped:
                raise Error("seed-patch overlap graph capped")
            if len(nonproductive_overlap_states(g)) > 0:
                n_nonproductive += 1
                print("NONPRODUCTIVE overlap specimen:", spec.label())
                continue
            var left = first_left_aligned_depths(g)
            var slot = bounds.slot(tables)
            var worst_excess = 0
            var worst_m0 = 0
            for v in range(g.size()):
                var t = g.states[v].shift
                var m0 = bounds.least_level(slot, g, t)
                if m0 < 0 or m0 > left[v]:
                    raise Error("contracting bound exceeds the left-aligned depth")
                if (m0 == 0) != t.is_zero():
                    raise Error("contracting bound vanishes off offset zero")
                var excess = left[v] - m0
                vertex_m0.record(m0)
                vertex_excess.record(excess)
                worst_m0 = max_int(worst_m0, m0)
                worst_excess = max_int(worst_excess, excess)
            specimen_m0.record(worst_m0)
            specimen_excess.record(worst_excess)
            if bounds.is_complex(slot):
                complex_regime.absorb(worst_m0, worst_excess)
            else:
                real_regime.absorb(worst_m0, worst_excess)
        except e:
            n_failed += 1
            print("FAILED specimen:", spec.label(), " ", e)
        report_progress(s + 1)

    print("PIP specimens:", len(corpus), " failed:", n_failed, " nonproductive:", n_nonproductive)
    print("vertices checked:", vertex_m0.total())
    print("maximum contracting lower bound m0:", vertex_m0.maximum())
    print(vertex_m0.line("vertices by contracting lower bound m0:"))
    print("maximum excess b - m0:", vertex_excess.maximum())
    print(vertex_excess.line("vertices by excess b - m0:"))
    print(specimen_excess.line("specimens by maximal excess:"))
    print(specimen_m0.line("specimens by maximal m0:"))
    print(complex_regime.line("complex-pair specimens:"))
    print(real_regime.line("real-conjugate specimens:"))
