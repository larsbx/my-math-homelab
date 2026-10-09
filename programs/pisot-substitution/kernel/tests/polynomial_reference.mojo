"""Pre-optimization exact kernels; regression and benchmark baseline only."""
from finite_exact.rat_q import Q
from psc.exact import q_is_zero

def poly_eval(p: List[Q], x: Q) -> Q:
    """Horner evaluation; `p` is low-degree-first."""
    var acc = Q.zero()
    for i in range(len(p) - 1, -1, -1):
        acc = acc.mul(x).add(p[i])
    return acc^


def poly_degree(p: List[Q]) -> Int:
    for i in range(len(p) - 1, -1, -1):
        if not q_is_zero(p[i]):
            return i
    return -1


def poly_rem(a: List[Q], b: List[Q]) -> List[Q]:
    """Remainder of `a` on division by `b` over Q."""
    var r = a.copy()
    var db = poly_degree(b)
    if db < 0:
        return r^
    while True:
        var dr = poly_degree(r)
        if dr < db:
            return r^
        var f = r[dr].div(b[db])
        for i in range(db + 1):
            r[dr - db + i] = r[dr - db + i].sub(f.mul(b[i]))
        r[dr] = Q.zero()
