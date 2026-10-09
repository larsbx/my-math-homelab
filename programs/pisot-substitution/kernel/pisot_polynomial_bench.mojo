"""Before/after exact kernel benchmark; run with -I . -I tests."""
from std.time import perf_counter_ns
from std.testing import assert_true
from finite_exact.rat_q import Q
from psc.exact import q_int, q_poly
from psc.pisot import poly_eval, poly_rem
from polynomial_reference import poly_eval as reference_eval, poly_rem as reference_rem


def main() raises:
    var coefficients: List[Int] = [-1, -1, -2, 1]
    var p = q_poly(coefficients)
    var a: List[Int] = [3, 0, 2, 0, 2, 0, 2]
    var b: List[Int] = [0, 0, 2]
    var dividend = q_poly(a)
    var divisor = q_poly(b)
    var x = q_int(2).div(q_int(3))
    for trial in range(5):
        var sums = List[Q]()
        for path in range(2):
            var baseline = (path + trial) % 2 == 0
            var checksum = Q.zero()
            var start = perf_counter_ns()
            for _ in range(18000):
                var value = Q.zero()
                if baseline:
                    value = reference_eval(p, x)
                else:
                    value = poly_eval(p, x)
                checksum = checksum.add(value)
            var eval_ns = perf_counter_ns() - start
            start = perf_counter_ns()
            for _ in range(2000):
                var r = List[Q]()
                if baseline:
                    r = reference_rem(dividend, divisor)
                else:
                    r = poly_rem(dividend, divisor)
                checksum = checksum.add(r[0])
            var rem_ns = perf_counter_ns() - start
            print("trial", trial, "baseline", baseline, "eval_ns", eval_ns, "rem_ns", rem_ns)
            sums.append(checksum^)
        assert_true(sums[0].eq(sums[1]))
    print("All exact checksums agree; evaluation calls/path: 18000; remainder calls/path: 2000")
