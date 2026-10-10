"""A1' on the Proposition D normal form, via the equal-length walk.

Equal Parikh prefixes have equal length (the components sum to the length), so
a common vertex of u = sigma^inf(x) and w = sigma^inf(c) is an s with
pi(u[0:s]) = pi(w[0:s]), and a shared tile is such an s with u[s] = w[s].
One linear scan, exact integer counters only.
"""
import sys
import itertools
from collections import Counter

sys.path.insert(0, "reference")
from psc_research.pip_screen import mat, charpoly, primitive, irreducible, pisot


def sigma_of(p, q, r, s0, s1, t, s2):
    return {1: (1,) + (3,) * p + (s0 + 1,),
            2: (2,) + (3,) * q + (s1 + 1,),
            3: (t + 1,) + (3,) * r + (s2 + 1,)}


def det3(M):
    return (M[0][0] * (M[1][1] * M[2][2] - M[1][2] * M[2][1])
            - M[0][1] * (M[1][0] * M[2][2] - M[1][2] * M[2][0])
            + M[0][2] * (M[1][0] * M[2][1] - M[1][1] * M[2][0]))


def iterate(sig, letter, cap):
    """A prefix of sigma^inf(letter), with the length reached at each level."""
    w = (letter,)
    lengths = [1]
    while len(w) < cap:
        nxt = []
        for a in w:
            nxt.extend(sig[a])
        nxt = tuple(nxt)
        if nxt == w:
            break
        w = nxt
        lengths.append(len(w))
    return w, lengths


def witness(sig, cap):
    """(position, coincidence level) of the first shared tile, or None."""
    u, lu = iterate(sig, 1, cap)
    w, lw = iterate(sig, 2, cap)
    n = min(len(u), len(w))
    cu = [0, 0, 0]
    cw = [0, 0, 0]
    for s in range(n):
        if cu == cw and u[s] == w[s]:
            lev = max(next(i for i, L in enumerate(lu) if L > s),
                      next(i for i, L in enumerate(lw) if L > s))
            return s, lev
        cu[u[s] - 1] += 1
        cw[w[s] - 1] += 1
    return None


def sweep(bound, cap):
    members = 0
    miss = []
    pos = []
    lev = Counter()
    by_end = {}
    for p, q, r in itertools.product(range(bound + 1), repeat=3):
        for s0, s1, t, s2 in itertools.product(range(2), repeat=4):
            sig = sigma_of(p, q, r, s0, s1, t, s2)
            M = mat(sig)
            T, U, D = charpoly(M)
            if not (primitive(M) and irreducible(T, U, D) and pisot(T, U, D)):
                continue
            if abs(det3(M)) != 2:
                continue
            members += 1
            got = witness(sig, cap)
            if got is None:
                miss.append((p, q, r, s0, s1, t, s2))
                continue
            s, n = got
            pos.append(s)
            lev[n] += 1
            k = (s0, s1, t, s2)
            by_end[k] = max(by_end.get(k, 0), n)
    return members, miss, pos, lev, by_end


if __name__ == "__main__":
    for bound, cap in ((5, 2_000_000), (8, 2_000_000), (11, 2_000_000)):
        members, miss, pos, lev, by_end = sweep(bound, cap)
        print(f"--- p,q,r <= {bound}: {members} PIP members with |det M| = 2")
        print(f"    A1' not witnessed within the cap: {len(miss)}")
        if pos:
            print(f"    first shared tile position: max {max(pos)}, "
                  f"median {sorted(pos)[len(pos) // 2]}")
            print(f"    coincidence LEVEL distribution: {dict(sorted(lev.items()))}"
                  f"  -> max {max(lev)}")
            print(f"    max level per ending (s_x,s_c,t,s_y): {dict(sorted(by_end.items()))}")
        sys.stdout.flush()
