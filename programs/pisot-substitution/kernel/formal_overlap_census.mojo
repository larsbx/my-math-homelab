"""Exact census of formal versus realized overlap carriers over the PIP corpus.

For every specimen of the standing 4,554-member corpus, `psc.formal_overlap`
builds the formal (potential) overlap graph from a Pisot-contraction box, the
realized swap-seed graph, and every formal carrier: a recurrent SCC of the
formal graph with its coincidences deleted. Each carrier is classified as
realized or unrealized, closed or exiting, aligned (an offset-zero vertex) or
strict, with its death depth (least number of inflations from the carrier to
a coincidence) and whether a coincidence is a direct child of it.

A closed carrier would be a nonproductive recurrent obstruction; a formal
nonproductive state would refute Q-infinity. Both are printed when found. A
clean record is finite evidence only. It replaces the uninstrumented
"1,764 formal producer-free cycles / death radius 7" ledger line: carriers
replace simple cycles and death depth replaces the unreproducible collar
radius; the two are not claimed equal.

Usage: `mojo run -I . formal_overlap_census.mojo [records]`. With `records`,
one JSON line per carrier follows the summary. Specimens are folded in
canonical order, so the record does not depend on the worker count.
"""

from std.sys import argv
from parallel_fold.map_fold import parallel_map_fold
from psc.corpus import Specimen, pip_corpus
from psc.formal_overlap import survey_formal_overlaps
from psc.histogram import Histogram, max_int
from psc.overlap_seed_patch import build_seed_overlap_tables

comptime WORKERS = 4
comptime FIELDS = 10  # specimen, size, cyclomatic, realized, closed, aligned, direct, death,
# aligned depth (offset zero, coincidences included), proper aligned depth (offset zero, not a coincidence)


struct FormalCensus(Copyable, Movable):
    var specimens: Int
    var formal_states: Int
    var realized_states: Int
    var max_formal: Int
    var nonproductive: Int
    var outside_box: Int
    var carriers: List[Int]
    var failed_index: Int

    def __init__(out self):
        self.specimens = 0
        self.formal_states = 0
        self.realized_states = 0
        self.max_formal = 0
        self.nonproductive = 0
        self.outside_box = 0
        self.carriers = List[Int]()
        self.failed_index = -1


def merge(a: FormalCensus, b: FormalCensus) -> FormalCensus:
    var out = a.copy()
    out.specimens += b.specimens
    out.formal_states += b.formal_states
    out.realized_states += b.realized_states
    out.max_formal = max_int(out.max_formal, b.max_formal)
    out.nonproductive += b.nonproductive
    out.outside_box += b.outside_box
    out.carriers += b.carriers.copy()
    if b.failed_index >= 0 and (out.failed_index < 0 or b.failed_index < out.failed_index):
        out.failed_index = b.failed_index
    return out^


def evaluate(index: Int, spec: Specimen) -> FormalCensus:
    var out = FormalCensus()
    try:
        var s = survey_formal_overlaps(build_seed_overlap_tables(spec.sigma))
        out.specimens = 1
        out.formal_states = s.formal.size()
        out.realized_states = s.realized_states
        out.max_formal = s.formal.size()
        out.nonproductive = s.nonproductive
        out.outside_box = 0 if s.carriers_inside_box else 1
        for c in range(len(s.carriers)):
            ref x = s.carriers[c]
            out.carriers += [
                index, x.size(), x.cyclomatic(), Int(x.realized), Int(x.closed),
                Int(x.aligned), Int(x.direct_producer), x.death_depth,
                x.aligned_depth, x.proper_aligned_depth,
            ]
    except:
        out.failed_index = index
    return out^


def _flag(x: Int) -> String:
    return "true" if x != 0 else "false"


def main() raises:
    var args = argv()
    var corpus = pip_corpus()

    def one(s: Int) {corpus} -> FormalCensus:
        return evaluate(s, corpus[s])

    var r = parallel_map_fold(one, merge, FormalCensus(), len(corpus), WORKERS)
    if r.failed_index >= 0:
        _ = survey_formal_overlaps(build_seed_overlap_tables(corpus[r.failed_index].sigma))
        raise Error("formal overlap census: worker failure did not replay")

    var n = len(r.carriers) // FIELDS
    var counts = List[Int](length=16, fill=0)  # realized*8 + closed*4 + aligned*2 + direct
    var death_realized = Histogram(64)
    var death_unrealized = Histogram(64)
    var size_unrealized = Histogram(4096)
    # Aligned-route decomposition (P1 two-route map), split by realization:
    # L = aligned depth, D - L the remainder after the first offset-zero hit,
    # and whether an aligned noncoincident pair (P1a's object) is reachable.
    var first_aligned = List[Histogram]()
    var remainder = List[Histogram]()
    var through_proper = List[Int](length=2, fill=0)
    var proper_before_death = List[Int](length=2, fill=0)
    for _ in range(2):
        first_aligned.append(Histogram(64))
        remainder.append(Histogram(64))
    var cyclomatic = 0
    var with_unrealized = List[Bool](length=len(corpus), fill=False)
    for c in range(n):
        ref f = r.carriers
        var o = c * FIELDS
        counts[f[o + 3] * 8 + f[o + 4] * 4 + f[o + 5] * 2 + f[o + 6]] += 1
        cyclomatic += f[o + 2]
        var real = f[o + 3]
        if f[o + 8] < 0 or f[o + 8] > f[o + 7]:
            raise Error("aligned depth exceeds death depth: a coincidence is offset zero")
        first_aligned[real].record(f[o + 8])
        remainder[real].record(f[o + 7] - f[o + 8])
        if f[o + 9] >= 0:
            through_proper[real] += 1
            if f[o + 9] < f[o + 7]:
                proper_before_death[real] += 1
        if f[o + 4] != 0:
            print("CLOSED formal carrier: specimen", corpus[f[o]].label(), "size", f[o + 1])
        if f[o + 3] != 0:
            death_realized.record(f[o + 7])
        else:
            death_unrealized.record(f[o + 7])
            size_unrealized.record(f[o + 1])
            with_unrealized[f[o]] = True
    var specimens_unrealized = 0
    for i in range(len(with_unrealized)):
        specimens_unrealized += Int(with_unrealized[i])

    print("Formal overlap carrier census, specimens:", r.specimens)
    print("formal states:", r.formal_states, " largest formal graph:", r.max_formal,
          " realized states:", r.realized_states)
    print("formal nonproductive states (Q-infinity):", r.nonproductive,
          " specimens with a carrier outside the box:", r.outside_box)
    var names: List[String] = ["unrealized", "realized"]
    for real in range(2):
        var total = 0
        var aligned = 0
        var direct = 0
        var closed = 0
        for k in range(8):
            var m = counts[real * 8 + k]
            total += m
            aligned += m if (k & 2) != 0 else 0
            direct += m if (k & 1) != 0 else 0
            closed += m if (k & 4) != 0 else 0
        print(names[real], "carriers:", total, " aligned:", aligned, " strict:", total - aligned,
              " closed:", closed, " with a direct coincidence child:", direct)
    print("formal carriers:", n, " cycle-space rank in total:", cyclomatic,
          " specimens with an unrealized carrier:", specimens_unrealized)
    print(death_realized.line("realized carriers by death depth:"))
    print(death_unrealized.line("unrealized carriers by death depth:"))
    print(size_unrealized.line("unrealized carriers by size:"))
    for real in range(2):
        print(first_aligned[real].line(names[real] + " carriers by first offset-zero depth L:"))
        print(remainder[real].line(names[real] + " carriers by death depth minus L:"))
        print(
            names[real], "carriers reaching an aligned noncoincident pair:", through_proper[real],
            " strictly before their death depth:", proper_before_death[real],
        )

    if len(args) > 1 and String(args[1]) == "records":
        for c in range(n):
            ref f = r.carriers
            var o = c * FIELDS
            print(
                "{" + corpus[f[o]].json_fields()
                + ",\"size\":" + String(f[o + 1])
                + ",\"cyclomatic\":" + String(f[o + 2])
                + ",\"realized\":" + _flag(f[o + 3])
                + ",\"closed\":" + _flag(f[o + 4])
                + ",\"aligned\":" + _flag(f[o + 5])
                + ",\"direct\":" + _flag(f[o + 6])
                + ",\"death\":" + String(f[o + 7])
                + ",\"aligned_depth\":" + String(f[o + 8])
                + ",\"proper_aligned_depth\":" + String(f[o + 9]) + "}"
            )
