#!/usr/bin/env python3
"""Exact descriptor for the Witt-stabilized octonion/Descartes bridge."""

def inv(a,p):
    if a%p==0: raise ValueError("noninvertible")
    return pow(a,-1,p)

def descartes_det(n,p):
    if p==2 or n<2 or n%p==0: raise ValueError("degenerate or unsupported Descartes form")
    return (-2*inv(n,p))%p

def is_square(a,p):
    if a%p==0: return True
    return pow(a%p,(p-1)//2,p)==1

def bridge_descriptor(n,p):
    if n<6: raise ValueError("whole-octonion bridge requires n >= 6")
    delta=descartes_det(n,p)
    k=n-6
    if k==0:
        return {"n":n,"p":p,"complement_dim":0,"complement_diag":[],
                "descartes_det":delta,"available":is_square(delta,p)}
    diag=[1]*(k-1)+[delta]
    prod=1
    for x in diag: prod=prod*x%p
    assert prod==delta
    return {"n":n,"p":p,"complement_dim":k,"complement_diag":diag,
            "descartes_det":delta,"available":True}

if __name__=="__main__":
    for n in range(6,13):
        print(bridge_descriptor(n,7))
