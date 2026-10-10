"""Independent primitives for the adversarial check (no repo code imported)."""
from fractions import Fraction
from itertools import product
import numpy as np
import mpmath as mp

mp.mp.dps = 60
A = 3

def parikh(w):
    v = [0, 0, 0]
    for ch in w:
        v[ch] += 1
    return tuple(v)

def matrix(sigma):
    # M[a][b] = |sigma(b)|_a
    cols = [parikh(sigma[b]) for b in range(A)]
    return [[cols[b][a] for b in range(A)] for a in range(A)]

def det3(m):
    return (m[0][0]*(m[1][1]*m[2][2]-m[1][2]*m[2][1])
            - m[0][1]*(m[1][0]*m[2][2]-m[1][2]*m[2][0])
            + m[0][2]*(m[1][0]*m[2][1]-m[1][1]*m[2][0]))

def charpoly(m):
    tr = m[0][0]+m[1][1]+m[2][2]
    s2 = sum(m[i][i]*m[j][j]-m[i][j]*m[j][i] for i in range(3) for j in range(i+1, 3))
    return [1, -tr, s2, -det3(m)]   # t^3 - tr t^2 + s2 t - det

def primitive(m):
    a = np.array(m, dtype=object); p = a.copy()
    for _ in range(6):
        if all(x > 0 for x in p.flatten()):
            return True
        p = p.dot(a)
    return False

def irreducible_cubic(c):
    d = c[3]
    if d == 0:
        return False
    for r in range(1, abs(d)+1):
        if d % r == 0:
            for s in (r, -r):
                if s**3 + c[1]*s**2 + c[2]*s + c[3] == 0:
                    return False
    return True

def pisot(c):
    roots = mp.polyroots([mp.mpf(x) for x in c], maxsteps=200, extraprec=200)
    mods = sorted(abs(z) for z in roots)
    return mods[2] > 1 and mods[1] < 1 and abs(mp.im(max(roots, key=abs))) < mp.mpf(10)**-40

def pip(sigma):
    m = matrix(sigma); c = charpoly(m)
    return primitive(m) and irreducible_cubic(c) and pisot(c)

def left_pf(m):
    c = charpoly(m)
    beta = max((z for z in mp.polyroots([mp.mpf(x) for x in c], maxsteps=200, extraprec=200)), key=abs).real
    # left eigenvector ell M = beta ell, normalise ell_0 = 1 via null space
    B = mp.matrix([[m[b][a] - (beta if a == b else 0) for b in range(3)] for a in range(3)])  # (M^T - beta)
    # solve two rows with ell_0 = 1
    sub = mp.matrix([[B[1, 1], B[1, 2]], [B[2, 1], B[2, 2]]])
    rhs = mp.matrix([-B[1, 0], -B[2, 0]])
    try:
        x = mp.lu_solve(sub, rhs)
        ell = [mp.mpf(1), x[0], x[1]]
    except ZeroDivisionError:
        sub = mp.matrix([[B[0, 1], B[0, 2]], [B[1, 1], B[1, 2]]])
        x = mp.lu_solve(sub, mp.matrix([-B[0, 0], -B[1, 0]]))
        ell = [mp.mpf(1), x[0], x[1]]
    return beta, ell

def coincidence_level(sigma, a, b, max_states=2_000_000):
    """Decide strong coincidence of {a,b} exactly on the overlap graph.
    Returns the first level with a shared tile, or None if the full reachable
    overlap closure contains no coincidence (a rigorous 'no')."""
    m = matrix(sigma)
    beta, ell = left_pf(m)
    pre = [[parikh(sigma[x][:k]) for k in range(len(sigma[x]))] for x in range(3)]
    eps = mp.mpf(10)**-40
    def overlaps(i, j, d):
        x = -sum(ell[k]*d[k] for k in range(3))   # B-tile left end, A-tile at 0
        return -ell[j] + eps < x < ell[i] - eps
    def mul(d):
        return tuple(sum(m[r][k]*d[k] for k in range(3)) for r in range(3))
    frontier = {(a, b, (0, 0, 0))}
    seen = set(frontier)
    level = 0
    while frontier:
        if any(i == j and d == (0, 0, 0) for i, j, d in frontier):
            return level
        level += 1
        nxt = set()
        for i, j, d in frontier:
            md = mul(d)
            for p, li in enumerate(sigma[i]):
                for q, lj in enumerate(sigma[j]):
                    nd = tuple(md[k] + pre[i][p][k] - pre[j][q][k] for k in range(3))
                    s = (li, lj, nd)
                    if s not in seen and overlaps(li, lj, nd):
                        seen.add(s); nxt.add(s)
        if len(seen) > max_states:
            raise RuntimeError("cap")
        frontier = nxt
    return None

def shared_tile_at(sigma, n, a, b, pos):
    u, w = a_word(sigma, a, n), a_word(sigma, b, n)
    return pos < min(len(u), len(w)) and u[pos] == w[pos] and parikh(u[:pos]) == parikh(w[:pos])

def a_word(sigma, a, n):
    w = [a]
    for _ in range(n):
        w = [y for x in w for y in sigma[x]]
    return w
