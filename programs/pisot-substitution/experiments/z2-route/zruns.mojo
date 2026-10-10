from std.sys import argv
from std.time import perf_counter_ns
from odd_letter_family_certificate import RunPattern, ShapeCover, cover_pattern_guided, Y, Z

def alt(first: Int, n: Int) -> List[Int]:
    var out = List[Int]()
    var c = first
    for _ in range(n):
        out.append(c)
        c = Z if c == Y else Y
    return out^

def patterns(s: Int, d: Int, r1: Int, r2: Int) -> List[RunPattern]:
    var l2s = List[List[Int]]()
    l2s.append(List[Int]())
    for first in [Y, Z]:
        for n in range(1, r2 + 1):
            l2s.append(alt(first, n))
    var out = List[RunPattern]()
    for n1 in range(1, r1 + 1):
        for j in range(len(l2s)):
            var pat = RunPattern(alt(Z, n1), False, l2s[j].copy(), False)
            if s == 1:
                pat.tail_run1 = d
            out.append(pat^)
    return out^

def run(pat: RunPattern, s: Int, d: Int, floor: Int, budget: Int, q_lift: Bool) raises -> ShapeCover:
    var t0 = perf_counter_ns()
    var c = cover_pattern_guided(pat, s, d, budget, True, z_floor=floor, q_lift=q_lift)
    var ok = c.open == 0 and not c.budget_exhausted
    print("   ", "qlift" if q_lift else "plain", "closed" if ok else "OPEN  ", pat, " regions", c.regions, " open", c.open, " budget", c.budget_exhausted, " secs", (perf_counter_ns() - t0) // 1000000000, flush=True)
    return c^

def main() raises:
    # zruns s delta floor r1 r2 budget [qlift 0/1]   every pattern, one cover
    # zruns s delta floor r1 r2 budget count         number of patterns
    # zruns s delta floor r1 r2 budget at <i>        pattern i: plain, then q-lift if open
    # zruns s delta floor r1 r2 budget at <i> plain|qlift   that one stage alone
    var args = argv()
    var s = Int(String(args[1]))
    var d = Int(String(args[2]))
    var floor = Int(String(args[3]))
    var budget = Int(String(args[6]))
    var mode = String(args[7]) if len(args) > 7 else String("0")
    var pats = patterns(s, d, Int(String(args[4])), Int(String(args[5])))
    if mode == "count":
        print(len(pats))
        return
    if mode == "at":
        var i = Int(String(args[8]))
        if i < 0 or i >= len(pats):
            raise Error("pattern index out of range")
        var stage = String(args[9]) if len(args) > 9 else String("both")
        if stage != "both" and stage != "plain" and stage != "qlift":
            raise Error("stage must be plain or qlift")
        print("PATTERN", pats[i], flush=True)
        if stage != "qlift":
            var c = run(pats[i], s, d, floor, budget, False)
            if c.open == 0 and not c.budget_exhausted:
                print("VERDICT plain")
                return
            if stage == "plain":
                print("VERDICT open")
                return
        var c = run(pats[i], s, d, floor, budget, True)
        print("VERDICT", "qlift" if c.open == 0 and not c.budget_exhausted else "open")
        return
    var q_lift = mode == "1"
    var closed = 0
    var regions = 0
    for i in range(len(pats)):
        var c = run(pats[i], s, d, floor, budget, q_lift)
        regions += c.regions
        if c.open == 0 and not c.budget_exhausted:
            closed += 1
    print("s =", s, " |Delta| >=", abs(d), " Z_2 >=", floor, " q-lift" if q_lift else "", ": patterns", len(pats), " closed", closed, " regions", regions)
