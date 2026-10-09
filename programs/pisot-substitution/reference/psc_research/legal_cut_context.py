"""Certified legal local contexts for deep balanced-pair zero returns.

Repository BPA states are generated from every swap seed and need not themselves
be factors of the substitution language.  Mossé recognizability therefore
cannot be applied blindly to arbitrary finite BPA words.

For a fixed base word w, however, sigma^n(w) is a concatenation of the finitely
many level-n letter supertiles sigma^n(a).  A radius-R cut context that stays
inside one such supertile is a legal language context for primitive sigma.  In a
finite strict child-closed component, the uniform zero-return gap theorem gives
linearly many zero returns while only finitely many positions lie near the
original source-letter junctions.  Hence sufficiently deep iterates contain
zero returns whose radius-R contexts are certified legal on both sides.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Sequence

from .bpa import (
    State,
    Substitution,
    alphabet_size,
    apply_substitution_n,
    coincidence_boundaries,
    parikh,
)


@dataclass(frozen=True)
class SourceSupertileBlock:
    """One level-n image of an original source letter inside sigma^n(word)."""

    source_index: int
    letter: int
    start: int
    end: int

    @property
    def length(self) -> int:
        return self.end - self.start


def level_n_source_blocks(
    sigma: Substitution,
    word: Sequence[int],
    depth: int,
) -> tuple[SourceSupertileBlock, ...]:
    """Decompose sigma^depth(word) into images of the original source letters."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    blocks: list[SourceSupertileBlock] = []
    cursor = 0
    for index, letter in enumerate(word):
        image_length = len(apply_substitution_n(sigma, (letter,), depth))
        blocks.append(SourceSupertileBlock(index, letter, cursor, cursor + image_length))
        cursor += image_length
    return tuple(blocks)


def context_inside_one_source_supertile(
    blocks: Sequence[SourceSupertileBlock],
    cut: int,
    radius: int,
) -> bool:
    """Whether [cut-R, cut+R) stays inside one original-letter supertile."""
    if radius < 0:
        raise ValueError("context radius must be nonnegative")
    if not blocks:
        return radius == 0 and cut == 0
    total = blocks[-1].end
    if cut < 0 or cut > total:
        raise ValueError("cut lies outside source-block decomposition")
    return any(block.start <= cut - radius and cut + radius <= block.end for block in blocks)


def single_supertile_zero_returns(
    sigma: Substitution,
    state: State,
    depth: int,
    radius: int,
) -> tuple[int, ...]:
    """Interior zero returns with radius-R context inside one supertile per side.

    For primitive substitutions, every returned top and bottom radius-R context
    is a factor of some sigma^depth(a), hence is a legal hull context.  The
    function itself checks only the finite containment statement and does not
    attempt to decide primitivity or recognizability.
    """
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    if radius < 0:
        raise ValueError("context radius must be nonnegative")
    size = alphabet_size(sigma)
    u, v = state
    if parikh(u, size) != parikh(v, size):
        raise ValueError("legal-context extraction requires a balanced state")
    top = apply_substitution_n(sigma, u, depth)
    bottom = apply_substitution_n(sigma, v, depth)
    if len(top) != len(bottom):
        raise AssertionError("balanced iterates have unequal lengths")
    top_blocks = level_n_source_blocks(sigma, u, depth)
    bottom_blocks = level_n_source_blocks(sigma, v, depth)
    return tuple(
        cut
        for cut in coincidence_boundaries(top, bottom, size)
        if 0 < cut < len(top)
        and context_inside_one_source_supertile(top_blocks, cut, radius)
        and context_inside_one_source_supertile(bottom_blocks, cut, radius)
    )


def bad_context_position_upper_bound(state: State, radius: int) -> int:
    """Safe depth-independent bound on cuts too close to source-word junctions.

    There are len(u)+1 source-block boundaries on the top and len(v)+1 on the
    bottom.  Each excludes at most 2R+1 integer cut positions.  The union can be
    smaller; this intentionally overcounts.
    """
    if radius < 0:
        raise ValueError("context radius must be nonnegative")
    u, v = state
    return (len(u) + len(v) + 2) * (2 * radius + 1)


def zero_return_count_lower_bound(total_length: int, max_gap: int) -> int:
    """Minimum number of zero-return cuts when endpoints are returns and gaps <=B."""
    if total_length < 0:
        raise ValueError("total length must be nonnegative")
    if max_gap <= 0:
        raise ValueError("max gap must be positive")
    intervals = (total_length + max_gap - 1) // max_gap
    return intervals + 1


def count_forces_single_supertile_context(
    *,
    state: State,
    total_length: int,
    max_zero_return_gap: int,
    radius: int,
) -> bool:
    """Pigeonhole criterion guaranteeing a radius-R good zero return.

    If the lower bound on the number of zero-return positions exceeds the safe
    upper bound on positions lying near any original source-letter boundary,
    at least one zero return has a radius-R context contained in a single
    level-n source supertile on both sides.  Such a cut is automatically
    interior because endpoint neighborhoods are included among the bad
    positions.
    """
    return zero_return_count_lower_bound(total_length, max_zero_return_gap) > bad_context_position_upper_bound(
        state, radius
    )
