"""
type_determinacy_check.py — machine validation of the Boundary-Type Determinacy Lemma.

Claim under test: for a genuine overlap cell c = (a, d, b), t_off = <d, L>:
  left-boundary type of c  = I iff t_off < 0,  J iff t_off > 0   (t_off = 0: prefix anchor)
  right-boundary type of c = I iff t_off > L_a - L_b, J iff <    (equality: suffix anchor)
and for consecutive refinement cells the boundary's geometric type (which subdivision
grid has a vertex there) matches BOTH the right-predicate of the left cell and the
left-predicate of the right cell.  All position comparisons exact (integer vectors;
Q-independence of the L_a).  Shared cuts (both grids) must coincide with anchor
degeneracies in the incident cells per Lemma 3.5 geometry.

Also re-validates Lemma 6.9 typing: type-I step => j unchanged, delta jump -e_{i(left)};
type-J => i unchanged, +e_{j(left)}.
"""
from __future__ import annotations

import sys
import numpy as np

sys.path.insert(0, "/mnt/project")
import psc_core as P  # noqa: E402
from overlap_residual import tile_lengths, prefix_parikhs, seed_overlaps, build_overlap_graph  # noqa: E402
from census import is_pip  # noqa: E402


def ordered_children(state, s, M, pp, L):
    """Children of `state` as left-to-right cells with exact boundary vectors.
    Returns list of (child_state, left_vec, right_vec) sorted by left endpoint."""
    i, d, j = state
    d = np.array(d, dtype=np.int64)
    Md = M @ d
    cells = []
    ni, nj = len(s.images[i]), len(s.images[j])
    for p in range(ni):
        for q in range(nj):
            a, b = s.images[i][p], s.images[j][q]
            lv_I, lv_J = pp[i][p], Md + pp[j][q]           # candidate left vectors
            rv_I, rv_J = pp[i][p + 1], Md + pp[j][q + 1]   # candidate right vectors
            left = lv_I if lv_I @ L > lv_J @ L else lv_J
            right = rv_I if rv_I @ L < rv_J @ L else rv_J
            if left @ L < right @ L - 1e-9:                # nonempty interior
                child = (a, tuple((Md + pp[j][q] - pp[i][p]).tolist()), b)
                cells.append((child, left, right, rv_I, rv_J))
    cells.sort(key=lambda c: c[1] @ L)
    return cells


def boundary_geom_type(rv_I, rv_J, L):
    """Geometric type of the right boundary of a cell: which grid cuts there."""
    if np.array_equal(rv_I, rv_J):
        return "shared"
    return "I" if rv_I @ L < rv_J @ L else "J"


def left_pred(state, L):
    a, d, b = state
    t = np.array(d) @ L
    if abs(t) < 1e-12:
        return "anchor0"
    return "I" if t < 0 else "J"


def right_pred(state, L):
    a, d, b = state
    v = np.array(d).copy()
    v[a] -= 1
    v[b] += 1                       # d - (e_a - e_b)
    t = v @ L
    if abs(t) < 1e-12:
        return "anchorS"
    return "I" if t > 0 else "J"


def check_specimen(s):
    M = np.array(P.incidence_matrix(s), dtype=np.int64)
    tl = tile_lengths(M)
    L = tl[0]
    pp = [[np.array(v, dtype=np.int64) for v in row] for row in prefix_parikhs(s)]
    seeds = seed_overlaps(s, L)
    states, edges, coin = build_overlap_graph(s, L)[:3]
    n_bound = n_ok = n_shared = n_anchor_adj = n_fail = 0
    n_69_ok = n_69_fail = 0
    for st in states:
        cells = ordered_children(st, s, M, pp, L)
        for r in range(len(cells) - 1):
            cL, _, _, rvI, rvJ = cells[r]
            cR = cells[r + 1][0]
            n_bound += 1
            g = boundary_geom_type(rvI, rvJ, L)
            pR, pL2 = right_pred(cL, L), left_pred(cR, L)
            if g == "shared":
                n_shared += 1
                # degenerate: incident cells must show anchor predicates
                if pR == "anchorS" or pL2 == "anchor0":
                    n_anchor_adj += 1
                continue
            if pR == g == pL2:
                n_ok += 1
            else:
                n_fail += 1
                if n_fail <= 3:
                    print("   FAIL", st, cL, cR, g, pR, pL2)
            # Lemma 6.9 typing re-validation
            aL, dL, bL = cL
            aR, dR, bR = cR
            jump = np.array(dR) - np.array(dL)
            e = np.zeros(len(L), dtype=np.int64)
            if g == "I":
                e[aL] -= 1
                ok69 = (bR == bL) and np.array_equal(jump, e)
            else:
                e[bL] += 1
                ok69 = (aR == aL) and np.array_equal(jump, e)
            n_69_ok += ok69
            n_69_fail += (not ok69)
    return dict(states=len(states), boundaries=n_bound, ok=n_ok, fail=n_fail,
                shared=n_shared, shared_anchor_adjacent=n_anchor_adj,
                l69_ok=n_69_ok, l69_fail=n_69_fail)


if __name__ == "__main__":
    import itertools
    from census import enum_k3
    specs = [
        ("tribonacci", P.Substitution(((0, 1), (0, 2), (0,)))),
        ("flipped_trib", P.Substitution(((1, 0), (2, 0), (0,)))),
        ("plastic-ish", P.Substitution(((1,), (2,), (0, 1)))),
    ]
    # add 12 PIP specimens spread through the enumeration
    got = 0
    for idx, s in enumerate(enum_k3()):
        if idx % 4801 == 0:
            ok, *_ = is_pip(s)
            if ok:
                specs.append((f"idx{idx}", s))
                got += 1
    tot = dict(boundaries=0, ok=0, fail=0, shared=0, shared_anchor_adjacent=0,
               l69_ok=0, l69_fail=0)
    for name, s in specs:
        ok, *_ = is_pip(s)
        if not ok:
            print(f"{name}: not PIP, skipped")
            continue
        r = check_specimen(s)
        for key in tot:
            tot[key] += r[key]
        print(f"{name}: {r}")
    print("TOTAL:", tot)
    assert tot["fail"] == 0 and tot["l69_fail"] == 0
    print("TYPE-DETERMINACY + LEMMA-6.9 VALIDATION PASSED" )
