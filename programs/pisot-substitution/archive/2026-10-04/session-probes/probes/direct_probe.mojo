from parallel_fold.map_fold import parallel_map_fold
from psc.one_tile import _recurrent_nonzero, catch_up_free, leftmost_child
from psc.corpus import pip_corpus
from psc.overlap_seed_patch import build_seed_overlap_tables
from psc.perron_field3 import CubicElt
from psc.vertex_coincidence import build_box_graph

struct R(Copyable, Movable):
    var nonfree: Int
    var with_direct: Int
    var direct_vertices: Int
    var err: Int
    var missing: List[Int]
    def __init__(out self):
        self.nonfree = 0; self.with_direct = 0; self.direct_vertices = 0; self.err = 0
        self.missing = List[Int]()

def merge(a: R, b: R) -> R:
    var o = a.copy()
    o.nonfree += b.nonfree; o.with_direct += b.with_direct; o.direct_vertices += b.direct_vertices; o.err += b.err
    for i in range(len(b.missing)):
        o.missing.append(b.missing[i])
    return o^

def main() raises:
    var c = pip_corpus()
    def one(s: Int) {c} -> R:
        var o = R()
        try:
            if catch_up_free(c[s].sigma):
                return o^
            o.nonfree = 1
            var t = build_seed_overlap_tables(c[s].sigma)
            var a = build_box_graph(t)
            var cache = Dict[CubicElt, Int]()
            var rec = _recurrent_nonzero(a)
            var n = 0
            for k in range(len(rec)):
                if leftmost_child(t, cache, a.states[rec[k]]).shift.is_zero():
                    n += 1
            o.direct_vertices = n
            if n > 0:
                o.with_direct = 1
            else:
                o.missing.append(s)
        except:
            o.err = 1
        return o^
    var r = parallel_map_fold(one, merge, R(), len(c), 4)
    print("non-catch-up-free:", r.nonfree, " with a recurrent one-step catch-up:", r.with_direct, " vertices:", r.direct_vertices, " errors:", r.err)
    for i in range(min(len(r.missing), 10)):
        print("none:", c[r.missing[i]].label())
