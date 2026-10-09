"""Elliptic curves over F_p(t): reduction types, Frobenius traces at places, and L-functions.

The Galois side of Drinfeld's dictionary for GL_2 over F_q(t): H^1 of E is a rank-2 local
system on P^1 minus the bad places; its Frobenius traces are a_p(E) = |F_p| + 1 - #E(F_p),
computed by point counting over F_p = GF(q, p) (t acts as a root of p).  A curve with
conductor n·oo (multiplicative at n and split multiplicative at oo) corresponds, by
Drinfeld + Deligne/Jacquet–Langlands, to a Hecke eigenform on Gamma_0(n)\\T.
"""
from __future__ import annotations

from dataclasses import dataclass
from functools import cached_property
from itertools import product

from .gf import GF, Poly, _trim, is_irreducible, poly_add, poly_divmod, poly_mod, poly_mul, poly_sub

APoly = tuple[int, ...]


def _padd(*fs, p):
    out: APoly = ()
    for f in fs:
        out = poly_add(out, f, p)
    return out


def _psc(k: int, f: APoly, p: int) -> APoly:
    return _trim(tuple(k * c % p for c in f))


def _ppow(f: APoly, e: int, p: int) -> APoly:
    out: APoly = (1,)
    for _ in range(e):
        out = poly_mul(out, f, p)
    return out


@dataclass(frozen=True)
class FunctionFieldCurve:
    p: int
    a: tuple[APoly, APoly, APoly, APoly, APoly]  # a1, a2, a3, a4, a6 in F_p[t]

    @cached_property
    def invariants(self) -> dict[str, APoly]:
        p = self.p
        a1, a2, a3, a4, a6 = self.a
        m = lambda f, g: poly_mul(f, g, p)  # noqa: E731
        b2 = _padd(m(a1, a1), _psc(4, a2, p), p=p)
        b4 = _padd(_psc(2, a4, p), m(a1, a3), p=p)
        b6 = _padd(m(a3, a3), _psc(4, a6, p), p=p)
        b8 = _padd(m(m(a1, a1), a6), _psc(4, m(a2, a6), p), _psc(-1, m(m(a1, a3), a4), p), m(a2, m(a3, a3)), _psc(-1, m(a4, a4), p), p=p)
        c4 = _padd(m(b2, b2), _psc(-24, b4, p), p=p)
        c6 = _padd(_psc(-1, _ppow(b2, 3, p), p), _psc(36, m(b2, b4), p), _psc(-216, b6, p), p=p)
        disc = _padd(_psc(-1, m(m(b2, b2), b8), p), _psc(-8, _ppow(b4, 3, p), p), _psc(-27, m(b6, b6), p), _psc(9, m(m(b2, b4), b6), p), p=p)
        return {"b2": b2, "b4": b4, "b6": b6, "b8": b8, "c4": c4, "c6": c6, "disc": disc}

    @property
    def discriminant(self) -> APoly:
        return self.invariants["disc"]

    # ----------------------------------------------------------- reductions --
    def reduce_at(self, prime: APoly) -> "ReducedCurve":
        K = GF(self.p, prime)
        theta = K.gen
        coeffs = tuple(K.eval_poly(tuple(K.from_int(c) for c in ai), theta) for ai in self.a)
        return ReducedCurve(K, coeffs)

    def model_at_infinity(self) -> "FunctionFieldCurve":
        """Same curve in the coordinate s = 1/t: a_i(s) = s^{i d} a_i(1/s), d minimal with deg a_i <= i d."""
        d = max((-(-(len(ai) - 1) // i) for i, ai in zip((1, 2, 3, 4, 6), self.a) if ai), default=0)
        new = []
        for i, ai in zip((1, 2, 3, 4, 6), self.a):
            n = i * d
            new.append(_trim(tuple(ai[n - j] if 0 <= n - j < len(ai) else 0 for j in range(n + 1))))
        return FunctionFieldCurve(self.p, tuple(new))

    def reduce_at_infinity(self) -> "ReducedCurve":
        return self.model_at_infinity().reduce_at((0, 1))  # s = 0

    def bad_primes(self, max_degree: int) -> tuple[APoly, ...]:
        disc = self.discriminant
        return tuple(f for f in monic_irreducibles(self.p, max_degree) if not poly_mod(disc, f, self.p))

    def valuation(self, f: APoly, prime: APoly) -> int:
        v = 0
        while f and not poly_mod(f, prime, self.p):
            f, v = poly_divmod(f, prime, self.p)[0], v + 1
        return v

    def reduction_type(self, prime: APoly | None) -> str:
        """'good' | 'split' | 'nonsplit' | 'additive' at a finite prime, or at oo (prime=None).
        Requires the model to be minimal there (v(disc) < 12 is enforced)."""
        E = self if prime is not None else self.model_at_infinity()
        pr = prime if prime is not None else (0, 1)
        disc, c4 = E.discriminant, E.invariants["c4"]
        if E.valuation(disc, pr) >= 12:
            raise ValueError("model may be non-minimal at this place")
        if poly_mod(disc, pr, self.p):
            return "good"
        if not poly_mod(c4, pr, self.p):
            return "additive"
        return "split" if E.reduce_at(pr).node_is_split() else "nonsplit"

    def local_data(self, max_degree: int) -> dict:
        """Tate's algorithm at every bad place of degree <= max_degree and at oo (key None):
        Kodaira type, conductor exponent, Tamagawa number, minimal model."""
        from .tate import PolyLocal, tate

        out = {f: tate(PolyLocal(self.p, f), self.a) for f in self.bad_primes(max_degree)}
        out[None] = tate(PolyLocal(self.p, (0, 1)), self.model_at_infinity().a)
        return {f: r for f, r in out.items() if r.kodaira != "I0"}

    def conductor_degree(self, max_degree: int) -> int:
        """deg N = sum over bad places (degree <= max_degree, oo included) of f_v * deg v."""
        return sum(r.conductor_exponent * (1 if f is None else len(f) - 1) for f, r in self.local_data(max_degree).items())

    def conductor_support(self, max_degree: int) -> dict:
        types = {f: self.reduction_type(f) for f in self.bad_primes(max_degree)}
        types[None] = self.reduction_type(None)
        return {f: t for f, t in types.items() if t != "good"}

    # ---------------------------------------------------------------- traces --
    def trace_at(self, prime: APoly | None) -> int:
        """Frobenius trace at a finite prime (or oo): |F| + 1 - #E~(F) for good reduction,
        +1 / -1 for split / nonsplit multiplicative, 0 for additive."""
        kind = self.reduction_type(prime)
        if kind == "good":
            R = self.reduce_at(prime) if prime is not None else self.reduce_at_infinity()
            return R.K.order + 1 - R.point_count()
        return {"split": 1, "nonsplit": -1, "additive": 0}[kind]

    def l_series(self, order: int) -> tuple[int, ...]:
        """Coefficients of L(E, T) = prod_v L_v(T) to T^order, all places of degree <= order (oo has degree 1)."""
        series = [1] + [0] * order
        places = [(f, len(f) - 1) for f in monic_irreducibles(self.p, order)] + [(None, 1)]
        for f, d in places:
            kind = self.reduction_type(f)
            a = self.trace_at(f)
            # local factor inverse: (1 - a T^d + q^d T^{2d}) good, (1 - a T^d) multiplicative, 1 additive
            factor = {0: 1}
            if kind == "good":
                factor = {0: 1, d: -a, 2 * d: self.p**d}
            elif kind in ("split", "nonsplit"):
                factor = {0: 1, d: -a}
            # multiply series by 1/factor: series_new[n] = series[n] - sum_{k>0} factor[k] series_new[n-k]
            new = [0] * (order + 1)
            for n in range(order + 1):
                s = series[n]
                for k, c in factor.items():
                    if k and n - k >= 0:
                        s -= c * new[n - k]
                new[n] = s
            series = new
        return tuple(series)


@dataclass(frozen=True)
class ReducedCurve:
    """A Weierstrass curve over a finite field K (general form; may be singular)."""

    K: GF
    a: tuple[Poly, Poly, Poly, Poly, Poly]

    def equation(self, x: Poly, y: Poly) -> Poly:
        K = self.K
        a1, a2, a3, a4, a6 = self.a
        lhs = K.add(K.add(K.mul(y, y), K.mul(K.mul(a1, x), y)), K.mul(a3, y))
        rhs = K.add(K.add(K.add(K.pow(x, 3), K.mul(a2, K.mul(x, x))), K.mul(a4, x)), a6)
        return K.sub(lhs, rhs)

    def point_count(self) -> int:
        K = self.K
        return 1 + sum(1 for x in K.elements() for y in K.elements() if self.equation(x, y) == K.zero)

    def singular_points(self) -> list[tuple[Poly, Poly]]:
        K = self.K
        a1, a2, a3, a4, a6 = self.a
        out = []
        for x in K.elements():
            for y in K.elements():
                if self.equation(x, y) != K.zero:
                    continue
                fy = K.add(K.add(K.scale(2, y), K.mul(a1, x)), a3)
                fx = K.sub(K.mul(a1, y), K.add(K.add(K.scale(3, K.mul(x, x)), K.scale(2, K.mul(a2, x))), a4))
                if fx == K.zero and fy == K.zero:
                    out.append((x, y))
        return out

    def node_is_split(self) -> bool:
        """At the (unique) node, the tangent cone Q(X, Y) = degree-2 part of f(x0 + X, y0 + Y)
        splits into K-rational lines iff it has a nontrivial zero on P^1(K)."""
        K = self.K
        a1, a2, a3, a4, a6 = self.a
        sing = self.singular_points()
        if len(sing) != 1:
            raise ValueError("expected exactly one singular point")
        x0, y0 = sing[0]
        # degree-2 terms of f(x0+X, y0+Y):  Y^2 + a1 X Y - (3 x0 + a2) X^2
        qXX = K.neg(K.add(K.scale(3, x0), a2))
        qXY, qYY = a1, K.one
        for X, Y in [(K.one, y) for y in K.elements()] + [(K.zero, K.one)]:
            val = K.add(K.add(K.mul(qXX, K.mul(X, X)), K.mul(qXY, K.mul(X, Y))), K.mul(qYY, K.mul(Y, Y)))
            if val == K.zero:
                return True
        return False


def monic_irreducibles(p: int, max_degree: int) -> tuple[APoly, ...]:
    out = []
    for d in range(1, max_degree + 1):
        for low in product(range(p), repeat=d):
            f = tuple(low) + (1,)
            if is_irreducible(f, p):
                out.append(f)
    return tuple(out)


def search_conductor_n_infinity(p: int, degrees: tuple[int, int, int, int, int], n_degree: int) -> list["FunctionFieldCurve"]:
    """Curves with a_i of degree <= degrees[i], discriminant = unit * n^m for a monic irreducible n of
    degree n_degree, multiplicative at n and split multiplicative at oo (hence conductor n oo)."""
    found = []
    cubics = [f for f in monic_irreducibles(p, n_degree) if len(f) - 1 == n_degree]
    ranges = [list(product(range(p), repeat=d + 1)) for d in degrees]
    for a1, a2, a3, a4, a6 in product(*ranges):
        E = FunctionFieldCurve(p, tuple(_trim(x) for x in (a1, a2, a3, a4, a6)))
        disc = E.discriminant
        if not disc or (len(disc) - 1) % n_degree:
            continue
        m = (len(disc) - 1) // n_degree
        for n in cubics:
            if disc == _psc(disc[-1], _ppow(n, m, p), p):
                try:
                    if E.reduction_type(n) in ("split", "nonsplit") and E.reduction_type(None) == "split":
                        found.append((n, E))
                except ValueError:
                    pass
                break
    return found
