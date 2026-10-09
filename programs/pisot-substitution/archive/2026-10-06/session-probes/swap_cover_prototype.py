"""Prototype cover of the swap family's |det M| = 2 planes by certified cones.

Plane coordinates (u, v) >= 0 per class branch; regions are a base point with
free directions. Exploratory only.
"""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "..", "..", "reference"))
import itertools
from cone_witness_prototype import *

E = {'S1': (X, X, X, X), 'S2': (X, X, X, C), 'S3': (X, X, C, X), 'S4': (X, X, C, C), 'S5': (X, C, X, X)}
# (class, branch name, base (p,q,r) at u=v=0, g_u, g_v)
BRANCHES = [
    ('S1', 'r=q+1', (0, 1, 2), (1, 1, 1), (0, 1, 1)),
    ('S1', 'r=q-1', (0, 1, 0), (1, 1, 1), (0, 1, 1)),
    ('S2', 'r=p+1', (1, 0, 2), (1, 1, 1), (1, 0, 1)),
    ('S2', 'r=p-1', (1, 0, 0), (1, 1, 1), (1, 0, 1)),
    ('S3', 'r=p+1', (1, 0, 2), (1, 1, 1), (1, 0, 1)),
    ('S3', 'r=p-1', (1, 0, 0), (1, 1, 1), (1, 0, 1)),
    ('S4', 'q+r=2p+1', (1, 0, 3), (1, 1, 1), (1, 0, 2)),
    ('S4', 'q+r=2p-1', (1, 0, 1), (1, 1, 1), (1, 0, 2)),
    ('S5', 'q=p+1', (0, 1, 0), (1, 1, 0), (0, 0, 1)),
    ('S5', 'p=q+1', (1, 0, 0), (1, 1, 0), (0, 0, 1)),
]


def det3(M):
    return (M[0][0] * (M[1][1] * M[2][2] - M[1][2] * M[2][1])
            - M[0][1] * (M[1][0] * M[2][2] - M[1][2] * M[2][0])
            + M[0][2] * (M[1][0] * M[2][1] - M[1][1] * M[2][0]))


def mat_at(e, p, q, r):
    sx, sc, t, sy = e
    img = {X: [C] + [Y] * p + [sx], C: [X] + [Y] * q + [sc], Y: [t] + [Y] * r + [sy]}
    return [[img[j].count(i) for j in range(3)] for i in range(3)]


def f_at(M, t):
    return det3([[(t if i == j else 0) - M[i][j] for j in range(3)] for i in range(3)])


def affine_of(fn, base, gens):
    """fn: (p,q,r) -> int, affine; returns its affine form in the cone variables."""
    b = fn(*base)
    out = [b]
    for g in gens:
        out.append(fn(*(base[i] + g[i] for i in range(3))) - b)
    # verify affinity on a few points
    for ks in itertools.product(range(3), repeat=len(gens)):
        pt = tuple(base[i] + sum(k * g[i] for k, g in zip(ks, gens)) for i in range(3))
        assert fn(*pt) == out[0] + sum(k * c for k, c in zip(ks, out[1:])), "not affine"
    return tuple(out)


def cover(cl, base, gu, gv, K=3, maxlev=6, depth=8):
    e = E[cl]
    certs, cut, points, fails = [], [], [], []

    def pqr(u, v):
        return tuple(base[i] + u * gu[i] + v * gv[i] for i in range(3))

    def rec(u0, v0, dirs, d):
        b = pqr(u0, v0)
        gens = [gu if k == 'u' else gv for k in dirs]
        if not dirs:
            points.append(b)
            return
        f1 = affine_of(lambda p, q, r: f_at(mat_at(e, p, q, r), 1), b, gens)
        fm = affine_of(lambda p, q, r: f_at(mat_at(e, p, q, r), -1), b, gens)
        if nonneg(f1) or nonneg(fm):
            cut.append((b, dirs, 'f(1)' if nonneg(f1) else 'f(-1)'))
            return
        fam = swap_family(b, gens, e)
        res = search(fam, K=K, maxlev=maxlev)
        if res is not None:
            certs.append((b, dirs, res))
            return
        if d == 0:
            fails.append((b, dirs))
            return
        if len(dirs) == 2:
            rec(u0, v0, 'v', d - 1)
            rec(u0 + 1, v0, 'u', d - 1)
            rec(u0 + 1, v0 + 1, 'uv', d - 1)
        else:
            rec(u0, v0, '', d - 1)
            if dirs == 'u':
                rec(u0 + 1, v0, 'u', d - 1)
            else:
                rec(u0, v0 + 1, 'v', d - 1)

    rec(0, 0, 'uv', depth)
    return certs, cut, points, fails


if __name__ == "__main__":
    maxlev = int(sys.argv[1]) if len(sys.argv) > 1 else 5
    depth = int(sys.argv[2]) if len(sys.argv) > 2 else 8
    for cl, name, base, gu, gv in BRANCHES:
        certs, cut, points, fails = cover(cl, base, gu, gv, maxlev=maxlev, depth=depth)
        lv = sorted(c[2][0] for c in certs)
        print(f"{cl} {name}: cones {len(certs)} (levels {lv}), cut {len(cut)}, points {len(points)}, FAILED {len(fails)}")
        for b, dirs, why in cut:
            print("    cut", b, dirs, why)
        print("    points", points)
        for f in fails:
            print("    FAIL", f)
        sys.stdout.flush()
