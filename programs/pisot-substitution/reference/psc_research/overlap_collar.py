"""Radius-``m`` symbolic collars of seed-patch occurrences (independent oracle).

Canonical implementation: ``kernel/psc/overlap_collar.mojo``.  An occurrence
path from a swap seed is an actual pair of tiles in the inflated periodic
patches ``sigma^n((ab)^Z)`` and ``sigma^n((ba)^Z)``.  Its radius-``m``
collar records the ``m`` letters on each side of each tile in its patch.
The collar of a child occurrence is a function of the parent's collar and the
child indices (the collar recursion), so the collared occurrence graph at any
radius is finite and projects onto the seed-patch overlap graph.

Three finite diagnostics are defined on it.  An *unresolved collision* is a
collared state reached by occurrences with different one-step ancestry
(parent letters and child indices): the collar does not determine the parent
occurrence.  The *separation radius* is the least radius with no unresolved
collision; a survivor at the tested radius is retained, not explained away.
The *lift* of an affine pump replays an occurrence-labelled cycle on the
fibre over its first state and reports the eventual period of the collar.
A collision that no radius separates has a structural source: a seed pair
whose iterated patch collapses to a proper power, hence to a periodic word
with two parsings into images (``patch_power_level``).
None of this proves a recognizability radius for the periodic patches, nor
overlap productivity.
"""
from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from typing import Any

from psc_research.overlap_affine_pump import occurrence_edges, verify_affine_pump

Word = tuple[int, ...]


@dataclass(frozen=True)
class Collar:
    left: Word
    right: Word


@dataclass(frozen=True)
class CollaredState:
    state_index: int
    top: Collar
    bottom: Collar


Label = tuple[int, int, int, int]  # top parent letter, top child index, bottom parent letter, bottom child index


@dataclass(frozen=True)
class CollaredEdge:
    parent: int
    ordinal: int
    child: int
    label: Label


@dataclass(frozen=True)
class CollaredGraph:
    radius: int
    states: tuple[CollaredState, ...]
    edges: tuple[CollaredEdge, ...]

    def out_edges(self, k: int) -> tuple[CollaredEdge, ...]:
        return tuple(e for e in self.edges if e.parent == k)

    def fibre(self, state_index: int) -> tuple[int, ...]:
        return tuple(k for k, c in enumerate(self.states) if c.state_index == state_index)


@dataclass(frozen=True)
class Collision:
    child: int
    labels: tuple[Label, ...]


@dataclass(frozen=True)
class LiftedOrbit:
    start: int
    preperiod: int
    period: int


def _image(sigma: Any, word: Word) -> Word:
    return tuple(x for y in word for x in sigma[y])


def seed_collar(letter: int, partner: int, radius: int) -> Collar:
    """Collar of ``letter`` in the periodic word alternating ``letter`` and ``partner``."""
    if radius < 0:
        raise RuntimeError("collar radius must be nonnegative")
    right = tuple(partner if k % 2 == 0 else letter for k in range(radius))
    return Collar(right[::-1], right)


def inflate_collar(sigma: Any, collar: Collar, letter: int, child_index: int, radius: int) -> Collar:
    """Collar of the ``child_index``-th child of a tile ``letter`` with collar ``collar``.

    Every image has at least one letter, so the inflated collar supplies the
    ``radius`` letters on each side however short the parent image is."""
    if radius < 0:
        raise RuntimeError("collar radius must be nonnegative")
    if not 0 <= child_index < len(sigma[letter]):
        raise RuntimeError("collar child index lies outside the parent image")
    left = _image(sigma, collar.left) + tuple(sigma[letter][:child_index])
    right = tuple(sigma[letter][child_index + 1 :]) + _image(sigma, collar.right)
    if len(left) < radius or len(right) < radius:
        raise RuntimeError("inflated collar is shorter than its radius")
    return Collar(left[len(left) - radius :], right[:radius])


def collared_seeds(g: Any, radius: int) -> tuple[CollaredState, ...]:
    """The seed overlaps with the collars of their tiles in ``(ab)^Z`` and ``(ba)^Z``."""
    if g.capped:
        raise RuntimeError("collared seeds are undefined for a capped seed-patch graph")
    F = g.F
    out = []
    for a in (1, 2, 3):
        for b in range(a + 1, 4):
            partner = {a: b, b: a}
            for ta, xa in ((a, F.zero), (b, g.l[a - 1])):
                for tb, xb in ((b, F.zero), (a, g.l[b - 1])):
                    s = (ta, tb, F.sub(xb, xa))
                    if g.overlaps(s):
                        out.append(CollaredState(g.index[s], seed_collar(ta, partner[ta], radius), seed_collar(tb, partner[tb], radius)))
    return tuple(out)


def build_collared_graph(g: Any, radius: int, max_states: int = 200_000) -> CollaredGraph:
    """Breadth-first closure of the collared seeds under actual child occurrences."""
    if g.capped:
        raise RuntimeError("collared graph is undefined for a capped seed-patch graph")
    if max_states <= 0:
        raise RuntimeError("collared state cap must be positive")
    edges_of = [occurrence_edges(g, k) for k in range(len(g.states))]

    def children(c: CollaredState) -> list[tuple[int, CollaredState, Label]]:
        top, bottom, _ = g.states[c.state_index]
        return [(e.occurrence_ordinal,
                 CollaredState(e.child_index,
                               inflate_collar(g.sigma, c.top, top, e.top_child_index, radius),
                               inflate_collar(g.sigma, c.bottom, bottom, e.bottom_child_index, radius)),
                 (top, e.top_child_index, bottom, e.bottom_child_index))
                for e in edges_of[c.state_index]]

    states: list[CollaredState] = []
    index: dict[CollaredState, int] = {}
    queue = deque(collared_seeds(g, radius))
    while queue:
        c = queue.popleft()
        if c in index:
            continue
        if len(states) >= max_states:
            raise RuntimeError("collared occurrence graph exceeded its state cap")
        index[c] = len(states)
        states.append(c)
        queue.extend(child for _, child, _ in children(c))
    edges = tuple(CollaredEdge(k, ordinal, index[child], label)
                  for k, c in enumerate(states) for ordinal, child, label in children(c))
    return CollaredGraph(radius, tuple(states), edges)


def unresolved_collisions(cg: CollaredGraph) -> tuple[Collision, ...]:
    """Collared states reached by occurrences of different one-step ancestry."""
    labels: dict[int, set[Label]] = {}
    for e in cg.edges:
        labels.setdefault(e.child, set()).add(e.label)
    return tuple(Collision(child, tuple(sorted(ls))) for child, ls in sorted(labels.items()) if len(ls) > 1)


def separation_radius(g: Any, max_radius: int, max_states: int = 200_000) -> int | None:
    """Least radius up to ``max_radius`` at which every occurrence's one-step ancestry
    is determined by its collar; None if a collision survives at ``max_radius``.

    A finer collar determines the coarser one, so resolution is monotone in the radius."""
    if max_radius < 0:
        raise RuntimeError("separation radius search needs a nonnegative bound")
    return next((m for m in range(max_radius + 1) if not unresolved_collisions(build_collared_graph(g, m, max_states))), None)


def lift_affine_pump(g: Any, cg: CollaredGraph, certificate: Any) -> tuple[LiftedOrbit, ...]:
    """Replay an occurrence-labelled cycle from every collared state over its first
    state; the collar is eventually periodic, with the reported preperiod and period
    measured in traversals of the cycle.  The certificate is first replayed in full
    against the seed-patch graph ``g`` (every field of every edge), so only a verified
    affine pump is lifted."""
    states, edges = certificate.state_indices, certificate.edges
    if not states or len(states) != len(edges):
        raise RuntimeError("affine pump certificate is malformed")
    if any(e.parent_index != states[k] or e.child_index != states[(k + 1) % len(states)] for k, e in enumerate(edges)):
        raise RuntimeError("affine pump certificate edges do not close over its states")
    if not verify_affine_pump(g, certificate):
        raise RuntimeError("affine pump certificate does not replay on the seed-patch graph")
    step = {(e.parent, e.ordinal): e for e in cg.edges}

    def traverse(k: int) -> int:
        for e in certificate.edges:
            if cg.states[k].state_index != e.parent_index:
                raise RuntimeError("affine pump certificate leaves the fibre it is lifted from")
            selected = step[(k, e.occurrence_ordinal)]
            if (cg.states[selected.child].state_index, selected.label[1], selected.label[3]) != (e.child_index, e.top_child_index, e.bottom_child_index):
                raise RuntimeError("affine pump certificate edge disagrees with the collared occurrence it names")
            k = selected.child
        return k

    def orbit(start: int) -> LiftedOrbit:
        seen: dict[int, int] = {}
        k = start
        while k not in seen:
            seen[k] = len(seen)
            k = traverse(k)
        return LiftedOrbit(start, seen[k], len(seen) - seen[k])

    fibre = cg.fibre(certificate.state_indices[0])
    if not fibre:
        raise RuntimeError("affine pump certificate starts outside the collared graph")
    return tuple(orbit(k) for k in fibre)


def is_proper_power(word: Word) -> bool:
    """Whether ``word`` is ``u^k`` for a shorter ``u`` and ``k >= 2``."""
    n = len(word)
    return any(n % p == 0 and word == word[:p] * (n // p) for p in range(1, n // 2 + 1))


def patch_power_level(sigma: Any, a: int, b: int, max_level: int) -> int | None:
    """Least ``n`` in ``1..max_level`` with ``sigma^n(ab)`` a proper power, else None.

    Then the level-``n`` periodic patch ``(sigma^n(ab))^Z`` has a period shorter than the
    image of the seed period, so it admits two parsings into images of the level-``(n-1)``
    patch, shifted by that period: the same bi-infinite context with two ancestries, which
    no collar radius separates."""
    if max_level < 1:
        raise RuntimeError("patch power search needs a positive level bound")
    if a == b:
        raise RuntimeError("a swap seed needs two distinct letters")
    word: Word = (a, b)
    for n in range(1, max_level + 1):
        word = _image(sigma, word)
        if is_proper_power(word):
            return n
    return None


def collapsing_seed_pairs(g: Any, max_level: int) -> tuple[tuple[int, int, int], ...]:
    """The seed pairs ``(a, b, n)`` whose level-``n`` patch is a proper power, ``n <= max_level``."""
    return tuple((a, b, n) for a in (1, 2, 3) for b in range(a + 1, 4)
                 for n in (patch_power_level(g.sigma, a, b, max_level),) if n is not None)


def legal_factors(sigma: Any, length: int) -> frozenset[Word]:
    """All factors of length at most ``length`` of the language of ``sigma``."""
    if length < 1:
        raise RuntimeError("legal factor length must be positive")
    factors = {(a,) for a in sigma}
    while True:
        grown = factors | {img[i:i + n] for w in factors for img in (_image(sigma, w),)
                           for n in range(1, length + 1) for i in range(len(img) - n + 1)}
        if grown == factors:
            return frozenset(factors)
        factors = grown


def legal_collared_count(g: Any, cg: CollaredGraph) -> int:
    """Collared states whose two collared tiles are both factors of the language."""
    legal = legal_factors(g.sigma, 2 * cg.radius + 1)
    word = lambda collar, letter: collar.left + (letter,) + collar.right
    return sum(1 for c in cg.states for top, bottom, _ in (g.states[c.state_index],)
               if word(c.top, top) in legal and word(c.bottom, bottom) in legal)
