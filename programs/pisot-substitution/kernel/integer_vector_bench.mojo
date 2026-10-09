"""Does the dimension-three unroll earn its place in the canonical kernel?

The measurements in `docs/fixed-dimension-kernel-to-mojo-2026-09-28.md`
record a 3.2x speedup for a pure-Python fixed-size vector unroll. Its generator
expressions and `zip` are interpreted, so the corresponding optimisation in
the canonical kernel needs its own measurement.

Measurement discipline (docs/census-performance-handoff-2026-09-18.md): each
loop prints a checksum that depends on every value it computes, so the work
cannot be optimised away and then measure as free. Both paths print the same
checksum, which is also the differential: a faster kernel that computes
something else is not a faster kernel.
"""

from std.time import perf_counter_ns

from psc.corpus import pip_corpus
from psc.bpa import substitution_incidence
from finite_linear_algebra.integer_vector import (
    add,
    add_general,
    matvec,
    matvec_general,
    sub,
    sub_general,
)


comptime REPEATS = 300
"""Passes over the corpus matrices, so the timed region dominates start-up."""


def _matrices() raises -> List[List[List[Int]]]:
    """One 3x3 integer matrix per distinct corpus incidence, as row lists."""
    var corpus = pip_corpus()
    var seen = Dict[String, Int]()
    var out = List[List[List[Int]]]()
    for s in range(len(corpus)):
        var e = substitution_incidence(corpus[s].sigma)
        var key = String("")
        for i in range(9):
            key += String(e[i]) + ","
        if key in seen:
            continue
        seen[key] = 1
        var rows = List[List[Int]]()
        for i in range(3):
            var row: List[Int] = [e[3 * i], e[3 * i + 1], e[3 * i + 2]]
            rows.append(row^)
        out.append(rows^)
    return out^


def main() raises:
    var mats = _matrices()
    print("distinct corpus incidence matrices:", len(mats), " repeats:", REPEATS)

    var seed: List[Int] = [1, 2, 3]

    var t0 = perf_counter_ns()
    var check_unrolled = 0
    for _ in range(REPEATS):
        for k in range(len(mats)):
            var r = matvec(mats[k], seed)
            check_unrolled += r[0] + r[1] + r[2]
    var t1 = perf_counter_ns()

    var check_general = 0
    for _ in range(REPEATS):
        for k in range(len(mats)):
            var r = matvec_general(mats[k], seed)
            check_general += r[0] + r[1] + r[2]
    var t2 = perf_counter_ns()

    var check_add = 0
    for _ in range(REPEATS):
        for k in range(len(mats)):
            var r = add(mats[k][0], mats[k][1])
            var d = sub(mats[k][2], mats[k][0])
            check_add += r[0] + r[1] + r[2] + d[0] + d[1] + d[2]
    var t3 = perf_counter_ns()

    var check_add_general = 0
    for _ in range(REPEATS):
        for k in range(len(mats)):
            var r = add_general(mats[k][0], mats[k][1])
            var d = sub_general(mats[k][2], mats[k][0])
            check_add_general += r[0] + r[1] + r[2] + d[0] + d[1] + d[2]
    var t4 = perf_counter_ns()

    var calls = REPEATS * len(mats)
    print("matvec calls per path:", calls)
    print("matvec unrolled ns:", t1 - t0, " checksum:", check_unrolled)
    print("matvec general  ns:", t2 - t1, " checksum:", check_general)
    print("matvec checksums equal:", check_unrolled == check_general)
    print("add/sub canonical ns:", t3 - t2, " checksum:", check_add)
    print("add/sub general   ns:", t4 - t3, " checksum:", check_add_general)
    print("add/sub checksums equal:", check_add == check_add_general)
