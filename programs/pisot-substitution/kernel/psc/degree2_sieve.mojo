"""Necessary conditions on the incidence cubic for a three-state degree-2 SCC.

If a strict closed degree-2 SCC `C` has `|C| = 3`, the Parikh and signed `K2`
intertwiners force `N_C ~ M` and `S_C ~ Lambda^2 M`, with `N_C = A + B` and
`S_C = A - B` for non-negative integer `A, B`. Hence for every `k >= 1`

    tr(M^k) - tr((Lambda^2 M)^k) = 2 * sum_{odd B-count words} tr(word(A, B)) >= 0,

and for `k = 2` the difference is `4 tr(AB)`, divisible by four. With
`chi(x) = x^3 - T x^2 + U x - D` the power traces of `M` and of its exterior
square follow Newton recurrences in `(T, U, D)` alone, so the sieve is exact
integer arithmetic on the characteristic polynomial. `first_trace_failure`
returns the least `k` at which the condition fails, or `0` when it survives
through `max_k`. A survivor is not a counterexample: these are necessary
conditions only.
"""


def mod2(x: Int) -> Int:
    var r = x % 2
    return r if r >= 0 else r + 2


def parity_allows_three_states(t: Int, u: Int, d: Int) -> Bool:
    """Exactly the lcm-degree-3 rows of the merged mod-2 sieve."""
    var tp = mod2(t)
    var up = mod2(u)
    if tp != up:
        return False
    return tp == 0 or mod2(d) == 1


def traces_standard(t: Int, u: Int, d: Int, max_k: Int) -> List[Int]:
    """`tr(M^k)` for `0 <= k <= max_k` from Newton's identities."""
    var p: List[Int] = [3, t, t * t - 2 * u]
    for k in range(3, max_k + 1):
        p.append(t * p[k - 1] - u * p[k - 2] + d * p[k - 3])
    return p^


def traces_exterior(t: Int, u: Int, d: Int, max_k: Int) -> List[Int]:
    """`tr((Lambda^2 M)^k)`; the exterior square has `(T, U, D) -> (U, DT, D^2)`."""
    var q: List[Int] = [3, u, u * u - 2 * d * t]
    for k in range(3, max_k + 1):
        q.append(u * q[k - 1] - d * t * q[k - 2] + d * d * q[k - 3])
    return q^


def first_trace_failure(t: Int, u: Int, d: Int, max_k: Int) -> Int:
    """Least `k <= max_k` violating `tr(M^k) >= tr((Lambda^2 M)^k)` (with the
    mod-4 condition at `k = 2`), or `0` when every `k` survives."""
    var p = traces_standard(t, u, d, max_k)
    var q = traces_exterior(t, u, d, max_k)
    for k in range(1, max_k + 1):
        if p[k] < q[k] or (k == 2 and (p[2] - q[2]) % 4 != 0):
            return k
    return 0


def survives_through(first_failure: Int, k: Int) -> Bool:
    """Whether a `first_trace_failure` value passes every power up to `k`."""
    return first_failure == 0 or first_failure > k
