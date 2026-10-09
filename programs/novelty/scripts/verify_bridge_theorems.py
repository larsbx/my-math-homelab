#!/usr/bin/env python3
"""Finite exhaustive regression for N3-T01; not a proof of asymptotics."""
from itertools import product, permutations

def falling(n,k):
    out=1
    for j in range(k): out*=n-j
    return out

def occupancies(images,bins):
    out=[0]*bins
    for s in images: out[s]+=1
    return out

def lhs(images,bins,k):
    return sum(falling(m,k) for m in occupancies(images,bins))

def rhs(images,k):
    total=0
    for xs in permutations(range(len(images)),k):
        if len({images[i] for i in xs})==1: total+=1
    return total

def verify(max_x=5,max_s=3,max_k=4):
    cases=0
    for nx in range(max_x+1):
      for ns in range(1,max_s+1):
        for images in product(range(ns),repeat=nx):
          for k in range(1,min(max_k,nx)+1):
            assert lhs(images,ns,k)==rhs(images,k)
            cases+=1
    return cases

if __name__=="__main__":
    print(f"verified {verify()} finite map/moment cases")
