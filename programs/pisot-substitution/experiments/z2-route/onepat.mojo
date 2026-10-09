from std.sys import argv
from std.time import perf_counter_ns
from odd_letter_family_certificate import RunPattern, cover_pattern_guided, Y, Z

def letters(w: String) -> List[Int]:
    var out = List[Int]()
    for c in w.codepoint_slices():
        if c == "y":
            out.append(Y)
        elif c == "z":
            out.append(Z)
    return out^

def main() raises:
    # onepat s d floor budget l1 open1 l2 open2   (l1/l2 like "zy", "-" for empty)
    var args = argv()
    var s = Int(String(args[1]))
    var d = Int(String(args[2]))
    var floor = Int(String(args[3]))
    var budget = Int(String(args[4]))
    var pat = RunPattern(letters(String(args[5])), String(args[6]) == "1", letters(String(args[7])), String(args[8]) == "1")
    var tail = True
    if tail:
        pat.tail_run1 = d
    var t0 = perf_counter_ns()
    var c = cover_pattern_guided(pat, s, d, budget, tail, True, z_floor=floor)
    print(pat, ": regions", c.regions, "certified", c.certified, "line", c.line_certified, "crossing", c.crossing_certified, "cut", c.cut, "not member", c.not_member, "open", c.open, "budget", c.budget_exhausted, "secs", (perf_counter_ns() - t0) // 1000000000)
