"""Regression tests for psc.param_poly, the algebra shared by the symbolic line
and cone engines.

Every identity is checked through evaluation at a grid of integer parameter
points, so it tests the polynomials, not their representation; the keys are
checked to be canonical, since both engines intern vertices and memoize signs
by them.
"""

from std.testing import assert_equal, assert_false, assert_true
from finite_exact.rat_q import Q
from finite_linear_algebra.qpoly import evaluate, remainder
from finite_linear_algebra.scalar import q_int
from mojo_smoke.claims import require_contract
from psc.param_poly import (
    QX,
    TPoly,
    qx_add,
    qx_affine,
    qx_affine2,
    qx_at,
    qx_const,
    qx_const_term,
    qx_deg,
    qx_is_const,
    qx_key,
    qx_mul,
    qx_neg,
    qx_of,
    qx_scale,
    qx_shift,
    qx_sub,
    tp_at_t,
    tp_at_q,
    tp_const,
    tp_homog_at,
    tp_key,
    tp_mod_monic,
    tp_mul,
    tp_norm,
    tp_prem,
    tp_sub,
    tp_t,
)


def _samples() -> List[QX]:
    """`3 - 2a + b`, `a b - 1`, `(1 + a)^2`, `5`, `0`."""
    var a1 = qx_affine(1, 1)
    return [
        qx_affine2(3, -2, 1),
        qx_sub(qx_mul(qx_affine(0, 1), qx_affine2(0, 0, 1)), qx_const(1)),
        qx_mul(a1, a1),
        qx_const(5),
        QX(),
    ]


def _grid() -> List[Tuple[Int, Int]]:
    var out = List[Tuple[Int, Int]]()
    for a in range(-2, 4):
        for b in range(-1, 3):
            out.append((a, b))
    return out^


def _direct_at(p: QX, a: Int, b: Int) -> Q:
    """Independent monomial sum, rather than the production Horner evaluator."""
    var total = Q.zero()
    var bp = Q.one()
    for j in range(len(p)):
        var ap = Q.one()
        for i in range(len(p[j])):
            total = total.add(p[j][i].mul(ap).mul(bp))
            ap = ap.mul(q_int(a))
        bp = bp.mul(q_int(b))
    return total^


def _concrete_coefficients(p: TPoly, a: Int, b: Int) -> List[Q]:
    var out = List[Q]()
    for k in range(len(p)):
        out.append(_direct_at(p[k], a, b))
    return out^


def test_sparse_rational_coefficients_and_asymmetric_axes() raises:
    # Empty interior row, unequal degrees and fractional coefficients.
    var p: QX = [[Q(1, 2), Q(-7, 3), Q.zero(), Q(5, 4)], [], [Q(11, 6), Q(-2, 5)], []]
    for pt in _grid():
        var a = pt[0]
        var b = pt[1]
        assert_true(qx_at(p, a, b).eq(_direct_at(p, a, b)))
        assert_true(qx_at(qx_shift(p, -3, 5), a, b).eq(_direct_at(p, a - 3, b + 5)))
        assert_true(qx_at(qx_scale(p, Q(-2, 7)), a, b).eq(_direct_at(p, a, b).mul(Q(-2, 7))))
    # The cone's old 5 + 7 s1 + 11 s2 at (2, 3), read as (a, b) = (3, 2).
    var cone_affine = qx_affine2(5, 11, 7)
    assert_true(qx_at(cone_affine, 3, 2).eq(q_int(52)))
    assert_false(qx_at(cone_affine, 2, 3).eq(q_int(52)))
    assert_equal(qx_key(qx_of(Q(2, 4))), qx_key(qx_of(Q(1, 2))))
    assert_equal(qx_key([[Q.one(), Q.zero()], [], [Q.zero()]]), qx_key(qx_const(1)))


def test_ring_operations_commute_with_evaluation() raises:
    var ps = _samples()
    for i in range(len(ps)):
        for j in range(len(ps)):
            for pt in _grid():
                var x = qx_at(ps[i], pt[0], pt[1])
                var y = qx_at(ps[j], pt[0], pt[1])
                assert_true(qx_at(qx_add(ps[i], ps[j]), pt[0], pt[1]).eq(x.add(y)))
                assert_true(qx_at(qx_sub(ps[i], ps[j]), pt[0], pt[1]).eq(x.sub(y)))
                assert_true(qx_at(qx_mul(ps[i], ps[j]), pt[0], pt[1]).eq(x.mul(y)))


def test_affine_and_shift_follow_the_coordinates() raises:
    """`qx_affine2(c0, ca, cb) = c0 + ca a + cb b`, and `qx_shift` translates
    `(a, b)`. The cone engine reads `s1 = b`, `s2 = a` through exactly these."""
    var ps = _samples()
    for pt in _grid():
        var a = pt[0]
        var b = pt[1]
        assert_true(qx_at(qx_affine2(7, -3, 2), a, b).eq(q_int(7 - 3 * a + 2 * b)))
        for i in range(len(ps)):
            assert_true(qx_at(qx_shift(ps[i], 4, -3), a, b).eq(qx_at(ps[i], a + 4, b - 3)))


def test_keys_are_canonical() raises:
    var a = qx_affine(0, 1)
    var b = qx_affine2(0, 0, 1)
    var s = qx_add(a, b)
    var expanded = qx_add(qx_add(qx_mul(a, a), qx_mul(qx_const(2), qx_mul(a, b))), qx_mul(b, b))
    assert_equal(qx_key(qx_mul(s, s)), qx_key(expanded))
    assert_equal(qx_key(qx_sub(expanded, expanded)), qx_key(QX()))
    assert_equal(qx_key(qx_neg(qx_neg(expanded))), qx_key(expanded))
    var padded: TPoly = [expanded.copy(), QX(), qx_const(0)]
    assert_equal(tp_key(padded), tp_key(tp_const(expanded)))
    assert_equal(tp_key([QX(), qx_const(0)]), tp_key(TPoly()))


def test_degree_and_constants() raises:
    var ps = _samples()
    assert_equal(qx_deg(ps[0]), 1)
    assert_equal(qx_deg(ps[1]), 2)
    assert_equal(qx_deg(ps[2]), 2)
    assert_equal(qx_deg(ps[3]), 0)
    assert_equal(qx_deg(ps[4]), -1)
    assert_true(qx_const_term(ps[1]).eq(q_int(-1)))
    assert_true(qx_is_const(ps[3]) and qx_is_const(ps[4]))
    assert_false(qx_is_const(ps[0]))


def _cubic() -> TPoly:
    """`t^3 - (a + 1) t^2 - b t - 2`, monic in `t`."""
    return tp_norm([qx_const(-2), qx_affine2(0, 0, -1), qx_affine(-1, -1), qx_const(1)])


def test_reduction_modulo_a_monic_cubic() raises:
    var chi = _cubic()
    var t = tp_t()
    var t5 = tp_mul(tp_mul(tp_mul(t, t), tp_mul(t, t)), t)
    var r = tp_mod_monic(t5, chi)
    assert_true(len(r) <= 3)
    # t^5 - r is a multiple of chi: it reduces to zero.
    assert_equal(len(tp_mod_monic(tp_sub(t5, r), chi)), 0)
    var raised = False
    try:
        _ = tp_mod_monic(t5, tp_norm([qx_const(1), qx_affine(2, 1)]))
    except:
        raised = True
    assert_true(raised)
    # Independent Euclidean division after specialization, including axes
    # where a parameter coefficient vanishes. This does not call the reducer
    # again to establish its own correctness.
    for pt in _grid():
        var expected = remainder(_concrete_coefficients(t5, pt[0], pt[1]), _concrete_coefficients(chi, pt[0], pt[1]))
        var actual = tp_at_q(r, pt[0], pt[1])
        assert_equal(len(actual), len(expected))
        for k in range(len(expected)):
            assert_true(qx_at(actual[k], 0, 0).eq(expected[k]))
    assert_equal(len(tp_mod_monic(t5, tp_const(qx_const(1)))), 0)
    raised = False
    try:
        _ = tp_mod_monic(t5, TPoly())
    except:
        raised = True
    assert_true(raised)


def test_pseudo_remainder_even_scaling_with_negative_leading_coefficient() raises:
    var lead = qx_affine2(-5, 1, 2)
    var num = qx_affine2(3, -2, 1)
    var t = tp_t()
    var t3 = tp_mul(tp_mul(t, t), t)
    var divisor = tp_norm([qx_neg(num), lead.copy()])
    var r = tp_prem(t3, divisor)
    assert_equal(len(r), 1)
    for pt in _grid():
        var l = _direct_at(lead, pt[0], pt[1])
        var n = _direct_at(num, pt[0], pt[1])
        # Three division steps plus the parity correction: lc^4 (num/lc)^3.
        assert_true(qx_at(r[0], pt[0], pt[1]).eq(l.mul(n).mul(n).mul(n)))


def test_homogenized_value_is_den_power_times_value() raises:
    """`den^d p(num / den)` at integer points equals the rational evaluation."""
    var p = _cubic()
    var num = qx_affine2(1, 2, 0)  # 1 + 2a
    var den = qx_affine2(1, 0, 1)  # 1 + b
    var h = tp_homog_at(p, num, den, 3)
    for pt in _grid():
        var a = pt[0]
        var b = pt[1]
        if b == -1:
            continue
        var x = Q(Int64(1 + 2 * a), Int64(1 + b))
        var value = evaluate(_concrete_coefficients(p, a, b), x)
        var d3 = q_int((1 + b) * (1 + b) * (1 + b))
        assert_true(qx_at(h, a, b).eq(value.mul(d3)))
    assert_equal(qx_key(tp_homog_at(tp_const(qx_const(4)), num, den, 0)), qx_key(qx_const(4)))
    # Homogeneous substitution is defined at den = 0; no rational division is used.
    assert_true(qx_at(h, 2, -1).eq(q_int(125)))
    var negative_den = qx_affine2(-3, 0, 1)
    for d in [3, 4, 5]:
        var hd = tp_homog_at(p, num, negative_den, d)
        for pt in _grid():
            var n = _direct_at(num, pt[0], pt[1])
            var dn = _direct_at(negative_den, pt[0], pt[1])
            var dp = Q.one()
            for _ in range(d):
                dp = dp.mul(dn)
            var expected = evaluate(_concrete_coefficients(p, pt[0], pt[1]), n.div(dn)).mul(dp)
            assert_true(qx_at(hd, pt[0], pt[1]).eq(expected))


def main() raises:
    test_ring_operations_commute_with_evaluation()
    print("[PASS] test_ring_operations_commute_with_evaluation")
    test_affine_and_shift_follow_the_coordinates()
    print("[PASS] test_affine_and_shift_follow_the_coordinates")
    test_keys_are_canonical()
    print("[PASS] test_keys_are_canonical")
    test_sparse_rational_coefficients_and_asymmetric_axes()
    print("[PASS] test_sparse_rational_coefficients_and_asymmetric_axes")
    test_degree_and_constants()
    print("[PASS] test_degree_and_constants")
    test_reduction_modulo_a_monic_cubic()
    print("[PASS] test_reduction_modulo_a_monic_cubic")
    test_pseudo_remainder_even_scaling_with_negative_leading_coefficient()
    print("[PASS] test_pseudo_remainder_even_scaling_with_negative_leading_coefficient")
    test_homogenized_value_is_den_power_times_value()
    print("[PASS] test_homogenized_value_is_den_power_times_value")
    require_contract("Shared algebra independent oracle: monomial-sum evaluation with sparse rational coefficients and unequal axes, the cone (s1, s2) = (2, 3) maps to (a, b) = (3, 2); padded QX and TPoly keys are canonical; specialized monic remainders equal vendored Euclidean division, zero divisors refuse; pseudo-remainders use an even leading-coefficient power, including negative leading coefficients; homogeneous substitution agrees with independent rational evaluation for both denominator signs and retains its value at a zero denominator")
    require_contract("Parameter polynomials (psc.param_poly, shared by the symbolic line and cone engines): sum, difference and product commute with evaluation on an integer grid; qx_affine2 and qx_shift follow the (a, b) coordinates; equal polynomials have equal keys; total degree and constant term; reduction modulo a monic cubic leaves a multiple of it and refuses a non-monic modulus; den^d p(num / den) matches rational evaluation")
