from psc.one_tile import _cu_marks, _reaches_cu, _recurrent_nonzero
from psc.corpus import pip_corpus
from psc.overlap_seed_patch import build_seed_overlap_tables
from psc.vertex_coincidence import build_box_graph
from psc.overlap_obstruction import overlap_sccs
def main() raises:
    var want = Dict[String, Bool]()
    var text: String
    with open("../outputs/partial_labels.txt", "r") as f:
        text = f.read()
    for line in text.split("\n"):
        var l = String(line)
        if l.byte_length() > 0:
            want[l] = True
    var c = pip_corpus()
    var hist = Dict[Int, Int]()
    var single = 0
    var bad_total = 0
    for s in range(len(c)):
        if String(c[s].label()) not in want:
            continue
        var t = build_seed_overlap_tables(c[s].sigma)
        var a = build_box_graph(t)
        var mark = _cu_marks(t, a)
        var good = _reaches_cu(a, mark)
        var rec = _recurrent_nonzero(a)
        var comps = overlap_sccs(a)
        var comp_of = List[Int](length=a.size(), fill=-1)
        for q in range(len(comps)):
            for k in range(len(comps[q])):
                comp_of[comps[q][k]] = q
        for k in range(len(rec)):
            var v = rec[k]
            if good[v]:
                continue
            bad_total += 1
            var seen = Dict[Int, Bool]()
            var stack: List[Int] = [v]
            seen[v] = True
            var one_scc = True
            while len(stack) > 0:
                var x = stack.pop()
                if comp_of[x] != comp_of[v]:
                    one_scc = False
                for j in range(len(a.adj[x])):
                    var y = a.adj[x][j]
                    if a.states[y].shift.is_zero() or y in seen:
                        continue
                    seen[y] = True
                    stack.append(y)
            var n = len(seen)
            hist[n] = hist.get(n, 0) + 1
            if one_scc:
                single += 1
    print("failing recurrent vertices:", bad_total, " closure is its own SCC:", single)
    for e in hist.items():
        print("closure size", e.key, ":", e.value)
