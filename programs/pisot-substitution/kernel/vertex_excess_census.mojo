"""Exact census: first-hit depth against the contracting lower bound on the box graph.

For every standing-corpus specimen, builds the box graph of Proposition V
(docs/p1b-vertex-coincidence-box-2026-10-02.md) and, for every non-coincidence
vertex on a cycle, compares its first left-aligned depth `b` with the
contracting lower bound `m_0` of manuscript Proposition 5.42
(`psc.overlap_contracting`). It checks `m_0 <= b` and reports, by arithmetic
regime, the specimens by maximal excess `b - m_0` and the largest `m_0`. The
question it answers is whether the depth not explained by the Archimedean
bound is confined to the non-unimodular regime.
"""

from parallel_fold.map_fold import parallel_map_fold
from psc.corpus import Specimen, arithmetic_regime, pip_corpus
from psc.overlap_contracting import ContractingBound
from psc.overlap_obstruction import recurrent_sccs
from psc.overlap_seed_patch import build_seed_overlap_tables, first_left_aligned_depths
from psc.vertex_coincidence import build_box_graph

comptime WORKERS = 4
comptime SLOTS = 64
comptime REGIMES = 4


struct ExcessCensus(Copyable, Movable):
    var specimens: Int
    var failed_index: Int
    var max_m0: List[Int]  # by regime
    var excess_by_regime: List[Int]  # regime * SLOTS + maximal excess

    def __init__(out self):
        self.specimens = 0
        self.failed_index = -1
        self.max_m0 = List[Int](length=REGIMES, fill=0)
        self.excess_by_regime = List[Int](length=REGIMES * SLOTS, fill=0)


def merge(a: ExcessCensus, b: ExcessCensus) -> ExcessCensus:
    var out = a.copy()
    out.specimens += b.specimens
    if b.failed_index >= 0 and (out.failed_index < 0 or b.failed_index < out.failed_index):
        out.failed_index = b.failed_index
    for g in range(REGIMES):
        if b.max_m0[g] > out.max_m0[g]:
            out.max_m0[g] = b.max_m0[g]
    for k in range(len(out.excess_by_regime)):
        out.excess_by_regime[k] += b.excess_by_regime[k]
    return out^


def specimen_excess(spec: Specimen) raises -> ExcessCensus:
    var out = ExcessCensus()
    out.specimens = 1
    var tables = build_seed_overlap_tables(spec.sigma)
    var a = build_box_graph(tables)
    if a.capped:
        raise Error("box graph capped")
    var depths = first_left_aligned_depths(a)
    var bound = ContractingBound(tables)
    var regime = arithmetic_regime(spec.incidence)
    var worst = 0
    var comps = recurrent_sccs(a)
    for c in range(len(comps)):
        for k in range(len(comps[c])):
            var i = comps[c][k]
            var b = depths[i]
            var m0 = bound.least_level(a, a.states[i].shift)
            if b < 0 or m0 > b:
                raise Error("contracting lower bound exceeds the first left-aligned depth")
            if m0 > out.max_m0[regime]:
                out.max_m0[regime] = m0
            if b - m0 > worst:
                worst = b - m0
    if worst >= SLOTS:
        raise Error("excess outside the histogram")
    out.excess_by_regime[regime * SLOTS + worst] += 1
    return out^


def main() raises:
    var corpus = pip_corpus()

    def one(s: Int) {corpus} -> ExcessCensus:
        try:
            return specimen_excess(corpus[s])
        except:
            var failed = ExcessCensus()
            failed.failed_index = s
            return failed^

    var r = parallel_map_fold(one, merge, ExcessCensus(), len(corpus), WORKERS)
    if r.failed_index >= 0:
        _ = specimen_excess(corpus[r.failed_index])
        raise Error("excess census: worker failure did not replay")
    print("Box-graph excess census, specimens:", r.specimens)
    var names: List[String] = ["nonunimodular", "unimodular real", "unimodular complex", "zero discriminant"]
    for g in range(REGIMES):
        var line = String("maximal excess by specimen, ") + names[g] + " (largest m0 " + String(r.max_m0[g]) + "):"
        var any = False
        for k in range(SLOTS):
            var n = r.excess_by_regime[g * SLOTS + k]
            if n > 0:
                line += " " + String(k) + ":" + String(n)
                any = True
        if any:
            print(line)
