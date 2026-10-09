"""Normal-form sweep: all 16 endings, p,q,r <= N, |det|=2, PIP.
For each member of the four representative classes: evaluate the lemma
that claims it (named position, checked on the words), collect the
uncovered set, and decide {x,c} with the independent decider for EVERY member."""
import sys
from common import *
N = int(sys.argv[1])
X, C, Y = 0, 1, 2
def sig(p, q, r, sx, sc, t, sy):
    return ((X,)+(Y,)*p+(sx,), (C,)+(Y,)*q+(sc,), (t,)+(Y,)*r+(sy,))
CLS = {'A': (X, X, X, C), 'B': (X, X, C, X), 'C': (X, X, C, C), 'D': (C, X, C, C)}
def lemma(cls, p, q, r, s):
    if cls in 'BC':
        if p > q and ((r >= 1 and q >= 1) or (r == q == 0 and s[2][-1] == X)):
            return 2, (p+2) + q*(r+2) + 1
    if cls == 'D':
        if abs(p-q) == 1 and min(p, q) >= 1 and r >= 2:
            return 2, p+3 if p == q+1 else p+4
    if cls == 'A':
        if p > q and abs(r-q) == 1 and (p, q, r) != (1, 0, 1) and not (q == 1 and r == 0 and p >= 3) and not (q == 2 and r == 1 and p >= 4):
            return 3, (p+q+6+q*(r+2)) if r == q+1 else (p+q+5+q*(r+2))
    return None
uncov = []; failed_lemma = []; noncoinc = []; members = 0; maxlv = 0
for cls, e in CLS.items():
    for p in range(N+1):
        for q in range(N+1):
            for r in range(N+1):
                s = sig(p, q, r, *e)
                if abs(det3(matrix(s))) != 2 or not pip(s):
                    continue
                members += 1
                L = lemma(cls, p, q, r, s)
                if L is None:
                    uncov.append((cls, p, q, r))
                elif not shared_tile_at(s, L[0], X, C, L[1]):   # position = length of the shared prefix
                    failed_lemma.append((cls, p, q, r, L))
                if max(p, q, r) <= 14 or L is None:
                    lv = coincidence_level(s, X, C)
                    if lv is None: noncoinc.append((cls, p, q, r))
                    else: maxlv = max(maxlv, lv)
print("N", N, "PIP |det|=2 members (4 reps)", members)
print("lemma positions failing", len(failed_lemma), failed_lemma[:5])
print("uncovered", len(uncov), sorted(uncov))
print("non-coincident", noncoinc, "max level", maxlv)
