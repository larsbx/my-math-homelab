"""
The 19/400 specimens with NO legal swap seed: characterize them. ABBLS Thm 5.3 seeds from
(ab,ba) swaps; if NONE are legal, what does the bridge run from? 

Hypothesis: these are specimens where no two distinct letters are ever adjacent in BOTH
orders — e.g. a substitution whose language has ab but never ba for all a<b. This is a real
structural class. For PDS via ABBLS, the relevant seeds may be the legal ORDERED adjacent
pairs (a,b) with their balanced partner found differently, OR the bridge uses a different
seed set (the asymmetric legal two-words paired with their inflation balance).

Check: for these specimens, are there legal two-words at all, and is the substitution still
PIP/primitive (so PDS is even the right question)? And does the BPA from the ASYMMETRIC legal
seeds (pair each legal (a,b) with the balanced word of equal Parikh) terminate?
"""
import sys; sys.path.insert(0,"/mnt/user-data/outputs")
from bd_exact import legal_two_words
from balanced_pair import build_bpa, standard_seeds, parikh
from scc_matrix import recurrent_sccs
import census, json

def legal_swaps(s):
    L2=legal_two_words(s)
    return [((a,b),(b,a)) for a in range(s.k) for b in range(a+1,s.k)
            if (a,b) in L2 and (b,a) in L2]

n=0; found=[]
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    n+=1
    if n>400: break
    if legal_swaps(s): continue
    L2=sorted(legal_two_words(s))
    # is there ANY balanced pair of legal 2-words (u,v), u!=v, same Parikh?
    bp=[]
    for u in L2:
        for v in L2:
            if u!=v and parikh(u,s.k)==parikh(v,s.k):
                bp.append((u,v))
    found.append((s.images, L2, bp[:4]))
print(f"checked {n} PIP; specimens with NO legal swap seed: {len(found)}")
for img,L2,bp in found[:12]:
    print(f"  sigma={img}")
    print(f"    legal 2-words: {L2}")
    print(f"    legal balanced pairs (any): {bp}")
print()
print("INTERPRETATION: if 'legal balanced pairs (any)' is also EMPTY, then the subshift has")
print("no nontrivial length-2 balanced pair at all — the swap-seed bridge is vacuous and PDS")
print("must be certified by coincidence at the seed level (every length-2 factor is its own")
print("balanced class). That is the DEGENERATE-but-valid case, not a gap.")
