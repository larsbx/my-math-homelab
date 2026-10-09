"""
Collar Certification Lemma test: does the per-cycle imbalance radius R(C) of a recurrent
BPA SCC satisfy R(C) <= L_sigma, where L_sigma is the Mosse recognizability constant?

We use a computable recognizability proxy: L_rec = smallest L such that every length-L factor
of the fixed point determines the position of the nearest sigma-cut to its left uniquely
(bounded search over factors of sigma^N(a)). This is an upper proxy for the recognizability
window; if R(C) <= L_rec holds, the lemma's spirit holds with this constant.

Actually the cleaner, citeable form: L_sigma bounds the length beyond which a balanced pair
must contain a coincidence (recognizability forces desubstitution alignment). We test the
operational claim: R(C) (max imbalance over the SCC at saturation) <= C_Mosse, a per-sigma
constant we compute as the recognizability window.
"""
import numpy as np
import psc_core as P, balanced_pair as B
import census

def recognizability_window(sig, maxL=25, Nlev=5):
    """Smallest L: every length-L factor w of the fixed point occurs with a UNIQUE
    'phase' (distance from start of the sigma-block containing its first letter).
    Bounded: build a long word sigma^Nlev(0), scan factors, track phase via the
    desubstitution cut positions. Returns L or maxL if not resolved (proxy)."""
    # build a long admissible word and its cut positions (block boundaries under sigma)
    word=[0]
    cuts=[0]  # positions that are sigma-block starts at the TOP level
    for _ in range(Nlev):
        nw=[]; nc=[]; pos=0
        for x in word:
            nc.append(pos)
            img=sig.images[x]; nw.extend(img); pos+=len(img)
        word=nw; cuts=nc
    word=np.array(word); cutset=set(cuts)
    n=len(word)
    for L in range(1, maxL+1):
        # map each length-L factor -> set of phases (dist from factor start back to nearest cut<=start)
        phase_of={}
        ok=True
        # precompute nearest cut to the left for each position
        nearest=[0]*n; last=-1
        for i in range(n):
            if i in cutset: last=i
            nearest[i]=last
        seen={}
        for i in range(n-L+1):
            fac=tuple(word[i:i+L].tolist())
            ph=i-nearest[i]
            if fac in seen and seen[fac]!=ph:
                ok=False; break
            seen[fac]=ph
        if ok:
            return L
    return maxL

def scc_radius(sig, res, comp, n, depth=5):
    mx=0
    for s in comp:
        u,v=res.states[s]; U=u; V=v
        for _ in range(depth): U=sig.apply_word(U); V=sig.apply_word(V)
        L=min(len(U),len(V)); diff=[0]*n
        for k in range(L):
            a,b=U[k],V[k]
            if a!=b: diff[a]+=1; diff[b]-=1
            if any(diff): mx=max(mx,max(abs(x) for x in diff))
    return mx

from scc_matrix import recurrent_sccs
nn=0; viol=0; tested=0; ratios=[]
for sig in census.enum_k3(max_len=3):
    if not census.is_pip(sig)[0]: continue
    nn+=1
    if nn>50: break
    n=sig.k
    try:
        Lrec=recognizability_window(sig)
        res=B.build_bpa(sig, B.standard_seeds(sig), max_states=4000)
    except Exception: continue
    if not res.finite: continue
    for comp in recurrent_sccs(res):
        if len(comp)<2: continue
        R=scc_radius(sig,res,comp,n)
        tested+=1
        ratios.append(R/Lrec if Lrec>0 else 0)
        if R>Lrec: viol+=1
import statistics
print(f"specimens {nn}; recurrent SCCs tested {tested}")
print(f"R(C) > L_rec violations: {viol}")
if ratios:
    print(f"R(C)/L_rec: max {max(ratios):.3f}, median {statistics.median(ratios):.3f}, min {min(ratios):.3f}")
print("If 0 violations and ratio<=1, the Collar bound R(C)<=L_sigma holds empirically with")
print("the recognizability-window constant.")
