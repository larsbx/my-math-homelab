# markov.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md, section 1.
# Statements and the bridge: docs/tiling-connections-2026-09-20.md.
#
# The real Markov partition of a postcritically finite parameter, and the
# transition matrix it carries. The matrix is the object the substitution and
# tiling kernels of `larsbx/finite-math-kernels` consume -- in the transposed,
# column convention their `Substitution.incidence()` uses, which section 2.3
# of the note records.
#
# Exact over `Q` throughout. Nothing here takes a limit, claims an entropy, or
# measures anything: a matrix entry is a covering, and a covering is decided
# by two rational inequalities.
#
# This is the Mojo side of a differential pair; reference/markov.py is the Python
# side, and tests/test_markov.py compares the transcripts.

from finite_exact.exact_decimal import q_decimal
from finite_exact.rat_q import Q, q_max
from finite_linear_algebra.qpoly import RootBracket, charpoly, largest_root_bracket


# The budget the Python oracle shares. A `BigZ` limb is base `10^9`, so a
# limb count is a decimal digit count divided by nine and both sides compute
# it exactly; sharing it in limbs is what lets the transcripts be compared.
comptime MARKOV_LIMB_BUDGET = 40

# The smoke case's own budgets, kept beside the one they accompany.
comptime MARKOV_SMOKE_HORIZON = 64
comptime MARKOV_SMOKE_STEPS = 256


def coordinate_limbs(value: Q) -> Int:
    var numerator = len(value.num.limbs)
    var denominator = len(value.den.limbs)
    if numerator > denominator:
        return numerator
    return denominator


def escape_threshold(c: Q) -> Q:
    """`max(4, N(c))`, the threshold of docs/escape-criterion.md on the line."""
    return q_max(Q.from_int(4), c.square())


def sorted_points(points: List[Q]) -> List[Q]:
    """Selection sort. The set is the postcritical set, so it is tiny."""
    var used = List[Bool]()
    for _ in range(len(points)):
        used.append(False)
    var out = List[Q]()
    for _ in range(len(points)):
        var best = -1
        for i in range(len(points)):
            if used[i]:
                continue
            if best < 0 or points[i].lt(points[best]):
                best = i
        used[best] = True
        out.append(points[best].copy())
    return out^


def postcritical_points(c: Q, horizon: Int, limb_budget: Int) -> List[Q]:
    """The finite forward orbit of the critical point, sorted, with `0`.

    Empty for every parameter that does not certify a finite orbit: escaping,
    capped, or rejected. Refusing is the whole of the fail-closed rule here,
    and an empty list is the refusal.
    """
    var threshold = escape_threshold(c)
    var seen = List[Q]()
    seen.append(Q.zero())
    var z = Q.zero()
    for _ in range(horizon):
        z = z.square().add(c)
        if not z.accepted():
            return List[Q]()
        if threshold.lt(z.square()):
            return List[Q]()
        for i in range(len(seen)):
            if seen[i].eq(z):
                return sorted_points(seen)
        if coordinate_limbs(z) > limb_budget:
            return List[Q]()
        seen.append(z.copy())
    return List[Q]()


def covering_matrix(c: Q, points: List[Q]) -> List[Int]:
    """`A[i][j] = 1` iff interval `j` is covered by `f(interval i)`, row-major.

    `0` is a partition point, so `f` is monotone on each interval and the
    image is the interval between the endpoint images: note section 2.2.
    """
    var size = len(points) - 1
    var out = List[Int]()
    for i in range(size):
        var left = points[i].square().add(c)
        var right = points[i + 1].square().add(c)
        var lo = left.copy()
        var hi = right.copy()
        if right.lt(left):
            lo = right.copy()
            hi = left.copy()
        for j in range(size):
            if lo.le(points[j]) and points[j + 1].le(hi):
                out.append(1)
            else:
                out.append(0)
    return out^


def rational_matrix(matrix: List[Int], size: Int) -> List[List[Q]]:
    """The flat `0/1` covering matrix as rows over `Q`, for the kernels."""
    var out = List[List[Q]]()
    for i in range(size):
        var row = List[Q]()
        for j in range(size):
            row.append(Q.from_int(Int64(matrix[size * i + j])))
        out.append(row^)
    return out^


def transition_polynomial(matrix: List[Int], size: Int) -> List[Q]:
    """`det(x I - A)`, ascending, from the vendored `finite_linear_algebra`.

    This module carried its own Faddeev-LeVerrier until the kernels grew one
    that works in every dimension; `docs/tiling-connections-2026-09-20.md`,
    section 7, called keeping it here the wrong place for it.
    """
    return charpoly(rational_matrix(matrix, size))


def growth_bracket(matrix: List[Int], size: Int, width: Q, max_steps: Int) -> RootBracket:
    """An isolating bracket of the largest real root of `det(x I - A)`.

    The upstream routine isolates the largest root by a Sturm chain; the
    Python oracle's `growth_bracket` bisects a sign change and lands on some
    root. They answer different questions, so this one is not in the
    transcript the two compare: `tests/test_markov.py` checks each against the
    root it is supposed to bracket instead.
    """
    return largest_root_bracket(transition_polynomial(matrix, size), width, max_steps)


def transcript_line(c: Q, horizon: Int) -> String:
    """One parameter, as the Python oracle prints it too."""
    var line = "c=" + q_decimal(c)
    var points = postcritical_points(c, horizon, MARKOV_LIMB_BUDGET)
    if len(points) < 2:
        return line + " none"
    line += " points="
    for i in range(len(points)):
        if i > 0:
            line += ","
        line += q_decimal(points[i])
    var matrix = covering_matrix(c, points)
    var size = len(points) - 1
    line += " matrix="
    for i in range(len(matrix)):
        line += String(matrix[i])
    line += " poly="
    var poly = transition_polynomial(matrix, size)
    for i in range(len(poly)):
        if i > 0:
            line += ","
        line += q_decimal(poly[i])
    return line


def markov_smoke() -> Bool:
    """The two transition matrices the parameter domain supplies, and the
    root each of them brackets.

    The bracket comes from the vendored `finite_linear_algebra/qpoly.mojo`,
    so this case is also the check that the vendored package works here. It
    asserts a bracket, never a Pisot verdict: section 6 of
    `docs/tiling-connections-2026-09-20.md` reads `2` as a trivial one, and
    nothing in this repository computes that.
    """
    var width = Q(1, 1 << 20)
    var chebyshev = postcritical_points(Q(-2, 1), MARKOV_SMOKE_HORIZON, MARKOV_LIMB_BUDGET)
    if len(chebyshev) != 3:
        return False
    var pair = covering_matrix(Q(-2, 1), chebyshev)
    if len(pair) != 4:
        return False
    for i in range(len(pair)):
        if pair[i] != 1:
            return False
    var two = Q(2, 1)
    var bracket = growth_bracket(pair, 2, width, MARKOV_SMOKE_STEPS)
    if not bracket.found or not (bracket.lo.le(two) and two.le(bracket.hi)):
        return False
    var basilica = postcritical_points(Q(-1, 1), MARKOV_SMOKE_HORIZON, MARKOV_LIMB_BUDGET)
    if len(basilica) != 2:
        return False
    var single = covering_matrix(Q(-1, 1), basilica)
    var root = growth_bracket(single, 1, width, MARKOV_SMOKE_STEPS)
    return root.found and root.exact and root.lo.eq(Q.one())
