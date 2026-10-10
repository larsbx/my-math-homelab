"""
triple_overlap.py — triple-overlap graph (Q-B surrogate), generalizing
overlap_residual.py's pair construction to three legs.

State: (i, d2, j, d3, l) with d2,d3 integer vectors (offsets of legs 2,3 vs leg 1).
Genuine triple overlap: the common interior [0,L_i) ∩ [t2,t2+L_j) ∩ [t3,t3+L_l) is
nonempty AND none of the three pair projections is a touching/degenerate overlap.
Children: common refinement of the three inflated images (same proof as thm:partition).
Coincidence (full triple): all three legs are the same tile at offset 0 (i==j==l, d2=d3=0)
— but for the TRAPPED question the relevant notion is pairwise noncoincidence, so we tag
states by how many of the 3 pair-projections are coincident.

GATE before use: mass balance beta*w(s) = sum_children w(c) must hold exactly on the
common refinement (the defining identity); and each pair projection must be a genuine
pair overlap.
"""
import numpy as np
from collections import deque
import psc_core as P
from overlap_residual import tile_lengths, prefix_parikhs, genuine_overlap, seed_overlaps

EPS = 1e-9
MAX_STATES = 12000

def triple_interior(i, d2, j, d3, l, L):
    t2 = float(d2 @ L); t3 = float(d3 @ L)
    lo = max(0.0, t2, t3)
    hi = min(float(L[i]), t2 + float(L[j]), t3 + float(L[l]))
    return lo, hi  # width = hi-lo if >0

def genuine_triple(i, d2, j, d3, l, L, k):
    # all three pair projections genuine (noncoincident-capable overlaps), and common interior > 0
    okij, _ = genuine_overlap(i, d2, j, L, k)
    okil, _ = genuine_overlap(i, d3, l, L, k)
    okjl, _ = genuine_overlap(j, (np.asarray(d3)-np.asarray(d2)), l, L, k)
    if not (okij and okil and okjl):
        return False
    lo, hi = triple_interior(i, d2, j, d3, l, L)
    return hi - lo > EPS

def seed_triples(s, L, pair_seeds):
    """Combine pair seeds sharing leg-1 letter i into triples (i,d2,j,d3,l)."""
    k = s.k
    by_i = {}
    for (i, dt, j) in pair_seeds:
        by_i.setdefault(i, []).append((np.array(dt, dtype=np.int64), j))
    seeds = set()
    for i, lst in by_i.items():
        for a in range(len(lst)):
            d2, j = lst[a]
            for b in range(len(lst)):
                d3, l = lst[b]
                if genuine_triple(i, d2, j, d3, l, L, k):
                    seeds.add((i, tuple(d2.tolist()), j, tuple(d3.tolist()), l))
    return seeds

def build_triple_graph(s, L, pair_seeds):
    k = s.k; M = P.incidence_matrix(s); pp = prefix_parikhs(s)
    seeds = seed_triples(s, L, pair_seeds)
    if not seeds:
        return None
    idx = {}; states = []
    def get(st):
        if st not in idx:
            idx[st] = len(states); states.append(st)
        return idx[st]
    dq = deque()
    for st in seeds: get(st); dq.append(st)
    edges = {}; capped = False
    while dq:
        st = dq.popleft(); si = get(st)
        i, d2t, j, d3t, l = st
        d2 = np.array(d2t, np.int64); d3 = np.array(d3t, np.int64)
        D2 = M @ d2; D3 = M @ d3
        mult = {}
        for p in range(len(s.images[i])):
            ip = s.images[i][p]
            for q in range(len(s.images[j])):
                jq = s.images[j][q]
                for r in range(len(s.images[l])):
                    lr = s.images[l][r]
                    dch2 = D2 + pp[j][q] - pp[i][p]
                    dch3 = D3 + pp[l][r] - pp[i][p]
                    if not genuine_triple(ip, dch2, jq, dch3, lr, L, k):
                        continue
                    ch = (ip, tuple(dch2.tolist()), jq, tuple(dch3.tolist()), lr)
                    new = ch not in idx; ci = get(ch)
                    mult[ci] = mult.get(ci, 0) + 1
                    if new:
                        if len(states) > MAX_STATES: capped = True
                        else: dq.append(ch)
        edges[si] = sorted(mult.items())
        if capped: break
    return states, edges, capped

def mass_balance_gate(s, L, states, edges):
    """Check beta*w(s) == sum_children w(c) exactly (float, tight tol) on sampled states."""
    k = s.k
    beta = max(abs(np.linalg.eigvals(P.incidence_matrix(s))))
    def width(st):
        i, d2t, j, d3t, l = st
        lo, hi = triple_interior(i, np.array(d2t), j, np.array(d3t), l, L)
        return hi - lo
    bad = 0; checked = 0
    for si, ch in edges.items():
        if not ch: continue
        w = width(states[si])
        cw = sum(m * width(states[ci]) for ci, m in ch)
        if abs(beta * w - cw) > 1e-6 * max(1.0, beta*w):
            bad += 1
        checked += 1
        if checked >= 200: break
    return checked, bad

if __name__ == "__main__":
    import census
    # GATE on a few specimens: mass balance must hold exactly
    tested = 0; gate_fail = 0
    for s in census.enum_k3(max_len=3):
        if not census.is_pip(s)[0]: continue
        L = tile_lengths(P.incidence_matrix(s))[0] if False else None
        # tile_lengths returns left PF eigenvector
        Lvec = tile_lengths(P.incidence_matrix(s))
        L = Lvec[0] if isinstance(Lvec, tuple) else Lvec
        try:
            ps, _ = seed_overlaps(s, L)
        except Exception:
            continue
        if not ps: continue
        res = build_triple_graph(s, L, ps)
        if res is None: continue
        states, edges, capped = res
        chk, bad = mass_balance_gate(s, L, states, edges)
        if chk > 0:
            tested += 1
            if bad > 0: gate_fail += 1
            print(f"specimen {s.images}: triple states={len(states)} capped={capped} MB checked={chk} bad={bad}")
        if tested >= 8: break
    print(f"\nGATE: {tested} specimens, {gate_fail} with mass-balance failures")
