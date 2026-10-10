exec(open("a2.py").read().split("cnt=collections")[0])
def adj(m):
    c=lambda i,j: ((-1)**(i+j))*(m[(i+1)%3 if False else [k for k in range(3) if k!=i][0]][[k for k in range(3) if k!=j][0]]*m[[k for k in range(3) if k!=i][1]][[k for k in range(3) if k!=j][1]]-m[[k for k in range(3) if k!=i][0]][[k for k in range(3) if k!=j][1]]*m[[k for k in range(3) if k!=i][1]][[k for k in range(3) if k!=j][0]])
    return [[c(j,i) for j in range(3)] for i in range(3)]
def inLam(m,v):
    d=det(m); A=adj(m)
    return all(sum(A[i][k]*v[k] for k in range(3))%d==0 for i in range(3))
def ab(x):
    v=[0,0,0]
    for c in x: v[int(c)]+=1
    return v
tab=collections.Counter()
for k,w in words.items():
    m=M(w)
    pi=[ab(x[:i]) for x in w for i in range(1,len(x))]
    obstructed = not any(inLam(m,v) for v in pi)
    status = 'pass' if k not in fails else ('total' if fails[k][1]==0 else 'partial')
    tab[(obstructed,status)]+=1
print(sorted(tab.items()))
