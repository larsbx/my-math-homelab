"""Branch 1: geometric class field theory for GL_1 on E = 37a1 mod p, executed end to end."""
import pytest

from langlands import cyclotomic as cyc
from langlands.gf import GF
from langlands.gl1 import (
    Line, abel_sum, all_characters, character_sheaf_trace, closed_points, divisor_valuations, extension_curve,
    frobenius_is_translation, is_character, isotypic_frobenius_exponent, l_series, lang_fibers,
    weil_reciprocity_product, zeta_coefficients,
)
from langlands.newforms import newforms_of_level

E37 = newforms_of_level(37)[0]
assert E37.label == "37a1"


@pytest.fixture(scope="module", params=[5, 7])
def curve(request):
    return E37.reduction(request.param)


def test_37a1_reductions_have_the_tabulated_traces():
    assert {p: E37.reduction(p).trace_of_frobenius for p in (5, 7, 11, 13, 17, 19, 23)} == {
        5: -2, 7: -1, 11: -5, 13: -2, 17: 0, 19: 0, 23: 2}


# --------------------------------------------------------------- Galois side --
@pytest.mark.parametrize("n", [2, 3, 4])
def test_lang_fibers_are_torsors_with_frobenius_acting_by_translation(curve, n):
    E = curve
    fibers = lang_fibers(E, n)
    assert set(fibers) == {x for x in E.points if E.mul(n, x) is None}  # keys = E(F_p)[n]
    assert all(len(f.points) == E.order for f in fibers.values())         # E(F_p)-torsors
    assert all(frobenius_is_translation(E, n, f) for f in fibers.values())


def test_frobenius_trace_on_isotypic_line_is_chi_of_x(curve):
    """The sheaf-function dictionary, literally: on the chi-isotypic line of Qbar_l[fiber over x],
    Frobenius acts by chi(x)."""
    E = curve
    n = 4 if E.F.p == 5 else 3
    fibers = lang_fibers(E, n)
    for chi in all_characters(E.structure):
        for x, fiber in fibers.items():
            assert isotypic_frobenius_exponent(E, n, fiber, chi) == chi.exponent(x)


# ----------------------------------------------------------- automorphic side --
@pytest.mark.parametrize("k", [2, 3])
def test_character_sheaf_trace_over_extensions_is_a_character(curve, k):
    """tr(Frob_{p^k} | A_chi) on Pic^0(F_{p^k}) = E(F_{p^k}) is chi o N and is a character;
    restricted to E(F_p) it is chi^k (N P = k P), not chi."""
    E = curve
    Ek = extension_curve(E, k)
    for chi in all_characters(E.structure):
        tr = character_sheaf_trace(E, chi, k)
        assert is_character(Ek, tr, chi.N)
        for P in E.points:
            Pk = None if P is None else (Ek.F.from_int(P[0][0]), Ek.F.from_int(P[1][0]))
            assert tr[Pk] == (k * chi.exponent(P)) % chi.N


def test_abel_principal_divisors_of_lines_sum_to_zero(curve):
    """chi(div f) = 1 for every unramified character: descent of the character along Abel–Jacobi."""
    E, F = curve, curve.F
    K = GF.of_order(F.p, 6)
    lines = [Line(F.from_int(l), F.from_int(m)) for l in range(F.p) for m in range(F.p)] + [Line(None, F.from_int(c)) for c in range(F.p)]
    for line in lines:
        assert abel_sum(E, line, K) is None


def test_weil_reciprocity_with_deligne_sign(curve):
    """prod_P (f, g)_P = 1 for lines f, g, with (f, g)_O = (-1)^{3*3} = -1 carried by the finite points."""
    E, F = curve, curve.F
    K = GF.of_order(F.p, 6)
    minus_one = K.neg(K.one)
    pairs = [((1, 2), (3, 1)), ((0, 1), (1, 0)), ((2, 2), (4, 3)), ((1, 1), (1, 3))]
    for (l1, m1), (l2, m2) in pairs:
        f, g = Line(F.from_int(l1), F.from_int(m1)), Line(F.from_int(l2), F.from_int(m2))
        finite, at_O = weil_reciprocity_product(E, f, g, K)
        assert at_O == minus_one
        assert K.mul(finite, at_O) == K.one
    # vertical vs non-vertical: v_O = 2, 3 -> sign (+1) at O
    f, g = Line(None, F.from_int(1)), Line(F.from_int(1), F.from_int(2))
    finite, at_O = weil_reciprocity_product(E, f, g, K)
    assert K.mul(finite, at_O) == K.one


def test_divisor_of_a_line_has_degree_zero(curve):
    E, F = curve, curve.F
    K = GF.of_order(F.p, 6)
    for l, m in ((1, 2), (0, 0), (2, 3)):
        vals = divisor_valuations(E, Line(F.from_int(l), F.from_int(m)), K)
        assert vals[None] == -3 and sum(vals.values()) == 0


# ------------------------------------------------------- the L-function --
def test_l_function_of_nontrivial_character_is_one_and_trivial_is_zeta(curve):
    """L(chi, T) = prod_x (1 - chi(Nx) T^{deg x})^{-1}:  = 1 for chi != 1 (H^1(Ebar, L_chi) = 0 as 2g-2 = 0),
    = Z(E, T) for chi = 1 (H^1 has Frobenius trace a_p, the same a_p Brandt sees at level 37)."""
    E = curve
    order = 4 if E.F.p == 5 else 3
    pts = closed_points(E, order)
    zeta = zeta_coefficients(E, order)
    assert zeta[1] == E.order and zeta[2] == (E.order * (E.order + 1)) // 2 + sum(1 for x in pts if x.degree == 2)
    for chi in all_characters(E.structure):
        L = l_series(E, chi, order, pts)
        if chi.is_trivial:
            assert tuple(sum(c) for c in L) == zeta
        else:
            assert all(cyc.is_zero_in_cyclotomic_field(c) for c in L[1:])
            assert not all(sum(c) == 0 for c in L[1:])  # the vanishing is in Z[zeta], not termwise
