"""Finite configuration replacement oracle; no octonion bridge is selected.

The unlabeled object is a replacement multigraph, not an action of each
individually labeled generator. The model is n=6 over F_7 only.
"""

from experiments.soddy import n6_f7_orbits as arithmetic


def gram(w):
    q = arithmetic.descartes_gram()
    return arithmetic.mat_mul(arithmetic.transpose(w),
                              arithmetic.mat_mul(q, w))


def validate(w, target):
    for a in (w, target):
        if len(a) != 8 or any(len(row) != 8 for row in a):
            raise ValueError("configuration and target must be 8 by 8")
        if any(type(x) is not int or not 0 <= x < 7
               for row in a for x in row):
            raise ValueError("entries must be canonical F_7 integers")
    if arithmetic.transpose(target) != target:
        raise ValueError("target Gram matrix must be symmetric")
    arithmetic.mat_inv(w)
    arithmetic.mat_inv(target)
    if gram(w) != target:
        raise ValueError("configuration violates its target Gram identity")


def replace(w, target, i):
    validate(w, target)
    if type(i) is not int or not 0 <= i < 8:
        raise ValueError("replacement index must be in range(8)")
    result = arithmetic.mat_mul(arithmetic.apollonian_generators()[i], w)
    validate(result, target)
    return result


def unlabeled_key(w):
    return tuple(sorted(tuple(row) for row in w))


def neighbors(w, target):
    """Eight replacement edges, retaining repeated neighbors and loops."""
    from collections import Counter
    return Counter(unlabeled_key(replace(w, target, i)) for i in range(8))


def adjacent_swap(i):
    p = arithmetic.eye()
    p[i], p[i + 1] = p[i + 1], p[i]
    return p


def run():
    # W=I, R=Q is a full, invertible algebraic configuration witness.
    w = arithmetic.eye()
    target = arithmetic.descartes_gram()
    validate(w, target)
    for i in range(8):
        if replace(replace(w, target, i), target, i) != w:
            raise ValueError("replacement is not involutive")
    for i in range(7):
        p = adjacent_swap(i)
        if neighbors(arithmetic.mat_mul(p, w), target) != neighbors(w, target):
            raise ValueError("unlabeled replacement edges depend on labeling")
    return {"model": "n=6 over F_7", "configuration_rank": 8,
            "replacement_edges": sum(neighbors(w, target).values()),
            "distinct_unlabeled_neighbors": len(neighbors(w, target)),
            "status": "finite executable checks only"}


if __name__ == "__main__":
    print(run())
