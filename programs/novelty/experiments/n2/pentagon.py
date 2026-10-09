#!/usr/bin/env python3
"""Finite Cayley-Dickson pentagon experiment with no analytic normalization."""
from itertools import product

def add(x,y,p): return tuple((a+b)%p for a,b in zip(x,y))
def neg(x,p): return tuple((-a)%p for a in x)
def sub(x,y,p): return add(x,neg(y,p),p)

def conj(x,p):
    if len(x)==1: return x
    h=len(x)//2
    return conj(x[:h],p)+neg(x[h:],p)

def mul(x,y,p):
    if len(x)==1: return ((x[0]*y[0])%p,)
    h=len(x)//2; a,b=x[:h],x[h:]; c,d=y[:h],y[h:]
    return sub(mul(a,c,p),mul(conj(d,p),b,p),p)+add(mul(d,a,p),mul(b,conj(c,p),p),p)

def assoc(a,b,c,p): return sub(mul(a,mul(b,c,p),p),mul(mul(a,b,p),c,p),p)

def vertices(a,b,c,d,p):
    return (
      mul(mul(mul(a,b,p),c,p),d,p),
      mul(mul(a,mul(b,c,p),p),d,p),
      mul(a,mul(mul(b,c,p),d,p),p),
      mul(a,mul(b,mul(c,d,p),p),p),
      mul(mul(a,b,p),mul(c,d,p),p),
    )

def boundary_terms(a,b,c,d,p):
    return (
      mul(assoc(a,b,c,p),d,p),
      assoc(a,mul(b,c,p),d,p),
      mul(a,assoc(b,c,d,p),p),
      neg(assoc(a,b,mul(c,d,p),p),p),
      neg(assoc(mul(a,b,p),c,d,p),p),
    )

def boundary(a,b,c,d,p):
    z=(0,)*len(a)
    for term in boundary_terms(a,b,c,d,p): z=add(z,term,p)
    return z

def basis(dim):
    return [tuple(1 if i==j else 0 for i in range(dim)) for j in range(dim)]

def experiment(p=3):
    bs=basis(8); checked=nonflat=0; witness=None
    for a,b,c,d in product(bs,repeat=4):
        terms=boundary_terms(a,b,c,d,p)
        assert boundary(a,b,c,d,p)==(0,)*8
        if any(any(t) for t in terms):
            nonflat+=1
            if witness is None: witness=(a,b,c,d,vertices(a,b,c,d,p),terms)
        checked+=1
    return {"p":p,"basis_quadruples":checked,"nonflat_boundaries":nonflat,"witness":witness}

if __name__=="__main__":
    r=experiment()
    print(f"p={r['p']} checked={r['basis_quadruples']} nonflat={r['nonflat_boundaries']}")
