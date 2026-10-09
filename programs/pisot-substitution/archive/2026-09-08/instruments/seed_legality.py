"""
ABBLS seed-legality verification.

ABBLS Thm 5.3: irreducible Pisot has PDS <=> the balanced-pair algorithm terminates with
coincidence from the (ab,ba) swap seeds. The seed-legality hypothesis: the swap seeds used
must be LEGAL balanced pairs — both words ab and ba must lie in the language L(sigma), so
that the algorithm is seeded with genuine elements of the subshift's balanced-pair graph.

A balanced pair (u,v) is legal iff u and v are both factors of the subshift (here length-2
factors), AND have equal abelianization (automatic for a swap: ab and ba have the same
Parikh vector). We check: for each a<b, are ab AND ba both in legal_two_words(sigma)?

Three outcomes per swap seed (ab,ba):
 - BOTH legal: a genuine balanced-pair seed (the intended case).
 - ONE legal, other not: the swap is NOT a balanced pair in the subshift (asymmetric).
 - NEITHER legal: the pair of letters never appears adjacent; swap seed vacuous.

For Thm 5.3 to apply as stated, the relevant seeds must be the legal ones. The verification
question: does restricting to LEGAL swap seeds change the set of seeds the BPA must be run
from, and is the standard_seeds() generator (which emits ALL a<b swaps regardless of
legality) over- or under-seeding?
"""
import sys; sys.path.insert(0,"/mnt/user-data/outputs")
from bd_exact import legal_two_words
import census
import json

def seed_legality(s):
    L2 = legal_two_words(s)
    k = s.k
    rows = []
    for a in range(k):
        for b in range(a+1, k):
            ab_legal = (a,b) in L2
            ba_legal = (b,a) in L2
            rows.append(((a,b), ab_legal, ba_legal))
    return rows

n=0
both=one=neither=0
total_seeds=0
specimens_with_illegal_seed=0
specimens_all_both=0
examples_one=[]
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    n+=1
    rows = seed_legality(s)
    spec_one=False; spec_all_both=True
    for (pair, ab, ba) in rows:
        total_seeds+=1
        if ab and ba: both+=1
        elif ab or ba:
            one+=1; spec_one=True; spec_all_both=False
            if len(examples_one)<8: examples_one.append((s.images, pair, ab, ba))
        else:
            neither+=1; spec_all_both=False
    if spec_one: specimens_with_illegal_seed+=1
    if spec_all_both: specimens_all_both+=1
print(json.dumps(dict(
    pip_specimens=n, total_swap_seeds=total_seeds,
    both_legal=both, exactly_one_legal=one, neither_legal=neither,
    specimens_with_asymmetric_seed=specimens_with_illegal_seed,
    specimens_all_seeds_both_legal=specimens_all_both)))
print("examples (asymmetric: one of ab/ba legal, other not):")
for e in examples_one: print("  ", e)
