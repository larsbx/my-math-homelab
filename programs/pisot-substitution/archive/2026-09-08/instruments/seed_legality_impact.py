"""
Does restricting BPA seeds to LEGAL swaps change the outcome vs all swaps?
Compare, per specimen:
 - termination (finite) 
 - #recurrent noncoincident SCCs
 - set of recurrent-SCC state-signatures
between build_bpa(all standard_seeds) and build_bpa(legal swaps only).
If identical, the seed-legality hypothesis is BENIGN (illegal seeds add nothing reachable
that changes the G2/termination verdict). If different, it's a real correction.
"""
import sys; sys.path.insert(0,"/mnt/user-data/outputs")
from bd_exact import legal_two_words
from balanced_pair import build_bpa, standard_seeds, tarjan_scc
from scc_matrix import recurrent_sccs
import census, json

def legal_swaps(s):
    L2=legal_two_words(s)
    out=[]
    for a in range(s.k):
        for b in range(a+1,s.k):
            # a legal balanced swap needs BOTH ab and ba in language (else not a genuine
            # balanced pair of the subshift)
            if (a,b) in L2 and (b,a) in L2:
                out.append(((a,b),(b,a)))
    return out

n=0; diff_term=0; diff_scc=0; identical=0; legal_empty=0; both_checked=0
examples=[]
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    n+=1
    if n>400: break
    ls=legal_swaps(s)
    try:
        bpa_all=build_bpa(s, standard_seeds(s), max_states=5000)
        bpa_leg=build_bpa(s, ls, max_states=5000) if ls else None
    except Exception:
        continue
    both_checked+=1
    if not ls:
        legal_empty+=1
        # if no legal swap seeds at all, the bridge has NOTHING to run from — note it
        continue
    term_all=bpa_all.finite; term_leg=bpa_leg.finite
    rec_all=recurrent_sccs(bpa_all); rec_leg=recurrent_sccs(bpa_leg)
    # compare recurrent noncoincident SCC count
    na=sum(1 for c in rec_all if len(c)>=2); nl=sum(1 for c in rec_leg if len(c)>=2)
    if term_all!=term_leg: diff_term+=1
    if na!=nl:
        diff_scc+=1
        if len(examples)<8: examples.append((s.images, na, nl))
    if term_all==term_leg and na==nl: identical+=1
print(json.dumps(dict(checked=both_checked, identical_outcome=identical,
    differ_termination=diff_term, differ_rec_scc_count=diff_scc,
    specimens_no_legal_swap_seed=legal_empty)))
print("examples (all-swap rec-SCC count vs legal-swap):")
for e in examples: print("  ", e)
