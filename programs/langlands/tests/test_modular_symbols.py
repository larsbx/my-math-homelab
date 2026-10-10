"""Manin symbols for Gamma_0(N): dimensions, Jacquet–Langlands vs modular symbols, modularity at composite level."""
import pytest
import sympy as sp

from langlands.brandt import SupersingularLocus, ramanujan_violations
from langlands.modular_symbols import ManinSymbols, cusp_count, genus_X0
from langlands.newforms import point_count_general

x = sp.Symbol("x")


@pytest.mark.parametrize("N", list(range(2, 61)))
def test_dimensions_match_genus_and_cusps(N):
    """dim H_1(X_0(N), cusps; Q) = 2g + c - 1 and the cuspidal part has dimension 2g."""
    M = ManinSymbols(N)
    g, c = genus_X0(N), cusp_count(N)
    assert M.dimension == 2 * g + c - 1
    assert M.cuspidal_basis.cols == 2 * g


def test_known_genera():
    assert [genus_X0(N) for N in (11, 13, 14, 15, 17, 19, 20, 23, 27, 32, 36, 37, 43, 53, 59, 61, 101)] == \
        [1, 0, 1, 1, 1, 1, 1, 2, 1, 1, 1, 2, 3, 4, 5, 4, 8]


@pytest.mark.parametrize("p", (11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53))
def test_jacquet_langlands_modular_symbols_agree_with_brandt(p):
    """Two independent automorphic computations: char poly of T_ell on cuspidal modular symbols of level p
    equals the square of the Brandt Hecke polynomial (H_1 = S_2 ⊕ S_2-bar), for ell in {2, 3, 5, 7}."""
    M = ManinSymbols(p)
    L = SupersingularLocus.of(p)
    for ell in (2, 3, 5, 7):
        if ell == p:
            continue
        ms = M.cuspidal_hecke_polynomial(ell)
        brandt = L.hecke_polynomial(ell)
        assert sp.expand(ms.as_expr() - brandt.as_expr() ** 2) == 0, (p, ell)


COMPOSITE_CURVES = {  # conductor: minimal model (from the Tate tests)
    14: (1, 0, 1, 4, -6), 15: (1, 1, 1, -10, -10), 20: (0, 1, 0, 4, 4),
    27: (0, 0, 1, 0, -7), 32: (0, 0, 0, -1, 0), 36: (0, 0, 0, 0, 1),
}


@pytest.mark.parametrize("N", list(COMPOSITE_CURVES))
def test_modularity_at_composite_level(N):
    """genus 1 levels: a_p(E) by point count is the T_p-eigenvalue on the 2-dimensional cuspidal space."""
    M = ManinSymbols(N)
    assert M.cuspidal_basis.cols == 2
    for p in (2, 3, 5, 7, 11, 13):
        if N % p == 0:
            continue
        a_p = p + 1 - point_count_general(COMPOSITE_CURVES[N], p)
        assert sp.expand(M.cuspidal_hecke_polynomial(p).as_expr() - (x - a_p) ** 2) == 0, (N, p, a_p)


@pytest.mark.parametrize("N", (23, 29, 31, 41, 43, 47))
def test_hecke_operators_commute_and_are_ramanujan(N):
    M = ManinSymbols(N)
    mats = {ell: M.cuspidal_hecke_matrix(ell) for ell in (2, 3, 5, 7) if N % ell}
    for a in mats.values():
        for b in mats.values():
            assert (a * b - b * a).is_zero_matrix
    for ell, T in mats.items():
        assert ramanujan_violations(sp.Poly(T.charpoly(x).as_expr(), x), ell) == (0, 0)


# ------------------------------------------------------------- weight k --
from fractions import Fraction  # noqa: E402
from math import gcd  # noqa: E402

from langlands.modular_symbols import ManinSymbolsK, dim_S_k  # noqa: E402
from langlands.trace_formula import eichler_selberg, ramanujan_tau  # noqa: E402

WEIGHT_GRID = [(N, k) for N in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12) for k in (4, 6, 8, 12)] + [(16, 4), (18, 6), (25, 4), (27, 4)]


def test_dim_S_k_known_values():
    assert [dim_S_k(1, k) for k in (4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26)] == [0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 2, 1]
    assert dim_S_k(11, 4) == 2 and dim_S_k(2, 8) == 1 and dim_S_k(7, 6) == 3


@pytest.mark.parametrize("N, k", WEIGHT_GRID)
def test_weight_k_dimensions(N, k):
    M = ManinSymbolsK(N, k)
    assert M.dimension == 2 * dim_S_k(N, k) + cusp_count(N)
    assert M.cuspidal_basis.cols == 2 * dim_S_k(N, k)


@pytest.mark.parametrize("N, k", WEIGHT_GRID)
def test_eichler_selberg_higher_weight_against_operator_traces(N, k):
    """The weight dependence of every term (n^{k/2-1}, P_k, min^{k-1}, A4) checked against 1/2 tr T_n on
    cuspidal weight-k modular symbols, n <= 7 prime to N."""
    M = ManinSymbolsK(N, k)
    for n in range(1, 8):
        if gcd(n, N) != 1:
            continue
        spectral = Fraction(M.cuspidal_hecke_matrix(n).trace(), 2) if M.cuspidal_basis.cols else Fraction(0)
        assert eichler_selberg(N, k, n) == spectral, (N, k, n)


def test_weight_12_level_1_operator_traces_are_tau():
    M = ManinSymbolsK(1, 12)
    tau = ramanujan_tau(10)
    assert [M.cuspidal_hecke_matrix(n).trace() / 2 for n in range(1, 11)] == list(tau)


@pytest.mark.parametrize("N", (11, 14, 15, 23, 37))
def test_weight_2_eisenstein_complement_matches_boundary_map(N):
    """Two constructions of the cuspidal subspace at weight 2 give the same Hecke traces."""
    A, B = ManinSymbols(N), ManinSymbolsK(N, 2)
    assert A.cuspidal_basis.cols == B.cuspidal_basis.cols == 2 * genus_X0(N)
    for n in (2, 3, 5, 7):
        if N % n:
            assert A.cuspidal_hecke_matrix(n).trace() == B.cuspidal_hecke_matrix(n).trace()


@pytest.mark.parametrize("N, k", [(1, 24), (7, 6), (11, 4), (5, 8)])
def test_ramanujan_at_higher_weight(N, k):
    """|a_ell| <= 2 ell^{(k-1)/2} (Deligne): exact root isolation on the cuspidal Hecke polynomial."""
    M = ManinSymbolsK(N, k)
    for ell in (2, 3, 5):
        if N % ell:
            H = sp.Poly(M.cuspidal_hecke_matrix(ell).charpoly(x).as_expr(), x)
            assert ramanujan_violations(H, ell ** (k - 1)) == (0, 0)
