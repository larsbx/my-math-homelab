"""Branch 3 seed: the Carlitz module (function-field G_m) and its reciprocity / decomposition law."""
from itertools import product

import pytest

from langlands.carlitz import CarlitzModule, annihilator, order_mod
from langlands.gf import GF, is_irreducible, poly_mod


def monic_irreducibles(p, deg):
    return [tuple(low) + (1,) for low in product(range(p), repeat=deg) if is_irreducible(tuple(low) + (1,), p)]


@pytest.mark.parametrize("p", [2, 3, 5])
def test_fermat_carlitz_identity(p):
    for deg in (1, 2, 3):
        for P in monic_irreducibles(p, deg):
            assert CarlitzModule(p).fermat_carlitz_holds(P)


def test_carlitz_action_is_a_ring_action():
    C, p = CarlitzModule(3), 3
    K = GF.of_order(3, 4)
    theta = K.gen  # t acts through a root of the modulus; any element works for the module axioms
    a, b = (1, 2, 1), (2, 0, 1)
    ab = tuple(int(c) for c in __import__("langlands.gf", fromlist=["poly_mul"]).poly_mul(a, b, p))
    for x in list(K.elements())[:20]:
        assert C.act(ab, x, K, theta) == C.act(a, C.act(b, x, K, theta), K, theta)
        for y in list(K.elements())[:5]:
            assert C.act(a, K.add(x, y), K, theta) == K.add(C.act(a, x, K, theta), C.act(a, y, K, theta))


@pytest.mark.parametrize("p, M, P", [
    (3, (0, 0, 1), (1, 1)),        # M = t^2,       P = t + 1
    (3, (1, 0, 1), (0, 1)),        # M = t^2 + 1,   P = t
    (3, (1, 0, 1), (2, 1)),        # M = t^2 + 1,   P = t + 2
    (2, (1, 1, 0, 1), (0, 1)),     # M = t^3+t+1,   P = t
    (2, (1, 1, 0, 1), (1, 1)),     # M = t^3+t+1,   P = t + 1
    (2, (1, 1, 1), (1, 1, 0, 1)),  # M = t^2+t+1,   P = t^3+t+1 (deg 3)
])
def test_carlitz_reciprocity_and_decomposition_law(p, M, P):
    """In the residue field F_P (a root theta of P) and its extension containing C[M]:
      * C_M(x) is separable with |M| = p^{deg M} roots (C[M] ≅ A/M as an A-module);
      * Frob_P(lambda) = lambda^{|P|} = C_P(lambda)   (Artin symbol of P = Carlitz action of P);
      * the F_P-degree of lambda equals the order of P in (A/ann lambda)^x  (splitting of P in K(C[M]))."""
    C = CarlitzModule(p)
    d = len(P) - 1
    f = order_mod(P, M, p)
    K = GF.of_order(p, d * f)
    theta = next(r for r, _ in K.poly_roots(tuple(K.from_int(c) for c in P)))
    roots = K.poly_roots(C.torsion_polynomial_mod(M, K, theta))
    assert all(m == 1 for _, m in roots) and len(roots) == p ** (len(M) - 1)
    torsion = [lam for lam, _ in roots]
    frob = lambda x: K.pow(x, p**d)  # noqa: E731  (Frobenius of F_P)
    assert all(frob(lam) == C.act(P, lam, K, theta) for lam in torsion)
    anns = {}
    for lam in torsion:
        ann = annihilator(C, lam, M, K, theta)
        orbit, x = 1, frob(lam)
        while x != lam:
            x, orbit = frob(x), orbit + 1
        assert orbit == (1 if len(ann) == 1 else order_mod(P, ann, p))
        anns[ann] = anns.get(ann, 0) + 1
    assert anns[M] >= 1  # a generator of C[M] exists
