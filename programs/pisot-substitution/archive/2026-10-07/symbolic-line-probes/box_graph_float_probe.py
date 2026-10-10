"""EXPLORATORY float prototype of the Proposition V box graph (not a certificate)."""
import numpy as np, sys
from box_radii_float_probe import member, mat, radii
X,C,Y=0,1,2
EPS=1e-9
def analyse(s):
    M=mat(s).astype(np.int64); Mf=M.astype(float)
    ev,vl=np.linalg.eig(Mf.T); k=np.argmax(ev.real); beta=ev[k].real
    ell=np.abs(vl[:,k].real); ell/=ell.min()
    pre=[[np.array([w[:n].count(a) for a in range(3)]) for n in range(len(w))] for w in s]
    _,_,R=radii(s)
    R=[max(x,1) for x in R]
    # start set: all (a,b,w) with |w_m|<=R_m real
    def real(a,b,w):
        t=ell@w; return -ell[b]+EPS < t < ell[a]-EPS
    def children(a,b,w):
        out=[]
        Mw=M@w
        for p in range(len(s[a])):
            for q in range(len(s[b])):
                w2=Mw+pre[b][q]-pre[a][p]; a2=s[a][p]; b2=s[b][q]
                # sub-tiles: top [P, P+l_a2), bottom [beta t + Q, ...): overlap iff child real
                if real(a2,b2,w2): out.append((a2,b2,tuple(w2)))
        return out
    states={}; stack=[]
    import itertools
    for w in itertools.product(*[range(-r,r+1) for r in R]):
        w=np.array(w)
        for a in range(3):
            for b in range(3):
                if real(a,b,w):
                    key=(a,b,tuple(w)); 
                    if key not in states: states[key]=None; stack.append(key)
    adj={}
    while stack:
        v=stack.pop()
        a,b,w=v
        if a==b and w==(0,0,0): adj[v]=[]; continue
        ch=children(a,b,np.array(w)); adj[v]=ch
        for c in ch:
            if c not in states: states[c]=None; stack.append(c)
    # SCCs (iterative Tarjan)
    idx={}; low={}; on=set(); st=[]; comps=[]; n=0
    for root in adj:
        if root in idx: continue
        work=[(root,0)]
        while work:
            v,i=work.pop()
            if i==0:
                idx[v]=low[v]=n; n+=1; st.append(v); on.add(v)
            ch=adj[v]
            if i<len(ch):
                work.append((v,i+1)); c=ch[i]
                if c not in idx: work.append((c,0))
                elif c in on: low[v]=min(low[v],idx[c])
                continue
            for c in ch:
                if c in on: low[v]=min(low[v],low[c])
            if low[v]==idx[v]:
                comp=[]
                while True:
                    x=st.pop(); on.discard(x); comp.append(x)
                    if x==v: break
                if len(comp)>1 or v in adj[v]: comps.append(comp)
    rec=[v for c in comps for v in c if not (v[0]==v[1] and v[2]==(0,0,0))]
    # hit depth: BFS backwards from offset-zero vertices
    zero={v for v in adj if v[2]==(0,0,0)}
    rev={}
    for v,ch in adj.items():
        for c in ch: rev.setdefault(c,[]).append(v)
    depth={v:0 for v in zero}; frontier=list(zero)
    while frontier:
        nf=[]
        for v in frontier:
            for u in rev.get(v,[]):
                if u not in depth: depth[u]=depth[v]+1; nf.append(u)
        frontier=nf
    fails=[v for v in rec if v not in depth]
    W=np.array([v[2] for v in rec]) if rec else np.zeros((1,3),int)
    return set(rec), dict(beta=round(beta,3),R=R,states=len(adj),rec=len(rec),maxabs=list(np.abs(W).max(axis=0)),deep=max(depth.get(v,-1) for v in rec) if rec else -1,fails=len(fails))
if __name__=='__main__':
    ends=(X,X,C,X)
    for pqr in sys.argv[1:]:
        p,q,r=map(int,pqr.split(','))
        print((p,q,r),analyse(member(p,q,r,ends))[1],flush=True)
