# rational_trig.mojo
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Rational geometry substrate for the finite-regime Mandelbrot project.
#
# Core arithmetic uses quadrance, spread, dot/cross determinants, and algebraic
# rotor coordinates. Symbolic Q/Z ray-address doubling is the vendored
# `rational_dynamics.double_mod_one`.
#
# The rational coordinates use the selected dynamic-limb BigZ backend.

from finite_exact.rat_q import Q
from rational_dynamics.rational import ReducedFraction, double_mod_one, fraction_from_i64


struct Vec2Q(Copyable):
    var x: Q
    var y: Q

    def __init__(out self, x: Q, y: Q):
        self.x = x.copy()
        self.y = y.copy()


def dot(a: Vec2Q, b: Vec2Q) -> Q:
    return a.x.mul(b.x).add(a.y.mul(b.y))


def cross_det(a: Vec2Q, b: Vec2Q) -> Q:
    return a.x.mul(b.y).sub(a.y.mul(b.x))


def quadrance(v: Vec2Q) -> Q:
    # Q(v) = x^2 + y^2.
    return v.x.square().add(v.y.square())


def spread(a: Vec2Q, b: Vec2Q) -> Q:
    # s(a,b) = det(a,b)^2 / (Q(a) Q(b)).
    var d = cross_det(a, b)
    var qa = quadrance(a)
    var qb = quadrance(b)
    return d.square().div(qa.mul(qb))


def dot_ratio(a: Vec2Q, b: Vec2Q) -> Q:
    # d(a,b)^2 / (Q(a) Q(b)).
    var d = dot(a, b)
    return d.square().div(quadrance(a).mul(quadrance(b)))


struct RotorQ(Copyable):
    var u: Q
    var v: Q

    def __init__(out self, u: Q, v: Q):
        # A valid rotor satisfies u^2 + v^2 = 1, checked by valid_rotor().
        self.u = u.copy()
        self.v = v.copy()


def valid_rotor(r: RotorQ) -> Bool:
    var lhs = r.u.square().add(r.v.square())
    return lhs.eq(Q.one())


def rotate_by_rotor(v: Vec2Q, r: RotorQ) -> Vec2Q:
    return Vec2Q(v.x.mul(r.u).sub(v.y.mul(r.v)), v.x.mul(r.v).add(v.y.mul(r.u)))


def demo_spread_orthogonal_axes() -> Q:
    var e1 = Vec2Q(Q.one(), Q.zero())
    var e2 = Vec2Q(Q.zero(), Q.one())
    return spread(e1, e2)


def demo_ray_addr_doubling_half() -> ReducedFraction:
    return double_mod_one(fraction_from_i64(1, 2))
