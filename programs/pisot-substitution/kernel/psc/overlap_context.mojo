"""One-step paired prefix-suffix context for seed-patch occurrences.

The record is symbolic: it retains the proper prefix and suffix on both sides
of an actual ordered child occurrence.  It is deliberately weaker than a
periodic-patch collar through arbitrary ancestry depth.  Equal affine child
states with unequal records refute the use of ``(top,bottom,shift)`` alone as
a pump context; equality does not authorize loop deletion.
"""

from psc.overlap_affine_pump import occurrence_edges
from psc.overlap_seed_patch import SeedOverlapAutomaton, SeedOverlapTables


struct PairedPrefixSuffixContext(Copyable, Movable):
    var top_parent: Int
    var bottom_parent: Int
    var top_child_index: Int
    var bottom_child_index: Int
    var top_prefix: List[Int]
    var top_suffix: List[Int]
    var bottom_prefix: List[Int]
    var bottom_suffix: List[Int]

    def __init__(
        out self,
        top_parent: Int,
        bottom_parent: Int,
        top_child_index: Int,
        bottom_child_index: Int,
        top_prefix: List[Int],
        top_suffix: List[Int],
        bottom_prefix: List[Int],
        bottom_suffix: List[Int],
    ):
        self.top_parent = top_parent
        self.bottom_parent = bottom_parent
        self.top_child_index = top_child_index
        self.bottom_child_index = bottom_child_index
        self.top_prefix = top_prefix.copy()
        self.top_suffix = top_suffix.copy()
        self.bottom_prefix = bottom_prefix.copy()
        self.bottom_suffix = bottom_suffix.copy()


struct AffineContextMismatch(Copyable, Movable):
    var child_index: Int
    var first_parent_index: Int
    var first_occurrence_ordinal: Int
    var second_parent_index: Int
    var second_occurrence_ordinal: Int
    var first_context: PairedPrefixSuffixContext
    var second_context: PairedPrefixSuffixContext

    def __init__(
        out self,
        child_index: Int,
        first_parent_index: Int,
        first_occurrence_ordinal: Int,
        second_parent_index: Int,
        second_occurrence_ordinal: Int,
        first_context: PairedPrefixSuffixContext,
        second_context: PairedPrefixSuffixContext,
    ):
        self.child_index = child_index
        self.first_parent_index = first_parent_index
        self.first_occurrence_ordinal = first_occurrence_ordinal
        self.second_parent_index = second_parent_index
        self.second_occurrence_ordinal = second_occurrence_ordinal
        self.first_context = first_context.copy()
        self.second_context = second_context.copy()


def _slice_without_child(word: List[Int], child_index: Int) -> Tuple[List[Int], List[Int]]:
    var prefix = List[Int]()
    var suffix = List[Int]()
    for i in range(child_index):
        prefix.append(word[i])
    for i in range(child_index + 1, len(word)):
        suffix.append(word[i])
    return prefix^, suffix^


def occurrence_context(
    tables: SeedOverlapTables,
    graph: SeedOverlapAutomaton,
    parent_index: Int,
    occurrence_ordinal: Int,
) raises -> PairedPrefixSuffixContext:
    if graph.capped:
        raise Error("overlap context is undefined for a capped seed-patch graph")
    if parent_index < 0 or parent_index >= graph.size():
        raise Error("overlap context parent index is out of range")
    var edges = occurrence_edges(tables, graph, parent_index)
    if occurrence_ordinal < 0 or occurrence_ordinal >= len(edges):
        raise Error("overlap context occurrence ordinal is out of range")
    var edge = edges[occurrence_ordinal].copy()
    var parent = graph.states[parent_index]
    var top_parts = _slice_without_child(
        tables.sigma[parent.top], edge.top_child_index
    )
    var bottom_parts = _slice_without_child(
        tables.sigma[parent.bottom], edge.bottom_child_index
    )
    return PairedPrefixSuffixContext(
        parent.top,
        parent.bottom,
        edge.top_child_index,
        edge.bottom_child_index,
        top_parts[0],
        top_parts[1],
        bottom_parts[0],
        bottom_parts[1],
    )


def _same_word(a: List[Int], b: List[Int]) -> Bool:
    if len(a) != len(b):
        return False
    for i in range(len(a)):
        if a[i] != b[i]:
            return False
    return True


def same_context(a: PairedPrefixSuffixContext, b: PairedPrefixSuffixContext) -> Bool:
    return (
        a.top_parent == b.top_parent
        and a.bottom_parent == b.bottom_parent
        and a.top_child_index == b.top_child_index
        and a.bottom_child_index == b.bottom_child_index
        and _same_word(a.top_prefix, b.top_prefix)
        and _same_word(a.top_suffix, b.top_suffix)
        and _same_word(a.bottom_prefix, b.bottom_prefix)
        and _same_word(a.bottom_suffix, b.bottom_suffix)
    )


def first_affine_context_mismatch(
    tables: SeedOverlapTables, graph: SeedOverlapAutomaton
) raises -> List[AffineContextMismatch]:
    """Return zero or one deterministic affine-state/context mismatch."""
    if graph.capped:
        raise Error("context comparison is undefined for a capped seed-patch graph")
    var seen = List[Bool]()
    var first_parent = List[Int]()
    var first_ordinal = List[Int]()
    var contexts = List[PairedPrefixSuffixContext]()
    for _ in range(graph.size()):
        seen.append(False)
        first_parent.append(-1)
        first_ordinal.append(-1)
        contexts.append(
            PairedPrefixSuffixContext(-1, -1, -1, -1, [], [], [], [])
        )
    for parent_index in range(graph.size()):
        var edges = occurrence_edges(tables, graph, parent_index)
        for ordinal in range(len(edges)):
            var child_index = edges[ordinal].child_index
            var context = occurrence_context(tables, graph, parent_index, ordinal)
            if not seen[child_index]:
                seen[child_index] = True
                first_parent[child_index] = parent_index
                first_ordinal[child_index] = ordinal
                contexts[child_index] = context.copy()
            elif not same_context(contexts[child_index], context):
                var out = List[AffineContextMismatch]()
                out.append(
                    AffineContextMismatch(
                        child_index,
                        first_parent[child_index],
                        first_ordinal[child_index],
                        parent_index,
                        ordinal,
                        contexts[child_index],
                        context,
                    )
                )
                return out^
    return List[AffineContextMismatch]()
