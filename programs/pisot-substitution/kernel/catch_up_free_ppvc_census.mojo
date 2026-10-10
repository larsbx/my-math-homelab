"""Exact family survey of PeriodicPairVertexCoincidence on the catch-up-free `|det M| = 2` class.

**A bounded family survey, not a corpus census** (AGENTS.md, "The census
library"). It does not walk `pip_corpus()`: it enumerates parameter
presentations of the class's families, most of whose members lie outside the
standing corpus (images up to length 6), and screens each with `CubicScreen`,
as `a1_normal_form_census.mojo` does for the same families. Its counts describe
those presentations at the stated bound, not the 4,554-specimen corpus; the
corpus members of the class are covered by the standing PPVC census.

docs/p1b-catch-up-free-ppvc-2026-10-07.md. On this class Theorem K of
docs/p1a-a1-prime-2026-10-05.md proves all-pairs strong coincidence (SC_all)
outside one family, so by Proposition FP of
docs/formal-productivity-reduction-2026-10-04.md (FP <=> SC_all and BH) and
Proposition V of docs/p1b-vertex-coincidence-box-2026-10-02.md (BH <=> PPVC),
PPVC is the **single remaining obligation** for pure discrete spectrum there,
and it gives G1 on its own. This driver decides PPVC exactly, member by member,
on every parametric family of the class:

- the four classes of Theorem E (`class_member`), and the ten PIP endings of
  the swap family of Theorem H (`swap_member`), `p, q, r <= bound`;
- the two `sigma(x) = y` families of Proposition Y (`y_family_member`),
  `q, r <= bound`;
- Theorem K's family `sigma(o) = y`, `sigma(y) = o w_1 o`,
  `sigma(z) = o w_2 o` (`member_sigma`), `|w_1|, |w_2| <= bound`.

The decision is `psc.vertex_coincidence.decide_vertex_coincidence`, exact and
finite for every `r` at once, so a failing member is a verdict -- by Theorem S
it would refute pure discrete spectrum for that substitution -- and the driver
raises on one. A capped box graph is an exhausted budget, not a verdict, and
also raises. Members with an image longer than the exact Perron kernel's
certified domain (`MAX_CERTIFIED_COLUMN_SUM`) are counted as skipped, never
decided.

What it reports per family: members decided, skipped, and the histogram of
`deepest`, the largest first offset-zero depth over the recurrent vertices.
The question the survey is for is whether that depth stays bounded as the
parameters grow -- the precondition of a parametric certificate.

Usage: `mojo run -I . catch_up_free_ppvc_census.mojo [bound]` (default 3), or
`pixi run catch-up-free-ppvc-census`. A bound beyond `MAX_BOUND` is refused.
"""

from std.sys import argv
from finite_linear_algebra.mat3 import Mat3
from psc.bpa import substitution_incidence
from psc.histogram import Histogram
from psc.perron_field3 import MAX_CERTIFIED_COLUMN_SUM
from psc.pisot import CubicScreen
from psc.vertex_coincidence import decide_vertex_coincidence
from a1_normal_form_census import FAMILY_F1, FAMILY_F2, class_member, swap_member, y_family_member
from odd_letter_family_certificate import member_sigma

comptime MAX_BOUND = 6
comptime DEPTH_CAP = 64

comptime FAMILY_E = 0  # Theorem E's classes A-D
comptime FAMILY_SWAP = 1  # Theorem H's swap family
comptime FAMILY_Y = 2  # Proposition Y's F1 and F2
comptime FAMILY_K = 3  # Theorem K's family
comptime FAMILIES = 4


struct FamilyTally(Copyable, Movable):
    var decided: Int
    var skipped: Int
    var depths: Histogram
    var deepest: Int

    def __init__(out self) raises:
        self.decided = 0
        self.skipped = 0
        self.depths = Histogram(DEPTH_CAP)
        self.deepest = -1


struct PpvcCensus(Copyable, Movable):
    var families: List[FamilyTally]

    def __init__(out self) raises:
        self.families = List[FamilyTally]()
        for _ in range(FAMILIES):
            self.families.append(FamilyTally())


def in_certified_domain(sigma: List[List[Int]]) -> Bool:
    for a in range(len(sigma)):
        if len(sigma[a]) > MAX_CERTIFIED_COLUMN_SUM:
            return False
    return True


def fold_member(mut tally: FamilyTally, sigma: List[List[Int]], mut screen: CubicScreen) raises:
    """Screen one candidate; decide PPVC on it if it is a PIP, `|det M| = 2` member."""
    var m = Mat3(substitution_incidence(sigma))
    if abs(m.det()) != 2 or not screen.is_pip(m):
        return
    if not in_certified_domain(sigma):
        tally.skipped += 1
        return
    var v = decide_vertex_coincidence(sigma.copy())
    if v.capped:
        raise Error("box graph capped: an exhausted budget, not a verdict")
    if not v.holds:
        raise Error("PPVC REFUTED on a catch-up-free |det M| = 2 member: a strict zipper exists")
    tally.decided += 1
    tally.depths.record(v.deepest)
    if v.deepest > tally.deepest:
        tally.deepest = v.deepest


def words_over_yz(max_len: Int) -> List[List[Int]]:
    """Every word over `{y, z} = {1, 2}` of length at most `max_len`, shortest first."""
    var out = List[List[Int]]()
    out.append(List[Int]())
    var start = 0
    for _ in range(max_len):
        var end = len(out)
        for i in range(start, end):
            for letter in range(1, 3):
                var w = out[i].copy()
                w.append(letter)
                out.append(w^)
        start = end
    return out^


def census(bound: Int) raises -> PpvcCensus:
    if bound < 0 or bound > MAX_BOUND:
        raise Error("the PPVC census bound must lie in 0..", String(MAX_BOUND))
    var screen = CubicScreen()
    var out = PpvcCensus()
    for p in range(bound + 1):
        for q in range(bound + 1):
            for r in range(bound + 1):
                for cls in range(4):
                    fold_member(out.families[FAMILY_E], class_member(cls, p, q, r), screen)
                for e in range(16):
                    fold_member(out.families[FAMILY_SWAP], swap_member(p, q, r, e >> 3, (e >> 2) & 1, (e >> 1) & 1, e & 1), screen)
    for q in range(bound + 1):
        for r in range(bound + 1):
            fold_member(out.families[FAMILY_Y], y_family_member(FAMILY_F1, q, r), screen)
            fold_member(out.families[FAMILY_Y], y_family_member(FAMILY_F2, q, r), screen)
    var words = words_over_yz(bound)
    for i in range(len(words)):
        for j in range(len(words)):
            fold_member(out.families[FAMILY_K], member_sigma(words[i], words[j]), screen)
    return out^


def main() raises:
    var args = argv()
    var bound = 3 if len(args) < 2 else Int(args[1])
    var c = census(bound)
    var names: List[String] = ["Theorem E classes", "swap family", "Proposition Y families", "Theorem K family"]
    print("PPVC on the catch-up-free |det M| = 2 class, bound", bound)
    for f in range(FAMILIES):
        ref t = c.families[f]
        print(names[f], ": decided", t.decided, " skipped (outside certified domain)", t.skipped, " deepest", t.deepest)
        print(t.depths.line("  deepest depth"))
