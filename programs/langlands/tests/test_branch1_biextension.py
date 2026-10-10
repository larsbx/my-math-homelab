"""Branch 1: the Poincaré biextension of 37a1 in the monic Miller frame (exact Q arithmetic).

Over Q: rebuilds the Dossier II measurements (T1, T3, T4, T6, T8, T8v) independently and runs the acceptance
test it fixed in advance: with beta_2 twisted by (-1)^{u(a) du(c1,c2)} (`biextension.second_law`), the
exchange ratio is +1 on every stratum.  The sign algebra is PROVED in `BiextensionSign.lean`; tame Weil
reciprocity, which produces the sign, is the IMPORTED input measured here.
Over F_q: the Weil pairing is the commutator of (beta_1, strict beta_2), and E^v(F_p)[ell] parametrises the
order-ell characters of Pic^0(F_p) through it (geometric CFT duality, identified with `gl1`).
"""
from collections import Counter, defaultdict
from fractions import Fraction as F
from itertools import product

import pytest

from langlands.biextension import (
    E37A, FF, P0, commutator_pairing, deligne_sign, du, dual_character, exchange_ratio, first_law, frobenius,
    from_short, kappa_eds, miller_chain_eds, over, points, second_law, second_law_naive, to_short, ward_eds, weil,
)
from langlands.galois_rep import torsion_points, weil_pairing
from langlands.gf import GF
from langlands.gl1 import all_characters
from langlands.newforms import newforms_of_level

E = E37A
N = 4
PTS = {n: E.mul(n, P0) for n in range(-2 * N - 1, 2 * N + 2)}
IDX = range(-N, N + 1)


def sampled(fn, arity):
    """fn over all index tuples, skipping samples on a support (reported, never counted as passes)."""
    out = []
    for ns in product(IDX, repeat=arity):
        try:
            out.append((ns, fn(*(PTS[n] for n in ns))))
        except ZeroDivisionError:
            pass
    return out


def test_T1_multiples_of_the_generator():
    assert all(E.on_curve(P) for P in PTS.values())
    assert [PTS[n] for n in (1, 2, 3, 4, 5)] == [(0, 0), (1, 0), (-1, -1), (2, -3), (F(1, 4), F(-5, 8))]
    assert E.add(PTS[3], PTS[-3]) is None and E.add(PTS[4], PTS[-7]) == PTS[-3]


def test_T3_rigidification():
    for a in PTS.values():
        for c in PTS.values():
            assert first_law(E, c, None, a) == first_law(E, c, a, None) == 1
            assert second_law(E, a, None, c) == second_law(E, a, c, None) == 1
            assert second_law(E, None, a, c) == 1


def test_T4_T6_both_laws_are_symmetric_2_cocycles():
    """kappa(c; a1, a2) kappa(c; a1+a2, a3) = kappa(c; a1, a2+a3) kappa(c; a2, a3), exactly, and symmetry —
    for beta_1 and for the twisted beta_2 (the twist is a symmetric coboundary, `twist_cocycle`)."""
    def cocycle(law):
        def check(x, a1, a2, a3):
            lhs = law(E, x, a1, a2) * law(E, x, E.add(a1, a2), a3)
            rhs = law(E, x, a1, E.add(a2, a3)) * law(E, x, a2, a3)
            return lhs == rhs and law(E, x, a1, a2) == law(E, x, a2, a1)
        return check
    beta1 = lambda E_, c, a1, a2: first_law(E_, c, a1, a2)  # noqa: E731
    for law in (beta1, second_law):
        results = sampled(cocycle(law), 4)
        assert len(results) > 1000 and all(ok for _, ok in results)


def strata_of(ns):
    a1, a2, c1, c2 = (PTS[n] for n in ns)
    return E.ord_O(a1, a2), E.ord_O(c1, c2)


def test_T8_law_B_naive_exchange_fails_by_the_deligne_sign():
    """Naive swap: exchange ratio = (-1)^{ord_O g_{a1,a2} ord_O g_{c1,c2}} on every sample; -1 exactly on
    chord/chord, +1 on the vertical and O strata.  Every one of the nine strata is populated."""
    results = sampled(lambda a1, a2, c1, c2: (exchange_ratio(E, a1, a2, c1, c2, second_law_naive),
                                              deligne_sign(E, a1, a2, c1, c2)), 4)
    by_stratum = Counter()
    for ns, (ratio, sign) in results:
        assert ratio == sign, ns
        by_stratum[(strata_of(ns), ratio)] += 1
    assert set(k for k, _ in by_stratum) == set(product((0, -1, -2), repeat=2))
    assert all(r == (-1 if s == (-1, -1) else 1) for s, r in by_stratum)
    assert by_stratum[((-1, -1), -1)] >= 80 and by_stratum[((-2, -1), 1)] >= 40  # Dossier II's sample sizes


def test_acceptance_strict_second_law_satisfies_exchange_on_every_stratum():
    """The acceptance test of Dossier II §8, fixed before the construction: T8 and T8v return +1."""
    results = sampled(lambda a1, a2, c1, c2: exchange_ratio(E, a1, a2, c1, c2, second_law), 4)
    strata = Counter(strata_of(ns) for ns, _ in results)
    assert len(strata) == 9 and min(strata.values()) >= 40
    assert {r for _, r in results} == {1}


def test_generic_stratum_is_the_coboundary_of_u():
    """du(a, b) = [a, b, a+b != O] (`generic_eq_du`), and ord_O g_{a,b} is odd exactly there (`ordO_odd_iff`)."""
    for a, b in product(PTS.values(), repeat=2):
        assert du(E, a, b) == (E.ord_O(a, b) % 2)


# ---------------------------------------------------------------- over F_q --
E37_SHORT = newforms_of_level(37)[0]


@pytest.mark.parametrize("p", [5, 7, 11, 13])
@pytest.mark.parametrize("ell", [2, 3])
def test_weil_pairing_is_the_commutator_of_the_strict_biextension(p, ell):
    """prod beta_1(Q; iP, P) / prod beta_2(P; iQ, Q) over the Miller chain = e_ell(P, Q) of `galois_rep`
    (divisor-based Miller, short model, transported by (x, y) -> (36x, 108(2y+1))) on every independent
    pair of E[ell]; the naive swap gives (-1)^ell e_ell — the Law B sign summed along the chain
    (`chain_order`)."""
    EK, pts = torsion_points(E37_SHORT.reduction(p), ell)
    K = EK.F
    Em = over(E37A, K)
    checked = 0
    for Ps in pts:
        for Qs in pts:
            P, Q = (from_short((FF(K, R[0]), FF(K, R[1]))) for R in (Ps, Qs))
            assert Em.on_curve(P) and to_short(P) == (FF(K, Ps[0]), FF(K, Ps[1]))
            if Q in {Em.mul(i, P) for i in range(ell)}:
                continue
            e = FF(K, weil_pairing(EK, ell, Ps, Qs))
            assert commutator_pairing(Em, ell, P, Q) == e
            assert commutator_pairing(Em, ell, P, Q, second_law_naive) == (-1) ** ell * e
            checked += 1
    assert checked == (ell * ell - 1) * (ell * ell - ell)


def rational(P):
    return P is None or frobenius(P) == P


@pytest.mark.parametrize("p, ell, k", [(5, 2, 4), (7, 3, 3)])
def test_dual_curve_parametrises_the_characters_of_pic0(p, ell, k):
    """chi_c(x) = e_ell(Frob y - y, c), ell y = x: the Frobenius eigenvalue at x of the [ell]-cover local
    system with character e_ell(., c).  For c in E(F_p)[ell]: independent of y, a character of
    Pic^0(F_p) = E(F_p), multiplicative in c (the second law), and c -> chi_c is a bijection onto the
    characters of order dividing ell — exactly those of `gl1.all_characters` (short model) with
    ell chi = 0.  Geometric CFT duality at level ell: E^v(F_p)[ell] = Hom(E(F_p), mu_ell)."""
    Ek = over(E37A, GF.of_order(p, k))
    pts = points(Ek)
    fibre = defaultdict(list)
    for y in pts:
        fibre[Ek.mul(ell, y)].append(y)
    rat = [P for P in pts if rational(P)]
    tors = [c for c in rat if Ek.mul(ell, c) is None]
    chi = {}
    for c in tors:
        for x in rat:
            values = dual_character(Ek, ell, c, tuple(fibre[x]))
            assert len(values) == 1, (c, x)
            chi[c, x] = values.pop()
    assert all(chi[c, Ek.add(x, z)] == chi[c, x] * chi[c, z] for c in tors for x in rat for z in rat)
    assert all(chi[Ek.add(c, d), x] == chi[c, x] * chi[d, x] for c in tors for d in tors for x in rat)
    # identification with the automorphic side of gl1: discrete logs against a generator of mu_ell
    Es = E37_SHORT.reduction(p)
    zeta = next(z for z in (FF(Ek.a1.K, Ek.a1.K.from_int(a)) for a in range(2, p)) if z**ell == 1)
    log = {zeta**i: i for i in range(ell)}
    short = {x: None if x is None else tuple(Es.F.from_int(c.v[0]) for c in to_short(x)) for x in rat}
    N = Es.structure.exponent
    ours = {tuple(log[chi[c, x]] * (N // ell) % N for x in rat) for c in tors}
    theirs = {tuple(ch.exponent(short[x]) for x in rat) for ch in all_characters(Es.structure)
              if all(ell * ch.exponent(short[x]) % N == 0 for x in rat)}
    assert len(ours) == len(tors) == ell and ours == theirs


def test_isogeny_local_system_is_the_lang_local_system_at_degree_two():
    """p = 7, ell = 3: at all 54 closed points of degree 2 (x in E(F_49) minus E(F_7)), Frob^2 acts on the
    [3]-cover local system with character e_3(., c) by chi_c(x + Frob x): the trace function of the Lang
    local system L_{chi_c} (sec. 1.1), beyond the rational points that define chi_c."""
    Ek = over(E37A, GF.of_order(7, 6))
    pts = points(Ek)
    fibre = defaultdict(list)
    for y in pts:
        fibre[Ek.mul(3, y)].append(y)
    deg2 = [x for x in pts if frobenius(x, 2) == x and not rational(x)]
    tors = [c for c in pts if rational(c) and Ek.mul(3, c) is None]
    assert len(deg2) == 54 and len(tors) == 3
    for c in tors:
        for x in deg2:
            N = Ek.add(x, frobenius(x))
            y0 = fibre[N][0]
            predicted = weil(Ek, 3, Ek.add(frobenius(y0), Ek.neg(y0)), c)
            assert {weil(Ek, 3, Ek.add(frobenius(y, 2), Ek.neg(y)), c) for y in fibre[x]} == {predicted}


# ------------------------------------------------------- elliptic nets (§8 item 2) --
W37 = ward_eds(E, P0, 40)


def test_T2_ward_eds_of_37a1():
    """W_n = psi_n(P0): 0, 1, 1, -1, 1, 2, -1, -3, -5, 7, -4, -23, 29 (W_12^2 = 841, Dossier II's appendix);
    den x(nP0) = W_n^2 and den y(nP0) = |W_n|^3."""
    assert [W37[n] for n in range(13)] == [0, 1, 1, -1, 1, 2, -1, -3, -5, 7, -4, -23, 29]
    for n in range(1, 20):
        x, y = E.mul(n, P0)
        assert x.denominator == W37[n] ** 2 and y.denominator == abs(W37[n]) ** 3


def test_kappa_tame_is_an_elliptic_net_quotient():
    """The closed form of kappa_tame on 37a1 asked for in Dossier II §8 (item 2), measured on every
    (k, m, n) in [-8, 8]^3 off the supports, generic and vertical strata, exactly."""
    PTS8 = {j: E.mul(j, P0) for j in range(-8, 9)}
    counts = Counter()
    for k, m, n in product(range(-8, 9), repeat=3):
        if 0 in (k, m, n):
            continue
        try:
            value = E.miller(PTS8[m], PTS8[n], PTS8[k])
        except ZeroDivisionError:
            continue
        assert value == kappa_eds(W37, k, m, n), (k, m, n)
        counts[E.ord_O(PTS8[m], PTS8[n])] += 1
    assert counts[-1] > 2000 and counts[-2] > 100


def test_miller_chain_telescopes_to_eds():
    """f_{N,P0}(kP0) = prod_{i<N} g_{iP0,P0}(kP0) = (-1)^(N-1) W_N W_{k-1}^N / (W_{k-N} W_k^(N-1))."""
    for N in range(2, 9):
        for k in range(N + 1, N + 12):
            f, A = F(1), P0
            for _ in range(1, N):
                f, A = f * E.miller(A, P0, E.mul(k, P0)), E.add(A, P0)
            assert f == miller_chain_eds(W37, N, k), (N, k)


def test_third_chord_point_is_a_removable_zero_not_support():
    """g_{A,B} at c = -(A+B) (chord and vertical both vanish, c not in div g) is regularised through the
    conjugate chord and agrees with the elliptic-net closed form on every such sample (review fix)."""
    for m, n in product(range(-6, 7), repeat=2):
        if 0 in (m, n, m + n) or 2 * (m + n) == 0:
            continue
        c = E.mul(-(m + n), P0)
        assert E.miller(PTS[m], PTS[n], c) == kappa_eds(W37, -(m + n), m, n), (m, n)


def test_ff_equality_and_arithmetic_respect_the_field():
    """1 in F_5 and 1 in F_7 are different elements; mixing fields is rejected (review fix)."""
    one5, one7 = FF(GF.of_order(5, 1), (1,)), FF(GF.of_order(7, 1), (1,))
    assert one5 != one7 and len({one5, one7}) == 2 and one5 == 1
    with pytest.raises(ValueError):
        one5 + one7
