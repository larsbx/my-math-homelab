import itertools, cmath
def mat(s,d=3): return [[s[j].count(str(i)) for j in range(d)] for i in range(d)]
def mul(A,B): return [[sum(A[i][k]*B[k][j] for k in range(len(B))) for j in range(len(B[0]))] for i in range(len(A))]
def primitive(M):
    P=M
    for _ in range(6): P=mul(P,M)
    return all(v>0 for row in P for v in row)
def charpoly(M):
    (a,b,c),(d,e,f),(g,h,i)=M
    tr=a+e+i; det=a*(e*i-f*h)-b*(d*i-f*g)+c*(d*h-e*g)
    c2=(a*e-b*d)+(a*i-c*g)+(e*i-f*h)
    return [1,-tr,c2,-det]
def irreducible(c):
    d=c[3]
    if d==0: return False
    for r in range(1,abs(d)+1):
        if abs(d)%r==0:
            for t in (r,-r):
                if t**3+c[1]*t*t+c[2]*t+c[3]==0: return False
    return True
def roots(c):
    z=[complex(0.4,0.9)**k for k in range(3)]
    f=lambda t: ((t+c[1])*t+c[2])*t+c[3]
    for _ in range(500):
        z=[zi-f(zi)/((zi-z[(k+1)%3])*(zi-z[(k+2)%3])) for k,zi in enumerate(z)]
    return sorted(z,key=lambda t:-abs(t))
def pip(s):
    M=mat(s)
    if not primitive(M): return False
    c=charpoly(M)
    if not irreducible(c): return False
    r=roots(c)
    return abs(r[0])>1 and abs(r[1])<1 and abs(r[2])<1
def two_letter(s,n=8):
    w='0'
    seen=set()
    words={a for a in '012'}
    lang=set()
    # iterate images of all 2-letter words starting from letters
    frontier={s[a][k:k+2] for a in range(3) for k in range(len(s[a])-1)}
    lang|=frontier
    while True:
        new=set()
        for u in lang:
            img=''.join(s[int(ch)] for ch in u)
            for k in range(len(img)-1): new.add(img[k:k+2])
        if new<=lang: return lang
        lang|=new
