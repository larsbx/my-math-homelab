# escape_certificate.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md.
# Derivation and proofs: docs/escape-criterion.md.
#
# The escape criterion as a finite certificate. `julia_orbit.escapes_at` says
# that a quadrance passed a bound; this says what passing it buys, namely a
# rational ratio the quadrance grows by at every later step. Both forms below
# are polynomial in the two quadrances, so no modulus and no square root is
# needed and the argument stays inside the rank-2 layer.
#
# This is the Mojo side of a differential pair; reference/escape_certificate.py is
# the Python side.

from finite_exact.rat_q import Q


def threshold_form(t: Q, ratio: Q) -> Q:
    """`T(t, r) = t^2 - 2t(1 + r) + (r - 1)^2`.

    Its roots in `t` are `(sqrt(r) ± 1)^2`, so a positive value alone does not
    say which side of the parabola `t` is on. `certificate_holds` adds the
    vertex condition that picks the upper one.
    """
    var one = Q(1, 1)
    var two = Q(2, 1)
    return t.square().sub(two.mul(t).mul(one.add(ratio))).add(ratio.sub(one).square())


def growth_form(t: Q, m: Q, ratio: Q) -> Q:
    """`G(t, m, r) = (t^2 + m - r t)^2 - 4 t^2 m`, as a quadratic in `m`."""
    var two = Q(2, 1)
    var linear = two.mul(t).mul(t.add(ratio)).mul(m)
    return m.square().sub(linear).add(t.square().mul(t.sub(ratio).square()))


def certificate_holds(t: Q, m: Q, ratio: Q) -> Bool:
    """Does `ratio` certify that the quadrance grows by that factor at every step?

    Four exact comparisons: the ratio exceeds one, the parameter quadrance
    does not exceed the point's, the point is past the vertex, and the
    threshold form is positive there. A rejected value refuses rather than
    answering.
    """
    if not (t.accepted() and m.accepted() and ratio.accepted()):
        return False
    var zero = Q.zero()
    var one = Q(1, 1)
    if not one.lt(ratio):
        return False
    if not (zero.le(m) and m.le(t)):
        return False
    if not one.add(ratio).lt(t):
        return False
    return zero.lt(threshold_form(t, ratio))


def next_quadrance_bound(t: Q, ratio: Q) -> Q:
    """The certified lower bound on the next quadrance, `r t`."""
    return ratio.mul(t)


def escape_certificate_smoke() -> Bool:
    """The identities, the branch trap, and the threshold, on pinned values."""
    var t = Q(9, 1)
    var m = Q(4, 1)
    # G(t, t, r) = t^2 T(t, r): the worst parameter is m = t.
    if not growth_form(t, t, Q(2, 1)).eq(t.square().mul(threshold_form(t, Q(2, 1)))):
        return False
    # T vanishes at (sqrt(r) + 1)^2; for r = 4 that is t = 9.
    if not threshold_form(Q(9, 1), Q(4, 1)).eq(Q.zero()):
        return False
    if not certificate_holds(t, m, Q(2, 1)):
        return False
    if not next_quadrance_bound(t, Q(2, 1)).eq(Q(18, 1)):
        return False
    # The lower branch: T > 0 and the claim false. Vertex condition rejects it.
    var trap_t = Q(163, 31)
    var trap_m = Q(98, 19)
    var trap_ratio = Q(263, 19)
    if not Q.zero().lt(threshold_form(trap_t, trap_ratio)):
        return False
    if certificate_holds(trap_t, trap_m, trap_ratio):
        return False
    # At the classical threshold the admissible ratios are empty.
    if certificate_holds(Q(4, 1), Q(4, 1), Q(1, 1)):
        return False
    return not certificate_holds(Q(4, 1), Q(4, 1), Q(3, 2))
