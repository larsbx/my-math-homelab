"""
Finite collision-set and ray-address-doubling computations for the certificate calculus.

This file preserves the non-analytic combinatorial computations used by the
spec. It avoids external rays as geometric objects; addresses are rational
pairs (num, den), and doubling is arithmetic modulo den.
"""

from finite_exact.integer_gcd import gcd_int


def reduce_num(num0: Int, den0: Int) raises -> Int:
    var num = num0 % den0
    if num < 0:
        num += den0
    var g = gcd_int(num, den0)
    return num // g


def reduce_den(num0: Int, den0: Int) raises -> Int:
    var num = num0 % den0
    if num < 0:
        num += den0
    var g = gcd_int(num, den0)
    return den0 // g


def doubled_num(num: Int, den: Int) raises -> Int:
    return reduce_num(2 * num, den)


def doubled_den(num: Int, den: Int) raises -> Int:
    return reduce_den(2 * num, den)


def print_doubling_orbit(label: String, num0: Int, den0: Int, steps: Int) raises:
    print(label)
    var num = reduce_num(num0, den0)
    var den = reduce_den(num0, den0)
    print("D^0 = ", num, "/", den)
    for n in range(steps):
        var next_num = doubled_num(num, den)
        var next_den = doubled_den(num, den)
        num = next_num
        den = next_den
        print("D^", n + 1, " = ", num, "/", den)


def print_intended_forbidden_sets(ell: Int, k: Int, horizon: Int):
    """
    Intended equality set:
        I_{ell,k}(H) = {(i,j): 0 <= i < j <= H, i >= ell, k | (j-i)}

    Forbidden set:
        F_{ell,k}(H) = all pairs minus I_{ell,k}(H)

    This is the semantic fix that keeps longer horizons from rejecting
    intended periodic-tail equalities.
    """
    print("intended pairs I_{ell,k}(H):")
    for i in range(horizon + 1):
        for j in range(i + 1, horizon + 1):
            if i >= ell and ((j - i) % k == 0):
                print("  (", i, ", ", j, ")")

    print("forbidden pairs F_{ell,k}(H):")
    for i in range(horizon + 1):
        for j in range(i + 1, horizon + 1):
            if not (i >= ell and ((j - i) % k == 0)):
                print("  (", i, ", ", j, ")")


def c_minus_2_sets() raises:
    print("c=-2 horizon H=3")
    print_intended_forbidden_sets(2, 1, 3)
    print_doubling_orbit("ray address 1/2", 1, 2, 3)


def m41_sets() raises:
    print("M_{4,1} horizon H=6")
    print_intended_forbidden_sets(4, 1, 6)
    print_doubling_orbit("ray address 9/56", 9, 56, 6)
    print_doubling_orbit("ray address 11/56", 11, 56, 6)
    print_doubling_orbit("ray address 15/56", 15, 56, 6)


def main() raises:
    c_minus_2_sets()
    print("---")
    m41_sets()
