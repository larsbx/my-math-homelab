"""Exact Sturm--Tarski queries at real roots, over unbounded rationals.

Polynomials are `List[Q]`, low degree first.  For a squarefree integer
polynomial `P` and any `Qp`, `tarski_query(P, Qp, a, b)` returns the sum over
the real roots `r` of `P` in `(a, b)` of `sign(Qp(r))` (the Cauchy index of
`P' Qp / P`), computed from the signed-remainder sequence of `(P, P' Qp)`;
`a`, `b` must not be roots of `P`, which holds for rational endpoints and an
irreducible `P`.  With `Qp = 1` it counts the roots; on an isolating interval
it is the sign of `Qp` at that root.  `sign_at_perron` covers the Perron root
only; this module serves the two real contracting conjugates of a totally
real cubic Pisot field.  Every operation is exact; a rejected rational
raises (AGENTS.md rules 8 and 9).

The polynomial arithmetic (normalization, derivative, product, Euclidean
remainder, negation) and the sign-variation count are the vendored
`finite_linear_algebra.qpoly`; what is kept here is what that package does not
provide: the Tarski query of a pair `(P, Qp)`, rather than the Sturm chain of
`P` alone, and isolation of every real root in an interval, rather than of the
largest one.  The sequence is built from `P` itself, not from its squarefree
part, so it is the signed-remainder sequence of `(P, P' Qp)` exactly as
stated above.  Reading a variation difference as a Cauchy index is Tarski's
theorem, imported here as it was before the package was vendored."""

from finite_exact.rat_q import Q
from finite_linear_algebra import qpoly
from psc.exact import midpoint, q_is_zero, require_q


def _require_accepted(p: List[Q], what: StringLiteral) raises:
    """Raise on a rejected coefficient before any vendored call can abort on it.

    Accepted rationals are closed under the ring operations and under division
    by a nonzero value, so once the inputs are accepted every intermediate value
    of the query is too."""
    for i in range(len(p)):
        _ = require_q(p[i], what)


def tarski_query(P: List[Q], Qp: List[Q], a: Q, b: Q) raises -> Int:
    """Sum of `sign(Qp(r))` over the real roots `r` of `P` in `(a, b)`."""
    _require_accepted(P, "Tarski query P")
    _require_accepted(Qp, "Tarski query Qp")
    _ = require_q(a, "Tarski query endpoint")
    _ = require_q(b, "Tarski query endpoint")
    if not a.lt(b):
        raise Error("Tarski query needs a < b")
    var p0 = qpoly.normalize(P)
    if len(p0) < 2:
        raise Error("Tarski query needs a nonconstant P")
    if q_is_zero(qpoly.evaluate(p0, a)) or q_is_zero(qpoly.evaluate(p0, b)):
        raise Error("Tarski query endpoint is a root of P")
    var seq = List[List[Q]]()
    seq.append(p0.copy())
    var f1 = qpoly.mul(qpoly.derivative(p0), Qp)
    if len(f1) == 0:
        return 0
    seq.append(f1^)
    while True:
        # The divisor is the last appended entry, nonzero by construction.
        var r = qpoly.remainder(seq[len(seq) - 2], seq[len(seq) - 1])
        if len(r) == 0:
            break
        seq.append(qpoly.neg(r))
    return qpoly.variation_difference(seq, a, b)


def count_real_roots(P: List[Q], a: Q, b: Q) raises -> Int:
    var one = List[Q]()
    one.append(Q.one())
    return tarski_query(P, one, a, b)


def isolate_real_roots(P: List[Q], a: Q, b: Q, expected: Int) raises -> List[List[Q]]:
    """Isolating rational brackets for the real roots of `P` in `(a, b)`.

    Bisects until each bracket holds one root and raises if the count of
    roots in `(a, b)` is not `expected` (fail closed)."""
    if count_real_roots(P, a, b) != expected:
        raise Error("unexpected number of real roots in the isolation interval")
    var stack = List[List[Q]]()
    var first = List[Q]()
    first.append(a.copy())
    first.append(b.copy())
    stack.append(first^)
    var out = List[List[Q]]()
    while len(stack) > 0:
        var box = stack.pop()
        var n = count_real_roots(P, box[0], box[1])
        if n == 0:
            continue
        if n == 1:
            out.append(box^)
            continue
        var mid = midpoint(box[0], box[1])
        if q_is_zero(qpoly.evaluate(P, mid)):
            raise Error("rational root during isolation")
        var left = List[Q]()
        left.append(box[0].copy())
        left.append(mid.copy())
        var right = List[Q]()
        right.append(mid.copy())
        right.append(box[1].copy())
        stack.append(left^)
        stack.append(right^)
    if len(out) != expected:
        raise Error("root isolation produced the wrong number of brackets")
    return out^


def sign_at_isolated_root(P: List[Q], Qp: List[Q], lo: Q, hi: Q) raises -> Int:
    """Sign of `Qp` at the unique root of `P` in `(lo, hi)`; `0` iff `Qp(r) = 0`."""
    var s = tarski_query(P, Qp, lo, hi)
    if s < -1 or s > 1:
        raise Error("sign query did not isolate one root")
    return s
