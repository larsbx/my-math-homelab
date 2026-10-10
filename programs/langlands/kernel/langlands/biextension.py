"""Branch 1: the Poincaré biextension of 37a1 in the monic Miller frame, over Q, exactly.

E: y^2 + y = x^3 - x (37a1, minimal model), P0 = (0, 0) generates E(Q).  Uniformiser t = x/y at O:
x = t^-2(1 + O(t)), y = t^-3(1 + O(t)), so the chord y - lam x - nu (ord -3), the vertical x - x0
(ord -2) and the Miller function g_{A,B} = chord / vertical (ord -1) all have t-leading coefficient 1
("tame-monic").  With every piece monic, the regularised value at O is the leading coefficient, 1.

Factor systems in the frame s of P^x over E x E^v = E x E (principal polarisation):
    first law   kappa(c; a1, a2)  = g_{a1,a2}(c)
    second law  kappa'_a(c1, c2)  = g_{c1,c2}(a)            (the naive swap)
Exchange compares the two ways of combining the four fibres over (a_i, c_j); by tame Weil reciprocity
for f = g_{a1,a2}, h = g_{c1,c2} (divisors meeting only at O) the naive pair misses it by the Deligne
sign (-1)^{ord_O f * ord_O h} (Law B).  ord_O g_{a,b} is -1 on the generic stratum (a, b, a+b != O),
-2 on the vertical one (a + b = O != a) and 0 when an argument is O, so its parity is the coboundary of
u(a) = [a != O]; the second law in the frame s is therefore
    beta_2:  kappa''_a(c1, c2) = (-1)^{u(a) * du(c1, c2)} * g_{c1,c2}(a),
a rigidified symmetric-coboundary twist that cancels the sign on every stratum (`BiextensionSign.lean`
proves the sign algebra for any group).  No frame change can do this: the exchange defect is
frame-invariant.

Over F_q (`FF`, `over`): the m-fold first law against the m-fold strict second law along a Miller chain
is the Weil pairing e_m on the nose (the naive swap is off by (-1)^m, `chain_order`), and through it
E^v(F_q)[ell] parametrises the order-ell characters of Pic^0(F_q): chi_c(x) = e_ell(Frob y - y, c) with
ell y = x, the Frobenius eigenvalue of the [ell]-cover local system with character e_ell(., c).
"""
from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction

from .gf import GF, Poly

Point = tuple | None  # (x, y) over Q (Fraction) or F_{p^k} (FF); None = O


@dataclass(frozen=True)
class FF:
    """An element of F_{p^k} = GF(p, k) with arithmetic operators, so that `Weierstrass` runs unchanged
    over finite fields (integers coerce through the prime field)."""

    K: GF
    v: Poly

    def _c(self, o) -> "FF":
        if isinstance(o, FF):
            if o.K != self.K:
                raise ValueError("operands from different finite fields")
            return o
        return FF(self.K, self.K.from_int(o))

    def __add__(self, o): return FF(self.K, self.K.add(self.v, self._c(o).v))  # noqa: E704
    __radd__ = __add__
    def __sub__(self, o): return FF(self.K, self.K.sub(self.v, self._c(o).v))  # noqa: E704
    def __rsub__(self, o): return self._c(o) - self  # noqa: E704
    def __neg__(self): return FF(self.K, self.K.neg(self.v))  # noqa: E704
    def __mul__(self, o): return FF(self.K, self.K.mul(self.v, self._c(o).v))  # noqa: E704
    __rmul__ = __mul__

    def __truediv__(self, o):
        o = self._c(o)
        if o.v == self.K.zero:
            raise ZeroDivisionError("division by zero in F_q")
        return FF(self.K, self.K.div(self.v, o.v))

    def __pow__(self, e: int):
        return FF(self.K, self.K.pow(self.v, e)) if e >= 0 else FF(self.K, self.K.one) / FF(self.K, self.K.pow(self.v, -e))

    def __eq__(self, o):
        if isinstance(o, FF):
            return self.K == o.K and self.v == o.v
        return isinstance(o, int) and self.v == self._c(o).v

    def __hash__(self):
        return hash((self.K.p, self.K.k, self.v))

    def frobenius(self, power: int = 1) -> "FF":
        return FF(self.K, self.K.frobenius(self.v, power))


@dataclass(frozen=True)
class Weierstrass:
    """y^2 + a1 xy + a3 y = x^3 + a2 x^2 + a4 x + a6 over Q."""

    a1: Fraction
    a2: Fraction
    a3: Fraction
    a4: Fraction
    a6: Fraction

    def on_curve(self, P: Point) -> bool:
        if P is None:
            return True
        x, y = P
        return y * y + self.a1 * x * y + self.a3 * y == x**3 + self.a2 * x * x + self.a4 * x + self.a6

    def neg(self, P: Point) -> Point:
        return None if P is None else (P[0], -P[1] - self.a1 * P[0] - self.a3)

    def slope(self, P: Point, Q: Point) -> tuple[Fraction, Fraction] | None:
        """(lam, nu) of the chord/tangent through P, Q (both finite, Q != -P); None if vertical."""
        (x1, y1), (x2, y2) = P, Q
        if x1 != x2:
            lam = (y2 - y1) / (x2 - x1)
        elif y1 == y2 and 2 * y1 + self.a1 * x1 + self.a3 != 0:
            lam = (3 * x1 * x1 + 2 * self.a2 * x1 + self.a4 - self.a1 * y1) / (2 * y1 + self.a1 * x1 + self.a3)
        else:
            return None
        return lam, y1 - lam * x1

    def add(self, P: Point, Q: Point) -> Point:
        if P is None:
            return Q
        if Q is None:
            return P
        line = self.slope(P, Q)
        if line is None:
            return None
        lam, nu = line
        x3 = lam * lam + self.a1 * lam - self.a2 - P[0] - Q[0]
        return self.neg((x3, lam * x3 + nu))

    def mul(self, n: int, P: Point) -> Point:
        R, B = None, (P if n >= 0 else self.neg(P))
        for _ in range(abs(n)):
            R = self.add(R, B)
        return R

    # ------------------------------------------------------ Miller functions --
    def ord_O(self, A: Point, B: Point) -> int:
        """ord_O g_{A,B}: -1 generic, -2 vertical (A + B = O != A), 0 if A or B is O."""
        if A is None or B is None:
            return 0
        return -2 if self.add(A, B) is None else -1

    @property
    def one(self):
        return self.a1**0

    def miller(self, A: Point, B: Point, c: Point):
        """g_{A,B}(c), div g = (A) + (B) - (A+B) - (O), tame-monic at O; g(O) = 1 (regularised).
        Raises ZeroDivisionError when c lies on the support (the value is 0 or oo there)."""
        if A is None or B is None or c is None:
            return self.one
        x, y = c
        line = self.slope(A, B)
        if line is None:  # A + B = O: g = x - x_A
            v = x - A[0]
            if v == 0:
                raise ZeroDivisionError("c on the support of the vertical")
            return v
        lam, nu = line
        num = y - lam * x - nu
        den = x - self.add(A, B)[0]
        if num == 0 and den == 0 and c != self.add(A, B):
            # c = -(A+B), the third point of the chord: a common simple zero, not in div g.  On E,
            # chord * conjugate chord = -(x - x_A)(x - x_B)(x - x_{A+B}), so g = -(x - x_A)(x - x_B) / chord^sigma
            # with chord^sigma(x, y) = chord(x, -y - a1 x - a3), nonzero at c.
            conj = -y - self.a1 * x - self.a3 - lam * x - nu
            return -(x - A[0]) * (x - B[0]) / conj
        if num == 0 or den == 0:
            raise ZeroDivisionError("c on the support of the chord or vertical")
        return num / den


E37A = Weierstrass(*map(Fraction, (0, 0, 1, -1, 0)))
P0: Point = (Fraction(0), Fraction(0))


def u(P: Point) -> int:
    return 0 if P is None else 1


def du(E: Weierstrass, a: Point, b: Point) -> int:
    """(u(a) + u(b) + u(a+b)) mod 2: 1 exactly on the generic stratum."""
    return (u(a) + u(b) + u(E.add(a, b))) % 2


# ------------------------------------------------------------ the two laws --
def first_law(E: Weierstrass, c: Point, a1: Point, a2: Point) -> Fraction:
    return E.miller(a1, a2, c)


def second_law_naive(E: Weierstrass, a: Point, c1: Point, c2: Point) -> Fraction:
    return E.miller(c1, c2, a)


def second_law(E: Weierstrass, a: Point, c1: Point, c2: Point) -> Fraction:
    """beta_2 in the frame s: the naive swap twisted by (-1)^{u(a) du(c1, c2)}."""
    return (-1) ** (u(a) * du(E, c1, c2)) * second_law_naive(E, a, c1, c2)


def exchange_ratio(E: Weierstrass, a1: Point, a2: Point, c1: Point, c2: Point, second=second_law) -> Fraction:
    """[beta_1 at c1, c2 then beta_2 at a1+a2] / [beta_2 at a1, a2 then beta_1 at c1+c2]; 1 iff exchange holds."""
    lhs = first_law(E, c1, a1, a2) * first_law(E, c2, a1, a2) * second(E, E.add(a1, a2), c1, c2)
    rhs = second(E, a1, c1, c2) * second(E, a2, c1, c2) * first_law(E, E.add(c1, c2), a1, a2)
    return lhs / rhs


def deligne_sign(E: Weierstrass, a1: Point, a2: Point, c1: Point, c2: Point) -> int:
    """(-1)^{ord_O g_{a1,a2} * ord_O g_{c1,c2}}: the tame symbol at O of two monic functions."""
    return (-1) ** (E.ord_O(a1, a2) * E.ord_O(c1, c2))


# ------------------------------------------------------------- over F_q --
def over(E: Weierstrass, K: GF) -> Weierstrass:
    """The reduction of an integral model to K (coefficients through the prime field)."""
    return Weierstrass(*(FF(K, K.from_int(int(a))) for a in (E.a1, E.a2, E.a3, E.a4, E.a6)))


def points(E: Weierstrass) -> tuple[Point, ...]:
    """E(K) for odd characteristic: y^2 + (a1 x + a3) y = rhs(x) solved by completing the square."""
    K = E.a1.K
    out: list[Point] = [None]
    for xv in K.elements():
        x = FF(K, xv)
        b = E.a1 * x + E.a3
        disc = b * b + 4 * (x**3 + E.a2 * x * x + E.a4 * x + E.a6)
        out += [(x, (FF(K, r) - b) / 2) for r in K.sqrts(disc.v)]
    return tuple(out)


def frobenius(P: Point, power: int = 1) -> Point:
    return None if P is None else (P[0].frobenius(power), P[1].frobenius(power))


def to_short(P: Point) -> Point:
    """37a1: (x, y) -> (36 x, 108 (2y + 1)), the isomorphism onto y^2 = x^3 - 1296 x + 11664 (p > 3)."""
    return None if P is None else (36 * P[0], 108 * (2 * P[1] + 1))


def from_short(P: Point) -> Point:
    return None if P is None else (P[0] / 36, (P[1] / 108 - 1) / 2)


def commutator_pairing(E: Weierstrass, m: int, P: Point, Q: Point, second=second_law):
    """prod_{i<m} beta_1(Q; iP, P) / prod_{i<m} beta_2(P; iQ, Q): the m-fold first law against the m-fold
    second law, i.e. f_{m,P}(Q) / (+-f_{m,Q}(P)) with monic Miller functions.  For the strict beta_2 this
    is the Weil pairing e_m(P, Q); the naive swap is off by (-1)^m (Law B over the m - 2 generic steps).
    P, Q in E[m] with Q off the supports (Q not in <P>)."""
    num, den, A, B = E.one, E.one, P, Q
    for _ in range(1, m):
        num, A = num * first_law(E, Q, A, P), E.add(A, P)
        den, B = den * second(E, P, B, Q), E.add(B, Q)
    return num / den


def weil(E: Weierstrass, m: int, P: Point, Q: Point):
    """e_m(P, Q) as the strict commutator, extended by e = 1 on dependent pairs (alternating)."""
    span = {E.mul(i, P) for i in range(m)}
    return E.one if Q in span else commutator_pairing(E, m, P, Q)


def dual_character(E: Weierstrass, ell: int, c: Point, fibre: tuple[Point, ...]):
    """chi_c(x) = e_ell(Frob(y) - y, c) for y in the fibre {y : ell y = x}: the Frobenius eigenvalue of
    the [ell]-cover local system with character e_ell(., c) at the rational point x.  Returns the set of
    values over the fibre (a singleton iff chi_c(x) is well defined)."""
    return {weil(E, ell, E.add(frobenius(y), E.neg(y)), c) for y in fibre}


# ------------------------------------------------------------ elliptic nets --
def ward_eds(E: Weierstrass, P: Point, n_max: int) -> dict[int, Fraction]:
    """W_n = psi_n(P) for |n| <= n_max (W_{-n} = -W_n): division polynomials at P for n <= 4, then
    W_{2m+1} = W_{m+2} W_m^3 - W_{m-1} W_{m+1}^3 and W_{2m} = (W_{m+2} W_{m-1}^2 - W_{m-2} W_{m+1}^2) W_m / W_2."""
    a1, a2, a3, a4, a6 = E.a1, E.a2, E.a3, E.a4, E.a6
    x, y = P
    b2, b4, b6 = a1 * a1 + 4 * a2, 2 * a4 + a1 * a3, a3 * a3 + 4 * a6
    b8 = a1 * a1 * a6 + 4 * a2 * a6 - a1 * a3 * a4 + a2 * a3 * a3 - a4 * a4
    W = {0: 0 * x, 1: x**0, 2: 2 * y + a1 * x + a3, 3: 3 * x**4 + b2 * x**3 + 3 * b4 * x**2 + 3 * b6 * x + b8}
    W[4] = W[2] * (2 * x**6 + b2 * x**5 + 5 * b4 * x**4 + 10 * b6 * x**3 + 10 * b8 * x**2
                   + (b2 * b8 - b4 * b6) * x + (b4 * b8 - b6 * b6))
    for n in range(5, n_max + 1):
        m = n // 2
        W[n] = (W[m + 2] * W[m] ** 3 - W[m - 1] * W[m + 1] ** 3 if n % 2
                else (W[m + 2] * W[m - 1] ** 2 - W[m - 2] * W[m + 1] ** 2) * W[m] / W[2])
    return {**W, **{-n: -W[n] for n in range(1, n_max + 1)}}


def kappa_eds(W: dict[int, Fraction], k: int, m: int, n: int) -> Fraction:
    """Closed form of kappa_tame(kP; mP, nP) = g_{mP,nP}(kP) on the rank-1 net of P:
    generic stratum (m, n, m+n != 0): -W_{k-m} W_{k-n} W_{m+n} / (W_{k-m-n} W_k W_m W_n);
    vertical (m + n = 0 != m): x(kP) - x(mP) = -W_{k+m} W_{k-m} / (W_k^2 W_m^2).
    The sigma-function factorisation g_{u,v}(z) = sigma(z-u) sigma(z-v) sigma(u+v) / (sigma(z-u-v) sigma(z)
    sigma(u) sigma(v)) with W_j = sigma(ju)/sigma(u)^{j^2} (the sigma(u)-exponents cancel), and the sign
    -1 = (t/z)^{ord_O} with t = x/y ~ -z at O, is the derivation (IMPORTED); the identity is measured."""
    if m + n == 0:
        return -W[k + m] * W[k - m] / (W[k] ** 2 * W[m] ** 2)
    return -W[k - m] * W[k - n] * W[m + n] / (W[k - m - n] * W[k] * W[m] * W[n])


def miller_chain_eds(W: dict[int, Fraction], N: int, k: int) -> Fraction:
    """f_{N,P}(kP) = prod_{i<N} g_{iP,P}(kP), telescoped: (-1)^{N-1} W_N W_{k-1}^N / (W_{k-N} W_k^{N-1})."""
    return (-1) ** (N - 1) * W[N] * W[k - 1] ** N / (W[k - N] * W[k] ** (N - 1))
