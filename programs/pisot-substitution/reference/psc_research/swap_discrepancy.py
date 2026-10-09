"""Discrepancy of inflated swap seeds and of reachable balanced-pair states.

For a seed (ab, ba) and a level n, the *swap walk* is the prefix-difference
walk of the balanced pair (sigma^n(ab), sigma^n(ba)):

    Delta_n(j) = parikh(sigma^n(ab)[:j]) - parikh(sigma^n(ba)[:j]).

Every state of B_sigma is a block of the reduction of some (sigma^n(ab),
sigma^n(ba)) cut at a zero return, so its own prefix-difference walk is a
segment of a swap walk starting at 0.  Hence

    Disc(T) <= max_j ||Delta_n(j)||_inf

for every state T at depth n below the seed (ab, ba).  The bound
``swap_walk_sup`` is what the bounded-discrepancy theorem
(sources/issue-45/g1b1-bounded-discrepancy-reconstruction.md)
proves to be uniformly bounded in n; this module only evaluates it exactly.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping

from .bpa import State, Substitution, alphabet_size, apply_substitution_n, seed_states


def discrepancy(state: State, size: int) -> int:
    """max_k ||parikh(u[:k]) - parikh(v[:k])||_inf over the prefixes of a balanced pair."""
    u, v = state
    diff = [0] * size
    best = 0

    # Optimization: Instead of recalculating max(abs(c)) over the entire diff array (O(size))
    # on every iteration, we only check the two values that actually changed.
    # We also skip identical characters since they don't affect the difference vector.
    for x, y in zip(u, v):
        if not (1 <= x <= size and 1 <= y <= size):
            raise ValueError(f"state label lies outside 1..{size}: {(x, y)!r}")
        if x == y:
            continue

        diff[x - 1] += 1
        diff[y - 1] -= 1

        best = max(best, abs(diff[x - 1]), abs(diff[y - 1]))

    return best


def swap_walk_sup(sigma: Substitution, a: int, b: int, level: int) -> int:
    """max_j ||Delta_level(j)||_inf for the seed (ab, ba)."""
    size = alphabet_size(sigma)
    u = apply_substitution_n(sigma, (a, b), level)
    v = apply_substitution_n(sigma, (b, a), level)
    return discrepancy((u, v), size)


def swap_walk_profile(sigma: Substitution, levels: Iterable[int]) -> dict[int, int]:
    """Level -> max over all seeds of the swap-walk supremum."""
    size = alphabet_size(sigma)
    return {
        n: max(swap_walk_sup(sigma, a, b, n) for (a, b), _ in seed_states(size))
        for n in levels
    }


def max_reachable_discrepancy(graph: Mapping[State, object], size: int) -> int:
    """Largest discrepancy over the vertices of a balanced-pair graph."""
    return max((discrepancy(s, size) for s in graph), default=0)


def common_tile_count(
    sigma: Substitution, a: int, b: int, level: int
) -> tuple[int, int]:
    """(number of common tiles, number of tiles) of the level-`level` swap pair.

    A common tile is a position with equal letters on both sides and equal
    prefix Parikh vectors before it (a coincidence block of the reduction)."""
    u = apply_substitution_n(sigma, (a, b), level)
    v = apply_substitution_n(sigma, (b, a), level)
    size = alphabet_size(sigma)
    diff = [0] * size
    common = 0
    non_zero = 0

    for x, y in zip(u, v):
        if x == y:
            if non_zero == 0:
                common += 1
            # When letters are identical, their Parikh vector difference is unchanged.
            continue

        # Optimization: Track non_zero count instead of using any(diff) which is O(size).
        idx_x = x - 1
        val_x = diff[idx_x] + 1
        diff[idx_x] = val_x
        if val_x == 1:
            non_zero += 1
        elif val_x == 0:
            non_zero -= 1

        idx_y = y - 1
        val_y = diff[idx_y] - 1
        diff[idx_y] = val_y
        if val_y == -1:
            non_zero += 1
        elif val_y == 0:
            non_zero -= 1

    return common, len(u)
