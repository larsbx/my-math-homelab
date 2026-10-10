"""Exact finite-map classification for the C4 endpoint-core program.

The boundary synchronization mechanism depends only on the endpoint maps
`sigma_+` (first letter of each image) and `sigma_-` (last letter). On a
three-letter alphabet each is one of only `3^3 = 27` self-maps. The
classification of self-maps of any finite alphabet up to relabelling -- the
synchronization quotient and the recurrent off-diagonal core of `h x h` -- is
`substitution_dynamics.endpoint_maps`, re-exported here; what stays is the
C4 program's naming of the three-letter classes.

`endpoint_type` names the seven three-letter classes A..G of
docs/c4-endpoint-core-program.md by their cycle structure, which is fast
enough for the hot census loop; `test_endpoint_core.mojo` checks that it
agrees with the derived conjugacy classification on all 27 maps, so the
names are a verified view of `classify_maps(3)` rather than a parallel
definition.

This finite-map layer has no floating point and no substitution-specific
assumptions.
"""

from substitution_dynamics.endpoint_maps import (
    EndpointMapClass,
    LetterPair,
    all_maps,
    canonical_map,
    class_of,
    classify_maps,
    conjugacy_orbit,
    conjugate,
    fixed_points,
    functional_cycle_lengths,
    has_two_cycle,
    image_size,
    is_recurrent_pair,
    nonsynchronizing_pairs,
    pairs_key,
    recurrent_nonsynchronizing_core,
    steps_to_recurrent_core,
    synchronization_partition,
    synchronization_quotient_permutation,
    synchronizes,
    validate_map,
)
from substitution_dynamics.substitution import Substitution

comptime TYPE_A = 0
comptime TYPE_B = 1
comptime TYPE_C = 2
comptime TYPE_D = 3
comptime TYPE_E = 4
comptime TYPE_F = 5
comptime TYPE_G = 6
comptime ENDPOINT_TYPE_COUNT = 7


def prefix_endpoint_map(sigma: List[List[Int]]) -> List[Int]:
    """`sigma_+(a)`: first letter of `sigma(a)`."""
    # Trusted constructor over len(sigma) letters: unvalidated, as before.
    return Substitution(sigma.copy(), len(sigma)).prefix_endpoint_map()


def suffix_endpoint_map(sigma: List[List[Int]]) -> List[Int]:
    """`sigma_-(a)`: last letter of `sigma(a)`."""
    return Substitution(sigma.copy(), len(sigma)).suffix_endpoint_map()


def endpoint_type(h: List[Int]) -> Int:
    """The canonical three-letter functional-graph type id A..G as 0..6."""
    var fixed = fixed_points(h)
    if fixed == 3:
        return TYPE_D  # three fixed points
    if fixed == 2:
        return TYPE_C  # two fixed points plus one leaf
    if fixed == 0:
        return TYPE_F if has_two_cycle(h) else TYPE_G  # 2-cycle plus leaf, or 3-cycle
    # Exactly one fixed point remains.
    if has_two_cycle(h):
        return TYPE_E  # one fixed point plus a 2-cycle
    return TYPE_A if image_size(h) == 1 else TYPE_B  # constant, or a tail of length two


def endpoint_type_name(t: Int) -> String:
    var names: List[String] = ["A", "B", "C", "D", "E", "F", "G"]
    return names[t] if t >= 0 and t < len(names) else "?"
