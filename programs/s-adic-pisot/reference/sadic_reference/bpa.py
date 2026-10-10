"""Balanced pair algorithm, written independently of the vendored Mojo
`substitution_dynamics.balanced_pair_algorithm` (oracle only).

Seeds are the swap pairs `(ab, ba)`, `a < b`; a balanced pair is cut after
every common prefix with equal Parikh vectors; a state is a pair with its two
sides ordered lexicographically; a coincidence is a state `(a, a)`. The
algorithm *terminates* when the reachable closure is finite and every state
reaches a coincidence (BST23 Proposition 6.1 for the unimodular Pisot
irreducible case).
"""

from __future__ import annotations

from collections import deque

Pair = tuple[tuple[int, ...], tuple[int, ...]]
TERMINATES, FAILS, CAPPED = "terminates", "fails", "capped"


def _apply(sigma, w):
    return tuple(x for a in w for x in sigma[a])


def _norm(u, v) -> Pair:
    return (u, v) if u <= v else (v, u)


def split(u, v, size: int) -> list[Pair]:
    out, start, diff = [], 0, [0] * size
    for i, (a, b) in enumerate(zip(u, v)):
        diff[a] += 1
        diff[b] -= 1
        if not any(diff):
            out.append(_norm(u[start:i + 1], v[start:i + 1]))
            start = i + 1
    return out


def balanced_pair_algorithm(sigma, max_states: int = 20000, max_length: int = 400) -> str:
    size = len(sigma)
    seeds = [((a, b), (b, a)) for a in range(size) for b in range(a + 1, size)]
    edges: dict[Pair, list[Pair]] = {}
    queue = deque(seeds)
    while queue:
        state = queue.popleft()
        if state in edges:
            continue
        if len(edges) >= max_states or len(state[0]) > max_length:
            return CAPPED
        u, v = state
        kids = [] if len(u) == 1 and u == v else split(_apply(sigma, u), _apply(sigma, v), size)
        edges[state] = kids
        queue.extend(k for k in kids if k not in edges)
    good = {s for s in edges if len(s[0]) == 1 and s[0] == s[1]}
    changed = True
    while changed:
        changed = False
        for s, kids in edges.items():
            if s not in good and any(k in good for k in kids):
                good.add(s)
                changed = True
    return TERMINATES if len(good) == len(edges) else FAILS
