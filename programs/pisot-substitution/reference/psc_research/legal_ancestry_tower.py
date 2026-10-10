"""Legal-context towers along multi-level zero-return ancestry.

A radius-R context around a cut is certainly legal when the cut lies R symbols
inside one level-n image of a single original source letter.  This module makes
that protection stable for a prescribed number of desubstitution steps.

If L=max_a |sigma(a)| and a source cut lies fewer than m symbols from the end
of a source-letter supertile, then any point in its image lies fewer than
(m+1)L symbols from the corresponding image-supertil e end.  Contrapositively,
large enough margin upstairs forces margin downstairs.  Iterating this gives a
simple conservative margin recurrence.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Sequence

from .bpa import State, Substitution, alphabet_size, apply_substitution_n, coincidence_boundaries, parikh
from .legal_cut_context import (
    context_inside_one_source_supertile,
    level_n_source_blocks,
    single_supertile_zero_returns,
)
from .prefix_ancestry import AncestryPath, top_zero_return_ancestry


@dataclass(frozen=True)
class LegalAncestryTower:
    """A top zero return with legal source-supertile contexts down several levels."""

    depth: int
    cut: int
    radius: int
    descent_levels: int
    required_top_margin: int
    ancestry: AncestryPath


def descent_margin(radius: int, descent_levels: int, max_image_length: int) -> int:
    """Safe top-level margin protecting radius-R legality for L descents.

    The recurrence m <- (m+1)*max_image_length is intentionally conservative;
    exact image lengths can only improve it.
    """
    if radius < 0 or descent_levels < 0:
        raise ValueError("radius and descent_levels must be nonnegative")
    if max_image_length <= 0:
        raise ValueError("max image length must be positive")
    margin = radius
    for _ in range(descent_levels):
        margin = (margin + 1) * max_image_length
    return margin


def substitution_max_image_length(sigma: Substitution) -> int:
    if not sigma:
        raise ValueError("substitution must be nonempty")
    maximum = max(len(image) for image in sigma.values())
    if maximum <= 0:
        raise ValueError("substitution must be non-erasing")
    return maximum


def _context_legal_at_base_letter_scale(
    sigma: Substitution,
    state: State,
    depth: int,
    top_cut: int,
    bottom_cut: int,
    radius: int,
) -> bool:
    top_blocks = level_n_source_blocks(sigma, state[0], depth)
    bottom_blocks = level_n_source_blocks(sigma, state[1], depth)
    return context_inside_one_source_supertile(top_blocks, top_cut, radius) and context_inside_one_source_supertile(
        bottom_blocks, bottom_cut, radius
    )


def verify_legal_ancestry_tower(
    sigma: Substitution,
    state: State,
    depth: int,
    cut: int,
    *,
    radius: int,
    descent_levels: int,
) -> LegalAncestryTower:
    """Verify legality of the top cut and its first ``descent_levels`` ancestors."""
    if depth < 1:
        raise ValueError("tower depth must be positive")
    if descent_levels < 0 or descent_levels > depth:
        raise ValueError("descent_levels must lie in 0..depth")
    size = alphabet_size(sigma)
    u, v = state
    if parikh(u, size) != parikh(v, size):
        raise ValueError("legal ancestry tower requires a balanced state")
    top = apply_substitution_n(sigma, u, depth)
    bottom = apply_substitution_n(sigma, v, depth)
    if len(top) != len(bottom):
        raise AssertionError("balanced iterates have unequal length")
    if cut not in coincidence_boundaries(top, bottom, size):
        raise ValueError("tower top cut must be a zero return")

    max_image_length = substitution_max_image_length(sigma)
    required_margin = descent_margin(radius, descent_levels, max_image_length)
    if cut not in single_supertile_zero_returns(sigma, state, depth, required_margin):
        raise ValueError("top cut lacks the margin required for the requested legal tower")

    ancestry = top_zero_return_ancestry(sigma, state, depth, cut)
    if not _context_legal_at_base_letter_scale(sigma, state, depth, cut, cut, radius):
        raise AssertionError("protected top context is not legal")

    for descent in range(1, descent_levels + 1):
        step = ancestry.steps[-descent]
        source_depth = step.level - 1
        if not _context_legal_at_base_letter_scale(
            sigma,
            state,
            source_depth,
            step.top_source_cut,
            step.bottom_source_cut,
            radius,
        ):
            raise AssertionError("margin recurrence failed to protect a lower legal context")

    return LegalAncestryTower(
        depth=depth,
        cut=cut,
        radius=radius,
        descent_levels=descent_levels,
        required_top_margin=required_margin,
        ancestry=ancestry,
    )


def legal_tower_zero_returns(
    sigma: Substitution,
    state: State,
    depth: int,
    *,
    radius: int,
    descent_levels: int,
) -> tuple[int, ...]:
    """Zero returns whose top margin certifies a legal ancestry tower."""
    if descent_levels < 0 or descent_levels > depth:
        raise ValueError("descent_levels must lie in 0..depth")
    margin = descent_margin(radius, descent_levels, substitution_max_image_length(sigma))
    return single_supertile_zero_returns(sigma, state, depth, margin)


def first_legal_ancestry_tower(
    sigma: Substitution,
    state: State,
    depth: int,
    *,
    radius: int,
    descent_levels: int,
) -> LegalAncestryTower | None:
    """Return the first certified legal tower at this depth, if one exists."""
    cuts = legal_tower_zero_returns(
        sigma,
        state,
        depth,
        radius=radius,
        descent_levels=descent_levels,
    )
    if not cuts:
        return None
    return verify_legal_ancestry_tower(
        sigma,
        state,
        depth,
        cuts[0],
        radius=radius,
        descent_levels=descent_levels,
    )


def tower_count_forces_existence(
    *,
    state: State,
    total_length: int,
    max_zero_return_gap: int,
    radius: int,
    descent_levels: int,
    max_image_length: int,
) -> bool:
    """Safe finite criterion guaranteeing at least one protected tower top.

    The union of top/bottom original-letter supertile boundaries has at most
    ``len(u)+len(v)+2`` members with multiplicity ignored.  Around each such
    barrier we exclude the conservative top margin.  If the bounded-gap lower
    bound on zero returns exceeds that bad-position count, one zero return lies
    safely inside one original-letter supertile on both sides and therefore
    carries the requested legal ancestry tower.
    """
    if total_length < 0:
        raise ValueError("total length must be nonnegative")
    if max_zero_return_gap <= 0:
        raise ValueError("max zero-return gap must be positive")
    margin = descent_margin(radius, descent_levels, max_image_length)
    u, v = state
    bad_positions = (len(u) + len(v) + 2) * (2 * margin + 1)
    zero_return_lower_bound = (total_length + max_zero_return_gap - 1) // max_zero_return_gap + 1
    return zero_return_lower_bound > bad_positions
