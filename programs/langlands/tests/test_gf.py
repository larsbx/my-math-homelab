from hypothesis import given, settings
from hypothesis import strategies as st

from langlands.gf import GF, irreducible_polynomial, is_irreducible, poly_gcd, poly_mul

FIELDS = [GF.of_order(5, 1), GF.of_order(5, 2), GF.of_order(7, 3), GF.of_order(2, 4), GF.of_order(3, 3)]


def test_irreducible_search_is_deterministic_and_irreducible():
    for p, k in [(2, 1), (2, 7), (3, 4), (5, 2), (7, 3), (11, 2)]:
        f = irreducible_polynomial(p, k)
        assert len(f) == k + 1 and f[-1] == 1 and is_irreducible(f, p)


def test_reducible_detected():
    assert not is_irreducible(poly_mul((1, 1), (1, 1), 3), 3)
    assert poly_gcd(poly_mul((1, 1), (2, 1), 5), (1, 1), 5) == (1, 1)


@given(st.data())
@settings(max_examples=60)
def test_field_axioms(data):
    F = data.draw(st.sampled_from(FIELDS))
    elems = list(F.elements())
    a, b, c = (data.draw(st.sampled_from(elems)) for _ in range(3))
    assert F.mul(a, F.add(b, c)) == F.add(F.mul(a, b), F.mul(a, c))
    assert F.mul(F.mul(a, b), c) == F.mul(a, F.mul(b, c))
    if a != F.zero:
        assert F.mul(a, F.inv(a)) == F.one
    assert F.frobenius(F.add(a, b)) == F.add(F.frobenius(a), F.frobenius(b))
    assert F.frobenius(a, F.k) == a


def test_norm_lands_in_prime_field_and_is_multiplicative():
    F = GF.of_order(7, 3)
    for a in list(F.elements())[1:40]:
        assert F.is_prime_field_element(F.norm(a))
        assert F.norm(F.mul(a, F.gen)) == F.mul(F.norm(a), F.norm(F.gen))


def test_sqrt_table_and_roots():
    F = GF.of_order(5, 2)
    squares = {F.mul(a, a) for a in F.elements()}
    assert len(squares) == (25 + 1) // 2
    for s in squares:
        r = F.sqrt(s)
        assert r is not None and F.mul(r, r) == s
    # (Y - 2)^2 (Y - 3) over F_25
    two, three = F.from_int(2), F.from_int(3)
    poly = (F.neg(F.from_int(12)), F.from_int(16), F.neg(F.from_int(7)), F.one)
    assert dict(F.poly_roots(poly)) == {two: 2, three: 1}


def test_roots_of_inseparable_polynomials_keep_multiplicity_in_large_fields():
    K = GF.of_order(3, 10)  # above EXHAUSTIVE_LIMIT: the Cantor–Zassenhaus path
    assert K.order > K.EXHAUSTIVE_LIMIT
    one = K.one
    cube = (K.neg(one), K.zero, K.zero, one)  # (X - 1)^3 = X^3 - 1 in characteristic 3
    assert K.poly_roots(cube) == ((one, 3),)
    # (X - 1)^3 (X - t)^3 (X^2 + 1): inseparable part times a separable factor
    t = K.gen
    f = (one,)
    for factor in [(K.neg(one), one)] * 3 + [(K.neg(t), one)] * 3 + [(one, K.zero, one)]:
        f = K.pmul(f, factor)
    roots = dict(K.poly_roots(f))
    assert roots[one] == 3 and roots[t] == 3
    assert all(K.mul(r, r) != K.neg(one) or m == 1 for r, m in roots.items())


def test_sqrts_in_characteristic_two_are_unique():
    for k in (1, 3, 4):
        F = GF.of_order(2, k)
        for a in F.elements():
            roots = F.sqrts(a)
            assert len(roots) == 1 and F.mul(roots[0], roots[0]) == a  # Frobenius is bijective
    F5 = GF.of_order(5, 2)
    assert len(F5.sqrts(F5.from_int(4))) == 2 and F5.sqrts(F5.zero) == (F5.zero,)
