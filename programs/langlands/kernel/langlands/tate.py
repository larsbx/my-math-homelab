"""Tate's algorithm over an exact discrete valuation ring (Silverman, Advanced Topics IV.9.4).

Works in every residue characteristic: coordinate changes use lifts of residue-field elements,
root finding over the (finite) residue field is exhaustive, and repeated roots are detected by
discriminants (valid over any field).  Two rings are provided: Z localised at p (elements are
Fractions) and F_p[t] localised at a monic irreducible (elements are polynomials), the latter
also serving the place oo of F_p(t) through the s = 1/t model.

Output: (Kodaira type, conductor exponent f, Tamagawa number c, minimal a-invariants, v(Delta_min)).
Conductor exponents follow Ogg's formula f = v(Delta) - m + 1 (Saito: valid in all characteristics).
"""
from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from functools import cached_property
from typing import Any

from .gf import GF, Poly, _trim, poly_add, poly_divmod, poly_mod, poly_mul

APoly = tuple[int, ...]


# ------------------------------------------------------------ DVR interface --
class LocalRing:
    """Exact DVR: ring ops, valuation, exact division by the uniformiser, residue map and lifts."""

    residue_field: GF

    def zero(self): ...
    def one(self): ...
    def add(self, a, b): ...
    def sub(self, a, b): ...
    def mul(self, a, b): ...
    def neg(self, a): ...
    def scale(self, n: int, a): ...
    def valuation(self, a) -> int | None: ...
    def div_pi(self, a, k: int = 1): ...  # exact division by pi^k
    def residue(self, a) -> Poly: ...
    def lift(self, r: Poly): ...

    def half(self): ...  # the unit 1/2 (residue characteristic != 2)

    def divides_pi(self, a, k: int = 1) -> bool:
        v = self.valuation(a)
        return v is None or v >= k


@dataclass(frozen=True)
class ZLocal(LocalRing):
    """Z_(p): Fractions with denominator prime to p."""

    p: int

    @cached_property
    def residue_field(self) -> GF:  # type: ignore[override]
        return GF.of_order(self.p, 1)

    def zero(self):
        return Fraction(0)

    def one(self):
        return Fraction(1)

    def add(self, a, b):
        return a + b

    def sub(self, a, b):
        return a - b

    def mul(self, a, b):
        return a * b

    def neg(self, a):
        return -a

    def scale(self, n, a):
        return n * a

    def valuation(self, a):
        if a == 0:
            return None
        v, n, d = 0, a.numerator, a.denominator
        while n % self.p == 0:
            n //= self.p
            v += 1
        while d % self.p == 0:
            d //= self.p
            v -= 1
        return v

    def div_pi(self, a, k=1):
        return a / Fraction(self.p) ** k

    def residue(self, a):
        return self.residue_field.from_int(a.numerator * pow(a.denominator, -1, self.p))

    def lift(self, r):
        return Fraction(r[0])

    def half(self):
        return Fraction(1, 2)


@dataclass(frozen=True)
class PolyLocal(LocalRing):
    """F_p[t] localised at a monic irreducible pi (polynomial elements; divisions are exact)."""

    p: int
    pi: APoly

    @cached_property
    def residue_field(self) -> GF:  # type: ignore[override]
        return GF(self.p, self.pi)

    def zero(self):
        return ()

    def one(self):
        return (1,)

    def add(self, a, b):
        return poly_add(a, b, self.p)

    def sub(self, a, b):
        return poly_add(a, self.neg(b), self.p)

    def mul(self, a, b):
        return poly_mul(a, b, self.p)

    def neg(self, a):
        return _trim(tuple((-c) % self.p for c in a))

    def scale(self, n, a):
        return _trim(tuple(n * c % self.p for c in a))

    def valuation(self, a):
        a = _trim(a)
        if not a:
            return None
        v = 0
        while True:
            q, r = poly_divmod(a, self.pi, self.p)
            if r:
                return v
            a, v = q, v + 1

    def div_pi(self, a, k=1):
        for _ in range(k):
            q, r = poly_divmod(a, self.pi, self.p)
            if r:
                raise ValueError("inexact division by pi")
            a = q
        return a

    def residue(self, a):
        return self.residue_field.elt(poly_mod(a, self.pi, self.p))

    def lift(self, r):
        return _trim(tuple(r))

    def half(self):
        return (pow(2, -1, self.p),)


# ---------------------------------------------------------------- algebra --
@dataclass(frozen=True)
class TateResult:
    kodaira: str
    conductor_exponent: int
    tamagawa: int
    minimal_model: tuple
    discriminant_valuation: int
    split: bool | None = None  # for multiplicative reduction


def _transform(R: LocalRing, a, r, s, t):
    """(x, y) -> (x + r, y + s x + t): Silverman Table 3.1 with u = 1."""
    a1, a2, a3, a4, a6 = a
    m, ad, sb, sc = R.mul, R.add, R.sub, R.scale
    n1 = ad(a1, sc(2, s))
    n2 = sb(ad(sb(a2, m(s, a1)), sc(3, r)), m(s, s))
    n3 = ad(ad(a3, m(r, a1)), sc(2, t))
    n4 = sb(ad(sb(sb(a4, m(s, a3)), m(ad(t, m(r, s)), a1)), ad(sc(2, m(r, a2)), sc(3, m(r, r)))), sc(2, m(s, t)))
    n6 = sb(sb(sb(ad(ad(ad(a6, m(r, a4)), m(m(r, r), a2)), m(m(r, r), r)), m(t, a3)), m(t, t)), m(m(r, t), a1))
    return (n1, n2, n3, n4, n6)


def _b_invariants(R: LocalRing, a):
    a1, a2, a3, a4, a6 = a
    m, ad, sb, sc = R.mul, R.add, R.sub, R.scale
    b2 = ad(m(a1, a1), sc(4, a2))
    b4 = ad(sc(2, a4), m(a1, a3))
    b6 = ad(m(a3, a3), sc(4, a6))
    b8 = sb(ad(sb(ad(m(m(a1, a1), a6), sc(4, m(a2, a6))), m(m(a1, a3), a4)), m(a2, m(a3, a3))), m(a4, a4))
    return b2, b4, b6, b8


def discriminant(R: LocalRing, a):
    b2, b4, b6, b8 = _b_invariants(R, a)
    m, ad, sb, sc = R.mul, R.add, R.sub, R.scale
    return ad(sb(sb(R.neg(m(m(b2, b2), b8)), sc(8, m(m(b4, b4), b4))), sc(27, m(b6, b6))), sc(9, m(m(b2, b4), b6)))


def _k_roots(k: GF, coeffs) -> list:
    """Distinct roots in k of a polynomial with coefficients in k (low -> high)."""
    return [r for r, _ in k.poly_roots(tuple(coeffs))]


def _quadratic_has_double_root(k: GF, a, b) -> bool:
    """T^2 + a T + b has a repeated root iff a^2 - 4b = 0 (any characteristic)."""
    return k.sub(k.mul(a, a), k.scale(4, b)) == k.zero


def _cubic_root_structure(k: GF, b, c, d):
    """For T^3 + b T^2 + c T + d over k: ('distinct', None) | ('double', r) with r the double root in k
    | ('triple', r)."""
    disc = k.add(k.sub(k.sub(k.sub(k.mul(k.mul(b, b), k.mul(c, c)), k.scale(4, k.pow(c, 3))), k.scale(4, k.mul(k.pow(b, 3), d))),
                       k.scale(27, k.mul(d, d))), k.scale(18, k.mul(k.mul(b, c), d)))
    if disc != k.zero:
        return "distinct", None
    for r in k.elements():
        r3 = k.pow(r, 3)
        if b == k.scale(-3, r) and c == k.scale(3, k.mul(r, r)) and d == k.neg(r3):
            return "triple", r
    for r in k.elements():
        # r is a double root iff (T - r)^2 divides the cubic: P(r) = 0 and the deflated quadratic vanishes at r
        P = (d, c, b, k.one)
        q, rem = k._divide_by_linear(P, r)
        if rem == k.zero and k.eval_poly(q, r) == k.zero:
            return "double", r
    raise AssertionError("cubic with zero discriminant but no repeated root found")  # unreachable over a finite field


def _singular_point(k: GF, a):
    """The singular point of a singular Weierstrass cubic over k (unique)."""
    a1, a2, a3, a4, a6 = a
    for x in k.elements():
        for y in k.elements():
            F = k.sub(k.add(k.add(k.mul(y, y), k.mul(k.mul(a1, x), y)), k.mul(a3, y)),
                      k.add(k.add(k.add(k.pow(x, 3), k.mul(a2, k.mul(x, x))), k.mul(a4, x)), a6))
            if F != k.zero:
                continue
            Fy = k.add(k.add(k.scale(2, y), k.mul(a1, x)), a3)
            Fx = k.sub(k.mul(a1, y), k.add(k.add(k.scale(3, k.mul(x, x)), k.scale(2, k.mul(a2, x))), a4))
            if Fx == k.zero and Fy == k.zero:
                return x, y
    raise AssertionError("no singular point")


def tate(R: LocalRing, a) -> TateResult:
    """Tate's algorithm for y^2 + a1 xy + a3 y = x^3 + a2 x^2 + a4 x + a6 over the DVR R."""
    k = R.residue_field
    a = tuple(a)
    while True:
        disc = discriminant(R, a)
        vD = R.valuation(disc)
        if vD is None:
            raise ValueError("singular curve")
        if vD == 0:
            return TateResult("I0", 0, 1, a, 0)
        # Step 2: move the singular point to (0, 0)
        x0, y0 = _singular_point(k, tuple(R.residue(x) for x in a))
        a = _transform(R, a, R.lift(x0), R.zero(), R.lift(y0))
        a1, a2, a3, a4, a6 = a
        b2, b4, b6, b8 = _b_invariants(R, a)
        if not R.divides_pi(b2):
            # multiplicative: tangent cone T^2 + a1 T - a2 splits iff two roots in k
            roots = _k_roots(k, (k.neg(R.residue(a2)), R.residue(a1), k.one))
            split = len(roots) == 2
            c = vD if split else (2 if vD % 2 == 0 else 1)
            return TateResult(f"I{vD}", 1, c, a, vD, split)
        # Step 3
        if not R.divides_pi(a6, 2):
            return TateResult("II", vD, 1, a, vD)
        # Step 4
        if not R.divides_pi(b8, 3):
            return TateResult("III", vD - 1, 2, a, vD)
        # Step 5
        if not R.divides_pi(b6, 3):
            roots = _k_roots(k, (k.neg(R.residue(R.div_pi(a6, 2))), R.residue(R.div_pi(a3)), k.one))
            return TateResult("IV", vD - 2, 3 if len(roots) == 2 else 1, a, vD)
        # Step 6: make pi | a1, a2; pi^2 | a3, a4; pi^3 | a6
        # (i) y -> y + s x: the tangent cone y^2 + a1 xy - a2 x^2 becomes y^2 + (a1 + 2s) xy + (s^2 + a1 s - a2) x^2,
        #     a square iff a1 + 2s = 0 and s^2 + a1 s - a2 = 0 in k (possible since pi | b2 = a1^2 + 4 a2)
        r1, r2 = R.residue(a1), R.residue(a2)
        s = next(z for z in k.elements()
                 if k.add(r1, k.scale(2, z)) == k.zero and k.sub(k.add(k.mul(z, z), k.mul(r1, z)), r2) == k.zero)
        a = _transform(R, a, R.zero(), R.lift(s), R.zero())
        a1, a2, a3, a4, a6 = a
        # (ii) y -> y + t with t^2 + a3 t + a6 = 0 mod pi^3; t = pi * t1
        if k.p != 2:
            t = R.neg(R.mul(R.half(), a3))  # t = -a3/2 (2 is a unit; a3 has v >= 1)
        else:
            t1 = k.sqrt(R.residue(R.div_pi(a6, 2)))
            t = R.mul(R.lift(t1), _pi(R))
        a = _transform(R, a, R.zero(), R.zero(), t)
        a1, a2, a3, a4, a6 = a
        for x, e in ((a1, 1), (a2, 1), (a3, 2), (a4, 2), (a6, 3)):
            if not R.divides_pi(x, e):
                raise AssertionError("step 6 normalisation failed")
        # cubic P(T) = T^3 + (a2/pi) T^2 + (a4/pi^2) T + a6/pi^3 over k
        pb, pc, pd = R.residue(R.div_pi(a2)), R.residue(R.div_pi(a4, 2)), R.residue(R.div_pi(a6, 3))
        kind, root = _cubic_root_structure(k, pb, pc, pd)
        if kind == "distinct":
            nroots = len(_k_roots(k, (pd, pc, pb, k.one)))
            return TateResult("I0*", vD - 4, 1 + nroots, a, vD)
        if kind == "double":
            # Step 7: translate x so the double root is 0, then the I_n* loop
            a = _transform(R, a, R.mul(R.lift(root), _pi(R)), R.zero(), R.zero())
            n = 1
            j = 1
            while True:
                a1, a2, a3, a4, a6 = a
                if n % 2 == 1:  # Y^2 + (a3/pi^{j+1}) Y - a6/pi^{2j+2}
                    qa, qb = R.residue(R.div_pi(a3, j + 1)), k.neg(R.residue(R.div_pi(a6, 2 * j + 2)))
                    if not _quadratic_has_double_root(k, qa, qb):
                        c = 4 if len(_k_roots(k, (qb, qa, k.one))) == 2 else 2
                        return TateResult(f"I{n}*", vD - 4 - n, c, a, vD)
                    y0 = _k_roots(k, (qb, qa, k.one))[0]
                    a = _transform(R, a, R.zero(), R.zero(), R.mul(R.lift(y0), _pi_pow(R, j + 1)))
                else:  # (a2/pi) X^2 + (a4/pi^{j+2}) X + a6/pi^{2j+3}
                    lead = R.residue(R.div_pi(a2))
                    inv = k.inv(lead)
                    qa, qb = k.mul(inv, R.residue(R.div_pi(a4, j + 2))), k.mul(inv, R.residue(R.div_pi(a6, 2 * j + 3)))
                    if not _quadratic_has_double_root(k, qa, qb):
                        c = 4 if len(_k_roots(k, (qb, qa, k.one))) == 2 else 2
                        return TateResult(f"I{n}*", vD - 4 - n, c, a, vD)
                    x0 = _k_roots(k, (qb, qa, k.one))[0]
                    a = _transform(R, a, R.mul(R.lift(x0), _pi_pow(R, j + 1)), R.zero(), R.zero())
                    j += 1
                n += 1
        # triple root: Step 8
        a = _transform(R, a, R.mul(R.lift(root), _pi(R)), R.zero(), R.zero())
        a1, a2, a3, a4, a6 = a
        qa, qb = R.residue(R.div_pi(a3, 2)), k.neg(R.residue(R.div_pi(a6, 4)))
        if not _quadratic_has_double_root(k, qa, qb):
            c = 3 if len(_k_roots(k, (qb, qa, k.one))) == 2 else 1
            return TateResult("IV*", vD - 6, c, a, vD)
        y0 = _k_roots(k, (qb, qa, k.one))[0]
        a = _transform(R, a, R.zero(), R.zero(), R.mul(R.lift(y0), _pi_pow(R, 2)))
        a1, a2, a3, a4, a6 = a
        if not R.divides_pi(a4, 4):
            return TateResult("III*", vD - 7, 2, a, vD)
        if not R.divides_pi(a6, 6):
            return TateResult("II*", vD - 8, 1, a, vD)
        # Step 11: non-minimal; scale a_i -> a_i / pi^i and restart
        a = tuple(R.div_pi(x, e) for x, e in zip(a, (1, 2, 3, 4, 6)))


def _pi(R: LocalRing):
    return Fraction(R.p) if isinstance(R, ZLocal) else R.pi


def _pi_pow(R: LocalRing, e: int):
    out = R.one()
    for _ in range(e):
        out = R.mul(out, _pi(R))
    return out
