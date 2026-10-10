"""
Test v5 Theorem 5.1's predecessor-contraction inequality: beta * L(s') <= L(s) + D,
where s -> s' is a BPA child edge, L = geometric length (sum of tile lengths of the word),
D = total padding bound. Memory: violated by large factors. VERIFY empirically.

Convention: s=(u,v) balanced, L(s)=sum_a Lf[a]*count_a(u). Child s' = (mid_u,mid_v) from a
block of split(sigma(u),sigma(v)). The contraction should relate child length to parent.
We measure the worst-case ratio R = beta*L(child) - L(parent) and also beta*L(child)/L(parent).
The claim says R <= D (a constant). We report max R and whether it scales with L(parent)
(which would mean NO additive-D bound — the breakage).
"""
import numpy as np, json
import psc_core as P
from balanced_pair import build_bpa, standard_seeds, _split_balanced
from overlap_residual import tile_lengths
import census

def Lword(word, Lf):
    return sum(Lf[a] for a in word)

n=0; worst_ratio=0; worst_excess=0; scaling_violation=0
examples=[]
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    n+=1
    if n>300: break
    M=P.incidence_matrix(s); fl=tile_lengths(M)
    if fl is None: continue
    Lf,_,beta,_,_=fl
    # padding bound D: a natural choice is (beta-1)*Lmax or the max single-step length change;
    # v5 uses 'total padding bound D' ~ bounded constant. Use D_candidate = Lmax (generous).
    Lmax=max(Lf); D=Lmax
    try:
        bpa=build_bpa(s, standard_seeds(s), max_states=4000)
    except Exception: continue
    if not bpa.finite: continue
    # walk every parent state, inflate, split, measure child lengths
    for parent in bpa.states:
        u,v=parent
        Lp=Lword(u,Lf)
        iu=s.apply_word(u); iv=s.apply_word(v)
        children,_=_split_balanced(iu,iv)
        for (cu,cv),off in children:
            Lc=Lword(cu,Lf)
            excess = beta*Lc - Lp           # claim: <= D
            ratio  = beta*Lc/Lp if Lp>0 else 0
            if excess>worst_excess:
                worst_excess=excess
                if excess > 5*D and len(examples)<8:
                    examples.append((s.images, len(u), len(cu), round(Lp,3), round(Lc,3),
                                     round(beta,3), round(excess,3), round(D,3)))
            if ratio>worst_ratio: worst_ratio=ratio
            # scaling violation: excess grows with Lp (not bounded by constant D)
            if excess > 2*D and Lp > 2*Lmax:
                scaling_violation+=1
print(json.dumps(dict(
    specimens=n,
    worst_excess_betaLc_minus_Lp=round(worst_excess,4),
    worst_ratio_betaLc_over_Lp=round(worst_ratio,4),
    scaling_violations=scaling_violation)))
print("If worst_excess >> D and ratio can exceed 1 substantially, the predecessor")
print("contraction beta*L(s') <= L(s)+D is FALSE (confirms memory's breakage).")
print("examples (sigma, |u|, |child|, L_parent, L_child, beta, excess, D):")
for e in examples: print("  ", e)
