"""Exact census of all-pairs strong coincidence (SC_all) beyond the corpus.

SC_all, productivity of the six aligned pairs `(i, j, 0)`, is necessary for
pure discrete spectrum (Akiyama--Lee 2014 Cor. 4.5;
docs/pds-strong-coincidence-literature-gate-2026-10-04.md), so a PIP specimen
failing it would refute PSC. `psc.coincidence_formula` decides each pair
exactly; its exploration is finite by the Pisot property, so `-1` is a decided
negative, not a budget.

Each pair is split by mechanism. A pair *merged by the first-letter map*
`h(a) = sigma(a)[0]` (`h^n(i) = h^n(j)` for some `n`) coincides at the left end
of `sigma^n`, trivially; every other pair is *residual*, and the aligned route
(#138) is a statement about residual pairs only.

Lemma A (catch-up-free, `|det M| = 2`): an aligned pair has an offset-zero
child other than its leftmost one only if `h(a) = h(b)`, since by Lemma E every
nonempty proper prefix of `sigma(a)` holds exactly one E letter, `h(a)`. The
census checks it on every such pair. The census reports SC_all failures, the
residual pairs by depth, and the catch-up-free class (`psc.one_tile`) apart.

Usage: `mojo run -I . strong_coincidence_census.mojo [total [N] | len4]`
(standing corpus; total image length at most 8, or at most `N`; images of
length at most 4).
"""

from std.sys import argv
from parallel_fold.map_fold import parallel_map_fold
from finite_linear_algebra.mat3 import Mat3
from psc.bpa import substitution_incidence
from psc.coincidence_formula import balanced_proper_prefix_pairs, coincidence_level, first_letter_merge_level
from psc.corpus import Specimen, corpus_for, pip_corpus_total_length
from psc.one_tile import catch_up_free

comptime WORKERS = 4
comptime DEPTHS = 64


struct SCCensus(Copyable, Movable):
    var specimens: Int
    var failures: List[Int]
    var residual_specimens: Int
    var residual_pairs: Int
    var free: Int
    var free_residual: Int
    var residual_depths: List[Int]  # residual pairs by coincidence level
    var free_residual_depths: List[Int]
    var deepest: Int
    var deepest_index: Int
    var lemma_a_pairs: Int  # aligned pairs of catch-up-free |det M| = 2 specimens
    var lemma_a_violations: Int
    var interior_residual: Int  # residual pairs with an interior offset-zero child
    var failed_index: Int

    def __init__(out self):
        self.specimens = 0
        self.failures = List[Int]()
        self.residual_specimens = 0
        self.residual_pairs = 0
        self.free = 0
        self.free_residual = 0
        self.residual_depths = List[Int](length=DEPTHS, fill=0)
        self.free_residual_depths = List[Int](length=DEPTHS, fill=0)
        self.deepest = -1
        self.deepest_index = -1
        self.lemma_a_pairs = 0
        self.lemma_a_violations = 0
        self.interior_residual = 0
        self.failed_index = -1


def _first(a: Int, b: Int) -> Int:
    if a < 0:
        return b
    if b < 0:
        return a
    return min(a, b)


def merge(a: SCCensus, b: SCCensus) -> SCCensus:
    var out = a.copy()
    out.specimens += b.specimens
    out.failures += b.failures.copy()
    out.residual_specimens += b.residual_specimens
    out.residual_pairs += b.residual_pairs
    out.free += b.free
    out.free_residual += b.free_residual
    for k in range(DEPTHS):
        out.residual_depths[k] += b.residual_depths[k]
        out.free_residual_depths[k] += b.free_residual_depths[k]
    if b.deepest > out.deepest or (b.deepest == out.deepest and b.deepest_index < out.deepest_index):
        out.deepest = b.deepest
        out.deepest_index = b.deepest_index
    out.lemma_a_pairs += b.lemma_a_pairs
    out.lemma_a_violations += b.lemma_a_violations
    out.interior_residual += b.interior_residual
    out.failed_index = _first(out.failed_index, b.failed_index)
    return out^


def images(sigma: List[List[Int]]) -> String:
    var out = String("")
    for a in range(len(sigma)):
        out += (", " if a > 0 else "") + String(a) + " -> "
        for x in range(len(sigma[a])):
            out += String(sigma[a][x])
    return out


def _histogram(label: String, h: List[Int]):
    var line = label
    for k in range(DEPTHS):
        if h[k] > 0:
            line += " " + String(k) + ":" + String(h[k])
    print(line)


def main() raises:
    var args = argv()
    var mode = String(args[1]) if len(args) > 1 else String("")
    var corpus = pip_corpus_total_length(Int(args[2])) if mode == "total" and len(args) > 2 else corpus_for(mode)

    def one(s: Int) {corpus} -> SCCensus:
        var out = SCCensus()
        out.specimens = 1
        try:
            ref sigma = corpus[s].sigma
            var free = catch_up_free(sigma)
            out.free = Int(free)
            var det2 = abs(Mat3(substitution_incidence(sigma)).det()) == 2
            var residual = 0
            var failed = False
            for i in range(3):
                for j in range(i + 1, 3):
                    var interior = balanced_proper_prefix_pairs(sigma, i, j) > 0
                    var merge = first_letter_merge_level(sigma, i, j)
                    if free and det2:
                        out.lemma_a_pairs += 1
                        out.lemma_a_violations += Int(interior and merge != 1)
                    var level = coincidence_level(sigma, i, j)
                    if level < 0:
                        failed = True
                        continue
                    if merge >= 0:
                        continue
                    residual += 1
                    out.interior_residual += Int(interior)
                    if level >= DEPTHS:
                        raise Error("coincidence level beyond the histogram")
                    out.residual_depths[level] += 1
                    if free:
                        out.free_residual_depths[level] += 1
                    if level > out.deepest:
                        out.deepest = level
                        out.deepest_index = s
            if failed:
                out.failures.append(s)
            out.residual_pairs = residual
            out.residual_specimens = Int(residual > 0)
            out.free_residual = Int(free and residual > 0)
        except:
            out.failed_index = s
        return out^

    var r = parallel_map_fold(one, merge, SCCensus(), len(corpus), WORKERS)
    if r.failed_index >= 0:
        raise Error("strong coincidence census: worker failure at " + corpus[r.failed_index].label())
    print("SC_all census, specimens:", r.specimens)
    print("SC_all failures:", len(r.failures))
    for i in range(min(len(r.failures), 12)):
        print("SC_all fails:", images(corpus[r.failures[i]].sigma))
    print("specimens with a residual pair (not merged by the first-letter map):", r.residual_specimens, " residual pairs:", r.residual_pairs)
    print("residual pairs with an interior offset-zero child:", r.interior_residual)
    print("catch-up-free:", r.free, " with a residual pair:", r.free_residual)
    print("Lemma A, catch-up-free |det M| = 2 aligned pairs:", r.lemma_a_pairs, " violations:", r.lemma_a_violations)
    _histogram("residual pairs by coincidence level:", r.residual_depths)
    _histogram("catch-up-free residual pairs by level:", r.free_residual_depths)
    if r.deepest_index >= 0:
        print("deepest residual pair: level", r.deepest, "on", images(corpus[r.deepest_index].sigma))
