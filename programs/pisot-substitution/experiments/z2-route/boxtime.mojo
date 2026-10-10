from std.sys import argv
from std.time import perf_counter_ns
from psc.vertex_coincidence import decide_vertex_coincidence_screened
from psc.coincidence_formula import coincidence_level

def member(a: Int, b: Int, e: Int) -> List[List[Int]]:
    var w1 = List[Int]()
    for _ in range(a):
        w1.append(2)
    for _ in range(b):
        w1.append(1)
    var w2 = List[Int]()
    for _ in range(b + 2 + e):
        w2.append(1)
    for _ in range(a + 1):
        w2.append(2)
    var sy = List[Int]([0]); sy.extend(w1.copy()); sy.append(0)
    var sz = List[Int]([0]); sz.extend(w2.copy()); sz.append(0)
    return List[List[Int]]([List[Int]([1]), sy^, sz^])

def main() raises:
    var args = argv()
    var a = Int(String(args[1])); var b = Int(String(args[2])); var e = Int(String(args[3]))
    var mode = String(args[4])
    var s = member(a, b, e)
    var t0 = perf_counter_ns()
    if mode == "box":
        var v = decide_vertex_coincidence_screened(s)
        print("box", a, b, e, "capped", v.capped, "states", v.states, "productive", v.productive, "D", v.coincidence_depth, "ms", (perf_counter_ns() - t0) // 1000000)
    else:
        var l = coincidence_level(s, 0, 1)
        print("lvl", a, b, e, "level", l, "ms", (perf_counter_ns() - t0) // 1000000)
