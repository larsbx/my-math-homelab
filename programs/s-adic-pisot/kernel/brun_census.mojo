"""Census of the primitive periodic points of the unordered Brun algorithm.

For every Lyndon word w of length 1..L with w^infinity admissible under BST23
(6.10), run the verdict pipeline of kernel/sadic/periodic.mojo on the
composite sigma_w: primitive -> irreducible -> Pisot -> balanced pair
algorithm. Prints one summary line per length and every word whose verdict is
neither a certified exclusion nor `bpa:terminates`.

Usage: mojo run -I . brun_census.mojo [d] [L] [max_states] [max_length] [orbits]
(defaults 4 7 200000 20000). With `orbits`, one word per orbit under rotation
and letter permutation is classified (verdicts are orbit invariants: a
relabelling conjugates the composite) and its count is weighted by the orbit
size. Primitivity, irreducibility, Pisot and the mirror Barge class are
budget-free, so they are weighted. Balanced-pair outcomes depend on the
budgets, which a conjugate may exhaust differently, so they are reported per
orbit representative (`bpa-reps`), unweighted. Specification: docs/sadic-g3-brun4-census.md
(d = 4) and docs/sadic-g6-brun-higher-census.md (d >= 5).
"""

from std.sys import argv

from substitution_dynamics.barge_class import in_mirror_class
from sadic.periodic import brun_orbit_words, brun_unordered, is_open_verdict, periodic_verdict, periodic_words, verdict_index, verdict_names

def joined(w: List[Int]) -> String:
    var s = String("")
    for i in range(len(w)):
        if i > 0:
            s += ","
        s += String(w[i])
    return s


def main() raises:
    var args = argv()
    var d = Int(args[1]) if len(args) > 1 else 4
    var max_len = Int(args[2]) if len(args) > 2 else 7
    var max_states = Int(args[3]) if len(args) > 3 else 200000
    var max_length = Int(args[4]) if len(args) > 4 else 20000
    var orbits = len(args) > 5 and args[5] == "orbits"
    var shift = brun_unordered(d)
    print("Brun d=" + String(d) + " periodic census, periods 1.." + String(max_len) + ", BPA budgets " + String(max_states) + " states, length " + String(max_length))
    var names = verdict_names()
    var stages = len(names)
    var total = List[Int]()
    var total_reps = List[Int]()
    for _ in range(stages):
        total.append(0)
        total_reps.append(0)
    for n in range(1, max_len + 1):
        var counts = List[Int]()
        var reps = List[Int]()
        for _ in range(stages):
            counts.append(0)
            reps.append(0)
        # (word, weight): every word with weight 1, or one word per orbit
        # weighted by the orbit size
        var entries = List[List[Int]]()
        if orbits:
            entries = brun_orbit_words(d, n)
        else:
            for w in periodic_words(shift, n):
                var e = w.copy()
                e.append(1)
                entries.append(e^)
        var covered = 0
        var pip = 0
        var barge = 0
        for e in entries:
            var weight = e[len(e) - 1]
            var w = List[Int](e[0 : len(e) - 1])
            var v = periodic_verdict(shift, w, max_states, max_length)
            var i = verdict_index(v)
            if v.startswith("bpa:"):
                # primitive, irreducible and Pisot: Theorem B places the
                # composite's reversal in Barge's class
                pip += weight
                if in_mirror_class(shift.composite(w)):
                    barge += weight
            if orbits and v.startswith("bpa:"):
                # budget-dependent: one count per representative
                reps[i] += 1
                total_reps[i] += 1
            else:
                counts[i] += weight
                total[i] += weight
            covered += weight
            if is_open_verdict(v):
                print("  open: period " + String(n) + " word " + joined(w) + " (weight " + String(weight) + ") -> " + v)
        var line = "period " + String(n) + ": words " + String(covered)
        if orbits:
            line += " (orbits " + String(len(entries)) + ")"
        for i in range(stages):
            if not (orbits and names[i].startswith("bpa:")):
                line += "  " + names[i] + " " + String(counts[i])
        line += "  pip " + String(pip) + "  barge-mirror " + String(barge)
        if orbits:
            line += "  bpa-reps"
            for i in range(stages):
                if names[i].startswith("bpa:"):
                    line += " " + names[i] + " " + String(reps[i])
        print(line)
    var line = "total:"
    for i in range(stages):
        if not (orbits and names[i].startswith("bpa:")):
            line += "  " + names[i] + " " + String(total[i])
    if orbits:
        line += "  bpa-reps"
        for i in range(stages):
            if names[i].startswith("bpa:"):
                line += " " + names[i] + " " + String(total_reps[i])
    print(line)
