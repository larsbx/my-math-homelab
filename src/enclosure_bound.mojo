# enclosure_bound.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md.
# Statements and proofs: docs/enclosure-width-lemma.md.
#
# How far an enclosure can drift from the orbit it encloses. The classifier's
# certificates fire on the enclosure rather than on the points, so these
# bounds are what makes refining a box worth doing: inside the square of
# half-side M an enclosure grows by at most 6M per step, so over a fixed
# number of steps a small enough box stays as close to the orbit as required.
#
# This is the Mojo side of a differential pair; tools/enclosure_bound.py is
# the Python side.

from finite_exact.closed_interval import ComplexIQ, IQ
from finite_exact.rat_q import Q, q_abs, q_max


def sup_radius(box: ComplexIQ) -> Q:
    """Half the larger coordinate width: the radius in the sup norm."""
    if not box.accepted():
        return Q.zero()
    var widths = q_max(box.re.hi.sub(box.re.lo), box.im.hi.sub(box.im.lo))
    return widths.div(Q(2, 1))


def sup_magnitude(box: ComplexIQ) -> Q:
    """The largest coordinate magnitude the box reaches."""
    if not box.accepted():
        return Q.zero()
    var real = q_max(q_abs(box.re.lo), q_abs(box.re.hi))
    var imaginary = q_max(q_abs(box.im.lo), q_abs(box.im.hi))
    return q_max(real, imaginary)


def within(box: ComplexIQ, bound: Q) -> Bool:
    """Does the box lie inside the square of half-side `bound`?"""
    if not (box.accepted() and bound.accepted()):
        return False
    return sup_magnitude(box).le(bound)


def step_radius_bound(bound: Q, radius: Q) -> Q:
    """`4 M r + 2 r^2`, the sharp form of the one-step bound."""
    return Q(4, 1).mul(bound).mul(radius).add(Q(2, 1).mul(radius.square()))


def coarse_step_factor(bound: Q) -> Q:
    """`6 M`: the one-step bound with `r <= M` folded in, so it composes."""
    return Q(6, 1).mul(bound)


def iterated_radius_bound(bound: Q, steps: Int, radius: Q) -> Q:
    """`(6 M)^n r`, valid while every iterate stays inside the square."""
    if steps < 0:
        return Q(0, 0)
    var factor = coarse_step_factor(bound)
    var accumulated = radius.copy()
    for _ in range(steps):
        accumulated = accumulated.mul(factor)
    return accumulated.copy()


def orbit_gap_bound(bound: Q, steps: Int, radius: Q) -> Q:
    """`2 (6 M)^n r`: the distance from the enclosure to the orbit it holds."""
    return Q(2, 1).mul(iterated_radius_bound(bound, steps, radius))


def enclosure_bound_smoke() -> Bool:
    """The one-step bound against the arithmetic, on boxes chosen to be awkward."""
    var bound = Q(2, 1)
    var c = ComplexIQ.singleton(Q(-1, 1), Q.zero())
    # A box straddling zero in both coordinates: the case the proof splits on.
    var straddling = ComplexIQ(IQ(Q(-1, 4), Q(1, 4)), IQ(Q(-1, 4), Q(1, 4)))
    var image = straddling.square().add(c)
    if not sup_radius(image).le(step_radius_bound(bound, sup_radius(straddling))):
        return False
    # A box at the edge of the square, where the linear term is largest.
    var edge = ComplexIQ(IQ(Q(7, 4), Q(2, 1)), IQ(Q(7, 4), Q(2, 1)))
    var edge_image = edge.square().add(c)
    if not sup_radius(edge_image).le(step_radius_bound(bound, sup_radius(edge))):
        return False
    # A singleton stays a singleton.
    var singleton = ComplexIQ.singleton(Q(1, 3), Q(-2, 5))
    if not sup_radius(singleton.square().add(c)).eq(Q.zero()):
        return False
    # The sharp bound is dominated by the coarse factor, which is what composes.
    var radius = sup_radius(straddling)
    if not step_radius_bound(bound, radius).le(coarse_step_factor(bound).mul(radius)):
        return False
    # Two steps compose: (6M)^2 r.
    if not iterated_radius_bound(bound, 2, radius).eq(coarse_step_factor(bound).square().mul(radius)):
        return False
    return orbit_gap_bound(bound, 0, radius).eq(Q(2, 1).mul(radius))
