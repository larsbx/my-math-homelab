"""Is R(C)/L_rec bounded or unbounded? Correlate the ratio with beta, cycle maxlen, |beta_2|.
If it tracks maxlen (which grows with cycle complexity), the Collar bound by a per-sigma
constant L_sigma is FALSE — R is a per-cycle quantity not capped by recognizability alone."""
import numpy as np, statistics, json
import psc_core as P, balanced_pair as B
import census
from scc_matrix import recurrent_sccs
from collar_test import recognizability_window, scc_radius

nn=0; data=[]
for sig in census.enum_k3(max_len=3):
    if not census.is_pip(sig)[0]: continue
    nn+=1
    if nn>80: break
    n=sig.k
    try:
        Lrec=recognizability_window(sig, maxL=25, Nlev=5)
        res=B.build_bpa(sig,B.standard_seeds(sig),max_states=4000)
    except Exception: continue
    if not res.finite: continue
    M=P.incidence_matrix(sig); ev=sorted(abs(np.linalg.eigvals(M)),reverse=True)
    beta=ev[0]; b2=ev[1] if len(ev)>1 else 0
    for comp in recurrent_sccs(res):
        if len(comp)<2: continue
        R=scc_radius(sig,res,comp,n)
        cml=max(max(len(res.states[s][0]),len(res.states[s][1])) for s in comp)
        data.append(dict(R=R,Lrec=Lrec,ratio=R/max(1,Lrec),cml=cml,beta=beta,b2=b2))
# does ratio correlate with cml (cycle maxlen)?
rats=[d['ratio'] for d in data]; cmls=[d['cml'] for d in data]; Rs=[d['R'] for d in data]
import numpy as np
print(json.dumps(dict(
  n=len(data), max_ratio=round(max(rats),3),
  corr_ratio_cml=round(float(np.corrcoef(rats,cmls)[0,1]),3),
  corr_R_cml=round(float(np.corrcoef(Rs,cmls)[0,1]),3),
  R_eq_cml_minus1_violations=sum(1 for d in data if d['R']>d['cml']-1),
  R_le_cml_violations=sum(1 for d in data if d['R']>d['cml']))))
# the proven bound R<=(maxlen-1)+B0 from radius_closed_bound: is R<=cml-1 alone enough?
print("If R<=cml-1 has 0 violations, the SOUND per-CYCLE bound is R(C)<=maxlen(C)-1, NOT a")
print("per-sigma L_sigma bound. Collar Lemma (per-sigma constant) is then FALSE; the honest")
print("statement is the per-cycle maxlen bound (already in radius_closed_bound.py).")
