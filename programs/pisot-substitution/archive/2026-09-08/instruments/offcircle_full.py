"""For productive SCCs: does chi_NC have nonzero roots that are NEITHER roots of
unity NOR conjugates inside chi_A? I.e. is the 'all nonzero roots are roots of
unity' clause (condition 1) FALSE for productive SCCs? Expected yes (PF(N_C)
itself is a Perron number >1, not a root of unity)."""
import sympy as sp, numpy as np, time, json
from psc_core import incidence_matrix
from balanced_pair import build_bpa, standard_seeds
from scc_matrix import recurrent_sccs, within_scc_matrix, pf_eigenvalue, is_closed
import census
x=sp.symbols('x')
def cpe(M):
    Mi=sp.Matrix([[int(round(v)) for v in r] for r in np.asarray(M)])
    return sp.Poly(Mi.charpoly(x).as_expr(),x)

count=examined=allcyc=hasoff=errs=0; t0=time.time()
for sig in census.enum_k3(max_len=3):
    if not census.is_pip(sig)[0]: continue
    count+=1
    if count>300 or time.time()-t0>600: break
    try:
        A=incidence_matrix(sig)
        bpa=build_bpa(sig,standard_seeds(sig),max_states=2000)
        for comp in recurrent_sccs(bpa):
            if not (2<=len(comp)<=60): continue
            NC=within_scc_matrix(sig,bpa,comp)
            if NC.size==0: continue
            examined+=1
            chi=cpe(NC)
            p=chi
            while p.degree()>0 and p.eval(0)==0:
                p=sp.Poly(sp.div(p.as_expr(),x)[0],x)
            _,facs=sp.factor_list(p.as_expr(),x)
            noncyc=[(f,m) for f,m in facs if not (sp.Poly(f,x).is_cyclotomic or
                     (sp.Poly(f,x).degree()==1 and sp.solve(f,x)[0] in (1,-1)))]
            if noncyc: hasoff+=1
            else: allcyc+=1
    except Exception: errs+=1
print(json.dumps({"pip":count,"sccs":examined,
                  "all_nonzero_roots_are_RoU":allcyc,
                  "has_non_RoU_root":hasoff,"errs":errs,"sec":round(time.time()-t0)}))
