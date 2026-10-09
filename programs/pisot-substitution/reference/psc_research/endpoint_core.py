"""Exact finite-map classification for the C4 endpoint-core program.

The boundary synchronization mechanism depends only on the endpoint maps
``sigma_+`` and ``sigma_-``. For a three-letter alphabet each endpoint map is
one of only ``3^3 = 27`` functions. This module classifies those functions up
to alphabet relabeling and computes both the synchronization quotient and the
recurrent off-diagonal core of the product map ``h x h``.

The central quotient is defined by ``a ~ b`` iff the forward orbits of ``a``
and ``b`` eventually coalesce at the same iterate. This is an equivalence
relation, and ``h`` induces a permutation on its quotient classes. Thus a
nonsynchronizing endpoint pair is simply a pair in two distinct quotient
classes; on a three-letter alphabet its quotient phase has period at most 3.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import permutations, product
from typing import Iterator, Sequence

FiniteMap = tuple[int, ...]
Pair = tuple[int, int]
Partition = tuple[tuple[int, ...], ...]


@dataclass(frozen=True)
class EndpointMapClass:
    """One conjugacy class of finite maps under alphabet relabeling."""

    representative: FiniteMap
    members: tuple[FiniteMap, ...]
    nonsynchronizing_pairs: tuple[Pair, ...]
    recurrent_core: tuple[Pair, ...]

    @property
    def size(self) -> int:
        return len(self.members)

    @property
    def globally_synchronizing(self) -> bool:
        return not self.nonsynchronizing_pairs


def validate_map(h: Sequence[int]) -> FiniteMap:
    """Return ``h`` as a tuple after checking ``h:{0,...,n-1}->{0,...,n-1}``."""
    out = tuple(h)
    n = len(out)
    if n == 0:
        raise ValueError("finite map must have a nonempty domain")
    if any(x < 0 or x >= n for x in out):
        raise ValueError(f"map values must lie in 0..{n - 1}")
    return out


def all_maps(size: int = 3) -> Iterator[FiniteMap]:
    """Enumerate every self-map of ``size`` letters in lexicographic order."""
    if size < 1:
        raise ValueError("size must be positive")
    yield from product(range(size), repeat=size)


def conjugate(h: Sequence[int], permutation: Sequence[int]) -> FiniteMap:
    """Return ``p o h o p^{-1}`` for a permutation ``p`` of the alphabet."""
    h = validate_map(h)
    p = tuple(permutation)
    n = len(h)
    if tuple(sorted(p)) != tuple(range(n)):
        raise ValueError("permutation must contain every alphabet element once")
    inverse = [0] * n
    for old, new in enumerate(p):
        inverse[new] = old
    return tuple(p[h[inverse[x]]] for x in range(n))


def conjugacy_orbit(h: Sequence[int]) -> tuple[FiniteMap, ...]:
    """All relabelings of ``h``, sorted and deduplicated."""
    h = validate_map(h)
    return tuple(sorted({conjugate(h, p) for p in permutations(range(len(h))) }))


def canonical_map(h: Sequence[int]) -> FiniteMap:
    """Lexicographically least conjugate of ``h``."""
    return conjugacy_orbit(h)[0]


def synchronizes(h: Sequence[int], a: int, b: int) -> bool:
    """Whether the two forward orbits of ``a`` and ``b`` ever meet.

    The decision is exact: iterate the product map until reaching the diagonal
    or repeating an ordered pair. Repetition off the diagonal proves that the
    two deterministic forward orbits will never meet.
    """
    h = validate_map(h)
    n = len(h)
    if not (0 <= a < n and 0 <= b < n):
        raise ValueError("pair lies outside the map domain")
    seen: set[Pair] = set()
    x, y = a, b
    while x != y:
        pair = (x, y)
        if pair in seen:
            return False
        seen.add(pair)
        x, y = h[x], h[y]
    return True


def synchronization_partition(h: Sequence[int]) -> Partition:
    """Partition letters by eventual same-time coalescence under ``h``."""
    h = validate_map(h)
    blocks: list[list[int]] = []
    for a in range(len(h)):
        for block in blocks:
            if synchronizes(h, a, block[0]):
                block.append(a)
                break
        else:
            blocks.append([a])
    return tuple(tuple(block) for block in blocks)


def synchronization_quotient_permutation(h: Sequence[int]) -> FiniteMap:
    """Permutation induced by ``h`` on synchronization-equivalence classes.

    If ``a ~ b`` then ``h(a) ~ h(b)``, so the quotient map is well-defined.
    Conversely, if ``h(a) ~ h(b)`` then ``a ~ b`` one iterate earlier; hence
    the quotient map is injective and, on a finite quotient, a permutation.
    """
    h = validate_map(h)
    partition = synchronization_partition(h)
    class_of_letter: dict[int, int] = {}
    for i, block in enumerate(partition):
        for a in block:
            class_of_letter[a] = i

    quotient: list[int] = []
    for block in partition:
        targets = {class_of_letter[h[a]] for a in block}
        if len(targets) != 1:
            raise AssertionError("synchronization quotient is not well-defined")
        quotient.append(next(iter(targets)))

    if sorted(quotient) != list(range(len(partition))):
        raise AssertionError("synchronization quotient is not a permutation")
    return tuple(quotient)


def nonsynchronizing_pairs(h: Sequence[int]) -> tuple[Pair, ...]:
    """All ordered distinct pairs whose forward orbits never coalesce."""
    h = validate_map(h)
    n = len(h)
    return tuple(
        (a, b)
        for a in range(n)
        for b in range(n)
        if a != b and not synchronizes(h, a, b)
    )


def is_recurrent_pair(h: Sequence[int], pair: Pair) -> bool:
    """Whether ``pair`` is periodic under ``h x h`` and stays off diagonal."""
    h = validate_map(h)
    a, b = pair
    n = len(h)
    if not (0 <= a < n and 0 <= b < n):
        raise ValueError("pair lies outside the map domain")
    if a == b:
        return False

    start = (a, b)
    seen: set[Pair] = set()
    x, y = start
    while (x, y) not in seen:
        if x == y:
            return False
        seen.add((x, y))
        x, y = h[x], h[y]
    return (x, y) == start


def recurrent_nonsynchronizing_core(h: Sequence[int]) -> tuple[Pair, ...]:
    """Periodic off-diagonal points of the product map ``h x h``."""
    h = validate_map(h)
    return tuple(pair for pair in nonsynchronizing_pairs(h) if is_recurrent_pair(h, pair))


def steps_to_recurrent_core(h: Sequence[int], a: int, b: int) -> int | None:
    """Steps until a nonsynchronizing pair first enters the recurrent core.

    Returns ``None`` when the pair synchronizes. For a nonsynchronizing pair,
    deterministic finiteness guarantees eventual entry into an off-diagonal
    periodic orbit.
    """
    h = validate_map(h)
    n = len(h)
    if not (0 <= a < n and 0 <= b < n):
        raise ValueError("pair lies outside the map domain")
    if synchronizes(h, a, b):
        return None

    core = set(recurrent_nonsynchronizing_core(h))
    seen: set[Pair] = set()
    x, y = a, b
    steps = 0
    while (x, y) not in core:
        pair = (x, y)
        if pair in seen:
            raise AssertionError("nonsynchronizing orbit repeated before recurrent core")
        seen.add(pair)
        x, y = h[x], h[y]
        steps += 1
    return steps


def classify_maps(size: int = 3) -> tuple[EndpointMapClass, ...]:
    """Classify all self-maps of ``size`` letters up to conjugacy."""
    groups: dict[FiniteMap, list[FiniteMap]] = {}
    for h in all_maps(size):
        groups.setdefault(canonical_map(h), []).append(h)

    out: list[EndpointMapClass] = []
    for representative in sorted(groups):
        members = tuple(sorted(groups[representative]))
        out.append(
            EndpointMapClass(
                representative=representative,
                members=members,
                nonsynchronizing_pairs=nonsynchronizing_pairs(representative),
                recurrent_core=recurrent_nonsynchronizing_core(representative),
            )
        )
    return tuple(out)


def class_of(h: Sequence[int]) -> EndpointMapClass:
    """Return the conjugacy class descriptor containing ``h``."""
    h = validate_map(h)
    representative = canonical_map(h)
    return EndpointMapClass(
        representative=representative,
        members=conjugacy_orbit(h),
        nonsynchronizing_pairs=nonsynchronizing_pairs(representative),
        recurrent_core=recurrent_nonsynchronizing_core(representative),
    )


def functional_cycle_lengths(h: Sequence[int]) -> tuple[int, ...]:
    """Sorted cycle lengths of the functional graph of ``h``.

    This is a readable invariant for reports. It is not used as the canonical
    classifier because distinct rooted-tree attachments can share cycle data.
    """
    h = validate_map(h)
    n = len(h)
    lengths: list[int] = []
    globally_seen: set[int] = set()

    for start in range(n):
        if start in globally_seen:
            continue
        path: list[int] = []
        position: dict[int, int] = {}
        x = start
        while x not in position and x not in globally_seen:
            position[x] = len(path)
            path.append(x)
            x = h[x]
        globally_seen.update(path)
        if x in position:
            lengths.append(len(path[position[x] :]))
    return tuple(sorted(lengths))
