import itertools
from lib import pip, mat, charpoly, roots
words=[''.join(p) for k in range(1,4) for p in itertools.product('012',repeat=k)]
corpus=[s for s in itertools.product(words,repeat=3) if pip(s)]
def ev(g,x): return g[0]+g[1]*x+g[2]*x*x
def mulmod(a,b,c):
    p=[0]*5
    for i in range(3):
        for j in range(3): p[i+j]+=a[i]*b[j]
    for d in (4,3):
        k=p[d]; p[d]=0
        for i in range(3): p[d-3+i]-=k*c[i]
    return p[:3]
worst=0;tot=0;ws=None
for s in corpus:
    M=mat(s); c=charpoly(M); r=roots(c); beta=r[0].real
    # left eigvec as polys in beta: use numeric
    import cmath
    def leig(lam):
        A=[[M[i][j]-(lam if i==j else 0) for j in range(3)] for i in range(3)]
        cols=[[A[i][j] for i in range(3)] for j in range(3)]
        for u,v in ((cols[0],cols[1]),(cols[0],cols[2]),(cols[1],cols[2])):
            l=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
            if max(abs(x) for x in l)>1e-9: return l
    L=[leig(x) for x in r]
    l=[x.real for x in L[0]]; 
    if l[0]<0: l=[-x for x in l]
    # scale conjugates consistently: sigma_k(l) - recompute via normalization l[0]=1 for each
    Ls=[[x/Lk[0] for x in Lk] for Lk in L]
    pass
    pre=[[[s[a][:k].count(str(b)) for b in range(3)] for k in range(len(s[a]))] for a in range(3)]
    D={tuple(q[k]-p[k] for k in range(3)) for a in range(3) for b in range(3) for p in pre[a] for q in pre[b]}
    B=[max(abs(sum(Ls[m][k]*d[k] for k in range(3))) for d in D)/(1-abs(r[m])) for m in (1,2)]
    # coordinate bounds via inverse of Ls
    a=Ls; det=(a[0][0]*(a[1][1]*a[2][2]-a[1][2]*a[2][1])-a[0][1]*(a[1][0]*a[2][2]-a[1][2]*a[2][0])+a[0][2]*(a[1][0]*a[2][1]-a[1][1]*a[2][0]))
    inv=[[0]*3 for _ in range(3)]
    for i in range(3):
        for j in range(3):
            mm=[[a[x][y] for y in range(3) if y!=i] for x in range(3) if x!=j]
            inv[i][j]=((-1)**(i+j))*(mm[0][0]*mm[1][1]-mm[0][1]*mm[1][0])/det
    yb=[max(abs(x) for x in Ls[0]),B[0],B[1]]
    R=[sum(abs(inv[k][m])*yb[m] for m in range(3)) for k in range(3)]
    vol=1
    for x in R: vol*=2*x+1
    tot+=vol
    if vol>worst: worst=vol; ws=(s,R)
print('worst box points',worst,ws,'total',tot)
