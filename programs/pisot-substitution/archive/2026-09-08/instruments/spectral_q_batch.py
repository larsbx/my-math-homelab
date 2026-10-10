import sympy as sp, numpy as np, time, json, sys
from psc_core import incidence_matrix
from balanced_pair import build_bpa, standard_seeds
from scc_matrix import recurrent_sccs, is_closed, within_scc_matrix, pf_eigenvalue
import census
x = sp.symbols('x')
NMAX=int(sys.argv[1]); START=int(sys.argv[2]) if len(sys.argv)>2 else 0

def cpe(M):
    Mi=sp.Matrix([[int(round(v)) for v in r] for r in np.asarray(M)])
    return sp.Poly(Mi.charpoly(x).as_expr(),x)
def is_cyc_product(poly):
    p=poly
    while p.degree()>0 and p.eval(0)==0:
        p=sp.Poly(sp.div(p.as_expr(),x)[0],x)
    if p.degree()==0: return True,[]
    _,facs=sp.factor_list(p.as_expr(),x)
    nc=[(f,m) for f,m in facs if not sp.Poly(f,x).is_cyclotomic]
    return (len(nc)==0),nc

count=examined=nodiv=noncyc=errs=skipbig=0
examples=[]; idx=0; t0=time.time()
out=open(f"spec_rows_{START}.jsonl","w")
for sig in census.enum_k3(max_len=3):
    if not census.is_pip(sig)[0]: continue
    idx+=1
    if idx<=START: continue
    if count>=NMAX: break
    count+=1
    try:
        A=incidence_matrix(sig); chiA=cpe(A)
        bpa=build_bpa(sig,standard_seeds(sig),max_states=2500)
        for comp in recurrent_sccs(bpa):
            if len(comp)<2 or len(comp)>120:   # cap N_C size for exact charpoly
                if len(comp)>120: skipbig+=1
                continue
            NC=within_scc_matrix(sig,bpa,comp)
            if NC.size==0 or NC.shape[0]<A.shape[0]: continue
            examined+=1
            chiNC=cpe(NC)
            quo,rem=sp.div(chiNC,chiA,x)
            if rem!=sp.Poly(0,x):
                nodiv+=1
                out.write(json.dumps({"idx":idx,"scc":len(comp),"div":0})+"\n")
                continue
            allcyc,nc=is_cyc_product(quo)
            rec={"idx":idx,"scc":len(comp),"closed":is_closed(bpa,comp),
                 "pf":round(pf_eigenvalue(NC),4),"cyc":int(allcyc),
                 "noncyc":[str(f) for f,_ in nc][:3]}
            out.write(json.dumps(rec)+"\n")
            if not allcyc:
                noncyc+=1
                if len(examples)<12: examples.append(rec)
    except Exception as e:
        errs+=1
out.close()
print(json.dumps({"examined_pip":count,"sccs":examined,"nodiv":nodiv,
                  "noncyc":noncyc,"skipbig":skipbig,"errs":errs,
                  "sec":round(time.time()-t0)}))
for e in examples: print(e)
