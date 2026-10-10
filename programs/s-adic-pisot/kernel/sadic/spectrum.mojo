"""Exact spectral certificates for integer matrices and monic integer polynomials.

Polynomials are `List[Int]`, lowest degree first; all arithmetic is checked
and an overflow raises (inconclusive, never a wrong verdict). Specification
and proofs: docs/sadic-kernel-g2-spectrum.md.

- `charpoly`: `det(zI - M)` by Faddeev-LeVerrier; every division is exact.
- `disc_zero_count`: zeros in the open unit disc by the Schur-Cohn reduction,
  in arbitrary-precision integers (`finite_exact.bigint_z`)
  `Tp = p(0) p - a_n p*`, with `p*(z) = z^n p(1/z)` (Rouche on the circle,
  where `|p*| = |p|`). A degenerate step `|p(0)| = |a_n|` is removed, exactly,
  by multiplying by `2z - 1` (one more zero in the disc). Zeros on the circle
  and reciprocal pairs are common zeros of `p` and `p*`, survive every step,
  and make the count raise.
- `pisot_verdict`: one root outside the closed disc, the rest inside the open
  disc, for a monic irreducible polynomial; reciprocal polynomials by Lemma R.
- `irreducibility_verdict`: a monic integer factor refutes (rational roots
  first); degree <= 3 without a root is irreducible; otherwise the least prime
  `p < 200` with `f mod p` irreducible (Rabin's test) certifies
  irreducibility over Q, and failing that an exhaustive search for monic
  factors of degree 2..d/2, bounded by Fujiwara's root bound, decides; a
  search beyond its budget is inconclusive.

Reference oracle: `reference/sadic_reference/spectrum.py` (independent
algorithms: interpolation, a Routh array on the Cayley transform,
enumeration of monic divisors mod p, and Kronecker's factor search).
"""

from finite_exact.bigint_z import BigZ, bigz_add, bigz_div_exact, bigz_from_i64, bigz_gcd, bigz_mul, bigz_neg, bigz_sub, bigz_zero
from finite_exact.checked_int import checked_add, checked_mul, checked_neg, checked_sub
from sadic.cocycle import matmul

comptime FACTOR_SEARCH_BUDGET = 20_000_000
comptime SCHUR_COHN_BUDGET = 64
comptime PRIME_LIMIT = 200


def charpoly(m: List[Int], d: Int) raises -> List[Int]:
    """`det(zI - M)`, lowest degree first, monic."""
    if len(m) != d * d:
        raise Error("charpoly needs a d x d matrix")
    var coeffs = List[Int]()
    for _ in range(d + 1):
        coeffs.append(0)
    coeffs[d] = 1
    var mk = List[Int]()
    for _ in range(d * d):
        mk.append(0)
    for k in range(1, d + 1):
        # M_k = A M_{k-1} + c_{d-k+1} I ; c_{d-k} = -tr(A M_k) / k
        var next = matmul(m, mk, d)
        for i in range(d):
            next[i * d + i] = checked_add(next[i * d + i], coeffs[d - k + 1])
        mk = next^
        var am = matmul(m, mk, d)
        var trace = 0
        for i in range(d):
            trace = checked_add(trace, am[i * d + i])
        if trace % k != 0:
            raise Error("Faddeev-LeVerrier division is not exact")
        coeffs[d - k] = checked_neg(trace // k)
    return coeffs^


def _big_trim(p: List[BigZ]) -> List[BigZ]:
    var out = p.copy()
    while len(out) > 1 and out[len(out) - 1].is_zero():
        _ = out.pop()
    return out^


def _big_primitive(p: List[BigZ]) raises -> List[BigZ]:
    var g = bigz_zero()
    for c in p:
        g = bigz_gcd(g, c)
    if g.is_zero():
        return p.copy()
    var out = List[BigZ]()
    for c in p:
        var q = bigz_div_exact(c, g)
        if q.rejected:
            raise Error("content division is not exact")
        out.append(q.quotient.copy())
    return out^


def _disc_count(p0: List[BigZ], budget: Int) raises -> Int:
    if budget <= 0:
        raise Error("Schur-Cohn budget exhausted: inconclusive")
    var p = _big_trim(p0)
    var extra = 0
    while len(p) > 1 and p[0].is_zero():
        # a zero at the origin lies in the disc
        extra += 1
        var tail = List[BigZ]()
        for i in range(1, len(p)):
            tail.append(p[i].copy())
        p = tail^
    var n = len(p) - 1
    if n == 0:
        if p[0].is_zero():
            raise Error("zero polynomial: inconclusive")
        return extra
    var a0 = p[0].copy()
    var an = p[n].copy()
    var gamma = bigz_sub(bigz_mul(a0, a0), bigz_mul(an, an)).sign
    if gamma == 0:
        # (2z - 1) p has the extra zero 1/2 and |q(0)| != |q_lead|
        var q = List[BigZ]()
        q.append(bigz_neg(p[0]))
        for i in range(1, n + 1):
            q.append(bigz_sub(bigz_add(p[i - 1], p[i - 1]), p[i]))
        q.append(bigz_add(p[n], p[n]))
        return extra + _disc_count(q, budget - 1) - 1
    var t = List[BigZ]()
    for i in range(n + 1):
        t.append(bigz_sub(bigz_mul(a0, p[i]), bigz_mul(an, p[n - i])))
    t = _big_primitive(_big_trim(t))
    if len(t) == 1 and t[0].is_zero():
        raise Error("Schur-Cohn transform vanishes: inconclusive")
    var z = _disc_count(t, budget - 1)
    # |a_n| > |a_0|: Tp has the zeros of p* in the disc, n - Z(p) of them
    return extra + (n - z if gamma < 0 else z)


def disc_zero_count(p: List[Int]) raises -> Int:
    """Zeros of p in the open unit disc; raises when inconclusive. The
    recursion runs on arbitrary-precision integers: its coefficients grow
    quadratically per step before the content division."""
    var big = List[BigZ]()
    for c in p:
        big.append(bigz_from_i64(Int64(c)))
    return _disc_count(big, SCHUR_COHN_BUDGET)


def is_reciprocal(p: List[Int]) -> Bool:
    var n = len(p) - 1
    var plus = True
    var minus = True
    for i in range(n + 1):
        if p[i] != p[n - i]:
            plus = False
        if p[i] != -p[n - i]:
            minus = False
    return plus or minus


def pisot_verdict(p: List[Int]) -> Int:
    """1 certified Pisot, 0 certified not, -1 inconclusive; p monic and
    irreducible over Q."""
    var d = len(p) - 1
    if is_reciprocal(p):
        if d >= 3:
            return 0
        if d == 2:
            var t = p[1] if p[1] >= 0 else -p[1]
            return 1 if p[0] == 1 and t > 2 else 0
    try:
        return 1 if disc_zero_count(p) == d - 1 else 0
    except:
        return -1


# --- irreducibility -------------------------------------------------------


@fieldwise_init
struct IrreducibilityVerdict(Copyable, Movable):
    """`verdict` 1 with `witness` the certifying prime (0: by excluding rational
    roots, degree <= 3); 0 with `witness` an integer root; -1 inconclusive."""

    var verdict: Int
    var witness: Int


def _eval(p: List[Int], x: Int) raises -> Int:
    var acc = 0
    for i in range(len(p) - 1, -1, -1):
        acc = checked_add(checked_mul(acc, x), p[i])
    return acc


def _mod(a: Int, p: Int) -> Int:
    var r = a % p
    return r + p if r < 0 else r


def _reduce(a: List[Int], f: List[Int], p: Int) -> List[Int]:
    """`a mod (f, p)` for monic f."""
    var r = List[Int]()
    for c in a:
        r.append(_mod(c, p))
    var df = len(f) - 1
    while len(r) > df:
        var c = r[len(r) - 1]
        var shift = len(r) - 1 - df
        for i in range(df + 1):
            r[shift + i] = _mod(r[shift + i] - c * f[i], p)
        _ = r.pop()
    while len(r) > 1 and r[len(r) - 1] == 0:
        _ = r.pop()
    return r^


def _mulmod(a: List[Int], b: List[Int], f: List[Int], p: Int) -> List[Int]:
    var out = List[Int]()
    for _ in range(len(a) + len(b) - 1):
        out.append(0)
    for i in range(len(a)):
        for j in range(len(b)):
            out[i + j] = (out[i + j] + a[i] * b[j]) % p
    return _reduce(out, f, p)


def _powmod(a: List[Int], e: Int, f: List[Int], p: Int) -> List[Int]:
    var result: List[Int] = [1]
    var base = a.copy()
    var k = e
    while k > 0:
        if k % 2 == 1:
            result = _mulmod(result, base, f, p)
        base = _mulmod(base, base, f, p)
        k //= 2
    return result^


def _frobenius_power(f: List[Int], p: Int, k: Int) -> List[Int]:
    """`x^(p^k) mod (f, p)`."""
    var g: List[Int] = [0, 1]
    g = _reduce(g, f, p)
    for _ in range(k):
        g = _powmod(g, p, f, p)
    return g^


def _is_zero(a: List[Int]) -> Bool:
    for c in a:
        if c != 0:
            return False
    return True


def _gcd_degree(a0: List[Int], b0: List[Int], p: Int) -> Int:
    """Degree of `gcd(a, b)` over F_p (-1 for the zero polynomial)."""
    var a = a0.copy()
    var b = b0.copy()
    while not _is_zero(b):
        # a mod b, b not necessarily monic
        var lead = b[len(b) - 1]
        var inv = 1
        var e = p - 2
        var base = lead
        while e > 0:
            if e % 2 == 1:
                inv = inv * base % p
            base = base * base % p
            e //= 2
        var mb = List[Int]()
        for c in b:
            mb.append(c * inv % p)
        var r = _reduce(a, mb, p)
        a = b^
        b = r^
    while len(a) > 1 and a[len(a) - 1] == 0:
        _ = a.pop()
    return -1 if _is_zero(a) else len(a) - 1


def _x_minus(g: List[Int], p: Int) -> List[Int]:
    var out = g.copy()
    while len(out) < 2:
        out.append(0)
    out[1] = _mod(out[1] - 1, p)
    while len(out) > 1 and out[len(out) - 1] == 0:
        _ = out.pop()
    return out^


def irreducible_mod(f: List[Int], p: Int) -> Bool:
    """Rabin's test for a monic f over F_p."""
    var fp = List[Int]()
    for c in f:
        fp.append(_mod(c, p))
    var d = len(f) - 1
    if not _is_zero(_x_minus(_frobenius_power(fp, p, d), p)):
        return False
    for q in range(2, d + 1):
        if d % q != 0:
            continue
        var prime = True
        for r in range(2, q):
            if q % r == 0:
                prime = False
        if prime and _gcd_degree(fp, _x_minus(_frobenius_power(fp, p, d // q), p), p) != 0:
            return False
    return True


def _iroot_ceil(n: Int, k: Int) raises -> Int:
    """Least r >= 0 with r^k >= n, for n >= 0."""
    var r = 0
    while True:
        var power = 1
        for _ in range(k):
            power = checked_mul(power, r)
        if power >= n:
            return r
        r += 1


def fujiwara_bound(f: List[Int]) raises -> Int:
    """An integer F >= 1 with |z| <= F for every root z of the monic f:
    `2 max_i ceil(|f[d-i]|^(1/i))` (Fujiwara 1916, with |a_0| for |a_0|/2)."""
    var d = len(f) - 1
    var best = 0
    for i in range(1, d + 1):
        var c = f[d - i]
        best = max(best, _iroot_ceil(c if c >= 0 else -c, i))
    return max(1, checked_mul(2, best))


def _divides(f: List[Int], g: List[Int]) raises -> Bool:
    """Whether the monic g divides f over Z."""
    var r = f.copy()
    var dg = len(g) - 1
    while len(r) - 1 >= dg:
        var c = r[len(r) - 1]
        var shift = len(r) - 1 - dg
        for i in range(dg + 1):
            r[shift + i] = checked_sub(r[shift + i], checked_mul(c, g[i]))
        _ = r.pop()
    for x in r:
        if x != 0:
            return False
    return True


def _binomial(n: Int, k: Int) -> Int:
    var out = 1
    for i in range(k):
        out = out * (n - i) // (i + 1)
    return out


def _factor_search(f: List[Int], k: Int, bound: Int) raises -> Int:
    """1 when f has a monic integer factor of degree k, 0 when it has none,
    -1 when the search space exceeds FACTOR_SEARCH_BUDGET. A root of a factor
    is a root of f, so |e_j| <= C(k, j) bound^j bounds the coefficient
    `g[k-j] = (-1)^j e_j`; the constant term divides f(0)."""
    var c0 = f[0] if f[0] >= 0 else -f[0]
    var top = 1
    for _ in range(k):
        top = checked_mul(top, bound)
    var constants = List[Int]()
    for q in range(1, min(c0, top) + 1):
        if c0 % q == 0:
            constants.append(q)
            constants.append(-q)
    var limits = List[Int]()
    var size = len(constants)
    for j in range(1, k):
        var lim = _binomial(k, k - j)
        for _ in range(k - j):
            lim = checked_mul(lim, bound)
        limits.append(lim)
        size = checked_mul(size, checked_add(checked_mul(2, lim), 1))
        if size > FACTOR_SEARCH_BUDGET:
            return -1
    var f1 = _eval(f, 1)
    var fm1 = _eval(f, -1)
    # odometer over g[1..k-1], each in [-lim, lim]
    var g = List[Int]()
    for _ in range(k + 1):
        g.append(0)
    g[k] = 1
    for c in constants:
        g[0] = c
        for j in range(1, k):
            g[j] = -limits[j - 1]
        while True:
            var g1 = _eval(g, 1)
            var gm1 = _eval(g, -1)
            if g1 != 0 and gm1 != 0 and f1 % g1 == 0 and fm1 % gm1 == 0 and _divides(f, g):
                return 1
            var j = 1
            while j < k and g[j] == limits[j - 1]:
                g[j] = -limits[j - 1]
                j += 1
            if j >= k:
                break
            g[j] += 1
    return 0


def irreducibility_verdict(f: List[Int]) raises -> IrreducibilityVerdict:
    """f monic of degree d >= 1. `verdict` 0 with `witness` the least degree of
    a monic integer factor; 1 with `witness` a certifying prime, or 0 when
    every factor of degree <= d/2 is excluded; -1 inconclusive."""
    var d = len(f) - 1
    if d >= 2:
        if f[0] == 0:
            return IrreducibilityVerdict(0, 1)
        var c0 = f[0] if f[0] > 0 else -f[0]
        var bound = fujiwara_bound(f)
        for k in range(1, min(c0, bound) + 1):
            if c0 % k != 0:
                continue
            for r in [-k, k]:
                if _eval(f, r) == 0:
                    return IrreducibilityVerdict(0, 1)
    if d <= 3:
        return IrreducibilityVerdict(1, 0)
    for p in range(2, PRIME_LIMIT):
        var prime = True
        for r in range(2, p):
            if r * r > p:
                break
            if p % r == 0:
                prime = False
        if prime and irreducible_mod(f, p):
            return IrreducibilityVerdict(1, p)
    var bound = fujiwara_bound(f)
    for k in range(2, d // 2 + 1):
        var found = _factor_search(f, k, bound)
        if found == 1:
            return IrreducibilityVerdict(0, k)
        if found == -1:
            return IrreducibilityVerdict(-1, 0)
    return IrreducibilityVerdict(1, 0)
