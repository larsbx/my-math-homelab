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
from box_classifier import is_trap
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


def trap_image(trap: ComplexIQ, c: ComplexIQ, steps: Int) -> ComplexIQ:
    """`F^steps(trap)`, recomputed from the trap."""
    var image = trap.copy()
    for _ in range(steps):
        image = quadratic_step(image, c)
    return image.copy()


def side_compatible(cut: Cut, trap: ComplexIQ, c: ComplexIQ, period: Int) -> Bool:
    """Is every image of the trap on a decided side of this cut?

    Decided, not the same side: two orbits inside one image box are on the
    same side of everything, whatever that side is.
    """
    if period < 1 or cut.rejected or not (trap.accepted() and c.accepted()):
        return False
    for index in range(period):
        if side(cut, trap_image(trap, c, index)) == side_undecided():
            return False
    return True


def permanently_unseparated(
    left: ComplexIQ,
    right: ComplexIQ,
    c: ComplexIQ,
    cut: Cut,
    trap: ComplexIQ,
    period: Int,
    entry: Int,
) -> Bool:
    """The witness of `docs/permanent-non-separation.md`, for one cut.

    The search that would look for a separation lives on the Python side,
    because it needs a bit budget and this layer has no access to one through
    the exact-arithmetic boundary. What is here is the verification, which is
    what a certificate is for: `entry` steps of direct checking and `period`
    box comparisons replace the infinite tail.
    """
    if entry < 0 or period < 1 or cut.rejected:
        return False
    if not (left.accepted() and right.accepted() and c.accepted() and trap.accepted()):
        return False
    if not is_trap(trap, c, period):
        return False
    if not side_compatible(cut, trap, c, period):
        return False
    var here = left.copy()
    var there = right.copy()
    for _ in range(entry):
        if opposite(side(cut, here), side(cut, there)):
            return False
        here = quadratic_step(here, c)
        there = quadratic_step(there, c)
    var left_inside = here.subset_of(trap)
    var right_inside = there.subset_of(trap)
    if left_inside.rejected or right_inside.rejected:
        return False
    return left_inside.value and right_inside.value


def permanent_witness_smoke() -> Bool:
    """The two witnesses of `tools/parameter_corpus.py`, replayed."""
    # c = 0, the cut x = 1/2, the fixed trap, entry at step three.
    var c_zero = ComplexIQ.singleton(Q.zero(), Q.zero())
    var cut_zero = Cut.of(Q(1, 1), Q.zero(), Q(1, 2))
    var trap_zero = ComplexIQ(IQ(Q(-1, 4), Q(1, 4)), IQ(Q(-1, 4), Q(1, 4)))
    var a0 = ComplexIQ(IQ(Q(19, 32), Q(21, 32)), IQ(Q(-1, 32), Q(1, 32)))
    var b0 = ComplexIQ(IQ(Q(11, 16), Q(23, 32)), IQ(Q(-1, 32), Q(1, 32)))
    if not permanently_unseparated(a0, b0, c_zero, cut_zero, trap_zero, 1, 3):
        return False
    # An entry step that is too early is refused rather than stretched.
    if permanently_unseparated(a0, b0, c_zero, cut_zero, trap_zero, 1, 2):
        return False
    # c = -1, a period-two trap whose two images straddle the cut.
    var c_basilica = ComplexIQ.singleton(Q(-1, 1), Q.zero())
    var cut_basilica = Cut.of(Q(1, 1), Q.zero(), Q(-1, 2))
    var trap_basilica = ComplexIQ(IQ(Q(-1, 8), Q(1, 8)), IQ(Q(-1, 8), Q(1, 8)))
    if not side_compatible(cut_basilica, trap_basilica, c_basilica, 2):
        return False
    var a1 = ComplexIQ(IQ(Q(1, 4), Q(9, 32)), IQ(Q(-1, 64), Q(1, 64)))
    var b1 = ComplexIQ(IQ(Q(-9, 32), Q(-1, 4)), IQ(Q(-1, 64), Q(1, 64)))
    if not permanently_unseparated(a1, b1, c_basilica, cut_basilica, trap_basilica, 2, 4):
        return False
    # A trap that straddles the cut carries no witness: the fixed trap at the
    # origin against the cut through the origin.
    var through_origin = Cut.of(Q(1, 1), Q.zero(), Q.zero())
    if side_compatible(through_origin, trap_zero, c_zero, 1):
        return False
    return not permanently_unseparated(a0, b0, c_zero, through_origin, trap_zero, 1, 3)


def real_axis_cut() -> Cut:
    """`y = 0`. At a real parameter this is not an arbitrary line: see
    `docs/ray-certificates.md` section 3."""
    return Cut.of(Q.zero(), Q(1, 1), Q.zero())


def certifies_real_rays(c: Q, outer: Q, segment: Q) -> Bool:
    """The rational inequalities of `docs/ray-certificates.md` section 2.

    Beyond `outer` the real half-lines escape, with advance at least
    `outer^2 + c - outer` at every step; `[-segment, segment]` is forward
    invariant and so inside `K_c`.
    """
    if not (c.accepted() and outer.accepted() and segment.accepted()):
        return False
    if outer.lt(Q(1, 1)):
        return False
    if not Q.zero().lt(outer.square().add(c).sub(outer)):
        return False
    if not Q.zero().lt(segment):
        return False
    if segment.lt(segment.square().add(c)):
        return False
    if c.lt(segment.neg()):
        return False
    return segment.lt(outer)


def ray_witness_smoke() -> Bool:
    """The real rows of `tools/parameter_corpus.py`, and the one refusal."""
    if not certifies_real_rays(Q.zero(), Q(2, 1), Q(1, 2)):
        return False
    if not certifies_real_rays(Q(-1, 1), Q(2, 1), Q(1, 1)):
        return False
    if not certifies_real_rays(Q(-2, 1), Q(9, 4), Q(2, 1)):
        return False
    if not certifies_real_rays(Q(1, 4), Q(2, 1), Q(1, 2)):
        return False
    if not certifies_real_rays(Q(-3, 4), Q(2, 1), Q(1, 1)):
        return False
    # c = 1 has no real fixed point, so no invariant segment exists and the
    # certificate declines rather than inventing one.
    if certifies_real_rays(Q(1, 1), Q(2, 1), Q(1, 1)):
        return False
    if certifies_real_rays(Q(1, 1), Q(4, 1), Q(8, 1)):
        return False
    # The two regions must not overlap, and the outer bound must be at least one.
    if certifies_real_rays(Q(-1, 1), Q(2, 1), Q(4, 1)):
        return False
    if certifies_real_rays(Q(-1, 1), Q(1, 2), Q(1, 4)):
        return False
    # The real axis separates conjugate boxes at a real parameter.
    var c_basilica = ComplexIQ.singleton(Q(-1, 1), Q.zero())
    var upper = ComplexIQ(IQ(Q(9, 8), Q(5, 4)), IQ(Q(1, 8), Q(1, 4)))
    var lower = ComplexIQ(IQ(Q(9, 8), Q(5, 4)), IQ(Q(-1, 4), Q(-1, 8)))
    if separating_level(upper, lower, c_basilica, real_axis_cut(), 3) != 0:
        return False
    var straddling = ComplexIQ(IQ(Q(9, 8), Q(5, 4)), IQ(Q(-1, 8), Q(1, 8)))
    return side(real_axis_cut(), straddling) == side_undecided()
