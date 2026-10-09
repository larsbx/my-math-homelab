"""Branch 3: the Satake isomorphism for PGL_2.  Lean (`Satake.lean`) proves the algebra for every q;
these tests compute its two inputs on the lattice model of the tree and check its arithmetic output
on the Drinfeld eigenforms of levels t^3 over F_2(t) and F_3(t)."""
from collections import Counter

import pytest
import sympy as sp

from langlands.bruhat_tits import Gamma0Quotient, Tree
from langlands.ec_function_field import FunctionFieldCurve
from langlands.satake import (
    ORIGIN, chi, frobenius_power_trace, h, hecke_eigenvalues, hecke_structure_constants,
    horocycle_profile, local_hecke_image, sat, sphere,
)

E_T3 = FunctionFieldCurve(2, ((0, 1), (), (), (1,), ()))            # y^2 + t x y = x^3 + x, level t^3
E3_A = FunctionFieldCurve(3, ((), (0, 0, 1), (), (0, 1), (1,)))    # y^2 = x^3 + t^2 x^2 + t x + 1
E3_B = FunctionFieldCurve(3, ((), (0, 0, 1), (), (0, 2), (1,)))    # its t -> 2t conjugate


def pad(c, length):
    return tuple(c) + (0,) * (length - len(c))


def lift(c):
    """The same Laurent polynomial read in degree n + 2."""
    return (0, *c)


def mul_chi1(q, c):
    """Multiplication by X + q X^-1, degree n -> n + 1."""
    return tuple(a + q * b for a, b in zip((*c, 0), lift(c)))


def add(c, d, k=1):
    m = max(len(c), len(d))
    return tuple(a + k * b for a, b in zip(pad(c, m), pad(d, m)))


# ------------------------------------------------------ the Lean statements --
@pytest.mark.parametrize("q", [2, 3, 4, 5, 7, -3])
def test_closed_forms_mirror_lean(q):
    """sat_weyl, sat_hecke, sat_eq_chi_sub, chi_clebsch_gordan, ball_eq_chi at sample q (Lean: all q)."""
    for n in range(8):
        s = sat(q, n)
        assert all(s[n - j] == q ** (n - 2 * j) * s[j] for j in range(n // 2 + 1))
        assert mul_chi1(q, chi(q, n + 1)) == add(chi(q, n + 2), lift(chi(q, n)), q)
        if n >= 1:
            assert mul_chi1(q, sat(q, n + 1)) == add(sat(q, n + 2), lift(sat(q, n)), q)
        if n >= 2:
            assert s == add(chi(q, n), lift(chi(q, n - 2)), -1)
        ball = ()
        for i in range(n // 2 + 1):
            ball = add(ball, (0,) * i + sat(q, n - 2 * i))
        assert ball == chi(q, n)
    assert mul_chi1(q, sat(q, 1)) == add(sat(q, 2), lift(sat(q, 0)), q + 1)


# ------------------------------------------------ the inputs, on the tree --
@pytest.mark.parametrize("q", [2, 3, 5])
def test_horocycle_profile_of_spheres_is_the_satake_transform(q):
    """On the tree of PGL_2(F_q((1/t))): the sphere of radius n about v_0, sorted by the Iwasawa
    coordinate k (horocycles of the end k = -oo), has profile S(A_n) — the input `sphere_eq_sat` takes
    from the walk model."""
    for n in range(5 if q < 5 else 4):
        assert horocycle_profile(q, n) == sat(q, n), (q, n)


@pytest.mark.parametrize("q", [2, 3])
def test_hecke_relation_on_the_tree(q):
    """A_1 A_n = A_{n+1} + q A_{n-1} (n >= 2), A_1 A_1 = A_2 + (q+1) A_0: the structure constants
    #{w ~ o : d(w, u) = n} depend only on d(o, u) and are 1 at n+1, q (or q+1 at n = 1) at n-1, else 0."""
    for n in range(1, 4):
        expected = {r: {1 if r == n + 1 else (q + 1 if n == 1 else q) if r == n - 1 else 0} for r in range(n + 2)}
        assert hecke_structure_constants(q, n) == expected, (q, n)


@pytest.mark.parametrize("q", [2, 3])
def test_hecke_operator_of_sym_n_is_the_ball_of_the_parity(q):
    """K diag(pi^a, pi^(n-a)) K / K over 0 <= a <= n (pi = 1/t) is every vertex at distance n, n-2, ...
    from v_0, each exactly once: the local T(pi^n) = A_n + A_{n-2} + ... is the Hecke operator of Sym^n
    (`ball_eq_chi`)."""
    tree = Tree(q)
    for n in range(5):
        ball = [v for i in range(n // 2 + 1) for v in sphere(tree, ORIGIN, n - 2 * i)]
        assert local_hecke_image(q, n) == Counter(ball), (q, n)


# ------------------------------------------ the output, on Drinfeld eigenforms --
def test_satake_parameter_of_the_level_t3_form_over_F2():
    """T(p^n) on the unique cusp form of Gamma_0(t^3) over F_2(t) acts by h_n(alpha, beta), where
    alpha + beta = a_p, alpha beta = |p| (`hecke_seq_eq_h`), and h_n - |p| h_{n-2} = alpha^n + beta^n is
    |p|^n + 1 - #E_{t^3}(F_{p,n}) by counting points over the degree-n extension (`power_sum_eq`)."""
    G = Gamma0Quotient(2, (0, 0, 0, 1), 5)
    for prime, n_max in (((1, 1), 4), ((1, 1, 1), 2)):
        Q = 2 ** (len(prime) - 1)
        a = E_T3.trace_at(prime)
        e = hecke_eigenvalues(a, Q, n_max)
        for n in range(1, n_max + 1):
            T = G.hecke_matrix(prime, n)
            assert T.shape == (1, 1) and T[0, 0] == e[n], (prime, n)
            p_n = frobenius_power_trace(E_T3, prime, n)
            assert e[n] - Q * (e[n - 2] if n >= 2 else 0) == p_n, (prime, n)
        # the Satake parameter itself: alpha, beta roots of x^2 - a x + Q, and e_n = h_n(alpha, beta)
        x = sp.Symbol("x")
        alpha, beta = sp.roots(x**2 - a * x + Q, x, multiple=True)
        assert all(sp.expand(h(alpha, beta, n) - e[n]) == 0 for n in range(n_max + 1))


def test_satake_recursion_as_matrices_at_level_t3_over_F3():
    """Genus 2: T(p^2) = T(p)^2 - q, T(p^3) = T(p) T(p^2) - q T(p) as matrices (q-twisted Clebsch–Gordan,
    the Hecke algebra is Z[T(p)]), and both rational eigensystems have T(p^n)-eigenvalue e_n(a_p(E))
    with e_n - q e_{n-2} = the Frobenius trace of E over F_{3^n}."""
    G = Gamma0Quotient(3, (0, 0, 0, 1), 5)
    prime, q = (1, 1), 3
    T1, T2, T3 = (G.hecke_matrix(prime, n) for n in (1, 2, 3))
    I = sp.eye(T1.rows)
    assert T2 == T1 * T1 - q * I
    assert T3 == T1 * T2 - q * T1
    for E in (E3_A, E3_B):
        e = hecke_eigenvalues(E.trace_at(prime), q, 3)
        mats = {n: M for n, M in ((1, T1), (2, T2), (3, T3))}
        stacked = sp.Matrix.vstack(*[mats[n] - e[n] * I for n in mats])
        assert stacked.nullspace(), E
        assert [e[n] - q * (e[n - 2] if n >= 2 else 0) for n in (1, 2, 3)] == [frobenius_power_trace(E, prime, n) for n in (1, 2, 3)]
