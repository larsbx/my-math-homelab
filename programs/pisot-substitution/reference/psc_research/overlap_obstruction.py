"""Independent Python oracle for finite bad-overlap obstruction extraction.

The canonical executable implementation is ``kernel/psc/overlap_obstruction.mojo``.
This module intentionally works against the public ``OverlapGraph`` shape
(``states``, ``adj``, ``capped``, ``nonproductive()``), so tests can also use
small synthetic graphs that isolate the graph-theoretic contract.
"""
from __future__ import annotations

from typing import Any


def common_child_start_count(g: Any, state: Any) -> int:
    """Count top/bottom substituted child starts that agree exactly.

    For an ``OverlapGraph`` state ``(top,bottom,t)``, top child ``i`` starts at
    ``p_i`` and bottom child ``j`` at ``beta*t+q_j``.  Equality is exactly the
    zero-shift condition for that child overlap.  This uses field equality,
    not numerical approximation.
    """
    top, bottom, shift = state
    F = g.F
    scaled = F.mul(F.beta, shift)
    count = 0
    for i in range(len(g.sigma[top])):
        p = g.prefix[(top, i)]
        for j in range(len(g.sigma[bottom])):
            q = F.add(scaled, g.prefix[(bottom, j)])
            if p == q:
                count += 1
    return count


def sccs(g: Any) -> list[list[int]]:
    """Strongly connected components of a complete directed overlap graph.

    Iterative Kosaraju implementation.  Capped graphs are incomplete and fail
    closed rather than being interpreted as finite countermodels.
    """
    if g.capped:
        raise RuntimeError("overlap SCCs are undefined for a capped partial graph")

    n = len(g.states)
    seen = [False] * n
    order: list[int] = []

    for root in range(n):
        if seen[root]:
            continue
        seen[root] = True
        stack: list[tuple[int, int]] = [(root, 0)]
        while stack:
            v, pos = stack[-1]
            if pos < len(g.adj[v]):
                w = g.adj[v][pos]
                stack[-1] = (v, pos + 1)
                if not seen[w]:
                    seen[w] = True
                    stack.append((w, 0))
            else:
                stack.pop()
                order.append(v)

    rev: list[list[int]] = [[] for _ in range(n)]
    for v, children in enumerate(g.adj):
        for w in children:
            rev[w].append(v)

    assigned = [False] * n
    out: list[list[int]] = []
    for root in reversed(order):
        if assigned[root]:
            continue
        assigned[root] = True
        comp: list[int] = []
        stack = [root]
        while stack:
            v = stack.pop()
            comp.append(v)
            for w in rev[v]:
                if not assigned[w]:
                    assigned[w] = True
                    stack.append(w)
        out.append(comp)
    return out


def _has_cycle(g: Any, comp: list[int]) -> bool:
    if len(comp) > 1:
        return True
    return bool(comp) and comp[0] in g.adj[comp[0]]


def nonproductive_sink_sccs(g: Any) -> list[list[int]]:
    """Return closed recurrent SCCs contained in the nonproductive set.

    Nonproductivity is backward-hereditary: if a child were productive, its
    parent would be productive.  Thus the nonproductive set of a complete
    overlap graph is forward closed.  Sink SCCs are the finite recurrent cores
    in which a counterexample to overlap productivity must eventually live.
    """
    if g.capped:
        raise RuntimeError("overlap obstruction is undefined for a capped partial graph")

    bad = set(g.nonproductive())
    out: list[list[int]] = []
    for comp in sccs(g):
        members = set(comp)
        if not comp or not _has_cycle(g, comp) or not members <= bad:
            continue
        if all(child in members for v in comp for child in g.adj[v]):
            out.append(comp)
    return out
