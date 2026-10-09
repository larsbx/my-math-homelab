from __future__ import annotations

from dataclasses import dataclass
import itertools
from collections import deque
from typing import Mapping, Sequence

Letter = int
Word = tuple[Letter, ...]
State = tuple[Word, Word]
Substitution = Mapping[Letter, Word]


@dataclass(frozen=True)
class BoundaryHit:
    """A synchronizing boundary witness inside an inflated balanced pair."""

    state: State
    iterate: int
    boundary: int
    side: str  # "right" or "left"
    pair: tuple[Letter, Letter]
    sync_after: int
    letter: Letter


@dataclass(frozen=True)
class BoundaryLineage:
    """One zero-return boundary classified relative to the previous inflation."""

    state: State
    iterate: int
    boundary: int
    inherited: bool


def alphabet_size(sigma: Substitution) -> int:
    return max(sigma.keys())


def parikh(word: Sequence[Letter], size: int | None = None) -> tuple[int, ...]:
    if size is None:
        size = max(word, default=0)
    counts = [0] * size
    for a in word:
        if a < 1 or a > size:
            raise ValueError(f"letter {a!r} outside alphabet 1..{size}")
        counts[a - 1] += 1
    return tuple(counts)


def apply_substitution(sigma: Substitution, word: Sequence[Letter]) -> Word:
    # Optimization: itertools.chain.from_iterable inside a tuple constructor avoids list
    # allocations and list.extend() overhead, making it significantly faster and more memory-efficient.
    return tuple(itertools.chain.from_iterable(sigma[a] for a in word))


def apply_substitution_n(sigma: Substitution, word: Sequence[Letter], n: int) -> Word:
    result = tuple(word)
    for _ in range(n):
        result = apply_substitution(sigma, result)
    return result


def normalize_state(state: State) -> State:
    u, v = state
    return (u, v) if u <= v else (v, u)


def coincidence_boundaries(u: Sequence[Letter], v: Sequence[Letter], size: int | None = None) -> list[int]:
    if len(u) != len(v):
        raise ValueError("coincidence_boundaries expects equal-length words")
    if size is None:
        size = max(max(u, default=0), max(v, default=0))
    if (
        min(u, default=1) < 1
        or max(u, default=0) > size
        or min(v, default=1) < 1
        or max(v, default=0) > size
    ):
        raise ValueError(f"letter lies outside alphabet 1..{size}")
    if not size:
        return [0]

    diff = [0] * size
    out = [0]
    non_zero = 0

    for i, (a, b) in enumerate(zip(u, v), start=1):
        if a != b:
            idx_a = a - 1
            val_a = diff[idx_a] + 1
            diff[idx_a] = val_a
            if val_a == 1:
                non_zero += 1
            elif val_a == 0:
                non_zero -= 1

            idx_b = b - 1
            val_b = diff[idx_b] - 1
            diff[idx_b] = val_b
            if val_b == -1:
                non_zero += 1
            elif val_b == 0:
                non_zero -= 1

        if non_zero == 0:
            out.append(i)
    return out


def _image_prefix_lengths(sigma: Substitution, word: Sequence[Letter]) -> list[int]:
    out = [0]
    for a in word:
        out.append(out[-1] + len(sigma[a]))
    return out


def inherited_boundary_positions(
    sigma: Substitution,
    u: Sequence[Letter],
    v: Sequence[Letter],
) -> set[int]:
    """Positions at the next inflation inherited from current zero-return cuts.

    If `k` is a zero-return boundary of `(u,v)`, the Parikh vectors of the two
    prefixes agree. Hence their substituted prefixes have the same length and
    determine a canonical boundary in `(sigma(u), sigma(v))`.
    """
    size = alphabet_size(sigma)
    old_boundaries = coincidence_boundaries(u, v, size)
    upos = _image_prefix_lengths(sigma, u)
    vpos = _image_prefix_lengths(sigma, v)
    inherited: set[int] = set()
    for k in old_boundaries:
        if upos[k] != vpos[k]:
            raise AssertionError("balanced prefixes mapped to unequal image lengths")
        inherited.add(upos[k])
    return inherited


def boundary_lineage(
    sigma: Substitution,
    state: State,
    iterate: int,
) -> list[BoundaryLineage]:
    """Classify zero-return boundaries at `iterate >= 1` as inherited/newborn.

    This is a finite diagnostic for conjecture C3 (Newborn Synchronizing
    Boundary). It does not assert that a newborn boundary must synchronize.
    """
    if iterate < 1:
        raise ValueError("boundary_lineage requires iterate >= 1")
    size = alphabet_size(sigma)
    u, v = state
    prev_u = apply_substitution_n(sigma, u, iterate - 1)
    prev_v = apply_substitution_n(sigma, v, iterate - 1)
    cur_u = apply_substitution(sigma, prev_u)
    cur_v = apply_substitution(sigma, prev_v)
    inherited = inherited_boundary_positions(sigma, prev_u, prev_v)
    return [
        BoundaryLineage(state, iterate, k, k in inherited)
        for k in coincidence_boundaries(cur_u, cur_v, size)
    ]


def newborn_boundary_positions(
    sigma: Substitution,
    state: State,
    iterate: int,
) -> list[int]:
    """Zero-return cuts created at this inflation rather than inherited."""
    return [item.boundary for item in boundary_lineage(sigma, state, iterate) if not item.inherited]


def decompose_pair(u: Sequence[Letter], v: Sequence[Letter], size: int | None = None) -> list[State]:
    bdys = coincidence_boundaries(u, v, size)
    return [(tuple(u[bdys[i] : bdys[i + 1]]), tuple(v[bdys[i] : bdys[i + 1]])) for i in range(len(bdys) - 1)]


def children(sigma: Substitution, state: State) -> list[State]:
    size = alphabet_size(sigma)
    u, v = state
    su = apply_substitution(sigma, u)
    sv = apply_substitution(sigma, v)
    return [normalize_state(child) for child in decompose_pair(su, sv, size)]


def seed_states(size: int) -> list[State]:
    return [((a, b), (b, a)) for a in range(1, size + 1) for b in range(a + 1, size + 1)]


def build_bpa(sigma: Substitution, max_states: int = 10000) -> dict[State, list[State]]:
    """Build the reachable balanced-pair graph from all seeds (ab, ba)."""
    size = alphabet_size(sigma)
    graph: dict[State, list[State]] = {}
    queue: deque[State] = deque(normalize_state(s) for s in seed_states(size))

    while queue:
        state = queue.popleft()
        if state in graph:
            continue
        if len(graph) >= max_states:
            raise RuntimeError(f"BPA exceeded max_states={max_states}")
        u, v = state
        if u == v:
            graph[state] = []
            continue
        cs = children(sigma, state)
        graph[state] = cs
        for c in cs:
            if c not in graph:
                queue.append(c)
    return graph


def _tarjan(graph: Mapping[State, Sequence[State]]) -> list[list[State]]:
    index = 0
    stack: list[State] = []
    indices: dict[State, int] = {}
    low: dict[State, int] = {}
    on_stack: set[State] = set()
    sccs: list[list[State]] = []

    def strongconnect(v: State) -> None:
        nonlocal index
        indices[v] = index
        low[v] = index
        index += 1
        stack.append(v)
        on_stack.add(v)
        for w in graph.get(v, []):
            if w not in indices:
                strongconnect(w)
                low[v] = min(low[v], low[w])
            elif w in on_stack:
                low[v] = min(low[v], indices[w])
        if low[v] == indices[v]:
            comp: list[State] = []
            while True:
                w = stack.pop()
                on_stack.remove(w)
                comp.append(w)
                if w == v:
                    break
            sccs.append(comp)

    for v in graph:
        if v not in indices:
            strongconnect(v)
    return sccs


def recurrent_noncoincident_sccs(graph: Mapping[State, Sequence[State]]) -> list[list[State]]:
    out: list[list[State]] = []
    for comp in _tarjan(graph):
        comp_set = set(comp)
        has_cycle = len(comp) > 1 or any(w == comp[0] for w in graph.get(comp[0], []))
        if not has_cycle:
            continue
        if not all(u != v for (u, v) in comp):
            continue
        if any(w in comp_set for s in comp for w in graph.get(s, [])):
            out.append(comp)
    return out


def scc_is_closed(graph: Mapping[State, Sequence[State]], comp: Sequence[State]) -> bool:
    comp_set = set(comp)
    for s in comp:
        for child in graph.get(s, []):
            u, v = child
            if u != v and child not in comp_set:
                return False
    return True


def scc_is_productive(sigma: Substitution, comp: Sequence[State], max_iterate: int = 1) -> bool:
    """Whether some state in comp produces a single-tile coincidence sibling by max_iterate."""
    size = alphabet_size(sigma)
    for state in comp:
        u, v = state
        for n in range(1, max_iterate + 1):
            su = apply_substitution_n(sigma, u, n)
            sv = apply_substitution_n(sigma, v, n)
            for cu, cv in decompose_pair(su, sv, size):
                if len(cu) == 1 and cu == cv:
                    return True
    return False


def endpoint_maps(sigma: Substitution) -> tuple[dict[Letter, Letter], dict[Letter, Letter]]:
    return ({a: sigma[a][0] for a in sigma}, {a: sigma[a][-1] for a in sigma})


def sync_pairs(h: Mapping[Letter, Letter]) -> dict[tuple[Letter, Letter], tuple[int, Letter]]:
    """Return pairs that coalesce under iterates of a finite map.

    Values are (least_m_observed, common_letter). The bound 2|A|+1 is sufficient for
    finite maps: if two synchronized orbits have not met by then, they never will.
    """
    letters = sorted(h)
    bound = 2 * len(letters) + 1
    out: dict[tuple[Letter, Letter], tuple[int, Letter]] = {}
    for a in letters:
        for b in letters:
            x, y = a, b
            for m in range(bound + 1):
                if x == y:
                    out[(a, b)] = (m, x)
                    break
                x, y = h[x], h[y]
    return out


def _sync_hits_for_positions(
    state: State,
    iterate: int,
    u: Sequence[Letter],
    v: Sequence[Letter],
    positions: Sequence[int],
    sync_plus: Mapping[tuple[Letter, Letter], tuple[int, Letter]],
    sync_minus: Mapping[tuple[Letter, Letter], tuple[int, Letter]],
) -> list[BoundaryHit]:
    hits: list[BoundaryHit] = []
    for k in positions:
        if k < len(u):
            pair = (u[k], v[k])
            if pair in sync_plus:
                m, c = sync_plus[pair]
                hits.append(BoundaryHit(state, iterate, k, "right", pair, m, c))
        if k > 0:
            pair = (u[k - 1], v[k - 1])
            if pair in sync_minus:
                m, c = sync_minus[pair]
                hits.append(BoundaryHit(state, iterate, k, "left", pair, m, c))
    return hits


def boundary_sync_hits(
    sigma: Substitution,
    comp: Sequence[State],
    max_iterate: int = 3,
) -> list[BoundaryHit]:
    """Find boundary-synchronization witnesses for a recurrent noncoincident SCC."""
    size = alphabet_size(sigma)
    sigma_plus, sigma_minus = endpoint_maps(sigma)
    sync_plus = sync_pairs(sigma_plus)
    sync_minus = sync_pairs(sigma_minus)
    hits: list[BoundaryHit] = []

    for state in comp:
        u, v = state
        for n in range(max_iterate + 1):
            su = apply_substitution_n(sigma, u, n)
            sv = apply_substitution_n(sigma, v, n)
            if len(su) != len(sv):
                continue
            positions = coincidence_boundaries(su, sv, size)
            hits.extend(_sync_hits_for_positions(state, n, su, sv, positions, sync_plus, sync_minus))
    return hits


def newborn_boundary_sync_hits(
    sigma: Substitution,
    comp: Sequence[State],
    max_iterate: int = 3,
) -> list[BoundaryHit]:
    """Synchronizing witnesses supported only on newborn zero-return cuts.

    This directly instruments the mechanism conjectured in C3. A hit is
    evidence for the mechanism on a finite instance, not a proof of C3.
    """
    size = alphabet_size(sigma)
    sigma_plus, sigma_minus = endpoint_maps(sigma)
    sync_plus = sync_pairs(sigma_plus)
    sync_minus = sync_pairs(sigma_minus)
    hits: list[BoundaryHit] = []

    for state in comp:
        prev_u, prev_v = state
        for n in range(1, max_iterate + 1):
            cur_u = apply_substitution(sigma, prev_u)
            cur_v = apply_substitution(sigma, prev_v)
            inherited = inherited_boundary_positions(sigma, prev_u, prev_v)
            positions = [
                k for k in coincidence_boundaries(cur_u, cur_v, size)
                if k not in inherited
            ]
            hits.extend(_sync_hits_for_positions(state, n, cur_u, cur_v, positions, sync_plus, sync_minus))
            prev_u, prev_v = cur_u, cur_v
    return hits


def inherited_boundary_sync_hits(
    sigma: Substitution,
    comp: Sequence[State],
    max_iterate: int = 3,
) -> list[BoundaryHit]:
    """Synchronizing witnesses supported on inherited zero-return cuts only."""
    size = alphabet_size(sigma)
    sigma_plus, sigma_minus = endpoint_maps(sigma)
    sync_plus = sync_pairs(sigma_plus)
    sync_minus = sync_pairs(sigma_minus)
    hits: list[BoundaryHit] = []

    for state in comp:
        prev_u, prev_v = state
        for n in range(1, max_iterate + 1):
            cur_u = apply_substitution(sigma, prev_u)
            cur_v = apply_substitution(sigma, prev_v)
            inherited = inherited_boundary_positions(sigma, prev_u, prev_v)
            positions = [
                k for k in coincidence_boundaries(cur_u, cur_v, size)
                if k in inherited
            ]
            hits.extend(_sync_hits_for_positions(state, n, cur_u, cur_v, positions, sync_plus, sync_minus))
            prev_u, prev_v = cur_u, cur_v
    return hits
