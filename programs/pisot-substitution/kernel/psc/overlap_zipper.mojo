"""Ordered child-occurrence geometry for seed-patch overlaps.

The overlap graph intentionally stores child *types*.  For the strict-zipper
branch of issue #84 we also need occurrence order: repeated child types at
different prefix positions are distinct geometric events.  This module scans
the two substituted tile partitions left-to-right with exact Perron-field
comparisons and returns every overlapping child occurrence in geometric order.

A consecutive occurrence advances the top child index, the bottom child index,
or both.  The diagonal step is exactly a common subdivision boundary.  Thus an
alignment-free obstruction has only top/bottom steps: a strict prefix-grid
zipper.
"""

from psc.overlap_seed_patch import OverlapState, SeedOverlapTables
from psc.perron_field3 import (
    CubicElt,
    cubic_add_checked,
    cubic_mul_beta,
    cubic_sub_checked,
    sign_at_perron,
)


struct ChildOccurrence(ImplicitlyCopyable, Copyable, Movable):
    var top_index: Int
    var bottom_index: Int
    var state: OverlapState
    var left: CubicElt
    var right: CubicElt

    def __init__(
        out self,
        top_index: Int,
        bottom_index: Int,
        state: OverlapState,
        left: CubicElt,
        right: CubicElt,
    ):
        self.top_index = top_index
        self.bottom_index = bottom_index
        self.state = state
        self.left = left
        self.right = right


def _cmp(tables: SeedOverlapTables, a: CubicElt, b: CubicElt) raises -> Int:
    return sign_at_perron(tables.field, cubic_sub_checked(a, b))


def _max_exact(
    tables: SeedOverlapTables, a: CubicElt, b: CubicElt
) raises -> CubicElt:
    return a if _cmp(tables, a, b) >= 0 else b


def _min_exact(
    tables: SeedOverlapTables, a: CubicElt, b: CubicElt
) raises -> CubicElt:
    return a if _cmp(tables, a, b) <= 0 else b


def ordered_child_occurrences(
    tables: SeedOverlapTables, parent: OverlapState
) raises -> List[ChildOccurrence]:
    """Return geometric child overlaps in left-to-right occurrence order.

    The scan is a merge of the two exact child partitions. Boundary-only
    contacts are skipped.  Every returned cell has positive intersection
    length.  Repeated overlap states remain repeated when they occur at
    different child-index pairs.
    """
    if parent.top < 0 or parent.top >= 3 or parent.bottom < 0 or parent.bottom >= 3:
        raise Error("overlap state tile type lies outside 0..2")

    var top_count = len(tables.sigma[parent.top])
    var bottom_count = len(tables.sigma[parent.bottom])
    var scaled_shift = cubic_mul_beta(tables.field, parent.shift)
    var out = List[ChildOccurrence]()
    var i = 0
    var j = 0

    while i < top_count and j < bottom_count:
        var top_letter = tables.sigma[parent.top][i]
        var bottom_letter = tables.sigma[parent.bottom][j]
        var top_start = tables.prefix(parent.top, i)
        var bottom_start = cubic_add_checked(
            scaled_shift, tables.prefix(parent.bottom, j)
        )
        var top_end = cubic_add_checked(top_start, tables.lengths.at(top_letter))
        var bottom_end = cubic_add_checked(
            bottom_start, tables.lengths.at(bottom_letter)
        )

        # Boundary-only contact has zero intersection length and is not an
        # overlap occurrence.
        if _cmp(tables, top_end, bottom_start) <= 0:
            i += 1
            continue
        if _cmp(tables, bottom_end, top_start) <= 0:
            j += 1
            continue

        var child = OverlapState(
            top_letter,
            bottom_letter,
            cubic_sub_checked(bottom_start, top_start),
        )
        var left = _max_exact(tables, top_start, bottom_start)
        var right = _min_exact(tables, top_end, bottom_end)
        if _cmp(tables, right, left) <= 0:
            raise Error("ordered overlap scan produced a non-positive cell")
        out.append(ChildOccurrence(i, j, child, left, right))

        var end_cmp = _cmp(tables, top_end, bottom_end)
        if end_cmp < 0:
            i += 1
        elif end_cmp > 0:
            j += 1
        else:
            i += 1
            j += 1

    if len(out) == 0:
        raise Error("genuine overlap produced no child occurrence")
    return out^


def zipper_steps(occurrences: List[ChildOccurrence]) raises -> List[Int]:
    """Encode transitions between ordered occurrences.

    Codes: 1 = top index advances, 2 = bottom index advances,
    3 = both advance at one common subdivision boundary.
    """
    if len(occurrences) == 0:
        raise Error("zipper path requires at least one occurrence")
    var out = List[Int]()
    for k in range(1, len(occurrences)):
        var di = occurrences[k].top_index - occurrences[k - 1].top_index
        var dj = occurrences[k].bottom_index - occurrences[k - 1].bottom_index
        if di == 1 and dj == 0:
            out.append(1)
        elif di == 0 and dj == 1:
            out.append(2)
        elif di == 1 and dj == 1:
            out.append(3)
        else:
            raise Error("ordered child occurrences do not form a prefix-grid zipper")
    return out^


def zero_shift_occurrence_count(occurrences: List[ChildOccurrence]) -> Int:
    var count = 0
    for i in range(len(occurrences)):
        if occurrences[i].state.shift.is_zero():
            count += 1
    return count


def is_strict_zipper(occurrences: List[ChildOccurrence]) -> Bool:
    """True exactly when the ordered occurrence path has no common child start."""
    return zero_shift_occurrence_count(occurrences) == 0
