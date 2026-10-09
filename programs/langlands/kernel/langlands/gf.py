"""Exact finite fields F_{p^k}: immutable, dependency-free.

An element of GF(p, modulus) is a tuple of k ints in [0, p), coefficients of a
polynomial in the class of `t` modulo `modulus` (monic irreducible over F_p,
coefficients low -> high).  All operations are methods on the field so that
elements stay plain hashable tuples.
"""
from __future__ import annotations

import random
from dataclasses import dataclass
from functools import cached_property
from itertools import product
from typing import Iterator

Poly = tuple[int, ...]  # coefficients low -> high


# ----------------------------------------------------------------- F_p[x] ----
def _trim(a: Poly) -> Poly:
    n = len(a)
    while n and a[n - 1] == 0:
        n -= 1
    return a[:n]


def poly_add(a: Poly, b: Poly, p: int) -> Poly:
    n = max(len(a), len(b))
    a, b = a + (0,) * (n - len(a)), b + (0,) * (n - len(b))
    return _trim(tuple((x + y) % p for x, y in zip(a, b)))


def poly_sub(a: Poly, b: Poly, p: int) -> Poly:
    return poly_add(a, tuple(-x % p for x in b), p)


def poly_mul(a: Poly, b: Poly, p: int) -> Poly:
    if not a or not b:
        return ()
    out = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                out[i + j] = (out[i + j] + x * y) % p
    return _trim(tuple(out))


def poly_divmod(a: Poly, b: Poly, p: int) -> tuple[Poly, Poly]:
    b = _trim(b)
    if not b:
        raise ZeroDivisionError("polynomial division by zero")
    a = list(_trim(a))
    inv_lead = pow(b[-1], -1, p)
    q = [0] * max(0, len(a) - len(b) + 1)
    for i in range(len(a) - len(b), -1, -1):
        c = a[i + len(b) - 1] * inv_lead % p
        q[i] = c
        if c:
            for j, y in enumerate(b):
                a[i + j] = (a[i + j] - c * y) % p
    return _trim(tuple(q)), _trim(tuple(a[: len(b) - 1]))


def poly_mod(a: Poly, m: Poly, p: int) -> Poly:
    return poly_divmod(a, m, p)[1]


def poly_gcd(a: Poly, b: Poly, p: int) -> Poly:
    a, b = _trim(a), _trim(b)
    while b:
        a, b = b, poly_mod(a, b, p)
    if not a:
        return ()
    inv = pow(a[-1], -1, p)
    return tuple(x * inv % p for x in a)


def poly_powmod(a: Poly, e: int, m: Poly, p: int) -> Poly:
    result, base = (1,), poly_mod(a, m, p)
    while e:
        if e & 1:
            result = poly_mod(poly_mul(result, base, p), m, p)
        base = poly_mod(poly_mul(base, base, p), m, p)
        e >>= 1
    return result


def poly_eval(a: Poly, x: int, p: int) -> int:
    acc = 0
    for c in reversed(a):
        acc = (acc * x + c) % p
    return acc


def is_irreducible(f: Poly, p: int) -> bool:
    """Rabin's test: f monic of degree k is irreducible over F_p iff
    x^{p^k} = x mod f and gcd(x^{p^{k/r}} - x, f) = 1 for every prime r | k."""
    f = _trim(f)
    k = len(f) - 1
    if k < 1:
        return False
    x: Poly = (0, 1)
    if poly_powmod(x, p**k, f, p) != poly_mod(x, f, p):
        return False
    for r in _prime_factors(k):
        h = poly_sub(poly_powmod(x, p ** (k // r), f, p), x, p)
        if len(poly_gcd(h, f, p)) > 1:
            return False
    return True


def _prime_factors(n: int) -> tuple[int, ...]:
    out, d = [], 2
    while d * d <= n:
        if n % d == 0:
            out.append(d)
            while n % d == 0:
                n //= d
        d += 1
    return tuple(out + ([n] if n > 1 else []))


def irreducible_polynomial(p: int, k: int) -> Poly:
    """First monic irreducible of degree k over F_p in a fixed order (deterministic): the
    constant term varies fastest, so candidates with zero constant term are skipped cheaply."""
    if k == 1:
        return (0, 1)
    for high_to_low in product(range(p), repeat=k):
        f = tuple(reversed(high_to_low)) + (1,)
        if f[0] and is_irreducible(f, p):
            return f
    raise ValueError(f"no irreducible polynomial of degree {k} over F_{p}")  # unreachable


# ------------------------------------------------------------- F_{p^k} -------
@dataclass(frozen=True)
class GF:
    """The field F_p[t]/(modulus).  Elements are tuples of length k = deg modulus."""

    p: int
    modulus: Poly

    @staticmethod
    def of_order(p: int, k: int = 1) -> "GF":
        return GF(p, irreducible_polynomial(p, k))

    def __post_init__(self) -> None:
        if len(self.modulus) < 2 or self.modulus[-1] != 1:
            raise ValueError("modulus must be monic of degree >= 1")
        if not is_irreducible(self.modulus, self.p):
            raise ValueError("modulus must be irreducible")

    @property
    def k(self) -> int:
        return len(self.modulus) - 1

    @cached_property
    def order(self) -> int:
        return self.p ** self.k

    @cached_property
    def zero(self) -> Poly:
        return (0,) * self.k

    @cached_property
    def one(self) -> Poly:
        return self.elt((1,))

    @cached_property
    def gen(self) -> Poly:
        """The class of t (a generator of the field as an F_p-algebra)."""
        return self.elt((0, 1))

    def elt(self, coeffs) -> Poly:
        c = poly_mod(tuple(int(x) % self.p for x in coeffs), self.modulus, self.p)
        return c + (0,) * (self.k - len(c))

    def from_int(self, n: int) -> Poly:
        return self.elt((n,))

    def is_prime_field_element(self, a: Poly) -> bool:
        return all(x == 0 for x in a[1:])

    def to_int(self, a: Poly) -> int:
        if not self.is_prime_field_element(a):
            raise ValueError("not in the prime field")
        return a[0]

    def elements(self) -> Iterator[Poly]:
        return (tuple(reversed(c)) for c in product(range(self.p), repeat=self.k))

    def add(self, a: Poly, b: Poly) -> Poly:
        return tuple((x + y) % self.p for x, y in zip(a, b))

    def sub(self, a: Poly, b: Poly) -> Poly:
        return tuple((x - y) % self.p for x, y in zip(a, b))

    def neg(self, a: Poly) -> Poly:
        return tuple(-x % self.p for x in a)

    TABLE_LIMIT = 1 << 17

    @cached_property
    def _tables(self) -> tuple[dict[Poly, int], tuple[Poly, ...]] | None:
        """Zech-style log/exp tables for fields of order <= TABLE_LIMIT: mul, inv, pow in O(1)."""
        if self.order > self.TABLE_LIMIT:
            return None
        n = self.order - 1
        cofactors = tuple(n // r for r in _prime_factors(n))
        generic_pow = lambda a, e: self.elt(poly_powmod(a, e, self.modulus, self.p))  # noqa: E731
        g = next(g for g in self.elements() if g != self.zero and all(generic_pow(g, c) != self.one for c in cofactors))
        exp, x = [self.one], self.one
        for _ in range(n - 1):
            x = self._mul_generic(x, g)
            exp.append(x)
        return {a: i for i, a in enumerate(exp)}, tuple(exp)

    @cached_property
    def _reduction(self) -> tuple[Poly, ...]:
        """t^d for d in [k, 2k-2], reduced modulo the modulus (rows of length k)."""
        return tuple(self.elt((0,) * d + (1,)) for d in range(self.k, 2 * self.k - 1))

    def _mul_generic(self, a: Poly, b: Poly) -> Poly:
        k, p = self.k, self.p
        prod = [0] * (2 * k - 1)
        for i, x in enumerate(a):
            if x:
                for j, y in enumerate(b):
                    prod[i + j] += x * y
        out = prod[:k]
        for d in range(k, 2 * k - 1):
            c = prod[d]
            if c:
                row = self._reduction[d - k]
                for i in range(k):
                    out[i] += c * row[i]
        return tuple(x % p for x in out)

    def mul(self, a: Poly, b: Poly) -> Poly:
        t = self._tables
        if t is None:
            return self._mul_generic(a, b)
        if a == self.zero or b == self.zero:
            return self.zero
        log, exp = t
        return exp[(log[a] + log[b]) % (self.order - 1)]

    def scale(self, n: int, a: Poly) -> Poly:
        return tuple(n * x % self.p for x in a)

    def pow(self, a: Poly, e: int) -> Poly:
        if e < 0:
            return self.pow(self.inv(a), -e)
        t = self._tables
        if t is None:
            return self.elt(poly_powmod(a, e, self.modulus, self.p))
        if a == self.zero:
            return self.one if e == 0 else self.zero
        log, exp = t
        return exp[(log[a] * e) % (self.order - 1)]

    def inv(self, a: Poly) -> Poly:
        if a == self.zero:
            raise ZeroDivisionError("inverse of zero")
        t = self._tables
        if t is None:
            return self.pow(a, self.order - 2)
        log, exp = t
        return exp[(-log[a]) % (self.order - 1)]

    def div(self, a: Poly, b: Poly) -> Poly:
        return self.mul(a, self.inv(b))

    def frobenius(self, a: Poly, power: int = 1) -> Poly:
        """a -> a^{p^power}; the absolute Frobenius (power=1) generates Gal(F_{p^k}/F_p)."""
        return self.pow(a, self.p**power)

    def norm(self, a: Poly) -> Poly:
        """N_{F_{p^k}/F_p}(a) = a^{(p^k-1)/(p-1)}, returned as a field element."""
        return self.pow(a, (self.order - 1) // (self.p - 1))

    @cached_property
    def _sqrt_table(self) -> dict[Poly, Poly]:
        table: dict[Poly, Poly] = {}
        for a in self.elements():
            table.setdefault(self.mul(a, a), a)
        return table

    def sqrt(self, a: Poly) -> Poly | None:
        """A square root of a if one exists (exact: log/exp tables, else a square table), else None."""
        t = self._tables
        if t is None:
            return self._sqrt_table.get(a)
        if a == self.zero:
            return self.zero
        log, exp = t
        e = log[a]
        if self.p == 2:
            return exp[(e * (self.order // 2)) % (self.order - 1)]  # sqrt = a^{q/2}
        return exp[e // 2] if e % 2 == 0 else None

    def sqrts(self, a: Poly) -> tuple[Poly, ...]:
        """All square roots of a: none, one (a = 0, or characteristic 2 where -r = r), or two."""
        r = self.sqrt(a)
        if r is None:
            return ()
        return (r,) if r == self.zero or self.p == 2 else (r, self.neg(r))

    def multiplicative_order(self, a: Poly) -> int:
        if a == self.zero:
            raise ValueError("zero has no multiplicative order")
        n, x = 1, a
        while x != self.one:
            x, n = self.mul(x, a), n + 1
        return n

    EXHAUSTIVE_LIMIT = 20000

    def poly_roots(self, coeffs: tuple[Poly, ...]) -> tuple[tuple[Poly, int], ...]:
        """Roots in this field of a polynomial with coefficients here (low -> high), with
        multiplicities.  Exhaustive search for small fields, else Cantor–Zassenhaus on the
        split squarefree part; multiplicities by repeated deflation either way."""
        f = self.ptrim(tuple(coeffs))
        candidates = (
            [r for r in self.elements() if self.eval_poly(f, r) == self.zero]
            if self.order <= self.EXHAUSTIVE_LIMIT or len(f) <= 1
            else self._distinct_roots_cz(f)
        )
        roots = []
        for r in candidates:
            mult = 0
            while True:
                q, rem = self._divide_by_linear(f, r)
                if rem != self.zero:
                    break
                f, mult = q, mult + 1
            roots.append((r, mult))
        return tuple(roots)

    # -- polynomials over this field (coefficients low -> high, tuples of elements) --
    def ptrim(self, f: tuple[Poly, ...]) -> tuple[Poly, ...]:
        n = len(f)
        while n and f[n - 1] == self.zero:
            n -= 1
        return f[:n]

    def pmul(self, f, g):
        if not f or not g:
            return ()
        out = [self.zero] * (len(f) + len(g) - 1)
        for i, x in enumerate(f):
            if x != self.zero:
                for j, y in enumerate(g):
                    out[i + j] = self.add(out[i + j], self.mul(x, y))
        return self.ptrim(tuple(out))

    def psub(self, f, g):
        n = max(len(f), len(g))
        f, g = f + (self.zero,) * (n - len(f)), g + (self.zero,) * (n - len(g))
        return self.ptrim(tuple(self.sub(x, y) for x, y in zip(f, g)))

    def pdivmod(self, f, g):
        g = self.ptrim(g)
        f = list(self.ptrim(f))
        inv = self.one if g[-1] == self.one else self.inv(g[-1])
        q = [self.zero] * max(0, len(f) - len(g) + 1)
        for i in range(len(f) - len(g), -1, -1):
            c = self.mul(f[i + len(g) - 1], inv)
            q[i] = c
            if c != self.zero:
                for j, y in enumerate(g):
                    f[i + j] = self.sub(f[i + j], self.mul(c, y))
        return self.ptrim(tuple(q)), self.ptrim(tuple(f[: len(g) - 1]))

    def pmod(self, f, g):
        return self.pdivmod(f, g)[1]

    def pgcd(self, f, g):
        f, g = self.ptrim(f), self.ptrim(g)
        while g:
            f, g = g, self.pmod(f, g)
        if not f:
            return ()
        inv = self.inv(f[-1])
        return tuple(self.mul(inv, x) for x in f)

    def pmonic(self, f):
        f = self.ptrim(f)
        inv = self.inv(f[-1])
        return tuple(self.mul(inv, x) for x in f)

    def ppowmod(self, f, e, m):
        m = self.pmonic(m)
        result, base = (self.one,), self.pmod(f, m)
        while e:
            if e & 1:
                result = self.pmod(self.pmul(result, base), m)
            base = self.pmod(self.pmul(base, base), m)
            e >>= 1
        return result

    def pderiv(self, f):
        return self.ptrim(tuple(self.scale(i, c) for i, c in enumerate(f))[1:])

    def _distinct_roots_cz(self, f: tuple[Poly, ...]) -> list[Poly]:
        """Distinct roots in this field: g = gcd(f, x^q - x) = prod (x - r) over the roots r in K
        (squarefree by construction, so inseparable f is handled), then split g with
        (x + r)^{(q-1)/2} - 1 over random r (p odd)."""
        x = (self.zero, self.one)
        g = self.pgcd(f, self.psub(self.ppowmod(x, self.order, f), x))
        return self._split(g)

    def equal_degree_factors(self, f, d: int) -> list[tuple[Poly, ...]]:
        """Monic irreducible factors of a squarefree f all of whose irreducible factors have degree d
        (Cantor–Zassenhaus with exponent (q^d - 1)/2; p odd)."""
        f = self.pmonic(f)
        if len(f) - 1 == d:
            return [f]
        rng = random.Random(len(f) * 104729 + d)
        e = (self.order**d - 1) // 2
        for _ in range(64 * len(f)):
            r = tuple(tuple(rng.randrange(self.p) for _ in range(self.k)) for _ in range(len(f) - 1))
            h = self.psub(self.ppowmod(self.ptrim(r), e, f), (self.one,))
            g = self.pgcd(f, h)
            if 1 < len(g) < len(f):
                return self.equal_degree_factors(g, d) + self.equal_degree_factors(self.pdivmod(f, g)[0], d)
        raise AssertionError("no splitting element found")

    def _split(self, g) -> list[Poly]:
        g = self.ptrim(g)
        if len(g) <= 1:
            return []
        if len(g) == 2:
            return [self.neg(self.mul(g[0], self.inv(g[1])))]
        if self.p == 2:
            raise NotImplementedError("Cantor–Zassenhaus splitting implemented for odd p only")
        rng = random.Random(len(g) * 7919 + sum(sum(c) for c in g))  # deterministic per input
        g = self.pmonic(g)
        for _ in range(64 * len(g)):
            r = tuple(rng.randrange(self.p) for _ in range(self.k))
            h = self.psub(self.ppowmod((r, self.one), (self.order - 1) // 2, g), (self.one,))
            d = self.pgcd(g, h)
            if 1 < len(d) < len(g):
                return self._split(d) + self._split(self.pdivmod(g, d)[0])
        raise AssertionError("no splitting element found")  # probability ~ 2^-64 for a split squarefree g

    def eval_poly(self, coeffs: tuple[Poly, ...], x: Poly) -> Poly:
        acc = self.zero
        for c in reversed(coeffs):
            acc = self.add(self.mul(acc, x), c)
        return acc

    def _divide_by_linear(self, f: tuple[Poly, ...], r: Poly) -> tuple[tuple[Poly, ...], Poly]:
        """Synthetic division of f by (X - r): (quotient, remainder)."""
        q: list[Poly] = []
        acc = self.zero
        for c in reversed(f):
            acc = self.add(self.mul(acc, r), c)
            q.append(acc)
        rem = q.pop()
        return tuple(reversed(q)), rem
