import itertools, cmath, sys
from lib import mat, charpoly, roots, pip
def left_eig(M, lam):
    # solve l (M - lam I) = 0 : columns; take cross product of two columns of (M-lam I) (as rows of transpose)
    A=[[M[i][j]-(lam if i==j else 0) for j in range(3)] for i in range(3)]
    c0=[A[i][0] for i in range(3)]; c1=[A[i][1] for i in range(3)]; c2=[A[i][2] for i in range(3)]
    for u,v in ((c0,c1),(c0,c2),(c1,c2)):
        l=[u[1]*v[2]-u[2]*v[1], u[2]*v[0]-u[0]*v[2], u[0]*v[1]-u[1]*v[0]]
        if max(abs(x) for x in l)>1e-9: return l
def box_graph(s):
    M=mat(s); c=charpoly(M); r=roots(c)
    beta=r[0].real
    L=[left_eig(M,lam) for lam in r]
    l=[x.real for x in L[0]]
    if l[0]<0: l=[-x for x in l]
    l=[x/min(l) for x in l]
    L[0]=l
    pre=[[ [s[a][:k].count(str(b)) for b in range(3)] for k in range(len(s[a]))] for a in range(3)]
    D={tuple(q[k]-p[k] for k in range(3)) for a in range(3) for b in range(3) for p in pre[a] for q in pre[b]}
    B=[None]+[1.02*max(abs(sum(L[m][k]*d[k] for k in range(3))) for d in D)/(1-abs(r[m]))+1e-9 for m in (1,2)]
    lmax=max(l)
    # coordinate bound: w = sum_m y_m * dual_m ; dual basis = inverse of matrix rows L
    import copy
    Lm=[list(map(complex,row)) for row in L]
    # invert 3x3 complex
    a=Lm; det=(a[0][0]*(a[1][1]*a[2][2]-a[1][2]*a[2][1])-a[0][1]*(a[1][0]*a[2][2]-a[1][2]*a[2][0])+a[0][2]*(a[1][0]*a[2][1]-a[1][1]*a[2][0]))
    inv=[[0]*3 for _ in range(3)]
    for i in range(3):
        for j in range(3):
            m=[[a[x][y] for y in range(3) if y!=i] for x in range(3) if x!=j]
            inv[i][j]=((-1)**(i+j))*(m[0][0]*m[1][1]-m[0][1]*m[1][0])/det
    yb=[lmax*1.01, B[1], B[2]]
    R=[int(sum(abs(inv[k][m])*yb[m] for m in range(3)))+1 for k in range(3)]
    t=lambda w: sum(l[k]*w[k] for k in range(3))
    def inbox(w):
        return all(abs(sum(L[m][k]*w[k] for k in range(3)))<=B[m] for m in (1,2))
    V=set()
    for w in itertools.product(*[range(-x,x+1) for x in R]):
        if not inbox(w): continue
        tw=t(w)
        for i in range(3):
            for j in range(3):
                if -l[j]+1e-12 < tw < l[i]-1e-12: V.add((i,j,w))
    def children(v):
        i,j,w=v
        Mw=[sum(M[k][m]*w[m] for m in range(3)) for k in range(3)]
        out=[]
        for p_idx,p in enumerate(pre[i]):
            a=int(s[i][p_idx]); pa=t(p)
            for q_idx,q in enumerate(pre[j]):
                b=int(s[j][q_idx])
                w2=tuple(Mw[k]+q[k]-p[k] for k in range(3)); t2=t(w2)
                if -l[b]+1e-12 < t2 < l[a]-1e-12: out.append((a,b,w2))
        return out
    # closure
    stack=list(V); allv=set(V); E={}
    while stack:
        v=stack.pop(); ch=children(v); E[v]=ch
        for u in ch:
            if u not in allv: allv.add(u); stack.append(u)
    # vertices with offset-zero descendant: reverse BFS
    rev={v:[] for v in allv}
    for v,ch in E.items():
        for u in ch: rev[u].append(v)
    good={v for v in allv if v[2]==(0,0,0)}
    st=list(good)
    while st:
        u=st.pop()
        for v in rev[u]:
            if v not in good: good.add(v); st.append(v)
    # first left-aligned depths (BFS reverse from offset zero)
    dist={v:0 for v in allv if v[2]==(0,0,0)}
    from collections import deque
    dq=deque(dist)
    while dq:
        u=dq.popleft()
        for v in rev[u]:
            if v not in dist: dist[v]=dist[u]+1; dq.append(v)
    # SCC on noncoincidence subgraph (coincidences have no out-edges)
    adj={v:([] if (v[0]==v[1] and v[2]==(0,0,0)) else E.get(v,[])) for v in allv}
    idx={};low={};on=set();st=[];cnt=[0];rec=[]
    for root in allv:
        if root in idx: continue
        work=[(root,0)]
        while work:
            v,i=work.pop()
            if i==0:
                idx[v]=low[v]=cnt[0];cnt[0]+=1;st.append(v);on.add(v)
            recurse=False
            ch=adj[v]
            while i<len(ch):
                u=ch[i];i+=1
                if u not in idx:
                    work.append((v,i));work.append((u,0));recurse=True;break
                elif u in on: low[v]=min(low[v],idx[u])
            if recurse: continue
            if low[v]==idx[v]:
                comp=[]
                while True:
                    x=st.pop();on.discard(x);comp.append(x)
                    if x==v: break
                if len(comp)>1 or v in adj[v]: rec.extend(comp)
            if work:
                p=work[-1][0]; low[p]=min(low[p],low[v])
    return len(allv)-len(good), len(rec), max(dist.get(v,-1) for v in rec) if rec else -1
if __name__=='__main__':
    for s in [('01','02','0'),('1','222','0222'),('1','021','001')]:
        print(s, box_graph(s))
