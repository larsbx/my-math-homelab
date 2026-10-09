"""Exact census: is every terminal leftmost cycle a prefix-vs-interior pair?

Proposition LC of docs/p1b-leftmost-chain-periodic-pair-2026-10-05.md. The
leftmost child is a function on nonzero-offset vertices, so each such vertex's
chain either reaches offset zero -- the vertex is in `CU`, a catch-up hit --
or runs into a terminal cycle, and those cycles are exactly the witnesses that
`CU` is missed. For each standing-corpus specimen this census reads off every
terminal cycle of that function and checks the proposition's two assertions:

- the offset keeps one strict sign along the cycle, so the index used on the
  side whose tile starts later is `0` at every step;
- composed over the cycle, that side's index in `sigma^r` is `0` with a
  nonempty tail -- a prefix occurrence `sigma^r(i) = i U` -- and the other
  side's index is strictly interior -- an interior occurrence
  `sigma^r(j) = Q j V` with `Q`, `V` nonempty.

The offset `w0 = (I - M^r)^{-1} pi(Q)` is replayed over Z where `M^r` stays in
the exact integer range (`MAX_INTEGRAL_R`), and a longer cycle is reported in
its own column rather than assumed: an uncomputed offset is not a verdict. A
capped box graph is likewise reported, never counted as a pass.

A specimen with no terminal cycle is one where every nonzero-offset vertex
reaches a catch-up; the catch-up-free specimens are at the other extreme,
where every recurrent vertex runs into a cycle. Both counts are reported, so
the census also says how the leftmost-chain picture lines up with the Q1
trichotomy of `one_tile_census.mojo`.

Usage: `mojo run -I . leftmost_chain_census.mojo [total]`. With `total` it
surveys the 24,486 specimens of total image length at most 8.
"""

from std.sys import argv
from parallel_fold.map_fold import parallel_map_fold
from psc.corpus import Specimen, corpus_for
from psc.leftmost_chain import certify_leftmost_cycles, terminal_leftmost_cycles
from psc.one_tile import catch_up_free
from psc.overlap_seed_patch import build_seed_overlap_tables
from psc.vertex_coincidence import build_box_graph

comptime WORKERS = 2
comptime MAX_INTEGRAL_R = 12


struct LeftmostCensus(Copyable, Movable):
    var specimens: Int
    var cycles: Int
    var sign_constant: Int
    var prefix_vs_interior: Int
    var offsets_certified: Int
    var offsets_beyond_range: Int
    var offset_failures: Int
    var max_r: Int
    var capped: Int
    var cycle_free: Int
    var free_with_cycles: Int
    var free_without_cycles: List[Int]
    var failed_index: Int

    def __init__(out self):
        self.specimens = 0
        self.cycles = 0
        self.sign_constant = 0
        self.prefix_vs_interior = 0
        self.offsets_certified = 0
        self.offsets_beyond_range = 0
        self.offset_failures = 0
        self.max_r = 0
        self.capped = 0
        self.cycle_free = 0
        self.free_with_cycles = 0
        self.free_without_cycles = List[Int]()
        self.failed_index = -1


def merge(a: LeftmostCensus, b: LeftmostCensus) -> LeftmostCensus:
    var out = a.copy()
    out.specimens += b.specimens
    out.cycles += b.cycles
    out.sign_constant += b.sign_constant
    out.prefix_vs_interior += b.prefix_vs_interior
    out.offsets_certified += b.offsets_certified
    out.offsets_beyond_range += b.offsets_beyond_range
    out.offset_failures += b.offset_failures
    if b.max_r > out.max_r:
        out.max_r = b.max_r
    out.capped += b.capped
    out.cycle_free += b.cycle_free
    out.free_with_cycles += b.free_with_cycles
    for i in range(len(b.free_without_cycles)):
        out.free_without_cycles.append(b.free_without_cycles[i])
    if b.failed_index >= 0 and (out.failed_index < 0 or b.failed_index < out.failed_index):
        out.failed_index = b.failed_index
    return out^


def require_complete_census(r: LeftmostCensus) raises:
    """A capped or refuted census must refuse a successful process verdict.

    Offsets beyond the declared replay range remain a separate, uncomputed
    column; this gate certifies sign/shape and the integral replays performed.
    """
    if r.capped != 0:
        raise Error("leftmost-chain census: a capped box graph is inconclusive")
    if r.sign_constant != r.cycles or r.prefix_vs_interior != r.cycles or r.offset_failures != 0:
        raise Error("Proposition LC refuted on this domain")


def main() raises:
    var args = argv()
    var corpus = corpus_for(String(args[1]) if len(args) > 1 else String(""))

    def one(s: Int) {corpus} -> LeftmostCensus:
        var out = LeftmostCensus()
        out.specimens = 1
        try:
            var tables = build_seed_overlap_tables(corpus[s].sigma)
            var a = build_box_graph(tables)
            var v = certify_leftmost_cycles(tables, a, MAX_INTEGRAL_R)
            if v.capped:
                out.capped = 1
                return out^
            out.cycles = v.cycles
            out.sign_constant = v.sign_constant
            out.prefix_vs_interior = v.prefix_vs_interior
            out.offsets_certified = v.offsets_certified
            out.offsets_beyond_range = v.offsets_beyond_range
            out.offset_failures = v.offset_failures
            out.max_r = v.max_r
            if v.cycles == 0:
                out.cycle_free = 1
            # A catch-up-free specimen has no vertex in CU (Lemma P), so every
            # nonzero-offset vertex must run into a terminal cycle.
            if catch_up_free(corpus[s].sigma):
                if v.cycles > 0:
                    out.free_with_cycles = 1
                else:
                    out.free_without_cycles.append(s)
        except:
            out.failed_index = s
        return out^

    var r = parallel_map_fold(one, merge, LeftmostCensus(), len(corpus), WORKERS)
    if r.failed_index >= 0:
        var tables = build_seed_overlap_tables(corpus[r.failed_index].sigma)
        _ = certify_leftmost_cycles(tables, build_box_graph(tables), MAX_INTEGRAL_R)
        raise Error("leftmost-chain census: worker failure did not replay")
    print("Leftmost-chain census, specimens:", r.specimens, " capped box graphs:", r.capped)
    print("terminal leftmost cycles:", r.cycles, " longest cycle r:", r.max_r)
    print("Proposition LC, sign kept along the cycle:", r.sign_constant, "/", r.cycles)
    print("Proposition LC, prefix-vs-interior shape:", r.prefix_vs_interior, "/", r.cycles)
    print(
        "cycle equation (I - M^r) w0 = pi(Q) replayed over Z:",
        r.offsets_certified,
        " beyond the exact integer range (r >",
        MAX_INTEGRAL_R,
        "):",
        r.offsets_beyond_range,
        " failed:",
        r.offset_failures,
    )
    print("specimens with no terminal cycle (every nonzero vertex reaches a catch-up):", r.cycle_free)
    print("catch-up-free specimens with a terminal cycle:", r.free_with_cycles, " without:", len(r.free_without_cycles))
    for i in range(min(len(r.free_without_cycles), 8)):
        print("catch-up-free with no terminal cycle:", corpus[r.free_without_cycles[i]].label())
    if r.capped != 0:
        print("INCONCLUSIVE: a capped box graph is an exhausted budget, not a verdict")
    require_complete_census(r)
    print("Proposition LC holds on every terminal leftmost cycle of this domain")
