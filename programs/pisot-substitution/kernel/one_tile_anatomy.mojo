"""Exact anatomy of the one-tile analysis on the standing corpus.

The side computations behind docs/p1b-vertex-coincidence-box-2026-10-02.md
§5.6b, each exact on every specimen (`psc.one_tile`):

- Q1 failures by spectral class (`|det M|`, real or complex contracting pair);
- the closure sizes of the Q1-failing vertices outside the catch-up-free class;
- one-step catch-ups: recurrent vertices whose leftmost child is offset zero,
  on the specimens that are not catch-up-free (the converse of Lemma P asks
  whether some recurrent vertex reaches a catch-up), and whether the
  specimens without one still satisfy Q1 through longer leftmost chains;
- diagonal hits `(c, c, 0)` against off-diagonal hits `(c, d, 0)`, `c != d`:
  how many recurrent vertices reach each kind through nonzero offsets (a
  diagonal state is an exact tile coincidence and is terminal in the box
  graph; an off-diagonal offset-zero state is expanded), and on
  how many catch-up-free specimens every recurrent vertex reaches a diagonal
  hit.

Folded in canonical order on `parallel_fold`. Usage:
`mojo run -I . one_tile_anatomy.mojo`.
"""

from finite_linear_algebra.mat3 import Mat3
from parallel_fold.map_fold import parallel_map_fold
from psc.bpa import substitution_incidence
from psc.corpus import cubic_discriminant, pip_corpus
from psc.one_tile import (
    _cu_marks,
    _reaches_cu,
    _recurrent_nonzero,
    catch_up_free,
    leftmost_child,
    nonzero_closure_size,
    reaches_hit_kind,
)
from psc.overlap_seed_patch import build_seed_overlap_tables
from psc.perron_field3 import CubicElt
from psc.vertex_coincidence import build_box_graph

comptime WORKERS = 4
comptime CLASSES = 3  # 0: |det| 1 real, 1: |det| 1 complex, 2: |det| 2 complex


struct Anatomy(Copyable, Movable):
    var specimens: List[Int]
    var partial: List[Int]
    var total: List[Int]
    var closure1: Int
    var closure2: Int
    var closure_more: Int
    var not_free: Int
    var one_step_specimens: Int
    var one_step_vertices: Int
    var no_one_step: List[Int]
    var no_one_step_q1_fail: Int
    var recurrent: Int
    var reach_diag: Int
    var reach_off: Int
    var free_all_diag: Int
    var free_some_not: Int
    var free_not_diag_vertices: Int
    var failed_index: Int

    def __init__(out self):
        self.specimens = List[Int](length=CLASSES, fill=0)
        self.partial = List[Int](length=CLASSES, fill=0)
        self.total = List[Int](length=CLASSES, fill=0)
        self.closure1 = 0
        self.closure2 = 0
        self.closure_more = 0
        self.not_free = 0
        self.one_step_specimens = 0
        self.one_step_vertices = 0
        self.no_one_step = List[Int]()
        self.no_one_step_q1_fail = 0
        self.recurrent = 0
        self.reach_diag = 0
        self.reach_off = 0
        self.free_all_diag = 0
        self.free_some_not = 0
        self.free_not_diag_vertices = 0
        self.failed_index = -1


def merge(a: Anatomy, b: Anatomy) -> Anatomy:
    var o = a.copy()
    for c in range(CLASSES):
        o.specimens[c] += b.specimens[c]
        o.partial[c] += b.partial[c]
        o.total[c] += b.total[c]
    o.closure1 += b.closure1
    o.closure2 += b.closure2
    o.closure_more += b.closure_more
    o.not_free += b.not_free
    o.one_step_specimens += b.one_step_specimens
    o.one_step_vertices += b.one_step_vertices
    for i in range(len(b.no_one_step)):
        o.no_one_step.append(b.no_one_step[i])
    o.no_one_step_q1_fail += b.no_one_step_q1_fail
    o.recurrent += b.recurrent
    o.reach_diag += b.reach_diag
    o.reach_off += b.reach_off
    o.free_all_diag += b.free_all_diag
    o.free_some_not += b.free_some_not
    o.free_not_diag_vertices += b.free_not_diag_vertices
    if b.failed_index >= 0 and (o.failed_index < 0 or b.failed_index < o.failed_index):
        o.failed_index = b.failed_index
    return o^


def spectral_class(sigma: List[List[Int]]) raises -> Int:
    var m = Mat3(substitution_incidence(sigma))
    var d = abs(m.det())
    var complex = cubic_discriminant(m.charpoly()) < 0
    if d == 1:
        return 1 if complex else 0
    if d == 2 and complex:
        return 2
    raise Error("spectral class outside the standing corpus")


def anatomy(sigma: List[List[Int]], mut o: Anatomy) raises -> Bool:
    """Fill `o` for one specimen; returns whether it has no one-step catch-up
    (only meaningful when it is not catch-up-free)."""
    var cls = spectral_class(sigma)
    o.specimens[cls] = 1
    var free = catch_up_free(sigma)
    var t = build_seed_overlap_tables(sigma)
    var a = build_box_graph(t)
    var good = _reaches_cu(a, _cu_marks(t, a))
    var diag = reaches_hit_kind(a, True)
    var off = reaches_hit_kind(a, False)
    var rec = _recurrent_nonzero(a)
    var cache = Dict[CubicElt, Int]()
    var failing = 0
    var one_step = 0
    var not_diag = 0
    for k in range(len(rec)):
        var v = rec[k]
        o.recurrent += 1
        if diag[v]:
            o.reach_diag += 1
        else:
            not_diag += 1
        if off[v]:
            o.reach_off += 1
        if leftmost_child(t, cache, a.states[v]).shift.is_zero():
            one_step += 1
        if not good[v]:
            failing += 1
            if not free:
                var size = nonzero_closure_size(a, v, 2)
                if size == 1:
                    o.closure1 += 1
                elif size == 2:
                    o.closure2 += 1
                else:
                    o.closure_more += 1
    if failing == len(rec) and failing > 0:
        o.total[cls] = 1
    elif failing > 0:
        o.partial[cls] = 1
    if free:
        if not_diag == 0:
            o.free_all_diag = 1
        else:
            o.free_some_not = 1
            o.free_not_diag_vertices = not_diag
        return False
    o.not_free = 1
    o.one_step_vertices = one_step
    if one_step > 0:
        o.one_step_specimens = 1
        return False
    if failing > 0:
        o.no_one_step_q1_fail = 1
    return True


def main() raises:
    var corpus = pip_corpus()

    def one(s: Int) {corpus} -> Anatomy:
        var o = Anatomy()
        try:
            if anatomy(corpus[s].sigma, o):
                o.no_one_step.append(s)
        except:
            o.failed_index = s
        return o^

    var r = parallel_map_fold(one, merge, Anatomy(), len(corpus), WORKERS)
    if r.failed_index >= 0:
        var o = Anatomy()
        _ = anatomy(corpus[r.failed_index].sigma, o)
        raise Error("one-tile anatomy: worker failure did not replay")
    var names: List[String] = ["|det M| 1 real", "|det M| 1 complex", "|det M| 2 complex"]
    print("One-tile anatomy, specimens:", len(corpus))
    for c in range(CLASSES):
        print("class", names[c], ": specimens", r.specimens[c], " Q1 partial", r.partial[c], " Q1 total", r.total[c])
    print("Q1-failing vertices outside the catch-up-free class by nonzero closure size: 1:", r.closure1, " 2:", r.closure2, " >2:", r.closure_more)
    print("not catch-up-free:", r.not_free, " with a recurrent one-step catch-up:", r.one_step_specimens, " recurrent one-step vertices:", r.one_step_vertices, " without:", len(r.no_one_step))
    print("specimens without a recurrent one-step catch-up that fail Q1:", r.no_one_step_q1_fail)
    print("recurrent vertices:", r.recurrent, " reach a diagonal hit:", r.reach_diag, " reach an off-diagonal hit:", r.reach_off)
    print("catch-up-free: every recurrent vertex reaches a diagonal hit:", r.free_all_diag, " not:", r.free_some_not, " vertices reaching none:", r.free_not_diag_vertices)
    for i in range(len(r.no_one_step)):
        print("no recurrent one-step catch-up:", corpus[r.no_one_step[i]].label())
