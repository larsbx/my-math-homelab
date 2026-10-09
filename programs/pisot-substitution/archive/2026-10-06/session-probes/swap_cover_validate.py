"""Numeric validation of the prototype cone certificates, and end-to-end
coverage against the exact PIP screen. Exploratory only."""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "..", "..", "reference"))
import itertools
from swap_cover_prototype import *
from psc_research.pip_screen import charpoly, primitive, irreducible, pisot


def ev(a, ns):
    return a[0] + sum(c * n for c, n in zip(a[1:], ns))


def sigma_at(e, p, q, r):
    sx, sc, t, sy = e
    return {X: [C] + [Y] * p + [sx], C: [X] + [Y] * q + [sc], Y: [t] + [Y] * r + [sy]}


def apply(s, w):
    return [b for a in w for b in s[a]]


def check_path(e, b, gens, res, ns):
    p, q, r = (b[i] + sum(n * g[i] for n, g in zip(ns, gens)) for i in range(3))
    s = sigma_at(e, p, q, r)
    lev, path = res
    # walk: positions per level; compute absolute positions
    a, bb = X, C
    pos_a, pos_b = 0, 0  # absolute positions inside sigma^l(x), sigma^l(c)
    for l, (prev, cur, ia, ib) in enumerate(path):
        i, k = ev(ia, ns), ev(ib, ns)
        if not (0 <= i < len(s[a]) and 0 <= k < len(s[bb])):
            return False
        if s[a][i] != cur[0] or s[bb][k] != cur[1]:
            return False
        # absolute position at level l+1: sigma(prefix of sigma^l(x) up to pos) + i
        wa = [X]; wb = [C]
        for _ in range(l):
            wa = apply(s, wa); wb = apply(s, wb)
        pos_a = len(apply(s, wa[:pos_a])) + i
        pos_b = len(apply(s, wb[:pos_b])) + k
        a, bb = cur[0], cur[1]
    u, w = [X], [C]
    for _ in range(lev):
        u, w = apply(s, u), apply(s, w)
    if pos_a != pos_b:
        return False
    pu = [u[:pos_a].count(z) for z in range(3)]
    pw = [w[:pos_b].count(z) for z in range(3)]
    return pu == pw and u[pos_a] == w[pos_b]


def is_pip(M):
    T, U, D = charpoly(M)
    return primitive(M) and irreducible(T, U, D) and pisot(T, U, D)


if __name__ == "__main__":
    S = int(sys.argv[1]) if len(sys.argv) > 1 else 3
    B = int(sys.argv[2]) if len(sys.argv) > 2 else 12
    covered = {}
    for cl, name, base, gu, gv in BRANCHES:
        certs, cut, points, fails = cover(cl, base, gu, gv, maxlev=5, depth=8)
        assert not fails
        e = E[cl]
        nchk = 0
        for b, dirs, res in certs:
            gens = [gu if k == 'u' else gv for k in dirs]
            for ns in itertools.product(range(S), repeat=len(gens)):
                assert check_path(e, b, gens, res, ns), (cl, name, b, dirs, ns)
                nchk += 1
        covered[(cl, name)] = (certs, cut, points)
        print(cl, name, 'numeric checks', nchk)
    # end-to-end: every PIP |det|=2 point with p,q,r <= B is in a cone or a residue point
    for cl, e in E.items():
        npip = 0; incone = 0; inres = []
        for p, q, r in itertools.product(range(B + 1), repeat=3):
            M = mat_at(e, p, q, r)
            if abs(det3(M)) != 2 or not is_pip([[M[i][j] for j in range(3)] for i in range(3)]):
                continue
            npip += 1
            hit = False
            for (c2, name), (certs, cut, points) in covered.items():
                if c2 != cl:
                    continue
                br = [x for x in BRANCHES if x[0] == cl and x[1] == name][0]
                for b, dirs, res in certs:
                    gens = [br[3] if k == 'u' else br[4] for k in dirs]
                    # solve (p,q,r) = b + sum n g, n >= 0 integer, brute force
                    for ns in itertools.product(range(B + 2), repeat=len(gens)):
                        if tuple(b[i] + sum(n * g[i] for n, g in zip(ns, gens)) for i in range(3)) == (p, q, r):
                            hit = True; break
                    if hit: break
                if not hit and (p, q, r) in points:
                    inres.append((p, q, r)); hit = True
                if hit: break
            assert hit, ("UNCOVERED PIP", cl, (p, q, r))
            if (p, q, r) not in inres:
                incone += 1
        print(cl, 'PIP', npip, 'in cones', incone, 'residue', inres)
