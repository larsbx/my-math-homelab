# rank2_operator.mojo
#
# Rank-2 coordinate-record substrate for finite-regime Mandelbrot arithmetic.
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# A complex-like object here is a coordinate record or vertex-data payload with
# the multiplication law (x,y) star (u,v) = (xu-yv, xv+yu). It is not an
# analytic singleton and it does not introduce measured-angle geometry.

from finite_exact.rat_q import Q


# Regime correspondence: rank2-coordinate-record
struct Coord2:
    var x: Q
    var y: Q

    fn __init__(inout self, x: Q, y: Q):
        self.x = x
        self.y = y

    fn zero() -> Coord2:
        return Coord2(Q.zero(), Q.zero())

    fn add(self, other: Coord2) -> Coord2:
        return Coord2(self.x.add(other.x), self.y.add(other.y))

    fn sub(self, other: Coord2) -> Coord2:
        return Coord2(self.x.sub(other.x), self.y.sub(other.y))

    fn star(self, other: Coord2) -> Coord2:
        # (x,y) star (u,v) = (xu-yv, xv+yu)
        var real_part = self.x.mul(other.x).sub(self.y.mul(other.y))
        var imag_part = self.x.mul(other.y).add(self.y.mul(other.x))
        return Coord2(real_part, imag_part)

    fn square(self) -> Coord2:
        return self.star(self)

    fn quadrance(self) -> Q:
        return self.x.square().add(self.y.square())


struct Matrix2Special:
    var a00: Q
    var a01: Q
    var a10: Q
    var a11: Q

    fn __init__(inout self, a00: Q, a01: Q, a10: Q, a11: Q):
        self.a00 = a00
        self.a01 = a01
        self.a10 = a10
        self.a11 = a11

    fn apply(self, v: Coord2) -> Coord2:
        return Coord2(
            self.a00.mul(v.x).add(self.a01.mul(v.y)),
            self.a10.mul(v.x).add(self.a11.mul(v.y)),
        )


# Regime correspondence: rank2-coordinate-record
fn operator_matrix(u: Coord2) -> Matrix2Special:
    # M(u,v) = [[u, -v], [v, u]]
    return Matrix2Special(u.x, u.y.neg(), u.y, u.x)


# Regime correspondence: rank2-coordinate-record
fn operator_apply_by_star(v: Coord2, u: Coord2) -> Coord2:
    return v.star(u)


fn operator_apply_by_matrix(v: Coord2, u: Coord2) -> Coord2:
    return operator_matrix(u).apply(v)


fn same_coord(a: Coord2, b: Coord2) -> Bool:
    return a.x.eq(b.x) and a.y.eq(b.y)


fn star_matches_matrix(v: Coord2, u: Coord2) -> Bool:
    return same_coord(operator_apply_by_star(v, u), operator_apply_by_matrix(v, u))


fn quadrance_scaling_law(v: Coord2, u: Coord2) -> Bool:
    var lhs = v.star(u).quadrance()
    var rhs = v.quadrance().mul(u.quadrance())
    return lhs.eq(rhs)


# Regime correspondence: unit-quadrance-rotor
fn is_rotor(u: Coord2) -> Bool:
    return u.quadrance().eq(Q.one())


fn mandelbrot_square(z: Coord2) -> Coord2:
    # (x,y)^2 = (x^2-y^2, 2xy)
    return z.square()


fn mandelbrot_step(z: Coord2, c: Coord2) -> Coord2:
    return mandelbrot_square(z).add(c)


fn square_quadrance_law(z: Coord2) -> Bool:
    var lhs = mandelbrot_square(z).quadrance()
    var rhs = z.quadrance().square()
    return lhs.eq(rhs)


fn demo_star_matrix_equivalence() -> Bool:
    var v = Coord2(Q(3, 1), Q(4, 1))
    var u = Coord2(Q(5, 1), Q(2, 1))
    return star_matches_matrix(v, u)


fn demo_quadrance_scaling() -> Bool:
    var v = Coord2(Q(3, 1), Q(4, 1))
    var u = Coord2(Q(5, 1), Q(2, 1))
    return quadrance_scaling_law(v, u)


fn demo_rotor_rational_3_4_5() -> Bool:
    var r = Coord2(Q(3, 5), Q(4, 5))
    return is_rotor(r)


fn demo_square_quadrance() -> Bool:
    var z = Coord2(Q(2, 1), Q(1, 1))
    return square_quadrance_law(z)
