"""Exact census: which specimens have a power or conjugate in Barge's class.

For every specimen of the standing corpus (or, with `total`, of total image
length at most 8), `psc.barge_class` searches `sigma^n`, `n <= MAX_POWER`,
and its maximal common-prefix and common-suffix rotations for membership in
Barge's 2016 PDS class (injective on initial letters, constant on final
letters) or its mirror. A witness gives pure discrete spectrum, hence PPVC
(Theorem S), for that specimen; the census counts witnesses overall and in
the catch-up-free class, where T2 is PPVC itself
(docs/p1b-vertex-coincidence-box-2026-10-02.md §5.6g). No witness within
`MAX_POWER` is not a verdict. Folded in canonical order on `parallel_fold`.

Usage: `mojo run -I . barge_class_census.mojo [total]`.
"""

from std.sys import argv
from parallel_fold.map_fold import parallel_map_fold
from psc.barge_class import KIND_DIRECT, KIND_LEFT_ROTATION, KIND_RIGHT_ROTATION, barge_witness
from psc.corpus import Specimen, corpus_for
from finite_linear_algebra.mat3 import Mat3
from psc.bpa import substitution_incidence
from psc.one_tile import catch_up_free
from psc.valuation_ascent import letter_classes

comptime WORKERS = 4
comptime MAX_POWER = 6


struct BargeCensus(Copyable, Movable):
    var specimens: Int
    var witnessed: Int
    var free: Int
    var free_witnessed: Int
    var by_power: List[Int]  # index n: specimens whose least witness power is n
    var by_kind: List[Int]  # direct, left rotation, right rotation
    var mirror: Int
    var free_missing: List[Int]
    var strata: List[Int]  # catch-up-free, |det M| = 2: [|E|][short][witnessed] flattened
    var free_other_det: List[Int]  # catch-up-free, |det M| != 2: [without, with]
    var failed_index: Int

    def __init__(out self):
        self.specimens = 0
        self.witnessed = 0
        self.free = 0
        self.free_witnessed = 0
        self.by_power = List[Int](length=MAX_POWER + 1, fill=0)
        self.by_kind = List[Int](length=4, fill=0)
        self.mirror = 0
        self.free_missing = List[Int]()
        self.strata = List[Int](length=4 * 4 * 2, fill=0)
        self.free_other_det = List[Int](length=2, fill=0)
        self.failed_index = -1


def merge(a: BargeCensus, b: BargeCensus) -> BargeCensus:
    var out = a.copy()
    out.specimens += b.specimens
    out.witnessed += b.witnessed
    out.free += b.free
    out.free_witnessed += b.free_witnessed
    for k in range(MAX_POWER + 1):
        out.by_power[k] += b.by_power[k]
    for k in range(4):
        out.by_kind[k] += b.by_kind[k]
    out.mirror += b.mirror
    out.free_missing += b.free_missing.copy()
    for k in range(len(out.strata)):
        out.strata[k] += b.strata[k]
    for k in range(2):
        out.free_other_det[k] += b.free_other_det[k]
    if b.failed_index >= 0 and (out.failed_index < 0 or b.failed_index < out.failed_index):
        out.failed_index = b.failed_index
    return out^


def main() raises:
    var args = argv()
    var corpus = corpus_for(String(args[1]) if len(args) > 1 else String(""))

    def one(s: Int) {corpus} -> BargeCensus:
        var out = BargeCensus()
        out.specimens = 1
        try:
            var w = barge_witness(corpus[s].sigma, MAX_POWER)
            var free = catch_up_free(corpus[s].sigma)
            out.free = Int(free)
            if w.found():
                out.witnessed = 1
                out.free_witnessed = Int(free)
                out.by_power[w.power] += 1
                out.by_kind[w.kind] += 1
                out.mirror = Int(w.mirror)
            elif free:
                out.free_missing.append(s)
            if free:
                var m = Mat3(substitution_incidence(corpus[s].sigma))
                if abs(m.det()) == 2:
                    var chi = letter_classes(m)
                    var e = chi[0] + chi[1] + chi[2]
                    var short = 0
                    for a in range(3):
                        short += Int(len(corpus[s].sigma[a]) == 1)
                    out.strata[(e * 4 + short) * 2 + Int(w.found())] += 1
                else:
                    out.free_other_det[Int(w.found())] += 1
        except:
            out.failed_index = s
        return out^

    var r = parallel_map_fold(one, merge, BargeCensus(), len(corpus), WORKERS)
    if r.failed_index >= 0:
        _ = barge_witness(corpus[r.failed_index].sigma, MAX_POWER)
        raise Error("Barge class census: worker failure did not replay")
    print("Barge-class conjugacy census, specimens:", r.specimens, " max power:", MAX_POWER)
    print("with a witness:", r.witnessed, " (mirror class:", r.mirror, ")")
    print("catch-up-free:", r.free, " with a witness:", r.free_witnessed, " without:", len(r.free_missing))
    var line = String("witnessed specimens by least power:")
    for n in range(1, MAX_POWER + 1):
        line += " " + String(n) + ":" + String(r.by_power[n])
    print(line)
    print(
        "by kind: direct", r.by_kind[KIND_DIRECT], " left rotation", r.by_kind[KIND_LEFT_ROTATION],
        " right rotation", r.by_kind[KIND_RIGHT_ROTATION],
    )
    for e in range(4):
        for sh in range(4):
            var o = (e * 4 + sh) * 2
            if r.strata[o] + r.strata[o + 1] > 0:
                print(
                    "catch-up-free |det M| = 2, |E| =", e, " length-1 images =", sh,
                    ": specimens", r.strata[o] + r.strata[o + 1], " with a witness", r.strata[o + 1],
                )
    if r.free_other_det[0] + r.free_other_det[1] > 0:
        print("catch-up-free |det M| != 2: specimens", r.free_other_det[0] + r.free_other_det[1], " with a witness", r.free_other_det[1])
    for i in range(min(len(r.free_missing), 12)):
        print("catch-up-free without a witness:", corpus[r.free_missing[i]].label())
