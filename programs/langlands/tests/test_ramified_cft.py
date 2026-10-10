"""Branch 1, ramified: class field theory of F_p(E) with modulus 2 P_0 (generalized Jacobian), executed."""
import pytest

from langlands import cyclotomic as cyc
from langlands.gl1 import closed_points, zeta_coefficients
from langlands.newforms import newforms_of_level
from langlands.ramified_cft import RayClassGroup, all_characters, conjugate, l_series

E37 = newforms_of_level(37)[0]


def setup(p: int, order: int):
    E = E37.reduction(p)
    P0 = E.points[1]
    T = next(P for P in E.points[1:] if P != P0 and P != E.neg(P0))
    return E, RayClassGroup(E, P0, T), closed_points(E, order)


@pytest.mark.parametrize("p", [5, 7])
def test_ray_class_group_is_an_extension_of_E_by_the_additive_group(p):
    E, G, _ = setup(p, 1)
    assert len(G.elements) == p * E.order
    # abelian and associative: the 2-cocycle is symmetric and satisfies the cocycle identity
    for S1 in E.points:
        for S2 in E.points:
            assert G.cocycle[(S1, S2)] == G.cocycle[(S2, S1)]
    pts = E.points[:4]
    for S1 in pts:
        for S2 in pts:
            for S3 in pts:
                a, b = G.add(G.add((S1, 1), (S2, 2)), (S3, 3)), G.add((S1, 1), G.add((S2, 2), (S3, 3)))
                assert a == b
    # the inertia subgroup {(O, a)} is F_p with the additive law (cocycle vanishes on it)
    assert all(G.add((None, a), (None, b)) == (None, (a + b) % p) for a in range(p) for b in range(p))
    assert len(G.log_table) == p * E.order


@pytest.mark.parametrize("p, order", [(5, 4), (7, 3)])
def test_l_functions_of_ray_class_characters(p, order):
    """L_m(chi, T) = prod_{x != P0} (1 - chi(x) T^{deg x})^{-1}:
       ramified chi (conductor 2 P0): a polynomial of degree 2g - 2 + 2 = 2 with |c_2|^2 = q^2 and
         |c_1|^2 <= 4q in every embedding (Weil / Riemann hypothesis);
       unramified nontrivial chi: 1 - chi(P0) T (the Euler factor at P0 removed from L = 1);
       trivial chi: Z(E, T) (1 - T)."""
    E, G, pts = setup(p, order)
    chars = all_characters(G)
    assert len(chars) == p * E.order
    ramified = [chi for chi in chars if chi.is_ramified]
    assert len(ramified) == p * E.order - E.order
    zeta = zeta_coefficients(E, order)
    P0_class = (G.P0, 0)  # (P0) is not prime to m; an unramified chi sees only the image in E(F_p)
    for chi in chars:
        L = l_series(G, chi, order, pts)
        N = chi.N
        if chi.is_trivial:
            assert tuple(sum(c) for c in L) == tuple(zeta[n] - (zeta[n - 1] if n else 0) for n in range(order + 1))
        elif not chi.is_ramified:
            assert cyc.equal_in_cyclotomic_field(L[1], cyc.scale(-1, cyc.unit(N, chi.exponent(P0_class))))
            assert all(cyc.is_zero_in_cyclotomic_field(c) for c in L[2:])
        else:
            assert all(cyc.is_zero_in_cyclotomic_field(c) for c in L[3:])
            assert not cyc.is_zero_in_cyclotomic_field(L[2])
            assert cyc.equal_in_cyclotomic_field(cyc.mul(L[2], conjugate(L[2])), cyc.scale(p * p, cyc.unit(N, 0)))
            assert cyc.all_conjugates_at_most(cyc.mul(L[1], conjugate(L[1])), 4 * p)


# ------------------------------------------------ invariant-factor decomposition --
from itertools import product  # noqa: E402
from math import prod  # noqa: E402

from langlands.abelian import abelian_structure  # noqa: E402
from langlands.ec import Curve  # noqa: E402
from langlands.gf import GF  # noqa: E402


@pytest.mark.parametrize("shape", [(4, 4), (2, 2, 2), (6, 2), (8, 4, 2), (3, 9), (12,), (2, 4, 4)])
def test_abelian_structure_on_products_of_cyclic_groups(shape):
    elems = list(product(*[range(n) for n in shape]))
    add = lambda a, b: tuple((x + y) % n for x, y, n in zip(a, b, shape))  # noqa: E731
    basis, orders = abelian_structure(elems, add, tuple(0 for _ in shape))
    assert prod(orders) == len(elems)
    assert all(orders[i] % orders[i + 1] == 0 for i in range(len(orders) - 1))
    gen = {tuple(0 for _ in shape)}
    for b, m in zip(basis, orders):
        gen = {add(g, tuple((k * x) % n for x, n in zip(b, shape))) for g in gen for k in range(m)}
    assert len(gen) == len(elems)


def test_noncyclic_ray_class_group_y2_eq_x3_plus_8_over_F13():
    """Review finding: E(F_13) = Z/4 x Z/4 for y^2 = x^3 + 8; the greedy decomposition raised because a
    maximal-order element's cyclic subgroup is not complemented by any raw element.  The recursive
    invariant-factor decomposition handles it; characters and L-series then work."""
    E = Curve.from_ints(GF.of_order(13, 1), 0, 8)
    assert E.structure.orders == (4, 4)
    P0 = E.points[1]
    T = next(P for P in E.points[1:] if P != P0 and P != E.neg(P0))
    G = RayClassGroup(E, P0, T)
    basis, orders = G.structure
    assert prod(orders) == 13 * 16 and orders[0] % orders[-1] == 0
    assert len(G.log_table) == 13 * 16
    chars = all_characters(G)
    assert len(chars) == 13 * 16 and sum(1 for c in chars if c.is_ramified) == 13 * 16 - 16
    pts = closed_points(E, 2)
    chi = next(c for c in chars if c.is_ramified)
    L = l_series(G, chi, 2, pts)
    assert cyc.equal_in_cyclotomic_field(cyc.mul(L[2], conjugate(L[2])), cyc.scale(169, cyc.unit(chi.N, 0)))
