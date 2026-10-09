# run_examples.mojo
#
# Example runner for the finite-regime Mandelbrot computation scaffold.
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2, QUARANTINED).
#
# This is intentionally numeric at this stage. It preserves the computations
# used in the notes and gives future exact/dyadic code a behavioral target.

from dynamics.complex_box import C64, q_iter, h_ij, print_orbit
from certificates.collision_sets import print_collision_partition


fn run_c_minus_2():
    print("=== c = -2 smoke test ===")
    let c = C64(-2.0, 0.0)
    print_orbit(c, 3)

    print("Expected raw return polynomial:")
    print("R_{2,1}(C) = Q_3(C)-Q_2(C) = C^3(C+2)")
    print("Corrected squarefree localization polynomial:")
    print("P_{2,1}(C) = sqfree(R_{2,1}) = C(C+2)")
    print("Selected root: C=-2; other squarefree root C=0 is outside the box.")

    print_collision_partition(2, 1, 3)

    print("Forbidden value checks at C=-2:")
    let h01 = h_ij(c, 0, 1)
    let h02 = h_ij(c, 0, 2)
    let h03 = h_ij(c, 0, 3)
    let h12 = h_ij(c, 1, 2)
    let h13 = h_ij(c, 1, 3)
    print("H_01=", h01.re, "+", h01.im, "i")
    print("H_02=", h02.re, "+", h02.im, "i")
    print("H_03=", h03.re, "+", h03.im, "i")
    print("H_12=", h12.re, "+", h12.im, "i")
    print("H_13=", h13.re, "+", h13.im, "i")


fn run_m41_stress_target():
    print("=== M_{4,1} stress target ===")
    let c = C64(-0.10109636384562216, 0.95628651080914150)
    print_orbit(c, 6)

    print("Expected raw return polynomial factorization:")
    print("R_{4,1}=C^5(C+2)(C^3+2C^2+2C+2)F_7(C)")
    print("F_7=C^7+4C^6+6C^5+6C^4+6C^3+4C^2+2C+2")
    print("Corrected localization: P_{4,1}=sqfree(R_{4,1})")
    print("Target root is the upper non-real root of F_7.")

    print_collision_partition(4, 1, 6)

    print("Angle datum:")
    print("Theta = {9/56, 11/56, 15/56}")
    print("critical type (ell,k)=(4,1); angle preperiod lambda=3; ray period n=3")
    print("D^3(Theta)={1/7,2/7,4/7}; D cyclically permutes that set.")


fn main():
    run_c_minus_2()
    print("")
    run_m41_stress_target()
