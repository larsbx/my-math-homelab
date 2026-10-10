"""The image of rho_2 for the 15 Cremona curves of prime level: exact type, Frobenius witnesses,
and the Dedekind consistency between computed Frobenius matrices and the 2-division cubic mod p."""
import pytest

from langlands.mod2_image import (frobenius_class, mod2_image, psi2_coefficients, root_count_mod_p)
from langlands.galois_rep import frobenius_matrix
from langlands.newforms import CREMONA_PRIME_LEVEL

EXPECTED = {"17a1": "C2", "73a1": "C2", "89b1": "C2"}


@pytest.mark.parametrize("f", CREMONA_PRIME_LEVEL, ids=lambda f: f.label)
def test_mod2_image_type(f):
    """S_3 for twelve curves; C_2 with a rational 2-torsion point for 17a1, 73a1, 89b1; never C_3 or trivial."""
    im = mod2_image(f)
    assert im.group == EXPECTED.get(f.label, "S3"), im
    c3, c2, c1, c0 = psi2_coefficients(f.a_invariants)
    assert all(c3 * r**3 + c2 * r**2 + c1 * r + c0 == 0 for r in im.rational_roots)
    if im.group == "S3":
        assert {"ord3", "ord2"} <= im.witnesses.keys(), im
    else:
        assert len(im.rational_roots) == 1 and "ord2" in im.witnesses and "ord3" not in im.witnesses, im


@pytest.mark.parametrize("f", CREMONA_PRIME_LEVEL, ids=lambda f: f.label)
def test_frobenius_class_matches_cubic_factorisation(f):
    """Dedekind: rho_2(Frob_p) has order 3, 2, 1 exactly when psi_2 mod p has 0, 1, 3 roots."""
    c = psi2_coefficients(f.a_invariants)
    for p in (5, 7, 11, 13, 17, 19, 23, 29, 31):
        if p == f.conductor:
            continue
        cls = frobenius_class(frobenius_matrix(f.reduction(p), 2).matrix)
        assert {0: "ord3", 1: "ord2", 3: "id"}[root_count_mod_p(c, p)] == cls, (f.label, p)


def test_s3_generated_by_orders_three_and_two():
    """In GL_2(F_2) = S_3 every (order-3, order-2) pair generates; two order-2 elements need not."""
    G = [(a, b, c, d) for a in (0, 1) for b in (0, 1) for c in (0, 1) for d in (0, 1) if (a * d - b * c) % 2]
    mul = lambda x, y: ((x[0]*y[0] + x[1]*y[2]) % 2, (x[0]*y[1] + x[1]*y[3]) % 2, (x[2]*y[0] + x[3]*y[2]) % 2, (x[2]*y[1] + x[3]*y[3]) % 2)

    def gen(gens):
        seen, frontier = set(gens), list(gens)
        while frontier:
            new = [z for x in frontier for g in gens if (z := mul(x, g)) not in seen]
            seen.update(new)
            frontier = new
        return seen

    ord3 = [g for g in G if frobenius_class(g) == "ord3"]
    ord2 = [g for g in G if frobenius_class(g) == "ord2"]
    assert (len(G), len(ord3), len(ord2)) == (6, 2, 3)
    assert all(len(gen([g, h])) == 6 for g in ord3 for h in ord2)
    assert all(len(gen([h, h])) == 2 for h in ord2)
