import itertools
from collections import deque, Counter
from multiprocessing import Pool
from lib import pip
src=open('mine.py').read()
i=src.index('    # potentials'); j=src.index("if __name__=='__main__':")
src=src[:i]+'''    return M,r,lt,Ls,sig,E,rec,allv,t,pre
'''+src[j:].split("if __name__=='__main__':")[0]
ns={}; exec(src,ns)
TOL=1e-7
def births(s):
    M,r,lt,Ls,sig,E,rec,allv,t,pre=ns['analyse'](s)
    beta=r[0].real
    # children with prefix positions
    def kids(v):
        i,j,w=v
        if i==j and w==(0,0,0): return []
        Mw=[sum(M[k][m]*w[m] for m in range(3)) for k in range(3)]
        out=[]
        for pi_,p in enumerate(pre[i]):
            P=sum(lt[k]*p[k] for k in range(3))
            for qi,q in enumerate(pre[j]):
                w2=tuple(Mw[k]+q[k]-p[k] for k in range(3)); a,b=int(s[i][pi_]),int(s[j][qi]); t2=t(w2)
                if -lt[b]+1e-12<t2<lt[a]-1e-12: out.append(((a,b,w2),P))
        return out
    K={v:kids(v) for v in allv}
    rev={v:[] for v in allv}
    for v,ch in K.items():
        for u,P in ch: rev[u].append(v)
    dist={v:0 for v in allv if v[2]==(0,0,0)}; nxt={}
    dq=deque(dist)
    while dq:
        u=dq.popleft()
        for x in rev[u]:
            if x not in dist: dist[x]=dist[u]+1; dq.append(x)
    stats=Counter()
    for v in rec:
        if v[2]==(0,0,0) or v[0]==v[1]: 
            if v[2]==(0,0,0): continue
        m=dist[v]
        # greedy path along dist-decreasing children
        path=[v]; tops=[]
        x=v
        while dist[x]>0:
            for u,P in K[x]:
                if dist.get(u,10**9)==dist[x]-1: x=u; tops.append(P); path.append(u); break
        # y relative to top-tile start at level m is 0; go up
        y=0.0; kA=m; kB=m
        for lev in range(m,-1,-1):
            node=path[lev]; tn=t(node[2])
            if abs(y)<TOL: kA=lev
            if abs(y-tn)<TOL: kB=lev
            if lev>0: y=(y+tops[lev-1])/beta
        kind='simultaneous' if kA==m and kB==m else 'catch-up'
        cross='cross' if v[0]!=v[1] else 'same'
        stats[(cross,kind)]+=1
        stats[(cross,'early', min(kA,kB))]+=1 if kind=='catch-up' else 0
    return s,dict(stats)
if __name__=='__main__':
    for s in [('1','222','0222'),('1','021','001'),('210','0','110'),('1','2','01')]:
        res=births(s)[1]
        print(s,{k:v for k,v in res.items() if v})
