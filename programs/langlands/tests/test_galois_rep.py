"""Mod-ell Galois representations as computed matrices; the Weil pairing as the biextension commutator."""
import pytest

from langlands.galois_rep import _basis, frobenius_matrix, torsion_points, weil_pairing
from langlands.newforms import CREMONA_PRIME_LEVEL, newforms_of_level

E37 = newforms_of_level(37)[0]
PRIMES = [5, 7, 11, 13, 17, 19, 23, 29, 31]


@pytest.mark.parametrize("ell", [2, 3])
@pytest.mark.parametrize("f", CREMONA_PRIME_LEVEL, ids=lambda f: f.label)
def test_eichler_shimura_mod_ell_as_a_matrix_identity(f, ell):
    """rho_ell(Frob_p) on E[ell] over the splitting field: trace = a_p, det = p (mod ell)."""
    for p in PRIMES:
        if p == f.conductor:
            continue
        E = f.reduction(p)
        M = frobenius_matrix(E, ell)
        assert M.trace == E.trace_of_frobenius % ell and M.det == p % ell, (f.label, p, ell, M)
        assert (M.matrix[0] * M.matrix[3] - M.matrix[1] * M.matrix[2]) % ell != 0


def test_splitting_degree_is_the_order_of_the_frobenius_matrix():
    """Frob^k = 1 on E[ell] exactly when k is the splitting degree, so the matrix has that order."""
    for p in PRIMES:
        for ell in (2, 3):
            M = frobenius_matrix(E37.reduction(p), ell)
            a, b, c, d = M.matrix
            X, k = (1, 0, 0, 1), 0
            while True:
                X = ((X[0] * a + X[1] * c) % ell, (X[0] * b + X[1] * d) % ell, (X[2] * a + X[3] * c) % ell, (X[2] * b + X[3] * d) % ell)
                k += 1
                if X == (1, 0, 0, 1):
                    break
            assert k == M.splitting_degree, (p, ell, M)


@pytest.mark.parametrize("p", [7, 11, 13, 19])
@pytest.mark.parametrize("ell", [2, 3])
def test_weil_pairing_is_the_biextension_commutator(p, ell):
    """e_ell is bilinear, alternating, nondegenerate, of exact order ell, and Galois-equivariant:
    e(Frob P, Frob Q) = e(P, Q)^p, i.e. det rho_ell(Frob_p) = p (mod ell) — the cyclotomic character."""
    EK, pts = torsion_points(E37.reduction(p), ell)
    P, Q = _basis(EK, ell, pts)
    F = EK.F
    e = weil_pairing(EK, ell, P, Q)
    assert e != F.one and F.pow(e, ell) == F.one
    assert weil_pairing(EK, ell, P, P) == F.one and weil_pairing(EK, ell, Q, Q) == F.one
    assert weil_pairing(EK, ell, Q, P) == F.inv(e)
    assert weil_pairing(EK, ell, EK.add(P, Q), Q) == e  # bilinear with e(Q, Q) = 1
    assert weil_pairing(EK, ell, EK.mul(2, P), Q) == F.mul(e, e)
    assert weil_pairing(EK, ell, EK.frobenius(P), EK.frobenius(Q)) == F.pow(e, p)
    M = frobenius_matrix(E37.reduction(p), ell)
    assert F.pow(e, M.det) == F.pow(e, p)  # det rho = p mod ell, read off the pairing


# ------------------------------------------------------- image of rho_3 --
def _gl2(ell):
    return [(a, b, c, d) for a in range(ell) for b in range(ell) for c in range(ell) for d in range(ell)
            if (a * d - b * c) % ell]


def _mul(x, y, ell):
    return ((x[0] * y[0] + x[1] * y[2]) % ell, (x[0] * y[1] + x[1] * y[3]) % ell,
            (x[2] * y[0] + x[3] * y[2]) % ell, (x[2] * y[1] + x[3] * y[3]) % ell)


def _generated(gens, ell):
    seen, frontier = set(gens), list(gens)
    while frontier:
        new = [z for x in frontier for g in gens if (z := _mul(x, g, ell)) not in seen]
        seen.update(new)
        frontier = new
    return seen


def _invariants(m, ell):
    a, b, c, d = m
    return (a + d) % ell, (a * d - b * c) % ell, m == (1, 0, 0, 1)


def test_mod3_image_of_37a1_is_full():
    """rho_3(Frob_5) has order 8 and rho_3(Frob_7) is a non-scalar unipotent; every pair of elements of
    GL_2(F_3) with these invariants generates the whole group, so the image of rho_3 (a subgroup meeting
    both conjugacy classes) is GL_2(F_3).  Mirrors proof/langlands/LanglandsOracles/ImageMod3.lean."""
    F5 = frobenius_matrix(E37.reduction(5), 3).matrix
    F7 = frobenius_matrix(E37.reduction(7), 3).matrix
    assert _invariants(F5, 3) in {(1, 2, False), (2, 2, False)}, F5   # order 8
    assert _invariants(F7, 3) == (2, 1, False), F7                    # unipotent, order 3
    G = _gl2(3)
    assert len(G) == 48
    ord8 = [g for g in G if _invariants(g, 3) in {(1, 2, False), (2, 2, False)}]
    unip = [h for h in G if _invariants(h, 3) == (2, 1, False)]
    assert (len(ord8), len(unip)) == (12, 8)
    assert all(len(_generated([g, h], 3)) == 48 for g in ord8 for h in unip)


def test_mod3_image_criterion_is_sharp():
    """Negative control: an order-8 element with an order-3 element of a *different* kind (order 6,
    charpoly (x + 1)^2) still generates, but two unipotents never do (they lie in SL_2), and an order-8
    element with a scalar never does."""
    G = _gl2(3)
    ord8 = [g for g in G if _invariants(g, 3) in {(1, 2, False), (2, 2, False)}]
    unip = [h for h in G if _invariants(h, 3) == (2, 1, False)]
    assert all(len(_generated([h, k], 3)) <= 24 for h in unip for k in unip)
    assert all(len(_generated([g, (2, 0, 0, 2)], 3)) <= 16 for g in ord8)
