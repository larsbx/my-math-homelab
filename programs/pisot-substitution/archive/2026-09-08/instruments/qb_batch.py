import numpy as np, json, time, sys
from scipy import sparse
from scipy.sparse.linalg import eigs
import psc_core as P
import census
from overlap_residual import tile_lengths, seed_overlaps
from triple_overlap import build_triple_graph
sys.setrecursionlimit(2000000)
NMAX=int(sys.argv[1]) if len(sys.argv)>1 else 60

def tarjan(n, adj):
    idx=[None]*n; low=[0]*n; on=[False]*n; st=[]; out=[]; c=[0]
    def dfs(root):
        work=[(root,0)]
        while work:
            v,pi=work[-1]
            if pi==0: idx[v]=low[v]=c[0]; c[0]+=1; st.append(v); on[v]=True
            nbrs=adj.get(v,()); recurse=False
            if pi<len(nbrs):
                work[-1]=(v,pi+1); w=nbrs[pi]
                if idx[w] is None: work.append((w,0)); recurse=True
                elif on[w]: low[v]=min(low[v],idx[w])
            if not recurse and pi>=len(nbrs):
                if low[v]==idx[v]:
                    comp=[]
                    while True:
                        w=st.pop(); on[w]=False; comp.append(w)
                        if w==v: break
                    out.append(comp)
                work.pop()
                if work: u=work[-1][0]; low[u]=min(low[u],low[v])
    for v in range(n):
        if idx[v] is None: dfs(v)
    return out

def pf_sparse(NC):
    n=NC.shape[0]
    if n==1: return float(NC[0,0])
    if n<=4: return float(max(abs(np.linalg.eigvals(NC.toarray()))))
    try:
        return float(abs(eigs(NC.astype(float),k=1,which='LM',return_eigenvectors=False,maxiter=3000)[0]))
    except Exception:
        v=np.ones(n)
        for _ in range(1500):
            w=NC@v; nv=np.linalg.norm(w)
            if nv==0: return 0.0
            v=w/nv
        return float((v@(NC@v))/(v@v))

def pc(st):
    i,d2,j,d3,l=st; d2=np.array(d2);d3=np.array(d3);d23=d3-d2
    return (i==j and not d2.any()),(i==l and not d3.any()),(j==l and not d23.any())

if __name__=="__main__":
  _run=True
else:
  _run=False
if __name__=="__main__":
    t0=time.time();n=0;analyzed=0;closed_tr=0;pfv=0;rows=[];capped_n=0
    for s in census.enum_k3(max_len=3):
        if not census.is_pip(s)[0]: continue
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
            analyzed+=1; pf=pf_sparse(NC)
            if pf>beta+1e-4: pfv+=1
            if closed and pf>beta-1e-4:
                closed_tr+=1; rows.append({"img":[list(w) for w in s.images],"scc":len(sub),"pf":round(pf,4),"beta":round(beta,4)})
    print(json.dumps({"spec":n,"capped":capped_n,"triple_nc_sccs":analyzed,"closed_triple":closed_tr,"pf_gt_beta":pfv,"sec":round(time.time()-t0)}))
    for r in rows[:8]: print(r)

    # (extended driver appended in qb_batch2)
