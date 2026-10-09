"""Truncated Laurent series over an exact finite field, and local expansions on
y^2 = x^3 + a x + b at every point, including O.

A series is (valuation, coefficients) with coefficients low -> high in the
uniformizer, truncated to a fixed absolute precision.  These give exact orders
of vanishing and leading coefficients, hence exact tame symbols
    (f, g)_P = (-1)^{v(f) v(g)} (f^{v(g)} / g^{v(f)})(P)
for rational functions given as polynomials in x, y.
"""
from __future__ import annotations

from dataclasses import dataclass

from .ec import Curve, Point
from .gf import GF, Poly


@dataclass(frozen=True)
class Laurent:
    """sum_{i} c[i] u^{v + i}, known modulo u^{prec} (absolute precision)."""

    F: GF
    v: int
    c: tuple[Poly, ...]
    prec: int

    @staticmethod
    def of(F: GF, v: int, coeffs: tuple[Poly, ...], prec: int) -> "Laurent":
        return Laurent(F, v, coeffs, prec).normalized()

    def normalized(self) -> "Laurent":
        c, v = list(self.c), self.v
        while c and c[0] == self.F.zero:
            c.pop(0)
            v += 1
        c = c[: max(0, self.prec - v)]
        while c and c[-1] == self.F.zero:  # trailing zeros are implied by coeff(); never store them
            c.pop()
        if not c:
            return Laurent(self.F, self.prec, (), self.prec)  # zero to precision
        return Laurent(self.F, v, tuple(c), self.prec)

    @property
    def is_zero(self) -> bool:
        return not self.c

    @property
    def leading(self) -> Poly:
        if self.is_zero:
            raise ValueError("zero series has no leading coefficient")
        return self.c[0]

    def coeff(self, i: int) -> Poly:
        k = i - self.v
        return self.c[k] if 0 <= k < len(self.c) else self.F.zero

    def _binary(self, other: "Laurent", sign: int) -> "Laurent":
        F, prec = self.F, min(self.prec, other.prec)
        v = min(self.v, other.v)
        n = prec - v
        coeffs = tuple(
            F.add(self.coeff(v + i), F.scale(sign, other.coeff(v + i))) for i in range(n)
        )
        return Laurent.of(F, v, coeffs, prec)

    def __add__(self, other: "Laurent") -> "Laurent":
        return self._binary(other, 1)

    def __sub__(self, other: "Laurent") -> "Laurent":
        return self._binary(other, -1)

    def __mul__(self, other: "Laurent") -> "Laurent":
        F = self.F
        prec = min(self.prec + other.v, other.prec + self.v)  # a zero series has v = prec
        if self.is_zero or other.is_zero:
            return Laurent(F, prec, (), prec)
        v = self.v + other.v
        n = min(prec - v, len(self.c) + len(other.c) - 1)
        out = [F.zero] * max(n, 0)
        for i, x in enumerate(self.c):
            for j, y in enumerate(other.c):
                if i + j < n:
                    out[i + j] = F.add(out[i + j], F.mul(x, y))
        return Laurent.of(F, v, tuple(out), prec)

    def scale(self, k: Poly) -> "Laurent":
        return Laurent.of(self.F, self.v, tuple(self.F.mul(k, x) for x in self.c), self.prec)

    def __pow__(self, n: int) -> "Laurent":
        if n < 0:
            return self.inverse() ** (-n)
        result = Laurent(self.F, 0, (self.F.one,), 10**6)
        base = self
        while n:
            if n & 1:
                result = result * base
            base, n = base * base, n >> 1
        return result

    def inverse(self) -> "Laurent":
        """1/self by the recursion for a unit power series times u^{-v}."""
        F = self.F
        if self.is_zero:
            raise ZeroDivisionError
        n = self.prec - self.v  # relative precision
        lead_inv = F.inv(self.c[0])
        inv = [lead_inv]
        for k in range(1, n):
            s = F.zero
            for i in range(1, k + 1):
                if i < len(self.c):
                    s = F.add(s, F.mul(self.c[i], inv[k - i]))
            inv.append(F.neg(F.mul(lead_inv, s)))
        return Laurent.of(F, -self.v, tuple(inv), n - self.v)


def constant(F: GF, k: Poly, prec: int) -> Laurent:
    return Laurent.of(F, 0, (k,), prec)


def uniformizer(F: GF, prec: int) -> Laurent:
    return Laurent.of(F, 1, (F.one,), prec)


@dataclass(frozen=True)
class LocalExpansion:
    """x and y as Laurent series in a uniformizer u at P (u = x - x_P if y_P != 0,
    u = y at a 2-torsion point, u = -x/y at O)."""

    P: Point
    x: Laurent
    y: Laurent

    def evaluate(self, f: "XYPoly") -> Laurent:
        F = self.x.F
        total = Laurent(F, 10**6, (), 10**6)
        for (i, j), c in f.items():
            total = total + (self.x**i * self.y**j).scale(c)
        return total


XYPoly = dict[tuple[int, int], Poly]  # {(i, j): c}  <->  sum c x^i y^j, with j <= 1 preferred


def local_expansion(E: Curve, P: Point, prec: int = 12) -> LocalExpansion:
    F = E.F
    u = uniformizer(F, prec)
    if P is None:
        # w = -1/y, t = -x/y:  w = t^3 + a t w^2 + b w^3   (Silverman IV.1), iterate t-adically.
        # Extra working precision absorbs the loss in 1/w (valuation -3) so x, y are exact mod t^prec.
        t = uniformizer(F, prec + 6)
        w = t**3
        for _ in range(prec // 2 + 1):  # each step gains >= 2 in t-adic precision
            w = t**3 + (t * w * w).scale(E.a) + (w**3).scale(E.b)
        x = t * w.inverse()
        y = w.inverse().scale(F.neg(F.one))
        return LocalExpansion(None, x, y)
    xP, yP = P
    if yP != F.zero:
        x = constant(F, xP, prec) + u
        rhs = x**3 + x.scale(E.a) + constant(F, E.b, prec)
        y = constant(F, yP, prec)
        half = F.inv(F.from_int(2))
        for _ in range(prec.bit_length() + 1):  # Hensel: y <- (y + rhs/y)/2, quadratic convergence
            y = (y + rhs * y.inverse()).scale(half)
        return LocalExpansion(P, x, y)
    # 2-torsion point: uniformizer y; solve R(xP + w) = u^2 for w by Newton.
    y = u
    w = Laurent(F, 10**6, (), prec)
    for _ in range(prec.bit_length() + 1):  # Newton, quadratic convergence
        xw = constant(F, xP, prec) + w
        R = xw**3 + xw.scale(E.a) + constant(F, E.b, prec)
        Rp = (xw * xw).scale(F.from_int(3)) + constant(F, E.a, prec)
        w = w - (R - y * y) * Rp.inverse()
    return LocalExpansion(P, constant(F, xP, prec) + w, y)


def tame_symbol(E: Curve, f: XYPoly, g: XYPoly, P: Point, prec: int = 12) -> Poly:
    """(f, g)_P = (-1)^{v(f) v(g)} lc(f)^{v(g)} / lc(g)^{v(f)} with lc the leading coefficient
    in the uniformizer at P.  Exact; raises if the precision cannot certify the valuation."""
    F = E.F
    loc = local_expansion(E, P, prec)
    sf, sg = loc.evaluate(f), loc.evaluate(g)
    if sf.is_zero or sg.is_zero:
        raise ValueError("precision too low to determine a valuation")
    vf, vg = sf.v, sg.v
    sign = F.neg(F.one) if (vf * vg) % 2 else F.one
    return F.mul(sign, F.div(F.pow(sf.leading, vg), F.pow(sg.leading, vf)))


def valuation(E: Curve, f: XYPoly, P: Point, prec: int = 12) -> int:
    s = local_expansion(E, P, prec).evaluate(f)
    if s.is_zero:
        raise ValueError("precision too low")
    return s.v
