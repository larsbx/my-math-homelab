"""A degree-`n` Pisot screen, exact and fail-closed.

`psc.pisot` decides the Pisot condition for degree three only, and it does so
with a cubic-specific trick: for one real root and one conjugate pair,
`beta * |beta_2|^2 = det`, so the pair sits inside the unit disc exactly when
`chi(det) < 0`. That identity does not generalise, so degree four and above
needs a different method.

The method here works at any degree. Send the unit circle to the imaginary axis
by the Moebius substitution

    z = (1 + w) / (1 - w),      q(w) = (1 - w)^n p((1 + w) / (1 - w)),

under which `|z| < 1` becomes `Re(w) < 0` and `|z| > 1` becomes `Re(w) > 0`.
Then count right-half-plane roots of `q` with a Routh array over exact
rationals. `z = -1` maps to `w = infinity`, which shows up as a degree drop in
`q`, and `z = 1` maps to `w = 0`; both are settled before the array is built.

Every value is a `finite_exact` rational. No floating point is used anywhere,
and the polynomial helpers are shared with `psc.pisot` and the vendored
`finite_linear_algebra.qpoly` (gcd, Cauchy root bound) rather than repeated.

**A refusal is not a negative result, and it is not a positive one either.**
The array is undecided when a first-column entry vanishes or a row terminates
early. Those are the two classical Routh singularities and they do not mean the
same thing. A *vanishing row* is handled here by the auxiliary-derivative rule.
A *first-column zero in a row that is not itself zero* is a different
singularity, with its own classical remedies, and this module implements none
of them: it refuses. Such a refusal says only that this array did not resolve.

So `SCREEN_REFUSED` must not be read either way. `x^3 - 3x^2 - 3x - 3` is
refused here and is nevertheless a genuine Pisot polynomial: its image is
`4w^3 + 12w - 8`, whose second Routh row is `[0, -8]`, while its roots are
3.951... and a conjugate pair of modulus 0.871... . Its real part on the
imaginary axis is the constant `-8`, so it has no axis root at all. That bound
is recorded in the literature gate; see `known_first_column_refusal`.

The literature gate for this diagnostic is
`docs/pisot-screen-literature-gate-2026-09-16.md`; the Python oracle it was
differentially tested against is `reference/psc_research/pisot_screen.py`.
"""

from finite_exact.rat_q import Q
from finite_linear_algebra import qpoly
from finite_linear_algebra.scalar import q_int, q_is_zero
from psc.exact import q_poly, q_sign
from psc.pisot import count_roots_in, poly_degree, poly_eval

comptime SCREEN_PISOT = 1
comptime SCREEN_NOT_PISOT = 0
comptime SCREEN_REFUSED = -1

comptime IRREDUCIBLE = 1
comptime REDUCIBLE = 0
comptime IRREDUCIBILITY_REFUSED = -1

# A count of roots is never negative, so this sentinel cannot be mistaken for
# one. It says the method did not decide, which is neither "none outside" nor
# "a root on the circle": see the module docstring for a refused Pisot case.
comptime ROUTH_UNDECIDED = -1

# Rational-root testing rules out linear factors only, so irreducibility is
# decided here only up to degree three, where no factor can escape it.
comptime MAX_DECIDABLE_IRREDUCIBLE_DEGREE = 3


def int_degree(coeffs: List[Int]) -> Int:
    """Index of the highest non-zero coefficient; `-1` for the zero polynomial.
    Coefficients are low-degree-first throughout this module."""
    for i in range(len(coeffs) - 1, -1, -1):
        if coeffs[i] != 0:
            return i
    return -1


def is_monic_integer(coeffs: List[Int]) -> Bool:
    var n = int_degree(coeffs)
    return n >= 1 and coeffs[n] == 1


def binomial_power(k: Int, sign: Int) -> List[Q]:
    """Coefficients of `(1 + sign * w)^k`, low degree first."""
    var row = List[Q]()
    row.append(Q.one())
    for _ in range(k):
        var nxt = List[Q]()
        for i in range(len(row) + 1):
            var a = Q.zero()
            if i < len(row):
                a = row[i].copy()
            var b = Q.zero()
            if i >= 1:
                b = row[i - 1].mul(q_int(sign))
            nxt.append(a.add(b))
        row = nxt^
    return row^


def halfplane_transform(coeffs: List[Int]) -> List[Q]:
    """`q(w) = (1 - w)^n p((1 + w) / (1 - w))`, low degree first.

    `q` has degree `n` unless `z = -1` is a root of `p`, in which case the
    leading coefficient vanishes and the degree drops."""
    var n = int_degree(coeffs)
    var out = List[Q]()
    for _ in range(n + 1):
        out.append(Q.zero())
    for k in range(n + 1):
        if coeffs[k] == 0:
            continue
        var left = binomial_power(k, 1)
        var right = binomial_power(n - k, -1)
        var c = q_int(coeffs[k])
        for i in range(len(left)):
            for j in range(len(right)):
                out[i + j] = out[i + j].add(c.mul(left[i]).mul(right[j]))
    return out^


def all_zero(row: List[Q]) -> Bool:
    for i in range(len(row)):
        if not q_is_zero(row[i]):
            return False
    return True


def auxiliary_derivative(row: List[Q], top_degree: Int) -> List[Q]:
    """Derivative of the auxiliary polynomial a Routh row stands for.

    A row holds the coefficients of `w^d, w^(d-2), w^(d-4), ...`, so the
    derivative's coefficients in the same stepped layout are those scaled by
    the exponent they carried."""
    var out = List[Q]()
    for i in range(len(row)):
        var power = top_degree - 2 * i
        if power <= 0:
            break
        out.append(row[i].mul(q_int(power)))
    return out^


def routh_right_half_plane_count(q: List[Q]) -> Int:
    """Roots of `q` with `Re(w) > 0`, or `ROUTH_UNDECIDED`.

    Undecided means this array did not resolve, and nothing more. It never
    means zero, and it is not evidence of a root on the imaginary axis: a
    first-column zero in a non-zero row refuses here whether or not `q` has an
    axis root. Use `has_root_on_unit_circle` to decide that question."""
    var n = poly_degree(q)
    if n < 1:
        return ROUTH_UNDECIDED
    var rows = List[List[Q]]()
    var first = List[Q]()
    for i in range(n // 2 + 1):
        first.append(q[n - 2 * i].copy())
    var second = List[Q]()
    for i in range((n - 1) // 2 + 1):
        second.append(q[n - 1 - 2 * i].copy())
    rows.append(first^)
    rows.append(second^)
    while len(rows[len(rows) - 1]) > 0 and len(rows) <= n:
        var above = rows[len(rows) - 2].copy()
        var current = rows[len(rows) - 1].copy()
        if all_zero(current):
            # A vanishing row means `q` has roots placed symmetrically about
            # the origin, which in `z` is a reciprocal pair. The classical
            # remedy is to continue from the derivative of the auxiliary
            # polynomial the row above represents. Without it the array stops
            # and every reciprocal Pisot polynomial, `x^2 - 3x + 1` among them,
            # is refused.
            current = auxiliary_derivative(above, n - (len(rows) - 2))
            if len(current) == 0 or all_zero(current):
                return ROUTH_UNDECIDED
            rows[len(rows) - 1] = current.copy()
        if q_is_zero(current[0]):
            return ROUTH_UNDECIDED       # a first-column zero, not a whole row
        var width = len(above)
        if len(current) > width:
            width = len(current)
        var nxt = List[Q]()
        for i in range(1, width):
            var a = Q.zero()
            if i < len(above):
                a = above[i].copy()
            var b = Q.zero()
            if i < len(current):
                b = current[i].copy()
            nxt.append(current[0].mul(a).sub(above[0].mul(b)).div(current[0]))
        while len(nxt) > 0 and q_is_zero(nxt[len(nxt) - 1]):
            _ = nxt.pop()
        if len(nxt) == 0:
            break
        rows.append(nxt^)
    var column = List[Q]()
    for i in range(len(rows)):
        if len(rows[i]) > 0:
            column.append(rows[i][0].copy())
    if len(column) < n + 1:
        return ROUTH_UNDECIDED           # the array terminated early
    for i in range(len(column)):
        if q_is_zero(column[i]):
            return ROUTH_UNDECIDED
    var count = 0
    for i in range(n):
        if q_sign(column[i]) != q_sign(column[i + 1]):
            count += 1
    return count


def real_root_count(p: List[Q]) -> Int:
    """Distinct real roots, by Sturm counting over the Cauchy bound."""
    if poly_degree(p) < 1:
        return 0
    var bound = qpoly.root_bound(p)
    return count_roots_in(p, bound.neg(), bound)


def has_root_on_unit_circle(coeffs: List[Int]) -> Bool:
    """Whether `p` has a root of absolute value exactly one.

    Such a root disqualifies a Pisot polynomial outright, and the Routh count
    alone cannot see it: once the auxiliary-row rule completes an array, a
    Salem polynomial, whose conjugates lie *on* the circle, counts one root
    outside and reads as Pisot. This is the check that stops that.

    On the imaginary axis `w = iy` the transform splits into real and imaginary
    parts, so a purely imaginary root of `q` is a common real root of the two."""
    var p = q_poly(coeffs)
    if q_is_zero(poly_eval(p, Q.one())):
        return True
    if q_is_zero(poly_eval(p, Q.one().neg())):
        return True
    var q = halfplane_transform(coeffs)
    var real_part = List[Q]()
    var imag_part = List[Q]()
    for _ in range(len(q)):
        real_part.append(Q.zero())
        imag_part.append(Q.zero())
    for k in range(len(q)):
        # w = iy gives i^k = (-1)^(k//2) for even k, and i times that for odd k,
        # so one stepped sign serves both parts.
        var sign = 1
        if (k // 2) % 2 == 1:
            sign = -1
        if k % 2 == 0:
            real_part[k] = q[k].mul(q_int(sign))
        else:
            imag_part[k] = q[k].mul(q_int(sign))
    var shared = qpoly.gcd(real_part, imag_part)
    if poly_degree(shared) < 1:
        return False
    return real_root_count(shared) > 0


def roots_outside_unit_circle(coeffs: List[Int]) -> Int:
    """How many roots of `p` satisfy `|z| > 1`, or `ROUTH_UNDECIDED`.

    Undecided means the count was not established. A root at `z = 1` or
    `z = -1` is one reason; an unresolved Routh singularity is another, and it
    carries no implication about the unit circle."""
    var n = int_degree(coeffs)
    if n < 1:
        return ROUTH_UNDECIDED
    var p = q_poly(coeffs)
    if q_is_zero(poly_eval(p, Q.one())):
        return ROUTH_UNDECIDED           # a root at z = 1
    if q_is_zero(poly_eval(p, Q.one().neg())):
        return ROUTH_UNDECIDED           # a root at z = -1
    return routh_right_half_plane_count(halfplane_transform(coeffs))


def screen(coeffs: List[Int]) -> Int:
    """`SCREEN_PISOT`, `SCREEN_NOT_PISOT`, or `SCREEN_REFUSED`.

    `SCREEN_PISOT` means exactly one root lies outside the closed unit disc,
    that root is real and greater than one, and every other root lies
    *strictly* inside the disc. The last clause is not redundant: a Salem
    polynomial meets the first two and is still answered `SCREEN_NOT_PISOT`,
    on the strength of `has_root_on_unit_circle`, precisely because its
    remaining conjugates sit on the boundary. Note that this is a rejection and
    not a refusal: `SCREEN_REFUSED` is reserved for an array that did not
    resolve, and the two must not be run together in prose either.

    It is a statement about root location, not about irreducibility: use
    `irreducibility` for that, and note that a Pisot *number* is defined by its
    minimal polynomial."""
    if not is_monic_integer(coeffs):
        return SCREEN_REFUSED
    if has_root_on_unit_circle(coeffs):
        return SCREEN_NOT_PISOT          # a conjugate on the circle disqualifies
    var outside = roots_outside_unit_circle(coeffs)
    if outside == ROUTH_UNDECIDED:
        return SCREEN_REFUSED
    if outside != 1:
        return SCREEN_NOT_PISOT
    # The lone root outside is real, since non-real roots come in conjugate
    # pairs of equal absolute value. Every other root satisfies |z| < 1, so the
    # only root in [1, B) is that one, and a sign change across it says it is
    # positive. p(1) is non-zero, or `outside` would have been undecided.
    var p = q_poly(coeffs)
    var low = poly_eval(p, Q.one())
    var high = poly_eval(p, qpoly.root_bound(p))
    if q_sign(low) == q_sign(high):
        return SCREEN_NOT_PISOT          # the outside root is below -1
    return SCREEN_PISOT


def has_rational_root(coeffs: List[Int]) -> Bool:
    """Any degree, exact. A rational root of a monic integer polynomial is an
    integer dividing the constant term."""
    if coeffs[0] == 0:
        return True                      # zero is a root
    var p = q_poly(coeffs)
    var c = abs(coeffs[0])
    var d = 1
    while d * d <= c:
        if c % d == 0:
            var other = c // d
            if q_is_zero(poly_eval(p, q_int(d))):
                return True
            if q_is_zero(poly_eval(p, q_int(-d))):
                return True
            if q_is_zero(poly_eval(p, q_int(other))):
                return True
            if q_is_zero(poly_eval(p, q_int(-other))):
                return True
        d += 1
    return False


def irreducibility(coeffs: List[Int]) -> Int:
    """`IRREDUCIBLE`, `REDUCIBLE`, or `IRREDUCIBILITY_REFUSED` over Q.

    Degree one is irreducible outright. Above that, a rational root settles
    degrees two and three, because a factorisation there must include a linear
    factor. At degree four and above a product of two irreducible quadratics
    has no rational root, so the same test proves nothing and this refuses
    rather than guessing."""
    var n = int_degree(coeffs)
    if not is_monic_integer(coeffs):
        return IRREDUCIBILITY_REFUSED
    if n == 1:
        # Every non-constant linear polynomial is irreducible, and every one
        # also has a rational root, so the test below would call all of them
        # reducible. Degree one has to be settled before asking.
        return IRREDUCIBLE
    if has_rational_root(coeffs):
        return REDUCIBLE
    if n > MAX_DECIDABLE_IRREDUCIBLE_DEGREE:
        return IRREDUCIBILITY_REFUSED
    return IRREDUCIBLE


# --- non-claims -----------------------------------------------------------------


def known_first_column_refusal() -> List[Int]:
    """`x^3 - 3x^2 - 3x - 3`: Pisot, refused, and with no root on the circle.

    Kept as a named witness so the bound is visible from the module rather than
    only from the tests. Its image `4w^3 + 12w - 8` has second Routh row
    `[0, -8]`, a first-column zero this module does not resolve."""
    var c: List[Int] = [-3, -3, -3, 1]
    return c^


def refusal_means_not_pisot() -> Bool:
    """A refusal says the method could not decide, which is a different fact
    from the polynomial not being Pisot."""
    return False


def screen_decides_irreducibility() -> Bool:
    """Root location and irreducibility are independent questions here."""
    return False


def refusal_means_root_on_unit_circle() -> Bool:
    """The converse mistake: a refusal is not evidence of a circle root, so a
    refused specimen must never be recorded as one."""
    return False
