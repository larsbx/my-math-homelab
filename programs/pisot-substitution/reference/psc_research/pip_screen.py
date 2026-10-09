"""Exact enumeration of the alphabet-3 PIP corpus (letters 1..3, image
lengths <= 3): primitivity by integer matrix powers, irreducibility by the
integer rational-root test, and the Pisot property by Sturm sequences over Q.
No floating point.  Independent Python oracle of kernel/psc/pisot.mojo."""
from __future__ import annotations

import itertools
from fractions import Fraction

def par(w):
    p=[0,0,0]
    for a in w: p[a-1]+=1
    return p
def mat(sigma): return [[par(sigma[j+1])[i] for j in range(3)] for i in range(3)]
def mul(A,B): return [[sum(A[i][k]*B[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
def primitive(M):
    P=M
    for _ in range(5): P=mul(P,M)
    return all(x>0 for r in P for x in r)
def charpoly(M):  # x^3 - T x^2 + U x - D
    T=M[0][0]+M[1][1]+M[2][2]
    U=(M[0][0]*M[1][1]-M[0][1]*M[1][0])+(M[0][0]*M[2][2]-M[0][2]*M[2][0])+(M[1][1]*M[2][2]-M[1][2]*M[2][1])
    D=(M[0][0]*(M[1][1]*M[2][2]-M[1][2]*M[2][1])-M[0][1]*(M[1][0]*M[2][2]-M[1][2]*M[2][0])+M[0][2]*(M[1][0]*M[2][1]-M[1][1]*M[2][0]))
    return T,U,D
def irreducible(T,U,D):
    """Monic integer cubic: irreducible over Q iff no integer root dividing D."""
    if D==0: return False
    f=lambda x: x**3-T*x**2+U*x-D
    for r in range(1,abs(D)+1):
        if D%r==0 and (f(r)==0 or f(-r)==0): return False
    return True

# --- exact Pisot test by Sturm sequences over Q (mirrors kernel/psc/pisot.mojo) ---
def _deg(p):
    n = len(p)
    while n > 0:
        n -= 1
        if p[n] != 0: return n
    return -1
def _eval(p,x):
    n = len(p)
    if n == 4:
        return ((p[3]*x+p[2])*x+p[1])*x+p[0]
    elif n == 3:
        return (p[2]*x+p[1])*x+p[0]
    elif n == 2:
        return p[1]*x+p[0]
    elif n == 1:
        return p[0]
    elif n == 0:
        return Fraction(0)
    acc = Fraction(0)
    for c in p[::-1]:
        acc = acc * x + c
    return acc
def _rem(a,b):
    r=list(a); db=_deg(b)
    if db < 0: return r
    inv = Fraction(1, b[db])
    while _deg(r)>=db:
        dr=_deg(r); f=r[dr]*inv
        for i in range(db+1): r[dr-db+i]-=f*b[i]
        r[dr]=Fraction(0)
    return r
def _sturm(p):
    chain=[list(p),[i*p[i] for i in range(1,len(p))]]
    while _deg(chain[-1])>0:
        neg=[-c for c in _rem(chain[-2],chain[-1])]
        if _deg(neg)<0: break
        chain.append(neg)
    return chain
def _changes(chain,x):
    last=0; n=0
    for q in chain:
        v=_eval(q,x)
        if v==0: continue
        sgn=1 if v>0 else -1
        if last and sgn!=last: n+=1
        last=sgn
    return n
def _roots_in(p,a,b):
    """Distinct real roots of p in (a,b]."""
    ch=_sturm(p); return _changes(ch,a)-_changes(ch,b)
def pisot(T,U,D):
    """Exactly one root outside the closed unit disc, real and > 1.
    Three real roots: Sturm counting. One real root: beta*|beta2|^2 = D, so
    |beta2| < 1 iff D < beta iff f(D) < 0 (beta the only real root)."""
    p=[Fraction(-D),Fraction(U),Fraction(-T),Fraction(1)]   # low-degree first
    B=Fraction(2+max(abs(T),abs(U),abs(D)))
    nreal=_roots_in(p,-B,B)
    if _roots_in(p,Fraction(1),B)!=1: return False
    if nreal==3: return _roots_in(p,Fraction(-1),Fraction(1))==2
    if nreal!=1: return False
    return D>0 and _eval(p,Fraction(D))<0


def pip_corpus():
    """All PIP substitutions on {1,2,3} with image lengths <= 3, in enumeration order."""
    words=[w for L in (1,2,3) for w in itertools.product((1,2,3),repeat=L)]
    corpus=[]
    for a in words:
        for b in words:
            for c in words:
                sigma={1:a,2:b,3:c}
                M=mat(sigma); T,U,D=charpoly(M)
                if primitive(M) and irreducible(T,U,D) and pisot(T,U,D):
                    corpus.append(sigma)
    return corpus
