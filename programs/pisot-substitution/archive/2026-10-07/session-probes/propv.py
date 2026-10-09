"""Prop V step 1 + (⇐), independently: enumerate interior-occurrence pairs,
keep integral centre offsets w0, check |w0_m| <= R_m (radii recomputed here
with mpmath) and that v0 has an offset-zero descendant (a shared vertex)."""
import sys
from common import *
from fractions import Fraction
import sympy as S

def radii(sigma):
    m = matrix(sigma); c = charpoly(m)
    roots = mp.polyroots([mp.mpf(x) for x in c], maxsteps=200, extraprec=200)
    beta = max(roots, key=abs).real
    conj = [z for z in roots if abs(z) < 1]
    beta_, ell = left_pf(m)
    # field embeddings: ell lies in Q(beta); express ell_a = poly_a(beta) via exact basis
    # use the conjugate left eigenvectors directly: sigma_k(ell) = left eigvec for conj root, same normalisation ell_0=1
    def lvec(lam):
        B = mp.matrix([[m[b][a] - (lam if a == b else 0) for b in range(3)] for a in range(3)])
        sub = mp.matrix([[B[1, 1], B[1, 2]], [B[2, 1], B[2, 2]]]); rhs = mp.matrix([-B[1, 0], -B[2, 0]])
        x = mp.lu_solve(sub, rhs); return [mp.mpf(1), x[0], x[1]]
    E = [ell] + [lvec(z) for z in conj]            # embeddings of (ell_0, ell_1, ell_2)
    # increments F: <ell, pi(q) - pi(p)> over prefixes; conjugate k uses E[k]
    pref = [parikh(sigma[a][:k]) for a in range(3) for k in range(len(sigma[a]))]
    lmax = max(ell)
    R = []
    # theta_m: trace-dual basis; embeddings matrix V[k][a] = sigma_k(ell_a); theta embeddings = rows of V^{-T}
    V = mp.matrix([[E[k][a] for a in range(3)] for k in range(3)])
    Th = V ** -1                                     # (Th V)[m,a] = Tr(theta_m ell_a) = delta
    Bk = []
    for k in (1, 2):
        mu = abs(conj[k-1])
        Ck = max(abs(sum(E[k][a]*(u[a]-v[a]) for a in range(3))) for u in pref for v in pref)
        Bk.append(Ck / (1 - mu))
    for mm in range(3):
        R.append(abs(Th[mm, 0]) * lmax + sum(abs(Th[mm, k]) * Bk[k-1] for k in (1, 2)))
    return R, ell

def offset_zero_descendant(sigma, i, j, w, ell, cap=10**6):
    m = matrix(sigma)
    pre = [[parikh(sigma[x][:k]) for k in range(len(sigma[x]))] for x in range(3)]
    eps = mp.mpf(10)**-40
    d0 = tuple(-x for x in w)
    fr = {(i, j, d0)}; seen = set(fr); lvl = 0
    while fr:
        if any(d == (0, 0, 0) for _, _, d in fr): return lvl
        lvl += 1; nx = set()
        for a, b, d in fr:
            md = tuple(sum(m[r][k]*d[k] for k in range(3)) for r in range(3))
            for p, la in enumerate(sigma[a]):
                for q, lb in enumerate(sigma[b]):
                    nd = tuple(md[k] + pre[a][p][k] - pre[b][q][k] for k in range(3))
                    x = -sum(ell[k]*nd[k] for k in range(3))
                    s = (la, lb, nd)
                    if s not in seen and -ell[lb] + eps < x < ell[la] - eps:
                        seen.add(s); nx.add(s)
        fr = nx
    return None

specimens = {'tribonacci': ((0, 1), (0, 2), (0,)), 'cube': ((1,), (2, 2, 2), (0, 2, 2, 2)), 'golden pump': ((1,), (0, 2, 1), (0, 0, 1))}
RMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 5
for name, s in specimens.items():
    R, ell = radii(s); m = S.Matrix(matrix(s))
    worst = 0; n_int = 0; fails = 0; maxdepth = 0
    for r in range(1, RMAX+1):
        Mr = m**r; inv = (Mr - S.eye(3)).inv()
        occ = {a: [] for a in range(3)}
        for a in range(3):
            w = a_word(s, a, r); v = [0, 0, 0]
            for pos, ch in enumerate(w):
                if ch == a and 0 < pos < len(w) - 1: occ[a].append(tuple(v))
                v[ch] += 1
        if sum(len(o) for o in occ.values())**2 > 3e5: break
        for i in range(3):
            for j in range(3):
                for P in occ[i]:
                    for Q in occ[j]:
                        w0 = inv * S.Matrix([P[k]-Q[k] for k in range(3)])
                        if not all(x.is_integer for x in w0): continue
                        n_int += 1
                        w0 = [int(x) for x in w0]
                        worst = max(worst, max(abs(w0[k]) / R[k] for k in range(3)))
                        dz = offset_zero_descendant(s, i, j, w0, ell)
                        if dz is None: fails += 1
                        else: maxdepth = max(maxdepth, dz)
        last = r
    print(f"{name}: R = {[mp.nstr(x, 6) for x in R]}, r<= {last}, integral pairs {n_int}, max |w_m|/R_m = {float(worst):.3f}, PPVC failures {fails}, deepest first offset-zero {maxdepth}")
