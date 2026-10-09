"""Theorem E, attacked from the definitions: enumerate every 3-letter
substitution with h(0)=0, h(1)=1 (WLOG x=0, c=1), images of length <= L,
|det M| = 2, catch-up-free, PIP; check Prop D's normal form and decide {0,1}."""
import sys
from itertools import product
import numpy as np
from common import *

L = int(sys.argv[1])
words = [w for n in range(1, L+1) for w in product(range(3), repeat=n)]
w0 = [w for w in words if w[0] == 0]
w1 = [w for w in words if w[0] == 1]
P = lambda ws: np.array([parikh(w) for w in ws], dtype=np.int64)
P0, P1, P2 = P(w0), P(w1), P(words)

def catch_up_free(sigma, m):
    d = det3(m)
    adj = np.array(sympy_adj(m), dtype=object)
    for img in sigma:
        for k in range(1, len(img)):
            u = np.array(parikh(img[:k]), dtype=object)
            if all(x % d == 0 for x in adj.dot(u)):
                return False
    return True

def sympy_adj(m):
    import sympy
    return sympy.Matrix(m).adjugate().tolist()

def normal_form(sigma):
    # Prop D: sigma(x)=x y^p s, sigma(c)=c y^q s, sigma(y)=t y^r s, s,t in {0,1}
    for img in sigma:
        if len(img) < 2 or img[0] == 2 or img[-1] == 2 or any(z != 2 for z in img[1:-1]):
            return False
    return True

hits = []; bad_nf = []; noncoinc = []; tot = 0
for i2, (w2, p2) in enumerate(zip(words, P2)):
    # det of columns (p0, p1, p2), vectorised over p0 x p1
    c = np.cross(P0[:, None, :], P1[None, :, :])        # p0 x p1
    det = c @ p2
    for a, b in zip(*np.nonzero(np.abs(det) == 2)):
        sigma = (w0[a], w1[b], w2)
        m = matrix(sigma)
        if not catch_up_free(sigma, m) or not pip(sigma):
            continue
        tot += 1
        if not normal_form(sigma):
            bad_nf.append(sigma)
        lv = coincidence_level(sigma, 0, 1)
        if lv is None:
            noncoinc.append(sigma)
        hits.append((sigma, lv))
print("L", L, "class members", tot, "normal-form violations", len(bad_nf), "NON-coincident", len(noncoinc))
print("max level", max(h[1] for h in hits))
for s in bad_nf[:5] + noncoinc[:5]:
    print(s)
