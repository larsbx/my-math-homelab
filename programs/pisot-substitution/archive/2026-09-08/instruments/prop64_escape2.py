import numpy as np
import psc_core as P, census
from balanced_pair import build_bpa, standard_seeds
from scc_matrix import recurrent_sccs, is_closed

n=0; open_sccs=0; closed_sccs=0; open_with_escape=0
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    n+=1
    if n>150: break
    try: bpa=build_bpa(s,standard_seeds(s),max_states=3000)
    except Exception: continue
    if not bpa.finite: continue
    # edges: dict u-> list of v (indices) or list of (u,v)? inspect
    edges=bpa.edges
    # build adjacency
    adj={}
    if isinstance(edges, dict):
        adj=edges
    else:
        for e in edges:
            u,v=e[0],e[1]; adj.setdefault(u,[]).append(v)
    # map state->index
    idx={st:i for i,st in enumerate(bpa.states)}
    for comp in recurrent_sccs(bpa):
        if len(comp)<2: continue
        # comp may be states or indices; normalize to indices
        cidx=set(comp if all(isinstance(x,int) for x in comp) else [idx[x] for x in comp])
        closed=is_closed(bpa,comp)
        if closed: closed_sccs+=1; continue
        open_sccs+=1
        escapes=False
        for u in cidx:
            for v in adj.get(u,[]):
                if v not in cidx: escapes=True; break
            if escapes: break
        if escapes: open_with_escape+=1
print(f"specimens {n}; closed {closed_sccs}, open {open_sccs}; open-with-escape {open_with_escape}/{open_sccs}")
