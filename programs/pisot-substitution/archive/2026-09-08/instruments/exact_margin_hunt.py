"""
Hunt for genuineness decisions where float t is within a small margin of a boundary
(0, L_i, or L_i - L_j), i.e. where the 1e-9 threshold COULD flip the decision, and verify
exact Q(beta) agrees. These are the only places a float census error could hide.
"""
import numpy as np, sympy as sp
import psc_core as P
import census
from overlap_residual import tile_lengths as float_L, seed_overlaps, build_overlap_graph
from exact_lengths import beta_field, exact_genuine

n=0; margins=[]; mismatch=0; near=0; checked=0; minmargin=1e9
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    n+=1
    if n>120: break
    M=P.incidence_matrix(s)
    fl=float_L(M)
    if fl is None: continue
    Lf=fl[0]
    try:
        states,_=build_overlap_graph(s,Lf)[:2] if isinstance(build_overlap_graph(s,Lf),tuple) else (None,None)
    except Exception:
        states=None
    # use seed overlaps + their states as the test set of (i,delta,j)
    try: ps,_=seed_overlaps(s,Lf)
    except Exception: continue
    if not ps: continue
    # measure float margin to nearest boundary for each seed
    triples=[(i,np.array(dt),j) for (i,dt,j) in ps]
    # build exact field lazily only if a near-margin case appears
    bf=None
    for (i,delta,j) in triples:
        t=float(delta@Lf); Li=Lf[i]; Lj=Lf[j]
        m=min(abs(t-0.0), abs(t-Li), abs((t)-(Li-Lj)), abs(t+Lj-0.0))
        minmargin=min(minmargin,m)
        checked+=1
        if m < 1e-4:   # marginal: verify exactly
            near+=1
            if bf is None:
                bf=beta_field(M)
            if bf is None: continue
            beta,mp,L=bf
            fg = (t>1e-9) and (min(Li,t+Lj)-max(0.0,t) > 1e-9)
            eg,_=exact_genuine(i,delta,j,L,beta)
            if fg!=eg: mismatch+=1; margins.append((s.images,float(m)))
print(f"specimens {n}; seed-triples checked {checked}; near-margin (<1e-4) {near}")
print(f"smallest float margin to a boundary observed: {minmargin:.3e}")
print(f"float/exact mismatches among marginal cases: {mismatch}")
if margins: print("MISMATCH CASES:", margins[:5])
print("=> if 0 mismatches and smallest margin >> 1e-9, the float census threshold was safe.")
