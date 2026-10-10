"""Exact polynomials in two integer parameters, and polynomials in `t` over them.

The shared algebra of the symbolic engines: `psc.symbolic_line` (lines and
wedges, parameters `(a, b)`) and `psc.symbolic_cone` (cones, parameters
`(s1, s2)`, read here as `s1 = b`, `s2 = a`). A `QX` is a polynomial in `a, b`
over `Q`: row `j` is the coefficient of `b^j`, an ascending polynomial in `a`
handled by the vendored univariate `qpoly`. A one-parameter family never
involves `b`, and then every operation reduces to `qpoly` on row 0. A `TPoly`
is a polynomial in `t` with `QX` coefficients, ascending; three `QX`
coordinates are a weight vector.

Polynomial arithmetic returns normalized values (no trailing zero rows or
terms), and `qx_key` / `tp_key` ignore zero padding in their inputs. Nothing
here decides a sign: that is the engines' business.
"""

from finite_exact.rat_q import Q
from finite_linear_algebra.qpoly import add, evaluate, mul, normalize, scale
from finite_linear_algebra.scalar import q_int
from psc.exact import q_string

comptime QX = List[List[Q]]  # a polynomial in the parameters (a, b): row j is the coefficient of b^j, a polynomial in a
comptime TPoly = List[QX]  # a polynomial in t whose coefficients are parameter polynomials

# ---------------------------------------------------------------------------
# Polynomials in the parameters.
# ---------------------------------------------------------------------------

def qx_norm(p: QX) -> QX:
    var width = len(p)
    while width > 0 and len(normalize(p[width - 1])) == 0:
        width -= 1
    var out = QX()
    for j in range(width):
        out.append(normalize(p[j]))
    return out^


def qx_row(p: QX, j: Int) -> List[Q]:
    return p[j].copy() if j < len(p) else List[Q]()


def qx_const(c: Int) -> QX:
    return qx_norm([[q_int(c)]])


def qx_of(c: Q) -> QX:
    return qx_norm([[c.copy()]])


def qx_affine(c0: Int, c1: Int) -> QX:
    """`c0 + c1 a`."""
    return qx_norm([[q_int(c0), q_int(c1)]])


def qx_affine2(c0: Int, ca: Int, cb: Int) -> QX:
    """`c0 + ca a + cb b`."""
    return qx_norm([[q_int(c0), q_int(ca)], [q_int(cb)]])


def qx_add(x: QX, y: QX) -> QX:
    var out = QX()
    for j in range(max(len(x), len(y))):
        out.append(add(qx_row(x, j), qx_row(y, j)))
    return qx_norm(out)


def qx_scale(p: QX, c: Q) -> QX:
    var out = QX()
    for j in range(len(p)):
        out.append(scale(p[j], c))
    return qx_norm(out)


def qx_neg(p: QX) -> QX:
    return qx_scale(p, q_int(-1))


def qx_sub(x: QX, y: QX) -> QX:
    return qx_add(x, qx_neg(y))


def qx_mul(x: QX, y: QX) -> QX:
    var u = qx_norm(x)
    var v = qx_norm(y)
    if len(u) == 0 or len(v) == 0:
        return QX()
    var out = QX()
    for _ in range(len(u) + len(v) - 1):
        out.append(List[Q]())
    for i in range(len(u)):
        for j in range(len(v)):
            out[i + j] = add(out[i + j], mul(u[i], v[j]))
    return qx_norm(out)


def qx_is_zero(p: QX) -> Bool:
    return len(qx_norm(p)) == 0


def qx_is_const(p: QX) -> Bool:
    var f = qx_norm(p)
    return len(f) == 0 or (len(f) == 1 and len(f[0]) <= 1)


def qx_const_term(p: QX) -> Q:
    var f = qx_norm(p)
    return f[0][0].copy() if len(f) > 0 and len(f[0]) > 0 else Q.zero()


def qx_at(p: QX, a: Int, b: Int = 0) -> Q:
    var total = Q.zero()
    for index in range(len(p)):
        total = total.mul(q_int(b)).add(evaluate(p[len(p) - 1 - index], q_int(a)))
    return total^


def qx_shift(p: QX, da: Int, db: Int) -> QX:
    """`p(a + da, b + db)`."""
    var sa = qx_affine(da, 1)
    var sb = qx_affine2(db, 0, 1)
    var total = QX()
    for index in range(len(p)):
        var row = p[len(p) - 1 - index].copy()
        var r = QX()
        for k in range(len(row)):
            r = qx_add(qx_mul(r, sa), qx_of(row[len(row) - 1 - k]))
        total = qx_add(qx_mul(total, sb), r)
    return total^


def qx_key(p: QX) -> String:
    var f = qx_norm(p)
    var out = String("")
    for j in range(len(f)):
        out += "{"
        for i in range(len(f[j])):
            out += q_string(f[j][i]) + ","
        out += "}"
    return out^

def qx_deg(p: QX) -> Int:
    """Total degree; -1 for the zero polynomial."""
    var f = qx_norm(p)
    var d = -1
    for j in range(len(f)):
        if len(f[j]) > 0 and j + len(f[j]) - 1 > d:
            d = j + len(f[j]) - 1
    return d

# ---------------------------------------------------------------------------
# Polynomials in t over the parameter polynomials.
# ---------------------------------------------------------------------------

def tp_norm(p: TPoly) -> TPoly:
    var width = len(p)
    while width > 0 and qx_is_zero(p[width - 1]):
        width -= 1
    var out = TPoly()
    for i in range(width):
        out.append(qx_norm(p[i]))
    return out^


def tp_deg(p: TPoly) -> Int:
    return len(tp_norm(p)) - 1


def tp_coeff(p: TPoly, k: Int) -> QX:
    if k < len(p):
        return p[k].copy()
    return QX()


def tp_add(a: TPoly, b: TPoly) -> TPoly:
    var width = len(a) if len(a) > len(b) else len(b)
    var out = TPoly()
    for k in range(width):
        out.append(qx_add(tp_coeff(a, k), tp_coeff(b, k)))
    return tp_norm(out)


def tp_scale(p: TPoly, c: QX) -> TPoly:
    var out = TPoly()
    for k in range(len(p)):
        out.append(qx_mul(p[k], c))
    return tp_norm(out)


def tp_neg(p: TPoly) -> TPoly:
    return tp_scale(p, qx_const(-1))


def tp_sub(a: TPoly, b: TPoly) -> TPoly:
    return tp_add(a, tp_neg(b))


def tp_mul(a: TPoly, b: TPoly) -> TPoly:
    var x = tp_norm(a)
    var y = tp_norm(b)
    if len(x) == 0 or len(y) == 0:
        return TPoly()
    var out = TPoly()
    for _ in range(len(x) + len(y) - 1):
        out.append(QX())
    for i in range(len(x)):
        for j in range(len(y)):
            out[i + j] = qx_add(out[i + j], qx_mul(x[i], y[j]))
    return tp_norm(out)


def tp_shift(p: TPoly, k: Int) -> TPoly:
    """`t^k p`."""
    var out = TPoly()
    for _ in range(k):
        out.append(QX())
    for i in range(len(p)):
        out.append(p[i].copy())
    return tp_norm(out)


def tp_const(c: QX) -> TPoly:
    return tp_norm([c.copy()])


def tp_has_b(p: TPoly) -> Bool:
    for k in range(len(p)):
        if len(qx_norm(p[k])) > 1:
            return True
    return False


def tp_t() -> TPoly:
    return tp_norm([QX(), qx_const(1)])


def tp_key(p: TPoly) -> String:
    var f = tp_norm(p)
    var out = String("")
    for k in range(len(f)):
        out += "[" + qx_key(f[k]) + "]"
    return out^


def tp_deriv(p: TPoly) -> TPoly:
    var out = TPoly()
    for k in range(1, len(p)):
        out.append(qx_scale(p[k], q_int(k)))
    return tp_norm(out)


def tp_at_t(p: TPoly, x: Q) -> QX:
    """Substitute a rational for `t`: a parameter polynomial."""
    var total = QX()
    for index in range(len(p)):
        total = qx_add(qx_scale(total, x), p[len(p) - 1 - index])
    return total^


def tp_at_q(p: TPoly, a: Int, b: Int = 0) -> TPoly:
    """Substitute integers for the parameters: a polynomial in `t` with constant coefficients."""
    var out = TPoly()
    for k in range(len(p)):
        out.append(qx_of(qx_at(p[k], a, b)))
    return tp_norm(out)


def tp_prem(a: TPoly, b: TPoly) raises -> TPoly:
    """`lc(b)^e a mod b` with `e` even, so the result has the sign of `a` at
    every root of `b` where `lc(b) != 0`."""
    var bb = tp_norm(b)
    var db = len(bb) - 1
    if db < 0:
        raise Error("pseudo-division by the zero polynomial")
    var lead = bb[db].copy()
    var r = tp_norm(a)
    var steps = 0
    while len(r) - 1 >= db and len(r) > 0:
        var dr = len(r) - 1
        var top = r[dr].copy()
        r = tp_sub(tp_scale(r, lead), tp_scale(tp_shift(bb, dr - db), top))
        steps += 1
    if steps % 2 == 1:
        r = tp_scale(r, lead)
    return r^

def tp_mod_monic(a: TPoly, b: TPoly) raises -> TPoly:
    """`a mod b` for `b` monic in `t`."""
    var bb = tp_norm(b)
    var db = len(bb) - 1
    if db < 0 or qx_deg(qx_sub(bb[db], qx_const(1))) >= 0:
        raise Error("reduction modulo a polynomial that is not monic")
    var r = tp_norm(a)
    while len(r) - 1 >= db and len(r) > 0:
        var dr = len(r) - 1
        r = tp_sub(r, tp_scale(tp_shift(bb, dr - db), r[dr]))
    return r^


def tp_homog_at(p: TPoly, num: QX, den: QX, d: Int) -> QX:
    """`den^d p(num / den)` for `deg p <= d`: the sign of `p(num / den)` when `den > 0`."""
    var total = QX()
    var dpow = qx_const(1)
    var parts = List[QX]()  # parts[k] = num^k
    parts.append(qx_const(1))
    for k in range(1, len(p)):
        parts.append(qx_mul(parts[k - 1], num))
    for j in range(d + 1):
        var k = d - j  # term p_k num^k den^(d - k), accumulated from k = d down
        if k < len(p):
            total = qx_add(total, qx_mul(qx_mul(p[k], parts[k]), dpow))
        dpow = qx_mul(dpow, den)
    return total^

# ---------------------------------------------------------------------------
# Weight vectors: three parameter-polynomial coordinates.
# ---------------------------------------------------------------------------

def w_add(a: List[QX], b: List[QX]) -> List[QX]:
    var out = List[QX]()
    for i in range(3):
        out.append(qx_add(a[i], b[i]))
    return out^


def w_sub(a: List[QX], b: List[QX]) -> List[QX]:
    var out = List[QX]()
    for i in range(3):
        out.append(qx_sub(a[i], b[i]))
    return out^


def w_unit(i: Int, c: QX) -> List[QX]:
    var out = List[QX]()
    for k in range(3):
        out.append(c.copy() if k == i else QX())
    return out^


def w_zero() -> List[QX]:
    return w_unit(0, QX())
