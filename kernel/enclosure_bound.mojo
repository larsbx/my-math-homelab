# enclosure_bound.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md.
# Statements and proofs: docs/enclosure-width-lemma.md.
#
# What this repository owes the interval layer's refinement theorem, which is
# the step factor and nothing else. Section 2.5 of the specification bounds
# how far an enclosure drifts from the orbit it encloses, for any extension
# with a rational per-step width factor K; sections 2 and 4(b) of the lemma
# supply `K = 6M` for `z -> z^2 + c` and convert the resulting distance into
# a quadrance, which is what the escape test reads.
#
# This is the Mojo side of a differential pair; reference/enclosure_bound.py is
# the Python side and keeps its own arithmetic, because a differential pair
# that shares an implementation compares nothing.

from finite_exact.closed_interval import ComplexIQ, IQ
from finite_exact.enclosure_width import refinement_radius as interval_refinement_radius, sup_radius
from finite_exact.rat_q import Q, q_abs, q_max



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




def quadrance_drift_bound(bound: Q, distance: Q) -> Q:
    """`6 M e`: how far a quadrance can move over a sup-distance `e <= 1`."""
    return Q(6, 1).mul(bound).mul(distance)



def refinement_radius(bound: Q, steps: Int, margin: Q) -> Q:
    """Section 5's `s = delta / (12 M (6 M)^N)`, for a margin `delta <= 1`.

    The interval layer's radius at this map's step factor, with the margin
    converted from a quadrance gap to a distance by 4(b).
    """
    if not (margin.accepted() and Q.zero().lt(margin) and margin.le(Q(1, 1))):
        return Q(0, 0)
    var factor = coarse_step_factor(bound)
    return interval_refinement_radius(factor, steps, margin.div(factor))


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
    # Section 4(b): a sup-distance of e moves a quadrance by at most 6 M e.
    var drift = quadrance_drift_bound(bound, Q(1, 8))
    if not drift.eq(Q(3, 2)):
        return False
    # Section 5's s: delta / (12 M (6 M)^N), refused outside (0, 1].
    if not refinement_radius(bound, 2, Q(1, 1)).eq(
        Q(1, 1).div(Q(12, 1).mul(bound).mul(coarse_step_factor(bound).square()))
    ):
        return False
    return not refinement_radius(bound, 2, Q(2, 1)).accepted()
