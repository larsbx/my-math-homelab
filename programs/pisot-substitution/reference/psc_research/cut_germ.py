"""Finite decorated cut germs for the C4 recognizability route.

The Pisot ancestry theorem makes the Parikh-defect coordinate of a deep cut
finite-state.  This module adds only finite local information around each cut:
within-image offsets, the one-step correction digit, and a bounded word context
on each side.  For any fixed context radius this therefore remains a finite
state space.

The construction is deliberately weaker than a recognizability theorem.  A
repeated decorated germ is a finite-pigeon consequence, not a contradiction:
Tribonacci already has a repeated nonzero radius-1 germ along a legal
zero-return ancestry.  The missing C4 step must additionally use the strict
nonproductive/nonsynchronizing regime.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Sequence

from .bpa import State, Substitution, alphabet_size, apply_substitution_n
from .prefix_ancestry import AncestryPath, AncestryStep, multilevel_prefix_ancestry
from .prefix_difference import Vector


@dataclass(frozen=True)
class CutContext:
    """Radius-R local word content around one cut.

    ``0`` is used only as an exterior sentinel; repository letters are positive
    integers.  Both tuples always have length ``radius``.
    """

    left: tuple[int, ...]
    right: tuple[int, ...]


@dataclass(frozen=True)
class CutGerm:
    """Level-free finite data attached to one ancestry transition."""

    source_difference: Vector
    correction: Vector
    top_offset: int
    bottom_offset: int
    top_context: CutContext
    bottom_context: CutContext

    @property
    def source_aligned_on_both_sides(self) -> bool:
        return self.top_offset == 0 and self.bottom_offset == 0


@dataclass(frozen=True)
class LevelledCutGerm:
    level: int
    germ: CutGerm


def cut_context(word: Sequence[int], cut: int, radius: int) -> CutContext:
    """Return a fixed-width local context around ``cut``.

    Boundary truncation is encoded with the sentinel ``0`` so equality of
    contexts also remembers whether the observed cut is near a finite-word end.
    """
    if radius < 0:
        raise ValueError("context radius must be nonnegative")
    if cut < 0 or cut > len(word):
        raise ValueError("cut lies outside word")
    if radius == 0:
        return CutContext((), ())

    left_raw = tuple(word[max(0, cut - radius) : cut])
    right_raw = tuple(word[cut : min(len(word), cut + radius)])
    left = (0,) * (radius - len(left_raw)) + left_raw
    right = right_raw + (0,) * (radius - len(right_raw))
    return CutContext(left, right)


def germ_from_step(
    sigma: Substitution,
    state: State,
    step: AncestryStep,
    radius: int,
) -> CutGerm:
    """Decorate one exact ancestry step with finite local output contexts."""
    if step.level < 1:
        raise ValueError("ancestry step level must be positive")
    top_word = apply_substitution_n(sigma, state[0], step.level)
    bottom_word = apply_substitution_n(sigma, state[1], step.level)
    return CutGerm(
        source_difference=step.source_difference,
        correction=step.correction,
        top_offset=step.top_offset,
        bottom_offset=step.bottom_offset,
        top_context=cut_context(top_word, step.top_output_cut, radius),
        bottom_context=cut_context(bottom_word, step.bottom_output_cut, radius),
    )


def decorate_ancestry_path(
    sigma: Substitution,
    state: State,
    path: AncestryPath,
    radius: int,
) -> tuple[LevelledCutGerm, ...]:
    """Attach radius-R local contexts to every transition in an ancestry path."""
    if path.depth != len(path.steps):
        raise ValueError("ancestry path depth does not match its step count")
    return tuple(
        LevelledCutGerm(step.level, germ_from_step(sigma, state, step, radius))
        for step in path.steps
    )


def decorated_prefix_ancestry(
    sigma: Substitution,
    state: State,
    depth: int,
    top_cut: int,
    bottom_cut: int | None = None,
    *,
    radius: int,
) -> tuple[LevelledCutGerm, ...]:
    """Construct and decorate a multi-level cut ancestry in one call."""
    path = multilevel_prefix_ancestry(
        sigma,
        state,
        depth,
        top_cut,
        bottom_cut,
    )
    return decorate_ancestry_path(sigma, state, path, radius)


def repeated_germ_level_pairs(
    germs: Sequence[LevelledCutGerm],
) -> tuple[tuple[int, int], ...]:
    """All earlier/later level pairs carrying exactly the same finite germ."""
    first_levels: dict[CutGerm, list[int]] = {}
    repeats: list[tuple[int, int]] = []
    for item in germs:
        prior = first_levels.setdefault(item.germ, [])
        repeats.extend((old, item.level) for old in prior)
        prior.append(item.level)
    return tuple(repeats)


def distinct_germs(germs: Iterable[LevelledCutGerm]) -> frozenset[CutGerm]:
    return frozenset(item.germ for item in germs)


def germ_space_upper_bound(
    *,
    defect_count: int,
    correction_count: int,
    letter_count: int,
    max_image_length: int,
    radius: int,
) -> int:
    """Coarse finite bound for a fixed-radius decorated germ alphabet.

    If the ancestry-defect alphabet has size ``defect_count`` and the local
    correction alphabet has size ``correction_count``, then each side has at
    most ``max_image_length`` canonical offsets and ``(letter_count+1)^(2R)``
    sentinel-padded contexts.  Multiplying gives a safe overcount.
    """
    values = (defect_count, correction_count, letter_count, max_image_length, radius)
    if any(value < 0 for value in values):
        raise ValueError("germ-space parameters must be nonnegative")
    if defect_count == 0 or correction_count == 0:
        return 0
    if letter_count == 0 or max_image_length == 0:
        raise ValueError("nonempty germ alphabets require letters and image length")
    return (
        defect_count
        * correction_count
        * max_image_length**2
        * (letter_count + 1) ** (4 * radius)
    )


def substitution_context_parameters(sigma: Substitution) -> tuple[int, int]:
    """Return (alphabet size, maximum image length) for bound calculations."""
    size = alphabet_size(sigma)
    if size == 0 or not sigma:
        raise ValueError("substitution must be nonempty")
    return size, max(len(image) for image in sigma.values())
