import pytest

from psc_research.degree2_parity import (
    _remainder,
    characteristic_cubic_mod2,
    exterior_characteristic_cubic_mod2,
    gcd_mod2,
    minimum_degree2_scc_size_from_parity,
    parity_sieve,
)


def _naive_remainder(a: int, b: int) -> int:
    """Independent reference: recompute both degrees on every comparison.

    Valid only for positive bitmasks, which is the domain the differential test
    exercises.
    """
    while a and a.bit_length() >= b.bit_length():
        a ^= b << (a.bit_length() - b.bit_length())
    return a


def test_remainder_rejects_negative_bitmasks_before_dividing():
    """`_remainder` fails closed when reached outside `gcd_mod2`.

    A negative bitmask is an impossible exact-arithmetic state.  Caching a raw
    `bit_length()` instead of going through `_degree` drops this check: `(-1, 1)`
    then oscillates between `-1` and `-2` forever, and a negative divisor grows
    the dividend without bound instead of raising, so the invalid state would be
    reported as a remainder rather than refused.
    """
    for a, b in ((-1, 1), (-2, 0b11), (0b1011, -1), (-1, -1)):
        with pytest.raises(ValueError):
            _remainder(a, b)


def test_remainder_keeps_its_zero_contract():
    assert _remainder(0, 0b1011) == 0
    with pytest.raises(ZeroDivisionError):
        _remainder(0b1011, 0)


def test_remainder_agrees_with_the_naive_reference_on_valid_bitmasks():
    for a in range(1, 256):
        for b in range(1, 40):
            assert _remainder(a, b) == _naive_remainder(a, b)


def test_all_eight_parity_classes_have_expected_lower_bound():
    expected = {
        (0, 0, 0): 3,
        (0, 0, 1): 3,
        (0, 1, 0): 4,
        (0, 1, 1): 6,
        (1, 0, 0): 4,
        (1, 0, 1): 6,
        (1, 1, 0): 5,
        (1, 1, 1): 3,
    }
    for parity, bound in expected.items():
        assert minimum_degree2_scc_size_from_parity(*parity) == bound


def test_odd_determinant_opposite_trace_second_parities_are_coprime():
    for trace, second in ((0, 1), (1, 0)):
        data = parity_sieve(trace, second, 1)
        assert data.gcd_mod2 == 1
        assert data.lcm_degree == 6


def test_three_state_degree2_case_requires_reduced_cubics_to_coincide():
    allowed = []
    for trace in (0, 1):
        for second in (0, 1):
            for det in (0, 1):
                p = characteristic_cubic_mod2(trace, second, det)
                q = exterior_characteristic_cubic_mod2(trace, second, det)
                if minimum_degree2_scc_size_from_parity(trace, second, det) == 3:
                    assert p == q
                    allowed.append((trace, second, det))
    assert allowed == [(0, 0, 0), (0, 0, 1), (1, 1, 1)]


def test_polynomial_gcd_examples():
    # t^3+t+1 and t^3+t^2+1 are coprime over F2.
    p = characteristic_cubic_mod2(0, 1, 1)
    q = exterior_characteristic_cubic_mod2(0, 1, 1)
    assert gcd_mod2(p, q) == 1

    # For (T,U,d)=(1,1,0), gcd is t.
    p = characteristic_cubic_mod2(1, 1, 0)
    q = exterior_characteristic_cubic_mod2(1, 1, 0)
    assert gcd_mod2(p, q) == 0b10


def _parikh(word):
    return tuple(word.count(a) for a in range(3))


def _irreducible_balanced(u, v):
    if _parikh(u) != _parikh(v):
        return False
    pu = [0, 0, 0]
    pv = [0, 0, 0]
    for index, (a, b) in enumerate(zip(u, v), start=1):
        pu[a] += 1
        pv[b] += 1
        if index < len(u) and pu == pv:
            return False
    return True


def _k2_wedge(u, v):
    def counts(word):
        seen = [0, 0, 0]
        out = [0] * 9
        for b in word:
            for a in range(3):
                out[3 * a + b] += seen[a]
            seen[b] += 1
        return out

    left = counts(u)
    right = counts(v)
    diff = [x - y for x, y in zip(left, right)]
    return (diff[1], diff[2], diff[5])


def test_swapped_endpoint_k2_halfspace_route_has_exact_length9_counterexample():
    witnesses = (
        ((0, 2, 1, 0, 2, 0, 0, 0, 1), (1, 0, 0, 0, 0, 2, 1, 2, 0)),
        ((0, 1, 0, 1, 1, 2, 0, 2, 1), (1, 2, 0, 0, 2, 1, 1, 1, 0)),
        ((0, 1, 1, 1, 0, 0, 0, 2, 1), (1, 2, 0, 0, 0, 1, 1, 1, 0)),
        ((0, 2, 2, 2, 1, 1, 0, 0, 1), (1, 0, 0, 1, 1, 2, 2, 2, 0)),
    )
    expected = ((2, -5, -2), (2, 3, 4), (-2, 4, 2), (1, -3, -9))
    coefficients = (50, 8, 61, 6)

    vectors = []
    for (u, v), q in zip(witnesses, expected):
        assert u[0] == 0 and v[0] == 1 and u[-1] == 1 and v[-1] == 0
        assert _irreducible_balanced(u, v)
        assert _k2_wedge(u, v) == q
        vectors.append(q)

    assert tuple(
        sum(coefficients[k] * vectors[k][coordinate] for k in range(4))
        for coordinate in range(3)
    ) == (0, 0, 0)
