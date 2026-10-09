#!/usr/bin/env python3
"""Exact finite checks for N3-T02."""
from itertools import permutations
from fractions import Fraction

def validate_action(perms):
    n=len(perms[0]); ident=tuple(range(n))
    assert ident in perms and all(sorted(p)==list(range(n)) for p in perms)
    P=set(perms)
    assert all(tuple(p[q[i]] for i in range(n)) in P for p in perms for q in perms)

def orbits(perms):
    validate_action(perms); unseen=set(range(len(perms[0]))); out=[]
    while unseen:
        x=min(unseen); o={p[x] for p in perms}; out.append(o); unseen-=o
    return out

def quotient_occupancies(perms,labels,bins):
    obs=orbits(perms); out=[0]*bins
    for o in obs:
        vals={labels[x] for x in o}
        if len(vals)!=1: raise ValueError("labels are not invariant")
        out[vals.pop()]+=1
    return out

def burnside_occupancies(perms,labels,bins):
    validate_action(perms); g=len(perms); out=[]
    for s in range(bins):
        fixed=sum(1 for p in perms for x,y in enumerate(p) if x==y and labels[x]==s)
        out.append(Fraction(fixed,g))
    return out

def falling(n,k):
    z=1
    for j in range(k): z*=n-j
    return z

def quotient_rhs(perms,labels,k):
    obs=orbits(perms); reps=[min(o) for o in obs]
    return sum(1 for xs in permutations(reps,k) if len({labels[x] for x in xs})==1)

def verify():
    cases=0
    examples=[
      ([(0,1,2,3)],(0,0,1,1),2),
      ([(0,1,2,3),(1,0,3,2)],(0,0,1,1),2),
      ([(0,1,2,3),(1,0,2,3)],(0,0,1,1),2),
      ([(0,1,2),(1,2,0),(2,0,1)],(0,0,0),1)
    ]
    for perms,labels,bins in examples:
      q=quotient_occupancies(perms,labels,bins)
      assert [Fraction(x) for x in q]==burnside_occupancies(perms,labels,bins)
      for k in range(1,len(orbits(perms))+1):
        assert sum(falling(x,k) for x in q)==quotient_rhs(perms,labels,k)
        cases+=1
    return cases
if __name__=="__main__": print(f"verified {verify()} orbit-collision cases")
