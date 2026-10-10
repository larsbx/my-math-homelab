"""Exact prefix-difference calculus for balanced-pair factorization.

This module keeps the object that actually determines BPA child boundaries:
the Parikh difference of aligned prefixes. It separates an inflated cut into
completed source letters plus within-image offsets and proves the exact affine
identity

    D_{sigma(T)}(t) = M E_T(i,j) + c_sigma(i,r;j,s).

At a zero return the left side vanishes. Since det(M) != 0 in the standing
regime, the asynchronous source defect E is determined by one of a finite set
of local image-prefix corrections. In particular the source-index
misalignment i-j of any inflated zero return is uniformly bounded by sigma.

A zero return whose within-image offsets are both zero is exactly an inherited
balanced cut. Hence every interior zero return of the image of an irreducible
parent is misaligned with at least one level-1 source-image boundary.

For a finite strict child-closed component C, recursive factorization gives a
second exact fact: all iterates sigma^n(T) have zero-return gaps bounded by the
maximum state length in C, independently of n.

No Pisot contraction is used here. These are the finite-return and finite-
offset inputs for the next recognizability/contraction step.
"""

from __future__ import annotations

from bisect import bisect_right
from dataclasses import dataclass
from typing import Sequence

from .bpa import (
    State,
    Substitution,
    alphabet_size,
    apply_substitution,
    apply_substitution_n,
    children,
    coincidence_boundaries,
    normalize_state,
    parikh,
)
from .fixed_vector import add as _add_vectors, matvec as _matvec, sub as _sub_vectors
from .intertwiner import substitution_incidence

Vector = tuple[int, ...]


@dataclass(frozen=True)
class InflatedPrefixLift:
    """Canonical source/local decomposition of one aligned inflated cut."""

    output_cut: int
    top_source_index: int
    bottom_source_index: int
    top_offset: int
    bottom_offset: int
    source_difference: Vector
    local_difference: Vector
    inflated_difference: Vector

    @property
    def source_index_offset(self) -> int:
        return self.top_source_index - self.bottom_source_index

    @property
    def is_zero_return(self) -> bool:
        return all(x == 0 for x in self.inflated_difference)

    @property
    def source_aligned_on_both_sides(self) -> bool:
        return self.top_offset == 0 and self.bottom_offset == 0


def _det3(matrix: Sequence[Sequence[int]]) -> int:
    if len(matrix) != 3 or any(len(row) != 3 for row in matrix):
        raise ValueError("det3 expects a 3x3 matrix")
    a, b, c = matrix[0]
    d, e, f = matrix[1]
    g, h, i = matrix[2]
    return a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g)


def prefix_difference(
    u: Sequence[int],
    v: Sequence[int],
    cut: int,
    size: int | None = None,
) -> Vector:
    """Parikh(u[:cut])-Parikh(v[:cut]) for a common aligned cut."""
    if cut < 0 or cut > min(len(u), len(v)):
        raise ValueError("aligned cut lies outside one side")
    if size is None:
        size = max(max(u, default=0), max(v, default=0))
    return _sub_vectors(parikh(u[:cut], size), parikh(v[:cut], size))


def asynchronous_prefix_difference(
    u: Sequence[int],
    v: Sequence[int],
    top_cut: int,
    bottom_cut: int,
    size: int | None = None,
) -> Vector:
    """Parikh difference at possibly different source indices."""
    if top_cut < 0 or top_cut > len(u) or bottom_cut < 0 or bottom_cut > len(v):
        raise ValueError("source cut lies outside one side")
    if size is None:
        size = max(max(u, default=0), max(v, default=0))
    return _sub_vectors(parikh(u[:top_cut], size), parikh(v[:bottom_cut], size))


def image_prefix_lengths(sigma: Substitution, word: Sequence[int]) -> tuple[int, ...]:
    """Output positions of source-letter boundaries, including both ends."""
    out = [0]
    for a in word:
        out.append(out[-1] + len(sigma[a]))
    return tuple(out)


def locate_inflated_cut(
    sigma: Substitution,
    word: Sequence[int],
    output_cut: int,
) -> tuple[int, int]:
    """Return (completed source letters, offset into the next image).

    At an exact source-letter boundary the offset is zero and the source index
    is the number of completed letters. At the terminal boundary the source
    index is len(word) and the offset is zero.
    """
    positions = image_prefix_lengths(sigma, word)
    total = positions[-1]
    if output_cut < 0 or output_cut > total:
        raise ValueError("inflated cut lies outside word")
    if output_cut == total:
        return len(word), 0
    source_index = bisect_right(positions, output_cut) - 1
    return source_index, output_cut - positions[source_index]


def local_image_prefix_vector(
    sigma: Substitution,
    word: Sequence[int],
    source_index: int,
    offset: int,
    size: int | None = None,
) -> Vector:
    """Parikh vector of the partial image after completed source letters."""
    if size is None:
        size = alphabet_size(sigma)
    if source_index == len(word):
        if offset != 0:
            raise ValueError("terminal source index only admits offset zero")
        return (0,) * size
    if source_index < 0 or source_index >= len(word):
        raise ValueError("source index outside word")
    image = sigma[word[source_index]]
    if offset < 0 or offset >= len(image):
        raise ValueError("canonical within-image offset must be a proper prefix")
    return parikh(image[:offset], size)


def inflated_prefix_lift(
    sigma: Substitution,
    state: State,
    output_cut: int,
) -> InflatedPrefixLift:
    """Decompose an aligned cut in (sigma(u),sigma(v)) exactly."""
    size = alphabet_size(sigma)
    u, v = state
    if parikh(u, size) != parikh(v, size):
        raise ValueError("prefix lift requires a balanced state")
    su = apply_substitution(sigma, u)
    sv = apply_substitution(sigma, v)
    if len(su) != len(sv):
        raise AssertionError("balanced-state images have unequal total length")
    if output_cut < 0 or output_cut > len(su):
        raise ValueError("output cut outside inflated state")

    i, r = locate_inflated_cut(sigma, u, output_cut)
    j, s = locate_inflated_cut(sigma, v, output_cut)
    source = asynchronous_prefix_difference(u, v, i, j, size)
    top_local = local_image_prefix_vector(sigma, u, i, r, size)
    bottom_local = local_image_prefix_vector(sigma, v, j, s, size)
    local = _sub_vectors(top_local, bottom_local)
    direct = prefix_difference(su, sv, output_cut, size)
    reconstructed = _add_vectors(_matvec(substitution_incidence(sigma), source), local)
    if reconstructed != direct:
        raise AssertionError("prefix-difference inflation identity failed")

    return InflatedPrefixLift(
        output_cut=output_cut,
        top_source_index=i,
        bottom_source_index=j,
        top_offset=r,
        bottom_offset=s,
        source_difference=source,
        local_difference=local,
        inflated_difference=direct,
    )


def aligned_zero_return_source_cut(
    sigma: Substitution,
    state: State,
    output_cut: int,
) -> int | None:
    """Return the inherited source cut iff a zero return is source-aligned twice.

    Under det(M)!=0, if a zero return of sigma(state) has offset zero on both
    sides, then M*E=0, so E=0. Hence its source indices agree and that common
    index is an old balanced cut. Conversely every old balanced cut maps to
    exactly such a doubly source-aligned zero return.
    """
    m = substitution_incidence(sigma)
    if len(m) != 3 or any(len(row) != 3 for row in m):
        raise ValueError("aligned-cut characterization currently requires three letters")
    if _det3(m) == 0:
        raise ValueError("aligned-cut characterization requires det(M) != 0")
    lift = inflated_prefix_lift(sigma, state, output_cut)
    if not lift.is_zero_return or not lift.source_aligned_on_both_sides:
        return None
    if any(lift.source_difference):
        raise AssertionError("invertible M allowed a nonzero aligned zero-return source defect")
    if lift.top_source_index != lift.bottom_source_index:
        raise AssertionError("zero Parikh source defect has unequal source lengths")
    return lift.top_source_index


def zero_return_lifts(sigma: Substitution, state: State) -> tuple[InflatedPrefixLift, ...]:
    """Canonical ancestry data for every zero return of sigma(state)."""
    size = alphabet_size(sigma)
    u, v = state
    su = apply_substitution(sigma, u)
    sv = apply_substitution(sigma, v)
    return tuple(
        inflated_prefix_lift(sigma, state, cut)
        for cut in coincidence_boundaries(su, sv, size)
    )


def proper_image_prefix_vectors(sigma: Substitution) -> tuple[Vector, ...]:
    """Finite set of Parikh vectors of canonical within-image prefixes."""
    size = alphabet_size(sigma)
    values = {(0,) * size}
    for image in sigma.values():
        for offset in range(len(image)):
            values.add(parikh(image[:offset], size))
    return tuple(sorted(values))


def possible_local_corrections(sigma: Substitution) -> tuple[Vector, ...]:
    """Finite correction alphabet c_sigma for the inflation identity."""
    prefixes = proper_image_prefix_vectors(sigma)
    return tuple(sorted({_sub_vectors(a, b) for a in prefixes for b in prefixes}))


def zero_return_source_defects_seen(
    sigma: Substitution,
    states: Sequence[State],
) -> tuple[Vector, ...]:
    """Distinct E values actually occurring at one-step zero returns."""
    return tuple(
        sorted(
            {
                lift.source_difference
                for state in states
                for lift in zero_return_lifts(sigma, state)
                if lift.is_zero_return
            }
        )
    )


def source_offset_bound_from_corrections(sigma: Substitution) -> int:
    """Exact sigma-only bound on |i-j| for any inflated zero return.

    We enumerate the finite local correction alphabet and retain precisely those
    c for which M E = -c has an integer solution E. For the three-letter case
    this is computed through the adjugate identity.
    """
    if alphabet_size(sigma) != 3:
        raise ValueError("sigma-only source-offset bound currently requires three letters")
    m = substitution_incidence(sigma)
    a, b, c = m[0]
    d, e, f = m[1]
    g, h, i = m[2]
    det = a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g)
    if det == 0:
        raise ValueError("source-offset bound requires det(M) != 0")
    adj = (
        (e * i - f * h, c * h - b * i, b * f - c * e),
        (f * g - d * i, a * i - c * g, c * d - a * f),
        (d * h - e * g, b * g - a * h, a * e - b * d),
    )
    bound = 0
    for corr in possible_local_corrections(sigma):
        numer = _matvec(adj, tuple(-x for x in corr))
        if all(x % det == 0 for x in numer):
            defect = tuple(x // det for x in numer)
            bound = max(bound, abs(sum(defect)))
    return bound


def strict_child_closed(sigma: Substitution, comp: Sequence[State]) -> bool:
    """Every state is balanced/noncoincident and every normalized child stays in comp."""
    comp_set = {normalize_state(state) for state in comp}
    if not comp_set:
        return False
    size = alphabet_size(sigma)
    if any(u == v or parikh(u, size) != parikh(v, size) for u, v in comp_set):
        return False
    return all(child in comp_set for state in comp_set for child in children(sigma, state))


def component_block_bound(comp: Sequence[State]) -> int:
    if not comp:
        raise ValueError("component must be nonempty")
    if any(len(u) != len(v) for u, v in comp):
        raise ValueError("component states must have equal side lengths")
    return max(len(u) for u, _v in comp)


def iterated_zero_return_max_gap(
    sigma: Substitution,
    state: State,
    depth: int,
) -> int:
    """Maximum gap between zero returns in sigma^depth(state)."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    size = alphabet_size(sigma)
    u, v = state
    su = apply_substitution_n(sigma, u, depth)
    sv = apply_substitution_n(sigma, v, depth)
    cuts = coincidence_boundaries(su, sv, size)
    if len(cuts) < 2:
        return len(su)
    return max(cuts[k + 1] - cuts[k] for k in range(len(cuts) - 1))


def verify_uniform_return_gap(
    sigma: Substitution,
    comp: Sequence[State],
    max_depth: int,
) -> bool:
    """Finite regression for the strict-component bounded-gap theorem."""
    if max_depth < 0:
        raise ValueError("max_depth must be nonnegative")
    if not strict_child_closed(sigma, comp):
        raise ValueError("component must be strict, balanced, and child-closed")
    bound = component_block_bound(comp)
    return all(
        iterated_zero_return_max_gap(sigma, state, depth) <= bound
        for state in comp
        for depth in range(max_depth + 1)
    )
