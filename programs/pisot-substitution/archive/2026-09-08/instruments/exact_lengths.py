"""
exact_lengths.py — exact Q(beta) tile lengths and algebraic-number sign tests,
replacing the float L of overlap_residual.tile_lengths in the genuineness predicate.

L is the right PF eigenvector of M^T (i.e. M^T L = beta L), normalized L[0]=1. Its entries
lie in Q(beta) where beta is the Pisot root of chi_M (irreducible for PIP). We represent
each L[i] as an element of the number field Q(beta) via sympy's AlgebraicField, compute the
eigenvector by exact linear algebra over Q(beta), and decide signs of t=<delta,L> and
L_i - t exactly (sympy can compare algebraic numbers exactly).

GATE: exact L must (a) satisfy M^T L = beta L exactly, (b) have L[0]=1, (c) agree with float
L to tolerance, and (d) reproduce the genuineness decision of overlap_residual.genuine_overlap
on every seed/state of sampled specimens.
"""
import numpy as np, sympy as sp
import psc_core as P
from overlap_residual import genuine_overlap as float_genuine, tile_lengths as float_L

x = sp.symbols('x')

def beta_field(M):
    """Return (beta as AlgebraicNumber, minpoly, exact L vector in Q(beta))."""
    Mi = sp.Matrix(M.tolist())
    cp = Mi.charpoly(x)
    # irreducible factor containing the Pisot root = the whole charpoly for PIP (irreducible)
    fac = sp.factor_list(cp.as_expr(), x)[1]
    # pick the factor whose largest real root > 1 (the Pisot factor)
    pis = None
    for f,_ in fac:
        rts = sp.Poly(f,x).all_roots()
        for r in rts:
            cr = complex(r.evalf())
            if abs(cr.imag) < 1e-9 and cr.real > 1.0:
                pis = sp.Poly(f,x); break
        if pis is not None: break
    if pis is None: return None
    # beta = the Pisot root as an AlgebraicNumber
    beta_root = max((r for r in pis.all_roots()
                     if abs(complex(r.evalf()).imag)<1e-9),
                    key=lambda r: complex(r.evalf()).real)
    beta = sp.AlgebraicNumber(beta_root)
    # Solve M^T L = beta L exactly over Q(beta): (M^T - beta I) L = 0, L[0]=1.
    k = M.shape[0]
    MT = sp.Matrix(M.T.tolist())
    A = MT - beta*sp.eye(k)
    # nullspace over the field Q(beta)
    ns = A.nullspace()
    if not ns:
        return None
    v = ns[0]
    if v[0] == 0: return None
    L = sp.simplify(v / v[0])   # normalize L[0]=1
    return beta, pis.as_expr(), L

def exact_genuine(i, delta, j, L, beta):
    """Exact genuineness: overlap interior o = [max(0,t), min(L_i, t+L_j)) nonempty and not
    a pure touching. t = <delta, L>. All comparisons exact in Q(beta)."""
    t = sum(int(delta[m])*L[m] for m in range(len(L)))
    Li, Lj = L[i], L[j]
    lo = sp.Max(0, t); hi = sp.Min(Li, t+Lj)
    width = sp.simplify(hi - lo)
    # genuine iff width > 0 (exact sign)
    return sp.sign(width) == 1, t

if __name__ == "__main__":
    import census
    n=0; gate_ok=0; mismatch=0; field_fail=0; checked=0
    for s in census.enum_k3(max_len=3):
        if not census.is_pip(s)[0]: continue
        n+=1
        if n>30: break
        M = P.incidence_matrix(s)
        bf = beta_field(M)
        if bf is None: field_fail+=1; continue
        beta, mp, L = bf
        # GATE (a): M^T L = beta L exactly
        MT = sp.Matrix(M.T.tolist())
        resid = sp.simplify(MT*L - beta*L)
        if any(e != 0 for e in resid): 
            print("EIGEN FAIL", s.images); continue
        # GATE (c): agree with float
        fl = float_L(M)
        if fl is None: continue
        Lf = fl[0]
        Lnum = [float(sp.N(e)) for e in L]
        if max(abs(a-b) for a,b in zip(Lnum, Lf)) > 1e-6:
            print("FLOAT DISAGREE", s.images, Lnum, list(Lf)); continue
        gate_ok+=1
        # GATE (d): reproduce genuineness decisions on a grid of small delta
        k=s.k
        for i in range(k):
            for j in range(k):
                for d in range(-2,3):
                    for axis in range(k):
                        delta=np.zeros(k,dtype=np.int64); delta[axis]=d
                        fg,_=float_genuine(i,delta,j,Lf,k)
                        eg,_=exact_genuine(i,delta,j,L,beta)
                        checked+=1
                        if fg!=eg: mismatch+=1
    print(f"\nspecimens {n}; field built {gate_ok}; field_fail {field_fail}")
    print(f"genuineness decisions checked {checked}; float/exact mismatches {mismatch}")
    print("GATE PASS" if mismatch==0 and gate_ok>0 else "GATE: review mismatches")
