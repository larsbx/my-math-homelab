"""Independent oracle for seed-relative overlap occurrence multiplicities.

Canonical implementation: ``kernel/psc/overlap_growth_bridge.mojo``.  Counts
are per inherited period of the swap seeds and stop at coincidence vertices,
matching the residual seed-patch graph contract.
"""
from __future__ import annotations

from typing import Any

IMPLEMENTATION_ROLE = "independent-oracle"
CANONICAL_IMPLEMENTATION = "kernel/psc/overlap_growth_bridge.mojo"


def seed_occurrence_multiplicity(g: Any) -> tuple[int, ...]:
    if g.capped:
        raise RuntimeError("occurrence multiplicity is undefined for a capped graph")
    counts = [0] * len(g.states)
    for seed in g.seeds():
        counts[g.index[seed]] += 1
    return tuple(counts)


def occurrence_multiplicity_at_level(g: Any, level: int, max_count: int = 1_000_000_000) -> tuple[int, ...]:
    """Residual state multiplicities after ``level`` substitutions."""
    if g.capped:
        raise RuntimeError("occurrence multiplicity is undefined for a capped graph")
    if level < 0 or max_count < 1:
        raise RuntimeError("occurrence multiplicity needs a nonnegative level and positive cap")
    counts = seed_occurrence_multiplicity(g)
    for _ in range(level):
        nxt = [0] * len(g.states)
        for parent, multiplicity in enumerate(counts):
            # Repeated adjacency entries are distinct prefix-position pairs.
            for child in g.adj[parent]:
                nxt[child] += multiplicity
                if nxt[child] > max_count:
                    raise RuntimeError("occurrence multiplicity exceeded its exact count cap")
        counts = tuple(nxt)
    return counts
