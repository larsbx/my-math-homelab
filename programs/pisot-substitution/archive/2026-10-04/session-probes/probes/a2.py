exec(open("feat.py").read())
def M(w):
    m=[[0]*3 for _ in range(3)]
    for a,x in enumerate(w):
        for c in x: m[int(c)][a]+=1
    return m
def det(m):
    return (m[0][0]*(m[1][1]*m[2][2]-m[1][2]*m[2][1])-m[0][1]*(m[1][0]*m[2][2]-m[1][2]*m[2][0])+m[0][2]*(m[1][0]*m[2][1]-m[1][1]*m[2][0]))
def disc(m):
    tr=m[0][0]+m[1][1]+m[2][2]
    c2=sum(m[i][i]*m[j][j]-m[i][j]*m[j][i] for i in range(3) for j in range(i+1,3))
    d=det(m); a,b,c=-tr,c2,-d
    return 18*a*b*c-4*a**3*c+a*a*b*b-4*b**3-27*c*c
cnt=collections.Counter(); al=collections.Counter()
for k,w in words.items():
    m=M(w); tag=(abs(det(m)), 'cx' if disc(m)<0 else 're')
    al[tag]+=1
    if k in fails: cnt[(tag,'total' if fails[k][1]==0 else 'partial')]+=1
print(sorted(al.items())); print(sorted(cnt.items()))
