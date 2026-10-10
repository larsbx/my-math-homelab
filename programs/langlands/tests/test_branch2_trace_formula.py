"""Branch 2: Brandt matrices, Eichler / Eichler–Selberg trace formulas, Jacquet–Langlands, Ramanujan."""
from fractions import Fraction

import pytest
import sympy as sp

from langlands.brandt import SupersingularLocus, ramanujan_violations
from langlands.modular_polynomial import MODULAR_POLYNOMIALS, phi_int
from langlands.newforms import CREMONA_PRIME_LEVEL, newforms_of_level
from langlands.qforms import class_number, hurwitz
from langlands.supersingular import supersingular_j_invariants
from langlands.trace_formula import eichler_brandt_trace, eichler_selberg_level1, ramanujan_tau, supersingular_count

PRIMES = (11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53)


# ------------------------------------------------------------ class numbers --
def test_class_numbers_against_gauss_table():
    table = {-3: 1, -4: 1, -7: 1, -8: 1, -11: 1, -15: 2, -19: 1, -20: 2, -23: 3, -24: 2, -31: 3, -35: 2,
             -39: 4, -40: 2, -43: 1, -47: 5, -51: 2, -52: 2, -55: 4, -56: 4, -59: 3, -67: 1, -71: 7, -163: 1,
             -12: 1, -16: 1, -27: 1, -28: 1, -32: 2, -36: 2, -48: 2, -64: 2, -75: 2, -99: 2, -100: 2}
    assert {d: class_number(d) for d in table} == table


def test_hurwitz_values():
    assert [hurwitz(N) for N in (0, 3, 4, 7, 8, 11, 12, 15, 16, 19, 20, 23)] == [
        Fraction(-1, 12), Fraction(1, 3), Fraction(1, 2), 1, 1, 1, Fraction(4, 3), 2, Fraction(3, 2), 1, 2, 3]


# --------------------------------------------------- Eichler–Selberg, level 1 --
def test_eichler_selberg_reproduces_ramanujan_tau():
    tau = ramanujan_tau(30)
    assert tau[:6] == (1, -24, 252, -1472, 4830, -6048)
    assert [eichler_selberg_level1(12, n) for n in range(1, 31)] == list(tau)


def test_eichler_selberg_dimensions():
    dims = {4: 0, 6: 0, 8: 0, 10: 0, 12: 1, 14: 0, 16: 1, 18: 1, 20: 1, 22: 1, 24: 2, 26: 1, 28: 2, 30: 2, 36: 3}
    assert {k: eichler_selberg_level1(k, 1) for k in dims} == dims


def test_eichler_selberg_weight_16_18_20_and_24():
    # unique normalized eigenforms: a_2 = 216 (k=16), -528 (k=18), 456 (k=20); dim S_24 = 2, tr T_2 = 1080.
    assert eichler_selberg_level1(16, 2) == 216
    assert eichler_selberg_level1(18, 2) == -528
    assert eichler_selberg_level1(20, 2) == 456
    assert eichler_selberg_level1(24, 2) == 1080


# ------------------------------------------------------ modular polynomials --
@pytest.mark.parametrize("ell", [2, 3])
def test_modular_polynomial_symmetric_and_kronecker_congruence(ell):
    phi = MODULAR_POLYNOMIALS[ell]
    assert all(phi[(j, i)] == c for (i, j), c in phi.items())
    X, Y = sp.symbols("X Y")
    expr = sum(c * X**i * Y**j for (i, j), c in phi.items())
    kron = sp.expand((X**ell - Y) * (X - Y**ell))
    assert sp.Poly(sp.expand(expr - kron), X, Y, modulus=ell).is_zero


def test_modular_polynomial_cm_points():
    assert phi_int(2, 1728, 287496) == 0        # j(i), j(2i)
    assert phi_int(2, 0, 54000) == 0            # j(rho), j(2 rho)
    assert phi_int(2, -3375, 16581375) == 0     # j((1+sqrt-7)/2), j(sqrt-7)
    assert phi_int(3, 0, -12288000) == 0        # j(rho), j(3 rho)
    Y = sp.Symbol("Y")
    phi2_1728 = sum(c * 1728**i * Y**j for (i, j), c in MODULAR_POLYNOMIALS[2].items())
    assert sp.expand(phi2_1728 - (Y - 1728) * (Y - 287496) ** 2) == 0
    phi3_0 = sum(c * 0**i * Y**j for (i, j), c in MODULAR_POLYNOMIALS[3].items())
    assert sp.expand(phi3_0 - Y * (Y + 12288000) ** 3) == 0


# ---------------------------------------------------------- supersingular --
@pytest.mark.parametrize("p", PRIMES + (59, 61, 67, 71, 73))
def test_supersingular_count_matches_deuring(p):
    expected = p // 12 + {1: 0, 5: 1, 7: 1, 11: 2}[p % 12]
    assert len(supersingular_j_invariants(p)) == expected == supersingular_count(p)


# -------------------------------------------------- Eichler's trace formula --
@pytest.mark.parametrize("p", PRIMES)
def test_brandt_traces_equal_class_number_side(p):
    """Spectral side (isogeny-graph adjacency traces) = geometric side (class numbers), all n <= 12 prime to p."""
    L = SupersingularLocus.of(p)
    for n in (1, 2, 3, 4, 6, 8, 9, 12):
        if n % p:
            assert L.hecke_operator(n).trace() == eichler_brandt_trace(p, n), (p, n)


@pytest.mark.parametrize("p", PRIMES)
def test_brandt_matrices_commute_and_are_stochastic(p):
    L = SupersingularLocus.of(p)
    B2, B3 = L.brandt_matrix(2), L.brandt_matrix(3)
    assert (B2 * B3 - B3 * B2).is_zero_matrix
    for ell, B in ((2, B2), (3, B3)):
        assert all(sum(B.row(i)) == ell + 1 for i in range(B.rows))
        W = sp.diag(*L.aut_orders)
        assert (B * W - (B * W).T).is_zero_matrix  # B_ij |Aut E_j| = B_ji |Aut E_i| (dual isogeny)


# ------------------------------------ Jacquet–Langlands via point counts --
@pytest.mark.parametrize("f", CREMONA_PRIME_LEVEL, ids=lambda f: f.label)
def test_jacquet_langlands_rational_newforms(f):
    """A common eigenvector of B(2), B(3) with eigenvalues a_2(E), a_3(E) exists, with multiplicity one."""
    L = SupersingularLocus.of(f.conductor)
    eig = {2: f.a(2), 3: f.a(3)}
    v = L.common_eigenvector(eig)
    assert v is not None, (f.label, eig)
    n = len(L.j)
    stacked = sp.Matrix.vstack(*[L.brandt_matrix(l) - a * sp.eye(n) for l, a in eig.items()])
    assert len(stacked.nullspace()) == len([g for g in newforms_of_level(f.conductor) if (g.a(2), g.a(3)) == (eig[2], eig[3])])


@pytest.mark.parametrize("p", (11, 17, 19, 37))
def test_eichler_trace_formula_against_point_counts_for_ell_up_to_31(p):
    """Levels where S_2(Gamma_0(p)) is spanned by rational newforms: tr B(ell) - (ell+1) = sum_E a_ell(E)."""
    forms = newforms_of_level(p)
    assert len(forms) == supersingular_count(p) - 1
    for ell in (5, 7, 11, 13, 17, 19, 23, 29, 31):
        if ell != p:
            assert eichler_brandt_trace(p, ell) - (ell + 1) == sum(f.a(ell) for f in forms), (p, ell)


@pytest.mark.parametrize("p", (23, 29, 31, 43))
def test_hecke_polynomials_with_irrational_eigenvalues(p):
    x = sp.Symbol("x")
    expected = {23: x**2 + x - 1, 29: x**2 + 2 * x - 1, 31: x**2 - x - 1, 43: (x + 2) * (x**2 - 2)}[p]
    assert sp.expand(SupersingularLocus.of(p).hecke_polynomial(2).as_expr() - expected) == 0


# ------------------------------------------------------ Ramanujan–Petersson --
@pytest.mark.parametrize("p", PRIMES + (59, 61, 67, 71))
@pytest.mark.parametrize("ell", [2, 3])
def test_isogeny_graph_is_ramanujan(p, ell):
    H = SupersingularLocus.of(p).hecke_polynomial(ell)
    assert ramanujan_violations(H, ell) == (0, 0)


# ------------------------------------------------ Vélu (no modular polynomial) --
@pytest.mark.parametrize("p", (11, 13, 17, 19, 23, 29, 31))
def test_velu_reproduces_phi3_brandt_matrix(p):
    L = SupersingularLocus.of(p)
    assert L.brandt_matrix_velu(3) == L.brandt_matrix(3)


@pytest.mark.parametrize("p", (11, 13, 17, 19, 23, 29, 31, 37))
def test_brandt_5_7_traces_and_commutation(p):
    """B(5), B(7) by Vélu: Eichler's formula at n = 5, 7, 25, 35, 49, 10, 14, 15, 21; commute with B(2), B(3)."""
    L = SupersingularLocus.of(p)
    for n in (5, 7, 10, 14, 15, 21, 25, 35, 49):
        if n % p:
            assert L.hecke_operator(n).trace() == eichler_brandt_trace(p, n), (p, n)
    B = {ell: L.brandt_matrix(ell) for ell in (2, 3, 5, 7) if ell != p}
    for x in B.values():
        for y in B.values():
            assert (x * y - y * x).is_zero_matrix


@pytest.mark.parametrize("f", [f for f in CREMONA_PRIME_LEVEL if f.conductor <= 37], ids=lambda f: f.label)
def test_jacquet_langlands_at_2_3_5_7(f):
    L = SupersingularLocus.of(f.conductor)
    eig = {ell: f.a(ell) for ell in (2, 3, 5, 7) if ell != f.conductor}
    assert L.common_eigenvector(eig) is not None, (f.label, eig)


@pytest.mark.parametrize("p", (11, 13, 17, 19, 23, 29, 31, 37))
@pytest.mark.parametrize("ell", [5, 7])
def test_isogeny_graph_is_ramanujan_at_5_and_7(p, ell):
    if ell != p:
        assert ramanujan_violations(SupersingularLocus.of(p).hecke_polynomial(ell), ell) == (0, 0)


# ------------------------------------------ Eichler–Selberg at level N --
from fractions import Fraction  # noqa: E402
from math import gcd  # noqa: E402

from langlands.modular_symbols import ManinSymbols  # noqa: E402
from langlands.trace_formula import eichler_selberg  # noqa: E402


def test_level_N_formula_reduces_to_zagier_at_level_1():
    assert all(eichler_selberg(1, 12, n) == eichler_selberg_level1(12, n) for n in range(1, 20))
    assert all(eichler_selberg(1, k, 2) == eichler_selberg_level1(k, 2) for k in (4, 16, 18, 20, 24))


@pytest.mark.parametrize("N", list(range(2, 41)))
def test_eichler_selberg_level_N_against_modular_symbols(N):
    """Geometric side (class numbers, local factors mu, A3, A4) = spectral side (1/2 tr T_n on cuspidal
    modular symbols) for weight 2, all n <= 12 prime to N."""
    M = ManinSymbols(N)
    for n in range(1, 13):
        if gcd(n, N) != 1:
            continue
        spectral = Fraction(M.cuspidal_hecke_matrix(n).trace(), 2) if M.cuspidal_basis.cols else Fraction(0)
        assert eichler_selberg(N, 2, n) == spectral, (N, n)


@pytest.mark.parametrize("p", (11, 13, 17, 19, 23, 29, 31, 37, 41, 43))
def test_level_p_formula_agrees_with_eichler_brandt_formula(p):
    """Two class-number formulas: tr T_n | S_2(Gamma_0(p)) = tr B(n) - sigma(n) (Eisenstein eigenvalue)."""
    for n in range(1, 13):
        if n % p:
            sigma = sum(d for d in range(1, n + 1) if n % d == 0)
            assert eichler_selberg(p, 2, n) == eichler_brandt_trace(p, n) - sigma, (p, n)
