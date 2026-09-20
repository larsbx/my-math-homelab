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
# This is the Mojo side of a differential pair; tools/markov.py is the Python
# side, and tests/test_markov.py compares the transcripts.

from finite_exact.bigint_z import BigZ, BIGZ_BASE
from finite_exact.rat_q import Q, q_max


# The budget the Python oracle shares. A `BigZ` limb is base `10^9`, so a
# limb count is a decimal digit count divided by nine and both sides compute
# it exactly; sharing it in limbs is what lets the transcripts be compared.
comptime MARKOV_LIMB_BUDGET = 40


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


def characteristic_polynomial(matrix: List[Int], size: Int) -> List[Q]:
    """Coefficients of `det(x I - A)`, ascending, by Faddeev-LeVerrier.

    Exact over `Q` and monic by construction. The recurrence is
    `M_k = A (M_(k-1) + c_(k-1) I)`, which is `A M_(k-1) + c_(k-1) A`.
    """
    var current = List[Q]()
    for _ in range(size * size):
        current.append(Q.zero())
    var coefficients = List[Q]()
    coefficients.append(Q.one())
    for step in range(1, size + 1):
        var tail = coefficients[len(coefficients) - 1].copy()
        var updated = List[Q]()
        for i in range(size):
            for j in range(size):
                var total = Q.zero()
                for k in range(size):
                    total = total.add(Q.from_int(Int64(matrix[size * i + k])).mul(current[size * k + j]))
                total = total.add(tail.mul(Q.from_int(Int64(matrix[size * i + j]))))
                updated.append(total^)
        current = updated.copy()
        var trace = Q.zero()
        for i in range(size):
            trace = trace.add(current[size * i + i])
        coefficients.append(trace.neg().div(Q.from_int(Int64(step))))
    var out = List[Q]()
    for i in range(len(coefficients)):
        out.append(coefficients[len(coefficients) - 1 - i].copy())
    return out^


def bigz_small(value: BigZ) -> Int:
    """The integer a `BigZ` holds, for transcript rendering only.

    Every quantity this module prints is a small integer; a value too large
    for `Int` would be a bug in the caller, not a case to handle here.
    """
    var magnitude = 0
    for index in range(len(value.limbs)):
        magnitude = magnitude * Int(BIGZ_BASE) + Int(value.limbs[len(value.limbs) - 1 - index])
    return value.sign * magnitude


def q_text(value: Q) -> String:
    if value.rejected:
        return "rejected"
    return String(bigz_small(value.num)) + "/" + String(bigz_small(value.den))


def transcript_line(c: Q, horizon: Int) -> String:
    """One parameter, as the Python oracle prints it too."""
    var line = "c=" + q_text(c)
    var points = postcritical_points(c, horizon, MARKOV_LIMB_BUDGET)
    if len(points) < 2:
        return line + " none"
    line += " points="
    for i in range(len(points)):
        if i > 0:
            line += ","
        line += q_text(points[i])
    var matrix = covering_matrix(c, points)
    var size = len(points) - 1
    line += " matrix="
    for i in range(len(matrix)):
        line += String(matrix[i])
    line += " poly="
    var poly = characteristic_polynomial(matrix, size)
    for i in range(len(poly)):
        if i > 0:
            line += ","
        line += q_text(poly[i])
    return line
