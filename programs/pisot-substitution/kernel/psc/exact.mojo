"""PSC-side conventions over the vendored `finite_exact` package.

`finite_exact` (pinned in `vendored.toml`) reports invalid arithmetic
through a `rejected` flag on every carrier and never raises. The PSC kernels
fail closed, so this module is the single place where a rejected exact value
becomes an `Error` (interval enclosures, where rejection is a legitimate
runtime outcome) or an `abort` (scalar polynomial arithmetic on integer data,
where rejection is an impossible state). Nothing here changes a mathematical result:
a rejected rational or interval is invalid input or an invalid enclosure, not
an unknown sign.

Rational-interval semantics (unchanged from the retired checked layer):

* natural interval extension is the first enclosure layer;
* a strict sign is certified only when the entire interval excludes zero;
* an interval containing zero means *unknown*, never equality or failure;
* callers may delegate unknown cases to an independent exact algebraic oracle.
"""

from std.os import abort

from finite_exact.bigint_z import BIGZ_BASE, BigZ, bigz_divmod, bigz_from_i64
from finite_exact.rat_q import Q, q_abs, q_from_bigz
from finite_linear_algebra.scalar import q_int, q_is_zero, q_vec
from finite_exact.closed_interval import IQ


def q_poly(coeffs: List[Int]) -> List[Q]:
    """Integer coefficient list, low degree first, lifted into Q[x]."""
    return q_vec(coeffs)


def require_q(x: Q, what: StringLiteral) raises -> Q:
    if x.rejected:
        raise Error(String(what) + ": rejected exact rational")
    return x.copy()


def require_iq(x: IQ, what: StringLiteral) raises -> IQ:
    if x.rejected:
        raise Error(String(what) + ": rejected rational interval")
    return x.copy()


def q_sign(x: Q) -> Int:
    """`-1`, `0`, or `1` of an accepted value.

    A rejected operand is an impossible state for the integer-seeded
    polynomial arithmetic that calls this (rule 8 of AGENTS.md: abort, never
    return a value that could be misread as evidence).
    """
    if x.rejected:
        abort("sign of a rejected exact rational")
    return x.num.sign


def q_floor_abs(x: Q) -> Q:
    """`floor(|x|)` as an exact rational (an integer); aborts on a rejected value."""
    var a = q_abs(x)
    if a.rejected:
        abort("floor of a rejected exact rational")
    var division = bigz_divmod(a.num, a.den)
    if division.rejected:
        abort("floor: rejected exact division")
    return q_from_bigz(division.quotient, bigz_from_i64(1))


def midpoint(a: Q, b: Q) raises -> Q:
    return require_q(a.add(b).div(q_int(2)), "midpoint")


def integer_interval(lo: Int, hi: Int) raises -> IQ:
    return require_iq(IQ(q_int(lo), q_int(hi)), "integer interval")


def strict_sign(box: IQ) raises -> Int:
    """`+/-1` only when every value of the box has that sign, else `0`."""
    var s = box.sign()
    if s.rejected:
        raise Error("strict sign of a rejected rational interval")
    return s.code


def contains_zero(box: IQ) raises -> Bool:
    var c = box.contains_zero()
    if c.rejected:
        raise Error("zero containment of a rejected rational interval")
    return c.value


def interval_horner_int(coeffs: List[Int], x: IQ) raises -> IQ:
    """Natural interval extension of an integer polynomial, low degree first."""
    if len(coeffs) == 0:
        return IQ.singleton(Q.zero())
    var acc = IQ.singleton(q_int(coeffs[len(coeffs) - 1]))
    for i in range(len(coeffs) - 2, -1, -1):
        acc = acc.mul(x).add(IQ.singleton(q_int(coeffs[i])))
    return require_iq(acc, "interval Horner")


def eval_int_poly_at_q(coeffs: List[Int], x: Q) raises -> Q:
    """Exact Horner evaluation at one rational value."""
    if len(coeffs) == 0:
        return Q.zero()
    var acc = q_int(coeffs[len(coeffs) - 1])
    for i in range(len(coeffs) - 2, -1, -1):
        acc = acc.mul(x).add(q_int(coeffs[i]))
    return require_q(acc, "exact Horner")


def eval_q_poly_at_q(coeffs: List[Q], x: Q) raises -> Q:
    """Exact Horner evaluation of a rational polynomial, low degree first."""
    var acc = Q.zero()
    for i in range(len(coeffs) - 1, -1, -1):
        acc = require_q(acc.mul(x).add(coeffs[i]), "exact rational Horner")
    return acc^


def bigz_string(z: BigZ) -> String:
    """Decimal rendering for diagnostics (limbs are base 10^9, little-endian)."""
    if z.is_zero():
        return String("0")
    var out = String("-") if z.sign < 0 else String("")
    var idx = len(z.limbs) - 1
    out += String(z.limbs[idx])
    idx -= 1
    while idx >= 0:
        var digits = String(z.limbs[idx])
        var pad = 9 - digits.byte_length()
        for _ in range(pad):
            out += "0"
        out += digits
        idx -= 1
    return out^


def q_string(x: Q) -> String:
    """`num/den` rendering for diagnostics; never used as a key or encoding."""
    if x.rejected:
        return String("rejected")
    if x.den.limb_count() == 1 and x.den.limb(0) == 1:
        return bigz_string(x.num)
    return bigz_string(x.num) + "/" + bigz_string(x.den)
