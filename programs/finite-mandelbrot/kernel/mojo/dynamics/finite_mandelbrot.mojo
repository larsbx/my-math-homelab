"""
Finite-regime Mandelbrot computations preserved in Mojo.

Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2, QUARANTINED).

This file intentionally separates:
- executable numeric smoke/stress checks, and
- exact algebraic certificate obligations that should later be backed by a
  polynomial / dyadic-interval library.

Current project rule: the finite certificate substrate is the one-variable
formal polynomial recurrence

    Q_0(C) = 0
    Q_{n+1}(C) = Q_n(C)^2 + C

with dyadic complex boxes used only as finite rational enclosures.
"""

alias F64 = Float64


def sq_re(x: F64, y: F64) -> F64:
    return x * x - y * y


def sq_im(x: F64, y: F64) -> F64:
    return 2.0 * x * y


def step_re(zr: F64, zi: F64, cr: F64) -> F64:
    return sq_re(zr, zi) + cr


def step_im(zr: F64, zi: F64, ci: F64) -> F64:
    return sq_im(zr, zi) + ci


def norm2(x: F64, y: F64) -> F64:
    return x * x + y * y


def orbit_print(label: String, cr: F64, ci: F64, steps: Int):
    print(label)
    var zr: F64 = 0.0
    var zi: F64 = 0.0
    print("Q_0 = (", zr, ", ", zi, ")")
    for n in range(steps):
        var nr = step_re(zr, zi, cr)
        var ni = step_im(zr, zi, ci)
        zr = nr
        zi = ni
        print("Q_", n + 1, " = (", zr, ", ", zi, "), N = ", norm2(zr, zi))


def c_minus_2_smoke_test():
    """
    Worked instance: antenna tip c = -2.

    Critical orbit:
        0 -> -2 -> 2 -> 2

    Claimed type:
        (ell, k) = (2, 1)

    Raw return polynomial:
        R_{2,1}(C) = Q_3(C) - Q_2(C)
                   = C^3(C + 2)

    Corrected localization polynomial:
        P_{2,1}(C) = sqfree(R_{2,1}) = C(C + 2)

    Target root:
        c0 = -2

    P'_{2,1}(C) = 2C + 2, so P'(-2) = -2 != 0.

    Forbidden values at C=-2 for horizon H=3:
        H_{0,1} = Q_1 - Q_0 = -2
        H_{0,2} = Q_2 - Q_0 =  2
        H_{0,3} = Q_3 - Q_0 =  2
        H_{1,2} = Q_2 - Q_1 =  4
        H_{1,3} = Q_3 - Q_1 =  4

    Intended equality:
        H_{2,3} = Q_3 - Q_2 = 0

    This instance checks the equality/inequality split: the intended equality
    must be routed structurally, while forbidden collisions must be separated.
    """
    orbit_print("c = -2 smoke test", -2.0, 0.0, 3)


def m41_stress_test_numeric():
    """
    Stress instance: principal branch Misiurewicz point M_{4,1}.

    Approximate target:
        c0 ~= -0.10109636384562216 + 0.95628651080914150 i

    Critical-orbit type:
        (ell, k) = (4, 1)

    Raw return polynomial:
        R_{4,1}(C) = Q_5(C) - Q_4(C)

    Known factorization preserved from the spec:
        R_{4,1}(C)
          = C^5 (C+2)
            (C^3 + 2C^2 + 2C + 2)
            (C^7 + 4C^6 + 6C^5 + 6C^4
                 + 6C^3 + 4C^2 + 2C + 2)

    Corrected localization polynomial:
        P_{4,1}(C) = sqfree(R_{4,1})
          = C (C+2)
            (C^3 + 2C^2 + 2C + 2)
            (C^7 + 4C^6 + 6C^5 + 6C^4
                 + 6C^3 + 4C^2 + 2C + 2)

    Target root is the upper non-real root of the degree-7 factor.

    Landing angle datum:
        Theta = {9/56, 11/56, 15/56}

    Critical-orbit type and angle type differ:
        ell = 4, k = 1
        lambda = ell - 1 = 3
        ray period n = 3
        kneading/orbit period k = 1
    """
    orbit_print("M_{4,1} numeric stress test", -0.10109636384562216, 0.95628651080914150, 6)


def main():
    c_minus_2_smoke_test()
    print("---")
    m41_stress_test_numeric()
