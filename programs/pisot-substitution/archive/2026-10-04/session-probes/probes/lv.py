exec(open("a3.py").read().split("tab=collections")[0])
def mul(a,b): return [[sum(a[i][k]*b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
def sub(w,n,a):
    x=[str(a)]
    for _ in range(n): x=[c for l in x for c in w[int(l)]]
    return x
def agrees(w,n):
    m=M(w)
    pw=[[[1,0,0],[0,1,0],[0,0,1]]]
    for k in range(n+1): pw.append(mul(pw[-1],m))
    for a in range(3):
        for k in range(n+1): pass
        # exact level of prefix boundary j of sigma^n(a)
        lev={}
        for k in range(n,-1,-1):
            x=sub(w,n-k,a)
            for j in range(1,len(x)):
                v=ab(x[:j]); v=[sum(pw[k][i][l]*v[l] for l in range(3)) for i in range(3)]
                lev.setdefault(tuple(v),k)
        for v,k in lev.items():
            val=max(kk for kk in range(n+1) if inLam(pw[kk],list(v)) ) if True else 0
            if val!=k: return False
    return True
res=collections.Counter()
for key,w in words.items():
    m=M(w)
    pi=[ab(x[:i]) for x in w for i in range(1,len(x))]
    free = not any(inLam(m,v) for v in pi)
    res[(abs(det(m)),free,agrees(w,5))]+=1
print(res)
