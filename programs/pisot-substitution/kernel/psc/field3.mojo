"""Exact arithmetic in the cubic Perron field `Q(beta) = Q[x]/(chi)`.

One home for the field operations the overlap modules share: `Q`-coefficient
elements (`List[Q]`, low degree first) with addition, scaling,
multiplication modulo `chi` and the norm; the discriminant and a Cauchy bound
of `chi`. Moved here from `psc.overlap_contracting` without changing any
definition.
"""

from finite_exact.rat_q import Q
from finite_exact.checked_int import checked_add as _checked_add, checked_mul as _checked_mul, checked_sub as _checked_sub
from psc.exact import q_poly, q_sign, require_q
from psc.perron_field3 import CubicElt, PerronField3


# ---- Q[x]/(chi): elements are `List[Q]`, low degree first, trimmed ----------


def lift(x: CubicElt) -> List[Q]:
    var v: List[Int] = [x.a0, x.a1, x.a2]
    return q_poly(v)


def q_coef(x: List[Q], i: Int) -> Q:
    if i < len(x):
        return x[i].copy()
    return Q.zero()


def qf_add(x: List[Q], y: List[Q]) raises -> List[Q]:
    var n = len(x) if len(x) > len(y) else len(y)
    var out = List[Q]()
    for i in range(n):
        out.append(require_q(q_coef(x, i).add(q_coef(y, i)), "field add"))
    return out^


def qf_neg(x: List[Q]) -> List[Q]:
    var out = List[Q]()
    for i in range(len(x)):
        out.append(x[i].neg())
    return out^


def qf_sub(x: List[Q], y: List[Q]) raises -> List[Q]:
    return qf_add(x, qf_neg(y))


def qf_scale(x: List[Q], k: Q) raises -> List[Q]:
    var out = List[Q]()
    for i in range(len(x)):
        out.append(require_q(x[i].mul(k), "field scale"))
    return out^


def qf_mul(chi: List[Q], x: List[Q], y: List[Q]) raises -> List[Q]:
    var prod = List[Q]()
    if len(x) == 0 or len(y) == 0:
        return prod^
    for _ in range(len(x) + len(y) - 1):
        prod.append(Q.zero())
    for i in range(len(x)):
        for j in range(len(y)):
            prod[i + j] = require_q(prod[i + j].add(x[i].mul(y[j])), "field mul")
    # reduce modulo the monic cubic chi
    var r = prod.copy()
    for d in range(len(r) - 1, 2, -1):
        var k = r[d].copy()
        if q_sign(k) == 0:
            continue
        for i in range(4):
            r[d - 3 + i] = require_q(r[d - 3 + i].sub(k.mul(chi[i])), "field reduce")
    var out = List[Q]()
    for i in range(3):
        out.append(q_coef(r, i))
    return out^


def qf_norm(chi: List[Q], x: List[Q]) raises -> Q:
    """N(x) = det of multiplication by x on the basis 1, beta, beta^2."""
    var beta = q_poly([0, 1])
    var c0 = x.copy()
    var c1 = qf_mul(chi, c0, beta)
    var c2 = qf_mul(chi, c1, beta)
    var m00 = q_coef(c0, 0)
    var m01 = q_coef(c1, 0)
    var m02 = q_coef(c2, 0)
    var m10 = q_coef(c0, 1)
    var m11 = q_coef(c1, 1)
    var m12 = q_coef(c2, 1)
    var m20 = q_coef(c0, 2)
    var m21 = q_coef(c1, 2)
    var m22 = q_coef(c2, 2)
    var t0 = m00.mul(m11.mul(m22).sub(m12.mul(m21)))
    var t1 = m01.mul(m10.mul(m22).sub(m12.mul(m20)))
    var t2 = m02.mul(m10.mul(m21).sub(m11.mul(m20)))
    return require_q(t0.sub(t1).add(t2), "field norm")


def field_norm(field: PerronField3, x: CubicElt) raises -> Q:
    return qf_norm(q_poly(field.charpoly()), lift(x))


def discriminant(field: PerronField3) raises -> Int:
    """Discriminant of x^3 + chi2 x^2 + chi1 x + chi0; negative iff a complex pair."""
    var a = field.chi2
    var b = field.chi1
    var c = field.chi0
    var t1 = _checked_mul(18, _checked_mul(a, _checked_mul(b, c)))
    var t2 = _checked_mul(4, _checked_mul(a, _checked_mul(a, _checked_mul(a, c))))
    var t3 = _checked_mul(_checked_mul(a, a), _checked_mul(b, b))
    var t4 = _checked_mul(4, _checked_mul(b, _checked_mul(b, b)))
    var t5 = _checked_mul(27, _checked_mul(c, c))
    return _checked_sub(_checked_sub(_checked_add(_checked_sub(t1, t2), t3), t4), t5)


def cauchy_bound(field: PerronField3) raises -> Int:
    var m = 0
    for v in [field.chi0, field.chi1, field.chi2]:
        var a = _checked_sub(0, v) if v < 0 else v
        if a > m:
            m = a
    return _checked_add(m, 1)
