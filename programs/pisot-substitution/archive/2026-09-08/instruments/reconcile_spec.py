import sympy as sp, numpy as np
from psc_core import incidence_matrix
from balanced_pair import build_bpa, standard_seeds
from scc_matrix import recurrent_sccs, is_closed, within_scc_matrix, pf_eigenvalue
import census
x=sp.symbols('x')
def cpe(M):
    Mi=sp.Matrix([[int(round(v)) for v in r] for r in np.asarray(M)])
    return sp.Poly(Mi.charpoly(x).as_expr(),x)

shown=0
for sig in census.enum_k3(max_len=3):
    if not census.is_pip(sig)[0]: continue
    A=incidence_matrix(sig)
    try:
        bpa=build_bpa(sig,standard_seeds(sig),max_states=2000)
    except Exception: continue
    for comp in recurrent_sccs(bpa):
        if not (2<=len(comp)<=8): continue
        NC=within_scc_matrix(sig,bpa,comp)
        if NC.size==0: continue
        chiA=cpe(A); chiNC=cpe(NC)
        beta=max(abs(np.linalg.eigvals(A)))
        pf=pf_eigenvalue(NC)
        gcd=sp.gcd(chiA,chiNC)
        closed=is_closed(bpa,comp)
        print(f"scc={len(comp)} closed={closed} beta={beta:.4f} pf(NC)={pf:.4f}")
        print(f"  chiA   = {chiA.as_expr()}")
        print(f"  chiNC  = {chiNC.as_expr()}")
        print(f"  gcd    = {gcd.as_expr()}")
        print(f"  beta in spec(NC)? {min(abs(complex(r)-beta) for r in np.linalg.eigvals(NC))<1e-6}")
        shown+=1
        if shown>=6: break
    if shown>=6: break
