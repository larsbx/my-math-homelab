"""Replay the four specimens of the BPA/overlap representation-control note.

This is a regression repair for existing graph contracts, not a new invariant
or quotient. BPA states use the canonical top/bottom normalization; overlap
states retain ordered tile types and exact offsets. The literature comparison
uses a finite, uncertified fixed-point prefix, exactly as oa_overlap_types does.
Every cap and failed exact PIP screen refuses to return a completed row.
"""

from finite_linear_algebra.mat3 import Mat3
from psc.bpa import build, nonproductive_states, substitution_incidence
from psc.corpus import STATE_CAP
from psc.oa_overlap_types import (
    TypeInclusionReport,
    fixed_point_prefix,
    oa_window,
    prolongable_point,
    type_inclusion_report,
)
from psc.overlap_seed_patch import (
    build_seed_overlap_graph_from_tables,
    build_seed_overlap_tables,
    nonproductive_overlap_states,
)
from psc.pisot import is_pip
from psc.symmetry import parse_substitution_key

comptime MIN_PREFIX_LENGTH = 6000
comptime TRANSLATION_PREFIX_LENGTH = 1


def specimen_keys() -> List[String]:
    return ["01/02/0", "11/02/002", "21/22/102", "022/20/11"]


struct RepresentationCounts(Copyable, Movable):
    var determinant: Int
    var bpa_types: Int
    var bpa_all_productive: Bool
    var seed_all_productive: Bool
    var prefix_length: Int
    var window: Int
    var comparison: TypeInclusionReport

    def __init__(
        out self,
        determinant: Int,
        bpa_types: Int,
        bpa_all_productive: Bool,
        seed_all_productive: Bool,
        prefix_length: Int,
        window: Int,
        var comparison: TypeInclusionReport,
    ):
        self.determinant = determinant
        self.bpa_types = bpa_types
        self.bpa_all_productive = bpa_all_productive
        self.seed_all_productive = seed_all_productive
        self.prefix_length = prefix_length
        self.window = window
        self.comparison = comparison^


def recompute_counts(
    key: String,
    max_states: Int = STATE_CAP,
    min_prefix_length: Int = MIN_PREFIX_LENGTH,
) raises -> RepresentationCounts:
    if max_states <= 0:
        raise Error("representation-control state cap must be positive")
    if min_prefix_length <= 0:
        raise Error("representation-control fixed-point prefix must be positive")
    var sigma = parse_substitution_key(key)
    var matrix = Mat3(substitution_incidence(sigma))
    if not is_pip(matrix):
        raise Error("representation-control specimen is outside the exact PIP regime")
    var bpa = build(sigma, max_states)
    if bpa.capped:
        raise Error("representation-control BPA row is capped and inconclusive")
    var tables = build_seed_overlap_tables(sigma)
    var seed = build_seed_overlap_graph_from_tables(tables, max_states)
    if seed.capped:
        raise Error("representation-control overlap row is capped and inconclusive")
    var point = prolongable_point(sigma)
    var u = fixed_point_prefix(sigma, point, min_prefix_length)
    # type_inclusion_report queries OA productivity, which raises on an OA
    # cap. Its two differences count NONCOINCIDENCE types, not graph sizes.
    var comparison = type_inclusion_report(
        tables, seed, u, point, TRANSLATION_PREFIX_LENGTH, max_states
    )
    return RepresentationCounts(
        matrix.det(),
        bpa.size(),
        len(nonproductive_states(bpa)) == 0,
        len(nonproductive_overlap_states(seed)) == 0,
        len(u),
        oa_window(tables, u, TRANSLATION_PREFIX_LENGTH),
        comparison^,
    )
