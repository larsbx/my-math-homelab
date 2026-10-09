# poly_z.mojo
#
# Exact univariate polynomial arithmetic over Z[C], expressed in Mojo shape.
#
# This module is intentionally conservative: coefficients are Int and the
# maximum degree is fixed by the caller. That is enough to preserve and test
# the finite-regime Mandelbrot computations already in the repo:
#
#   Q_0(C) = 0
#   Q_{n+1}(C) = Q_n(C)^2 + C
#   R_{l,k}(C) = Q_{l+k}(C) - Q_l(C)
#   P_{l,k}(C) = squarefree(R_{l,k})
#
# Later hardening target: replace fixed buffers with a BigInt-backed dynamic
# representation and implement a fully checked Euclidean gcd witness.


comptime MAX_DEGREE = 256


struct PolyZ(Copyable):
    var coeffs: List[Int]
    var degree: Int

    def __init__(out self):
        var xs = List[Int](capacity=MAX_DEGREE + 1)
        for _ in range(MAX_DEGREE + 1):
            xs.append(0)
        self.coeffs = xs^
        self.degree = 0

    def normalize(mut self):
        var d = MAX_DEGREE
        while d > 0 and self.coeffs[d] == 0:
            d -= 1
        self.degree = d

    def coefficient(self, i: Int) -> Int:
        if i < 0 or i > MAX_DEGREE:
            return 0
        return self.coeffs[i]

    def set_coefficient(mut self, i: Int, value: Int):
        if i >= 0 and i <= MAX_DEGREE:
            self.coeffs[i] = value
            self.normalize()

    def is_zero(self) -> Bool:
        return self.degree == 0 and self.coeffs[0] == 0


def constant(value: Int) -> PolyZ:
    var p = PolyZ()
    p.coeffs[0] = value
    p.normalize()
    return p^


def variable() -> PolyZ:
    var p = PolyZ()
    p.coeffs[1] = 1
    p.degree = 1
    return p^


def add(a: PolyZ, b: PolyZ) -> PolyZ:
    var r = PolyZ()
    for i in range(MAX_DEGREE + 1):
        r.coeffs[i] = a.coefficient(i) + b.coefficient(i)
    r.normalize()
    return r^


def sub(a: PolyZ, b: PolyZ) -> PolyZ:
    var r = PolyZ()
    for i in range(MAX_DEGREE + 1):
        r.coeffs[i] = a.coefficient(i) - b.coefficient(i)
    r.normalize()
    return r^


def mul(a: PolyZ, b: PolyZ) -> PolyZ:
    var r = PolyZ()
    for i in range(a.degree + 1):
        for j in range(b.degree + 1):
            var k = i + j
            if k <= MAX_DEGREE:
                r.coeffs[k] += a.coefficient(i) * b.coefficient(j)
    r.normalize()
    return r^


def derivative(a: PolyZ) -> PolyZ:
    var r = PolyZ()
    if a.degree == 0:
        return r^
    for i in range(1, a.degree + 1):
        r.coeffs[i - 1] = a.coefficient(i) * i
    r.normalize()
    return r^


def monic_linear(root_negated: Int) -> PolyZ:
    # Returns C + root_negated.
    var p = variable()
    p.coeffs[0] = root_negated
    p.normalize()
    return p^


def pow_poly(base: PolyZ, exponent: Int) -> PolyZ:
    var r = constant(1)
    var b = base.copy()
    var e = exponent
    while e > 0:
        if e % 2 == 1:
            r = mul(r, b)
        e = e // 2
        if e > 0:
            b = mul(b, b)
    return r^


def critical_orbit_poly(n: Int) -> PolyZ:
    # Q_0 = 0, Q_{n+1} = Q_n^2 + C.
    var q = constant(0)
    var c = variable()
    for _ in range(n):
        q = add(mul(q, q), c)
    return q^


def raw_return_poly(l: Int, k: Int) -> PolyZ:
    return sub(critical_orbit_poly(l + k), critical_orbit_poly(l))


def equal_poly(a: PolyZ, b: PolyZ) -> Bool:
    if a.degree != b.degree:
        return False
    for i in range(MAX_DEGREE + 1):
        if a.coefficient(i) != b.coefficient(i):
            return False
    return True


def factor_c_minus_zero_power(power: Int) -> PolyZ:
    return pow_poly(variable(), power)


def expected_R_2_1() -> PolyZ:
    # R_{2,1}(C) = C^3(C+2).
    return mul(pow_poly(variable(), 3), monic_linear(2))


def expected_P_2_1_squarefree() -> PolyZ:
    # P_{2,1}(C) = sqfree(C^3(C+2)) = C(C+2).
    return mul(variable(), monic_linear(2))


def expected_F7_M41() -> PolyZ:
    # F_7(C) = C^7 + 4C^6 + 6C^5 + 6C^4 + 6C^3 + 4C^2 + 2C + 2.
    var p = PolyZ()
    p.coeffs[0] = 2
    p.coeffs[1] = 2
    p.coeffs[2] = 4
    p.coeffs[3] = 6
    p.coeffs[4] = 6
    p.coeffs[5] = 6
    p.coeffs[6] = 4
    p.coeffs[7] = 1
    p.normalize()
    return p^


def expected_R_4_1_factorized() -> PolyZ:
    # R_{4,1} = C^5(C+2)(C^3+2C^2+2C+2)F_7.
    var c = variable()
    var cubic = PolyZ()
    cubic.coeffs[0] = 2
    cubic.coeffs[1] = 2
    cubic.coeffs[2] = 2
    cubic.coeffs[3] = 1
    cubic.normalize()
    return mul(mul(mul(pow_poly(c, 5), monic_linear(2)), cubic), expected_F7_M41())


def expected_P_4_1_squarefree() -> PolyZ:
    # P_{4,1} = C(C+2)(C^3+2C^2+2C+2)F_7.
    var c = variable()
    var cubic = PolyZ()
    cubic.coeffs[0] = 2
    cubic.coeffs[1] = 2
    cubic.coeffs[2] = 2
    cubic.coeffs[3] = 1
    cubic.normalize()
    return mul(mul(mul(c, monic_linear(2)), cubic), expected_F7_M41())


def smoke_poly_identities() -> Bool:
    # These are preservation checks for computations used in the spec.
    var r21 = raw_return_poly(2, 1)
    if not equal_poly(r21, expected_R_2_1()):
        return False

    var r41 = raw_return_poly(4, 1)
    if not equal_poly(r41, expected_R_4_1_factorized()):
        return False

    return True
