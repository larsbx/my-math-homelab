"""Pin exact polynomial kernels against the pre-optimization algorithms."""
from std.testing import assert_equal, assert_true
from finite_exact.rat_q import Q, q_rejected
from psc.exact import q_int, q_poly
from psc.pisot import poly_eval, poly_degree, poly_rem
from mojo_smoke.claims import require_contract
from polynomial_reference import poly_eval as reference_eval, poly_degree as reference_degree, poly_rem as reference_rem


def main() raises:
    # Includes every unrolled length, empty/zero inputs, and longer fallback.
    for n in range(9):
        var p = List[Q]()
        for i in range(n):
            p.append(q_int((i * 7) % 11 - 5).div(q_int(i + 1)))
        for numerator in range(-4, 5):
            var x = q_int(numerator).div(q_int(3))
            assert_true(poly_eval(p, x).eq(reference_eval(p, x)))
        assert_equal(poly_degree(p), reference_degree(p))
        p.append(Q.zero())
        p.append(Q.zero())
        assert_equal(poly_degree(p), reference_degree(p))
    var constant: List[Int] = [7]
    assert_true(poly_eval(q_poly(constant), q_rejected()).rejected)
    var empty = List[Q]()
    assert_true(poly_eval(empty, q_rejected()).eq(Q.zero()))
    var a: List[Int] = [3, 0, 2, 0, 2, 0, 2, 0, 0]
    var b: List[Int] = [0, 0, 2, 0]
    var r = poly_rem(q_poly(a), q_poly(b))
    # Initial degree scan skips 8,7; cancellation descends 6 -> 4 -> 2 -> 0.
    assert_true(r[0].eq(q_int(3)))
    assert_equal(poly_degree(r), 0)
    for degree in range(1, 7):
        var dividend = List[Q]()
        var divisor = List[Q]()
        for i in range(9):
            dividend.append(q_int((i * 3) % 7 - 3).div(q_int(i + 1)))
        for i in range(degree + 1):
            divisor.append(q_int(i + 1).div(q_int(i + 2)))
        var actual = poly_rem(dividend, divisor)
        var expected = reference_rem(dividend, divisor)
        assert_equal(len(actual), len(expected))
        for i in range(len(actual)):
            assert_true(actual[i].eq(expected[i]))
        assert_true(poly_degree(actual) < poly_degree(divisor))
    var zero = List[Q]()
    var short: List[Int] = [1, 2]
    var long: List[Int] = [1, 2, 3, 4]
    var unchanged = poly_rem(q_poly(short), zero)
    assert_equal(len(unchanged), 2)
    assert_true(unchanged[1].eq(q_int(2)))
    assert_equal(poly_degree(poly_rem(q_poly(short), q_poly(long))), 1)
    assert_equal(poly_degree(poly_rem(q_poly(long), q_poly(long))), -1)
    require_contract("Exact polynomial evaluation, degree and remainder equivalence")
