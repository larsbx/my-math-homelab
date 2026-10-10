"""The Carlitz module over A = F_p[t]: the function-field G_m, and its reciprocity law.

C_t(x) = t x + x^p; C_a is A-linear in a and F_p-linear in x (a p-polynomial).
For a monic irreducible P of degree d with residue field F_P = A/P ≅ F_{p^d}
(here literally the field GF(p, P)), the Carlitz–Hayes reciprocity law is
        Frob_P (lambda) = lambda^{|P|} = C_P(lambda)   for every lambda in C[M], P ∤ M,
and its polynomial form  C_P(x) ≡ x^{p^d} (mod P)  is the Fermat-Carlitz identity.
The decomposition law: the degree of every lambda in C[M] over F_P equals the
order of P in (A/ann(lambda))^x — the analogue of p splitting in Q(zeta_m)
according to ord_m(p).  All of this is computed below, exactly.
"""
from __future__ import annotations

from dataclasses import dataclass
from functools import cached_property

from .gf import GF, Poly, poly_add, poly_mod, poly_mul, poly_sub

APoly = tuple[int, ...]  # element of A = F_p[t], low -> high


@dataclass(frozen=True)
class CarlitzModule:
    p: int

    # C_a as a p-polynomial: tuple of coefficients (elements of A) of x^{p^i}, i = 0..deg a
    def carlitz_polynomial(self, a: APoly) -> tuple[APoly, ...]:
        p = self.p
        powers: list[tuple[APoly, ...]] = [((1,),)]  # C_1 = x
        for _ in range(len(a) - 1):  # C_{t^{i+1}} = C_t o C_{t^i} = t*C_{t^i} + (C_{t^i})^p
            prev = powers[-1]
            nxt = [poly_mul((0, 1), prev[0], p)]
            for i in range(1, len(prev) + 1):
                term = tuple(c for c in prev[i - 1])  # coefficient of x^{p^i}: prev_{i-1}^p = prev_{i-1} (Frobenius on A? no: (c x^{p^{i-1}})^p = c^p x^{p^i})
                term = self._frobenius_A(term)
                if i < len(prev):
                    term = poly_add(poly_mul((0, 1), prev[i], p), term, p)
                nxt.append(term)
            powers.append(tuple(nxt))
        out: list[APoly] = [()] * len(a)
        for i, ai in enumerate(a):
            for k, coeff in enumerate(powers[i]):
                out[k] = poly_add(out[k], tuple(ai * c % p for c in coeff), p)
        return tuple(out)

    def _frobenius_A(self, c: APoly) -> APoly:
        """c(t)^p = c(t^p) in F_p[t]."""
        out = [0] * (self.p * (len(c) - 1) + 1) if c else []
        for i, ci in enumerate(c):
            out[self.p * i] = ci
        return tuple(out)

    def act(self, a: APoly, x: Poly, K: GF, theta: Poly) -> Poly:
        """C_a(x) in the field K, where t acts through theta in K (a root of P for K = F_P or an extension)."""
        total = K.zero
        for i, coeff in enumerate(self.carlitz_polynomial(a)):
            c = K.eval_poly(tuple(K.from_int(ci) for ci in coeff), theta)
            total = K.add(total, K.mul(c, K.pow(x, self.p**i)))
        return total

    def torsion_polynomial_mod(self, m: APoly, K: GF, theta: Poly) -> tuple[Poly, ...]:
        """C_m(x) as an ordinary polynomial over K (coefficients low -> high)."""
        cp = self.carlitz_polynomial(m)
        deg = self.p ** (len(cp) - 1)
        coeffs = [K.zero] * (deg + 1)
        for i, coeff in enumerate(cp):
            coeffs[self.p**i] = K.eval_poly(tuple(K.from_int(ci) for ci in coeff), theta)
        return tuple(coeffs)

    def fermat_carlitz_holds(self, P: APoly) -> bool:
        """C_P(x) ≡ x^{p^{deg P}} (mod P) as p-polynomials with coefficients in A/P."""
        cp = self.carlitz_polynomial(P)
        d = len(P) - 1
        return all(poly_mod(c, P, self.p) == ((1,) if i == d else ()) for i, c in enumerate(cp))


def order_mod(P: APoly, m: APoly, p: int) -> int:
    """Order of P in (A/m)^x (P coprime to m)."""
    one = (1,)
    n, x = 1, poly_mod(P, m, p)
    while x != one:
        x, n = poly_mod(poly_mul(x, P, p), m, p), n + 1
    return n


def annihilator(C: CarlitzModule, lam: Poly, m: APoly, K: GF, theta: Poly) -> APoly:
    """The monic generator of ann(lam) = {a : C_a(lam) = 0}, a divisor of m; found by
    checking all monic divisors of m (m small)."""
    from itertools import product

    best = m
    for deg in range(0, len(m)):
        for low in product(range(C.p), repeat=deg):
            a = tuple(low) + (1,)
            if poly_mod(m, a, C.p) == () and C.act(a, lam, K, theta) == K.zero and deg < len(best) - 1:
                return a
    return best
