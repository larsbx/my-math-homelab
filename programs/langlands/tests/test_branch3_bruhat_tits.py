"""Branch 3, second act: the Bruhat–Tits tree, Gamma_0(n)\\T, harmonic cochains, Hecke operators, Drinfeld side."""
import random
from collections import Counter

import pytest
import sympy as sp

from langlands import local_field as lf
from langlands.brandt import ramanujan_violations
from langlands.bruhat_tits import Gamma0Quotient, Tree, mat_from_polys, standard_vertex, vertex
from langlands.ec_function_field import monic_irreducibles


def gekeler_genus_prime(q: int, d: int) -> int:
    """g(X_0(p)) for p prime of degree d (Gekeler): (q^d - q^2)/(q^2 - 1) for d even, (q^d - q)/(q^2 - 1) for d odd."""
    return (q**d - (q**2 if d % 2 == 0 else q)) // (q**2 - 1)


# ------------------------------------------------------------------ tree --
@pytest.mark.parametrize("q", [2, 3, 5])
def test_tree_is_regular_and_symmetric(q):
    T = Tree(q)
    random.seed(q)
    for _ in range(30):
        k = random.randint(-3, 4)
        v = vertex(k, {e: random.randrange(q) for e in range(-2, k)})
        nb = T.neighbours(v)
        assert len(set(nb)) == q + 1
        assert all(v in T.neighbours(w) for w in nb)


@pytest.mark.parametrize("q", [2, 3, 5])
def test_reduction_lands_on_the_half_line_with_gl2_A(q):
    """Serre: GL_2(A)\\T is the ray v_0 - v_1 - ...; the Euclid loop exhibits gamma in GL_2(A)."""
    T = Tree(q)
    random.seed(q + 1)
    for _ in range(60):
        k = random.randint(-4, 6)
        v = vertex(k, {e: random.randrange(q) for e in range(-4, k)})
        n, g = T.reduce(v)
        (a, b), (c, d) = g
        assert all(all(e <= 0 for e in x) for x in (a, b, c, d))  # polynomial entries
        det = lf.add(lf.mul(a, d, q), lf.neg(lf.mul(b, c, q), q), q)
        assert set(det) == {0}  # unit determinant
        assert T.act(g, v) == standard_vertex(n)


@pytest.mark.parametrize("q", [2, 3])
def test_stabilizers_fix_standard_vertices_and_down_neighbours_are_equivalent(q):
    T = Tree(q)
    for n in range(4):
        for g in T.stabilizer_elements(n):
            assert T.act(g, standard_vertex(n)) == standard_vertex(n)
        if n >= 1:
            for a in range(1, q):  # (1-n, a t^n) -> v_{n-1} by the translation [[1, -a t^n], [0, 1]] in Stab(v_n)
                tau = mat_from_polys((1,), (0,) * n + ((-a) % q,), (), (1,), q)
                assert T.act(tau, vertex(1 - n, {-n: a})) == standard_vertex(n - 1)


# ------------------------------------------------------- level structure --
GENUS_CASES = [(2, (0, 1)), (2, (1, 1, 1)), (2, (1, 1, 0, 1)), (2, (1, 0, 1, 1)), (3, (1, 0, 1)), (3, (1, 2, 0, 1)), (2, (1, 1, 0, 0, 1))]


@pytest.mark.parametrize("q, n", GENUS_CASES)
def test_cusp_form_dimension_equals_gekeler_genus(q, n):
    G = Gamma0Quotient(q, n, len(n) + 1)
    assert G.genus == gekeler_genus_prime(q, len(n) - 1)
    assert Gamma0Quotient(q, n, len(n) + 2).genus == G.genus  # independent of the truncation depth
    levels = Counter(v[0] for v in G.vertices)
    assert levels[G.depth] == 2  # two cusps for prime n


@pytest.mark.parametrize("q, n", GENUS_CASES)
def test_cusp_forms_equal_first_betti_number_of_the_quotient_core(q, n):
    G = Gamma0Quotient(q, n, len(n) + 1)
    levels = Counter(v[0] for v in G.vertices)
    edge_levels = Counter(e[0] for e in G.edge_variables)
    V = sum(c for l, c in levels.items() if l < G.depth)
    E = sum(c for l, c in edge_levels.items() if l < G.depth - 1)
    assert G.genus == E - V + 1


@pytest.mark.slow
def test_genus_five_over_F5():
    assert Gamma0Quotient(5, (1, 1, 0, 1), 4).genus == 5


# ------------------------------------------------------------------ Hecke --
@pytest.mark.parametrize("q, n", [(2, (1, 1, 0, 1)), (3, (1, 2, 0, 1))])
def test_hecke_operators_commute_and_satisfy_drinfeld_ramanujan_bound(q, n):
    G = Gamma0Quotient(q, n, len(n) + 1)
    x = sp.Symbol("x")
    mats = {pr: G.hecke_matrix(pr) for pr in monic_irreducibles(q, 2) if pr != n}
    for a in mats.values():
        for b in mats.values():
            assert (a * b - b * a).is_zero_matrix
    for pr, T in mats.items():
        H = sp.Poly(T.charpoly(x).as_expr(), x)
        assert ramanujan_violations(H, q ** (len(pr) - 1)) == (0, 0)


def test_no_rational_eigenform_for_the_cubic_primes_over_F2_and_F3():
    """Charpolys of T_t are irreducible over Q: no elliptic curve of conductor n oo for these n."""
    x = sp.Symbol("x")
    G2 = Gamma0Quotient(2, (1, 1, 0, 1), 4)
    assert sp.expand(G2.hecke_matrix((0, 1)).charpoly(x).as_expr() - (x**2 + 2 * x - 1)) == 0
    G3 = Gamma0Quotient(3, (1, 2, 0, 1), 4)
    assert sp.expand(G3.hecke_matrix((0, 1)).charpoly(x).as_expr() - (x**3 + x**2 - 4 * x + 1)) == 0
    # n = t^3 + 2t + 1 is invariant under t -> t + c, so T_t, T_{t+1}, T_{t+2} are conjugate
    assert G3.hecke_matrix((1, 1)).charpoly(x) == G3.hecke_matrix((0, 1)).charpoly(x)


# ------------------------------------------------------ Drinfeld's dictionary --
from langlands.bruhat_tits import common_eigenvector  # noqa: E402
from langlands.ec_function_field import FunctionFieldCurve  # noqa: E402

E_T3 = FunctionFieldCurve(2, ((0, 1), (), (), (1,), ()))            # y^2 + t x y = x^3 + x
E_T4 = FunctionFieldCurve(2, ((0, 1), (), (0, 0, 1), (1,), (0, 1, 1, 1)))  # y^2 + t x y + t^2 y = x^3 + x + t^3 + t^2 + t


def good_primes(q, max_degree, level):
    return [f for f in monic_irreducibles(q, max_degree) if f[0]]  # p ∤ t


def test_curves_are_bad_only_at_t_and_split_at_infinity():
    for E in (E_T3, E_T4):
        assert E.bad_primes(4) == ((0, 1),)
        assert E.reduction_type((0, 1)) == "additive"
        assert E.reduction_type(None) == "split"


def test_drinfeld_dictionary_level_t3_over_F2():
    """The unique cusp form on Gamma_0(t^3)\\T over F_2(t) has T_p-eigenvalues a_p(E_T3) at every p ∤ t,
    deg p <= 3 (point counts over F_p); and L(E_T3, T) = 1, of degree deg(t^3 oo) - 4 = 0."""
    G = Gamma0Quotient(2, (0, 0, 0, 1), 5)
    assert G.genus == 1
    for pr in good_primes(2, 3, (0, 0, 0, 1)):
        T = G.hecke_matrix(pr)
        assert T.shape == (1, 1) and T[0, 0] == E_T3.trace_at(pr), pr
    assert E_T3.l_series(5) == (1, 0, 0, 0, 0, 0)


def test_drinfeld_dictionary_level_t4_newform_over_F2():
    """Level t^4 (genus 3) = two copies of the level-t^3 form plus one newform, whose eigenvalues are
    a_p(E_T4); L(E_T4, T) = 1 + 2T has degree 1 = deg(t^4 oo) - 4."""
    G = Gamma0Quotient(2, (0, 0, 0, 0, 1), 6)
    assert G.genus == 3
    primes = good_primes(2, 3, None)
    mats = {pr: G.hecke_matrix(pr) for pr in primes}
    x = sp.Symbol("x")
    old = {pr: E_T3.trace_at(pr) for pr in primes}
    new = {pr: E_T4.trace_at(pr) for pr in primes}
    for pr in primes:
        assert sp.expand(mats[pr].charpoly(x).as_expr() - (x - old[pr]) ** 2 * (x - new[pr])) == 0, pr
    assert common_eigenvector(mats, new) is not None
    assert E_T4.l_series(5) == (1, 2, 0, 0, 0, 0)


def test_cubic_prime_level_over_F2_has_no_rational_eigenform_and_no_curve():
    """Consistent negative: T_t on Gamma_0(t^3 + t + 1) has charpoly x^2 + 2x - 1 (irreducible), and the
    exhaustive search over a_i of degree <= i finds no curve of conductor n oo (checked offline, 2^21 models)."""
    G = Gamma0Quotient(2, (1, 1, 0, 1), 4)
    x = sp.Symbol("x")
    assert sp.Poly(G.hecke_matrix((0, 1)).charpoly(x).as_expr(), x).is_irreducible


E3_A = FunctionFieldCurve(3, ((), (0, 0, 1), (), (0, 1), (1,)))  # y^2 = x^3 + t^2 x^2 + t x + 1
E3_B = FunctionFieldCurve(3, ((), (0, 0, 1), (), (0, 2), (1,)))  # its t -> 2t conjugate


def test_drinfeld_dictionary_level_t3_over_F3():
    """Genus 2 at level t^3 over F_3(t): the two rational eigensystems are the two curves' traces."""
    G = Gamma0Quotient(3, (0, 0, 0, 1), 5)
    assert G.genus == 2
    primes = good_primes(3, 2, None)
    mats = {pr: G.hecke_matrix(pr) for pr in primes}
    for E in (E3_A, E3_B):
        assert E.bad_primes(3) == ((0, 1),) and E.reduction_type(None) == "split"
        assert common_eigenvector(mats, {pr: E.trace_at(pr) for pr in primes}) is not None
        assert E.l_series(4) == (1, 0, 0, 0, 0)
    assert E3_A.trace_at((1, 1)) == E3_B.trace_at((2, 1)) == 1  # t -> 2t swaps t+1 and t+2


@pytest.mark.slow
def test_level_t3_over_F5_has_no_rational_eigenform_as_tame_conductors_force():
    """In characteristic >= 5 the conductor exponent at an additive place is 2 (tame), so no elliptic curve
    over F_5(t) has conductor t^3 oo; accordingly X_0(t^3)/F_5 (genus 4) carries no rational eigenform."""
    from langlands.ec_function_field import FunctionFieldCurve
    from langlands.tate import PolyLocal, tate
    G = Gamma0Quotient(5, (0, 0, 0, 1), 5)
    assert G.genus == 4
    x = sp.Symbol("x")
    for pr in ((1, 1), (2, 1), (3, 1), (4, 1)):
        cp = sp.Poly(G.hecke_matrix(pr).charpoly(x).as_expr(), x)
        assert cp.ground_roots() == {}
    # Tate at t for additive curves over F_5(t): exponent 2 always
    for a in (((), (0, 0, 1), (), (0, 1), (1,)), ((), (), (), (0, 1), (0, 0, 1)), ((), (0, 1), (), (), (0, 0, 0, 1))):
        E = FunctionFieldCurve(5, a)
        res = tate(PolyLocal(5, (0, 1)), E.a)
        assert res.kodaira not in ("I0",) and not res.kodaira.startswith("I") or res.conductor_exponent <= 2
        if res.kodaira not in ("I0",) and not res.kodaira.startswith("I"):
            assert res.conductor_exponent == 2, res
