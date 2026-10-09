"""Do productive recurrent SCCs ever have a root of unity in spec(N_C)?
A root of unity in spec(N_C) <=> some cyclotomic Phi_n divides chi_NC.
Test directly on chi_NC (exact)."""
import sympy as sp, numpy as np, time, json
from psc_core import incidence_matrix
from balanced_pair import build_bpa, standard_seeds
from scc_matrix import recurrent_sccs, is_closed, within_scc_matrix, pf_eigenvalue
import census
x=sp.symbols('x')
def cpe(M):
    Mi=sp.Matrix([[int(round(v)) for v in r] for r in np.asarray(M)])
    return sp.Poly(Mi.charpoly(x).as_expr(),x)
def has_root_of_unity(chi):
    # factor; any cyclotomic factor => root of unity in spectrum
    _,facs=sp.factor_list(chi.as_expr(),x)
    rou=[]
    for f,m in facs:
        fp=sp.Poly(f,x)
        if fp.degree()==1:
            # x - c: root c; root of unity iff c in {1,-1} (integer roots)
            r=sp.solve(f,x)
            if r and r[0] in (1,-1,sp.I,-sp.I): rou.append((str(f),m))
        elif fp.is_cyclotomic:
            rou.append((str(f),m))
    return rou

count=examined=withrou=errs=0; t0=time.time(); ex=[]
for sig in census.enum_k3(max_len=3):
    if not census.is_pip(sig)[0]: continue
    count+=1
    if count>400 or time.time()-t0>700: break
    try:
        A=incidence_matrix(sig)
        bpa=build_bpa(sig,standard_seeds(sig),max_states=2500)
        for comp in recurrent_sccs(bpa):
            if not (2<=len(comp)<=120): continue
            NC=within_scc_matrix(sig,bpa,comp)
            if NC.size==0: continue
            examined+=1
            chi=cpe(NC)
            rou=has_root_of_unity(chi)
            if rou:
                withrou+=1
                if len(ex)<10: ex.append({"scc":len(comp),"closed":is_closed(bpa,comp),
                                          "pf":round(pf_eigenvalue(NC),4),"rou":rou[:3]})
    except Exception: errs+=1
print(json.dumps({"pip":count,"sccs":examined,"with_root_of_unity":withrou,
                  "errs":errs,"sec":round(time.time()-t0)}))
for e in ex: print(e)
