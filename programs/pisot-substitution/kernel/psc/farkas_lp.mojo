"""Exact rational infeasibility of `c + A x >= 0, x >= 0`, with a checked
Farkas certificate.

docs/p1a-a1-prime-2026-10-05.md §3m. Fourier-Motzkin (the guided cover's
`fm_infeasible`) is capped and gives up on the lifted regions of the q-lift,
whose envelopes hold some 30 to 70 forms over a dozen variables. Here a
phase-1 simplex over `finite_exact.Q` (Bland's rule, so it cannot cycle)
searches for a multiplier vector `y`, and nothing is concluded from the
search itself: `farkas_refutes` checks in exact arithmetic that `y >= 0`,
`y^T A <= 0` coefficientwise and `y^T c < 0`. Then every `x >= 0` gives
`0 <= sum_i y_i (c_i + A_i x) <= y^T c < 0`, so the system has no rational
point. A simplex that reports infeasible with a certificate that fails the
check raises.
"""

from finite_exact.rat_q import Q
from finite_linear_algebra.scalar import q_int, q_is_zero
from psc.exact import q_sign

comptime LP_PIVOTS = 20000  # pivots before the search gives up (reports nothing)


def farkas_refutes(forms: List[List[Int]], m: Int, y: List[Q]) raises -> Bool:
    """`y` proves `c + A x >= 0` (rows `forms`, `[c, a_1..a_m]`) has no
    point `x >= 0`: `y >= 0`, `sum_i y_i a_ij <= 0` for every `j`, and
    `sum_i y_i c_i < 0`, in exact arithmetic. A rejected value fails; a
    form not of width `m + 1`, or a `y` not one per form, raises."""
    if len(y) != len(forms):
        raise Error("a Farkas multiplier vector not one per form")
    for i in range(len(forms)):
        if len(forms[i]) != m + 1:
            raise Error("a form of the wrong width for the LP")
    for i in range(len(y)):
        if y[i].rejected or q_sign(y[i]) < 0:
            return False
    for j in range(m + 1):
        var acc = Q.zero()
        for i in range(len(forms)):
            if forms[i][j] != 0:
                acc = acc.add(y[i].mul(q_int(forms[i][j])))
        if acc.rejected:
            return False
        if j == 0 and q_sign(acc) >= 0:
            return False
        if j > 0 and q_sign(acc) > 0:
            return False
    return True


def farkas_certificate(forms: List[List[Int]], m: Int) raises -> List[Q]:
    """A Farkas certificate for `c + A x >= 0, x >= 0` (rows `forms`), or
    empty when the system is feasible or the search gives up. Phase 1 of
    the simplex on `d_i (A_i x - s_i) + t_i = -d_i c_i` (`d_i = +-1` making
    the right side `>= 0`, `t` artificial and never re-entering); at an
    optimum of `sum t > 0` the reduced cost of slack `s_i` is `y_i`. The
    certificate is checked (`farkas_refutes`) and a failing one raises."""
    var n = len(forms)
    var cols = m + n  # x_1..x_m, then the slacks
    var rows = List[List[Q]]()
    var rhs = List[Q]()
    var basis = List[Int]()  # a column, or -1 for the row's artificial
    for i in range(n):
        if len(forms[i]) != m + 1:
            raise Error("a form of the wrong width for the LP")
        var d = -1 if forms[i][0] > 0 else 1
        var r = List[Q]()
        for j in range(m):
            r.append(q_int(d * forms[i][j + 1]))
        for k in range(n):
            r.append(q_int(-d if k == i else 0))
        rows.append(r^)
        rhs.append(q_int(-d * forms[i][0]))
        basis.append(-1)
    # reduced costs of minimizing the sum of the artificials
    var red = List[Q]()
    for j in range(cols):
        var acc = Q.zero()
        for i in range(n):
            acc = acc.sub(rows[i][j])
        red.append(acc^)
    var pivots = 0
    while True:
        var enter = -1
        for j in range(cols):
            if q_sign(red[j]) < 0:
                enter = j
                break
        if enter < 0:
            break
        pivots += 1
        if pivots > LP_PIVOTS:
            return List[Q]()
        # ratio test; ties to the smallest basic column (artificials first)
        var leave = -1
        var best = Q.zero()
        for i in range(n):
            if q_sign(rows[i][enter]) <= 0:
                continue
            var ratio = rhs[i].div(rows[i][enter])
            if leave < 0 or ratio.lt(best) or (ratio.eq(best) and basis[i] < basis[leave]):
                leave = i
                best = ratio^
        if leave < 0:
            raise Error("an unbounded phase-1 LP (its objective is bounded below by 0)")
        var p = rows[leave][enter].copy()
        for j in range(cols):
            rows[leave][j] = rows[leave][j].div(p)
        rhs[leave] = rhs[leave].div(p)
        for i in range(n):
            if i == leave or q_is_zero(rows[i][enter]):
                continue
            var f = rows[i][enter].copy()
            for j in range(cols):
                if not q_is_zero(rows[leave][j]):
                    rows[i][j] = rows[i][j].sub(f.mul(rows[leave][j]))
            rhs[i] = rhs[i].sub(f.mul(rhs[leave]))
        var g = red[enter].copy()
        for j in range(cols):
            if not q_is_zero(rows[leave][j]):
                red[j] = red[j].sub(g.mul(rows[leave][j]))
        basis[leave] = enter
    var z = Q.zero()
    for i in range(n):
        if basis[i] < 0:
            z = z.add(rhs[i])
    if q_sign(z) <= 0:
        return List[Q]()
    var y = List[Q]()
    for i in range(n):
        y.append(red[m + i].copy())
    if not farkas_refutes(forms, m, y):
        raise Error("a phase-1 LP optimum gives no Farkas certificate")
    return y^


def lp_infeasible(forms: List[List[Int]], m: Int) raises -> Bool:
    """No rational `x >= 0` with every form `>= 0`, by a checked Farkas
    certificate; false when none is found (feasible, or the search gave
    up)."""
    return len(farkas_certificate(forms, m)) > 0
