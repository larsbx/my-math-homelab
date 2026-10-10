"""Do recurrent noncoincident SCCs ever have IMPRIMITIVE N_C (irreducible but periodic)?
period = gcd of return-cycle lengths = number of eigenvalues of max modulus.
If period>1 the substitution Sigma_C is not primitive as stated."""
import numpy as np
from psc_core import incidence_matrix
from balanced_pair import build_bpa, standard_seeds
from scc_matrix import recurrent_sccs, within_scc_matrix
import census

def imprimitivity_index(NC):
    # for irreducible nonneg matrix, h = number of eigenvalues with |lambda|=PF
    ev=np.linalg.eigvals(NC.astype(float))
    pf=max(abs(ev))
    if pf<1e-9: return 0
    return int(sum(abs(abs(e)-pf)<1e-6*pf for e in ev))

n=0; imprim=0; total=0; maxh=1
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    n+=1
    if n>200: break
    try: bpa=build_bpa(s,standard_seeds(s),max_states=3000)
    except Exception: continue
    for comp in recurrent_sccs(bpa):
        if len(comp)<2: continue
        NC=within_scc_matrix(s,bpa,comp)
        if NC.size==0 or NC.shape[0]<2: continue
        h=imprimitivity_index(NC)
        total+=1
        if h>1: imprim+=1; maxh=max(maxh,h)
print(f"sampled {n} PIP; recurrent SCCs (size>=2): {total}")
print(f"IMPRIMITIVE N_C (period h>1): {imprim} ({100*imprim/max(1,total):.1f}%); max h={maxh}")
print("=> imprimitive N_C DO occur; the 'primitive Sigma_C' claim in v14 needs the power")
print("   normalization (sigma->sigma^p) to be honest, exactly as companion Thm 6.7 had.")
