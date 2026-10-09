from parallel_fold.map_fold import parallel_map_fold
from psc.one_tile import _recurrent_nonzero, catch_up_free
from psc.corpus import pip_corpus
from psc.overlap_seed_patch import build_seed_overlap_tables
from psc.vertex_coincidence import build_box_graph

struct D(Copyable, Movable):
    var free: Int
    var rec: Int
    var reach_diag: Int
    var reach_offdiag: Int
    var spec_all_diag: Int
    var spec_some_not: Int
    def __init__(out self):
        self.free = 0; self.rec = 0; self.reach_diag = 0; self.reach_offdiag = 0
        self.spec_all_diag = 0; self.spec_some_not = 0

def merge(a: D, b: D) -> D:
    var o = a.copy()
    o.free += b.free; o.rec += b.rec; o.reach_diag += b.reach_diag; o.reach_offdiag += b.reach_offdiag
    o.spec_all_diag += b.spec_all_diag; o.spec_some_not += b.spec_some_not
    return o^

def reach(a: SeedOverlapAutomaton, diag: Bool) -> List[Bool]:
    # nonzero vertices with an edge into an offset-zero child of the given kind, closed under parents
    var n = a.size()
    var good = List[Bool](length=n, fill=False)
    var parents = List[List[Int]]()
    for _ in range(n):
        parents.append(List[Int]())
    var queue = List[Int]()
    for i in range(n):
        for j in range(len(a.adj[i])):
            var y = a.adj[i][j]
            parents[y].append(i)
    for i in range(n):
        if a.states[i].shift.is_zero():
            continue
        for j in range(len(a.adj[i])):
            var y = a.adj[i][j]
            if a.states[y].shift.is_zero() and ((a.states[y].top == a.states[y].bottom) == diag) and not good[i]:
                good[i] = True
                queue.append(i)
    var h = 0
    while h < len(queue):
        var k = queue[h]; h += 1
        for j in range(len(parents[k])):
            var p = parents[k][j]
            if not good[p] and not a.states[p].shift.is_zero():
                good[p] = True; queue.append(p)
    return good^

from psc.overlap_seed_patch import SeedOverlapAutomaton

def main() raises:
    var c = pip_corpus()
    def one(s: Int) {c} -> D:
        var o = D()
        try:
            var free = catch_up_free(c[s].sigma)
            var t = build_seed_overlap_tables(c[s].sigma)
            var a = build_box_graph(t)
            var gd = reach(a, True)
            var go = reach(a, False)
            var rec = _recurrent_nonzero(a)
            var alld = True
            for k in range(len(rec)):
                o.rec += 1
                if gd[rec[k]]:
                    o.reach_diag += 1
                else:
                    alld = False
                if go[rec[k]]:
                    o.reach_offdiag += 1
            if free:
                o.free = 1
                if alld:
                    o.spec_all_diag = 1
                else:
                    o.spec_some_not = 1
        except:
            o.free = -1000000
        return o^
    var r = parallel_map_fold(one, merge, D(), len(c), 4)
    print("all specimens: recurrent", r.rec, "reach diagonal hit", r.reach_diag, "reach off-diagonal hit", r.reach_offdiag)
    print("catch-up-free specimens", r.free, ": every recurrent vertex reaches a diagonal hit in", r.spec_all_diag, " not in", r.spec_some_not)
