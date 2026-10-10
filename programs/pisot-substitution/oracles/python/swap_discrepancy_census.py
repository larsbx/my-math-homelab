"""Exact swap-discrepancy census.

Screens all 3-letter substitutions (letters 1..3) with image lengths <= 3 for
primitivity, irreducibility and the Pisot property (all exact: integer
matrix powers, rational-root test, Sturm sequences over Q; no floating point),
builds the reachable
balanced-pair graph from the three swap seeds (cap 20000 states), and reports
the maximum discrepancy over reachable states.  Independent Python oracle for
the canonical Mojo kernel kernel/swap_discrepancy_census.mojo.  Finite evidence
only; see
sources/issue-45/g1b1-bounded-discrepancy-reconstruction.md.
"""
import sys, time
sys.path.insert(0, str(__import__('pathlib').Path(__file__).resolve().parents[2] / 'reference'))
from psc_research.bpa import build_bpa

from psc_research.pip_screen import pip_corpus

corpus=pip_corpus()
print("PIP corpus size:",len(corpus),flush=True)

def disc(state):
    u,v=state; p=[0,0,0]; q=[0,0,0]; best=0
    for x,y in zip(u,v):
        p[x-1]+=1; q[y-1]+=1
        best=max(best,max(abs(p[i]-q[i]) for i in range(3)))
    return best

t0=time.time(); overall=0; hist={}; capped=0; nstates=0; maxlen=0
for idx,sigma in enumerate(corpus):
    try:
        g=build_bpa(sigma,max_states=20000)
    except RuntimeError:
        capped+=1; print("CAPPED",idx,sigma,flush=True); continue
    m=0
    for s in g:
        nstates+=1
        d=disc(s)
        if d>m: m=d
        if len(s[0])>maxlen: maxlen=len(s[0])
    hist[m]=hist.get(m,0)+1
    if m>overall:
        overall=m; print("new max",m,"at",idx,sigma,flush=True)
    if idx%250==0: print("progress",idx,"elapsed",round(time.time()-t0),"s",flush=True)
print("DONE capped",capped,"states",nstates,"overall max Disc",overall,"max state length",maxlen)
print("histogram of per-substitution max Disc:",sorted(hist.items()))
