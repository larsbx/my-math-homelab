"""Pseudocharacter => representation for a finite group, by search: GL_2(F_3) = Gal(Q(37a1[3])/Q)."""
import pytest

from langlands.galois_rep import frobenius_matrix
from langlands.newforms import newforms_of_level
from langlands.pseudochar import (are_conjugate, det, find_all_representations, find_representation, gl2,
                                  is_homomorphism, is_pseudocharacter, mat_mul, rouquier_data,
                                  rouquier_representation, trace)

P = 3
G = gl2(P)
ONE = (1, 0, 0, 1)
MUL = lambda x, y: mat_mul(x, y, P)
G0, G1 = (0, 1, 1, 1), (1, 2, 0, 1)  # rho_3(Frob_5), rho_3(Frob_7) of 37a1: order 8 and unipotent, generate GL_2(F_3)

TRACE = lambda g: trace(g, P)
TWIST = lambda g: (det(g, P) * trace(g, P)) % P            # trace of rho (x) det: p a_p mod 3 on Frob_p
CONTRA = lambda g: trace((g[3], -g[1] % P, -g[2] % P, g[0]), P)  # trace of the contragredient g^{-T}
BAD = lambda g: (trace(g, P) + det(g, P) - 1) % P            # tr + (det - 1): T(1) = 2, central, not Procesi


@pytest.mark.parametrize("T", [TRACE, TWIST, CONTRA], ids=["trace", "twist", "contragredient"])
def test_search_realises_pseudocharacters(T):
    assert is_pseudocharacter(T, G, MUL, ONE, P)
    rho = find_representation(T, G, MUL, ONE, (G0, G1), P)
    assert rho is not None and len(rho) == 48
    assert is_homomorphism(rho, G, MUL, P)
    assert all(trace(rho[g], P) == T(g) for g in G)


def test_non_pseudocharacter_is_rejected_and_unrealisable():
    """tr + det - 1 has T(1) = 2 and is central but fails Procesi; no representation has this trace."""
    assert BAD(ONE) == 2 and all(BAD(MUL(x, y)) == BAD(MUL(y, x)) for x in G for y in G)
    assert not is_pseudocharacter(BAD, G, MUL, ONE, P)
    assert find_representation(BAD, G, MUL, ONE, (G0, G1), P) is None


def test_twist_is_the_pseudocharacter_of_rho3_tensor_cyclotomic():
    """On Frobenius elements TWIST reads p a_p mod 3: the trace of rho_3(37a1) (x) chi_cyc."""
    E37 = newforms_of_level(37)[0]
    for p in (5, 7, 11, 13, 17, 19, 23):
        M = frobenius_matrix(E37.reduction(p), 3).matrix
        assert TWIST(M) == (p * E37.reduction(p).trace_of_frobenius) % 3


def test_found_representation_is_the_twist_up_to_conjugacy():
    """The search recovers g -> det(g) g: same trace and det everywhere, and the found rho is conjugate to it."""
    rho = find_representation(TWIST, G, MUL, ONE, (G0, G1), P)
    twist = {g: tuple((det(g, P) * e) % P for e in g) for g in G}
    assert all(trace(rho[g], P) == trace(twist[g], P) and det(rho[g], P) == det(twist[g], P) for g in G)
    inv = lambda c: tuple((pow(det(c, P), -1, P) * e) % P for e in (c[3], -c[1], -c[2], c[0]))
    assert any(all(MUL(MUL(c, twist[g]), inv(c)) == rho[g] for g in G) for c in G)


@pytest.mark.parametrize("T", [TRACE, TWIST], ids=["trace", "twist"])
def test_representation_is_unique_up_to_conjugacy(T):
    """Taylor's uniqueness: every solution of the search is conjugate to the first; there are exactly
    |GL_2(F_3)| / |centre| = 24 of them (the conjugates of one absolutely irreducible rho)."""
    sols = find_all_representations(T, G, MUL, ONE, (G0, G1), P)
    assert len(sols) == 24
    assert all(are_conjugate(sols[0], rho, G, P) for rho in sols)


@pytest.mark.parametrize("T", [TRACE, TWIST, CONTRA], ids=["trace", "twist", "contragredient"])
def test_rouquier_construction_is_a_representation_with_trace_T(T):
    """COMPUTED: the representation built from T alone (no search) is a homomorphism GL_2(F_3) -> GL_2(F_3)
    with trace T, conjugate to the one the search finds.  Instantiates `pseudochar_rep`
    (PseudocharRep.lean, PROVED for every group)."""
    g, lam, mu, x0, y0 = rouquier_data(T, G, MUL, P)
    rho = rouquier_representation(T, MUL, g, lam, mu, x0, y0, P)
    table = {x: rho(x) for x in G}
    assert table[ONE] == ONE
    assert is_homomorphism(table, G, MUL, P)
    assert all(trace(table[x], P) == T(x) for x in G)
    assert are_conjugate(table, find_representation(T, G, MUL, ONE, (G0, G1), P), G, P)


@pytest.mark.parametrize("k", [0, 1, 2, 3])
def test_rouquier_construction_over_F5(k):
    """COMPUTED: on GL_2(F_5), for the pseudocharacters T_k(g) = det(g)^k tr(g) (traces of g -> det(g)^k g),
    the constructed rho is a homomorphism with trace T_k on all 480^2 pairs.  Instantiates `pseudochar_rep`."""
    p = 5
    G5 = gl2(p)
    mul = lambda x, y: mat_mul(x, y, p)
    T = lambda x: (pow(det(x, p), k, p) * trace(x, p)) % p
    g, lam, mu, x0, y0 = rouquier_data(T, G5, mul, p)
    rho = rouquier_representation(T, mul, g, lam, mu, x0, y0, p)
    table = {x: rho(x) for x in G5}
    assert table[(1, 0, 0, 1)] == (1, 0, 0, 1)
    assert is_homomorphism(table, G5, mul, p)
    assert all(trace(table[x], p) == T(x) for x in G5)


def test_rouquier_construction_needs_procesi():
    """COMPUTED: on GL_2(F_5), T = tr + (det - 1) is central with T(1) = 2 (checked on all pairs) and fails
    Procesi; every other hypothesis of `pseudochar_rep` can be met (split g, lam != mu, B(x0, y0) != 0), and the
    constructed rho is not a homomorphism.  The Procesi identity is the hypothesis that does the work."""
    p = 5
    G5 = gl2(p)
    mul = lambda x, y: mat_mul(x, y, p)
    T = lambda g: (trace(g, p) + det(g, p) - 1) % p
    assert T((1, 0, 0, 1)) == 2 and all(T(mul(x, y)) == T(mul(y, x)) for x in G5 for y in G5)
    procesi = lambda x, y, z: (T(x) * T(y) * T(z) + T(mul(mul(x, y), z)) + T(mul(mul(x, z), y))
                               - T(mul(x, y)) * T(z) - T(mul(x, z)) * T(y) - T(mul(y, z)) * T(x)) % p
    assert any(procesi(x, y, z) for x in G5[:20] for y in G5[:20] for z in G5[:20])
    g, lam, mu, x0, y0 = rouquier_data(T, G5, mul, p)
    rho = rouquier_representation(T, mul, g, lam, mu, x0, y0, p)
    assert any(rho(mul(x, y)) != mat_mul(rho(x), rho(y), p) for x in G5[:40] for y in G5[:40])
