# complex_box.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2, QUARANTINED).
# Floating-point demo substrate; allowlisted in tools/exact_arithmetic_allowlist.md.
# Must not be imported by any module that emits or accepts certificate data.
#
# Finite-regime Mandelbrot computation substrate.
#
# This file keeps the executable/numeric side deliberately small:
# - complex arithmetic as rank-2 pairs
# - rectangular boxes represented by center + half-width
# - conservative disk-radius helpers used by the Krawczyk notes
#
# Next hardening step: replace Float64 helpers with dyadic-rational endpoints.

struct C64:
    var re: Float64
    var im: Float64

    fn __init__(inout self, re: Float64, im: Float64):
        self.re = re
        self.im = im

    fn add(self, other: C64) -> C64:
        return C64(self.re + other.re, self.im + other.im)

    fn sub(self, other: C64) -> C64:
        return C64(self.re - other.re, self.im - other.im)

    fn mul(self, other: C64) -> C64:
        return C64(
            self.re * other.re - self.im * other.im,
            self.re * other.im + self.im * other.re,
        )

    fn scale(self, s: Float64) -> C64:
        return C64(self.re * s, self.im * s)

    fn norm2(self) -> Float64:
        return self.re * self.re + self.im * self.im

    fn abs_upper(self) -> Float64:
        # Placeholder for sqrt(norm2). Kept as upper-bound friendly.
        # Mojo stdlib availability differs by version, so consumers may replace
        # this with an exact rational square-bound comparison.
        return self.norm2()


struct ComplexBox:
    var center: C64
    var half_width: Float64

    fn __init__(inout self, center: C64, half_width: Float64):
        self.center = center
        self.half_width = half_width

    fn disk_radius_bound(self) -> Float64:
        # Rectangle with half-width h is contained in disk of radius sqrt(2)h.
        # We use 2h as a conservative rational-friendly bound.
        return 2.0 * self.half_width

    fn contains_point_rough(self, z: C64) -> Bool:
        let dx = z.re - self.center.re
        let dy = z.im - self.center.im
        return dx <= self.half_width and dx >= -self.half_width and dy <= self.half_width and dy >= -self.half_width


fn q_next(z: C64, c: C64) -> C64:
    return z.mul(z).add(c)


fn q_iter(c: C64, n: Int) -> C64:
    var z = C64(0.0, 0.0)
    for _ in range(n):
        z = q_next(z, c)
    return z


fn h_ij(c: C64, i: Int, j: Int) -> C64:
    return q_iter(c, j).sub(q_iter(c, i))


fn print_orbit(c: C64, upto: Int):
    print("critical orbit:")
    for n in range(upto + 1):
        let z = q_iter(c, n)
        print("Q_", n, " = ", z.re, " + ", z.im, " i")
