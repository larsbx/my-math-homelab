"""Prototype (provenance; canonical: kernel/psc/cone_witness.mojo): parametric
witness paths with constant Parikh offsets.

A cone is (p,q,r) = base + sum n_k g_k, n_k >= 0. Affine forms are tuples
(c0, c1, ..., cm). A path step from (a, b, gamma) picks a position in sigma(a)
and one in sigma(b); gamma' = M gamma + pre_a - pre_b must stay constant.
Exploratory only.
"""
import itertools
from collections import deque

X, C, Y = 0, 1, 2
NM = "xcy"


def aff_const(m, c):
    return (c,) + (0,) * m


def aadd(a, b):
    return tuple(x + y for x, y in zip(a, b))


def asub(a, b):
    return tuple(x - y for x, y in zip(a, b))


def ascale(a, k):
    return tuple(k * x for x in a)


def is_const(a):
    return all(x == 0 for x in a[1:])


def nonneg(a):
    return all(x >= 0 for x in a)


class Family:
    """images: dict letter -> list of segments; a segment is ('L', letter) or ('Y', affine length)."""

    def __init__(self, m, images):
        self.m = m
        self.img = images
        # M[i][j] = number of letter i in sigma(j), affine
        self.M = [[aff_const(m, 0) for _ in range(3)] for _ in range(3)]
        for j in range(3):
            for seg in images[j]:
                if seg[0] == 'L':
                    self.M[seg[1]][j] = aadd(self.M[seg[1]][j], aff_const(m, 1))
                else:
                    self.M[Y][j] = aadd(self.M[Y][j], seg[1])

    def segs(self, a):
        """(segment, prefix vector before it, start index) for sigma(a)."""
        pre = [aff_const(self.m, 0)] * 3
        start = aff_const(self.m, 0)
        out = []
        for seg in self.img[a]:
            out.append((seg, list(pre), start))
            if seg[0] == 'L':
                pre[seg[1]] = aadd(pre[seg[1]], aff_const(self.m, 1))
                start = aadd(start, aff_const(self.m, 1))
            else:
                pre[Y] = aadd(pre[Y], seg[1])
                start = aadd(start, seg[1])
        return out

    def Mg(self, g):
        return [
            tuple(sum(self.M[i][j][k] * g[j] for j in range(3)) for k in range(self.m + 1))
            for i in range(3)
        ]


def steps(fam, a, b, g, K, small=(0, 1, 2)):
    Mg = fam.Mg(g)
    one = aff_const(fam.m, 1)
    for (sa, pa, sta) in fam.segs(a):
        for (sb, pb, stb) in fam.segs(b):
            d0 = [asub(aadd(Mg[i], pa[i]), pb[i]) for i in range(3)]
            if not (is_const(d0[X]) and is_const(d0[C])):
                continue
            gx, gc = d0[X][0], d0[C][0]
            if abs(gx) > K or abs(gc) > K:
                continue
            for ty in range(-K, K + 1):
                D = asub(aff_const(fam.m, ty), d0[Y])  # u - v must equal D
                cands = []
                if sa[0] == 'L' and sb[0] == 'L':
                    if D == aff_const(fam.m, 0):
                        cands.append((aff_const(fam.m, 0), aff_const(fam.m, 0)))
                elif sa[0] == 'Y' and sb[0] == 'L':
                    cands.append((D, aff_const(fam.m, 0)))
                elif sa[0] == 'L' and sb[0] == 'Y':
                    cands.append((aff_const(fam.m, 0), ascale(D, -1)))
                else:
                    for s in small:
                        cands.append((aadd(D, aff_const(fam.m, s)), aff_const(fam.m, s)))
                        cands.append((aff_const(fam.m, s), asub(aff_const(fam.m, s), D)))
                for u, v in cands:
                    ok = True
                    for seg, off in ((sa, u), (sb, v)):
                        if seg[0] == 'Y':
                            if not (nonneg(off) and nonneg(asub(asub(seg[1], off), one))):
                                ok = False
                    if not ok:
                        continue
                    la = sa[1] if sa[0] == 'L' else Y
                    lb = sb[1] if sb[0] == 'L' else Y
                    ia = aadd(sta, u)
                    ib = aadd(stb, v)
                    yield (la, lb, (gx, gc, ty), ia, ib)


def search(fam, K=3, maxlev=6, start=(X, C)):
    s0 = (start[0], start[1], (0, 0, 0))
    prev = {s0: None}
    frontier = [s0]
    for lev in range(1, maxlev + 1):
        nxt = []
        for st in frontier:
            a, b, g = st
            for (la, lb, g2, ia, ib) in steps(fam, a, b, g, K):
                ns = (la, lb, g2)
                if ns in prev:
                    continue
                prev[ns] = (st, ia, ib)
                if la == lb and g2 == (0, 0, 0):
                    path = []
                    cur = ns
                    while prev[cur] is not None:
                        p, ia_, ib_ = prev[cur]
                        path.append((p, cur, ia_, ib_))
                        cur = p
                    return lev, path[::-1]
                nxt.append(ns)
        frontier = nxt
    return None


def swap_family(base, gens, ending):
    """Cone over (p,q,r): affine forms in m = len(gens) variables."""
    m = len(gens)
    P = tuple([base[0]] + [g[0] for g in gens])
    Q = tuple([base[1]] + [g[1] for g in gens])
    R = tuple([base[2]] + [g[2] for g in gens])
    sx, sc, t, sy = ending
    img = {
        X: [('L', C), ('Y', P), ('L', sx)],
        C: [('L', X), ('Y', Q), ('L', sc)],
        Y: [('L', t), ('Y', R), ('L', sy)],
    }
    # drop zero-length runs only when the run is identically zero
    for k in img:
        img[k] = [s for s in img[k] if not (s[0] == 'Y' and all(v == 0 for v in s[1]))]
    return Family(m, img)


def fmt(a):
    s = str(a[0])
    for i, c in enumerate(a[1:]):
        if c:
            s += f"{c:+d}n{i+1}"
    return s


if __name__ == "__main__":
    import sys
    E = {'S1': (X, X, X, X), 'S2': (X, X, X, C), 'S3': (X, X, C, X), 'S4': (X, X, C, C), 'S5': (X, C, X, X)}
    tests = [
        ('S5', (2, 1, 2), [(1, 1, 0), (0, 0, 1)]),   # p = q+1, r >= 2
        ('S5', (1, 2, 2), [(1, 1, 0), (0, 0, 1)]),
        ('S2', (3, 1, 2), [(1, 1, 1), (1, 0, 1)]),
        ('S2', (3, 0, 4), [(1, 0, 1)]),
        ('S1', (1, 2, 3), [(1, 1, 1), (0, 1, 1)]),
    ]
    for cl, base, gens in tests:
        fam = swap_family(base, gens, E[cl])
        res = search(fam, K=3, maxlev=int(sys.argv[1]) if len(sys.argv) > 1 else 5)
        print(cl, base, gens, '->', None if res is None else res[0])
        if res:
            for (p, cur, ia, ib) in res[1]:
                print('    ', NM[p[0]], NM[p[1]], p[2], '->', NM[cur[0]], NM[cur[1]], cur[2], 'at', fmt(ia), fmt(ib))
