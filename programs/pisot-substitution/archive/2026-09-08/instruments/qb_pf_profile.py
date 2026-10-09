import numpy as np, json, time, sys
from scipy import sparse
from scipy.sparse.linalg import eigs
import psc_core as P
import census
from overlap_residual import tile_lengths, seed_overlaps
from triple_overlap import build_triple_graph
sys.setrecursionlimit(2000000)
from qb_batch import tarjan, pf_sparse, pc

t0=time.time();n=0;analyzed=0;closed_tr=0;pfv=0;capped_n=0
pf_over_beta=[]  # PF(N_C^triple)/beta for each nc SCC
START=int(sys.argv[1]) if len(sys.argv)>1 else 0
NMAX=int(sys.argv[2]) if len(sys.argv)>2 else 120
seen=0
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    seen+=1
    if seen<=START: continue
    n+=1
    if n>NMAX or time.time()-t0>800: break
    L=tile_lengths(P.incidence_matrix(s))
    if isinstance(L,tuple): L=L[0]
    beta=max(abs(np.linalg.eigvals(P.incidence_matrix(s))))
    try: ps,_=seed_overlaps(s,L)
    except Exception: continue
    if not ps: continue
    res=build_triple_graph(s,L,ps)
    if res is None: continue
    states,edges,capped=res
    if capped: capped_n+=1; continue
    adj={u:[v for v,_ in e] for u,e in edges.items()}
    nc=set(i for i,st in enumerate(states) if not any(pc(st)))
    for comp in tarjan(len(states),adj):
        cs=set(comp)
        if not (len(comp)>1 or any(v in cs for v in adj.get(comp[0],()))): continue
        sub=[v for v in comp if v in nc]
        if not sub: continue
        sidx={v:a for a,v in enumerate(sub)}
        ri=[];ci=[];da=[];closed=True
        for v in sub:
            for w,m in edges.get(v,()):
                if w in sidx: ri.append(sidx[v]);ci.append(sidx[w]);da.append(m)
                if w not in cs or w not in nc: closed=False
        NC=sparse.csr_matrix((da,(ri,ci)),shape=(len(sub),len(sub)))
        analyzed+=1; pf=pf_sparse(NC); pf_over_beta.append(pf/beta)
        if pf>beta+1e-4: pfv+=1
        if closed and pf>beta-1e-4: closed_tr+=1
pob=np.array(pf_over_beta) if pf_over_beta else np.array([0])
print(json.dumps({"spec":n,"capped":capped_n,"triple_nc_sccs":analyzed,
  "closed_triple":closed_tr,"pf_gt_beta":pfv,
  "pf/beta_max":round(float(pob.max()),4),"pf/beta_median":round(float(np.median(pob)),4),
  "pf/beta_min":round(float(pob.min()),4),"frac_above_0.9":round(float((pob>0.9).mean()),3),
  "sec":round(time.time()-t0)}))
