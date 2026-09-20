# separator.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md, section 2.4.
# Statements and what is given up: docs/finite-separator.md.
#
# A finite separator: exact rational cuts, pulled back by the dynamics. A ray
# is a curve and a curve is not available at rank 2, so the separator is built
# from what is: a linear form with rational coefficients, whose side a box is
# on is the three-valued interval sign, and the dynamics supplies the rest by
# pullback.
#
# Soundness never depends on where a cut is drawn. A badly placed cut is
# uninformative and cannot be wrong.
#
# This is the Mojo side of a differential pair; tools/separator.py is the
# Python side.

from finite_exact.closed_interval import ComplexIQ, IQ
from finite_exact.rat_q import Q
from quadratic_orbit.orbit import quadratic_step


def side_positive() -> Int:
    return 1


def side_negative() -> Int:
    return -1


def side_undecided() -> Int:
    """The cut meets the enclosure. A statement about the box, not its points."""
    return 0


struct Cut(Copyable, Movable):
    """The rational linear form `a x + b y - e`, or a refusal."""

    var a: Q
    var b: Q
    var e: Q
    var rejected: Bool

    def __init__(out self, a: Q, b: Q, e: Q, rejected: Bool):
        self.a = a.copy()
        self.b = b.copy()
        self.e = e.copy()
        self.rejected = rejected

    @staticmethod
    def of(a: Q, b: Q, e: Q) -> Cut:
        var degenerate = a.eq(Q.zero()) and b.eq(Q.zero())
        var malformed = not (a.accepted() and b.accepted() and e.accepted())
        return Cut(a, b, e, degenerate or malformed)

    @staticmethod
    def refused() -> Cut:
        return Cut(Q.zero(), Q.zero(), Q.zero(), True)

    def accepted(self) -> Bool:
        return not self.rejected


def cut_form(cut: Cut, box: ComplexIQ) -> IQ:
    """`a X + b Y - e` as an enclosure over the box."""
    if cut.rejected or not box.accepted():
        return IQ(Q(1, 0), Q(1, 0))
    var scaled = box.re.mul(IQ.singleton(cut.a)).add(box.im.mul(IQ.singleton(cut.b)))
    return scaled.sub(IQ.singleton(cut.e))


def side(cut: Cut, box: ComplexIQ) -> Int:
    """Which side of the cut the whole box is on, three-valued."""
    var value = cut_form(cut, box)
    if not value.accepted():
        return side_undecided()
    if Q.zero().lt(value.lo):
        return side_positive()
    if value.hi.lt(Q.zero()):
        return side_negative()
    return side_undecided()


def opposite(first: Int, second: Int) -> Bool:
    """Are these two decided sides, and different?"""
    if first == side_undecided() or second == side_undecided():
        return False
    return first != second


def separating_level(
    left: ComplexIQ, right: ComplexIQ, c: ComplexIQ, cut: Cut, level: Int
) -> Int:
    """The least step at which this cut separates the two boxes, or `-1`.

    One cut rather than a catalogue: a list of cuts is a consumer's data
    structure, and the Mojo side checks the one certificate the Python side
    reports. `-1` is not a level and must not be read as one.
    """
    if level < 0 or cut.rejected or not (left.accepted() and right.accepted() and c.accepted()):
        return -1
    var here = left.copy()
    var there = right.copy()
    for index in range(level + 1):
        if opposite(side(cut, here), side(cut, there)):
            return index
        here = quadratic_step(here, c)
        there = quadratic_step(there, c)
    return -1


def separator_smoke() -> Bool:
    """The three sides, the pullback, and the refusals, at `c = 0`."""
    var c = ComplexIQ.singleton(Q.zero(), Q.zero())
    var vertical = Cut.of(Q(1, 1), Q.zero(), Q.zero())
    var right_of = ComplexIQ(IQ(Q(7, 16), Q(9, 16)), IQ(Q(-1, 16), Q(1, 16)))
    var left_of = ComplexIQ(IQ(Q(-9, 16), Q(-7, 16)), IQ(Q(-1, 16), Q(1, 16)))
    var straddling = ComplexIQ(IQ(Q(-1, 16), Q(1, 16)), IQ(Q(-1, 16), Q(1, 16)))
    if side(vertical, right_of) != side_positive():
        return False
    if side(vertical, left_of) != side_negative():
        return False
    if side(vertical, straddling) != side_undecided():
        return False
    # Decided at once where the sides differ.
    if separating_level(right_of, left_of, c, vertical, 4) != 0:
        return False
    # The pullback does the work: `i/2` is undecided against the vertical cut
    # and its square is not.
    var upward = ComplexIQ(IQ(Q(-1, 16), Q(1, 16)), IQ(Q(7, 16), Q(9, 16)))
    if side(vertical, upward) != side_undecided():
        return False
    if separating_level(right_of, upward, c, vertical, 4) != 1:
        return False
    # Non-separation is reflexive: no cut puts a box on both sides of itself.
    if separating_level(right_of, right_of, c, vertical, 6) != -1:
        return False
    # A box that stays on the cut is never separated from anything by it.
    if separating_level(straddling, right_of, c, vertical, 6) != -1:
        return False
    # Refusals are values.
    if Cut.of(Q.zero(), Q.zero(), Q(1, 1)).accepted():
        return False
    return separating_level(right_of, left_of, c, Cut.refused(), 4) == -1
