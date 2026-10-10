"""Independent Python oracle for ordered child-occurrence zipper geometry.

Canonical executable implementation: ``kernel/psc/overlap_zipper.mojo``.
The state-level overlap graph intentionally forgets child occurrence position;
this module retains top/bottom child indices and geometric order so repeated
child types remain distinct events.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True)
class ChildOccurrence:
    top_index: int
    bottom_index: int
    state: Any
    left: Any
    right: Any


def _max_exact(g: Any, a: Any, b: Any) -> Any:
    return a if g.F.sign(g.F.sub(a, b)) >= 0 else b


def _min_exact(g: Any, a: Any, b: Any) -> Any:
    return a if g.F.sign(g.F.sub(a, b)) <= 0 else b


def ordered_child_occurrences(g: Any, parent: Any) -> list[ChildOccurrence]:
    """Merge the two substituted tile partitions and retain overlap occurrences."""
    top, bottom, shift = parent
    F = g.F
    scaled = F.mul(F.beta, shift)
    i = j = 0
    out: list[ChildOccurrence] = []

    while i < len(g.sigma[top]) and j < len(g.sigma[bottom]):
        top_letter = g.sigma[top][i]
        bottom_letter = g.sigma[bottom][j]
        top_start = g.prefix[(top, i)]
        bottom_start = F.add(scaled, g.prefix[(bottom, j)])
        top_end = F.add(top_start, g.l[top_letter - 1])
        bottom_end = F.add(bottom_start, g.l[bottom_letter - 1])

        if F.sign(F.sub(top_end, bottom_start)) <= 0:
            i += 1
            continue
        if F.sign(F.sub(bottom_end, top_start)) <= 0:
            j += 1
            continue

        child = (top_letter, bottom_letter, F.sub(bottom_start, top_start))
        left = _max_exact(g, top_start, bottom_start)
        right = _min_exact(g, top_end, bottom_end)
        if F.sign(F.sub(right, left)) <= 0:
            raise RuntimeError("ordered overlap scan produced a non-positive cell")
        out.append(ChildOccurrence(i, j, child, left, right))

        end_cmp = F.sign(F.sub(top_end, bottom_end))
        if end_cmp < 0:
            i += 1
        elif end_cmp > 0:
            j += 1
        else:
            i += 1
            j += 1

    if not out:
        raise RuntimeError("genuine overlap produced no child occurrence")
    return out


def zipper_steps(occurrences: list[ChildOccurrence]) -> list[int]:
    """Codes 1/2/3 for top/bottom/diagonal boundary advances."""
    if not occurrences:
        raise RuntimeError("zipper path requires at least one occurrence")
    out: list[int] = []
    for a, b in zip(occurrences, occurrences[1:]):
        di = b.top_index - a.top_index
        dj = b.bottom_index - a.bottom_index
        if (di, dj) == (1, 0):
            out.append(1)
        elif (di, dj) == (0, 1):
            out.append(2)
        elif (di, dj) == (1, 1):
            out.append(3)
        else:
            raise RuntimeError("ordered child occurrences do not form a prefix-grid zipper")
    return out


def zero_shift_occurrence_count(occurrences: list[ChildOccurrence]) -> int:
    return sum(1 for occurrence in occurrences if not any(occurrence.state[2]))


def is_strict_zipper(occurrences: list[ChildOccurrence]) -> bool:
    return zero_shift_occurrence_count(occurrences) == 0
