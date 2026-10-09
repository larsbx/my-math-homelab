"""
Re-run using the ACTUAL float_genuine (overlap_residual.genuine_overlap), not an inline
reimplementation, and SEPARATE the t=0 / t=Li-Lj anchor cases (which are boundary by
definition) from genuine near-misses. The earlier 1202 'mismatches' were my inline predicate
disagreeing with exact on exact-anchor states; the real question is whether float_genuine
itself ever disagrees with exact_genuine.
"""
import numpy as np, sympy as sp
import psc_core as P
import census
from overlap_residual import tile_lengths as float_L, seed_overlaps, genuine_overlap as fg_real
from exact_lengths import beta_field, exact_genuine

n=0; checked=0; mismatch=0; anchor=0; genuine_nearmiss=0; minmargin_nonanchor=1e9
mismatch_cases=[]
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    n+=1
    if n>40: break
    M=P.incidence_matrix(s); fl=float_L(M)
    if fl is None: continue
    Lf=fl[0]
    try: ps,_=seed_overlaps(s,Lf)
    except Exception: continue
    if not ps: continue
    bf=None
    for (i,dt,j) in ps:
        delta=np.array(dt); 
        # exact anchor? delta==0 or delta==e_i-e_j
        e=np.zeros(len(delta),dtype=np.int64)
        is_anchor = (not delta.any())
        ed=np.zeros(len(delta),dtype=np.int64); 
        if i<len(delta): ed[i]+=1
        if j<len(delta): ed[j]-=1
        if np.array_equal(delta, ed): is_anchor=True
        fg,_=fg_real(i,delta,j,Lf,len(delta))
        checked+=1
        if bf is None: bf=beta_field(M)
        if bf is None: continue
        beta,mp,L=bf
        eg,_=exact_genuine(i,delta,j,L,beta)
        if fg!=eg:
            mismatch+=1
            if is_anchor: anchor+=1
            else:
                genuine_nearmiss+=1
                mismatch_cases.append((s.images,tuple(dt),i,j))
print(f"specimens {n}; seed overlaps checked {checked}")
print(f"float_genuine vs exact_genuine mismatches: {mismatch}")
print(f"  of which exact-anchor (t=0 or Li-Lj, boundary by def): {anchor}")
print(f"  of which GENUINE near-miss (the dangerous kind): {genuine_nearmiss}")
if mismatch_cases: print("  dangerous cases:", mismatch_cases[:6])
else: print("  -> NO dangerous mismatches: float census genuineness was SOUND.")
