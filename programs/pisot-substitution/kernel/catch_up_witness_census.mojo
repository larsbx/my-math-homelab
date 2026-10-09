"""Exact all-path catch-up diagnostic and occurrence-address replay.

Usage (from kernel/):
  mojo run -I . catch_up_witness_census.mojo [standing|total8|len4 START END [records|failures] [CAP]]
  mojo run -I . catch_up_witness_census.mojo specimen MAX_LEN I J K
  mojo run -I . catch_up_witness_census.mojo replay MAX_LEN I J K TOP BOTTOM C0 C1 C2

Labels I J K index corpus.image_words_up_to(MAX_LEN). Vertex coordinates use
the canonical power basis 1,beta,beta^2, not transient graph indices.
`records` emits every recurrent nonzero vertex; `failures` emits all vertices
with no catch-up at either endpoint. Replay rebuilds the complete graph and
checks every child occurrence in a negative vertex's forward closure.
"""

from std.sys import argv
from finite_linear_algebra.mat3 import Mat3
from parallel_fold.map_fold import parallel_map_fold
from psc.bpa import substitution_incidence
from psc.corpus import Specimen, image_words_up_to, pip_corpus, pip_corpus_total_length, screened_triples, substitution_of
from psc.hit_witness import HitAnalysis, analyze_hits, hit_kind, occurrences, replay_births, simultaneous_closure, vertex_label, witness_path
from psc.overlap_seed_patch import OverlapState, SeedOverlapAutomaton, SeedOverlapTables, build_seed_overlap_tables
from psc.perron_field3 import CubicElt
from psc.vertex_coincidence import VERTEX_COINCIDENCE_STATE_CAP, build_box_graph

comptime WORKERS = 4


def record(spec: Specimen, st: OverlapState, h: HitAnalysis, v: Int) -> String:
    return String("{\"schema\":1,", spec.json_fields(), ",\"vertex\":[", vertex_label(st), "],\"catch_left\":", h.left[v], ",\"catch_right\":", h.right[v], ",\"new_left\":", h.new_left[v], ",\"new_right\":", h.new_right[v], "}")


struct Census(Copyable, Movable):
    var specimens: Int
    var capped: Int
    var recurrent: Int
    var left: Int
    var right: Int
    var either: Int
    var fail_specimens: Int
    var total_failures: Int
    var no_new_hit: Int
    var deepest: Int
    var failed_index: Int
    var lines: List[String]

    def __init__(out self):
        self.specimens = 0
        self.capped = 0
        self.recurrent = 0
        self.left = 0
        self.right = 0
        self.either = 0
        self.fail_specimens = 0
        self.total_failures = 0
        self.no_new_hit = 0
        self.deepest = -1
        self.failed_index = -1
        self.lines = List[String]()


def evaluate(spec: Specimen, mode: String, cap: Int) raises -> Census:
    var out = Census()
    out.specimens = 1
    var tables = build_seed_overlap_tables(spec.sigma)
    var a = build_box_graph(tables, cap)
    if a.capped:
        out.capped = 1
        out.lines.append(String("CAPPED specimen: ", spec.label()))
        return out^
    var h = analyze_hits(tables, a)
    for v in h.recurrent:
        out.recurrent += 1
        var left = h.left[v] > 0
        var right = h.right[v] > 0
        out.left += Int(left)
        out.right += Int(right)
        out.either += Int(left or right)
        if h.new_left[v] < 0 and h.new_right[v] < 0:
            out.no_new_hit += 1
        if left:
            out.deepest = max(out.deepest, h.left[v])
        if right:
            out.deepest = max(out.deepest, h.right[v])
        if mode == "records" or (mode == "failures" and not left and not right):
            out.lines.append(record(spec, a.states[v], h, v))
    if out.either < out.recurrent:
        out.fail_specimens = 1
        if out.either == 0:
            out.total_failures = 1
    return out^


def merge(a: Census, b: Census) -> Census:
    var out = a.copy()
    out.specimens += b.specimens
    out.capped += b.capped
    out.recurrent += b.recurrent
    out.left += b.left
    out.right += b.right
    out.either += b.either
    out.fail_specimens += b.fail_specimens
    out.total_failures += b.total_failures
    out.no_new_hit += b.no_new_hit
    out.deepest = max(out.deepest, b.deepest)
    if b.failed_index >= 0 and (out.failed_index < 0 or b.failed_index < out.failed_index):
        out.failed_index = b.failed_index
    for line in b.lines:
        out.lines.append(line.copy())
    return out^


def print_path(tables: SeedOverlapTables, a: SeedOverlapAutomaton, source: Int, dist: List[Int], right: Bool, catch_only: Bool) raises:
    if dist[source] < 0:
        return
    var path = witness_path(tables, a, source, dist, right, catch_only)
    var births = replay_births(tables, a.states[source], path, right)
    print("PATH endpoint:", "right" if right else "left", " target:", "catch-up" if catch_only else "new-hit", " depth:", len(path), " relative births (0 means already present):", births[0], births[1])
    var parent = a.states[source]
    for e in path:
        print("STEP", vertex_label(parent), " occurrence", e.top_index, e.bottom_index, " child", vertex_label(e.child), " hit-kind", hit_kind(tables, parent, e, right))
        parent = e.child


def replay(spec: Specimen, source: OverlapState) raises:
    var tables = build_seed_overlap_tables(spec.sigma)
    var a = build_box_graph(tables)
    var h = analyze_hits(tables, a)
    var v = -1
    for u in h.recurrent:
        if a.states[u] == source:
            v = u
            break
    if v < 0:
        raise Error("replay source is not a recurrent nonzero vertex of the complete box graph")
    print("REPLAY specimen:", spec.label(), " vertex:", vertex_label(source))
    print(record(spec, source, h, v))
    print_path(tables, a, v, h.new_left, False, False)
    print_path(tables, a, v, h.new_right, True, False)
    print_path(tables, a, v, h.left, False, True)
    print_path(tables, a, v, h.right, True, True)
    if h.left[v] < 0 and h.right[v] < 0:
        var closure = simultaneous_closure(tables, a, v)
        print("SIMULTANEOUS-ONLY closed certificate, vertices:", len(closure))
        var cache = Dict[CubicElt, Int]()
        for u in closure:
            var st = a.states[u]
            if st.is_coincidence():
                print("ABSORBING identical tiles", vertex_label(st))
                continue
            for e in occurrences(tables, st, cache):
                print("EDGE", vertex_label(st), " occurrence", e.top_index, e.bottom_index, " child", vertex_label(e.child), " left/right kinds", hit_kind(tables, st, e, False), hit_kind(tables, st, e, True))


def main() raises:
    var args = argv()
    var domain = String(args[1]) if len(args) > 1 else String("standing")
    if domain == "replay" or domain == "specimen":
        if len(args) != (11 if domain == "replay" else 6):
            raise Error("usage: specimen MAX_LEN I J K, or replay MAX_LEN I J K TOP BOTTOM C0 C1 C2")
        var max_len = Int(String(args[2]))
        if max_len < 1 or max_len > 6:
            raise Error("MAX_LEN must lie in 1..6")
        var words = image_words_up_to(max_len)
        var i = Int(String(args[3]))
        var j = Int(String(args[4]))
        var k = Int(String(args[5]))
        if i < 0 or j < 0 or k < 0 or max(i, max(j, k)) >= len(words):
            raise Error("specimen label lies outside the image-word domain")
        var sigma = substitution_of(words, i, j, k)
        # Tables validate PIP before a graph or verdict is produced.
        var tables = build_seed_overlap_tables(sigma)
        var spec = Specimen(0, i, j, k, sigma^, Mat3(substitution_incidence(tables.sigma)))
        if domain == "replay":
            replay(spec, OverlapState(Int(String(args[6])), Int(String(args[7])), CubicElt(Int(String(args[8])), Int(String(args[9])), Int(String(args[10])))))
        else:
            var r = evaluate(spec, "records", VERTEX_COINCIDENCE_STATE_CAP)
            for line in r.lines:
                print(line)
            print("specimen", spec.label(), " recurrent", r.recurrent, " catch-up left/right/either", r.left, r.right, r.either, " capped", r.capped)
        return
    if len(args) != 1 and (len(args) < 4 or len(args) > 6):
        raise Error("usage: [standing|total8|len4 START END [records|failures] [CAP]]")
    var corpus: List[Specimen]
    if domain == "standing":
        corpus = pip_corpus()
    elif domain == "total8":
        corpus = pip_corpus_total_length(8)
    elif domain == "len4":
        corpus = screened_triples(image_words_up_to(4), 12)
    else:
        raise Error("unknown canonical domain")
    var start = Int(String(args[2])) if len(args) > 2 else 0
    var end = Int(String(args[3])) if len(args) > 3 else len(corpus)
    var mode = String(args[4]) if len(args) > 4 else String("summary")
    var cap = Int(String(args[5])) if len(args) > 5 else VERTEX_COINCIDENCE_STATE_CAP
    if start < 0 or start > end or end > len(corpus) or cap < 1:
        raise Error("invalid domain slice or state cap")
    if mode != "records" and mode != "failures" and mode != "summary":
        raise Error("unknown output mode")
    print("Hit-witness census domain:", domain, " population:", len(corpus), " slice:", start, end, " cap:", cap)
    def one(s: Int) {corpus, start, mode, cap} -> Census:
        try:
            return evaluate(corpus[start + s], mode, cap)
        except:
            var failure = Census()
            failure.failed_index = start + s
            return failure^
    var r = parallel_map_fold(one, merge, Census(), end - start, WORKERS)
    if r.failed_index >= 0:
        _ = evaluate(corpus[r.failed_index], mode, cap)
        raise Error("hit-witness worker failure did not replay")
    print("specimens:", r.specimens, " complete:", r.specimens - r.capped, " capped:", r.capped)
    print("recurrent nonzero vertices:", r.recurrent, " catch-up left/right/either:", r.left, r.right, r.either)
    print("simultaneous-only vertices:", r.recurrent - r.either, " failing specimens:", r.fail_specimens, " total failures:", r.total_failures)
    print("vertices without any new hit:", r.no_new_hit, " maximum endpoint catch-up depth:", r.deepest)
    for line in r.lines:
        print(line)
