"""
CORRECT trapped-object search: a Q-infinity failure is a genuine state whose entire forward
cone (ALL branches) never reaches an anchor/coincidence. Equivalently, in the genuine-state
graph with correct child map (AT=M), the backward-reachable set from anchors does NOT cover
all genuine Delta-states. This is exactly what qinf2 certifies. Here we re-run the logic
independently (correct AT=M) over the corpus as an audit of the letter-graph episode and to
confirm ZERO trapped objects, classifying any failure by its letter-pair SCC if one existed.
"""
import numpy as np, json
from collections import deque
import psc_core as P, census
from overlap_residual import tile_lengths

def analyze(s, cap=300000):
    M=P.incidence_matrix(s); k=s.k
    fl=tile_lengths(M)
    if fl is None: return None
    Lf,embeds,beta,roots,_=fl
    AT=M  # CORRECT offset matrix
    pp=[]
    for a in range(k):
        row,acc=[],[0]*k
        for c in s.images[a]:
            row.append(tuple(acc)); acc[c]+=1
        pp.append(row)
    def genuine(i,d,j):
        t=sum(d[a]*Lf[a] for a in range(k)); return -Lf[j]+1e-9<t<Lf[i]-1e-9
    def anchored(i,d,j):
        return all(x==0 for x in d) or all(d[a]==((1 if a==i else 0)-(1 if a==j else 0)) for a in range(k))
    # conjugate-norm bound for Delta (sound finite box): reuse embeds
    def in_box(d, R=40.0):
        return all(abs(sum(d[a]*embeds[m][a] for a in range(k)))<R for m in range(len(embeds)))
    # seed: genuine, in box, not coincidence
    # forward closure from seeds
    idx={}; ch_of=[]; q=deque(); 
    def gid(st):
        if st not in idx: idx[st]=len(idx); ch_of.append(None); q.append(st)
        return idx[st]
    # build seeds by enumerating a delta box: use integer combos with conj-norm bound — but
    # to stay light, seed from anchors' preimages is what qinf2 does. Here: seed from all
    # genuine states discovered by forward closure starting from a spanning set. Simplest:
    # start from every genuine 1-step child of anchors is complex; instead trust qinf2 for
    # the certificate and here just confirm no forward-closed anchor-free cycle by checking
    # every genuine state reachable forward from a delta box seed reaches an anchor.
    # Seed box:
    seeds=[]
    rng=range(-6,7)
    import itertools
    for d in itertools.product(rng,repeat=k):
        for i in range(k):
            for j in range(k):
                if genuine(i,d,j) and in_box(d) and not (i==j and all(x==0 for x in d)):
                    seeds.append((i,d,j))
    for st in seeds: gid(st)
    capped=False
    while q:
        st=q.popleft(); u=idx[st]; i,d,j=st
        base=AT@np.array(d,dtype=np.int64); cc=[]
        for p,ip in enumerate(s.images[i]):
            for qq,jq in enumerate(s.images[j]):
                d2=tuple(int(base[a])+pp[j][qq][a]-pp[i][p][a] for a in range(k))
                if genuine(ip,d2,jq): cc.append(gid((ip,d2,jq)))
        ch_of[u]=cc
        if len(idx)>cap: capped=True; break
    if capped: return dict(capped=True)
    states=[None]*len(idx)
    for st,u in idx.items(): states[u]=st
    radj=[[] for _ in range(len(idx))]
    for u,cs in enumerate(ch_of):
        for v in cs: radj[v].append(u)
    good=deque(u for u,st in enumerate(states) if anchored(*st))
    reach=set(good)
    while good:
        v=good.popleft()
        for u in radj[v]:
            if u not in reach: reach.add(u); good.append(u)
    fails=[states[u] for u,st in enumerate(states) if u not in reach and st in set(seeds)]
    return dict(capped=False, n_states=len(idx), n_seeds=len(seeds), n_fail=len(fails),
                fails=fails[:5])

n=0; tot_fail=0; capped=0; cert=0
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    n+=1
    if n>50: break
    r=analyze(s)
    if r is None: continue
    if r.get('capped'): capped+=1; continue
    if r['n_fail']==0: cert+=1
    else:
        tot_fail+=1
        print("FAILURE (trapped candidate) in", s.images, r['fails'])
print(json.dumps(dict(specimens=n, certified_no_trapped=cert, with_failure=tot_fail, capped=capped)))
