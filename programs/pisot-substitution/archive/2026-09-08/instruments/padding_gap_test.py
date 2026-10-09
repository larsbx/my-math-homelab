"""
Test the reviewer's diagonal-run gap in Proposition 4.6.
Claim (as written): every maximal coincidence run has tile-length <= N_Phi <= |A|^2|sigma|^2_max.
Reviewer: only the NON-DIAGONAL phase length is bounded; diagonal runs can be arbitrarily long.

A 'coincidence run' = a maximal block where the two inflated sides agree letter-by-letter.
We measure, across inflated balanced pairs: the max coincidence-run length vs |A|^2 |sigma|^2_max.
If runs exceed the bound, the proposition is overclaimed as stated.
"""
import numpy as np
import psc_core as P
import census
from balanced_pair import build_bpa, standard_seeds

def coincidence_runs(u, v):
    """maximal runs where u[k]==v[k]."""
    L=min(len(u),len(v)); runs=[]; cur=0
    for k in range(L):
        if u[k]==v[k]: cur+=1
        else:
            if cur>0: runs.append(cur); cur=0
    if cur>0: runs.append(cur)
    return runs

n=0; worst_run=0; worst_bound_ratio=0; exceed=0; total_runs=0
examples=[]
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    n+=1
    if n>200: break
    smax=max(len(img) for img in s.images)
    bound=s.k**2 * smax**2
    try:
        bpa=build_bpa(s, standard_seeds(s), max_states=3000)
    except Exception: continue
    if not bpa.finite: continue
    for st in bpa.states:
        u,v=st
        iu=s.apply_word(u); iv=s.apply_word(v)
        for r in coincidence_runs(iu,iv):
            total_runs+=1
            if r>worst_run: worst_run=r
            if r>bound:
                exceed+=1
                ratio=r/bound
                if ratio>worst_bound_ratio:
                    worst_bound_ratio=ratio
                    if len(examples)<6:
                        examples.append((s.images, r, bound, round(ratio,2)))
print(f"specimens {n}; total coincidence runs {total_runs}")
print(f"worst run length {worst_run}; runs EXCEEDING |A|^2|sigma|^2_max bound: {exceed}")
print(f"worst run/bound ratio: {worst_bound_ratio:.2f}")
print("examples (sigma, run_len, bound, ratio):")
for e in examples: print("  ", e)
print()
print("If exceed>0, Prop 4.6 'every maximal coincidence run <= bound' is FALSE as written")
print("(confirms reviewer's diagonal-run gap). The bounded quantity is non-diagonal phase length.")
